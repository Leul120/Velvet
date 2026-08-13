package com.velvet.api.billing.service;

import com.velvet.api.billing.domain.SubscriptionEntity;
import com.velvet.api.billing.repo.SubscriptionRepository;
import com.velvet.api.notify.ConciergeNotifyService;
import com.velvet.api.notify.MemberNotifyService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class SubscriptionLifecycleService {

    private final SubscriptionRepository subscriptionRepository;
    private final ConciergeNotifyService notifyService;
    private final MemberNotifyService memberNotifyService;

    public SubscriptionLifecycleService(
            SubscriptionRepository subscriptionRepository,
            ConciergeNotifyService notifyService,
            MemberNotifyService memberNotifyService
    ) {
        this.subscriptionRepository = subscriptionRepository;
        this.notifyService = notifyService;
        this.memberNotifyService = memberNotifyService;
    }

    @Transactional
    public int expireOverdue() {
        List<SubscriptionEntity> overdue = subscriptionRepository.findByStatusAndEndsAtBefore("ACTIVE", Instant.now());
        overdue.forEach(s -> {
            s.setStatus("EXPIRED");
            memberNotifyService.notifyUser(
                    s.getUserId(),
                    "VELVET membership ended",
                    "Your membership has expired. Renew with Telebirr to keep curated introductions.",
                    "SUBSCRIPTION",
                    s.getId().toString()
            );
        });
        if (!overdue.isEmpty()) {
            notifyService.notifyOps(
                    "VELVET SUBSCRIPTIONS EXPIRED",
                    "Expired %d subscription(s)".formatted(overdue.size()),
                    "SUBSCRIPTION",
                    Instant.now().toString()
            );
        }
        return overdue.size();
    }

    @Transactional
    public int warnExpiringSoon() {
        Instant now = Instant.now();
        List<SubscriptionEntity> soon = subscriptionRepository
                .findByStatusAndEndsAtBetweenAndWarningSentAtIsNull(
                        "ACTIVE",
                        now,
                        now.plus(7, ChronoUnit.DAYS)
                );
        Instant marked = Instant.now();
        for (SubscriptionEntity sub : soon) {
            memberNotifyService.notifyUser(
                    sub.getUserId(),
                    "VELVET membership renewing soon",
                    "Your membership ends within 7 days. Open Membership to renew with Telebirr.",
                    "SUBSCRIPTION",
                    sub.getId().toString()
            );
            sub.setWarningSentAt(marked);
        }
        return soon.size();
    }
}
