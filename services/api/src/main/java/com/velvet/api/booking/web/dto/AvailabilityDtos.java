package com.velvet.api.booking.web.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;

public final class AvailabilityDtos {

    private AvailabilityDtos() {}

    public record WindowResponse(
            String id,
            Instant startsAt,
            Instant endsAt,
            String note
    ) {}

    public record WindowsResponse(List<WindowResponse> items) {}

    public record CreateWindowRequest(
            @NotNull @Future Instant startsAt,
            @NotNull Instant endsAt,
            @Size(max = 140) String note
    ) {}
}
