package com.velvet.api.notify.repo;

import com.velvet.api.notify.domain.DeviceTokenEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface DeviceTokenRepository extends JpaRepository<DeviceTokenEntity, UUID> {
    Optional<DeviceTokenEntity> findByToken(String token);

    List<DeviceTokenEntity> findByUserIdAndActiveTrue(UUID userId);

    List<DeviceTokenEntity> findByUserIdInAndActiveTrue(Collection<UUID> userIds);

    List<DeviceTokenEntity> findByUserId(UUID userId);
}
