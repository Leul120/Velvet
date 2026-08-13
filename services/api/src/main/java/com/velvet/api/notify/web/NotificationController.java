package com.velvet.api.notify.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.notify.MemberNotifyService;
import com.velvet.api.notify.web.dto.NotifyDtos;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/me/notifications")
public class NotificationController {

    private final MemberNotifyService notifyService;

    public NotificationController(MemberNotifyService notifyService) {
        this.notifyService = notifyService;
    }

    @GetMapping
    public ResponseEntity<List<NotifyDtos.NotificationResponse>> list(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @RequestParam(defaultValue = "false") boolean unreadOnly
    ) {
        return ResponseEntity.ok(notifyService.inbox(principal.getUserId(), unreadOnly));
    }

    @GetMapping("/unread-count")
    public ResponseEntity<Map<String, Long>> unreadCount(@AuthenticationPrincipal VelvetPrincipal principal) {
        return ResponseEntity.ok(Map.of("count", notifyService.unreadCount(principal.getUserId())));
    }

    @PostMapping("/{id}/read")
    public ResponseEntity<NotifyDtos.NotificationResponse> markRead(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(notifyService.markRead(principal.getUserId(), id));
    }

    @PostMapping("/read-all")
    public ResponseEntity<Map<String, Integer>> markAllRead(@AuthenticationPrincipal VelvetPrincipal principal) {
        return ResponseEntity.ok(Map.of("updated", notifyService.markAllRead(principal.getUserId())));
    }
}
