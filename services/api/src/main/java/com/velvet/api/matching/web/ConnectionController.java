package com.velvet.api.matching.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.matching.service.MatchingService;
import com.velvet.api.matching.web.dto.MatchDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

/**
 * Marketplace-facing alias for {@link MatchController}. Same payloads and behavior;
 * clients should prefer {@code /v1/connections} over legacy {@code /v1/matches}.
 */
@RestController
@RequestMapping("/v1/connections")
public class ConnectionController {

    private final MatchingService matchingService;

    public ConnectionController(MatchingService matchingService) {
        this.matchingService = matchingService;
    }

    @GetMapping
    public ResponseEntity<List<MatchDtos.MatchResponse>> list(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(matchingService.myMatches(principal.getUserId()));
    }

    @GetMapping("/history")
    public ResponseEntity<List<MatchDtos.MatchResponse>> history(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(matchingService.history(principal.getUserId()));
    }

    @GetMapping("/mutual")
    public ResponseEntity<List<MatchDtos.MatchResponse>> mutual(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(matchingService.mutualInbox(principal.getUserId()));
    }

    @PostMapping("/{id}/decision")
    public ResponseEntity<MatchDtos.MatchResponse> decide(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody MatchDtos.DecisionRequest request
    ) {
        return ResponseEntity.ok(matchingService.decide(principal.getUserId(), id, request));
    }
}
