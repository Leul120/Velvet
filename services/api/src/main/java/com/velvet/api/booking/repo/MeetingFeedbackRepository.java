package com.velvet.api.booking.repo;

import com.velvet.api.booking.domain.MeetingFeedbackEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface MeetingFeedbackRepository extends JpaRepository<MeetingFeedbackEntity, UUID> {
    Optional<MeetingFeedbackEntity> findByBookingIdAndUserId(UUID bookingId, UUID userId);

    boolean existsByBookingIdAndUserId(UUID bookingId, UUID userId);

    @org.springframework.data.jpa.repository.Query(
        "SELECT COUNT(f) FROM MeetingFeedbackEntity f " +
        "JOIN BookingEntity b ON f.bookingId = b.id " +
        "JOIN ConnectionEntity c ON b.connectionId = c.id " +
        "WHERE (c.memberAId = :userId OR c.memberBId = :userId) " +
        "AND f.userId != :userId"
    )
    long countFeedbackReceivedByUserId(@org.springframework.data.repository.query.Param("userId") UUID userId);

    @org.springframework.data.jpa.repository.Query(
        "SELECT COUNT(f) FROM MeetingFeedbackEntity f " +
        "JOIN BookingEntity b ON f.bookingId = b.id " +
        "JOIN ConnectionEntity c ON b.connectionId = c.id " +
        "WHERE (c.memberAId = :userId OR c.memberBId = :userId) " +
        "AND f.userId != :userId AND f.wouldMeetAgain = true"
    )
    long countPositiveFeedbackReceivedByUserId(@org.springframework.data.repository.query.Param("userId") UUID userId);
}
