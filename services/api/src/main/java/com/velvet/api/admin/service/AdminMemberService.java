package com.velvet.api.admin.service;

import com.velvet.api.admin.web.dto.AdminDtos;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.audit.AuditService;
import com.velvet.api.identity.domain.MemberProfileEntity;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.domain.UserStatus;
import com.velvet.api.identity.repo.MemberProfileRepository;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.identity.web.dto.ProfileDtos;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Service
public class AdminMemberService {

    private final UserRepository userRepository;
    private final MemberProfileRepository profileRepository;
    private final AuditService auditService;

    public AdminMemberService(
            UserRepository userRepository,
            MemberProfileRepository profileRepository,
            AuditService auditService
    ) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.auditService = auditService;
    }

    @Transactional(readOnly = true)
    public List<AdminDtos.MemberSummary> listMembers() {
        return userRepository.findAll().stream()
                .map(this::toSummary)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<ProfileDtos.PhotoReviewResponse> photoReviewQueue() {
        return profileRepository.findByPhotoQualityStatusOrderByUpdatedAtAsc("NEEDS_REVIEW").stream()
                .map(this::toPhotoReview).toList();
    }

    @Transactional
    public ProfileDtos.PhotoReviewResponse reviewPhotos(UUID userId, ProfileDtos.ReviewPhotosRequest request) {
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("PROFILE_NOT_FOUND", "Profile not found."));
        profile.setPhotoQualityStatus(request.approve() ? "APPROVED" : "REJECTED");
        profile.setPhotoQualityNotes(request.notes() == null ? "" : request.notes().trim());
        if (!request.approve()) profile.setListingActive(false);
        profileRepository.save(profile);
        auditService.log(null, "PROFILE_PHOTO_REVIEW", "USER", userId.toString(), Map.of("approved", request.approve()));
        return toPhotoReview(profile);
    }

    @Transactional(readOnly = true)
    public List<AdminDtos.MemberSummary> search(String q, String status, String role) {
        String query = q == null ? "" : q.trim().toLowerCase(Locale.ROOT);
        return userRepository.findAll().stream()
                .filter(u -> {
                    if (status != null && !status.isBlank() && !u.getStatus().name().equalsIgnoreCase(status.trim())) {
                        return false;
                    }
                    if (role != null && !role.isBlank() && !u.getRole().name().equalsIgnoreCase(role.trim())) {
                        return false;
                    }
                    if (query.isEmpty()) {
                        return true;
                    }
                    String phone = u.getPhoneE164() == null ? "" : u.getPhoneE164().toLowerCase(Locale.ROOT);
                    String name = u.getDisplayName() == null ? "" : u.getDisplayName().toLowerCase(Locale.ROOT);
                    String id = u.getId().toString().toLowerCase(Locale.ROOT);
                    return phone.contains(query) || name.contains(query) || id.startsWith(query);
                })
                .map(this::toSummary)
                .limit(50)
                .toList();
    }

    @Transactional
    public AdminDtos.MemberSummary updateStatus(UUID userId, AdminDtos.UpdateMemberStatusRequest request) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        try {
            user.setStatus(UserStatus.valueOf(request.status().trim().toUpperCase()));
        } catch (IllegalArgumentException ex) {
            throw new BusinessException("INVALID_STATUS", "Unknown status.");
        }
        userRepository.save(user);
        auditService.log(null, "MEMBER_STATUS", "USER", userId.toString(), Map.of("status", user.getStatus().name()));
        return toSummary(user);
    }

    @Transactional
    public AdminDtos.MemberSummary promote(AdminDtos.PromoteRequest request) {
        UserEntity user = userRepository.findById(request.userId())
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        try {
            user.setRole(UserRole.valueOf(request.role().trim().toUpperCase()));
        } catch (IllegalArgumentException ex) {
            throw new BusinessException("INVALID_ROLE", "Unknown role.");
        }
        userRepository.save(user);
        auditService.log(null, "MEMBER_PROMOTE", "USER", user.getId().toString(), Map.of("role", user.getRole().name()));
        return toSummary(user);
    }

    @Transactional
    public AdminDtos.MemberSummary updateNotes(UUID actorId, UUID userId, String notes) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseGet(() -> MemberProfileEntity.builder().userId(userId).build());
        profile.setConciergeNotes(notes == null ? null : notes.trim());
        profileRepository.save(profile);
        auditService.log(actorId, "MEMBER_NOTES", "USER", userId.toString(), Map.of());
        return toSummary(user);
    }

    private AdminDtos.MemberSummary toSummary(UserEntity user) {
        MemberProfileEntity profile = profileRepository.findById(user.getId()).orElse(null);
        return new AdminDtos.MemberSummary(
                user.getId().toString(),
                user.getPhoneE164(),
                user.getDisplayName(),
                user.getStatus().name(),
                user.getRole().name(),
                profile == null ? null : profile.getCity(),
                profile == null ? null : profile.getConciergeNotes()
        );
    }

    private ProfileDtos.PhotoReviewResponse toPhotoReview(MemberProfileEntity profile) {
        UserEntity user = userRepository.findById(profile.getUserId()).orElseThrow();
        return new ProfileDtos.PhotoReviewResponse(profile.getUserId().toString(), user.getDisplayName(),
                profile.getPhotoUrls() == null ? List.of() : List.copyOf(profile.getPhotoUrls()),
                profile.getPhotoQualityStatus(), profile.getPhotoQualityNotes(), profile.getUpdatedAt());
    }
}
