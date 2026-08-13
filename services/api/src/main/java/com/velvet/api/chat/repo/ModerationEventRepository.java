package com.velvet.api.chat.repo;

import com.velvet.api.chat.domain.ModerationEventEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ModerationEventRepository extends JpaRepository<ModerationEventEntity, UUID> {
    List<ModerationEventEntity> findTop100ByOrderByCreatedAtDesc();

    long countByAction(String action);
}
