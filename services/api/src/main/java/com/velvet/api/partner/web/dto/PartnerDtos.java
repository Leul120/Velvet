package com.velvet.api.partner.web.dto;

import java.time.Instant;

public final class PartnerDtos {

    private PartnerDtos() {}

    public record VenueResponse(
            String id,
            String name,
            String city,
            String addressLine,
            String category,
            boolean active
    ) {}

    public record BookingResponse(
            String id,
            String status,
            Instant startsAt,
            String venueName,
            String matchId
    ) {}
}
