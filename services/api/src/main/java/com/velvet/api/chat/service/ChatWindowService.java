package com.velvet.api.chat.service;

import com.velvet.api.booking.domain.BookingEntity;
import com.velvet.api.booking.domain.BookingStatus;
import com.velvet.api.booking.repo.BookingRepository;
import com.velvet.api.chat.domain.ChatThreadEntity;
import com.velvet.api.chat.domain.MessageEntity;
import com.velvet.api.chat.domain.ModerationStatus;
import com.velvet.api.chat.domain.ThreadStatus;
import com.velvet.api.chat.repo.ChatThreadRepository;
import com.velvet.api.chat.repo.MessageRepository;
import com.velvet.api.common.api.BusinessException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

/**
 * Marketplace chat windowing:
 * - No booking / PROPOSED → open (arrange place, rates, timing).
 * - CONFIRMED / CHECKED_IN / COMPLETED → open until closesAt (logistics stay available).
 * - After closesAt → LOCKED + purge messages.
 */
@Service
public class ChatWindowService {

    public static final long CLOSE_AFTER_MINUTES = 60;

    private final BookingRepository bookingRepository;
    private final ChatThreadRepository threadRepository;
    private final MessageRepository messageRepository;

    public ChatWindowService(
            BookingRepository bookingRepository,
            ChatThreadRepository threadRepository,
            MessageRepository messageRepository
    ) {
        this.bookingRepository = bookingRepository;
        this.threadRepository = threadRepository;
        this.messageRepository = messageRepository;
    }

    public record Window(boolean canSend, Instant opensAt, Instant closesAt, String reason) {}

    public Window windowForMatch(UUID matchId) {
        Optional<BookingEntity> bookingOpt = bookingRepository.findByConnectionId(matchId)
                .filter(b -> b.getStatus() != BookingStatus.CANCELLED);
        if (bookingOpt.isEmpty()) {
            return new Window(true, null, null, "NO_BOOKING");
        }
        BookingEntity booking = bookingOpt.get();
        if (booking.getStatus() == BookingStatus.PROPOSED) {
            return new Window(true, null, null, "PROPOSED");
        }
        if (booking.getStatus() == BookingStatus.NO_SHOW) {
            return new Window(false, null, null, "CLOSED");
        }
        Instant closesAt = closesAt(booking);
        Instant now = Instant.now();
        if (!now.isBefore(closesAt)) {
            return new Window(false, null, closesAt, "CLOSED");
        }
        return new Window(true, null, closesAt, "OPEN");
    }

    public void assertCanSend(UUID matchId) {
        Window w = windowForMatch(matchId);
        if (w.canSend()) {
            return;
        }
        throw new BusinessException(
                "CHAT_WINDOW_CLOSED",
                "This conversation is closed. Messages are removed after the meeting window."
        );
    }

    private static Instant closesAt(BookingEntity booking) {
        if (booking.getCheckedOutAt() != null) {
            return booking.getCheckedOutAt().plus(CLOSE_AFTER_MINUTES, ChronoUnit.MINUTES);
        }
        // Keep chat open through the booked duration, then a short grace period.
        long hours = "OVERNIGHT".equalsIgnoreCase(booking.getRateType() == null ? "" : booking.getRateType())
                ? 12
                : 3;
        return booking.getStartsAt().plus(hours, ChronoUnit.HOURS).plus(CLOSE_AFTER_MINUTES, ChronoUnit.MINUTES);
    }

    /** Sync thread LOCKED/OPEN from booking windows; purge expired message bodies. */
    @Transactional
    public int syncWindowsAndPurge() {
        Instant now = Instant.now();
        int changed = 0;

        List<BookingEntity> active = bookingRepository.findByStatusInAndStartsAtBetween(
                List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.COMPLETED),
                now.minus(48, ChronoUnit.HOURS),
                now.plus(48, ChronoUnit.HOURS)
        );
        for (BookingEntity booking : active) {
            Window w = windowForMatch(booking.getConnectionId());
            Optional<ChatThreadEntity> threadOpt = threadRepository.findByConnectionId(booking.getConnectionId());
            if (threadOpt.isEmpty()) {
                continue;
            }
            ChatThreadEntity thread = threadOpt.get();
            if (thread.getStatus() == ThreadStatus.CLOSED) {
                continue;
            }
            ThreadStatus desired = w.canSend() ? ThreadStatus.OPEN : ThreadStatus.LOCKED;
            if (thread.getStatus() != desired) {
                thread.setStatus(desired);
                threadRepository.save(thread);
                changed++;
            }
        }

        List<BookingEntity> purgeable = bookingRepository.findByStatusInAndStartsAtBeforeAndMessagesPurgedAtIsNull(
                List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.COMPLETED, BookingStatus.NO_SHOW),
                now.minus(CLOSE_AFTER_MINUTES, ChronoUnit.MINUTES)
        );
        for (BookingEntity booking : purgeable) {
            Window w = windowForMatch(booking.getConnectionId());
            if (w.canSend() || "PROPOSED".equals(w.reason()) || "NO_BOOKING".equals(w.reason()) || "OPEN".equals(w.reason())) {
                continue;
            }
            if (!"CLOSED".equals(w.reason())) {
                continue;
            }
            threadRepository.findByConnectionId(booking.getConnectionId()).ifPresent(thread -> {
                for (MessageEntity m : messageRepository.findByThreadId(thread.getId())) {
                    m.setBody("[removed after meeting]");
                    m.setModerationStatus(ModerationStatus.BLOCKED);
                    messageRepository.save(m);
                }
                thread.setStatus(ThreadStatus.LOCKED);
                threadRepository.save(thread);
            });
            booking.setMessagesPurgedAt(now);
            bookingRepository.save(booking);
            changed++;
        }

        // Mark no-shows: confirmed, started 45+ min ago, never checked in
        List<BookingEntity> noShows = bookingRepository.findByStatusAndStartsAtBeforeAndCheckedInAtIsNull(
                BookingStatus.CONFIRMED,
                now.minus(45, ChronoUnit.MINUTES)
        );
        for (BookingEntity booking : noShows) {
            booking.setStatus(BookingStatus.NO_SHOW);
            bookingRepository.save(booking);
            changed++;
        }

        return changed;
    }
}
