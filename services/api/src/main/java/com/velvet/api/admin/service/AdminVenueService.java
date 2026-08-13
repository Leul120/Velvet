package com.velvet.api.admin.service;

import com.velvet.api.admin.web.dto.AdminDtos;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.venues.domain.VenueEntity;
import com.velvet.api.venues.repo.VenueRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class AdminVenueService {

    private static final Set<String> CATEGORIES = Set.of("RESTAURANT", "CAFE", "HOTEL", "LOUNGE", "OTHER", "CLUB", "CULTURAL");
    private static final Set<String> PRIVACY = Set.of("STANDARD", "DISCREET", "PRIVATE_ROOM");
    private static final Set<String> PRICE_BANDS = Set.of("BUDGET", "MODERATE", "UPSCALE");
    private static final Set<String> VIBES = Set.of("QUIET", "BALANCED", "LIVELY");

    private final VenueRepository venueRepository;
    private final UserRepository userRepository;

    public AdminVenueService(VenueRepository venueRepository, UserRepository userRepository) {
        this.venueRepository = venueRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<AdminDtos.VenueAdminResponse> listAll() {
        return venueRepository.findAllByOrderByNameAsc().stream().map(this::toResponse).toList();
    }

    @Transactional
    public AdminDtos.VenueAdminResponse create(AdminDtos.UpsertVenueRequest request) {
        VenueEntity venue = apply(VenueEntity.builder().build(), request, true);
        return toResponse(venueRepository.save(venue));
    }

    @Transactional
    public AdminDtos.VenueAdminResponse update(UUID id, AdminDtos.UpsertVenueRequest request) {
        VenueEntity venue = venueRepository.findById(id)
                .orElseThrow(() -> new BusinessException("VENUE_NOT_FOUND", "Venue not found."));
        return toResponse(venueRepository.save(apply(venue, request, false)));
    }

    @Transactional
    public AdminDtos.VenueAdminResponse setActive(UUID id, boolean active) {
        VenueEntity venue = venueRepository.findById(id)
                .orElseThrow(() -> new BusinessException("VENUE_NOT_FOUND", "Venue not found."));
        venue.setActive(active);
        return toResponse(venueRepository.save(venue));
    }

    @Transactional
    public AdminDtos.VenueAdminResponse assignPartner(UUID venueId, UUID partnerUserId) {
        VenueEntity venue = venueRepository.findById(venueId)
                .orElseThrow(() -> new BusinessException("VENUE_NOT_FOUND", "Venue not found."));
        validatePartner(partnerUserId);
        venue.setPartnerUserId(partnerUserId);
        return toResponse(venueRepository.save(venue));
    }

    private VenueEntity apply(VenueEntity venue, AdminDtos.UpsertVenueRequest request, boolean creating) {
        if (request.name() == null || request.name().isBlank()) {
            throw new BusinessException("NAME_REQUIRED", "Venue name is required.");
        }
        if (request.addressLine() == null || request.addressLine().isBlank()) {
            throw new BusinessException("ADDRESS_REQUIRED", "Address is required.");
        }
        String category = request.category() == null || request.category().isBlank()
                ? "RESTAURANT"
                : request.category().trim().toUpperCase(Locale.ROOT);
        if (!CATEGORIES.contains(category)) {
            throw new BusinessException("INVALID_CATEGORY", "Unknown venue category.");
        }
        String privacy = request.privacyLevel() == null || request.privacyLevel().isBlank()
                ? "STANDARD"
                : request.privacyLevel().trim().toUpperCase(Locale.ROOT);
        if (!PRIVACY.contains(privacy)) {
            throw new BusinessException("INVALID_PRIVACY", "Privacy must be STANDARD or DISCREET.");
        }

        venue.setName(request.name().trim());
        venue.setNameAm(blankToNull(request.nameAm()));
        venue.setCity(request.city() == null || request.city().isBlank() ? "Addis Ababa" : request.city().trim());
        venue.setCategory(category);
        venue.setAddressLine(request.addressLine().trim());
        venue.setPrivacyLevel(privacy);
        venue.setLatitude(request.latitude());
        venue.setLongitude(request.longitude());
        venue.setGeofenceMeters(request.geofenceMeters() == null || request.geofenceMeters() < 50
                ? 400
                : request.geofenceMeters());
        if (creating) {
            venue.setActive(request.active() == null || request.active());
        } else if (request.active() != null) {
            venue.setActive(request.active());
        }
        if (request.partnerUserId() != null) {
            validatePartner(request.partnerUserId());
            venue.setPartnerUserId(request.partnerUserId());
        }
        if (request.area() != null) {
            venue.setArea(blankToNull(request.area()));
        }
        if (request.priceBand() != null && !request.priceBand().isBlank()) {
            String band = request.priceBand().trim().toUpperCase(Locale.ROOT);
            if (!PRICE_BANDS.contains(band)) {
                throw new BusinessException("INVALID_PRICE_BAND", "Price band must be BUDGET, MODERATE, or UPSCALE.");
            }
            venue.setPriceBand(band);
        } else if (creating) {
            venue.setPriceBand("MODERATE");
        }
        if (request.vibe() != null && !request.vibe().isBlank()) {
            String vibe = request.vibe().trim().toUpperCase(Locale.ROOT);
            if (!VIBES.contains(vibe)) {
                throw new BusinessException("INVALID_VIBE", "Vibe must be QUIET, BALANCED, or LIVELY.");
            }
            venue.setVibe(vibe);
        } else if (creating) {
            venue.setVibe("BALANCED");
        }
        if (request.photoUrls() != null) {
            venue.setPhotoUrls(request.photoUrls().stream()
                    .filter(u -> u != null && !u.isBlank())
                    .map(String::trim)
                    .limit(6)
                    .toList());
        } else if (creating) {
            venue.setPhotoUrls(List.of());
        }
        if (request.verified() != null) {
            venue.setVerified(request.verified());
        } else if (creating) {
            venue.setVerified(true);
        }
        return venue;
    }

    private AdminDtos.VenueAdminResponse toResponse(VenueEntity v) {
        return new AdminDtos.VenueAdminResponse(
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
                v.isActive(),
                v.getPartnerUserId() == null ? null : v.getPartnerUserId().toString(),
                v.getArea(),
                v.getPriceBand(),
                v.getVibe(),
                v.getPhotoUrls() == null ? List.of() : List.copyOf(v.getPhotoUrls()),
                v.isVerified()
        );
    }

    private void validatePartner(UUID partnerUserId) {
        if (partnerUserId == null) {
            throw new BusinessException("PARTNER_USER_REQUIRED", "Venue partner user is required.");
        }
        boolean isVenuePartner = userRepository.findById(partnerUserId)
                .map(user -> user.getRole() == UserRole.VENUE_PARTNER)
                .orElse(false);
        if (!isVenuePartner) {
            throw new BusinessException("INVALID_VENUE_PARTNER", "User must have the VENUE_PARTNER role.");
        }
    }

    private static String blankToNull(String s) {
        return s == null || s.isBlank() ? null : s.trim();
    }
}
