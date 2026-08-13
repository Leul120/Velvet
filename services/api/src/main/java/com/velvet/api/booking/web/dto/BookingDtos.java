package com.velvet.api.booking.web.dto;

import jakarta.validation.constraints.Future;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class BookingDtos {

    private BookingDtos() {}

    public record CreateBookingRequest(
            @NotNull UUID matchId,
            UUID venueId,
            @Size(max = 280) String meetupPlace,
            @Size(max = 16) String rateType,
            @NotNull @Future Instant startsAt,
            @Size(max = 500) String notes
    ) {}

    public record CheckInRequest(
            Double latitude,
            Double longitude
    ) {}

    public record CancelRequest(@Size(max = 500) String reason) {}

    public record RescheduleRequest(
            UUID venueId,
            @Size(max = 280) String meetupPlace,
            @Size(max = 16) String rateType,
            @NotNull @Future Instant startsAt,
            @Size(max = 500) String notes
    ) {}

    public record FeedbackRequest(
            @NotNull Boolean feltSafe,
            @NotNull Boolean wouldMeetAgain,
            @NotNull Boolean venueOk,
            @Size(max = 1000) String notes
    ) {}

    public record FeedbackResponse(
            String id,
            String bookingId,
            boolean feltSafe,
            boolean wouldMeetAgain,
            boolean venueOk,
            Instant createdAt
    ) {}

    public record BookingResponse(
            String id,
            String matchId,
            String venueId,
            String venueName,
            String venueNameAm,
            String venueArea,
            String venuePriceBand,
            String venueVibe,
            List<String> venuePhotoUrls,
            Boolean venueVerified,
            Double venueLatitude,
            Double venueLongitude,
            String venueAddressLine,
            String venueCity,
            String meetupPlace,
            String rateType,
            Integer amountEtb,
            String paymentStatus,
            String status,
            Instant startsAt,
            String notes,
            String proposedBy,
            Instant confirmedAt,
            Instant checkedInAt,
            Instant checkedOutAt,
            boolean myCheckoutConfirmed,
            boolean counterpartCheckoutConfirmed,
            Instant reminder24hSentAt,
            Instant reminder2hSentAt,
            boolean feedbackSubmitted
    ) {}
}
