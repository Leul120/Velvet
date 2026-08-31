package com.velvet.api.identity.web.dto;

import jakarta.validation.constraints.Past;
import jakarta.validation.constraints.Size;

import java.time.LocalDate;
import java.util.List;
import java.time.Instant;

public final class ProfileDtos {

    private ProfileDtos() {}

    public record MeResponse(
            String id,
            String phone,
            String email,
            String displayName,
            String status,
            String role,
            String preferredLocale,
            LocalDate dateOfBirth,
            String gender,
            boolean legalAccepted,
            String legalVersionRequired,
            ProfileBody profile,
            Integer trustScore
    ) {}

    public record ProfileBody(
            String bioEn,
            String bioAm,
            String city,
            Integer heightCm, String jobTitle, String education, String languages, String religion, String lookingFor,
            Integer sessionRateEtb,
            Integer overnightRateEtb,
            String availabilityNote,
            boolean availableTonight,
            String availableNeighborhood,
            String voiceIntroUrl,
            boolean listingActive,
            List<String> interests,
            List<String> photoUrls,
            List<String> privatePhotoUrls,
            boolean hasVaultAccess,
            String photoQualityStatus
    ) {}

    public record ToggleAvailableTonightRequest(
            boolean availableTonight,
            @Size(max = 64) String availableNeighborhood
    ) {}

    public record UploadVoiceIntroRequest(
            @jakarta.validation.constraints.NotBlank @Size(max = 1024) String voiceIntroUrl
    ) {}

    public record GrantVaultAccessRequest(
            @jakarta.validation.constraints.NotNull java.util.UUID memberId,
            @Size(max = 120) String reason
    ) {}

    public record RequestVaultAccessRequest(
            @jakarta.validation.constraints.NotNull java.util.UUID performerId,
            @Size(max = 280) String message
    ) {}



    public record UpdateMeRequest(
            @Size(max = 120) String displayName,
            @Size(max = 8) String preferredLocale,
            @Past LocalDate dateOfBirth,
            String gender,
            @Size(max = 2000) String bioEn,
            @Size(max = 2000) String bioAm,
            @Size(max = 64) String city,
            @jakarta.validation.constraints.Min(120) @jakarta.validation.constraints.Max(230) Integer heightCm,
            @Size(max = 120) String jobTitle, @Size(max = 120) String education,
            @Size(max = 200) String languages, @Size(max = 80) String religion, @Size(max = 160) String lookingFor,
            @jakarta.validation.constraints.Min(0) @jakarta.validation.constraints.Max(5_000_000) Integer sessionRateEtb,
            @jakarta.validation.constraints.Min(0) @jakarta.validation.constraints.Max(5_000_000) Integer overnightRateEtb,
            @Size(max = 280) String availabilityNote,
            Boolean listingActive,
            List<@Size(max = 64) String> interests
    ) {}

    public record AddPhotoRequest(
            @Size(max = 1024) String url
    ) {}

    public record RemovePhotoRequest(@Size(max = 1024) String url) {}

    public record ReorderPhotosRequest(
            @jakarta.validation.constraints.NotNull
            @jakarta.validation.constraints.Size(min = 1, max = 12)
            List<@Size(max = 1024) String> photoUrls
    ) {}

    public record PhotoReviewResponse(
            String userId, String displayName, List<String> photoUrls, String status,
            String notes, Instant updatedAt
    ) {}

    public record ReviewPhotosRequest(boolean approve, @Size(max = 500) String notes) {}
}
