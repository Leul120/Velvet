package com.velvet.api.identity.service;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.audit.AuditService;
import com.velvet.api.identity.domain.Gender;
import com.velvet.api.identity.domain.MemberProfileEntity;
import com.velvet.api.identity.domain.RefreshTokenEntity;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.domain.UserStatus;
import com.velvet.api.identity.repo.MemberProfileRepository;
import com.velvet.api.identity.repo.RefreshTokenRepository;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.identity.web.dto.ProfileDtos;
import com.velvet.api.storage.ObjectStorageService;
import com.velvet.api.notify.domain.DeviceTokenEntity;
import com.velvet.api.notify.repo.DeviceTokenRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.Period;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class ProfileService {

    private static final int MAX_PHOTOS = 3;

    private final UserRepository userRepository;
    private final MemberProfileRepository profileRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final DeviceTokenRepository deviceTokenRepository;
    private final AuditService auditService;
    private final LegalConsentService legalConsentService;
    private final com.velvet.api.booking.service.TrustService trustService;
    private final com.velvet.api.identity.repo.VaultAccessGrantRepository vaultAccessGrantRepository;
    private final ObjectStorageService storageService;


    public ProfileService(
            UserRepository userRepository,
            MemberProfileRepository profileRepository,
            RefreshTokenRepository refreshTokenRepository,
            DeviceTokenRepository deviceTokenRepository,
            AuditService auditService,
            LegalConsentService legalConsentService,
            com.velvet.api.booking.service.TrustService trustService,
            com.velvet.api.identity.repo.VaultAccessGrantRepository vaultAccessGrantRepository,
            ObjectStorageService storageService
    ) {
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.deviceTokenRepository = deviceTokenRepository;
        this.auditService = auditService;
        this.legalConsentService = legalConsentService;
        this.trustService = trustService;
        this.vaultAccessGrantRepository = vaultAccessGrantRepository;
        this.storageService = storageService;
    }


    @Transactional(readOnly = true)
    public ProfileDtos.MeResponse getMe(UUID userId) {
        UserEntity user = requireActiveAccount(userId);
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElse(MemberProfileEntity.builder().userId(userId).build());
        return toMe(user, profile);
    }

    @Transactional
    public ProfileDtos.MeResponse updateMe(UUID userId, ProfileDtos.UpdateMeRequest request) {
        UserEntity user = requireActiveAccount(userId);

        if (request.dateOfBirth() != null) {
            int age = Period.between(request.dateOfBirth(), LocalDate.now()).getYears();
            if (age < 21) {
                throw new BusinessException("AGE_RESTRICTED", "Members must be 21 or older.");
            }
            user.setDateOfBirth(request.dateOfBirth());
        }
        if (request.gender() != null && !request.gender().isBlank()) {
            try {
                Gender gender = Gender.valueOf(request.gender().trim().toUpperCase());
                user.setGender(gender);
                applyMarketplaceRole(user, gender);
            } catch (IllegalArgumentException ex) {
                throw new BusinessException("INVALID_GENDER", "Gender must be MALE or FEMALE.");
            }
        }
        if (request.displayName() != null) {
            user.setDisplayName(request.displayName().trim());
        }
        if (request.preferredLocale() != null) {
            user.setPreferredLocale(request.preferredLocale().trim());
        }
        userRepository.save(user);

        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseGet(() -> MemberProfileEntity.builder().userId(userId).build());

        if (request.bioEn() != null) {
            profile.setBioEn(request.bioEn());
        }
        if (request.bioAm() != null) {
            profile.setBioAm(request.bioAm());
        }
        if (request.city() != null) {
            profile.setCity(request.city().trim());
        }
        if (request.heightCm() != null) profile.setHeightCm(request.heightCm());
        if (request.jobTitle() != null) profile.setJobTitle(request.jobTitle().trim());
        if (request.education() != null) profile.setEducation(request.education().trim());
        if (request.languages() != null) profile.setLanguages(request.languages().trim());
        if (request.religion() != null) profile.setReligion(request.religion().trim());
        if (request.lookingFor() != null) profile.setLookingFor(request.lookingFor().trim());
        if (request.sessionRateEtb() != null) profile.setSessionRateEtb(request.sessionRateEtb());
        if (request.overnightRateEtb() != null) profile.setOvernightRateEtb(request.overnightRateEtb());
        if (request.availabilityNote() != null) profile.setAvailabilityNote(request.availabilityNote().trim());
        if (request.listingActive() != null) {
            if (Boolean.TRUE.equals(request.listingActive()) && !isListingEligible(user)) {
                throw new BusinessException(
                        "LISTING_REQUIRES_VERIFICATION",
                        "ID verification must be approved before your listing can go live."
                );
            }
            profile.setListingActive(request.listingActive());
        }
        if (request.interests() != null) {
            profile.setInterests(new ArrayList<>(request.interests()));
        }
        profileRepository.save(profile);

        return toMe(user, profile);
    }

    @Transactional
    public ProfileDtos.MeResponse addPhoto(UUID userId, ProfileDtos.AddPhotoRequest request) {
        String url = request == null ? null : request.url();
        if (url == null || url.isBlank()) {
            throw new BusinessException("URL_REQUIRED", "Photo URL is required.");
        }
        storageService.assertOwnedProfileImage(userId, url.trim());
        requireActiveAccount(userId);
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseGet(() -> MemberProfileEntity.builder().userId(userId).build());
        List<String> photos = profile.getPhotoUrls() == null ? new ArrayList<>() : new ArrayList<>(profile.getPhotoUrls());
        if (photos.size() >= MAX_PHOTOS) {
            throw new BusinessException("PHOTO_LIMIT", "Maximum of " + MAX_PHOTOS + " photos allowed.");
        }
        photos.add(url.trim());
        profile.setPhotoUrls(photos);
        // A new image invalidates the prior profile-wide review. Do not retain a
        // rejected state forever: the member must be able to replace bad photos
        // and have the replacement reviewed. Client-supplied quality fields are
        // deliberately ignored.
        profile.setPhotoQualityStatus(PhotoQualityService.Status.NEEDS_REVIEW.name());
        profile.setPhotoQualityNotes(null);
        profileRepository.save(profile);
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        return toMe(user, profile);
    }

    @Transactional
    public ProfileDtos.MeResponse removePhoto(UUID userId, String url) {
        requireActiveAccount(userId);
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("PROFILE_NOT_FOUND", "Profile not found."));
        List<String> photos = profile.getPhotoUrls() == null ? new ArrayList<>() : new ArrayList<>(profile.getPhotoUrls());
        photos.removeIf(u -> u.equals(url));
        profile.setPhotoUrls(photos);
        profileRepository.save(profile);
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        return toMe(user, profile);
    }

    @Transactional
    public ProfileDtos.MeResponse reorderPhotos(UUID userId, ProfileDtos.ReorderPhotosRequest request) {
        requireActiveAccount(userId);
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("PROFILE_NOT_FOUND", "Profile not found."));
        List<String> current = profile.getPhotoUrls() == null ? List.of() : List.copyOf(profile.getPhotoUrls());
        List<String> next = request.photoUrls().stream()
                .filter(u -> u != null && !u.isBlank())
                .map(String::trim)
                .distinct()
                .toList();
        if (next.size() != current.size() || !next.containsAll(current) || !current.containsAll(next)) {
            throw new BusinessException("PHOTO_ORDER_MISMATCH", "Reorder must include exactly your current photos.");
        }
        profile.setPhotoUrls(new ArrayList<>(next));
        profileRepository.save(profile);
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        return toMe(user, profile);
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
        return toPhotoReview(profileRepository.save(profile));
    }

    @Transactional
    public void withdraw(UUID userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getStatus() == UserStatus.WITHDRAWN) {
            return;
        }
        if (user.getStatus() == UserStatus.BANNED) {
            throw new BusinessException("ACCOUNT_BLOCKED", "Banned accounts cannot self-withdraw.");
        }
        user.setStatus(UserStatus.WITHDRAWN);
        userRepository.save(user);

        List<RefreshTokenEntity> tokens = refreshTokenRepository.findByUserIdAndRevokedFalse(userId);
        tokens.forEach(t -> t.setRevoked(true));
        refreshTokenRepository.saveAll(tokens);

        List<DeviceTokenEntity> devices = deviceTokenRepository.findByUserId(userId);
        devices.forEach(d -> d.setActive(false));
        deviceTokenRepository.saveAll(devices);

        auditService.log(userId, "ACCOUNT_WITHDRAW", "USER", userId.toString(), Map.of());
    }

    @Transactional(readOnly = true)
    public Map<String, Object> exportData(UUID userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElse(MemberProfileEntity.builder().userId(userId).build());
        long refreshTokenCount = refreshTokenRepository.findByUserIdAndRevokedFalse(userId).size();
        long deviceCount = deviceTokenRepository.findByUserId(userId).size();

        return Map.of(
                "user", Map.of(
                        "id", user.getId().toString(),
                        "phone", user.getPhoneE164(),
                        "email", user.getEmail() == null ? "" : user.getEmail(),
                        "displayName", user.getDisplayName() == null ? "" : user.getDisplayName(),
                        "status", user.getStatus().name(),
                        "role", user.getRole().name(),
                        "preferredLocale", user.getPreferredLocale(),
                        "dateOfBirth", user.getDateOfBirth() == null ? "" : user.getDateOfBirth().toString(),
                        "createdAt", user.getCreatedAt() == null ? "" : user.getCreatedAt().toString()
                ),
                "profile", Map.of(
                        "bioEn", profile.getBioEn() == null ? "" : profile.getBioEn(),
                        "bioAm", profile.getBioAm() == null ? "" : profile.getBioAm(),
                        "city", profile.getCity() == null ? "" : profile.getCity(),
                        "interests", profile.getInterests() == null ? List.of() : profile.getInterests(),
                        "photoUrls", profile.getPhotoUrls() == null ? List.of() : profile.getPhotoUrls()
                ),
                "summaries", Map.of(
                        "activeRefreshTokenCount", refreshTokenCount,
                        "deviceCount", deviceCount
                )
        );
    }

    @Transactional
    public void erasure(UUID userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getStatus() == UserStatus.BANNED) {
            throw new BusinessException("ACCOUNT_BLOCKED", "Banned accounts cannot self-erase.");
        }

        List<RefreshTokenEntity> tokens = refreshTokenRepository.findByUserIdAndRevokedFalse(userId);
        tokens.forEach(token -> token.setRevoked(true));
        refreshTokenRepository.saveAll(tokens);
        List<DeviceTokenEntity> devices = deviceTokenRepository.findByUserId(userId);
        devices.forEach(device -> device.setActive(false));
        deviceTokenRepository.saveAll(devices);

        String anonymizedPhone = "+000" + userId.toString().replace("-", "").substring(0, 8);
        userRepository.findByPhoneE164(anonymizedPhone)
                .filter(existing -> !existing.getId().equals(userId))
                .ifPresent(existing -> {
                    throw new BusinessException("ERASURE_PHONE_COLLISION", "Unable to allocate an anonymized phone number.");
                });
        user.setStatus(UserStatus.WITHDRAWN);
        user.setPhoneE164(anonymizedPhone);
        user.setDisplayName("Withdrawn member");
        user.setEmail(null);
        user.setPreferredLocale("en");
        userRepository.save(user);

        profileRepository.findById(userId).ifPresent(profile -> {
            List<String> photos = profile.getPhotoUrls() == null ? List.of() : List.copyOf(profile.getPhotoUrls());
            photos.forEach(url -> storageService.deleteOwnedProfileImage(userId, url));
            profile.setBioEn(null);
            profile.setBioAm(null);
            profile.setCity("");
            profile.setInterests(new ArrayList<>());
            profile.setPhotoUrls(new ArrayList<>());
            profileRepository.save(profile);
        });

        auditService.log(userId, "ACCOUNT_ERASURE", "USER", userId.toString(), Map.of());
    }

    private UserEntity requireActiveAccount(UUID userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getStatus() == UserStatus.WITHDRAWN
                || user.getStatus() == UserStatus.BANNED
                || user.getStatus() == UserStatus.SUSPENDED) {
            throw new BusinessException("ACCOUNT_BLOCKED", "This account cannot continue.");
        }
        return user;
    }

    /** Staff and venue roles are never overwritten by marketplace onboarding. */
    private void applyMarketplaceRole(UserEntity user, Gender gender) {
        UserRole role = user.getRole();
        if (role == UserRole.ADMIN || role == UserRole.CONCIERGE || role == UserRole.VENUE_PARTNER || role == UserRole.SUBSCRIBER) {
            return;
        }
        user.setRole(gender == Gender.FEMALE ? UserRole.PERFORMER : UserRole.CLIENT);
    }

    /** Performer listings require approved identity verification (status VERIFIED). */
    private static boolean isListingEligible(UserEntity user) {
        return user.getStatus() == UserStatus.VERIFIED;
    }

    private ProfileDtos.PhotoReviewResponse toPhotoReview(MemberProfileEntity profile) {
        UserEntity user = userRepository.findById(profile.getUserId()).orElseThrow();
        return new ProfileDtos.PhotoReviewResponse(profile.getUserId().toString(), user.getDisplayName(),
                profile.getPhotoUrls() == null ? List.of() : List.copyOf(profile.getPhotoUrls()),
                profile.getPhotoQualityStatus(), profile.getPhotoQualityNotes(), profile.getUpdatedAt());
    }

    @Transactional(readOnly = true)
    public boolean hasVaultAccess(UUID performerId, UUID memberId) {
        if (performerId == null || memberId == null) return false;
        if (performerId.equals(memberId)) return true;

        UserEntity viewer = userRepository.findById(memberId).orElse(null);
        if (viewer != null && (viewer.getRole() == UserRole.ADMIN || viewer.getRole() == UserRole.CONCIERGE || viewer.getRole() == UserRole.SUBSCRIBER)) {
            return true;
        }

        return vaultAccessGrantRepository.existsByPerformerIdAndMemberId(performerId, memberId);
    }

    @Transactional
    public void grantVaultAccess(UUID performerId, UUID memberId, String reason) {
        if (performerId.equals(memberId)) return;
        if (!vaultAccessGrantRepository.existsByPerformerIdAndMemberId(performerId, memberId)) {
            com.velvet.api.identity.domain.VaultAccessGrantEntity grant = com.velvet.api.identity.domain.VaultAccessGrantEntity.builder()
                    .performerId(performerId)
                    .memberId(memberId)
                    .grantedBy(performerId)
                    .reason(reason == null ? "Direct performer grant" : reason)
                    .build();
            vaultAccessGrantRepository.save(grant);
        }
    }

    @Transactional
    public ProfileDtos.MeResponse addPrivatePhoto(UUID userId, ProfileDtos.AddPhotoRequest request) {
        String url = request == null ? null : request.url();
        if (url == null || url.isBlank()) {
            throw new BusinessException("URL_REQUIRED", "Photo URL is required.");
        }
        UserEntity user = requireActiveAccount(userId);
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseGet(() -> MemberProfileEntity.builder().userId(userId).build());

        List<String> privates = new ArrayList<>(profile.getPrivatePhotoUrls() == null ? List.of() : profile.getPrivatePhotoUrls());
        if (!privates.contains(url)) {
            privates.add(url);
            profile.setPrivatePhotoUrls(privates);
            profileRepository.save(profile);
        }
        return toMe(user, profile, userId);
    }

    @Transactional
    public ProfileDtos.MeResponse toggleAvailableTonight(UUID userId, ProfileDtos.ToggleAvailableTonightRequest request) {
        UserEntity user = requireActiveAccount(userId);
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseGet(() -> MemberProfileEntity.builder().userId(userId).build());

        profile.setAvailableTonight(request.availableTonight());
        if (request.availableNeighborhood() != null) {
            profile.setAvailableNeighborhood(request.availableNeighborhood().trim());
        }
        profileRepository.save(profile);
        return toMe(user, profile, userId);
    }

    @Transactional
    public ProfileDtos.MeResponse setVoiceIntro(UUID userId, ProfileDtos.UploadVoiceIntroRequest request) {
        UserEntity user = requireActiveAccount(userId);
        MemberProfileEntity profile = profileRepository.findById(userId)
                .orElseGet(() -> MemberProfileEntity.builder().userId(userId).build());

        profile.setVoiceIntroUrl(request.voiceIntroUrl().trim());
        profileRepository.save(profile);
        return toMe(user, profile, userId);
    }

    private ProfileDtos.MeResponse toMe(UserEntity user, MemberProfileEntity profile) {
        return toMe(user, profile, user.getId());
    }

    public ProfileDtos.MeResponse toMe(UserEntity user, MemberProfileEntity profile, UUID viewingUserId) {
        boolean canSeeVault = hasVaultAccess(profile.getUserId(), viewingUserId);
        List<String> privates = (canSeeVault && profile.getPrivatePhotoUrls() != null) ? profile.getPrivatePhotoUrls() : List.of();

        return new ProfileDtos.MeResponse(
                user.getId().toString(),
                user.getPhoneE164(),
                user.getEmail(),
                user.getDisplayName(),
                user.getStatus().name(),
                user.getRole().name(),
                user.getPreferredLocale(),
                user.getDateOfBirth(),
                user.getGender() == null ? null : user.getGender().name(),
                legalConsentService.hasAcceptedCurrent(user),
                legalConsentService.currentVersion(),
                new ProfileDtos.ProfileBody(
                        profile.getBioEn(),
                        profile.getBioAm(),
                        profile.getCity(),
                        profile.getHeightCm(), profile.getJobTitle(), profile.getEducation(), profile.getLanguages(), profile.getReligion(), profile.getLookingFor(),
                        profile.getSessionRateEtb(),
                        profile.getOvernightRateEtb(),
                        profile.getAvailabilityNote(),
                        profile.isAvailableTonight(),
                        profile.getAvailableNeighborhood(),
                        profile.getVoiceIntroUrl(),
                        profile.isListingActive(),
                        profile.getInterests() == null ? java.util.List.of() : profile.getInterests(),
                        profile.getPhotoUrls() == null ? java.util.List.of() : profile.getPhotoUrls(),
                        privates,
                        canSeeVault,
                        profile.getPhotoQualityStatus() == null ? "APPROVED" : profile.getPhotoQualityStatus()
                ),
                trustService.getTrustScore(user.getId())
        );
    }


}
