package com.velvet.api.billing.domain;

public enum PaymentStatus {
    PENDING,
    CHECKOUT,
    PAID,
    FAILED,
    CANCELLED,
    EXPIRED,
    REFUND_PENDING,
    REFUNDED
}

