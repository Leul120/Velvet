package com.velvet.api.partner.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.partner.service.PartnerBookingService;
import com.velvet.api.partner.web.dto.PartnerDtos;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/partner")
public class PartnerController {

    private final PartnerBookingService partnerBookingService;

    public PartnerController(PartnerBookingService partnerBookingService) {
        this.partnerBookingService = partnerBookingService;
    }

    @GetMapping("/venue")
    public ResponseEntity<PartnerDtos.VenueResponse> venue(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(partnerBookingService.venueFor(principal.getUserId(), principal.getRole()));
    }

    @GetMapping("/bookings")
    public ResponseEntity<List<PartnerDtos.BookingResponse>> bookings(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(partnerBookingService.bookingsFor(principal.getUserId(), principal.getRole()));
    }

    @PostMapping("/bookings/{id}/desk-check-in")
    public ResponseEntity<PartnerDtos.BookingResponse> deskCheckIn(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(partnerBookingService.deskCheckIn(principal.getUserId(), principal.getRole(), id));
    }
}
