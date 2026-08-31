package com.velvet.api.identity.repo;

import com.velvet.api.identity.domain.VaultAccessGrantEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface VaultAccessGrantRepository extends JpaRepository<VaultAccessGrantEntity, UUID> {
    boolean existsByPerformerIdAndMemberId(UUID performerId, UUID memberId);
    Optional<VaultAccessGrantEntity> findByPerformerIdAndMemberId(UUID performerId, UUID memberId);
}
