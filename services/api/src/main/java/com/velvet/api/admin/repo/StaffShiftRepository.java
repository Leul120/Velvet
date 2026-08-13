package com.velvet.api.admin.repo;

import com.velvet.api.admin.domain.StaffShiftEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface StaffShiftRepository extends JpaRepository<StaffShiftEntity, UUID> {
    List<StaffShiftEntity> findByStartsAtLessThanEqualAndEndsAtGreaterThanEqual(Instant startsAt, Instant endsAt);

    List<StaffShiftEntity> findAllByOrderByStartsAtDesc();

    List<StaffShiftEntity> findByUserIdOrderByStartsAtDesc(UUID userId);
}
