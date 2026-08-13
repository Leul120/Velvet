package com.velvet.api.safety.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.UUID;

public final class SafetyDtos {

    private SafetyDtos() {}

    public record PanicRequest(
            UUID bookingId,
            UUID matchId,
            Double latitude,
            Double longitude,
            @Size(max = 500) String note
    ) {}

    public record PanicResponse(
            String id,
            String status,
            Instant createdAt
    ) {}

    public record ReportRequest(
            UUID reportedUserId,
            UUID matchId,
            UUID bookingId,
            @NotBlank String category,
            @NotBlank @Size(max = 2000) String details
    ) {}

    public record ReportResponse(
            String id,
            String category,
            String status,
            Instant createdAt
    ) {}

    public record BlockRequest(
            @jakarta.validation.constraints.NotNull UUID blockedUserId,
            @Size(max = 255) String reason
    ) {}

    public record BlockResponse(
            String id,
            String blockedUserId,
            String reason,
            Instant createdAt
    ) {}

    public record TripShareRequest(
            UUID bookingId,
            UUID matchId,
            Double latitude,
            Double longitude,
            Integer etaMinutes,
            @Size(max = 500) String note
    ) {}

    public record TripShareResponse(
            String id,
            String status,
            Instant createdAt
    ) {}
}
