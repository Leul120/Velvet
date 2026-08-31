package com.velvet.api.notify;

import com.velvet.api.admin.service.StaffShiftService;
import com.velvet.api.common.config.VelvetProperties;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.notify.domain.DeviceTokenEntity;
import com.velvet.api.notify.push.PushGateway;
import com.velvet.api.notify.repo.DeviceTokenRepository;
import com.velvet.api.notify.sms.SmsGateway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class ConciergeNotifyService {

    private static final Logger log = LoggerFactory.getLogger(ConciergeNotifyService.class);

    private final NotificationOutboxRepository outboxRepository;
    private final VelvetProperties properties;
    private final SmsGateway smsGateway;
    private final PushGateway pushGateway;
    private final DeviceTokenRepository deviceTokenRepository;
    private final UserRepository userRepository;
    private final StaffShiftService staffShiftService;
    private final com.velvet.api.admin.sse.AdminSseRegistry adminSseRegistry;

    public ConciergeNotifyService(
            NotificationOutboxRepository outboxRepository,
            VelvetProperties properties,
            SmsGateway smsGateway,
            PushGateway pushGateway,
            DeviceTokenRepository deviceTokenRepository,
            UserRepository userRepository,
            StaffShiftService staffShiftService,
            com.velvet.api.admin.sse.AdminSseRegistry adminSseRegistry
    ) {
        this.outboxRepository = outboxRepository;
        this.properties = properties;
        this.smsGateway = smsGateway;
        this.pushGateway = pushGateway;
        this.deviceTokenRepository = deviceTokenRepository;
        this.userRepository = userRepository;
        this.staffShiftService = staffShiftService;
        this.adminSseRegistry = adminSseRegistry;
    }

    @Transactional
    public void notifyPanic(String alertId, String userId, String note, Double lat, Double lng) {
        String body = "VELVET PANIC id=%s user=%s note=%s loc=%s,%s"
                .formatted(alertId, userId, note == null ? "-" : note, lat, lng);
        dispatch("VELVET PANIC", body, "PANIC", alertId, true);
        adminSseRegistry.broadcast("PANIC_ALERT", java.util.Map.of(
                "alertId", alertId,
                "userId", userId,
                "note", note == null ? "" : note
        ));
    }

    @Transactional
    public void notifyReport(String reportId, String category, String details) {
        String body = "VELVET REPORT id=%s category=%s details=%s"
                .formatted(reportId, category, truncate(details, 200));
        dispatch("VELVET REPORT", body, "REPORT", reportId, false);
        adminSseRegistry.broadcast("SAFETY_REPORT", java.util.Map.of(
                "reportId", reportId,
                "category", category,
                "details", details
        ));
    }


    @Transactional
    public void notifyOps(String subject, String body, String relatedType, String relatedId) {
        dispatch(subject, body, relatedType, relatedId, false);
    }

    @Transactional(readOnly = true)
    public List<NotificationOutboxEntity> recent(int limit) {
        return outboxRepository.findTop50ByOrderByCreatedAtDesc().stream().limit(Math.max(1, limit)).toList();
    }

    private void dispatch(String subject, String body, String relatedType, String relatedId, boolean smsUrgent) {
        if (smsUrgent) {
            for (String phone : urgentSmsRecipients()) {
                String status = "SENT";
                try {
                    smsGateway.send(phone, body);
                } catch (Exception e) {
                    status = "FAILED";
                    log.error("Failed concierge SMS to {}", phone, e);
                }
                outboxRepository.save(NotificationOutboxEntity.builder()
                        .channel("SMS")
                        .recipient(phone)
                        .subject(subject)
                        .body(body)
                        .relatedType(relatedType)
                        .relatedId(relatedId)
                        .status(status)
                        .build());
            }
        }

        List<UUID> staffIds = urgentPushRecipients();
        List<DeviceTokenEntity> tokens = staffIds.isEmpty()
                ? List.of()
                : deviceTokenRepository.findByUserIdInAndActiveTrue(staffIds);
        for (DeviceTokenEntity token : tokens) {
            String status = "SENT";
            try {
                pushGateway.send(token.getToken(), subject, body);
            } catch (Exception e) {
                status = "FAILED";
                log.error("Failed push to user {}", token.getUserId(), e);
            }
            outboxRepository.save(NotificationOutboxEntity.builder()
                    .channel("PUSH")
                    .recipient(token.getUserId().toString())
                    .subject(subject)
                    .body(body)
                    .relatedType(relatedType)
                    .relatedId(relatedId)
                    .status(status)
                    .build());
        }

        outboxRepository.save(NotificationOutboxEntity.builder()
                .channel("LOG")
                .recipient("ops")
                .subject(subject)
                .body(body)
                .relatedType(relatedType)
                .relatedId(relatedId)
                .status("SENT")
                .build());
    }

    /** Prefer on-call shift phones; fall back to configured concierge SMS list. */
    private List<String> urgentSmsRecipients() {
        Set<String> phones = new LinkedHashSet<>();
        for (var shift : staffShiftService.onCall(Instant.now())) {
            userRepository.findById(UUID.fromString(shift.userId()))
                    .map(UserEntity::getPhoneE164)
                    .ifPresent(phones::add);
        }
        if (phones.isEmpty()) {
            phones.addAll(conciergePhones());
        }
        return new ArrayList<>(phones);
    }

    private List<UUID> urgentPushRecipients() {
        List<UUID> onCall = staffShiftService.onCall(Instant.now()).stream()
                .map(s -> UUID.fromString(s.userId()))
                .toList();
        if (!onCall.isEmpty()) {
            return onCall;
        }
        return userRepository.findByRoleIn(List.of(UserRole.ADMIN, UserRole.CONCIERGE))
                .stream()
                .map(UserEntity::getId)
                .toList();
    }

    private List<String> conciergePhones() {
        VelvetProperties.Concierge cfg = properties.concierge();
        if (cfg == null || cfg.smsPhones() == null || cfg.smsPhones().isBlank()) {
            return List.of("+251911000000");
        }
        return Arrays.stream(cfg.smsPhones().split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .toList();
    }

    private static String truncate(String s, int max) {
        if (s == null) {
            return "-";
        }
        return s.length() <= max ? s : s.substring(0, max) + "…";
    }
}
