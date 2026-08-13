package com.velvet.api.waitlist.service;

import com.velvet.api.admin.service.AdminInviteService;
import com.velvet.api.admin.web.dto.AdminDtos;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.ratelimit.RateLimitService;
import com.velvet.api.notify.NotificationOutboxEntity;
import com.velvet.api.notify.NotificationOutboxRepository;
import com.velvet.api.notify.sms.SmsGateway;
import com.velvet.api.waitlist.domain.WaitlistApplicationEntity;
import com.velvet.api.waitlist.domain.WaitlistStatus;
import com.velvet.api.waitlist.repo.WaitlistApplicationRepository;
import com.velvet.api.waitlist.web.dto.WaitlistDtos;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class WaitlistService {

    private static final Logger log = LoggerFactory.getLogger(WaitlistService.class);

    private final WaitlistApplicationRepository waitlistRepository;
    private final AdminInviteService inviteService;
    private final RateLimitService rateLimitService;
    private final SmsGateway smsGateway;
    private final NotificationOutboxRepository outboxRepository;

    public WaitlistService(
            WaitlistApplicationRepository waitlistRepository,
            AdminInviteService inviteService,
            RateLimitService rateLimitService,
            SmsGateway smsGateway,
            NotificationOutboxRepository outboxRepository
    ) {
        this.waitlistRepository = waitlistRepository;
        this.inviteService = inviteService;
        this.rateLimitService = rateLimitService;
        this.smsGateway = smsGateway;
        this.outboxRepository = outboxRepository;
    }

    @Transactional
    public WaitlistDtos.ApplicationResponse apply(WaitlistDtos.ApplyRequest request) {
        String phone = normalizePhone(request.phoneE164());
        rateLimitService.checkWaitlist(phone);
        if (waitlistRepository.findByPhoneE164(phone).isPresent()) {
            throw new BusinessException("WAITLIST_APPLICATION_EXISTS", "A waitlist application already exists for this phone number.");
        }

        WaitlistApplicationEntity application = waitlistRepository.save(WaitlistApplicationEntity.builder()
                .phoneE164(phone)
                .displayName(blankToNull(request.displayName()))
                .city(defaultCity(request.city()))
                .note(blankToNull(request.note()))
                .status(WaitlistStatus.PENDING)
                .build());
        return toResponse(application);
    }

    @Transactional(readOnly = true)
    public List<WaitlistDtos.ApplicationResponse> listPending() {
        return waitlistRepository.findByStatusOrderByCreatedAtDesc(WaitlistStatus.PENDING).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<WaitlistDtos.ApplicationResponse> listAll() {
        return waitlistRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public WaitlistDtos.ApplicationResponse approve(UUID id, UUID reviewerId) {
        WaitlistApplicationEntity application = requirePending(id);
        AdminDtos.InviteResponse invite = inviteService.create(
                reviewerId,
                new AdminDtos.CreateInviteRequest(null, 1, 30)
        );
        application.setInviteCode(invite.code());
        application.setStatus(WaitlistStatus.APPROVED);
        application.setReviewedBy(reviewerId);
        application.setReviewedAt(Instant.now());
        WaitlistApplicationEntity saved = waitlistRepository.save(application);
        notifyInvite(saved.getPhoneE164(), invite.code());
        return toResponse(saved);
    }

    @Transactional
    public WaitlistDtos.ApplicationResponse reject(UUID id, UUID reviewerId) {
        WaitlistApplicationEntity application = requirePending(id);
        application.setStatus(WaitlistStatus.REJECTED);
        application.setReviewedBy(reviewerId);
        application.setReviewedAt(Instant.now());
        return toResponse(waitlistRepository.save(application));
    }

    @Transactional(readOnly = true)
    public WaitlistDtos.StatusResponse status(String phoneE164) {
        String phone = normalizePhone(phoneE164);
        WaitlistApplicationEntity application = waitlistRepository.findByPhoneE164(phone)
                .orElseThrow(() -> new BusinessException("WAITLIST_NOT_FOUND", "No waitlist application for this phone."));
        return new WaitlistDtos.StatusResponse(
                application.getStatus().name(),
                application.getInviteCode(),
                friendsApprovedCount(),
                application.getCreatedAt(),
                application.getReviewedAt()
        );
    }

    private void notifyInvite(String phone, String inviteCode) {
        String body = "VELVET invite approved. Your code is " + inviteCode
                + ". Open the app, enter the code with your phone, and verify OTP.";
        String status = "SENT";
        try {
            smsGateway.send(phone, body);
        } catch (Exception e) {
            status = "FAILED";
            log.warn("Failed waitlist invite SMS to {}", phone, e);
        }
        outboxRepository.save(NotificationOutboxEntity.builder()
                .channel("SMS")
                .recipient(phone)
                .subject("VELVET waitlist invite")
                .body(body)
                .relatedType("WAITLIST")
                .relatedId(inviteCode)
                .status(status)
                .build());
    }

    private WaitlistApplicationEntity requirePending(UUID id) {
        WaitlistApplicationEntity application = waitlistRepository.findById(id)
                .orElseThrow(() -> new BusinessException("WAITLIST_NOT_FOUND", "Waitlist application not found."));
        if (application.getStatus() != WaitlistStatus.PENDING) {
            throw new BusinessException("WAITLIST_ALREADY_REVIEWED", "Waitlist application has already been reviewed.");
        }
        return application;
    }

    private WaitlistDtos.ApplicationResponse toResponse(WaitlistApplicationEntity application) {
        return new WaitlistDtos.ApplicationResponse(
                application.getId().toString(),
                application.getPhoneE164(),
                application.getDisplayName(),
                application.getCity(),
                application.getNote(),
                application.getStatus().name(),
                application.getInviteCode(),
                application.getReviewedBy() == null ? null : application.getReviewedBy().toString(),
                application.getReviewedAt(),
                application.getCreatedAt(),
                friendsApprovedCount()
        );
    }

    private long friendsApprovedCount() {
        return waitlistRepository.countByStatus(WaitlistStatus.APPROVED);
    }

    private static String normalizePhone(String phone) {
        String normalized = phone == null ? "" : phone.trim().replaceAll("[\\s-]", "");
        if (!normalized.matches("^\\+251\\d{9}$")) {
            throw new BusinessException("INVALID_PHONE", "Phone number must be an Ethiopian E.164 number starting with +251.");
        }
        return normalized;
    }

    private static String defaultCity(String city) {
        String normalized = blankToNull(city);
        return normalized == null ? "Addis Ababa" : normalized;
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
