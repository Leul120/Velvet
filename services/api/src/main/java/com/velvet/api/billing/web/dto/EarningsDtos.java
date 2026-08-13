package com.velvet.api.billing.web.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;

public final class EarningsDtos {

    private EarningsDtos() {}

    public record BalanceResponse(
            BigDecimal availableEtb,
            BigDecimal lifetimeEarnedEtb,
            BigDecimal lifetimePaidOutEtb,
            int platformFeePercent,
            List<LedgerItem> recent,
            List<PayoutItem> payouts
    ) {}

    public record LedgerItem(
            String id,
            String entryType,
            BigDecimal amountEtb,
            String description,
            String bookingId,
            Instant createdAt
    ) {}

    public record PayoutItem(
            String id,
            BigDecimal amountEtb,
            String status,
            String destinationNote,
            Instant createdAt,
            Instant processedAt
    ) {}

    public record AdminPayoutItem(
            String id,
            String userId,
            String displayName,
            String phone,
            BigDecimal amountEtb,
            String status,
            String destinationNote,
            String adminNotes,
            Instant createdAt,
            Instant processedAt
    ) {}

    public record PayoutDecisionRequest(
            @Size(max = 500) String notes
    ) {}

    public record PayoutRequest(
            @NotNull @DecimalMin("50.00") BigDecimal amountEtb,
            @Size(max = 280) String destinationNote
    ) {}
}
