package com.velvet.api.safety.repo;

import com.velvet.api.safety.domain.PanicAlertEntity;
import com.velvet.api.safety.domain.PanicStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface PanicAlertRepository extends JpaRepository<PanicAlertEntity, UUID> {
    List<PanicAlertEntity> findByStatusOrderByCreatedAtDesc(PanicStatus status);

    List<PanicAlertEntity> findByCreatedAtBeforeAndLatitudeIsNotNull(Instant before);
}
