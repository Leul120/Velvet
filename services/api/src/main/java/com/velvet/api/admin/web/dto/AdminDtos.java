package com.velvet.api.admin.web.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.UUID;

public final class AdminDtos {

    private AdminDtos() {}

    public record MemberSummary(
            String id,
            String phone,
            String displayName,
            String status,
            String role,
            String city,
            String conciergeNotes
    ) {}

    public record UpdateMemberStatusRequest(
            @NotNull String status
    ) {}

    public record PromoteRequest(
            @NotNull UUID userId,
            @NotNull String role
    ) {}

    public record MemberNotesRequest(@Size(max = 4000) String notes) {}

    public record CreateInviteRequest(
            @Size(max = 64) String code,
            @Min(1) @Max(1000) Integer maxUses,
            @Min(1) @Max(365) Integer expiresInDays
    ) {}

    public record InviteResponse(
            String id,
            String code,
            int maxUses,
            int useCount,
            boolean active,
            boolean usable,
            Instant expiresAt,
            Instant createdAt
    ) {}

    public record ReviewHeldRequest(boolean approve) {}

    public record ReviewReportRequest(
            @NotNull String status,
            @Size(max = 2000) String notes
    ) {}

    public record UpsertVenueRequest(
            @Size(max = 160) String name,
            @Size(max = 160) String nameAm,
            @Size(max = 64) String city,
            @Size(max = 64) String category,
            @Size(max = 500) String addressLine,
            @Size(max = 32) String privacyLevel,
            Double latitude,
            Double longitude,
            @Min(50) @Max(5000) Integer geofenceMeters,
            Boolean active,
            UUID partnerUserId,
            @Size(max = 64) String area,
            @Size(max = 32) String priceBand,
            @Size(max = 32) String vibe,
            java.util.List<@Size(max = 1024) String> photoUrls,
            Boolean verified
    ) {}

    public record VenueAdminResponse(
            String id,
            String name,
            String nameAm,
            String city,
            String category,
            String addressLine,
            String privacyLevel,
            Double latitude,
            Double longitude,
            int geofenceMeters,
            boolean active,
            String partnerUserId,
            String area,
            String priceBand,
            String vibe,
            java.util.List<String> photoUrls,
            boolean verified
    ) {}

    public record CreateStaffShiftRequest(
            @NotNull UUID userId,
            @NotNull Instant startsAt,
            @NotNull Instant endsAt,
            @Size(max = 64) String roleLabel,
            Boolean onCall,
            @Size(max = 4000) String notes
    ) {}

    public record StaffShiftResponse(
            String id,
            String userId,
            Instant startsAt,
            Instant endsAt,
            String roleLabel,
            boolean onCall,
            String notes,
            Instant createdAt
    ) {}
}
