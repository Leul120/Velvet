package com.velvet.api.billing.web.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;

public final class BillingDtos {

    private BillingDtos() {}

    public record PlanResponse(
            String id,
            String code,
            String nameEn,
            String nameAm,
            BigDecimal priceEtb,
            int matchQuota,
            int durationDays
    ) {}

    public record SubscribeRequest(
            @NotBlank String planCode
    ) {}

    public record BookingPayRequest(
            @Size(max = 16) String provider
    ) {}

    public record CbeInstructions(
            String accountName,
            String accountNumber,
            String accountSuffix,
            String bankName,
            String transferNote
    ) {}

    public record CheckoutResponse(
            String paymentIntentId,
            String merchantOrderId,
            String checkoutUrl,
            String provider,
            BigDecimal amountEtb,
            String currency,
            String status,
            boolean mock,
            CbeInstructions cbe
    ) {}

    public record CbeProofRequest(
            @Size(max = 64) String reference,
            @Size(max = 16) String accountSuffix
    ) {}

    public record SubscriptionResponse(
            String id,
            String planCode,
            String planNameEn,
            String status,
            Instant startsAt,
            Instant endsAt,
            int matchQuota,
            int connectionsUsed
    ) {}

    // ── Admin ────────────────────────────────────────────────────────────────

    public record PaymentIntentAdminItem(
            String id,
            String userId,
            String userName,
            String userPhone,
            String userRole,
            String purpose,
            String bookingId,
            String provider,
            String merchantOrderId,
            BigDecimal amountEtb,
            String currency,
            String status,
            String receiptUrl,
            String providerRef,
            Instant createdAt,
            Instant paidAt
    ) {}


    public record AdminPaymentDecisionRequest(
            @Size(max = 256) String notes
    ) {}
}
