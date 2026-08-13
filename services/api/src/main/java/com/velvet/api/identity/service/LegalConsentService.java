package com.velvet.api.identity.service;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.audit.AuditService;
import com.velvet.api.common.config.VelvetProperties;
import com.velvet.api.identity.domain.LegalAcceptanceEntity;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.repo.LegalAcceptanceRepository;
import com.velvet.api.identity.repo.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.Map;
import java.util.UUID;

@Service
public class LegalConsentService {

    private final VelvetProperties properties;
    private final UserRepository userRepository;
    private final LegalAcceptanceRepository legalAcceptanceRepository;
    private final AuditService auditService;

    public LegalConsentService(
            VelvetProperties properties,
            UserRepository userRepository,
            LegalAcceptanceRepository legalAcceptanceRepository,
            AuditService auditService
    ) {
        this.properties = properties;
        this.userRepository = userRepository;
        this.legalAcceptanceRepository = legalAcceptanceRepository;
        this.auditService = auditService;
    }

    public String currentVersion() {
        String v = properties.legal() == null ? null : properties.legal().documentSetVersion();
        return (v == null || v.isBlank()) ? "v1-2026-08" : v.trim();
    }

    public boolean hasAcceptedCurrent(UserEntity user) {
        return currentVersion().equals(user.getLegalAcceptedVersion());
    }

    @Transactional
    public void acceptCurrent(UUID userId, String requestedVersion, String source) {
        String current = currentVersion();
        if (requestedVersion == null || requestedVersion.isBlank() || !current.equals(requestedVersion.trim())) {
            throw new BusinessException(
                    "LEGAL_VERSION_MISMATCH",
                    "Accept legal document set version " + current + "."
            );
        }
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        Instant now = Instant.now();
        user.setLegalAcceptedVersion(current);
        user.setLegalAcceptedAt(now);
        userRepository.save(user);

        if (legalAcceptanceRepository.findByUserIdAndDocumentSetVersion(userId, current).isEmpty()) {
            legalAcceptanceRepository.save(LegalAcceptanceEntity.builder()
                    .userId(userId)
                    .documentSetVersion(current)
                    .source(source == null || source.isBlank() ? "APP" : source.trim())
                    .build());
        }
        auditService.log(userId, "LEGAL_ACCEPT", "LEGAL", current, Map.of("version", current));
    }

    /** Used during registration: version must match before/at verify. */
    public void requireAcceptedVersionOrThrow(String acceptedLegalVersion) {
        String current = currentVersion();
        if (acceptedLegalVersion == null || acceptedLegalVersion.isBlank() || !current.equals(acceptedLegalVersion.trim())) {
            throw new BusinessException(
                    "LEGAL_CONSENT_REQUIRED",
                    "You must accept Terms, Privacy Policy, and Community Guidelines (version " + current + ")."
            );
        }
    }
}
