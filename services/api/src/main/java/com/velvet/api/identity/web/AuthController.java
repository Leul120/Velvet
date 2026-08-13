package com.velvet.api.identity.web;

import com.velvet.api.identity.service.AuthService;
import com.velvet.api.identity.web.dto.AuthDtos;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/otp/request")
    public ResponseEntity<AuthDtos.OtpRequestResponse> requestOtp(
            @Valid @RequestBody AuthDtos.OtpRequest request
    ) {
        return ResponseEntity.ok(authService.requestOtp(request));
    }

    @PostMapping("/otp/verify")
    public ResponseEntity<AuthDtos.TokenResponse> verifyOtp(
            @Valid @RequestBody AuthDtos.OtpVerifyRequest request
    ) {
        return ResponseEntity.ok(authService.verifyOtp(request));
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthDtos.TokenResponse> refresh(
            @Valid @RequestBody AuthDtos.RefreshRequest request
    ) {
        return ResponseEntity.ok(authService.refresh(request));
    }
}
