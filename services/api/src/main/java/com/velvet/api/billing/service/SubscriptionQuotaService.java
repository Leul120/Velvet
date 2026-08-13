package com.velvet.api.billing.service;

import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
public class SubscriptionQuotaService {

    /**
     * Connections are free. Revenue is collected on each confirmed session through the
     * booking payment flow, so there is no membership quota to consume.
     */
    public void assertAndConsumeMatch(UUID subscriberUserId) {
        // Intentionally no-op: payment is required per booking, not per connection.
    }

    public void assertHasActiveSubscription(UUID userId) {
        // Kept as a compatibility seam for existing callers; memberships are not enforced.
    }
}
