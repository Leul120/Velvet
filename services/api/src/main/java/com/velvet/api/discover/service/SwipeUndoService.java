package com.velvet.api.discover.service;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.discover.domain.MemberLikeEntity;
import com.velvet.api.discover.repo.MemberLikeRepository;
import com.velvet.api.discover.web.dto.DiscoverDtos;
import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.domain.MatchStatus;
import com.velvet.api.matching.repo.ConnectionRepository;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Tinder/Bumble-style undo for the last discover swipe (quota-limited).
 * Mutual matches cannot be undone.
 */
@Service
public class SwipeUndoService {

    private static final int MAX_UNDOS_PER_DAY = 5;
    private static final Duration LAST_SWIPE_TTL = Duration.ofHours(2);

    private final StringRedisTemplate redis;
    private final MemberLikeRepository likeRepository;
    private final ConnectionRepository connectionRepository;

    public SwipeUndoService(
            StringRedisTemplate redis,
            MemberLikeRepository likeRepository,
            ConnectionRepository connectionRepository
    ) {
        this.redis = redis;
        this.likeRepository = likeRepository;
        this.connectionRepository = connectionRepository;
    }

    public void remember(UUID fromUserId, UUID toUserId, String action) {
        String value = toUserId + "|" + action + "|" + Instant.now().toEpochMilli();
        redis.opsForValue().set(lastKey(fromUserId), value, LAST_SWIPE_TTL);
    }

    @Transactional
    public DiscoverDtos.UndoResponse undo(UUID userId) {
        long used = undoCount(userId);
        if (used >= MAX_UNDOS_PER_DAY) {
            throw new BusinessException("UNDO_LIMIT", "Daily undo limit reached. Try again tomorrow.");
        }

        String raw = redis.opsForValue().get(lastKey(userId));
        if (raw == null || raw.isBlank()) {
            throw new BusinessException("NOTHING_TO_UNDO", "Nothing to undo right now.");
        }
        String[] parts = raw.split("\\|");
        if (parts.length < 2) {
            redis.delete(lastKey(userId));
            throw new BusinessException("NOTHING_TO_UNDO", "Nothing to undo right now.");
        }
        UUID toUserId = UUID.fromString(parts[0]);
        String action = parts[1];

        // Block undo if a mutual match already exists between the pair.
        boolean mutual = connectionRepository.findForUserWithStatuses(userId, List.of(MatchStatus.MUTUAL)).stream()
                .anyMatch(m -> involves(m, userId, toUserId));
        if (mutual) {
            redis.delete(lastKey(userId));
            throw new BusinessException("UNDO_LOCKED", "Can't undo after a mutual match.");
        }

        MemberLikeEntity like = likeRepository.findByFromUserIdAndToUserId(userId, toUserId)
                .orElseThrow(() -> new BusinessException("NOTHING_TO_UNDO", "Nothing to undo right now."));
        likeRepository.delete(like);
        redis.delete(lastKey(userId));
        incrementUndoCount(userId);

        long remaining = Math.max(0, MAX_UNDOS_PER_DAY - undoCount(userId));
        return new DiscoverDtos.UndoResponse(toUserId.toString(), action, remaining);
    }

    public long remainingUndos(UUID userId) {
        return Math.max(0, MAX_UNDOS_PER_DAY - undoCount(userId));
    }

    private long undoCount(UUID userId) {
        String v = redis.opsForValue().get(countKey(userId));
        if (v == null || v.isBlank()) {
            return 0;
        }
        try {
            return Long.parseLong(v);
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    private void incrementUndoCount(UUID userId) {
        String key = countKey(userId);
        Long n = redis.opsForValue().increment(key);
        if (n != null && n == 1L) {
            long seconds = LocalDate.now(ZoneOffset.UTC).plusDays(1)
                    .atStartOfDay()
                    .toEpochSecond(ZoneOffset.UTC) - Instant.now().getEpochSecond();
            redis.expire(key, Math.max(60, seconds), TimeUnit.SECONDS);
        }
    }

    private static boolean involves(ConnectionEntity m, UUID a, UUID b) {
        return (m.getMemberAId().equals(a) && m.getMemberBId().equals(b))
                || (m.getMemberAId().equals(b) && m.getMemberBId().equals(a));
    }

    private static String lastKey(UUID userId) {
        return "velvet:swipe:last:" + userId;
    }

    private static String countKey(UUID userId) {
        return "velvet:swipe:undo:" + userId + ":" + LocalDate.now(ZoneOffset.UTC);
    }
}
