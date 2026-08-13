package com.velvet.api.matching.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class MatchDtos {

    private MatchDtos() {}

    public record CreateMatchRequest(
            @NotNull UUID memberAId,
            @NotNull UUID memberBId,
            UUID suggestedVenueId,
            @Size(max = 1000) String introNoteEn,
            @Size(max = 1000) String introNoteAm,
            Integer expiresInHours
    ) {}

    public record MatchResponse(
            String id,
            String status,
            String counterpartDisplayName,
            String counterpartUserId,
            String introNoteEn,
            String introNoteAm,
            VenueSummary suggestedVenue,
            Instant expiresAt,
            boolean awaitingMyResponse,
            boolean mutual,
            boolean meetingCompleted,
            String meetingVenueName,
            List<String> counterpartPhotoUrls,
            Integer counterpartAge,
            String counterpartCity,
            String counterpartBioEn,
            String counterpartBioAm,
            List<String> counterpartInterests,
            String source,
            boolean becameMutual,
            String lastMessagePreview,
            Instant lastMessageAt,
            boolean lastMessageFromMe,
            int unreadCount,
            String turn,
            boolean counterpartVerified,
            Integer counterpartTrustScore
    ) {}

    public record VenueSummary(
            String id,
            String name,
            String nameAm,
            String city,
            String category,
            String addressLine,
            String privacyLevel,
            Double latitude,
            Double longitude,
            Integer geofenceMeters,
            String area,
            String priceBand,
            String vibe,
            java.util.List<String> photoUrls,
            Boolean verified
    ) {}

    public record VenueResponse(
            String id,
            String name,
            String nameAm,
            String city,
            String category,
            String addressLine,
            String privacyLevel,
            Double latitude,
            Double longitude,
            Integer geofenceMeters,
            String area,
            String priceBand,
            String vibe,
            java.util.List<String> photoUrls,
            Boolean verified
    ) {}

    public record DecisionRequest(
            @NotBlank String action // ACCEPT | DECLINE
    ) {}
}
