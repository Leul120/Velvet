package com.velvet.api.booking.web;

import com.velvet.api.booking.service.AvailabilityService;
import com.velvet.api.booking.web.dto.AvailabilityDtos;
import com.velvet.api.identity.security.VelvetPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/v1/availability")
public class AvailabilityController {

    private final AvailabilityService availabilityService;

    public AvailabilityController(AvailabilityService availabilityService) {
        this.availabilityService = availabilityService;
    }

    @GetMapping("/me")
    public ResponseEntity<AvailabilityDtos.WindowsResponse> mine(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(availabilityService.listMine(principal.getUserId()));
    }

    @GetMapping("/users/{userId}")
    public ResponseEntity<AvailabilityDtos.WindowsResponse> forUser(@PathVariable UUID userId) {
        return ResponseEntity.ok(availabilityService.listPublic(userId));
    }

    @PostMapping
    public ResponseEntity<AvailabilityDtos.WindowResponse> create(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody AvailabilityDtos.CreateWindowRequest request
    ) {
        return ResponseEntity.ok(availabilityService.create(principal.getUserId(), request));
    }

    @DeleteMapping("/{windowId}")
    public ResponseEntity<Void> delete(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID windowId
    ) {
        availabilityService.delete(principal.getUserId(), windowId);
        return ResponseEntity.noContent().build();
    }
}
