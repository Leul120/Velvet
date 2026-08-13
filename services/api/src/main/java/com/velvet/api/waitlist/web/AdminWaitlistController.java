package com.velvet.api.waitlist.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.waitlist.service.WaitlistService;
import com.velvet.api.waitlist.web.dto.WaitlistDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/admin/waitlist")
public class AdminWaitlistController {

    private final WaitlistService waitlistService;

    public AdminWaitlistController(WaitlistService waitlistService) {
        this.waitlistService = waitlistService;
    }

    @GetMapping
    public ResponseEntity<List<WaitlistDtos.ApplicationResponse>> pending() {
        return ResponseEntity.ok(waitlistService.listPending());
    }

    @GetMapping("/all")
    public ResponseEntity<List<WaitlistDtos.ApplicationResponse>> all() {
        return ResponseEntity.ok(waitlistService.listAll());
    }

    @PostMapping("/{id}/approve")
    public ResponseEntity<WaitlistDtos.ApplicationResponse> approve(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody(required = false) WaitlistDtos.ReviewRequest request
    ) {
        return ResponseEntity.ok(waitlistService.approve(id, principal.getUserId()));
    }

    @PostMapping("/{id}/reject")
    public ResponseEntity<WaitlistDtos.ApplicationResponse> reject(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody(required = false) WaitlistDtos.ReviewRequest request
    ) {
        return ResponseEntity.ok(waitlistService.reject(id, principal.getUserId()));
    }
}
