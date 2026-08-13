package com.velvet.api.booking.web;

import com.velvet.api.booking.service.BookingService;
import com.velvet.api.booking.web.dto.BookingDtos;
import com.velvet.api.identity.security.VelvetPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/v1/bookings")
public class BookingController {

    private final BookingService bookingService;

    public BookingController(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @PostMapping
    public ResponseEntity<BookingDtos.BookingResponse> propose(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody BookingDtos.CreateBookingRequest request
    ) {
        return ResponseEntity.ok(bookingService.propose(principal.getUserId(), request));
    }

    @PostMapping("/{id}/confirm")
    public ResponseEntity<BookingDtos.BookingResponse> confirm(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(bookingService.confirm(principal.getUserId(), id));
    }

    @PostMapping("/{id}/cancel")
    public ResponseEntity<BookingDtos.BookingResponse> cancel(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) BookingDtos.CancelRequest request
    ) {
        String reason = request == null ? null : request.reason();
        return ResponseEntity.ok(bookingService.cancel(principal.getUserId(), id, reason));
    }

    @PostMapping("/{id}/reschedule")
    public ResponseEntity<BookingDtos.BookingResponse> reschedule(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody BookingDtos.RescheduleRequest request
    ) {
        return ResponseEntity.ok(bookingService.reschedule(principal.getUserId(), id, request));
    }

    @PostMapping("/{id}/check-in")
    public ResponseEntity<BookingDtos.BookingResponse> checkIn(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @RequestBody(required = false) BookingDtos.CheckInRequest request
    ) {
        return ResponseEntity.ok(bookingService.checkIn(
                principal.getUserId(),
                id,
                request == null ? new BookingDtos.CheckInRequest(null, null) : request
        ));
    }

    @PostMapping("/{id}/check-out")
    public ResponseEntity<BookingDtos.BookingResponse> checkOut(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(bookingService.checkOut(principal.getUserId(), id));
    }

    @PostMapping("/{id}/feedback")
    public ResponseEntity<BookingDtos.FeedbackResponse> feedback(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id,
            @Valid @RequestBody BookingDtos.FeedbackRequest request
    ) {
        return ResponseEntity.ok(bookingService.submitFeedback(principal.getUserId(), id, request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<BookingDtos.BookingResponse> get(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID id
    ) {
        return ResponseEntity.ok(bookingService.get(principal.getUserId(), id));
    }

    @GetMapping({"/by-match/{connectionId}", "/by-connection/{connectionId}"})
    public ResponseEntity<BookingDtos.BookingResponse> byConnection(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID connectionId
    ) {
        return ResponseEntity.ok(bookingService.forConnection(principal.getUserId(), connectionId));
    }
}
