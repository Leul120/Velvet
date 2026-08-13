package com.velvet.api.safety.repo;

import com.velvet.api.safety.domain.ReportStatus;
import com.velvet.api.safety.domain.SafetyReportEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface SafetyReportRepository extends JpaRepository<SafetyReportEntity, UUID> {
    List<SafetyReportEntity> findByStatusOrderByCreatedAtDesc(ReportStatus status);
}
