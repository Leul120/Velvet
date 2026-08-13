package com.velvet.api.billing.job;

import com.velvet.api.billing.service.SubscriptionLifecycleService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class SubscriptionExpiryJob {

    private static final Logger log = LoggerFactory.getLogger(SubscriptionExpiryJob.class);

    private final SubscriptionLifecycleService lifecycleService;

    public SubscriptionExpiryJob(SubscriptionLifecycleService lifecycleService) {
        this.lifecycleService = lifecycleService;
    }

    @Scheduled(fixedDelayString = "${velvet.jobs.subscription-expiry-ms:60000}")
    public void expire() {
        int warned = lifecycleService.warnExpiringSoon();
        if (warned > 0) {
            log.info("Sent renewal warnings for {} subscriptions", warned);
        }
        int count = lifecycleService.expireOverdue();
        if (count > 0) {
            log.info("Expired {} subscriptions", count);
        }
    }
}
