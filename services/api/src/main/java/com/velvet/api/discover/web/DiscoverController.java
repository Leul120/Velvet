package com.velvet.api.discover.web;

import com.velvet.api.discover.service.DiscoverService;
import com.velvet.api.discover.web.dto.DiscoverDtos;
import com.velvet.api.identity.security.VelvetPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/v1/discover")
public class DiscoverController {

    private final DiscoverService discoverService;

    public DiscoverController(DiscoverService discoverService) {
        this.discoverService = discoverService;
    }

    @GetMapping
    public ResponseEntity<DiscoverDtos.DiscoverFeedResponse> feed(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @RequestParam(defaultValue = "20") int limit
    ) {
        return ResponseEntity.ok(discoverService.feed(principal.getUserId(), limit));
    }

    @GetMapping("/received")
    public ResponseEntity<DiscoverDtos.DiscoverFeedResponse> received(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @RequestParam(defaultValue = "20") int limit
    ) {
        return ResponseEntity.ok(discoverService.receivedLikes(principal.getUserId(), limit));
    }

    @GetMapping("/passes")
    public ResponseEntity<DiscoverDtos.DiscoverFeedResponse> recentPasses(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @RequestParam(defaultValue = "5") int limit
    ) {
        return ResponseEntity.ok(discoverService.recentPasses(principal.getUserId(), limit));
    }

    @PostMapping("/passes/{userId}/rewind")
    public ResponseEntity<DiscoverDtos.UndoResponse> rewindPass(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID userId
    ) {
        return ResponseEntity.ok(discoverService.rewindPass(principal.getUserId(), userId));
    }

    @PostMapping("/undo")
    public ResponseEntity<DiscoverDtos.UndoResponse> undo(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(discoverService.undo(principal.getUserId()));
    }

    @PostMapping("/{userId}/action")
    public ResponseEntity<DiscoverDtos.DiscoverActionResponse> action(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID userId,
            @Valid @RequestBody DiscoverDtos.DiscoverActionRequest request
    ) {
        return ResponseEntity.ok(discoverService.action(principal.getUserId(), userId, request));
    }
}
