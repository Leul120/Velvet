package com.velvet.api.identity.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.Instant;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "users")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "phone_e164", nullable = false, unique = true, length = 20)
    private String phoneE164;

    @Column(length = 255)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    @Builder.Default
    private UserStatus status = UserStatus.APPLIED;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    @Builder.Default
    private UserRole role = UserRole.MEMBER;

    @Column(name = "display_name", length = 120)
    private String displayName;

    @Column(name = "date_of_birth")
    private LocalDate dateOfBirth;

    @Enumerated(EnumType.STRING)
    @Column(length = 16)
    private Gender gender;

    @Column(name = "preferred_locale", nullable = false, length = 8)
    @Builder.Default
    private String preferredLocale = "am";

    @Column(name = "invite_id")
    private UUID inviteId;

    @Column(name = "legal_accepted_version", length = 32)
    private String legalAcceptedVersion;

    @Column(name = "legal_accepted_at")
    private Instant legalAcceptedAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;
}
