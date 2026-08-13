package com.velvet.api.venues.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "venues")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VenueEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 160)
    private String name;

    @Column(name = "name_am", length = 160)
    private String nameAm;

    @Column(nullable = false, length = 64)
    @Builder.Default
    private String city = "Addis Ababa";

    @Column(nullable = false, length = 64)
    @Builder.Default
    private String category = "RESTAURANT";

    @Column(name = "address_line", nullable = false)
    private String addressLine;

    @Column(name = "privacy_level", nullable = false, length = 32)
    @Builder.Default
    private String privacyLevel = "STANDARD";

    private Double latitude;
    private Double longitude;

    @Column(name = "geofence_meters", nullable = false)
    @Builder.Default
    private int geofenceMeters = 400;

    @Column(nullable = false)
    @Builder.Default
    private boolean active = true;

    @Column(name = "partner_user_id")
    private UUID partnerUserId;

    /** Neighborhood / area label (e.g. Bole, Piazza). */
    @Column(length = 64)
    private String area;

    @Column(name = "price_band", nullable = false, length = 32)
    @Builder.Default
    private String priceBand = "MODERATE";

    /** QUIET | BALANCED | LIVELY */
    @Column(nullable = false, length = 32)
    @Builder.Default
    private String vibe = "BALANCED";

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "photo_urls", nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private List<String> photoUrls = new ArrayList<>();

    @Column(nullable = false)
    @Builder.Default
    private boolean verified = true;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
