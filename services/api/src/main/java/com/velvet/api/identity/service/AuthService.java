package com.velvet.api.identity.service;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import com.velvet.api.common.ratelimit.RateLimitService;
import com.velvet.api.identity.domain.*;
import com.velvet.api.identity.otp.OtpService;
import com.velvet.api.identity.repo.InviteRepository;
import com.velvet.api.identity.repo.MemberProfileRepository;
import com.velvet.api.identity.repo.RefreshTokenRepository;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.identity.security.JwtService;
import com.velvet.api.identity.web.dto.AuthDtos;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.Duration;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HexFormat;
import java.util.Optional;

@Service
public class AuthService {

    private static final String PENDING_INVITE_PREFIX = "auth:pending-invite:";

    private final OtpService otpService;
    private final UserRepository userRepository;
    private final InviteRepository inviteRepository;
    private final MemberProfileRepository profileRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final JwtService jwtService;
    private final VelvetProperties properties;
    private final StringRedisTemplate redis;
    private final RateLimitService rateLimitService;
    private final LegalConsentService legalConsentService;
    private final SecureRandom secureRandom = new SecureRandom();

    public AuthService(
            OtpService otpService,
            UserRepository userRepository,
            InviteRepository inviteRepository,
            MemberProfileRepository profileRepository,
            RefreshTokenRepository refreshTokenRepository,
            JwtService jwtService,
            VelvetProperties properties,
            StringRedisTemplate redis,
            RateLimitService rateLimitService,
            LegalConsentService legalConsentService
    ) {
        this.otpService = otpService;
        this.userRepository = userRepository;
        this.inviteRepository = inviteRepository;
        this.profileRepository = profileRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.jwtService = jwtService;
        this.properties = properties;
        this.redis = redis;
        this.rateLimitService = rateLimitService;
        this.legalConsentService = legalConsentService;
    }

    @Transactional(readOnly = true)
    public AuthDtos.OtpRequestResponse requestOtp(AuthDtos.OtpRequest request) {
        String phone = request.phone().trim();
        rateLimitService.checkOtp(phone);
        Optional<UserEntity> existing = userRepository.findByPhoneE164(phone);

        if (existing.isPresent()) {
            UserEntity user = existing.get();
            if (user.getStatus() == UserStatus.BANNED
                    || user.getStatus() == UserStatus.SUSPENDED
                    || user.getStatus() == UserStatus.WITHDRAWN) {
                throw new BusinessException("ACCOUNT_BLOCKED", "This account cannot sign in.");
            }
            redis.delete(PENDING_INVITE_PREFIX + phone);
        } else {
            if (request.inviteCode() == null || request.inviteCode().isBlank()) {
                throw new BusinessException("INVITE_REQUIRED", "Invite code is required for new members.");
            }
            InviteEntity invite = inviteRepository.findByCodeIgnoreCase(request.inviteCode().trim())
                    .orElseThrow(() -> new BusinessException("INVITE_INVALID", "Invalid invite code."));
            if (!invite.isUsable()) {
                throw new BusinessException("INVITE_EXHAUSTED", "Invite code is no longer valid.");
            }
            redis.opsForValue().set(
                    PENDING_INVITE_PREFIX + phone,
                    invite.getCode(),
                    Duration.ofSeconds(properties.otp().ttlSeconds())
            );
        }

        String otp = otpService.issue(phone);
        String devOtp = properties.otp().exposeInResponse() ? otp : null;
        return new AuthDtos.OtpRequestResponse("OTP sent", properties.otp().ttlSeconds(), devOtp);
    }

    @Transactional
    public AuthDtos.TokenResponse verifyOtp(AuthDtos.OtpVerifyRequest request) {
        String phone = request.phone().trim();
        otpService.verify(phone, request.code().trim());

        UserEntity user = userRepository.findByPhoneE164(phone).orElse(null);
        if (user == null) {
            legalConsentService.requireAcceptedVersionOrThrow(request.acceptedLegalVersion());
            String inviteCode = redis.opsForValue().get(PENDING_INVITE_PREFIX + phone);
            if (inviteCode == null || inviteCode.isBlank()) {
                throw new BusinessException(
                        "INVITE_REQUIRED",
                        "Request OTP with a valid invite code before verifying."
                );
            }
            user = registerNewMember(phone, inviteCode);
            redis.delete(PENDING_INVITE_PREFIX + phone);
            legalConsentService.acceptCurrent(user.getId(), request.acceptedLegalVersion(), "REGISTRATION");
            user = userRepository.findById(user.getId()).orElse(user);
        } else if (user.getStatus() == UserStatus.BANNED
                || user.getStatus() == UserStatus.SUSPENDED
                || user.getStatus() == UserStatus.WITHDRAWN) {
            throw new BusinessException("ACCOUNT_BLOCKED", "This account cannot sign in.");
        } else if (!legalConsentService.hasAcceptedCurrent(user)
                && request.acceptedLegalVersion() != null
                && !request.acceptedLegalVersion().isBlank()) {
            legalConsentService.acceptCurrent(user.getId(), request.acceptedLegalVersion(), "LOGIN");
            user = userRepository.findById(user.getId()).orElse(user);
        }

        maybePromoteBootstrapAdmin(user);
        return issueTokens(user, request.deviceId());
    }

    @Transactional
    public AuthDtos.TokenResponse refresh(AuthDtos.RefreshRequest request) {
        String hash = sha256(request.refreshToken());
        RefreshTokenEntity stored = refreshTokenRepository.findByTokenHashAndRevokedFalse(hash)
                .orElseThrow(() -> new BusinessException("REFRESH_INVALID", "Invalid refresh token."));
        if (stored.getExpiresAt().isBefore(Instant.now())) {
            throw new BusinessException("REFRESH_EXPIRED", "Refresh token expired.");
        }
        stored.setRevoked(true);
        refreshTokenRepository.save(stored);

        UserEntity user = userRepository.findById(stored.getUserId())
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getStatus() == UserStatus.BANNED
                || user.getStatus() == UserStatus.SUSPENDED
                || user.getStatus() == UserStatus.WITHDRAWN) {
            throw new BusinessException("ACCOUNT_BLOCKED", "This account cannot sign in.");
        }
        maybePromoteBootstrapAdmin(user);
        return issueTokens(user, stored.getDeviceId());
    }

    private void maybePromoteBootstrapAdmin(UserEntity user) {
        String bootstrap = properties.admin() != null ? properties.admin().bootstrapPhone() : null;
        if (bootstrap != null && !bootstrap.isBlank() && bootstrap.equals(user.getPhoneE164())) {
            if (user.getRole() != UserRole.ADMIN) {
                user.setRole(UserRole.ADMIN);
                if (user.getStatus() == UserStatus.APPLIED || user.getStatus() == UserStatus.UNDER_REVIEW) {
                    user.setStatus(UserStatus.ACTIVE);
                }
                userRepository.save(user);
            }
        }
    }
    private UserEntity registerNewMember(String phone, String inviteCode) {
        InviteEntity invite = inviteRepository.findByCodeIgnoreCase(inviteCode)
                .orElseThrow(() -> new BusinessException("INVITE_INVALID", "Invalid invite code."));
        if (!invite.isUsable()) {
            throw new BusinessException("INVITE_EXHAUSTED", "Invite code is no longer valid.");
        }
        invite.setUseCount(invite.getUseCount() + 1);
        inviteRepository.save(invite);

        UserEntity user = UserEntity.builder()
                .phoneE164(phone)
                .status(UserStatus.APPLIED)
                .role(UserRole.MEMBER)
                .preferredLocale("am")
                .inviteId(invite.getId())
                .build();
        user = userRepository.save(user);

        profileRepository.save(MemberProfileEntity.builder()
                .userId(user.getId())
                .city("Addis Ababa")
                .build());

        return user;
    }

    private AuthDtos.TokenResponse issueTokens(UserEntity user, String deviceId) {
        String access = jwtService.createAccessToken(user.getId(), user.getRole().name());
        String refreshRaw = randomToken();
        Instant refreshExp = Instant.now().plus(properties.jwt().refreshTokenDays(), ChronoUnit.DAYS);

        refreshTokenRepository.save(RefreshTokenEntity.builder()
                .userId(user.getId())
                .tokenHash(sha256(refreshRaw))
                .deviceId(deviceId)
                .expiresAt(refreshExp)
                .build());

        return new AuthDtos.TokenResponse(
                access,
                refreshRaw,
                "Bearer",
                properties.jwt().accessTokenMinutes() * 60,
                toSummary(user)
        );
    }

    public AuthDtos.UserSummary toSummary(UserEntity user) {
        return new AuthDtos.UserSummary(
                user.getId().toString(),
                user.getPhoneE164(),
                user.getDisplayName(),
                user.getStatus().name(),
                user.getRole().name(),
                user.getPreferredLocale(),
                user.getGender() == null ? null : user.getGender().name(),
                profileRepository.findById(user.getId())
                        .map(profile -> profile.getPhotoUrls() != null && profile.getPhotoUrls().size() >= 3
                                && profile.getCity() != null && !profile.getCity().isBlank()
                                && profile.getBioEn() != null && !profile.getBioEn().isBlank()
                                && profile.getBioAm() != null && !profile.getBioAm().isBlank())
                        .orElse(false),
                legalConsentService.hasAcceptedCurrent(user),
                legalConsentService.currentVersion()
        );
    }

    private String randomToken() {
        byte[] bytes = new byte[32];
        secureRandom.nextBytes(bytes);
        return HexFormat.of().formatHex(bytes);
    }

    private static String sha256(String value) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
}
