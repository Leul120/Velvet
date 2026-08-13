package com.velvet.api.booking.service;

import com.velvet.api.booking.domain.AvailabilityWindowEntity;
import com.velvet.api.booking.repo.AvailabilityWindowRepository;
import com.velvet.api.booking.web.dto.AvailabilityDtos;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.identity.domain.Gender;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.repo.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class AvailabilityService {

    public static final Duration SESSION_DURATION = Duration.ofHours(3);
    public static final Duration OVERNIGHT_DURATION = Duration.ofHours(12);
    private static final Duration MAX_WINDOW = Duration.ofDays(3);
    private static final int MAX_UPCOMING = 60;

    private final AvailabilityWindowRepository windowRepository;
    private final UserRepository userRepository;

    public AvailabilityService(
            AvailabilityWindowRepository windowRepository,
            UserRepository userRepository
    ) {
        this.windowRepository = windowRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public AvailabilityDtos.WindowsResponse listMine(UUID userId) {
        requirePerformer(userId);
        return new AvailabilityDtos.WindowsResponse(upcoming(userId));
    }

    @Transactional(readOnly = true)
    public AvailabilityDtos.WindowsResponse listPublic(UUID performerId) {
        requirePerformer(performerId);
        return new AvailabilityDtos.WindowsResponse(upcoming(performerId));
    }

    @Transactional
    public AvailabilityDtos.WindowResponse create(UUID userId, AvailabilityDtos.CreateWindowRequest request) {
        requirePerformer(userId);
        Instant starts = request.startsAt();
        Instant ends = request.endsAt();
        if (!ends.isAfter(starts)) {
            throw new BusinessException("INVALID_WINDOW", "End time must be after start time.");
        }
        if (Duration.between(starts, ends).compareTo(MAX_WINDOW) > 0) {
            throw new BusinessException("WINDOW_TOO_LONG", "Availability windows may be at most 3 days.");
        }
        if (Duration.between(starts, ends).compareTo(Duration.ofMinutes(30)) < 0) {
            throw new BusinessException("WINDOW_TOO_SHORT", "Availability windows must be at least 30 minutes.");
        }
        long upcoming = windowRepository.countByUserIdAndEndsAtAfter(userId, Instant.now());
        if (upcoming >= MAX_UPCOMING) {
            throw new BusinessException("WINDOW_LIMIT", "Too many upcoming windows. Remove old ones first.");
        }

        AvailabilityWindowEntity saved = windowRepository.save(AvailabilityWindowEntity.builder()
                .userId(userId)
                .startsAt(starts)
                .endsAt(ends)
                .note(blankToNull(request.note()))
                .build());
        return toResponse(saved);
    }

    @Transactional
    public void delete(UUID userId, UUID windowId) {
        requirePerformer(userId);
        AvailabilityWindowEntity window = windowRepository.findById(windowId)
                .orElseThrow(() -> new BusinessException("WINDOW_NOT_FOUND", "Availability window not found."));
        if (!window.getUserId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not your availability window.");
        }
        windowRepository.delete(window);
    }

    /**
     * Booking start must fall inside a published window that covers the full booking duration.
     */
    @Transactional(readOnly = true)
    public void requireCovered(UUID performerId, Instant startsAt, String rateType) {
        Instant endsAt = startsAt.plus(durationFor(rateType));
        long upcoming = windowRepository.countByUserIdAndEndsAtAfter(performerId, Instant.now().minus(Duration.ofHours(1)));
        if (upcoming == 0) {
            throw new BusinessException(
                    "AVAILABILITY_REQUIRED",
                    "Performer has not published availability windows yet."
            );
        }
        if (!windowRepository.coversRange(performerId, startsAt, endsAt)) {
            throw new BusinessException(
                    "OUTSIDE_AVAILABILITY",
                    "That time is outside the performer's published availability."
            );
        }
    }

    public static Duration durationFor(String rateType) {
        if (rateType != null && rateType.trim().equalsIgnoreCase("OVERNIGHT")) {
            return OVERNIGHT_DURATION;
        }
        return SESSION_DURATION;
    }

    private List<AvailabilityDtos.WindowResponse> upcoming(UUID userId) {
        return windowRepository.findByUserIdAndEndsAtAfterOrderByStartsAtAsc(userId, Instant.now())
                .stream()
                .limit(40)
                .map(this::toResponse)
                .toList();
    }

    private AvailabilityDtos.WindowResponse toResponse(AvailabilityWindowEntity entity) {
        return new AvailabilityDtos.WindowResponse(
                entity.getId().toString(),
                entity.getStartsAt(),
                entity.getEndsAt(),
                entity.getNote()
        );
    }

    private void requirePerformer(UUID userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getRole() != UserRole.PERFORMER) {
            throw new BusinessException("PERFORMER_ONLY", "Availability calendar is for performers.");
        }
    }

    private static String blankToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
