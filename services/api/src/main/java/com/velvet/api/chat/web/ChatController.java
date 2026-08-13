package com.velvet.api.chat.web;

import com.velvet.api.chat.service.ChatService;
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
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@RestController
@RequestMapping("/v1/chat")
public class ChatController {

    private final ChatService chatService;
    private final ExecutorService sseExecutor = Executors.newCachedThreadPool();

    public ChatController(ChatService chatService) {
        this.chatService = chatService;
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
     * Near-realtime: ~1.5s DB poll + typing pulses over SSE while connected.
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
        SseEmitter emitter = new SseEmitter(5 * 60_000L);
        Instant[] cursor = {after == null ? Instant.EPOCH : after};
        boolean[] lastTyping = {false};
        sseExecutor.execute(() -> {
            try {
                // ~5 minutes at 1.5s cadence
                for (int i = 0; i < 200; i++) {
                    List<ChatDtos.MessageResponse> batch = chatService.messagesAfter(userId, connectionId, cursor[0]);
                    for (ChatDtos.MessageResponse msg : batch) {
                        emitter.send(SseEmitter.event().name("message").data(msg));
                        if (msg.createdAt() != null && msg.createdAt().isAfter(cursor[0])) {
                            cursor[0] = msg.createdAt();
                        }
                    }
                    boolean typing = chatService.isPeerTyping(userId, connectionId);
                    if (typing != lastTyping[0] || i % 4 == 0) {
                        lastTyping[0] = typing;
                        emitter.send(SseEmitter.event().name("typing").data(Map.of("peerTyping", typing)));
                    }
                    if (i % 8 == 0) {
                        emitter.send(SseEmitter.event().name("ping").data(Map.of("t", Instant.now().toString())));
                    }
                    Thread.sleep(1_500L);
                }
                emitter.complete();
            } catch (IOException | InterruptedException e) {
                emitter.completeWithError(e);
                Thread.currentThread().interrupt();
            } catch (Exception e) {
                emitter.completeWithError(e);
            }
        });
        emitter.onTimeout(emitter::complete);
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
