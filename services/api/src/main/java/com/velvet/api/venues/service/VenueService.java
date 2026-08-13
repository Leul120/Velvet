package com.velvet.api.venues.service;

import com.velvet.api.matching.web.dto.MatchDtos;
import com.velvet.api.venues.domain.VenueEntity;
import com.velvet.api.venues.repo.VenueRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class VenueService {

    private final VenueRepository venueRepository;

    public VenueService(VenueRepository venueRepository) {
        this.venueRepository = venueRepository;
    }

    @Transactional(readOnly = true)
    public List<MatchDtos.VenueResponse> listActive() {
        return venueRepository.findByActiveTrueOrderByNameAsc().stream()
                .map(this::toResponse)
                .toList();
    }

    private MatchDtos.VenueResponse toResponse(VenueEntity v) {
        return new MatchDtos.VenueResponse(
                v.getId().toString(),
                v.getName(),
                v.getNameAm(),
                v.getCity(),
                v.getCategory(),
                v.getAddressLine(),
                v.getPrivacyLevel(),
                v.getLatitude(),
                v.getLongitude(),
                v.getGeofenceMeters(),
                v.getArea(),
                v.getPriceBand(),
                v.getVibe(),
                v.getPhotoUrls() == null ? List.of() : List.copyOf(v.getPhotoUrls()),
                v.isVerified()
        );
    }
}
