package com.velvet.api.safety.service;

import com.velvet.api.chat.domain.ThreadStatus;
import com.velvet.api.chat.repo.ChatThreadRepository;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.domain.MatchStatus;
import com.velvet.api.matching.repo.ConnectionRepository;
import com.velvet.api.safety.domain.MemberBlockEntity;
import com.velvet.api.safety.repo.MemberBlockRepository;
import com.velvet.api.safety.web.dto.SafetyDtos;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
public class BlockService {

    private final MemberBlockRepository blockRepository;
    private final ConnectionRepository connectionRepository;
    private final ChatThreadRepository threadRepository;

    public BlockService(
            MemberBlockRepository blockRepository,
            ConnectionRepository connectionRepository,
            ChatThreadRepository threadRepository
    ) {
        this.blockRepository = blockRepository;
        this.connectionRepository = connectionRepository;
        this.threadRepository = threadRepository;
    }

    @Transactional(readOnly = true)
    public boolean isBlockedEitherWay(UUID a, UUID b) {
        return blockRepository.existsBetween(a, b);
    }

    @Transactional(readOnly = true)
    public List<SafetyDtos.BlockResponse> list(UUID blockerId) {
        return blockRepository.findByBlockerIdOrderByCreatedAtDesc(blockerId).stream()
                .map(this::toDto)
                .toList();
    }

    @Transactional
    public SafetyDtos.BlockResponse block(UUID blockerId, UUID blockedId, String reason) {
        if (blockerId.equals(blockedId)) {
            throw new BusinessException("BLOCK_SELF", "Cannot block yourself.");
        }
        MemberBlockEntity existing = blockRepository.findByBlockerIdAndBlockedId(blockerId, blockedId).orElse(null);
        if (existing != null) {
            return toDto(existing);
        }
        MemberBlockEntity saved = blockRepository.save(MemberBlockEntity.builder()
                .blockerId(blockerId)
                .blockedId(blockedId)
                .reason(reason == null || reason.isBlank() ? null : reason.trim())
                .build());

        List<ConnectionEntity> open = connectionRepository.findForUserWithStatuses(
                blockerId,
                List.of(MatchStatus.PROPOSED, MatchStatus.ACCEPTED_A, MatchStatus.ACCEPTED_B, MatchStatus.MUTUAL)
        );
        for (ConnectionEntity match : open) {
            if (!match.getMemberAId().equals(blockedId) && !match.getMemberBId().equals(blockedId)) {
                continue;
            }
            match.setStatus(MatchStatus.DECLINED);
            connectionRepository.save(match);
            threadRepository.findByConnectionId(match.getId()).ifPresent(t -> {
                t.setStatus(ThreadStatus.CLOSED);
                threadRepository.save(t);
            });
        }
        return toDto(saved);
    }

    @Transactional
    public void unblock(UUID blockerId, UUID blockedId) {
        blockRepository.findByBlockerIdAndBlockedId(blockerId, blockedId)
                .ifPresent(blockRepository::delete);
    }

    private SafetyDtos.BlockResponse toDto(MemberBlockEntity b) {
        return new SafetyDtos.BlockResponse(
                b.getId().toString(),
                b.getBlockedId().toString(),
                b.getReason(),
                b.getCreatedAt()
        );
    }
}
