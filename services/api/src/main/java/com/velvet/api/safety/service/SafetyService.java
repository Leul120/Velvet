package com.velvet.api.safety.service;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.ratelimit.RateLimitService;
import com.velvet.api.notify.ConciergeNotifyService;
import com.velvet.api.safety.domain.PanicAlertEntity;
import com.velvet.api.safety.domain.PanicStatus;
import com.velvet.api.safety.domain.ReportStatus;
import com.velvet.api.safety.domain.SafetyReportEntity;
import com.velvet.api.safety.domain.TripShareEntity;
import com.velvet.api.safety.repo.PanicAlertRepository;
import com.velvet.api.safety.repo.SafetyReportRepository;
import com.velvet.api.safety.repo.TripShareRepository;
import com.velvet.api.safety.web.dto.SafetyDtos;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
public class SafetyService {

    private static final Logger log = LoggerFactory.getLogger(SafetyService.class);
    private static final Set<String> CATEGORIES = Set.of("HARASSMENT", "NO_SHOW", "UNSAFE", "POLICY", "OTHER");

    private final PanicAlertRepository panicRepository;
    private final SafetyReportRepository reportRepository;
    private final TripShareRepository tripShareRepository;
    private final ConciergeNotifyService conciergeNotifyService;
    private final RateLimitService rateLimitService;

    public SafetyService(
            PanicAlertRepository panicRepository,
            SafetyReportRepository reportRepository,
            TripShareRepository tripShareRepository,
            ConciergeNotifyService conciergeNotifyService,
            RateLimitService rateLimitService
    ) {
        this.panicRepository = panicRepository;
        this.reportRepository = reportRepository;
        this.tripShareRepository = tripShareRepository;
        this.conciergeNotifyService = conciergeNotifyService;
        this.rateLimitService = rateLimitService;
    }

    @Transactional
    public SafetyDtos.PanicResponse panic(UUID userId, SafetyDtos.PanicRequest request) {
        rateLimitService.checkPanic(userId.toString());
        PanicAlertEntity alert = panicRepository.save(PanicAlertEntity.builder()
                .userId(userId)
                .bookingId(request.bookingId())
                .matchId(request.matchId())
                .latitude(request.latitude())
                .longitude(request.longitude())
                .note(request.note())
                .status(PanicStatus.OPEN)
                .build());
        log.warn("PANIC alert id={} user={} booking={} match={}",
                alert.getId(), userId, request.bookingId(), request.matchId());
        conciergeNotifyService.notifyPanic(
                alert.getId().toString(),
                userId.toString(),
                request.note(),
                request.latitude(),
                request.longitude()
        );
        return new SafetyDtos.PanicResponse(alert.getId().toString(), alert.getStatus().name(), alert.getCreatedAt());
    }

    @Transactional
    public SafetyDtos.ReportResponse report(UUID reporterId, SafetyDtos.ReportRequest request) {
        rateLimitService.checkReport(reporterId.toString());
        String category = request.category().trim().toUpperCase();
        if (!CATEGORIES.contains(category)) {
            throw new BusinessException("INVALID_CATEGORY", "Unknown report category.");
        }
        SafetyReportEntity report = reportRepository.save(SafetyReportEntity.builder()
                .reporterId(reporterId)
                .reportedUserId(request.reportedUserId())
                .matchId(request.matchId())
                .bookingId(request.bookingId())
                .category(category)
                .details(request.details().trim())
                .status(ReportStatus.OPEN)
                .build());
        conciergeNotifyService.notifyReport(report.getId().toString(), category, report.getDetails());
        return new SafetyDtos.ReportResponse(
                report.getId().toString(),
                report.getCategory(),
                report.getStatus().name(),
                report.getCreatedAt()
        );
    }

    @Transactional
    public SafetyDtos.TripShareResponse shareTrip(UUID userId, SafetyDtos.TripShareRequest request) {
        TripShareEntity share = tripShareRepository.save(TripShareEntity.builder()
                .userId(userId)
                .bookingId(request.bookingId())
                .matchId(request.matchId())
                .latitude(request.latitude())
                .longitude(request.longitude())
                .etaMinutes(request.etaMinutes())
                .note(request.note() == null || request.note().isBlank() ? null : request.note().trim())
                .status("ACTIVE")
                .build());
        String body = "VELVET TRIP SHARE user=%s booking=%s eta=%s min loc=%s,%s note=%s"
                .formatted(
                        userId,
                        request.bookingId(),
                        request.etaMinutes() == null ? "-" : request.etaMinutes(),
                        request.latitude(),
                        request.longitude(),
                        share.getNote() == null ? "-" : share.getNote()
                );
        conciergeNotifyService.notifyOps("VELVET trip share", body, "TRIP_SHARE", share.getId().toString());
        log.info("Trip share id={} user={}", share.getId(), userId);
        return new SafetyDtos.TripShareResponse(share.getId().toString(), share.getStatus(), share.getCreatedAt());
    }

    @Transactional(readOnly = true)
    public List<PanicAlertEntity> openPanics() {
        return panicRepository.findByStatusOrderByCreatedAtDesc(PanicStatus.OPEN);
    }

    @Transactional
    public PanicAlertEntity acknowledgePanic(UUID alertId, UUID staffId) {
        PanicAlertEntity alert = panicRepository.findById(alertId)
                .orElseThrow(() -> new BusinessException("PANIC_NOT_FOUND", "Panic alert not found."));
        if (alert.getStatus() != PanicStatus.OPEN) {
            throw new BusinessException("PANIC_CLOSED", "Alert already handled.");
        }
        alert.setStatus(PanicStatus.ACKNOWLEDGED);
        alert.setAcknowledgedBy(staffId);
        alert.setAcknowledgedAt(Instant.now());
        return panicRepository.save(alert);
    }

    @Transactional(readOnly = true)
    public List<SafetyReportEntity> openReports() {
        return reportRepository.findByStatusOrderByCreatedAtDesc(ReportStatus.OPEN);
    }

    @Transactional
    public SafetyReportEntity reviewReport(UUID reportId, UUID staffId, String statusRaw, String notes) {
        SafetyReportEntity report = reportRepository.findById(reportId)
                .orElseThrow(() -> new BusinessException("REPORT_NOT_FOUND", "Report not found."));
        if (report.getStatus() != ReportStatus.OPEN && report.getStatus() != ReportStatus.TRIAGED) {
            throw new BusinessException("REPORT_CLOSED", "Report already closed.");
        }
        ReportStatus status;
        try {
            status = ReportStatus.valueOf(statusRaw.trim().toUpperCase());
        } catch (Exception e) {
            throw new BusinessException("INVALID_STATUS", "Status must be TRIAGED, RESOLVED, or DISMISSED.");
        }
        if (status != ReportStatus.TRIAGED && status != ReportStatus.RESOLVED && status != ReportStatus.DISMISSED) {
            throw new BusinessException("INVALID_STATUS", "Status must be TRIAGED, RESOLVED, or DISMISSED.");
        }
        report.setStatus(status);
        report.setReviewedBy(staffId);
        report.setReviewedAt(Instant.now());
        if (notes != null && !notes.isBlank()) {
            report.setStaffNotes(notes.trim());
        }
        return reportRepository.save(report);
    }
}
