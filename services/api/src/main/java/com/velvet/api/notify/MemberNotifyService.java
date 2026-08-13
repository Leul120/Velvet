package com.velvet.api.notify;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.notify.domain.DeviceTokenEntity;
import com.velvet.api.notify.domain.MemberNotificationEntity;
import com.velvet.api.notify.push.PushGateway;
import com.velvet.api.notify.repo.DeviceTokenRepository;
import com.velvet.api.notify.repo.MemberNotificationRepository;
import com.velvet.api.notify.web.dto.NotifyDtos;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Collection;
import java.util.List;
import java.util.UUID;

@Service
public class MemberNotifyService {

    private static final Logger log = LoggerFactory.getLogger(MemberNotifyService.class);

    private final DeviceTokenRepository deviceTokenRepository;
    private final PushGateway pushGateway;
    private final NotificationOutboxRepository outboxRepository;
    private final MemberNotificationRepository inboxRepository;

    public MemberNotifyService(
            DeviceTokenRepository deviceTokenRepository,
            PushGateway pushGateway,
            NotificationOutboxRepository outboxRepository,
            MemberNotificationRepository inboxRepository
    ) {
        this.deviceTokenRepository = deviceTokenRepository;
        this.pushGateway = pushGateway;
        this.outboxRepository = outboxRepository;
        this.inboxRepository = inboxRepository;
    }

    @Transactional
    public void notifyUsers(Collection<UUID> userIds, String subject, String body, String relatedType, String relatedId) {
        if (userIds == null || userIds.isEmpty()) {
            return;
        }
        for (UUID userId : userIds) {
            inboxRepository.save(MemberNotificationEntity.builder()
                    .userId(userId)
                    .subject(subject)
                    .body(body)
                    .relatedType(relatedType)
                    .relatedId(relatedId)
                    .build());

            List<DeviceTokenEntity> tokens = deviceTokenRepository.findByUserIdAndActiveTrue(userId);
            if (tokens.isEmpty()) {
                outboxRepository.save(NotificationOutboxEntity.builder()
                        .channel("LOG")
                        .recipient(userId.toString())
                        .subject(subject)
                        .body(body)
                        .relatedType(relatedType)
                        .relatedId(relatedId)
                        .status("NO_TOKEN")
                        .build());
                continue;
            }
            for (DeviceTokenEntity token : tokens) {
                String status = "SENT";
                try {
                    pushGateway.send(token.getToken(), subject, body);
                } catch (Exception e) {
                    status = "FAILED";
                    log.error("Member push failed user={}", userId, e);
                }
                outboxRepository.save(NotificationOutboxEntity.builder()
                        .channel("PUSH")
                        .recipient(userId.toString())
                        .subject(subject)
                        .body(body)
                        .relatedType(relatedType)
                        .relatedId(relatedId)
                        .status(status)
                        .build());
            }
        }
    }

    @Transactional
    public void notifyUser(UUID userId, String subject, String body, String relatedType, String relatedId) {
        notifyUsers(List.of(userId), subject, body, relatedType, relatedId);
    }

    @Transactional(readOnly = true)
    public List<NotifyDtos.NotificationResponse> inbox(UUID userId, boolean unreadOnly) {
        List<MemberNotificationEntity> rows = unreadOnly
                ? inboxRepository.findTop50ByUserIdAndReadAtIsNullOrderByCreatedAtDesc(userId)
                : inboxRepository.findTop50ByUserIdOrderByCreatedAtDesc(userId);
        return rows.stream().map(this::toDto).toList();
    }

    @Transactional(readOnly = true)
    public long unreadCount(UUID userId) {
        return inboxRepository.countByUserIdAndReadAtIsNull(userId);
    }

    @Transactional
    public NotifyDtos.NotificationResponse markRead(UUID userId, UUID notificationId) {
        MemberNotificationEntity n = inboxRepository.findById(notificationId)
                .orElseThrow(() -> new BusinessException("NOTIF_NOT_FOUND", "Notification not found."));
        if (!n.getUserId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not your notification.");
        }
        if (n.getReadAt() == null) {
            n.setReadAt(Instant.now());
            inboxRepository.save(n);
        }
        return toDto(n);
    }

    @Transactional
    public int markAllRead(UUID userId) {
        List<MemberNotificationEntity> unread = inboxRepository.findByUserIdAndReadAtIsNull(userId);
        Instant now = Instant.now();
        unread.forEach(n -> n.setReadAt(now));
        return unread.size();
    }

    private NotifyDtos.NotificationResponse toDto(MemberNotificationEntity n) {
        return new NotifyDtos.NotificationResponse(
                n.getId().toString(),
                n.getSubject(),
                n.getBody(),
                n.getRelatedType(),
                n.getRelatedId(),
                n.getReadAt() != null,
                n.getCreatedAt()
        );
    }
}
