package com.velvet.api.billing.repo;

import com.velvet.api.billing.domain.PayoutRequestEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface PayoutRequestRepository extends JpaRepository<PayoutRequestEntity, UUID> {
    List<PayoutRequestEntity> findByUserIdOrderByCreatedAtDesc(UUID userId);

    boolean existsByUserIdAndStatus(UUID userId, String status);

    List<PayoutRequestEntity> findByStatusOrderByCreatedAtAsc(String status);

    long countByStatus(String status);
}
