package com.velvet.api.safety.service;

import com.velvet.api.admin.sse.AdminSseRegistry;
import com.velvet.api.booking.domain.BookingEntity;
import com.velvet.api.booking.domain.BookingStatus;
import com.velvet.api.booking.repo.BookingRepository;
import com.velvet.api.notify.ConciergeNotifyService;
import com.velvet.api.notify.MemberNotifyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class SafetyTimerService {

    private static final Logger log = LoggerFactory.getLogger(SafetyTimerService.class);

    private final BookingRepository bookingRepository;
    private final MemberNotifyService memberNotifyService;
    private final ConciergeNotifyService conciergeNotifyService;
    private final AdminSseRegistry adminSseRegistry;

    // Track prompt sent timestamps & confirmed timestamps per booking ID
    private final Map<UUID, Instant> promptSentMap = new ConcurrentHashMap<>();
    private final Map<UUID, Instant> confirmedMap = new ConcurrentHashMap<>();
    private final Map<UUID, Boolean> escalatedMap = new ConcurrentHashMap<>();

    public SafetyTimerService(
            BookingRepository bookingRepository,
            MemberNotifyService memberNotifyService,
            ConciergeNotifyService conciergeNotifyService,
            AdminSseRegistry adminSseRegistry
    ) {
        this.bookingRepository = bookingRepository;
        this.memberNotifyService = memberNotifyService;
        this.conciergeNotifyService = conciergeNotifyService;
        this.adminSseRegistry = adminSseRegistry;
    }

    public void confirmSafety(UUID bookingId) {
        confirmedMap.put(bookingId, Instant.now());
        promptSentMap.remove(bookingId);
        log.info("Safety check-in confirmed by user for booking {}", bookingId);
    }

    @Scheduled(cron = "0 */1 * * * *")
    @Transactional
    public void monitorActiveSafetyTimers() {
        Instant now = Instant.now();
        List<BookingEntity> active = bookingRepository.findByStatusInAndStartsAtBetween(
                List.of(BookingStatus.CHECKED_IN),
                now.minus(24, ChronoUnit.HOURS),
                now.plus(1, ChronoUnit.HOURS)
        );

        for (BookingEntity booking : active) {
            UUID id = booking.getId();
            if (Boolean.TRUE.equals(escalatedMap.get(id))) {
                continue; // Already escalated
            }

            Instant lastConfirmed = confirmedMap.get(id);
            // If checked in > 30 mins ago and not confirmed in past 30 mins
            boolean needsPrompt = (lastConfirmed == null || lastConfirmed.isBefore(now.minus(30, ChronoUnit.MINUTES)));

            if (needsPrompt && !promptSentMap.containsKey(id)) {
                promptSentMap.put(id, now);
                memberNotifyService.notifyUser(
                        booking.getProposedBy(),
                        "Safety Check-In",
                        "Booking in progress — tap 'All Good' to confirm your safety.",
                        "SAFETY_PROMPT",
                        id.toString()
                );
                log.info("Discreet safety check-in prompt issued for booking {}", id);
            } else if (promptSentMap.containsKey(id)) {
                Instant promptTime = promptSentMap.get(id);
                // If prompt un-responded after 5 minutes, auto-escalate to sirens & concierge
                if (now.isAfter(promptTime.plus(5, ChronoUnit.MINUTES))) {
                    escalatedMap.put(id, true);
                    conciergeNotifyService.notifyPanic(
                            "AUTO_SAFETY_ALARM_" + id.toString().substring(0, 8),
                            booking.getProposedBy().toString(),
                            "Unresponded safety check-in timer on active booking " + id,
                            0.0, 0.0
                    );
                    adminSseRegistry.broadcast("SAFETY_ALARM", Map.of(
                            "bookingId", id.toString(),
                            "userId", booking.getProposedBy().toString(),
                            "reason", "Unresponded 5-minute safety check-in prompt"
                    ));
                    log.warn("SAFETY ALARM ESCALATED for booking {}", id);
                }
            }
        }
    }
}
