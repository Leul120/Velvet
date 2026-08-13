package com.velvet.api.notify;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface NotificationOutboxRepository extends JpaRepository<NotificationOutboxEntity, UUID> {
    List<NotificationOutboxEntity> findTop50ByOrderByCreatedAtDesc();
}
