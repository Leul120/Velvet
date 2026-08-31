package com.velvet.api.booking.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "bookings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BookingEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "connection_id", nullable = false, unique = true)
    private UUID connectionId;

    @Column(name = "venue_id")
    private UUID venueId;

    @Column(name = "meetup_place", length = 280)
    private String meetupPlace;

    /** SESSION | OVERNIGHT */
    @Column(name = "rate_type", length = 16)
    private String rateType;

    @Column(name = "amount_etb")
    private Integer amountEtb;

    /** UNPAID | PENDING | PAID | WAIVED */
    @Column(name = "payment_status", nullable = false, length = 32)
    @Builder.Default
    private String paymentStatus = "UNPAID";

    @Column(name = "payment_intent_id")
    private UUID paymentIntentId;

    @Column(name = "proposed_by", nullable = false)
    private UUID proposedBy;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    @Builder.Default
    private BookingStatus status = BookingStatus.PROPOSED;

    @Column(name = "starts_at", nullable = false)
    private Instant startsAt;

    private String notes;

    @Column(name = "confirmed_at")
    private Instant confirmedAt;

    @Column(name = "cancelled_at")
    private Instant cancelledAt;

    @Column(name = "checked_in_at")
    private Instant checkedInAt;

    @Column(name = "checked_out_at")
    private Instant checkedOutAt;

    @Column(name = "performer_checked_out_at")
    private Instant performerCheckedOutAt;

    @Column(name = "client_checked_out_at")
    private Instant clientCheckedOutAt;

    @Column(name = "reminder_24h_sent_at")
    private Instant reminder24hSentAt;

    @Column(name = "reminder_2h_sent_at")
    private Instant reminder2hSentAt;

    @Column(name = "messages_purged_at")
    private Instant messagesPurgedAt;

    @Column(name = "escrow_release_at")
    private Instant escrowReleaseAt;

    @Column(name = "escrow_released_at")
    private Instant escrowReleasedAt;

    @Column(name = "disputed_at")
    private Instant disputedAt;

    @Column(name = "dispute_notes", length = 500)
    private String disputeNotes;


    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
