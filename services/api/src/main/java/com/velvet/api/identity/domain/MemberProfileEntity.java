package com.velvet.api.identity.domain;

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
@Table(name = "member_profiles")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberProfileEntity {

    @Id
    @Column(name = "user_id")
    private UUID userId;

    @Column(name = "bio_en")
    private String bioEn;

    @Column(name = "bio_am")
    private String bioAm;

    @Column(nullable = false, length = 64)
    @Builder.Default
    private String city = "Addis Ababa";

    @Column(name = "height_cm") private Integer heightCm;
    @Column(name = "job_title") private String jobTitle;
    private String education;
    private String languages;
    private String religion;
    @Column(name = "looking_for") private String lookingFor;

    /** Session / evening rate in ETB (performer listings). */
    @Column(name = "session_rate_etb")
    private Integer sessionRateEtb;

    /** Overnight rate in ETB (performer listings). */
    @Column(name = "overnight_rate_etb")
    private Integer overnightRateEtb;

    @Column(name = "availability_note", length = 280)
    private String availabilityNote;

    @Column(name = "available_tonight", nullable = false)
    @Builder.Default
    private boolean availableTonight = false;

    @Column(name = "available_neighborhood", length = 64)
    private String availableNeighborhood;

    @Column(name = "voice_intro_url", length = 1024)
    private String voiceIntroUrl;

    @Column(name = "listing_active", nullable = false)
    @Builder.Default
    private boolean listingActive = true;


    @JdbcTypeCode(SqlTypes.JSON)
    @Column(nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private List<String> interests = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "photo_urls", nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private List<String> photoUrls = new ArrayList<>();

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "private_photo_urls", nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private List<String> privatePhotoUrls = new ArrayList<>();


    @Column(name = "concierge_notes", columnDefinition = "TEXT")
    private String conciergeNotes;

    @Column(name = "last_lat")
    private Double lastLat;

    @Column(name = "last_lng")
    private Double lastLng;

    @Column(name = "location_updated_at")
    private Instant locationUpdatedAt;

    /** APPROVED | NEEDS_REVIEW | REJECTED */
    @Column(name = "photo_quality_status", nullable = false, length = 32)
    @Builder.Default
    private String photoQualityStatus = "NEEDS_REVIEW";

    @Column(name = "photo_quality_notes", length = 500)
    private String photoQualityNotes;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
