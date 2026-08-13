package com.velvet.api.billing.repo;

import com.velvet.api.billing.domain.PaymentIntentEntity;
import com.velvet.api.billing.domain.PaymentStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PaymentIntentRepository extends JpaRepository<PaymentIntentEntity, UUID> {
    Optional<PaymentIntentEntity> findByMerchantOrderId(String merchantOrderId);

    Optional<PaymentIntentEntity> findByProviderAndProviderRefIgnoreCase(String provider, String providerRef);

    Optional<PaymentIntentEntity> findFirstByUserIdAndProviderAndStatusInOrderByCreatedAtDesc(
            UUID userId, String provider, Collection<PaymentStatus> statuses
    );

    Optional<PaymentIntentEntity> findFirstByUserIdAndPurposeAndProviderAndStatusInOrderByCreatedAtDesc(
            UUID userId,
            String purpose,
            String provider,
            Collection<PaymentStatus> statuses
    );

    /**
     * Returns the most-recent non-expired CBE/Telebirr intent for a specific booking.
     * Used to restore the payment panel on booking screen resume.
     */
    Optional<PaymentIntentEntity> findFirstByBookingIdAndStatusInOrderByCreatedAtDesc(
            UUID bookingId, Collection<PaymentStatus> statuses
    );

    List<PaymentIntentEntity> findByBookingIdAndStatusIn(UUID bookingId, Collection<PaymentStatus> statuses);

    /** Admin: all payment intents, newest first, optionally filtered by status. */
    Page<PaymentIntentEntity> findAllByOrderByCreatedAtDesc(Pageable pageable);

    Page<PaymentIntentEntity> findAllByStatusOrderByCreatedAtDesc(PaymentStatus status, Pageable pageable);

    List<PaymentIntentEntity> findAllByStatusInOrderByCreatedAtDesc(Collection<PaymentStatus> statuses);
}
