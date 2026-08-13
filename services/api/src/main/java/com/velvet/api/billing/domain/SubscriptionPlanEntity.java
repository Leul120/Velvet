package com.velvet.api.billing.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "subscription_plans")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SubscriptionPlanEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, unique = true, length = 32)
    private String code;

    @Column(name = "name_en", nullable = false, length = 120)
    private String nameEn;

    @Column(name = "name_am", length = 120)
    private String nameAm;

    @Column(name = "price_etb", nullable = false, precision = 12, scale = 2)
    private BigDecimal priceEtb;

    @Column(name = "match_quota", nullable = false)
    private int matchQuota;

    @Column(name = "duration_days", nullable = false)
    private int durationDays;

    @Column(nullable = false)
    @Builder.Default
    private boolean active = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
