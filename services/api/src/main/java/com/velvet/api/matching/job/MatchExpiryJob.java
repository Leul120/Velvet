package com.velvet.api.matching.job;

import com.velvet.api.matching.service.MatchingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class MatchExpiryJob {

    private static final Logger log = LoggerFactory.getLogger(MatchExpiryJob.class);

    private final MatchingService matchingService;

    public MatchExpiryJob(MatchingService matchingService) {
        this.matchingService = matchingService;
    }

    @Scheduled(fixedDelayString = "${velvet.jobs.match-expiry-ms:60000}")
    public void expire() {
        int count = matchingService.expireOverdue();
        if (count > 0) {
            log.info("Expired {} match proposals", count);
        }
    }
}
