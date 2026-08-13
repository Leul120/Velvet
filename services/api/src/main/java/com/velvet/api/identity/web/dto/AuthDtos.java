package com.velvet.api.identity.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public final class AuthDtos {

    private AuthDtos() {}

    public record OtpRequest(
            @NotBlank(message = "Phone is required")
            @Pattern(regexp = "^\\+[1-9]\\d{7,14}$", message = "Phone must be E.164 (e.g. +2519...)")
            String phone,

            /** Required for first-time registration; ignored for returning members. */
            @Size(max = 64)
            String inviteCode,

            String deviceId,
            String platform
    ) {}

    public record OtpVerifyRequest(
            @NotBlank @Pattern(regexp = "^\\+[1-9]\\d{7,14}$")
            String phone,

            @NotBlank @Size(min = 4, max = 8)
            String code,

            String deviceId,
            String platform,

            /** Required for first-time registration; ignored when already accepted current version. */
            @Size(max = 32)
            String acceptedLegalVersion
    ) {}

    public record RefreshRequest(
            @NotBlank String refreshToken
    ) {}

    public record OtpRequestResponse(
            String message,
            Long expiresInSeconds,
            String devOtp
    ) {}

    public record TokenResponse(
            String accessToken,
            String refreshToken,
            String tokenType,
            long expiresInSeconds,
            UserSummary user
    ) {}

    public record UserSummary(
            String id,
            String phone,
            String displayName,
            String status,
            String role,
            String preferredLocale,
            String gender,
            boolean profileReady,
            boolean legalAccepted,
            String legalVersionRequired
    ) {}

    public record AcceptLegalRequest(
            @NotBlank @Size(max = 32) String documentSetVersion
    ) {}

    public record LegalStatusResponse(
            String documentSetVersion,
            boolean accepted,
            String termsPath,
            String privacyPath,
            String communityPath
    ) {}
}
