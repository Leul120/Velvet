package com.velvet.api.safety.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.safety.service.BlockService;
import com.velvet.api.safety.service.SafetyService;
import com.velvet.api.safety.web.dto.SafetyDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/safety")
public class SafetyController {

    private final SafetyService safetyService;
    private final BlockService blockService;

    public SafetyController(SafetyService safetyService, BlockService blockService) {
        this.safetyService = safetyService;
        this.blockService = blockService;
    }

    @PostMapping("/panic")
    public ResponseEntity<SafetyDtos.PanicResponse> panic(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody SafetyDtos.PanicRequest request
    ) {
        return ResponseEntity.ok(safetyService.panic(principal.getUserId(), request));
    }

    @PostMapping("/trip-share")
    public ResponseEntity<SafetyDtos.TripShareResponse> tripShare(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody SafetyDtos.TripShareRequest request
    ) {
        return ResponseEntity.ok(safetyService.shareTrip(principal.getUserId(), request));
    }

    @PostMapping("/reports")
    public ResponseEntity<SafetyDtos.ReportResponse> report(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody SafetyDtos.ReportRequest request
    ) {
        return ResponseEntity.ok(safetyService.report(principal.getUserId(), request));
    }

    @GetMapping("/blocks")
    public ResponseEntity<List<SafetyDtos.BlockResponse>> blocks(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(blockService.list(principal.getUserId()));
    }

    @PostMapping("/blocks")
    public ResponseEntity<SafetyDtos.BlockResponse> block(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody SafetyDtos.BlockRequest request
    ) {
        return ResponseEntity.ok(blockService.block(
                principal.getUserId(),
                request.blockedUserId(),
                request.reason()
        ));
    }

    @DeleteMapping("/blocks/{blockedUserId}")
    public ResponseEntity<Map<String, String>> unblock(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID blockedUserId
    ) {
        blockService.unblock(principal.getUserId(), blockedUserId);
        return ResponseEntity.ok(Map.of("status", "UNBLOCKED"));
    }
}
