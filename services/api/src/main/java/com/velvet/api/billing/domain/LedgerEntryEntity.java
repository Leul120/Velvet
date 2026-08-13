package com.velvet.api.billing.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "ledger_entries")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LedgerEntryEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "payment_intent_id")
    private UUID paymentIntentId;

    @Column(name = "booking_id")
    private UUID bookingId;

    @Column(name = "entry_type", nullable = false, length = 32)
    private String entryType;

    @Column(name = "amount_etb", nullable = false, precision = 12, scale = 2)
    private BigDecimal amountEtb;

    @Column(nullable = false, length = 8)
    @Builder.Default
    private String currency = "ETB";

    private String description;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
