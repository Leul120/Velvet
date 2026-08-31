package com.velvet.api.booking.repo;

import com.velvet.api.booking.domain.BookingEntity;
import com.velvet.api.booking.domain.BookingStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface BookingRepository extends JpaRepository<BookingEntity, UUID> {
    Optional<BookingEntity> findByConnectionId(UUID matchId);

    List<BookingEntity> findByVenueIdOrderByStartsAtDesc(UUID venueId);

    List<BookingEntity> findByStatusAndStartsAtBetweenAndReminder24hSentAtIsNull(
            BookingStatus status,
            Instant from,
            Instant to
    );

    List<BookingEntity> findByStatusAndStartsAtBetweenAndReminder2hSentAtIsNull(
            BookingStatus status,
            Instant from,
            Instant to
    );

    List<BookingEntity> findByStatusInAndStartsAtBetween(
            List<BookingStatus> statuses,
            Instant from,
            Instant to
    );

    List<BookingEntity> findByStatusInAndStartsAtBeforeAndMessagesPurgedAtIsNull(
            List<BookingStatus> statuses,
            Instant before
    );

    List<BookingEntity> findByStatusAndStartsAtBeforeAndCheckedInAtIsNull(
            BookingStatus status,
            Instant before
    );

    List<BookingEntity> findByEscrowReleaseAtBeforeAndEscrowReleasedAtIsNullAndDisputedAtIsNull(Instant now);

}
