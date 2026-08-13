package com.velvet.api.chat.repo;

import com.velvet.api.chat.domain.MessageEntity;
import com.velvet.api.chat.domain.ModerationStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface MessageRepository extends JpaRepository<MessageEntity, UUID> {
    List<MessageEntity> findByThreadIdAndModerationStatusNotOrderByCreatedAtAsc(
            UUID threadId,
            ModerationStatus blocked
    );

    long countByThreadIdAndModerationStatusNot(UUID threadId, ModerationStatus blocked);

    List<MessageEntity> findByModerationStatusOrderByCreatedAtAsc(ModerationStatus status);

    void deleteByThreadId(UUID threadId);

    List<MessageEntity> findByThreadId(UUID threadId);

    Optional<MessageEntity> findTop1ByThreadIdAndModerationStatusOrderByCreatedAtDesc(
            UUID threadId,
            ModerationStatus status
    );

    @Query("""
            select count(m) from MessageEntity m
            where m.threadId = :threadId
              and m.moderationStatus = :allowed
              and m.senderId <> :viewerId
              and m.createdAt > :since
            """)
    long countUnread(
            @Param("threadId") UUID threadId,
            @Param("viewerId") UUID viewerId,
            @Param("since") Instant since,
            @Param("allowed") ModerationStatus allowed
    );

    @Query("""
            select m from MessageEntity m
            where m.threadId = :threadId
              and m.moderationStatus <> :blocked
              and m.createdAt > :after
            order by m.createdAt asc
            """)
    List<MessageEntity> findAfter(
            @Param("threadId") UUID threadId,
            @Param("blocked") ModerationStatus blocked,
            @Param("after") Instant after
    );

    @Query("""
            select m from MessageEntity m
            where m.mediaUrl = :relativeUrl or m.mediaUrl like concat('%', :storageKey)
            order by m.createdAt desc
            """)
    List<MessageEntity> findForMediaKey(
            @Param("relativeUrl") String relativeUrl,
            @Param("storageKey") String storageKey
    );
}
