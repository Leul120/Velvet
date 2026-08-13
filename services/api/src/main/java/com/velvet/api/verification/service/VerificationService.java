package com.velvet.api.verification.service;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.identity.domain.Gender;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.domain.UserStatus;
import com.velvet.api.identity.repo.MemberProfileRepository;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.verification.domain.VerificationCaseEntity;
import com.velvet.api.verification.domain.VerificationStatus;
import com.velvet.api.verification.repo.VerificationCaseRepository;
import com.velvet.api.verification.web.dto.VerificationDtos;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class VerificationService {

    private final VerificationCaseRepository caseRepository;
    private final UserRepository userRepository;
    private final MemberProfileRepository profileRepository;

    public VerificationService(
            VerificationCaseRepository caseRepository,
            UserRepository userRepository,
            MemberProfileRepository profileRepository
    ) {
        this.caseRepository = caseRepository;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
    }

    @Transactional
    public VerificationDtos.VerificationResponse submit(UUID userId, VerificationDtos.SubmitRequest request) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getStatus() == UserStatus.BANNED || user.getStatus() == UserStatus.SUSPENDED) {
            throw new BusinessException("ACCOUNT_BLOCKED", "Account cannot submit verification.");
        }

        caseRepository.findFirstByUserIdOrderByCreatedAtDesc(userId).ifPresent(existing -> {
            if (existing.getStatus() == VerificationStatus.SUBMITTED
                    || existing.getStatus() == VerificationStatus.IN_REVIEW) {
                throw new BusinessException("VERIFICATION_PENDING", "A verification case is already pending.");
            }
            if (existing.getStatus() == VerificationStatus.APPROVED
                    && (user.getStatus() == UserStatus.VERIFIED || user.getStatus() == UserStatus.ACTIVE)) {
                throw new BusinessException("ALREADY_VERIFIED", "Member is already verified.");
            }
        });

        VerificationCaseEntity created = caseRepository.save(VerificationCaseEntity.builder()
                .userId(userId)
                .status(VerificationStatus.SUBMITTED)
                .idDocumentUrl(request.idDocumentUrl().trim())
                .selfieUrl(request.selfieUrl().trim())
                .notes(request.notes())
                .build());

        user.setStatus(UserStatus.UNDER_REVIEW);
        userRepository.save(user);

        return toResponse(created);
    }

    @Transactional(readOnly = true)
    public VerificationDtos.VerificationResponse myLatest(UUID userId) {
        return caseRepository.findFirstByUserIdOrderByCreatedAtDesc(userId)
                .map(this::toResponse)
                .orElseThrow(() -> new BusinessException("VERIFICATION_NOT_FOUND", "No verification case yet."));
    }

    @Transactional(readOnly = true)
    public List<VerificationDtos.VerificationResponse> queue() {
        return caseRepository.findByStatusInOrderByCreatedAtAsc(
                        List.of(VerificationStatus.SUBMITTED, VerificationStatus.IN_REVIEW)
                ).stream()
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public VerificationDtos.VerificationResponse review(
            UUID caseId,
            UUID reviewerId,
            VerificationDtos.ReviewRequest request
    ) {
        VerificationCaseEntity vCase = caseRepository.findById(caseId)
                .orElseThrow(() -> new BusinessException("VERIFICATION_NOT_FOUND", "Case not found."));
        if (vCase.getStatus() != VerificationStatus.SUBMITTED && vCase.getStatus() != VerificationStatus.IN_REVIEW) {
            throw new BusinessException("VERIFICATION_CLOSED", "Case is already closed.");
        }

        UserEntity user = userRepository.findById(vCase.getUserId())
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));

        vCase.setReviewerId(reviewerId);
        vCase.setReviewedAt(Instant.now());
        if (request.notes() != null) {
            vCase.setNotes(request.notes());
        }

        if (request.approve()) {
            vCase.setStatus(VerificationStatus.APPROVED);
            user.setStatus(UserStatus.VERIFIED);
        } else {
            vCase.setStatus(VerificationStatus.REJECTED);
            user.setStatus(UserStatus.APPLIED);
            deactivatePerformerListing(user);
        }
        caseRepository.save(vCase);
        userRepository.save(user);
        return toResponse(vCase);
    }

    private void deactivatePerformerListing(UserEntity user) {
        if (user.getRole() != UserRole.PERFORMER) {
            return;
        }
        profileRepository.findById(user.getId()).ifPresent(profile -> {
            if (profile.isListingActive()) {
                profile.setListingActive(false);
                profileRepository.save(profile);
            }
        });
    }

    private VerificationDtos.VerificationResponse toResponse(VerificationCaseEntity entity) {
        return new VerificationDtos.VerificationResponse(
                entity.getId().toString(),
                entity.getUserId().toString(),
                entity.getStatus().name(),
                entity.getIdDocumentUrl(),
                entity.getSelfieUrl(),
                entity.getNotes(),
                entity.getCreatedAt(),
                entity.getReviewedAt()
        );
    }
}
