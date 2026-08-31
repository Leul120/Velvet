package com.velvet.api.identity.repo;

import com.velvet.api.identity.domain.EmergencyContactEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface EmergencyContactRepository extends JpaRepository<EmergencyContactEntity, UUID> {
    List<EmergencyContactEntity> findByUserIdAndEnabledTrue(UUID userId);
    List<EmergencyContactEntity> findByUserId(UUID userId);
}
