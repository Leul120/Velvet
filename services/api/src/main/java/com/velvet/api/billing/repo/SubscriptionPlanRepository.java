package com.velvet.api.billing.repo;

import com.velvet.api.billing.domain.SubscriptionPlanEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface SubscriptionPlanRepository extends JpaRepository<SubscriptionPlanEntity, UUID> {
    List<SubscriptionPlanEntity> findByActiveTrueOrderByPriceEtbAsc();
    Optional<SubscriptionPlanEntity> findByCodeIgnoreCase(String code);
}
