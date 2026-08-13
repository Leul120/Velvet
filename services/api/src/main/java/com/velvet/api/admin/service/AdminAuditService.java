package com.velvet.api.admin.service;

import com.velvet.api.common.audit.AuditService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;

@Service
public class AdminAuditService {

    private final AuditService auditService;

    public AdminAuditService(AuditService auditService) {
        this.auditService = auditService;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> list(int limit, String action) {
        return auditService.list(limit, action).stream()
                .map(log -> Map.<String, Object>of(
                        "id", log.getId().toString(),
                        "actorUserId", log.getActorUserId() == null ? "" : log.getActorUserId().toString(),
                        "action", log.getAction(),
                        "entityType", log.getEntityType() == null ? "" : log.getEntityType(),
                        "entityId", log.getEntityId() == null ? "" : log.getEntityId(),
                        "metadata", log.getMetadata() == null ? Map.of() : log.getMetadata(),
                        "createdAt", log.getCreatedAt().toString()
                ))
                .toList();
    }
}
