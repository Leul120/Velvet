package com.velvet.api.verification.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.verification.service.VerificationService;
import com.velvet.api.verification.web.dto.VerificationDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/verification")
public class VerificationController {

    private final VerificationService verificationService;

    public VerificationController(VerificationService verificationService) {
        this.verificationService = verificationService;
    }

    @PostMapping
    public ResponseEntity<VerificationDtos.VerificationResponse> submit(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody VerificationDtos.SubmitRequest request
    ) {
        return ResponseEntity.ok(verificationService.submit(principal.getUserId(), request));
    }

    @GetMapping("/me")
    public ResponseEntity<VerificationDtos.VerificationResponse> me(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(verificationService.myLatest(principal.getUserId()));
    }
}
