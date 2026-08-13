package com.velvet.api.identity.repo;

import com.velvet.api.identity.domain.InviteEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface InviteRepository extends JpaRepository<InviteEntity, UUID> {
    Optional<InviteEntity> findByCodeIgnoreCase(String code);

    List<InviteEntity> findAllByOrderByCreatedAtDesc();
}
