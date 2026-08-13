package com.velvet.api.identity.repo;

import com.velvet.api.identity.domain.RefreshTokenEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface RefreshTokenRepository extends JpaRepository<RefreshTokenEntity, UUID> {
    Optional<RefreshTokenEntity> findByTokenHashAndRevokedFalse(String tokenHash);

    List<RefreshTokenEntity> findByUserIdAndRevokedFalse(UUID userId);
}
