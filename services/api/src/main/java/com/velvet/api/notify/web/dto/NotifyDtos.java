package com.velvet.api.notify.web.dto;

import java.time.Instant;

public final class NotifyDtos {

    private NotifyDtos() {}

    public record NotificationResponse(
            String id,
            String subject,
            String body,
            String relatedType,
            String relatedId,
            boolean read,
            Instant createdAt
    ) {}
}
