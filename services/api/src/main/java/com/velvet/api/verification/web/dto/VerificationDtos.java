package com.velvet.api.verification.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.time.Instant;

public final class VerificationDtos {

    private VerificationDtos() {}

    public record SubmitRequest(
            @NotBlank @Size(max = 1024) String idDocumentUrl,
            @NotBlank @Size(max = 1024) String selfieUrl,
            @Size(max = 1000) String notes
    ) {}

    public record ReviewRequest(
            boolean approve,
            @Size(max = 1000) String notes
    ) {}

    public record VerificationResponse(
            String id,
            String userId,
            String status,
            String idDocumentUrl,
            String selfieUrl,
            String notes,
            Instant createdAt,
            Instant reviewedAt
    ) {}
}
