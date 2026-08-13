package com.velvet.api.admin.service;

import com.velvet.api.admin.domain.ConciergeTaskEntity;
import com.velvet.api.admin.repo.ConciergeTaskRepository;
import com.velvet.api.booking.domain.BookingEntity;
import com.velvet.api.booking.domain.BookingStatus;
import com.velvet.api.booking.repo.BookingRepository;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.notify.ConciergeNotifyService;
import com.velvet.api.venues.domain.VenueEntity;
import com.velvet.api.venues.repo.VenueRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class ConciergeTaskService {

    private static final long ESCALATE_AFTER_MINUTES = 15;

    private final ConciergeTaskRepository taskRepository;
    private final BookingRepository bookingRepository;
    private final VenueRepository venueRepository;
    private final ConciergeNotifyService conciergeNotifyService;

    public ConciergeTaskService(
            ConciergeTaskRepository taskRepository,
            BookingRepository bookingRepository,
            VenueRepository venueRepository,
            ConciergeNotifyService conciergeNotifyService
    ) {
        this.taskRepository = taskRepository;
        this.bookingRepository = bookingRepository;
        this.venueRepository = venueRepository;
        this.conciergeNotifyService = conciergeNotifyService;
    }

    @Transactional
    public int syncDueTasks() {
        Instant now = Instant.now();
        int created = 0;

        List<BookingEntity> upcoming = bookingRepository.findByStatusInAndStartsAtBetween(
                List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.COMPLETED),
                now.minus(3, ChronoUnit.HOURS),
                now.plus(2, ChronoUnit.HOURS)
        );

        for (BookingEntity booking : upcoming) {
            Instant starts = booking.getStartsAt();
            if (booking.getStatus() == BookingStatus.CONFIRMED
                    && !now.isBefore(starts.minus(30, ChronoUnit.MINUTES))
                    && now.isBefore(starts)) {
                created += ensureTask(booking, "PRE_CALL", starts.minus(30, ChronoUnit.MINUTES),
                        "Call both members 30 minutes before meeting.");
            }
            if (booking.getStatus() == BookingStatus.CONFIRMED
                    && booking.getCheckedInAt() == null
                    && !now.isBefore(starts.plus(15, ChronoUnit.MINUTES))) {
                created += ensureTask(booking, "ARRIVAL_CHECK", starts.plus(15, ChronoUnit.MINUTES),
                        "No check-in 15 minutes after start — contact members.");
            }
            Instant followDue = booking.getCheckedOutAt() != null
                    ? booking.getCheckedOutAt().plus(1, ChronoUnit.HOURS)
                    : starts.plus(2, ChronoUnit.HOURS);
            if ((booking.getStatus() == BookingStatus.COMPLETED
                    || booking.getCheckedOutAt() != null
                    || (booking.getStatus() == BookingStatus.CHECKED_IN && !now.isBefore(followDue)))
                    && !now.isBefore(followDue)) {
                created += ensureTask(booking, "FOLLOW_UP", followDue,
                        "Post-meeting safety follow-up call within 1 hour of end.");
            }
        }

        created += escalateOverdue(now);
        return created;
    }

    private int ensureTask(BookingEntity booking, String type, Instant dueAt, String notes) {
        if (taskRepository.findByBookingIdAndTaskType(booking.getId(), type).isPresent()) {
            return 0;
        }
        ConciergeTaskEntity task = taskRepository.save(ConciergeTaskEntity.builder()
                .bookingId(booking.getId())
                .matchId(booking.getConnectionId())
                .taskType(type)
                .dueAt(dueAt)
                .status("OPEN")
                .notes(notes)
                .build());
        VenueEntity venue = booking.getVenueId() == null
                ? null
                : venueRepository.findById(booking.getVenueId()).orElse(null);
        String venueName = venue != null
                ? venue.getName()
                : (booking.getMeetupPlace() != null && !booking.getMeetupPlace().isBlank()
                        ? booking.getMeetupPlace()
                        : "private meetup");
        conciergeNotifyService.notifyOps(
                "VELVET " + type,
                type + " for booking " + booking.getId() + " at " + venueName + " (match " + booking.getConnectionId() + ")",
                "CONCIERGE_TASK",
                task.getId().toString()
        );
        return 1;
    }

    private int escalateOverdue(Instant now) {
        Instant cutoff = now.minus(ESCALATE_AFTER_MINUTES, ChronoUnit.MINUTES);
        int n = 0;
        for (ConciergeTaskEntity task : taskRepository.findByStatusAndDueAtBeforeAndEscalatedAtIsNull("OPEN", cutoff)) {
            task.setStatus("ESCALATED");
            task.setEscalatedAt(now);
            taskRepository.save(task);
            conciergeNotifyService.notifyOps(
                    "VELVET TASK ESCALATION",
                    "Unacked " + task.getTaskType() + " task " + task.getId() + " overdue > "
                            + ESCALATE_AFTER_MINUTES + "m",
                    "CONCIERGE_TASK",
                    task.getId().toString()
            );
            // Re-use panic SMS path for urgency via notifyPanic-style: notifyOps is push; escalate with SMS:
            conciergeNotifyService.notifyPanic(
                    task.getId().toString(),
                    "task:" + task.getTaskType(),
                    "Escalation: unacked concierge task",
                    null,
                    null
            );
            n++;
        }
        return n;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> listOpen() {
        return taskRepository.findByStatusInOrderByDueAtAsc(List.of("OPEN", "ESCALATED", "ACKED")).stream()
                .map(this::toMap)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> todaysMeetings() {
        Instant now = Instant.now();
        Instant from = now.minus(12, ChronoUnit.HOURS);
        Instant to = now.plus(24, ChronoUnit.HOURS);
        List<Map<String, Object>> out = new ArrayList<>();
        for (BookingEntity b : bookingRepository.findByStatusInAndStartsAtBetween(
                List.of(BookingStatus.CONFIRMED, BookingStatus.CHECKED_IN, BookingStatus.COMPLETED, BookingStatus.NO_SHOW),
                from,
                to
        )) {
            VenueEntity venue = b.getVenueId() == null
                    ? null
                    : venueRepository.findById(b.getVenueId()).orElse(null);
            Map<String, Object> row = new LinkedHashMap<>();
            row.put("bookingId", b.getId().toString());
            row.put("matchId", b.getConnectionId().toString());
            row.put("status", b.getStatus().name());
            row.put("startsAt", b.getStartsAt().toString());
            row.put("checkedInAt", b.getCheckedInAt() == null ? null : b.getCheckedInAt().toString());
            row.put("checkedOutAt", b.getCheckedOutAt() == null ? null : b.getCheckedOutAt().toString());
            row.put("venueName", venue != null
                    ? venue.getName()
                    : (b.getMeetupPlace() == null ? "" : b.getMeetupPlace()));
            out.add(row);
        }
        return out;
    }

    @Transactional
    public Map<String, Object> ack(UUID taskId, UUID actorId) {
        ConciergeTaskEntity task = require(taskId);
        if ("DONE".equals(task.getStatus())) {
            throw new BusinessException("TASK_DONE", "Task already completed.");
        }
        task.setStatus("ACKED");
        task.setAckBy(actorId);
        task.setAckAt(Instant.now());
        taskRepository.save(task);
        return toMap(task);
    }

    @Transactional
    public Map<String, Object> done(UUID taskId, UUID actorId, String notes) {
        ConciergeTaskEntity task = require(taskId);
        task.setStatus("DONE");
        if (task.getAckBy() == null) {
            task.setAckBy(actorId);
            task.setAckAt(Instant.now());
        }
        if (notes != null && !notes.isBlank()) {
            task.setNotes((task.getNotes() == null ? "" : task.getNotes() + " | ") + notes.trim());
        }
        taskRepository.save(task);
        return toMap(task);
    }

    private ConciergeTaskEntity require(UUID taskId) {
        return taskRepository.findById(taskId)
                .orElseThrow(() -> new BusinessException("TASK_NOT_FOUND", "Concierge task not found."));
    }

    private Map<String, Object> toMap(ConciergeTaskEntity t) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", t.getId().toString());
        m.put("bookingId", t.getBookingId().toString());
        m.put("connectionId", t.getMatchId().toString());
        m.put("taskType", t.getTaskType());
        m.put("dueAt", t.getDueAt().toString());
        m.put("status", t.getStatus());
        m.put("notes", t.getNotes());
        m.put("ackAt", t.getAckAt() == null ? null : t.getAckAt().toString());
        m.put("escalatedAt", t.getEscalatedAt() == null ? null : t.getEscalatedAt().toString());
        return m;
    }
}
