package com.velvet.api.discover.domain;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "member_likes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberLikeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "from_user_id", nullable = false)
    private UUID fromUserId;

    @Column(name = "to_user_id", nullable = false)
    private UUID toUserId;

    @Column(nullable = false, length = 16)
    private String action;

    /** 0-based index into the counterpart's photo_urls when action is LIKE. */
    @Column(name = "liked_photo_index")
    private Integer likedPhotoIndex;

    /** e.g. bio_en / bio_am when they liked a prompt. */
    @Column(name = "liked_prompt_key", length = 64)
    private String likedPromptKey;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;
}
