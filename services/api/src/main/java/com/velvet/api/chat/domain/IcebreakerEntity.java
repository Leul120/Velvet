package com.velvet.api.chat.domain;

import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

@Entity
@Table(name = "icebreakers")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class IcebreakerEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(name = "text_en", nullable = false, columnDefinition = "TEXT")
    private String textEn;

    @Column(name = "text_am", nullable = false, columnDefinition = "TEXT")
    private String textAm;

    @Column(nullable = false)
    @Builder.Default
    private boolean active = true;
}
