package com.velvet.api.billing.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "payout_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PayoutRequestEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "amount_etb", nullable = false, precision = 12, scale = 2)
    private BigDecimal amountEtb;

    @Column(nullable = false, length = 32)
    @Builder.Default
    private String status = "REQUESTED";

    @Column(name = "destination_note", length = 280)
    private String destinationNote;

    @Column(name = "ledger_entry_id")
    private UUID ledgerEntryId;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "processed_at")
    private Instant processedAt;

    @Column(name = "admin_notes", length = 500)
    private String adminNotes;

    @Column(name = "processed_by")
    private UUID processedBy;
}
