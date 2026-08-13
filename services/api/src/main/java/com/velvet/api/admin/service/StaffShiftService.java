package com.velvet.api.admin.service;

import com.velvet.api.admin.domain.StaffShiftEntity;
import com.velvet.api.admin.repo.StaffShiftRepository;
import com.velvet.api.admin.web.dto.AdminDtos;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.repo.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class StaffShiftService {

    private final StaffShiftRepository shiftRepository;
    private final UserRepository userRepository;

    public StaffShiftService(StaffShiftRepository shiftRepository, UserRepository userRepository) {
        this.shiftRepository = shiftRepository;
        this.userRepository = userRepository;
    }

    @Transactional(readOnly = true)
    public List<AdminDtos.StaffShiftResponse> list() {
        return shiftRepository.findAllByOrderByStartsAtDesc().stream().map(this::toResponse).toList();
    }

    @Transactional(readOnly = true)
    public List<AdminDtos.StaffShiftResponse> onCall(Instant now) {
        return shiftRepository.findByStartsAtLessThanEqualAndEndsAtGreaterThanEqual(now, now).stream()
                .filter(StaffShiftEntity::isOnCall)
                .map(this::toResponse)
                .toList();
    }

    @Transactional
    public AdminDtos.StaffShiftResponse create(AdminDtos.CreateStaffShiftRequest request) {
        if (!request.endsAt().isAfter(request.startsAt())) {
            throw new BusinessException("INVALID_SHIFT_WINDOW", "Shift end time must be after its start time.");
        }
        UserEntity user = userRepository.findById(request.userId())
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (user.getRole() != UserRole.ADMIN && user.getRole() != UserRole.CONCIERGE) {
            throw new BusinessException("INVALID_SHIFT_USER", "Shifts can only be assigned to admins or concierges.");
        }
        StaffShiftEntity shift = shiftRepository.save(StaffShiftEntity.builder()
                .userId(request.userId())
                .startsAt(request.startsAt())
                .endsAt(request.endsAt())
                .roleLabel(request.roleLabel() == null || request.roleLabel().isBlank()
                        ? user.getRole().name()
                        : request.roleLabel().trim())
                .onCall(request.onCall() == null || request.onCall())
                .notes(request.notes())
                .build());
        return toResponse(shift);
    }

    @Transactional
    public void delete(UUID id) {
        if (!shiftRepository.existsById(id)) {
            throw new BusinessException("SHIFT_NOT_FOUND", "Staff shift not found.");
        }
        shiftRepository.deleteById(id);
    }

    private AdminDtos.StaffShiftResponse toResponse(StaffShiftEntity shift) {
        return new AdminDtos.StaffShiftResponse(
                shift.getId().toString(),
                shift.getUserId().toString(),
                shift.getStartsAt(),
                shift.getEndsAt(),
                shift.getRoleLabel(),
                shift.isOnCall(),
                shift.getNotes() == null ? "" : shift.getNotes(),
                shift.getCreatedAt()
        );
    }
}
