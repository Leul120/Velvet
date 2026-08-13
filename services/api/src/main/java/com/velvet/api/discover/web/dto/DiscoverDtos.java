package com.velvet.api.discover.web.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public final class DiscoverDtos {

    private DiscoverDtos() {}

    public record DiscoverCard(
            String userId,
            String displayName,
            Integer age,
            String city,
            String bioEn,
            String bioAm,
            Integer heightCm,
            String jobTitle,
            String education,
            String languages,
            String religion,
            String lookingFor,
            Integer sessionRateEtb,
            Integer overnightRateEtb,
            String availabilityNote,
            List<String> photoUrls,
            Double distanceKm,
            List<String> interests,
            boolean verified,
            Integer likedPhotoIndex,
            String likedPromptKey,
            String likedPhotoUrl,
            String likeReason,
            Integer trustScore
    ) {}

    public record DiscoverFeedResponse(List<DiscoverCard> items, String mode) {}

    public record DiscoverActionRequest(
            @NotBlank String action,
            @Min(0) @Max(20) Integer likedPhotoIndex,
            @Size(max = 64) String likedPromptKey
    ) {}

    public record DiscoverActionResponse(
            boolean mutual,
            String matchId,
            String connectionId,
            String counterpartDisplayName,
            List<String> counterpartPhotoUrls
    ) {
        public DiscoverActionResponse(
                boolean mutual,
                String connectionId,
                String counterpartDisplayName,
                List<String> counterpartPhotoUrls
        ) {
            this(mutual, connectionId, connectionId, counterpartDisplayName, counterpartPhotoUrls);
        }
    }

    public record UndoResponse(
            String restoredUserId,
            String undoneAction,
            long remainingUndos
    ) {}

    public record PreferencesResponse(
            int minAge,
            int maxAge,
            int maxDistanceKm,
            List<String> cities,
            List<String> preferredLanguages,
            List<String> intents,
            boolean verifiedOnly
    ) {}

    public record PreferencesRequest(
            @Min(21) @Max(99) Integer minAge,
            @Min(21) @Max(99) Integer maxAge,
            @Min(1) @Max(500) Integer maxDistanceKm,
            List<String> cities,
            List<String> preferredLanguages,
            List<String> intents,
            Boolean verifiedOnly
    ) {}

    public record LocationRequest(
            @NotNull Double latitude,
            @NotNull Double longitude
    ) {}
}
