package com.velvet.api.safety.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "trip_shares")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TripShareEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "booking_id")
    private UUID bookingId;

    @Column(name = "match_id")
    private UUID matchId;

    private Double latitude;
    private Double longitude;

    @Column(name = "eta_minutes")
    private Integer etaMinutes;

    private String note;

    @Column(nullable = false, length = 32)
    @Builder.Default
    private String status = "ACTIVE";

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
