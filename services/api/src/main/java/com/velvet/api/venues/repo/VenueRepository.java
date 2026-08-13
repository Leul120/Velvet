package com.velvet.api.venues.repo;

import com.velvet.api.venues.domain.VenueEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface VenueRepository extends JpaRepository<VenueEntity, UUID> {
    List<VenueEntity> findByActiveTrueOrderByNameAsc();

    List<VenueEntity> findAllByOrderByNameAsc();

    Optional<VenueEntity> findByPartnerUserId(UUID partnerUserId);

    List<VenueEntity> findAllByPartnerUserId(UUID partnerUserId);
}
