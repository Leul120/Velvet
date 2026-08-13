package com.velvet.api.chat.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "chat_threads")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatThreadEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "connection_id", nullable = false, unique = true)
    private UUID connectionId;

    @Column(name = "member_a_id", nullable = false)
    private UUID memberAId;

    @Column(name = "member_b_id", nullable = false)
    private UUID memberBId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    @Builder.Default
    private ThreadStatus status = ThreadStatus.OPEN;

    @Column(name = "a_last_read_at")
    private Instant aLastReadAt;

    @Column(name = "b_last_read_at")
    private Instant bLastReadAt;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
