package com.velvet.api.discover.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.annotations.UpdateTimestamp;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "member_preferences")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberPreferencesEntity {

    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "min_age", nullable = false)
    @Builder.Default
    private int minAge = 21;

    @Column(name = "max_age", nullable = false)
    @Builder.Default
    private int maxAge = 55;

    @Column(name = "max_distance_km", nullable = false)
    @Builder.Default
    private int maxDistanceKm = 50;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private List<String> cities = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "preferred_languages", nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private List<String> preferredLanguages = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private List<String> intents = new ArrayList<>();

    @Column(name = "verified_only", nullable = false)
    @Builder.Default
    private boolean verifiedOnly = false;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
