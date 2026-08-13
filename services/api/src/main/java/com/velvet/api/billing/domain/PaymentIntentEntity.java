package com.velvet.api.billing.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "payment_intents")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentIntentEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "plan_id")
    private UUID planId;

    /** MEMBERSHIP | BOOKING */
    @Column(nullable = false, length = 32)
    @Builder.Default
    private String purpose = "MEMBERSHIP";

    @Column(name = "booking_id")
    private UUID bookingId;

    @Column(nullable = false, length = 32)
    @Builder.Default
    private String provider = "TELEBIRR";

    @Column(name = "merchant_order_id", nullable = false, unique = true, length = 64)
    private String merchantOrderId;

    @Column(name = "amount_etb", nullable = false, precision = 12, scale = 2)
    private BigDecimal amountEtb;

    @Column(nullable = false, length = 8)
    @Builder.Default
    private String currency = "ETB";

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    @Builder.Default
    private PaymentStatus status = PaymentStatus.PENDING;

    @Column(name = "checkout_url")
    private String checkoutUrl;

    @Column(name = "provider_ref", length = 128)
    private String providerRef;

    @Column(name = "receipt_url")
    private String receiptUrl;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "raw_notify", columnDefinition = "jsonb")
    private Map<String, Object> rawNotify;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "paid_at")
    private Instant paidAt;
}
