package com.velvet.api.safety.job;

import com.velvet.api.safety.service.DataRetentionService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class DataRetentionJob {

    private static final Logger log = LoggerFactory.getLogger(DataRetentionJob.class);

    private final DataRetentionService dataRetentionService;

    public DataRetentionJob(DataRetentionService dataRetentionService) {
        this.dataRetentionService = dataRetentionService;
    }

    @Scheduled(fixedDelayString = "${velvet.jobs.data-retention-ms:3600000}")
    public void scrub() {
        int n = dataRetentionService.scrubExpiredLocation();
        if (n > 0) {
            log.info("Data retention scrubbed {} panic locations", n);
        }
    }
}
