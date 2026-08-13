package com.velvet.api.admin.service;

import com.velvet.api.billing.repo.PayoutRequestRepository;
import com.velvet.api.billing.repo.SubscriptionRepository;
import com.velvet.api.booking.domain.BookingStatus;
import com.velvet.api.booking.repo.BookingRepository;
import com.velvet.api.chat.domain.ModerationStatus;
import com.velvet.api.chat.repo.MessageRepository;
import com.velvet.api.chat.service.ModerationEventService;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.safety.domain.PanicStatus;
import com.velvet.api.safety.domain.ReportStatus;
import com.velvet.api.safety.repo.PanicAlertRepository;
import com.velvet.api.safety.repo.SafetyReportRepository;
import com.velvet.api.verification.domain.VerificationStatus;
import com.velvet.api.verification.repo.VerificationCaseRepository;
import com.velvet.api.waitlist.domain.WaitlistStatus;
import com.velvet.api.waitlist.repo.WaitlistApplicationRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class AdminMetricsService {

    private final UserRepository userRepository;
    private final PanicAlertRepository panicAlertRepository;
    private final SafetyReportRepository safetyReportRepository;
    private final MessageRepository messageRepository;
    private final VerificationCaseRepository verificationCaseRepository;
    private final BookingRepository bookingRepository;
    private final SubscriptionRepository subscriptionRepository;
    private final WaitlistApplicationRepository waitlistApplicationRepository;
    private final ModerationEventService moderationEventService;
    private final PayoutRequestRepository payoutRequestRepository;

    public AdminMetricsService(
            UserRepository userRepository,
            PanicAlertRepository panicAlertRepository,
            SafetyReportRepository safetyReportRepository,
            MessageRepository messageRepository,
            VerificationCaseRepository verificationCaseRepository,
            BookingRepository bookingRepository,
            SubscriptionRepository subscriptionRepository,
            WaitlistApplicationRepository waitlistApplicationRepository,
            ModerationEventService moderationEventService,
            PayoutRequestRepository payoutRequestRepository
    ) {
        this.userRepository = userRepository;
        this.panicAlertRepository = panicAlertRepository;
        this.safetyReportRepository = safetyReportRepository;
        this.messageRepository = messageRepository;
        this.verificationCaseRepository = verificationCaseRepository;
        this.bookingRepository = bookingRepository;
        this.subscriptionRepository = subscriptionRepository;
        this.waitlistApplicationRepository = waitlistApplicationRepository;
        this.moderationEventService = moderationEventService;
        this.payoutRequestRepository = payoutRequestRepository;
    }

    @Transactional(readOnly = true)
    public Map<String, Object> metrics() {
        Instant now = Instant.now();
        Map<String, Long> membersByStatus = new LinkedHashMap<>();
        userRepository.findAll().forEach(user -> membersByStatus.merge(user.getStatus().name(), 1L, Long::sum));

        Map<String, Object> metrics = new LinkedHashMap<>();
        metrics.put("membersByStatus", membersByStatus);
        metrics.put("openPanics", panicAlertRepository.findByStatusOrderByCreatedAtDesc(PanicStatus.OPEN).size());
        metrics.put("openReports", safetyReportRepository.findByStatusOrderByCreatedAtDesc(ReportStatus.OPEN).size());
        metrics.put("heldMessages", messageRepository.findByModerationStatusOrderByCreatedAtAsc(ModerationStatus.HELD).size());
        metrics.put("pendingVerifications", verificationCaseRepository
                .findByStatusInOrderByCreatedAtAsc(java.util.List.of(VerificationStatus.SUBMITTED, VerificationStatus.IN_REVIEW))
                .size());
        metrics.put("pendingWaitlist", waitlistApplicationRepository
                .findByStatusOrderByCreatedAtDesc(WaitlistStatus.PENDING).size());
        metrics.put("pendingPayouts", payoutRequestRepository.countByStatus("REQUESTED"));
        metrics.put("activeSubscriptions", subscriptionRepository.findAll().stream()
                .filter(subscription -> "ACTIVE".equalsIgnoreCase(String.valueOf(subscription.getStatus())))
                .filter(subscription -> subscription.getEndsAt().isAfter(now))
                .count());
        metrics.put("confirmedBookingsUpcoming", bookingRepository.findAll().stream()
                .filter(booking -> booking.getStatus() == BookingStatus.CONFIRMED)
                .filter(booking -> booking.getStartsAt().isAfter(now))
                .count());
        metrics.put("moderation", moderationEventService.stats());
        return metrics;
    }
}
