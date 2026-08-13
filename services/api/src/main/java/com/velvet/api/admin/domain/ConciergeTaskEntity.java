package com.velvet.api.admin.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "concierge_tasks")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConciergeTaskEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "booking_id", nullable = false)
    private UUID bookingId;

    @Column(name = "match_id", nullable = false)
    private UUID matchId;

    @Column(name = "task_type", nullable = false, length = 32)
    private String taskType;

    @Column(name = "due_at", nullable = false)
    private Instant dueAt;

    @Column(nullable = false, length = 32)
    @Builder.Default
    private String status = "OPEN";

    private String notes;

    @Column(name = "ack_by")
    private UUID ackBy;

    @Column(name = "ack_at")
    private Instant ackAt;

    @Column(name = "escalated_at")
    private Instant escalatedAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
