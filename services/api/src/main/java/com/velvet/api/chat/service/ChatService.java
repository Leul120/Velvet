package com.velvet.api.chat.service;

import com.velvet.api.chat.domain.*;
import com.velvet.api.chat.moderation.ContentModerator;
import com.velvet.api.chat.moderation.ModerationPipeline;
import com.velvet.api.chat.repo.ChatThreadRepository;
import com.velvet.api.chat.repo.IcebreakerRepository;
import com.velvet.api.chat.repo.MessageRepository;
import com.velvet.api.chat.web.dto.ChatDtos;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.ratelimit.RateLimitService;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.domain.MatchStatus;
import com.velvet.api.matching.repo.ConnectionRepository;
import com.velvet.api.notify.MemberNotifyService;
import com.velvet.api.safety.service.BlockService;
import com.velvet.api.storage.ObjectStorageService;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Service
public class ChatService {

    private static final int ICEBREAKER_FIRST_COUNT = 2;
    private static final Duration TYPING_TTL = Duration.ofSeconds(4);

    private final ChatThreadRepository threadRepository;
    private final MessageRepository messageRepository;
    private final IcebreakerRepository icebreakerRepository;
    private final ConnectionRepository connectionRepository;
    private final ModerationPipeline moderator;
    private final RateLimitService rateLimitService;
    private final BlockService blockService;
    private final ModerationEventService moderationEvents;
    private final ChatWindowService chatWindowService;
    private final StringRedisTemplate redis;
    private final MemberNotifyService memberNotifyService;
    private final UserRepository userRepository;
    private final ObjectStorageService storageService;

    public ChatService(
            ChatThreadRepository threadRepository,
            MessageRepository messageRepository,
            IcebreakerRepository icebreakerRepository,
            ConnectionRepository connectionRepository,
            ModerationPipeline moderator,
            RateLimitService rateLimitService,
            BlockService blockService,
            ModerationEventService moderationEvents,
            ChatWindowService chatWindowService,
            StringRedisTemplate redis,
            MemberNotifyService memberNotifyService,
            UserRepository userRepository,
            ObjectStorageService storageService
    ) {
        this.threadRepository = threadRepository;
        this.messageRepository = messageRepository;
        this.icebreakerRepository = icebreakerRepository;
        this.connectionRepository = connectionRepository;
        this.moderator = moderator;
        this.rateLimitService = rateLimitService;
        this.blockService = blockService;
        this.moderationEvents = moderationEvents;
        this.chatWindowService = chatWindowService;
        this.redis = redis;
        this.memberNotifyService = memberNotifyService;
        this.userRepository = userRepository;
        this.storageService = storageService;
    }

    @Transactional
    public ChatThreadEntity openForMatch(ConnectionEntity match) {
        return threadRepository.findByConnectionId(match.getId()).orElseGet(() ->
                threadRepository.save(ChatThreadEntity.builder()
                        .connectionId(match.getId())
                        .memberAId(match.getMemberAId())
                        .memberBId(match.getMemberBId())
                        .status(ThreadStatus.OPEN)
                        .build())
        );
    }

    @Transactional
    public ChatDtos.ThreadDetailResponse getByMatch(UUID userId, UUID matchId) {
        ChatThreadEntity thread = requireParticipantThread(userId, matchId);
        markReadInternal(thread, userId);
        List<ChatDtos.MessageResponse> messages = messageRepository
                .findByThreadIdAndModerationStatusNotOrderByCreatedAtAsc(thread.getId(), ModerationStatus.BLOCKED)
                .stream()
                .filter(m -> visibleTo(userId, m))
                .map(m -> toMessage(m, thread))
                .toList();
        List<ChatDtos.ConversationStarterResponse> conversationStarters = icebreakerRepository.findByActiveTrue().stream()
                .map(i -> new ChatDtos.ConversationStarterResponse(i.getId().toString(), i.getTextEn(), i.getTextAm()))
                .toList();
        return new ChatDtos.ThreadDetailResponse(
                toThread(thread),
                messages,
                conversationStarters,
                peerLastReadAt(thread, userId),
                isPeerTyping(userId, matchId)
        );
    }

    @Transactional(readOnly = true)
    public List<ChatDtos.MessageResponse> messagesAfter(UUID userId, UUID matchId, Instant after) {
        ChatThreadEntity thread = requireParticipantThread(userId, matchId);
        Instant cursor = after == null ? Instant.EPOCH : after;
        return messageRepository.findAfter(thread.getId(), ModerationStatus.BLOCKED, cursor).stream()
                .filter(m -> visibleTo(userId, m))
                .map(m -> toMessage(m, thread))
                .toList();
    }

    @Transactional
    public void markRead(UUID userId, UUID matchId) {
        ChatThreadEntity thread = requireParticipantThread(userId, matchId);
        markReadInternal(thread, userId);
    }

    public void setTyping(UUID userId, UUID matchId, boolean typing) {
        assertParticipant(userId, matchId);
        String key = typingKey(matchId, userId);
        if (typing) {
            redis.opsForValue().set(key, "1", TYPING_TTL.toSeconds(), TimeUnit.SECONDS);
        } else {
            redis.delete(key);
        }
    }

    @Transactional(readOnly = true)
    public boolean isPeerTyping(UUID userId, UUID matchId) {
        ConnectionEntity match = assertParticipant(userId, matchId);
        UUID peer = match.getMemberAId().equals(userId) ? match.getMemberBId() : match.getMemberAId();
        String v = redis.opsForValue().get(typingKey(matchId, peer));
        return v != null && !v.isBlank();
    }

    @Transactional(readOnly = true)
    public InboxMeta inboxMeta(UUID matchId, UUID viewerId) {
        return threadRepository.findByConnectionId(matchId)
                .map(thread -> buildInboxMeta(thread, viewerId))
                .orElseGet(() -> InboxMeta.empty());
    }

    @Transactional
    public ChatDtos.MessageResponse send(UUID userId, UUID matchId, ChatDtos.SendMessageRequest request) {
        rateLimitService.checkChat(userId.toString());
        ChatThreadEntity thread = requireParticipantThread(userId, matchId);
        if (thread.getStatus() != ThreadStatus.OPEN && thread.getStatus() != ThreadStatus.LOCKED) {
            throw new BusinessException("THREAD_LOCKED", "This conversation is locked.");
        }
        chatWindowService.assertCanSend(matchId);
        if (thread.getStatus() == ThreadStatus.LOCKED) {
            thread.setStatus(ThreadStatus.OPEN);
            threadRepository.save(thread);
        }

        String body = request.body() == null ? "" : request.body().trim();
        String mediaType = blankToNull(request.mediaType());
        String mediaUrl = blankToNull(request.mediaUrl());
        String mediaName = blankToNull(request.mediaName());
        String mediaMime = blankToNull(request.mediaMime());
        boolean hasMedia = mediaUrl != null;
        if (body.isBlank() && !hasMedia) {
            throw new BusinessException("EMPTY_MESSAGE", "Message cannot be empty.");
        }
        if (hasMedia) {
            String mt = mediaType == null ? "FILE" : mediaType.trim().toUpperCase();
            if (!List.of("IMAGE", "VIDEO", "AUDIO", "FILE").contains(mt)) {
                throw new BusinessException("MEDIA_TYPE", "Unsupported media type.");
            }
            mediaType = mt;
            storageService.assertOwnedChatMedia(userId, mediaUrl);
        }

        long prior = messageRepository.countByThreadIdAndModerationStatusNot(thread.getId(), ModerationStatus.BLOCKED);
        // Icebreaker requirement removed to allow free messaging from the start
        // if (prior < ICEBREAKER_FIRST_COUNT) {
        //     ...
        // }

        ModerationStatus status = ModerationStatus.ALLOWED;
        List<String> flags = new ArrayList<>();
        if (!body.isBlank()) {
            ContentModerator.Result result = moderator.evaluate(body);
            flags.addAll(result.flags());
            if (result.blocked()) {
                status = ModerationStatus.BLOCKED;
            } else if (result.held()) {
                status = ModerationStatus.HELD;
            }
        }

        MessageEntity saved = messageRepository.save(MessageEntity.builder()
                .threadId(thread.getId())
                .senderId(userId)
                .body(body)
                .mediaType(mediaType)
                .mediaUrl(mediaUrl)
                .mediaName(mediaName)
                .mediaMime(mediaMime)
                .moderationStatus(status)
                .moderationFlags(flags)
                .build());

        String action = switch (status) {
            case BLOCKED -> "PIPELINE_BLOCK";
            case HELD -> "PIPELINE_HOLD";
            default -> "PIPELINE_ALLOW";
        };
        moderationEvents.record(saved.getId(), userId, action, String.join(",", flags));

        if (status == ModerationStatus.BLOCKED) {
            throw new BusinessException(
                    "MESSAGE_BLOCKED",
                    "Message blocked by safety policy. Keep conversation respectful and venue-based."
            );
        }

        redis.delete(typingKey(matchId, userId));
        markReadInternal(thread, userId);

        if (status == ModerationStatus.ALLOWED) {
            try {
                UUID peer = thread.getMemberAId().equals(userId) ? thread.getMemberBId() : thread.getMemberAId();
                String senderName = userRepository.findById(userId)
                        .map(UserEntity::getDisplayName)
                        .filter(n -> n != null && !n.isBlank())
                        .orElse("Your match");
                String preview = hasMedia
                        ? (mediaType == null ? "Sent an attachment" : "Sent a " + mediaType.toLowerCase())
                        : (body.length() > 80 ? body.substring(0, 77) + "…" : body);
                memberNotifyService.notifyUser(
                        peer,
                        senderName,
                        preview,
                        "CHAT",
                        matchId.toString()
                );
            } catch (Exception ignored) {
                // Delivery failures must not fail the send.
            }
        }

        return toMessage(saved, thread);
    }

    private static String blankToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> heldQueue() {
        List<MessageEntity> held = messageRepository.findByModerationStatusOrderByCreatedAtAsc(ModerationStatus.HELD);
        Map<UUID, ChatThreadEntity> threads = threadRepository.findAllById(
                held.stream().map(MessageEntity::getThreadId).distinct().toList()
        ).stream().collect(Collectors.toMap(ChatThreadEntity::getId, t -> t));

        return held.stream().map(m -> {
            ChatThreadEntity thread = threads.get(m.getThreadId());
            java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
            row.put("id", m.getId().toString());
            row.put("threadId", m.getThreadId().toString());
            row.put("matchId", thread == null ? "" : thread.getConnectionId().toString());
            row.put("senderId", m.getSenderId().toString());
            row.put("body", m.getBody());
            row.put("flags", m.getModerationFlags());
            row.put("createdAt", m.getCreatedAt().toString());
            row.put("ageMinutes", java.time.Duration.between(m.getCreatedAt(), Instant.now()).toMinutes());
            return row;
        }).toList();
    }

    @Transactional
    public Map<String, Object> reviewHeld(UUID messageId, boolean approve) {
        MessageEntity message = messageRepository.findById(messageId)
                .orElseThrow(() -> new BusinessException("MESSAGE_NOT_FOUND", "Message not found."));
        if (message.getModerationStatus() != ModerationStatus.HELD) {
            throw new BusinessException("NOT_HELD", "Message is not awaiting review.");
        }
        message.setModerationStatus(approve ? ModerationStatus.ALLOWED : ModerationStatus.BLOCKED);
        messageRepository.save(message);
        moderationEvents.record(
                message.getId(),
                message.getSenderId(),
                approve ? "STAFF_APPROVE" : "STAFF_BLOCK",
                "held_review"
        );
        return Map.of(
                "id", message.getId().toString(),
                "moderationStatus", message.getModerationStatus().name()
        );
    }

    private InboxMeta buildInboxMeta(ChatThreadEntity thread, UUID viewerId) {
        MessageEntity last = messageRepository
                .findTop1ByThreadIdAndModerationStatusOrderByCreatedAtDesc(thread.getId(), ModerationStatus.ALLOWED)
                .orElse(null);
        Instant since = thread.getMemberAId().equals(viewerId) ? thread.getALastReadAt() : thread.getBLastReadAt();
        // Postgres cannot type a null Instant bind in comparisons — use epoch when never read.
        Instant unreadSince = since == null ? Instant.EPOCH : since;
        int unread = (int) messageRepository.countUnread(
                thread.getId(), viewerId, unreadSince, ModerationStatus.ALLOWED
        );
        if (last == null) {
            return new InboxMeta("Say hello — start with an icebreaker", null, false, unread, "YOUR_TURN");
        }
        boolean fromMe = last.getSenderId().equals(viewerId);
        String preview;
        if (last.getMediaUrl() != null && !last.getMediaUrl().isBlank()) {
            String mt = last.getMediaType() == null ? "attachment" : last.getMediaType().toLowerCase();
            preview = (fromMe ? "You: " : "") + mt;
        } else {
            String body = last.getBody() == null ? "" : last.getBody().trim();
            if (body.length() > 72) {
                body = body.substring(0, 69) + "…";
            }
            preview = fromMe ? "You: " + body : body;
        }
        String turn = fromMe ? "THEIR_TURN" : "YOUR_TURN";
        return new InboxMeta(preview, last.getCreatedAt(), fromMe, unread, turn);
    }

    private void markReadInternal(ChatThreadEntity thread, UUID userId) {
        Instant now = Instant.now();
        if (thread.getMemberAId().equals(userId)) {
            thread.setALastReadAt(now);
        } else {
            thread.setBLastReadAt(now);
        }
        threadRepository.save(thread);
    }

    private static Instant peerLastReadAt(ChatThreadEntity thread, UUID viewerId) {
        return thread.getMemberAId().equals(viewerId) ? thread.getBLastReadAt() : thread.getALastReadAt();
    }

    private static boolean visibleTo(UUID userId, MessageEntity m) {
        if (m.getModerationStatus() == ModerationStatus.ALLOWED) {
            return true;
        }
        return m.getModerationStatus() == ModerationStatus.HELD && m.getSenderId().equals(userId);
    }

    private ChatThreadEntity requireParticipantThread(UUID userId, UUID matchId) {
        ConnectionEntity match = assertParticipant(userId, matchId);
        return threadRepository.findByConnectionId(matchId)
                .orElseGet(() -> openForMatch(match));
    }

    private ConnectionEntity assertParticipant(UUID userId, UUID matchId) {
        ConnectionEntity match = connectionRepository.findById(matchId)
                .orElseThrow(() -> new BusinessException("MATCH_NOT_FOUND", "Match not found."));
        if (match.getStatus() != MatchStatus.MUTUAL) {
            throw new BusinessException("CHAT_LOCKED", "Chat unlocks after mutual acceptance.");
        }
        if (!match.getMemberAId().equals(userId) && !match.getMemberBId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not a participant.");
        }
        if (blockService.isBlockedEitherWay(match.getMemberAId(), match.getMemberBId())) {
            throw new BusinessException("CHAT_BLOCKED", "This conversation is unavailable due to a block.");
        }
        return match;
    }

    private ChatDtos.ThreadResponse toThread(ChatThreadEntity thread) {
        ChatWindowService.Window w = chatWindowService.windowForMatch(thread.getConnectionId());
        return new ChatDtos.ThreadResponse(
                thread.getId().toString(),
                thread.getConnectionId().toString(),
                thread.getStatus().name(),
                w.canSend(),
                w.opensAt(),
                w.closesAt(),
                w.reason()
        );
    }

    private ChatDtos.MessageResponse toMessage(MessageEntity m, ChatThreadEntity thread) {
        Instant peerRead = m.getSenderId().equals(thread.getMemberAId())
                ? thread.getBLastReadAt()
                : thread.getALastReadAt();
        boolean readByPeer = peerRead != null
                && m.getCreatedAt() != null
                && !peerRead.isBefore(m.getCreatedAt())
                && m.getModerationStatus() == ModerationStatus.ALLOWED;
        return new ChatDtos.MessageResponse(
                m.getId().toString(),
                m.getThreadId().toString(),
                m.getSenderId().toString(),
                m.getBody() == null ? "" : m.getBody(),
                m.getModerationStatus().name(),
                m.getCreatedAt(),
                m.getMediaType(),
                m.getMediaUrl(),
                m.getMediaName(),
                m.getMediaMime(),
                readByPeer
        );
    }

    private static String typingKey(UUID matchId, UUID userId) {
        return "velvet:chat:typing:" + matchId + ":" + userId;
    }


    public record InboxMeta(
            String lastMessagePreview,
            Instant lastMessageAt,
            boolean lastMessageFromMe,
            int unreadCount,
            String turn
    ) {
        public static InboxMeta empty() {
            return new InboxMeta(null, null, false, 0, "NONE");
        }
    }
}
