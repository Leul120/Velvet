package com.velvet.api.identity.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.identity.service.AuthService;
import com.velvet.api.identity.service.LegalConsentService;
import com.velvet.api.identity.web.dto.AuthDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/legal")
public class LegalController {

    private final LegalConsentService legalConsentService;
    private final AuthService authService;
    private final com.velvet.api.identity.repo.UserRepository userRepository;

    public LegalController(
            LegalConsentService legalConsentService,
            AuthService authService,
            com.velvet.api.identity.repo.UserRepository userRepository
    ) {
        this.legalConsentService = legalConsentService;
        this.authService = authService;
        this.userRepository = userRepository;
    }

    /** Public: current document set version for registration checkbox. */
    @GetMapping("/current")
    public ResponseEntity<AuthDtos.LegalStatusResponse> current() {
        String version = legalConsentService.currentVersion();
        return ResponseEntity.ok(new AuthDtos.LegalStatusResponse(
                version,
                false,
                "/legal/terms-en.html",
                "/legal/privacy-en.html",
                "/legal/community-en.html"
        ));
    }

    @GetMapping("/status")
    public ResponseEntity<AuthDtos.LegalStatusResponse> status(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        var user = userRepository.findById(principal.getUserId()).orElseThrow();
        String version = legalConsentService.currentVersion();
        return ResponseEntity.ok(new AuthDtos.LegalStatusResponse(
                version,
                legalConsentService.hasAcceptedCurrent(user),
                "/legal/terms-en.html",
                "/legal/privacy-en.html",
                "/legal/community-en.html"
        ));
    }

    @PostMapping("/accept")
    public ResponseEntity<AuthDtos.UserSummary> accept(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody AuthDtos.AcceptLegalRequest request
    ) {
        legalConsentService.acceptCurrent(principal.getUserId(), request.documentSetVersion(), "APP");
        var user = userRepository.findById(principal.getUserId()).orElseThrow();
        return ResponseEntity.ok(authService.toSummary(user));
    }
}
