package com.velvet.api.identity.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "vault_access_grants", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"performer_id", "member_id"})
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class VaultAccessGrantEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "performer_id", nullable = false)
    private UUID performerId;

    @Column(name = "member_id", nullable = false)
    private UUID memberId;

    @Column(name = "granted_by", nullable = false)
    private UUID grantedBy;

    @Column(name = "reason", length = 120)
    private String reason;

    @CreationTimestamp
    @Column(name = "granted_at", nullable = false, updatable = false)
    private Instant grantedAt;

    @Column(name = "expires_at")
    private Instant expiresAt;
}
