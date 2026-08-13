package com.velvet.api.partner.service;

import com.velvet.api.booking.domain.BookingEntity;
import com.velvet.api.booking.domain.BookingStatus;
import com.velvet.api.booking.repo.BookingRepository;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.partner.web.dto.PartnerDtos;
import com.velvet.api.venues.domain.VenueEntity;
import com.velvet.api.venues.repo.VenueRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class PartnerBookingService {

    private final VenueRepository venueRepository;
    private final BookingRepository bookingRepository;

    public PartnerBookingService(VenueRepository venueRepository, BookingRepository bookingRepository) {
        this.venueRepository = venueRepository;
        this.bookingRepository = bookingRepository;
    }

    @Transactional(readOnly = true)
    public PartnerDtos.VenueResponse venueFor(UUID partnerUserId, UserRole role) {
        return toVenueResponse(requirePartnerVenue(partnerUserId, role));
    }

    @Transactional(readOnly = true)
    public List<PartnerDtos.BookingResponse> bookingsFor(UUID partnerUserId, UserRole role) {
        VenueEntity venue = requirePartnerVenue(partnerUserId, role);
        return bookingRepository.findByVenueIdOrderByStartsAtDesc(venue.getId()).stream()
                .map(booking -> toBookingResponse(booking, venue))
                .toList();
    }

    @Transactional
    public PartnerDtos.BookingResponse deskCheckIn(UUID partnerUserId, UserRole role, UUID bookingId) {
        VenueEntity venue = requirePartnerVenue(partnerUserId, role);
        BookingEntity booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking not found."));
        if (!venue.getId().equals(booking.getVenueId())) {
            throw new BusinessException("FORBIDDEN", "Booking does not belong to your venue.");
        }
        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new BusinessException("BOOKING_NOT_CONFIRMED", "Desk check-in requires a confirmed booking.");
        }

        booking.setStatus(BookingStatus.CHECKED_IN);
        booking.setCheckedInAt(Instant.now());
        return toBookingResponse(bookingRepository.save(booking), venue);
    }

    private VenueEntity requirePartnerVenue(UUID partnerUserId, UserRole role) {
        if (role != UserRole.VENUE_PARTNER) {
            throw new BusinessException("FORBIDDEN", "Venue partner access is required.");
        }
        return venueRepository.findByPartnerUserId(partnerUserId)
                .orElseThrow(() -> new BusinessException("VENUE_NOT_ASSIGNED", "No venue is assigned to this partner."));
    }

    private PartnerDtos.VenueResponse toVenueResponse(VenueEntity venue) {
        return new PartnerDtos.VenueResponse(
                venue.getId().toString(),
                venue.getName(),
                venue.getCity(),
                venue.getAddressLine(),
                venue.getCategory(),
                venue.isActive()
        );
    }

    private PartnerDtos.BookingResponse toBookingResponse(BookingEntity booking, VenueEntity venue) {
        return new PartnerDtos.BookingResponse(
                booking.getId().toString(),
                booking.getStatus().name(),
                booking.getStartsAt(),
                venue.getName(),
                booking.getConnectionId().toString()
        );
    }
}
