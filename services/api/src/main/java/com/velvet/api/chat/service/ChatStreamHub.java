package com.velvet.api.chat.service;

import com.velvet.api.chat.web.dto.ChatDtos;
import jakarta.annotation.PreDestroy;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Component
public class ChatStreamHub {

    private static final Logger log = LoggerFactory.getLogger(ChatStreamHub.class);

    private final ConcurrentHashMap<UUID, CopyOnWriteArrayList<SseEmitter>> emitters = new ConcurrentHashMap<>();
    private final ScheduledExecutorService pingScheduler = Executors.newSingleThreadScheduledExecutor(r -> {
        Thread t = new Thread(r, "chat-sse-ping");
        t.setDaemon(true);
        return t;
    });

    public ChatStreamHub() {
        // Send a keep-alive ping event every 20 seconds to all connected SSE clients
        pingScheduler.scheduleAtFixedRate(this::sendHeartbeats, 20, 20, TimeUnit.SECONDS);
    }

    public void register(UUID connectionId, SseEmitter emitter) {
        emitters.computeIfAbsent(connectionId, k -> new CopyOnWriteArrayList<>()).add(emitter);

        Runnable cleanup = () -> remove(connectionId, emitter);
        emitter.onCompletion(cleanup);
        emitter.onTimeout(cleanup);
        emitter.onError(e -> cleanup.run());
    }

    public void broadcastMessage(UUID connectionId, ChatDtos.MessageResponse msg) {
        var list = emitters.get(connectionId);
        if (list == null || list.isEmpty()) return;

        for (SseEmitter emitter : list) {
            try {
                emitter.send(SseEmitter.event().name("message").data(msg));
            } catch (Exception e) {
                remove(connectionId, emitter);
            }
        }
    }

    public void broadcastTyping(UUID connectionId, boolean peerTyping) {
        var list = emitters.get(connectionId);
        if (list == null || list.isEmpty()) return;

        for (SseEmitter emitter : list) {
            try {
                emitter.send(SseEmitter.event().name("typing").data(Map.of("peerTyping", peerTyping)));
            } catch (Exception e) {
                remove(connectionId, emitter);
            }
        }
    }

    private void sendHeartbeats() {
        Instant now = Instant.now();
        emitters.forEach((connectionId, list) -> {
            for (SseEmitter emitter : list) {
                try {
                    emitter.send(SseEmitter.event().name("ping").data(Map.of("t", now.toString())));
                } catch (Exception e) {
                    remove(connectionId, emitter);
                }
            }
        });
    }

    private void remove(UUID connectionId, SseEmitter emitter) {
        var list = emitters.get(connectionId);
        if (list != null) {
            list.remove(emitter);
            if (list.isEmpty()) {
                emitters.remove(connectionId);
            }
        }
    }

    @PreDestroy
    public void shutdown() {
        pingScheduler.shutdownNow();
    }
}
