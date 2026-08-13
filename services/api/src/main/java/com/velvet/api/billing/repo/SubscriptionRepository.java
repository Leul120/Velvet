package com.velvet.api.billing.repo;

import com.velvet.api.billing.domain.SubscriptionEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SubscriptionRepository extends JpaRepository<SubscriptionEntity, UUID> {
    Optional<SubscriptionEntity> findFirstByUserIdAndStatusAndEndsAtAfterOrderByEndsAtDesc(
            UUID userId,
            String status,
            Instant now
    );

    List<SubscriptionEntity> findByStatusAndEndsAtBefore(String status, Instant endsAtBefore);

    List<SubscriptionEntity> findByStatusAndEndsAtBetweenAndWarningSentAtIsNull(
            String status,
            Instant from,
            Instant to
    );
}
