package com.velvet.api.identity.repo;

import com.velvet.api.identity.domain.LegalAcceptanceEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface LegalAcceptanceRepository extends JpaRepository<LegalAcceptanceEntity, UUID> {
    Optional<LegalAcceptanceEntity> findByUserIdAndDocumentSetVersion(UUID userId, String documentSetVersion);
}
