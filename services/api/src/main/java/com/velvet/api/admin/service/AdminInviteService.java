package com.velvet.api.admin.service;

import com.velvet.api.admin.web.dto.AdminDtos;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.identity.domain.InviteEntity;
import com.velvet.api.identity.repo.InviteRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class AdminInviteService {

    private static final String ALPHABET = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private final InviteRepository inviteRepository;
    private final SecureRandom random = new SecureRandom();

    public AdminInviteService(InviteRepository inviteRepository) {
        this.inviteRepository = inviteRepository;
    }

    @Transactional(readOnly = true)
    public List<AdminDtos.InviteResponse> list() {
        return inviteRepository.findAllByOrderByCreatedAtDesc().stream()
                .map(this::toDto)
                .toList();
    }

    @Transactional
    public AdminDtos.InviteResponse create(UUID issuerId, AdminDtos.CreateInviteRequest request) {
        String code = request.code() == null || request.code().isBlank()
                ? "VELVET-" + randomCode(6)
                : request.code().trim().toUpperCase(Locale.ROOT);
        if (inviteRepository.findByCodeIgnoreCase(code).isPresent()) {
            throw new BusinessException("INVITE_EXISTS", "Invite code already exists.");
        }
        int maxUses = request.maxUses() == null || request.maxUses() < 1 ? 1 : request.maxUses();
        Instant expires = null;
        if (request.expiresInDays() != null && request.expiresInDays() > 0) {
            expires = Instant.now().plus(request.expiresInDays(), ChronoUnit.DAYS);
        }
        InviteEntity saved = inviteRepository.save(InviteEntity.builder()
                .code(code)
                .issuerUserId(issuerId)
                .maxUses(maxUses)
                .expiresAt(expires)
                .active(true)
                .build());
        return toDto(saved);
    }

    @Transactional
    public AdminDtos.InviteResponse deactivate(UUID inviteId) {
        InviteEntity invite = inviteRepository.findById(inviteId)
                .orElseThrow(() -> new BusinessException("INVITE_NOT_FOUND", "Invite not found."));
        invite.setActive(false);
        return toDto(inviteRepository.save(invite));
    }

    private AdminDtos.InviteResponse toDto(InviteEntity i) {
        return new AdminDtos.InviteResponse(
                i.getId().toString(),
                i.getCode(),
                i.getMaxUses(),
                i.getUseCount(),
                i.isActive(),
                i.isUsable(),
                i.getExpiresAt(),
                i.getCreatedAt()
        );
    }

    private String randomCode(int len) {
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) {
            sb.append(ALPHABET.charAt(random.nextInt(ALPHABET.length())));
        }
        return sb.toString();
    }
}
