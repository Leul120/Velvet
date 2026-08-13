package com.velvet.api.safety.repo;

import com.velvet.api.safety.domain.TripShareEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface TripShareRepository extends JpaRepository<TripShareEntity, UUID> {
    List<TripShareEntity> findByUserIdAndStatusOrderByCreatedAtDesc(UUID userId, String status);
    
    boolean existsByBookingIdAndStatus(UUID bookingId, String status);
    boolean existsByMatchIdAndStatus(UUID matchId, String status);
}
