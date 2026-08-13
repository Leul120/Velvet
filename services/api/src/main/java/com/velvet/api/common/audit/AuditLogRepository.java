package com.velvet.api.common.audit;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AuditLogRepository extends JpaRepository<AuditLogEntity, UUID> {
    List<AuditLogEntity> findByOrderByCreatedAtDesc();

    List<AuditLogEntity> findTop100ByOrderByCreatedAtDesc();

    List<AuditLogEntity> findByActionIgnoreCaseOrderByCreatedAtDesc(String action);
}
