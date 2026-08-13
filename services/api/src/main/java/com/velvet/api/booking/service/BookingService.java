package com.velvet.api.booking.service;

import com.velvet.api.booking.domain.BookingEntity;
import com.velvet.api.booking.domain.BookingStatus;
import com.velvet.api.booking.domain.MeetingFeedbackEntity;
import com.velvet.api.booking.repo.BookingRepository;
import com.velvet.api.booking.repo.MeetingFeedbackRepository;
import com.velvet.api.booking.web.dto.BookingDtos;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import com.velvet.api.identity.domain.Gender;
import com.velvet.api.identity.domain.MemberProfileEntity;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.repo.MemberProfileRepository;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.domain.MatchStatus;
import com.velvet.api.matching.repo.ConnectionRepository;
import com.velvet.api.notify.ConciergeNotifyService;
import com.velvet.api.notify.MemberNotifyService;
import com.velvet.api.safety.service.BlockService;
import com.velvet.api.venues.domain.VenueEntity;
import com.velvet.api.venues.repo.VenueRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class BookingService {

    private final BookingRepository bookingRepository;
    private final MeetingFeedbackRepository feedbackRepository;
    private final ConnectionRepository connectionRepository;
    private final VenueRepository venueRepository;
    private final UserRepository userRepository;
    private final MemberProfileRepository profileRepository;
    private final VelvetProperties properties;
    private final MemberNotifyService memberNotifyService;
    private final ConciergeNotifyService conciergeNotifyService;
    private final BlockService blockService;
    private final AvailabilityService availabilityService;
    private final com.velvet.api.billing.service.BillingService billingService;
    private final com.velvet.api.safety.repo.TripShareRepository tripShareRepository;

    public BookingService(
            BookingRepository bookingRepository,
            MeetingFeedbackRepository feedbackRepository,
            ConnectionRepository connectionRepository,
            VenueRepository venueRepository,
            UserRepository userRepository,
            MemberProfileRepository profileRepository,
            VelvetProperties properties,
            MemberNotifyService memberNotifyService,
            ConciergeNotifyService conciergeNotifyService,
            BlockService blockService,
            AvailabilityService availabilityService,
            @org.springframework.context.annotation.Lazy com.velvet.api.billing.service.BillingService billingService,
            com.velvet.api.safety.repo.TripShareRepository tripShareRepository
    ) {
        this.bookingRepository = bookingRepository;
        this.feedbackRepository = feedbackRepository;
        this.connectionRepository = connectionRepository;
        this.venueRepository = venueRepository;
        this.userRepository = userRepository;
        this.profileRepository = profileRepository;
        this.properties = properties;
        this.memberNotifyService = memberNotifyService;
        this.conciergeNotifyService = conciergeNotifyService;
        this.blockService = blockService;
        this.availabilityService = availabilityService;
        this.billingService = billingService;
        this.tripShareRepository = tripShareRepository;
    }

    @Transactional
    public BookingDtos.BookingResponse propose(UUID userId, BookingDtos.CreateBookingRequest request) {
        ConnectionEntity match = connectionRepository.findById(request.matchId())
                .orElseThrow(() -> new BusinessException("MATCH_NOT_FOUND", "Match not found."));
        if (match.getStatus() != MatchStatus.MUTUAL) {
            throw new BusinessException("MATCH_NOT_MUTUAL", "Bookings require mutual acceptance.");
        }
        if (!match.getMemberAId().equals(userId) && !match.getMemberBId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not a participant.");
        }
        if (blockService.isBlockedEitherWay(match.getMemberAId(), match.getMemberBId())) {
            throw new BusinessException("MEMBERS_BLOCKED", "Cannot book while a block is in place.");
        }
        if (bookingRepository.findByConnectionId(match.getId()).filter(b -> b.getStatus() != BookingStatus.CANCELLED).isPresent()) {
            throw new BusinessException("BOOKING_EXISTS", "A booking already exists for this match.");
        }

        PlaceSelection place = resolvePlace(request.venueId(), request.meetupPlace());
        RateSnapshot rate = resolveRate(match, userId, request.rateType());
        UUID performerId = resolvePerformerId(match);
        assertScheduleOk(performerId, request.startsAt(), rate.rateType(), null);

        BookingEntity booking = bookingRepository.findByConnectionId(match.getId())
                .filter(b -> b.getStatus() == BookingStatus.CANCELLED)
                .orElse(null);
        if (booking == null) {
            booking = BookingEntity.builder()
                    .connectionId(match.getId())
                    .venueId(place.venueId())
                    .meetupPlace(place.meetupPlace())
                    .rateType(rate.rateType())
                    .amountEtb(rate.amountEtb())
                    .paymentStatus(rate.amountEtb() == null || rate.amountEtb() <= 0 ? "WAIVED" : "UNPAID")
                    .proposedBy(userId)
                    .startsAt(request.startsAt())
                    .notes(request.notes())
                    .status(BookingStatus.PROPOSED)
                    .build();
        } else {
            booking.setVenueId(place.venueId());
            booking.setMeetupPlace(place.meetupPlace());
            booking.setRateType(rate.rateType());
            booking.setAmountEtb(rate.amountEtb());
            booking.setPaymentStatus(rate.amountEtb() == null || rate.amountEtb() <= 0 ? "WAIVED" : "UNPAID");
            booking.setPaymentIntentId(null);
            booking.setProposedBy(userId);
            booking.setStartsAt(request.startsAt());
            booking.setNotes(request.notes());
            booking.setStatus(BookingStatus.PROPOSED);
            booking.setConfirmedAt(null);
            booking.setCancelledAt(null);
            booking.setCheckedInAt(null);
            booking.setCheckedOutAt(null);
            booking.setPerformerCheckedOutAt(null);
            booking.setClientCheckedOutAt(null);
            booking.setReminder24hSentAt(null);
            booking.setReminder2hSentAt(null);
        }
        booking = bookingRepository.save(booking);

        UUID other = match.getMemberAId().equals(userId) ? match.getMemberBId() : match.getMemberAId();
        String placeLabel = placeLabel(booking, place.venue());
        memberNotifyService.notifyUser(
                other,
                "Booking proposed · " + placeLabel,
                "Confirm the time" + (rate.amountEtb() != null ? " · " + rate.amountEtb() + " ETB" : "") + ".",
                "BOOKING",
                booking.getId().toString()
        );

        return toResponse(booking, place.venue(), userId);
    }

    @Transactional
    public BookingDtos.BookingResponse confirm(UUID userId, UUID bookingId) {
        BookingEntity booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking not found."));
        ConnectionEntity match = connectionRepository.findById(booking.getConnectionId())
                .orElseThrow(() -> new BusinessException("MATCH_NOT_FOUND", "Match not found."));
        if (!match.getMemberAId().equals(userId) && !match.getMemberBId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not a participant.");
        }
        if (booking.getProposedBy().equals(userId)) {
            throw new BusinessException("CANNOT_SELF_CONFIRM", "The other member must confirm.");
        }
        if (booking.getStatus() != BookingStatus.PROPOSED) {
            throw new BusinessException("BOOKING_CLOSED", "Booking is not awaiting confirmation.");
        }
        booking.setStatus(BookingStatus.CONFIRMED);
        booking.setConfirmedAt(Instant.now());
        bookingRepository.save(booking);
        VenueEntity venue = optionalVenue(booking.getVenueId());
        String placeLabel = placeLabel(booking, venue);
        memberNotifyService.notifyUsers(
                List.of(match.getMemberAId(), match.getMemberBId()),
                "Booking confirmed · " + placeLabel,
                "You're both set — open the booking for details.",
                "BOOKING",
                booking.getId().toString()
        );
        return toResponse(booking, venue, userId);
    }

    @Transactional
    public BookingDtos.BookingResponse cancel(UUID userId, UUID bookingId, String reason) {
        BookingEntity booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking not found."));
        ConnectionEntity match = connectionRepository.findById(booking.getConnectionId())
                .orElseThrow(() -> new BusinessException("MATCH_NOT_FOUND", "Match not found."));
        if (!match.getMemberAId().equals(userId) && !match.getMemberBId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not a participant.");
        }
        if (booking.getStatus() == BookingStatus.CANCELLED) {
            throw new BusinessException("ALREADY_CANCELLED", "Booking already cancelled.");
        }
        if (booking.getStatus() == BookingStatus.COMPLETED || booking.getStatus() == BookingStatus.CHECKED_IN) {
            throw new BusinessException("BOOKING_LOCKED", "Cannot cancel after check-in.");
        }
        if (booking.getStatus() == BookingStatus.PROPOSED && !booking.getProposedBy().equals(userId)) {
            throw new BusinessException("CANNOT_CANCEL", "Only the proposer can cancel a pending proposal.");
        }
        if (booking.getStatus() == BookingStatus.CONFIRMED && booking.getStartsAt().isBefore(Instant.now())) {
            throw new BusinessException("TOO_LATE", "Cannot cancel after the meeting start time.");
        }

        booking.setStatus(BookingStatus.CANCELLED);
        booking.setCancelledAt(Instant.now());
        if (reason != null && !reason.isBlank()) {
            String note = booking.getNotes() == null ? "" : booking.getNotes() + " | ";
            booking.setNotes(note + "Cancelled: " + reason.trim());
        }
        bookingRepository.save(booking);

        // A CBE receipt can be submitted later, so cancellation must explicitly
        // close every unpaid checkout attempt before the booking can be reused.
        billingService.cancelPendingBookingPayments(booking.getId(), reason);

        if ("PAID".equals(booking.getPaymentStatus())) {
            Instant cutoff = booking.getStartsAt().minus(2, java.time.temporal.ChronoUnit.HOURS);
            if (Instant.now().isBefore(cutoff)) {
                billingService.initiateRefund(booking.getId(), reason);
            } else {
                String penNote = booking.getNotes() == null ? "" : booking.getNotes() + " | ";
                booking.setNotes(penNote + "Penalty: Late cancellation refund forfeit.");
                bookingRepository.save(booking);
            }
        }

        VenueEntity venue = optionalVenue(booking.getVenueId());
        UUID other = match.getMemberAId().equals(userId) ? match.getMemberBId() : match.getMemberAId();
        memberNotifyService.notifyUser(
                other,
                "Booking cancelled",
                "The booking at " + placeLabel(booking, venue) + " was cancelled.",
                "BOOKING",
                booking.getId().toString()
        );
        return toResponse(booking, venue, userId);
    }

    @Transactional
    public BookingDtos.BookingResponse reschedule(UUID userId, UUID bookingId, BookingDtos.RescheduleRequest request) {
        BookingEntity booking = requireParticipantBooking(userId, bookingId);
        if (booking.getStatus() != BookingStatus.PROPOSED && booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new BusinessException("BOOKING_LOCKED", "Only proposed or confirmed meetings can be rescheduled.");
        }
        if ("PAID".equals(booking.getPaymentStatus()) || "PENDING".equals(booking.getPaymentStatus())) {
            throw new BusinessException(
                    "PAID_BOOKING_RESCHEDULE",
                    "A paid or pending-payment booking cannot be rescheduled. Cancel it first so payment can be refunded or resolved."
            );
        }
        PlaceSelection place = resolvePlace(
                request.venueId() != null ? request.venueId() : booking.getVenueId(),
                request.meetupPlace() != null ? request.meetupPlace() : booking.getMeetupPlace()
        );
        ConnectionEntity match = connectionRepository.findById(booking.getConnectionId()).orElseThrow();
        RateSnapshot rate = resolveRate(
                match,
                userId,
                request.rateType() != null ? request.rateType() : booking.getRateType()
        );
        assertScheduleOk(resolvePerformerId(match), request.startsAt(), rate.rateType(), booking.getId());

        boolean wasConfirmed = booking.getStatus() == BookingStatus.CONFIRMED;
        booking.setVenueId(place.venueId());
        booking.setMeetupPlace(place.meetupPlace());
        booking.setRateType(rate.rateType());
        booking.setAmountEtb(rate.amountEtb());
        if (!"PAID".equals(booking.getPaymentStatus())) {
            booking.setPaymentStatus(rate.amountEtb() == null || rate.amountEtb() <= 0 ? "WAIVED" : "UNPAID");
            booking.setPaymentIntentId(null);
        }
        booking.setStartsAt(request.startsAt());
        if (request.notes() != null) {
            booking.setNotes(request.notes());
        }
        booking.setProposedBy(userId);
        booking.setStatus(BookingStatus.PROPOSED);
        booking.setConfirmedAt(null);
        booking.setReminder24hSentAt(null);
        booking.setReminder2hSentAt(null);
        bookingRepository.save(booking);

        UUID other = match.getMemberAId().equals(userId) ? match.getMemberBId() : match.getMemberAId();
        memberNotifyService.notifyUser(
                other,
                "Booking rescheduled · " + placeLabel(booking, place.venue()),
                (wasConfirmed ? "A confirmed booking was moved. " : "") + "Please confirm the new time.",
                "BOOKING",
                booking.getId().toString()
        );
        return toResponse(booking, place.venue(), userId);
    }

    @Transactional
    public int sendDueReminders() {
        Instant now = Instant.now();
        int sent = 0;

        List<BookingEntity> due24 = bookingRepository.findByStatusAndStartsAtBetweenAndReminder24hSentAtIsNull(
                BookingStatus.CONFIRMED,
                now.plus(20, ChronoUnit.HOURS),
                now.plus(25, ChronoUnit.HOURS)
        );
        for (BookingEntity booking : due24) {
            sent += remind(booking, "24h") ? 1 : 0;
            booking.setReminder24hSentAt(now);
        }

        List<BookingEntity> due2 = bookingRepository.findByStatusAndStartsAtBetweenAndReminder2hSentAtIsNull(
                BookingStatus.CONFIRMED,
                now.plus(90, ChronoUnit.MINUTES),
                now.plus(150, ChronoUnit.MINUTES)
        );
        for (BookingEntity booking : due2) {
            sent += remind(booking, "2h") ? 1 : 0;
            booking.setReminder2hSentAt(now);
        }

        return sent;
    }

    private boolean remind(BookingEntity booking, String window) {
        ConnectionEntity match = connectionRepository.findById(booking.getConnectionId()).orElse(null);
        if (match == null) {
            return false;
        }
        VenueEntity venue = optionalVenue(booking.getVenueId());
        String label = placeLabel(booking, venue);
        String subject = "2h".equals(window)
                ? "Meeting in 2h · " + label
                : "Tomorrow · " + label;
        String body = "2h".equals(window)
                ? "Your VELVET booking starts in about 2 hours."
                : "Reminder: your booking at " + label + " is tomorrow.";
        memberNotifyService.notifyUsers(
                List.of(match.getMemberAId(), match.getMemberBId()),
                subject,
                body,
                "BOOKING_REMINDER",
                booking.getId().toString()
        );
        return true;
    }

    @Transactional(readOnly = true)
    public BookingDtos.BookingResponse get(UUID userId, UUID bookingId) {
        BookingEntity booking = requireParticipantBooking(userId, bookingId);
        return toResponse(booking, optionalVenue(booking.getVenueId()), userId);
    }

    @Transactional(readOnly = true)
    public BookingDtos.BookingResponse forConnection(UUID userId, UUID matchId) {
        ConnectionEntity match = connectionRepository.findById(matchId)
                .orElseThrow(() -> new BusinessException("MATCH_NOT_FOUND", "Match not found."));
        if (!match.getMemberAId().equals(userId) && !match.getMemberBId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not a participant.");
        }
        BookingEntity booking = bookingRepository.findByConnectionId(matchId)
                .filter(b -> b.getStatus() != BookingStatus.CANCELLED)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "No booking yet."));
        return toResponse(booking, optionalVenue(booking.getVenueId()), userId);
    }

    @Transactional
    public BookingDtos.BookingResponse checkIn(UUID userId, UUID bookingId, BookingDtos.CheckInRequest request) {
        BookingEntity booking = requireParticipantBooking(userId, bookingId);
        if (booking.getStatus() != BookingStatus.CONFIRMED && booking.getStatus() != BookingStatus.CHECKED_IN) {
            throw new BusinessException("BOOKING_NOT_CONFIRMED", "Check-in requires a confirmed booking.");
        }
        if (booking.getStartsAt().isAfter(Instant.now().plus(30, ChronoUnit.MINUTES))) {
            throw new BusinessException("CHECKIN_TOO_EARLY", "Check-in opens 30 minutes before the scheduled start time.");
        }
        if (!"PAID".equals(booking.getPaymentStatus())) {
            throw new BusinessException("BOOKING_PAYMENT_REQUIRED", "Payment must be verified before check-in.");
        }
        VenueEntity venue = optionalVenue(booking.getVenueId());
        if (venue != null) {
            assertWithinGeofence(venue, request);
        } else {
            // Strict Safety Requirement for Private Bookings
            if (!tripShareRepository.existsByBookingIdAndStatus(bookingId, "ACTIVE") &&
                !tripShareRepository.existsByMatchIdAndStatus(booking.getConnectionId(), "ACTIVE")) {
                throw new BusinessException("SAFETY_BEACON_REQUIRED", "Checking in to a private location requires an active trip share beacon. Please share your location first.");
            }
        }

        if (booking.getCheckedInAt() == null) {
            booking.setCheckedInAt(Instant.now());
            booking.setStatus(BookingStatus.CHECKED_IN);
            bookingRepository.save(booking);
        }
        return toResponse(booking, venue, userId);
    }

    private void assertWithinGeofence(VenueEntity venue, BookingDtos.CheckInRequest request) {
        boolean require = properties.concierge() != null && properties.concierge().requireGeofence();
        if (venue.getLatitude() == null || venue.getLongitude() == null) {
            if (require) {
                throw new BusinessException("VENUE_GEO_MISSING", "Venue has no geofence coordinates configured.");
            }
            return;
        }
        if (request == null || request.latitude() == null || request.longitude() == null) {
            if (require) {
                throw new BusinessException("LOCATION_REQUIRED", "Location is required to check in at the venue.");
            }
            return;
        }
        double meters = haversineMeters(
                venue.getLatitude(), venue.getLongitude(),
                request.latitude(), request.longitude()
        );
        int allowed = venue.getGeofenceMeters() <= 0 ? 400 : venue.getGeofenceMeters();
        if (meters > allowed) {
            throw new BusinessException(
                    "OUTSIDE_GEOFENCE",
                    "You appear to be " + Math.round(meters) + "m from the venue (allowed " + allowed + "m)."
            );
        }
    }

    private static double haversineMeters(double lat1, double lon1, double lat2, double lon2) {
        final double r = 6371000.0;
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        return 2 * r * Math.asin(Math.sqrt(a));
    }

    @Transactional
    public BookingDtos.BookingResponse checkOut(UUID userId, UUID bookingId) {
        BookingEntity booking = requireParticipantBooking(userId, bookingId);
        if (booking.getStatus() != BookingStatus.CHECKED_IN || booking.getCheckedInAt() == null) {
            throw new BusinessException("NOT_CHECKED_IN", "Check in before completing the meeting.");
        }
        if (booking.getCheckedInAt().plus(15, ChronoUnit.MINUTES).isAfter(Instant.now())) {
            throw new BusinessException("CHECKOUT_TOO_EARLY", "Checkout is available 15 minutes after check-in.");
        }
        UUID performerId = resolvePerformerId(connectionRepository.findById(booking.getConnectionId()).orElseThrow());
        Instant now = Instant.now();
        if (performerId.equals(userId)) {
            booking.setPerformerCheckedOutAt(now);
        } else {
            booking.setClientCheckedOutAt(now);
        }
        if (booking.getPerformerCheckedOutAt() != null && booking.getClientCheckedOutAt() != null) {
            booking.setCheckedOutAt(now);
            booking.setStatus(BookingStatus.COMPLETED);
        }
        bookingRepository.save(booking);
        if (booking.getStatus() == BookingStatus.COMPLETED) {
            billingService.settleCompletedBooking(booking.getId());
        }
        return toResponse(booking, optionalVenue(booking.getVenueId()), userId);
    }

    @Transactional
    public BookingDtos.FeedbackResponse submitFeedback(UUID userId, UUID bookingId, BookingDtos.FeedbackRequest request) {
        BookingEntity booking = requireParticipantBooking(userId, bookingId);
        if (booking.getStatus() != BookingStatus.COMPLETED && booking.getCheckedOutAt() == null) {
            throw new BusinessException("MEETING_NOT_COMPLETE", "Feedback is available after checkout.");
        }
        if (feedbackRepository.existsByBookingIdAndUserId(bookingId, userId)) {
            throw new BusinessException("FEEDBACK_EXISTS", "You already submitted feedback for this meeting.");
        }
        MeetingFeedbackEntity saved = feedbackRepository.save(MeetingFeedbackEntity.builder()
                .bookingId(bookingId)
                .userId(userId)
                .feltSafe(Boolean.TRUE.equals(request.feltSafe()))
                .wouldMeetAgain(Boolean.TRUE.equals(request.wouldMeetAgain()))
                .venueOk(Boolean.TRUE.equals(request.venueOk()))
                .notes(request.notes() == null || request.notes().isBlank() ? null : request.notes().trim())
                .build());
        if (!saved.isFeltSafe()) {
            conciergeNotifyService.notifyOps(
                    "VELVET meeting feedback — unsafe",
                    "user=%s booking=%s notes=%s".formatted(
                            userId, bookingId, saved.getNotes() == null ? "-" : saved.getNotes()),
                    "MEETING_FEEDBACK",
                    saved.getId().toString()
            );
        }
        return new BookingDtos.FeedbackResponse(
                saved.getId().toString(),
                bookingId.toString(),
                saved.isFeltSafe(),
                saved.isWouldMeetAgain(),
                saved.isVenueOk(),
                saved.getCreatedAt()
        );
    }

    /** Marks booking paid after a BOOKING payment intent succeeds. */
    @Transactional
    public void markPaymentPaid(UUID bookingId, UUID paymentIntentId) {
        BookingEntity booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking not found."));
        booking.setPaymentStatus("PAID");
        booking.setPaymentIntentId(paymentIntentId);
        bookingRepository.save(booking);
    }

    @Transactional
    public void markPaymentPending(UUID bookingId, UUID paymentIntentId) {
        BookingEntity booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking not found."));
        booking.setPaymentStatus("PENDING");
        booking.setPaymentIntentId(paymentIntentId);
        bookingRepository.save(booking);
    }

    private BookingEntity requireParticipantBooking(UUID userId, UUID bookingId) {
        BookingEntity booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking not found."));
        ConnectionEntity match = connectionRepository.findById(booking.getConnectionId())
                .orElseThrow(() -> new BusinessException("MATCH_NOT_FOUND", "Match not found."));
        if (!match.getMemberAId().equals(userId) && !match.getMemberBId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not a participant.");
        }
        return booking;
    }

    private PlaceSelection resolvePlace(UUID venueId, String meetupPlace) {
        boolean hasVenue = venueId != null;
        String place = meetupPlace == null ? null : meetupPlace.trim();
        boolean hasPlace = place != null && !place.isEmpty();
        if (hasVenue == hasPlace) {
            if (!hasVenue) {
                throw new BusinessException("PLACE_REQUIRED", "Provide a meetup place (hotel/suite) or a partner venue.");
            }
            throw new BusinessException("PLACE_CONFLICT", "Choose either a meetup place or a partner venue, not both.");
        }
        if (hasVenue) {
            VenueEntity venue = venueRepository.findById(venueId)
                    .filter(VenueEntity::isActive)
                    .orElseThrow(() -> new BusinessException("VENUE_NOT_FOUND", "Venue not found or inactive."));
            return new PlaceSelection(venue.getId(), null, venue);
        }
        return new PlaceSelection(null, place, null);
    }

    private RateSnapshot resolveRate(ConnectionEntity match, UUID proposerId, String rateTypeRaw) {
        UUID otherId = match.getMemberAId().equals(proposerId) ? match.getMemberBId() : match.getMemberAId();
        UserEntity performer = userRepository.findById(otherId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "Counterpart not found."));
        // Prefer listing on the performer; if proposer is the performer, use their own rates
        UserEntity listingUser = isPerformer(performer) ? performer
                : userRepository.findById(proposerId).filter(this::isPerformer).orElse(performer);
        MemberProfileEntity profile = profileRepository.findById(listingUser.getId()).orElse(null);

        String rateType = rateTypeRaw == null || rateTypeRaw.isBlank()
                ? "SESSION"
                : rateTypeRaw.trim().toUpperCase(Locale.ROOT);
        if (!rateType.equals("SESSION") && !rateType.equals("OVERNIGHT")) {
            throw new BusinessException("INVALID_RATE_TYPE", "rateType must be SESSION or OVERNIGHT.");
        }
        Integer amount = null;
        if (profile != null) {
            amount = rateType.equals("OVERNIGHT") ? profile.getOvernightRateEtb() : profile.getSessionRateEtb();
        }
        if (amount == null || amount <= 0) {
            throw new BusinessException(
                    "SESSION_RATE_REQUIRED",
                    "This performer must publish a positive " + rateType.toLowerCase(Locale.ROOT) + " rate before a booking can be proposed."
            );
        }
        return new RateSnapshot(rateType, amount);
    }

    private boolean isPerformer(UserEntity user) {
        return user.getRole() == UserRole.PERFORMER;
    }

    private UUID resolvePerformerId(ConnectionEntity match) {
        UserEntity a = userRepository.findById(match.getMemberAId()).orElse(null);
        UserEntity b = userRepository.findById(match.getMemberBId()).orElse(null);
        if (a != null && isPerformer(a)) {
            return a.getId();
        }
        if (b != null && isPerformer(b)) {
            return b.getId();
        }
        return match.getMemberBId();
    }

    private void assertScheduleOk(UUID performerId, Instant startsAt, String rateType, UUID excludeBookingId) {
        availabilityService.requireCovered(performerId, startsAt, rateType);
        Instant rangeEnd = startsAt.plus(AvailabilityService.durationFor(rateType));
        List<MatchStatus> statuses = List.of(MatchStatus.MUTUAL);
        for (ConnectionEntity otherMatch : connectionRepository.findForUserWithStatuses(performerId, statuses)) {
            bookingRepository.findByConnectionId(otherMatch.getId()).ifPresent(existing -> {
                if (excludeBookingId != null && existing.getId().equals(excludeBookingId)) {
                    return;
                }
                if (existing.getStatus() == BookingStatus.CANCELLED
                        || existing.getStatus() == BookingStatus.COMPLETED
                        || existing.getStatus() == BookingStatus.NO_SHOW) {
                    return;
                }
                Instant existingStart = existing.getStartsAt();
                Instant existingEnd = existingStart.plus(AvailabilityService.durationFor(existing.getRateType()));
                boolean overlaps = startsAt.isBefore(existingEnd) && rangeEnd.isAfter(existingStart);
                if (overlaps) {
                    throw new BusinessException(
                            "SCHEDULE_CONFLICT",
                            "Performer already has a booking overlapping that time."
                    );
                }
            });
        }
    }

    private VenueEntity optionalVenue(UUID venueId) {
        if (venueId == null) {
            return null;
        }
        return venueRepository.findById(venueId).orElse(null);
    }

    private static String placeLabel(BookingEntity booking, VenueEntity venue) {
        if (venue != null) {
            return venue.getName();
        }
        if (booking.getMeetupPlace() != null && !booking.getMeetupPlace().isBlank()) {
            return booking.getMeetupPlace();
        }
        return "private meetup";
    }

    private BookingDtos.BookingResponse toResponse(BookingEntity booking, VenueEntity venue) {
        return toResponse(booking, venue, null);
    }

    private BookingDtos.BookingResponse toResponse(BookingEntity booking, VenueEntity venue, UUID viewerId) {
        boolean feedbackSubmitted = viewerId != null
                && feedbackRepository.existsByBookingIdAndUserId(booking.getId(), viewerId);
        return new BookingDtos.BookingResponse(
                booking.getId().toString(),
                booking.getConnectionId().toString(),
                venue == null ? null : venue.getId().toString(),
                venue == null ? booking.getMeetupPlace() : venue.getName(),
                venue == null ? null : venue.getNameAm(),
                venue == null ? null : venue.getArea(),
                venue == null ? null : venue.getPriceBand(),
                venue == null ? null : venue.getVibe(),
                venue == null || venue.getPhotoUrls() == null ? List.of() : List.copyOf(venue.getPhotoUrls()),
                venue == null ? null : venue.isVerified(),
                venue == null ? null : venue.getLatitude(),
                venue == null ? null : venue.getLongitude(),
                venue == null ? null : venue.getAddressLine(),
                venue == null ? null : venue.getCity(),
                booking.getMeetupPlace(),
                booking.getRateType(),
                booking.getAmountEtb(),
                booking.getPaymentStatus(),
                booking.getStatus().name(),
                booking.getStartsAt(),
                booking.getNotes(),
                booking.getProposedBy().toString(),
                booking.getConfirmedAt(),
                booking.getCheckedInAt(),
                booking.getCheckedOutAt(),
                viewerId != null && hasCheckedOut(booking, viewerId),
                viewerId != null && hasCounterpartCheckedOut(booking, viewerId),
                booking.getReminder24hSentAt(),
                booking.getReminder2hSentAt(),
                feedbackSubmitted
        );
    }

    private record PlaceSelection(UUID venueId, String meetupPlace, VenueEntity venue) {}

    private record RateSnapshot(String rateType, Integer amountEtb) {}

    private boolean hasCheckedOut(BookingEntity booking, UUID userId) {
        UUID performerId = resolvePerformerId(connectionRepository.findById(booking.getConnectionId()).orElseThrow());
        return performerId.equals(userId)
                ? booking.getPerformerCheckedOutAt() != null
                : booking.getClientCheckedOutAt() != null;
    }

    private boolean hasCounterpartCheckedOut(BookingEntity booking, UUID userId) {
        UUID performerId = resolvePerformerId(connectionRepository.findById(booking.getConnectionId()).orElseThrow());
        return performerId.equals(userId)
                ? booking.getClientCheckedOutAt() != null
                : booking.getPerformerCheckedOutAt() != null;
    }
}
