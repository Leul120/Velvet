package com.velvet.api.waitlist.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;

public final class WaitlistDtos {

    private WaitlistDtos() {}

    public record ApplyRequest(
            @NotBlank @Size(max = 32) String phoneE164,
            @Size(max = 120) String displayName,
            @Size(max = 64) String city,
            @Size(max = 4000) String note
    ) {}

    public record ApplicationResponse(
            String id,
            String phoneE164,
            String displayName,
            String city,
            String note,
            String status,
            String inviteCode,
            String reviewedBy,
            Instant reviewedAt,
            Instant createdAt,
            long friendsApproved
    ) {}

    public record StatusResponse(
            String status,
            String inviteCode,
            long friendsApproved,
            Instant createdAt,
            Instant reviewedAt
    ) {}

    public record ReviewRequest(@Size(max = 4000) String notes) {}
}
