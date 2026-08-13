package com.velvet.api.verification.repo;

import com.velvet.api.verification.domain.VerificationCaseEntity;
import com.velvet.api.verification.domain.VerificationStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VerificationCaseRepository extends JpaRepository<VerificationCaseEntity, UUID> {
    Optional<VerificationCaseEntity> findFirstByUserIdOrderByCreatedAtDesc(UUID userId);
    List<VerificationCaseEntity> findByStatusInOrderByCreatedAtAsc(List<VerificationStatus> statuses);
}
