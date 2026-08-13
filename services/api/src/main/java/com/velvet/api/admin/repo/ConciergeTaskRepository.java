package com.velvet.api.admin.repo;

import com.velvet.api.admin.domain.ConciergeTaskEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ConciergeTaskRepository extends JpaRepository<ConciergeTaskEntity, UUID> {
    Optional<ConciergeTaskEntity> findByBookingIdAndTaskType(UUID bookingId, String taskType);

    List<ConciergeTaskEntity> findByStatusInOrderByDueAtAsc(List<String> statuses);

    List<ConciergeTaskEntity> findByStatusAndDueAtBeforeAndEscalatedAtIsNull(String status, Instant before);
}
