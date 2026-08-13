package com.velvet.api.chat.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "messages")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessageEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "thread_id", nullable = false)
    private UUID threadId;

    @Column(name = "sender_id", nullable = false)
    private UUID senderId;

    @Column(columnDefinition = "TEXT")
    @Builder.Default
    private String body = "";

    @Column(name = "media_type", length = 16)
    private String mediaType;

    @Column(name = "media_url", columnDefinition = "TEXT")
    private String mediaUrl;

    @Column(name = "media_name", length = 255)
    private String mediaName;

    @Column(name = "media_mime", length = 120)
    private String mediaMime;

    @Enumerated(EnumType.STRING)
    @Column(name = "moderation_status", nullable = false, length = 32)
    @Builder.Default
    private ModerationStatus moderationStatus = ModerationStatus.ALLOWED;

    @JdbcTypeCode(SqlTypes.JSON)
    @Column(name = "moderation_flags", nullable = false, columnDefinition = "jsonb")
    @Builder.Default
    private List<String> moderationFlags = new ArrayList<>();

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    public boolean hasMedia() {
        return mediaUrl != null && !mediaUrl.isBlank();
    }
}
