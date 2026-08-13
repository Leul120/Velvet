package com.velvet.api.booking.job;

import com.velvet.api.admin.service.ConciergeTaskService;
import com.velvet.api.booking.service.BookingService;
import com.velvet.api.chat.service.ChatWindowService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class BookingReminderJob {

    private static final Logger log = LoggerFactory.getLogger(BookingReminderJob.class);

    private final BookingService bookingService;
    private final ChatWindowService chatWindowService;
    private final ConciergeTaskService conciergeTaskService;

    public BookingReminderJob(
            BookingService bookingService,
            ChatWindowService chatWindowService,
            ConciergeTaskService conciergeTaskService
    ) {
        this.bookingService = bookingService;
        this.chatWindowService = chatWindowService;
        this.conciergeTaskService = conciergeTaskService;
    }

    @Scheduled(fixedDelayString = "${velvet.jobs.booking-reminder-ms:300000}")
    public void remind() {
        int reminders = bookingService.sendDueReminders();
        if (reminders > 0) {
            log.info("Sent booking reminders for {} bookings", reminders);
        }
        int chat = chatWindowService.syncWindowsAndPurge();
        if (chat > 0) {
            log.info("Chat window sync/purge touched {} rows", chat);
        }
        int tasks = conciergeTaskService.syncDueTasks();
        if (tasks > 0) {
            log.info("Concierge task sync created/escalated {} items", tasks);
        }
    }
}
