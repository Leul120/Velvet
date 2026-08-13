package com.velvet.api.notify.repo;

import com.velvet.api.notify.domain.MemberNotificationEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface MemberNotificationRepository extends JpaRepository<MemberNotificationEntity, UUID> {
    List<MemberNotificationEntity> findTop50ByUserIdOrderByCreatedAtDesc(UUID userId);

    List<MemberNotificationEntity> findTop50ByUserIdAndReadAtIsNullOrderByCreatedAtDesc(UUID userId);

    long countByUserIdAndReadAtIsNull(UUID userId);

    List<MemberNotificationEntity> findByUserIdAndReadAtIsNull(UUID userId);
}
