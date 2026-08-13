package com.velvet.api.billing.job;

import com.velvet.api.billing.service.BillingService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

/**
 * Periodically processes all payments marked as REFUND_PENDING,
 * simulating payout logic by restoring balances natively.
 */
@Component
public class RefundProcessingJob {

    private static final Logger log = LoggerFactory.getLogger(RefundProcessingJob.class);

    private final BillingService billingService;

    public RefundProcessingJob(BillingService billingService) {
        this.billingService = billingService;
    }

    @Scheduled(fixedDelayString = "${velvet.jobs.refund-processing-ms:300000}") // 5 mins
    public void processPendingRefunds() {
        log.info("Starting RefundProcessingJob sequence");
        try {
            billingService.processPendingRefunds();
            log.info("Finished RefundProcessingJob sequence");
        } catch (Exception e) {
            log.error("RefundProcessingJob encountered a fatal error during automated sweeps", e);
        }
    }
}
