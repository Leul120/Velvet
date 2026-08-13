package com.velvet.api.waitlist.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "waitlist_applications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WaitlistApplicationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "phone_e164", nullable = false, unique = true, length = 32)
    private String phoneE164;

    @Column(name = "display_name", length = 120)
    private String displayName;

    @Column(nullable = false, length = 64)
    @Builder.Default
    private String city = "Addis Ababa";

    private String note;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    @Builder.Default
    private WaitlistStatus status = WaitlistStatus.PENDING;

    @Column(name = "invite_code", length = 64)
    private String inviteCode;

    @Column(name = "reviewed_by")
    private UUID reviewedBy;

    @Column(name = "reviewed_at")
    private Instant reviewedAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
