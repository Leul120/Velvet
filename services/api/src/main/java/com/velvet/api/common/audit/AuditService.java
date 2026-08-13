package com.velvet.api.common.audit;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class AuditService {

    private final AuditLogRepository repository;

    public AuditService(AuditLogRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public void log(UUID actorId, String action, String entityType, String entityId, Map<String, Object> metadata) {
        repository.save(AuditLogEntity.builder()
                .actorUserId(actorId)
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .metadata(metadata == null ? Map.of() : metadata)
                .build());
    }

    @Transactional(readOnly = true)
    public List<AuditLogEntity> list(int limit, String action) {
        List<AuditLogEntity> logs = action == null || action.isBlank()
                ? repository.findTop100ByOrderByCreatedAtDesc()
                : repository.findByActionIgnoreCaseOrderByCreatedAtDesc(action.trim());
        return logs.stream().limit(Math.max(1, Math.min(limit, 100))).toList();
    }
}
