package com.velvet.api.chat.web.dto;

import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;

public final class ChatDtos {

    private ChatDtos() {}

    public record ThreadResponse(
            String id,
            String connectionId,
            String status,
            boolean canSend,
            Instant windowOpensAt,
            Instant windowClosesAt,
            String windowReason
    ) {}

    public record MessageResponse(
            String id,
            String threadId,
            String senderId,
            String body,
            String moderationStatus,
            Instant createdAt,
            String mediaType,
            String mediaUrl,
            String mediaName,
            String mediaMime,
            boolean readByPeer
    ) {}

    public record SendMessageRequest(
            @Size(max = 2000) String body,
            @Size(max = 16) String mediaType,
            @Size(max = 2000) String mediaUrl,
            @Size(max = 255) String mediaName,
            @Size(max = 120) String mediaMime
    ) {}

    public record TypingRequest(boolean typing) {}

    public record TypingStatusResponse(boolean peerTyping) {}

    public record ConversationStarterResponse(
            String id,
            String textEn,
            String textAm
    ) {}

    public record ThreadDetailResponse(
            ThreadResponse thread,
            List<MessageResponse> messages,
            List<ConversationStarterResponse> conversationStarters,
            Instant peerLastReadAt,
            boolean peerTyping
    ) {}
}
