package com.velvet.api.booking.repo;

import com.velvet.api.booking.domain.AvailabilityWindowEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface AvailabilityWindowRepository extends JpaRepository<AvailabilityWindowEntity, UUID> {

    List<AvailabilityWindowEntity> findByUserIdAndEndsAtAfterOrderByStartsAtAsc(UUID userId, Instant after);

    @Query("""
            select count(w) > 0 from AvailabilityWindowEntity w
            where w.userId = :userId
              and w.startsAt <= :rangeStart
              and w.endsAt >= :rangeEnd
            """)
    boolean coversRange(
            @Param("userId") UUID userId,
            @Param("rangeStart") Instant rangeStart,
            @Param("rangeEnd") Instant rangeEnd
    );

    long countByUserIdAndEndsAtAfter(UUID userId, Instant after);
}
