package com.velvet.api.chat.repo;

import com.velvet.api.chat.domain.ChatThreadEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ChatThreadRepository extends JpaRepository<ChatThreadEntity, UUID> {
    Optional<ChatThreadEntity> findByConnectionId(UUID matchId);
}
