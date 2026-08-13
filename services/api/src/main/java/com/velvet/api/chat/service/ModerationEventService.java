package com.velvet.api.chat.service;

import com.velvet.api.chat.domain.ModerationEventEntity;
import com.velvet.api.chat.repo.ModerationEventRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class ModerationEventService {

    private final ModerationEventRepository repository;

    public ModerationEventService(ModerationEventRepository repository) {
        this.repository = repository;
    }

    @Transactional
    public void record(UUID messageId, UUID userId, String action, String detail) {
        repository.save(ModerationEventEntity.builder()
                .messageId(messageId)
                .userId(userId)
                .action(action)
                .detail(detail == null ? "" : detail)
                .build());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> recent() {
        return repository.findTop100ByOrderByCreatedAtDesc().stream()
                .map(e -> {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id", e.getId().toString());
                    row.put("messageId", e.getMessageId() == null ? "" : e.getMessageId().toString());
                    row.put("userId", e.getUserId() == null ? "" : e.getUserId().toString());
                    row.put("action", e.getAction());
                    row.put("detail", e.getDetail() == null ? "" : e.getDetail());
                    row.put("createdAt", e.getCreatedAt().toString());
                    return row;
                })
                .toList();
    }

    @Transactional(readOnly = true)
    public Map<String, Object> stats() {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("pipelineBlocked", repository.countByAction("PIPELINE_BLOCK"));
        stats.put("pipelineHeld", repository.countByAction("PIPELINE_HOLD"));
        stats.put("pipelineAllowed", repository.countByAction("PIPELINE_ALLOW"));
        stats.put("staffApproved", repository.countByAction("STAFF_APPROVE"));
        stats.put("staffBlocked", repository.countByAction("STAFF_BLOCK"));
        return stats;
    }
}
