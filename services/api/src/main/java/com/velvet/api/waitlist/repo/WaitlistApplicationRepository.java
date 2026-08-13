package com.velvet.api.waitlist.repo;

import com.velvet.api.waitlist.domain.WaitlistApplicationEntity;
import com.velvet.api.waitlist.domain.WaitlistStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface WaitlistApplicationRepository extends JpaRepository<WaitlistApplicationEntity, UUID> {
    List<WaitlistApplicationEntity> findByStatusOrderByCreatedAtDesc(WaitlistStatus status);

    Optional<WaitlistApplicationEntity> findByPhoneE164(String phoneE164);

    List<WaitlistApplicationEntity> findAllByOrderByCreatedAtDesc();

    long countByStatus(WaitlistStatus status);
}
