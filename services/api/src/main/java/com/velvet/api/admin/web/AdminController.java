package com.velvet.api.admin.web;

import com.velvet.api.admin.service.AdminInviteService;
import com.velvet.api.admin.service.AdminMemberService;
import com.velvet.api.admin.service.AdminMetricsService;
import com.velvet.api.admin.service.AdminVenueService;
import com.velvet.api.admin.web.dto.AdminDtos;
import com.velvet.api.billing.service.BillingService;
import com.velvet.api.billing.service.EarningsService;
import com.velvet.api.billing.web.dto.BillingDtos;
import com.velvet.api.billing.web.dto.EarningsDtos;
import com.velvet.api.chat.service.ChatService;
import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.matching.service.MatchingService;
import com.velvet.api.matching.web.dto.MatchDtos;
import com.velvet.api.notify.ConciergeNotifyService;
import com.velvet.api.safety.domain.PanicAlertEntity;
import com.velvet.api.safety.service.SafetyService;
import com.velvet.api.verification.service.VerificationService;
import com.velvet.api.verification.web.dto.VerificationDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/admin")
public class AdminController {

    private final VerificationService verificationService;
    private final MatchingService matchingService;
    private final AdminMemberService adminMemberService;
    private final SafetyService safetyService;
    private final ConciergeNotifyService notifyService;
    private final ChatService chatService;
    private final AdminInviteService inviteService;
    private final AdminVenueService venueService;
    private final EarningsService earningsService;
    private final BillingService billingService;
    private final AdminMetricsService metricsService;

    public AdminController(
            VerificationService verificationService,
            MatchingService matchingService,
            AdminMemberService adminMemberService,
            SafetyService safetyService,
            ConciergeNotifyService notifyService,
            ChatService chatService,
            AdminInviteService inviteService,
            AdminVenueService venueService,
            EarningsService earningsService,
            BillingService billingService,
            AdminMetricsService metricsService
    ) {
        this.verificationService = verificationService;
        this.matchingService = matchingService;
        this.adminMemberService = adminMemberService;
        this.safetyService = safetyService;
        this.notifyService = notifyService;
        this.chatService = chatService;
        this.inviteService = inviteService;
        this.venueService = venueService;
        this.earningsService = earningsService;
        this.billingService = billingService;
        this.metricsService = metricsService;
    }

    @GetMapping("/verification/queue")
    public ResponseEntity<List<VerificationDtos.VerificationResponse>> verificationQueue() {
        return ResponseEntity.ok(verificationService.queue());
    }

    @PostMapping("/verification/{caseId}/review")
    public ResponseEntity<VerificationDtos.VerificationResponse> review(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID caseId,
            @Valid @RequestBody VerificationDtos.ReviewRequest request
    ) {
        return ResponseEntity.ok(verificationService.review(caseId, principal.getUserId(), request));
    }

    @GetMapping("/photos/review-queue")
    public ResponseEntity<List<com.velvet.api.identity.web.dto.ProfileDtos.PhotoReviewResponse>> photoReviewQueue() {
        return ResponseEntity.ok(adminMemberService.photoReviewQueue());
    }

    @PostMapping("/members/{userId}/photos/review")
    public ResponseEntity<com.velvet.api.identity.web.dto.ProfileDtos.PhotoReviewResponse> reviewPhotos(
            @PathVariable UUID userId,
            @Valid @RequestBody com.velvet.api.identity.web.dto.ProfileDtos.ReviewPhotosRequest request
    ) {
        return ResponseEntity.ok(adminMemberService.reviewPhotos(userId, request));
    }

    @GetMapping("/members")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AdminDtos.MemberSummary>> members(
            @RequestParam(required = false) String q,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String role
    ) {
        if ((q != null && !q.isBlank()) || (status != null && !status.isBlank()) || (role != null && !role.isBlank())) {
            return ResponseEntity.ok(adminMemberService.search(q, status, role));
        }
        return ResponseEntity.ok(adminMemberService.listMembers());
    }

    @PatchMapping("/members/{userId}/notes")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.MemberSummary> updateNotes(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID userId,
            @Valid @RequestBody AdminDtos.MemberNotesRequest request
    ) {
        return ResponseEntity.ok(adminMemberService.updateNotes(principal.getUserId(), userId, request.notes()));
    }

    @PatchMapping("/members/{userId}/status")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.MemberSummary> updateStatus(
            @PathVariable UUID userId,
            @Valid @RequestBody AdminDtos.UpdateMemberStatusRequest request
    ) {
        return ResponseEntity.ok(adminMemberService.updateStatus(userId, request));
    }

    @PostMapping("/members/promote")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.MemberSummary> promote(
            @Valid @RequestBody AdminDtos.PromoteRequest request
    ) {
        return ResponseEntity.ok(adminMemberService.promote(request));
    }

    @PostMapping({"/connections", "/matches"})
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<MatchDtos.MatchResponse> createMatch(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody MatchDtos.CreateMatchRequest request
    ) {
        return ResponseEntity.ok(matchingService.create(principal.getUserId(), request));
    }

    @GetMapping("/safety/panics")
    public ResponseEntity<List<Map<String, Object>>> panics() {
        return ResponseEntity.ok(safetyService.openPanics().stream().map(this::panicMap).toList());
    }

    @PostMapping("/safety/panics/{id}/ack")
    public ResponseEntity<Map<String, Object>> ackPanic(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(panicMap(safetyService.acknowledgePanic(id, principal.getUserId())));
    }

    @GetMapping("/safety/reports")
    public ResponseEntity<List<Map<String, Object>>> reports() {
        return ResponseEntity.ok(safetyService.openReports().stream()
                .map(r -> Map.<String, Object>of(
                        "id", r.getId().toString(),
                        "category", r.getCategory(),
                        "details", r.getDetails(),
                        "status", r.getStatus().name(),
                        "reporterId", r.getReporterId().toString(),
                        "createdAt", r.getCreatedAt().toString()
                ))
                .toList());
    }

    @PostMapping("/safety/reports/{id}/review")
    public ResponseEntity<Map<String, Object>> reviewReport(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody AdminDtos.ReviewReportRequest request
    ) {
        var r = safetyService.reviewReport(id, principal.getUserId(), request.status(), request.notes());
        return ResponseEntity.ok(Map.of(
                "id", r.getId().toString(),
                "status", r.getStatus().name(),
                "staffNotes", r.getStaffNotes() == null ? "" : r.getStaffNotes(),
                "reviewedAt", r.getReviewedAt() == null ? "" : r.getReviewedAt().toString()
        ));
    }

    @GetMapping("/notifications/outbox")
    public ResponseEntity<List<Map<String, Object>>> outbox(
            @RequestParam(defaultValue = "50") int limit
    ) {
        return ResponseEntity.ok(notifyService.recent(limit).stream()
                .map(n -> Map.<String, Object>of(
                        "id", n.getId().toString(),
                        "channel", n.getChannel(),
                        "recipient", n.getRecipient(),
                        "subject", n.getSubject() == null ? "" : n.getSubject(),
                        "body", n.getBody(),
                        "relatedType", n.getRelatedType() == null ? "" : n.getRelatedType(),
                        "status", n.getStatus(),
                        "createdAt", n.getCreatedAt().toString()
                ))
                .toList());
    }

    @GetMapping("/chat/held")
    public ResponseEntity<List<Map<String, Object>>> heldMessages() {
        return ResponseEntity.ok(chatService.heldQueue());
    }

    @PostMapping("/chat/held/{messageId}/review")
    public ResponseEntity<Map<String, Object>> reviewHeld(
            @PathVariable UUID messageId,
            @Valid @RequestBody AdminDtos.ReviewHeldRequest request
    ) {
        return ResponseEntity.ok(chatService.reviewHeld(messageId, request.approve()));
    }

    @GetMapping("/invites")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AdminDtos.InviteResponse>> invites() {
        return ResponseEntity.ok(inviteService.list());
    }

    @PostMapping("/invites")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.InviteResponse> createInvite(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody AdminDtos.CreateInviteRequest request
    ) {
        return ResponseEntity.ok(inviteService.create(principal.getUserId(), request));
    }

    @PostMapping("/invites/{id}/deactivate")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.InviteResponse> deactivateInvite(@PathVariable UUID id) {
        return ResponseEntity.ok(inviteService.deactivate(id));
    }

    @GetMapping("/venues")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AdminDtos.VenueAdminResponse>> venues() {
        return ResponseEntity.ok(venueService.listAll());
    }

    @PostMapping("/venues")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.VenueAdminResponse> createVenue(
            @Valid @RequestBody AdminDtos.UpsertVenueRequest request
    ) {
        return ResponseEntity.ok(venueService.create(request));
    }

    @PatchMapping("/venues/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.VenueAdminResponse> updateVenue(
            @PathVariable UUID id,
            @Valid @RequestBody AdminDtos.UpsertVenueRequest request
    ) {
        return ResponseEntity.ok(venueService.update(id, request));
    }

    @PostMapping("/venues/{id}/active")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.VenueAdminResponse> setVenueActive(
            @PathVariable UUID id,
            @RequestParam boolean active
    ) {
        return ResponseEntity.ok(venueService.setActive(id, active));
    }

    @PostMapping("/venues/{id}/partner")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AdminDtos.VenueAdminResponse> assignPartner(
            @PathVariable UUID id,
            @RequestParam UUID partnerUserId
    ) {
        return ResponseEntity.ok(venueService.assignPartner(id, partnerUserId));
    }

    @GetMapping("/payouts")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<EarningsDtos.AdminPayoutItem>> payouts(
            @RequestParam(required = false) String status
    ) {
        return ResponseEntity.ok(earningsService.adminQueue(status));
    }

    @PostMapping("/payouts/{id}/complete")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EarningsDtos.AdminPayoutItem> completePayout(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) EarningsDtos.PayoutDecisionRequest request
    ) {
        String notes = request == null ? null : request.notes();
        return ResponseEntity.ok(earningsService.completePayout(id, principal.getUserId(), notes));
    }

    @PostMapping("/payouts/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<EarningsDtos.AdminPayoutItem> rejectPayout(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) EarningsDtos.PayoutDecisionRequest request
    ) {
        String notes = request == null ? null : request.notes();
        return ResponseEntity.ok(earningsService.rejectPayout(id, principal.getUserId(), notes));
    }

    private Map<String, Object> panicMap(PanicAlertEntity a) {
        return Map.of(
                "id", a.getId().toString(),
                "userId", a.getUserId().toString(),
                "bookingId", a.getBookingId() == null ? "" : a.getBookingId().toString(),
                "connectionId", a.getMatchId() == null ? "" : a.getMatchId().toString(),
                "status", a.getStatus().name(),
                "note", a.getNote() == null ? "" : a.getNote(),
                "createdAt", a.getCreatedAt().toString()
        );
    }

    // ── Payments ──────────────────────────────────────────────────────────────


    /**
     * Paginated list of all payment intents, optionally filtered by status
     * (PENDING | CHECKOUT | PAID | FAILED).
     */
    @GetMapping("/payments")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BillingDtos.PaymentIntentAdminItem>> adminPayments(
            @RequestParam(required = false) String status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(billingService.listPaymentsForAdmin(status, page, size));
    }

    /**
     * Alias queue specifically for viewing pending refunds.
     */
    @GetMapping("/refunds")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<BillingDtos.PaymentIntentAdminItem>> adminRefunds(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        return ResponseEntity.ok(billingService.listPaymentsForAdmin("REFUND_PENDING", page, size));
    }

    /**
     * Manually approve a payment intent that could not be auto-verified.
     * Sets status to PAID and activates the associated subscription or booking.
     */
    @PostMapping("/payments/{id}/approve")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BillingDtos.PaymentIntentAdminItem> approvePayment(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) BillingDtos.AdminPaymentDecisionRequest body
    ) {
        String notes = body == null ? null : body.notes();
        return ResponseEntity.ok(billingService.approvePaymentByAdmin(id, principal.getUserId(), notes));
    }

    /**
     * Manually reject a payment intent (marks FAILED, blocks future proof submissions
     * until the client contacts support).
     */
    @PostMapping("/payments/{id}/reject")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BillingDtos.PaymentIntentAdminItem> rejectPayment(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) BillingDtos.AdminPaymentDecisionRequest body
    ) {
        String notes = body == null ? null : body.notes();
        return ResponseEntity.ok(billingService.rejectPaymentByAdmin(id, principal.getUserId(), notes));
    }

    @PostMapping("/payments/{id}/refund")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<BillingDtos.PaymentIntentAdminItem> overrideRefundPayment(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) BillingDtos.AdminPaymentDecisionRequest req
    ) {
        String notes = req != null ? req.notes() : null;
        return ResponseEntity.ok(billingService.markRefundedByAdmin(id, principal.getUserId(), notes));
    }
}
