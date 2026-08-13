package com.velvet.api.billing.web;

import com.velvet.api.billing.service.EarningsService;
import com.velvet.api.billing.web.dto.EarningsDtos;
import com.velvet.api.identity.security.VelvetPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/v1/earnings")
public class EarningsController {

    private final EarningsService earningsService;

    public EarningsController(EarningsService earningsService) {
        this.earningsService = earningsService;
    }

    @GetMapping
    public ResponseEntity<EarningsDtos.BalanceResponse> summary(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        return ResponseEntity.ok(earningsService.summary(principal.getUserId()));
    }

    @PostMapping("/payout")
    public ResponseEntity<EarningsDtos.PayoutItem> requestPayout(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody EarningsDtos.PayoutRequest request
    ) {
        return ResponseEntity.ok(earningsService.requestPayout(principal.getUserId(), request));
    }
}
