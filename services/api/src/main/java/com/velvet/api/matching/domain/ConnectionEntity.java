package com.velvet.api.matching.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "connections")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConnectionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "member_a_id", nullable = false)
    private UUID memberAId;

    @Column(name = "member_b_id", nullable = false)
    private UUID memberBId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    @Builder.Default
    private MatchStatus status = MatchStatus.PROPOSED;

    @Column(nullable = false, length = 16)
    @Builder.Default
    private String source = "CONCIERGE";

    @Column(name = "curator_id")
    private UUID curatorId;

    @Column(name = "intro_note_en")
    private String introNoteEn;

    @Column(name = "intro_note_am")
    private String introNoteAm;

    @Column(name = "suggested_venue_id")
    private UUID suggestedVenueId;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    @Column(name = "a_responded_at")
    private Instant aRespondedAt;

    @Column(name = "b_responded_at")
    private Instant bRespondedAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
