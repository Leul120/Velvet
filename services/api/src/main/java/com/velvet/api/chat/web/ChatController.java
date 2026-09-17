package com.velvet.api.chat.web;

import com.velvet.api.chat.service.ChatService;
import com.velvet.api.chat.service.ChatStreamHub;
import com.velvet.api.chat.web.dto.ChatDtos;
import com.velvet.api.identity.security.VelvetPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/chat")
public class ChatController {

    private final ChatService chatService;
    private final ChatStreamHub chatStreamHub;

    public ChatController(ChatService chatService, ChatStreamHub chatStreamHub) {
        this.chatService = chatService;
        this.chatStreamHub = chatStreamHub;
    }

    @GetMapping({"/matches/{connectionId}", "/connections/{connectionId}"})
    public ResponseEntity<ChatDtos.ThreadDetailResponse> thread(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID connectionId
    ) {
        return ResponseEntity.ok(chatService.getByMatch(principal.getUserId(), connectionId));
    }

    @GetMapping({"/matches/{connectionId}/messages", "/connections/{connectionId}/messages"})
    public ResponseEntity<List<ChatDtos.MessageResponse>> messagesAfter(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID connectionId,
            @RequestParam(required = false) Instant after
    ) {
        return ResponseEntity.ok(chatService.messagesAfter(principal.getUserId(), connectionId, after));
    }

    /**
     * Event-driven SSE: broadcasts instant messages & typing events via ChatStreamHub,
     * with periodic keep-alive pings. Zero thread starvation and zero DB polling storm.
     */
    @GetMapping(
            path = {"/matches/{connectionId}/stream", "/connections/{connectionId}/stream"},
            produces = MediaType.TEXT_EVENT_STREAM_VALUE
    )
    public SseEmitter stream(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID connectionId,
            @RequestParam(required = false) Instant after
    ) {
        UUID userId = principal.getUserId();
        chatService.assertParticipant(userId, connectionId);

        SseEmitter emitter = new SseEmitter(10 * 60_000L);

        // Catch up any messages after cursor if requested
        if (after != null) {
            List<ChatDtos.MessageResponse> catchup = chatService.messagesAfter(userId, connectionId, after);
            for (ChatDtos.MessageResponse msg : catchup) {
                try {
                    emitter.send(SseEmitter.event().name("message").data(msg));
                } catch (IOException e) {
                    emitter.complete();
                    return emitter;
                }
            }
        }

        // Send initial typing status
        boolean typing = chatService.isPeerTyping(userId, connectionId);
        try {
            emitter.send(SseEmitter.event().name("typing").data(Map.of("peerTyping", typing)));
        } catch (IOException ignored) {}

        chatStreamHub.register(connectionId, emitter);
        return emitter;
    }

    @PostMapping({"/matches/{connectionId}/messages", "/connections/{connectionId}/messages"})
    public ResponseEntity<ChatDtos.MessageResponse> send(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID connectionId,
            @Valid @RequestBody ChatDtos.SendMessageRequest request
    ) {
        return ResponseEntity.ok(chatService.send(principal.getUserId(), connectionId, request));
    }

    @PostMapping({"/matches/{connectionId}/read", "/connections/{connectionId}/read"})
    public ResponseEntity<Map<String, Object>> markRead(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID connectionId
    ) {
        chatService.markRead(principal.getUserId(), connectionId);
        return ResponseEntity.ok(Map.of("ok", true));
    }

    @PostMapping({"/matches/{connectionId}/typing", "/connections/{connectionId}/typing"})
    public ResponseEntity<ChatDtos.TypingStatusResponse> typing(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID connectionId,
            @RequestBody ChatDtos.TypingRequest request
    ) {
        chatService.setTyping(principal.getUserId(), connectionId, request.typing());
        return ResponseEntity.ok(new ChatDtos.TypingStatusResponse(
                chatService.isPeerTyping(principal.getUserId(), connectionId)
        ));
    }
}
