package com.velvet.api.admin.web;

import com.velvet.api.admin.service.AdminAuditService;
import com.velvet.api.admin.service.AdminMetricsService;
import com.velvet.api.admin.service.ConciergeTaskService;
import com.velvet.api.admin.service.OpsReadinessService;
import com.velvet.api.admin.service.StaffShiftService;
import com.velvet.api.admin.web.dto.AdminDtos;
import com.velvet.api.chat.service.ModerationEventService;
import com.velvet.api.identity.security.VelvetPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/admin")
public class AdminOpsController {

    private final AdminAuditService adminAuditService;
    private final StaffShiftService staffShiftService;
    private final AdminMetricsService adminMetricsService;
    private final ModerationEventService moderationEventService;
    private final OpsReadinessService opsReadinessService;
    private final ConciergeTaskService conciergeTaskService;

    public AdminOpsController(
            AdminAuditService adminAuditService,
            StaffShiftService staffShiftService,
            AdminMetricsService adminMetricsService,
            ModerationEventService moderationEventService,
            OpsReadinessService opsReadinessService,
            ConciergeTaskService conciergeTaskService
    ) {
        this.adminAuditService = adminAuditService;
        this.staffShiftService = staffShiftService;
        this.adminMetricsService = adminMetricsService;
        this.moderationEventService = moderationEventService;
        this.opsReadinessService = opsReadinessService;
        this.conciergeTaskService = conciergeTaskService;
    }

    @GetMapping("/audit")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Map<String, Object>>> audit(
            @RequestParam(defaultValue = "50") int limit,
            @RequestParam(required = false) String action
    ) {
        return ResponseEntity.ok(adminAuditService.list(limit, action));
    }

    @GetMapping("/shifts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AdminDtos.StaffShiftResponse>> shifts() {
        return ResponseEntity.ok(staffShiftService.list());
    }

    @GetMapping("/shifts/on-call")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AdminDtos.StaffShiftResponse>> onCall() {
        return ResponseEntity.ok(staffShiftService.onCall(Instant.now()));
    }

    @PostMapping("/shifts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.StaffShiftResponse> createShift(
            @Valid @RequestBody AdminDtos.CreateStaffShiftRequest request
    ) {
        return ResponseEntity.ok(staffShiftService.create(request));
    }

    @DeleteMapping("/shifts/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteShift(@PathVariable UUID id) {
        staffShiftService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/metrics")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> metrics() {
        return ResponseEntity.ok(adminMetricsService.metrics());
    }

    @GetMapping("/moderation/events")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<Map<String, Object>>> moderationEvents() {
        return ResponseEntity.ok(moderationEventService.recent());
    }

    @GetMapping("/moderation/stats")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> moderationStats() {
        return ResponseEntity.ok(moderationEventService.stats());
    }

    @GetMapping("/ops/readiness")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Map<String, Object>> readiness() {
        return ResponseEntity.ok(opsReadinessService.readiness());
    }

    @GetMapping("/concierge/tasks")
    public ResponseEntity<List<Map<String, Object>>> conciergeTasks() {
        return ResponseEntity.ok(conciergeTaskService.listOpen());
    }

    @GetMapping("/concierge/meetings")
    public ResponseEntity<List<Map<String, Object>>> conciergeMeetings() {
        return ResponseEntity.ok(conciergeTaskService.todaysMeetings());
    }

    @PostMapping("/concierge/tasks/{id}/ack")
    public ResponseEntity<Map<String, Object>> ackTask(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(conciergeTaskService.ack(id, principal.getUserId()));
    }

    @PostMapping("/concierge/tasks/{id}/done")
    public ResponseEntity<Map<String, Object>> doneTask(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) Map<String, String> body
    ) {
        String notes = body == null ? null : body.get("notes");
        return ResponseEntity.ok(conciergeTaskService.done(id, principal.getUserId(), notes));
    }
}
