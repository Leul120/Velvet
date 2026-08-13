package com.velvet.api.billing.service;

import com.velvet.api.billing.domain.LedgerEntryEntity;
import com.velvet.api.billing.domain.PaymentIntentEntity;
import com.velvet.api.billing.domain.PayoutRequestEntity;
import com.velvet.api.billing.repo.LedgerEntryRepository;
import com.velvet.api.billing.repo.PayoutRequestRepository;
import com.velvet.api.billing.web.dto.EarningsDtos;
import com.velvet.api.booking.domain.BookingEntity;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.identity.domain.Gender;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.repo.ConnectionRepository;
import com.velvet.api.notify.ConciergeNotifyService;
import com.velvet.api.notify.MemberNotifyService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
public class EarningsService {

    /** Platform cut of each paid booking (performer receives the rest). */
    public static final int PLATFORM_FEE_PERCENT = 15;

    private final LedgerEntryRepository ledgerEntryRepository;
    private final PayoutRequestRepository payoutRequestRepository;
    private final UserRepository userRepository;
    private final ConnectionRepository connectionRepository;
    private final ConciergeNotifyService conciergeNotifyService;
    private final MemberNotifyService memberNotifyService;

    public EarningsService(
            LedgerEntryRepository ledgerEntryRepository,
            PayoutRequestRepository payoutRequestRepository,
            UserRepository userRepository,
            ConnectionRepository connectionRepository,
            ConciergeNotifyService conciergeNotifyService,
            MemberNotifyService memberNotifyService
    ) {
        this.ledgerEntryRepository = ledgerEntryRepository;
        this.payoutRequestRepository = payoutRequestRepository;
        this.userRepository = userRepository;
        this.connectionRepository = connectionRepository;
        this.conciergeNotifyService = conciergeNotifyService;
        this.memberNotifyService = memberNotifyService;
    }

    /**
     * After a booking payment succeeds: credit the performer and record the platform fee.
     * Idempotent per booking (unique PERFORMER_CREDIT per booking_id).
     */
    @Transactional
    public void creditPerformerForPaidBooking(BookingEntity booking, PaymentIntentEntity intent) {
        if (booking == null || intent == null || intent.getAmountEtb() == null) {
            return;
        }
        if (ledgerEntryRepository.existsByBookingIdAndEntryType(booking.getId(), "PERFORMER_CREDIT")) {
            return;
        }
        UUID performerId = resolvePerformerId(booking);
        if (performerId == null) {
            return;
        }

        BigDecimal gross = intent.getAmountEtb().setScale(2, RoundingMode.HALF_UP);
        BigDecimal fee = gross.multiply(BigDecimal.valueOf(PLATFORM_FEE_PERCENT))
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
        BigDecimal net = gross.subtract(fee);
        if (net.compareTo(BigDecimal.ZERO) < 0) {
            net = BigDecimal.ZERO;
        }

        ledgerEntryRepository.save(LedgerEntryEntity.builder()
                .userId(performerId)
                .paymentIntentId(intent.getId())
                .bookingId(booking.getId())
                .entryType("PERFORMER_CREDIT")
                .amountEtb(net)
                .currency("ETB")
                .description("Booking credit (" + (100 - PLATFORM_FEE_PERCENT) + "% of " + gross.toPlainString() + " ETB)")
                .build());

        ledgerEntryRepository.save(LedgerEntryEntity.builder()
                .userId(null)
                .paymentIntentId(intent.getId())
                .bookingId(booking.getId())
                .entryType("PLATFORM_FEE")
                .amountEtb(fee)
                .currency("ETB")
                .description("Platform fee " + PLATFORM_FEE_PERCENT + "% booking " + booking.getId())
                .build());
    }

    /** Reconcile legacy early credits once the corresponding booking refund is completed. */
    @Transactional
    public void reversePerformerCreditForRefund(BookingEntity booking, PaymentIntentEntity intent) {
        if (booking == null || intent == null
                || ledgerEntryRepository.existsByBookingIdAndEntryType(booking.getId(), "PERFORMER_CREDIT_REVERSAL")) {
            return;
        }
        ledgerEntryRepository.findFirstByBookingIdAndEntryType(booking.getId(), "PERFORMER_CREDIT")
                .ifPresent(credit -> ledgerEntryRepository.save(LedgerEntryEntity.builder()
                        .userId(credit.getUserId())
                        .paymentIntentId(intent.getId())
                        .bookingId(booking.getId())
                        .entryType("PERFORMER_CREDIT_REVERSAL")
                        .amountEtb(credit.getAmountEtb())
                        .currency(credit.getCurrency())
                        .description("Booking refund — performer credit reversed")
                        .build()));
    }

    @Transactional(readOnly = true)
    public EarningsDtos.BalanceResponse summary(UUID userId) {
        requirePerformer(userId);
        BigDecimal available = ledgerEntryRepository.balanceFor(userId).setScale(2, RoundingMode.HALF_UP);
        List<LedgerEntryEntity> entries = ledgerEntryRepository.findByUserIdOrderByCreatedAtDesc(userId);
        BigDecimal earned = entries.stream()
                .filter(e -> "PERFORMER_CREDIT".equals(e.getEntryType()))
                .map(LedgerEntryEntity::getAmountEtb)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal paidOut = entries.stream()
                .filter(e -> "PERFORMER_PAYOUT".equals(e.getEntryType()))
                .map(LedgerEntryEntity::getAmountEtb)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        BigDecimal reversed = entries.stream()
                .filter(e -> "PERFORMER_PAYOUT_REVERSAL".equals(e.getEntryType()))
                .map(LedgerEntryEntity::getAmountEtb)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
        paidOut = paidOut.subtract(reversed);
        if (paidOut.compareTo(BigDecimal.ZERO) < 0) {
            paidOut = BigDecimal.ZERO;
        }

        List<EarningsDtos.LedgerItem> recent = entries.stream()
                .limit(40)
                .map(e -> new EarningsDtos.LedgerItem(
                        e.getId().toString(),
                        e.getEntryType(),
                        e.getAmountEtb(),
                        e.getDescription(),
                        e.getBookingId() == null ? null : e.getBookingId().toString(),
                        e.getCreatedAt()
                ))
                .toList();

        List<EarningsDtos.PayoutItem> payouts = payoutRequestRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .limit(20)
                .map(p -> new EarningsDtos.PayoutItem(
                        p.getId().toString(),
                        p.getAmountEtb(),
                        p.getStatus(),
                        p.getDestinationNote(),
                        p.getCreatedAt(),
                        p.getProcessedAt()
                ))
                .toList();

        return new EarningsDtos.BalanceResponse(
                available,
                earned.setScale(2, RoundingMode.HALF_UP),
                paidOut.setScale(2, RoundingMode.HALF_UP),
                PLATFORM_FEE_PERCENT,
                recent,
                payouts
        );
    }

    @Transactional
    public EarningsDtos.PayoutItem requestPayout(UUID userId, EarningsDtos.PayoutRequest request) {
        requirePerformer(userId);
        if (payoutRequestRepository.existsByUserIdAndStatus(userId, "REQUESTED")) {
            throw new BusinessException("PAYOUT_PENDING", "You already have a payout request in progress.");
        }
        BigDecimal amount = request.amountEtb().setScale(2, RoundingMode.HALF_UP);
        BigDecimal available = ledgerEntryRepository.balanceFor(userId).setScale(2, RoundingMode.HALF_UP);
        if (amount.compareTo(available) > 0) {
            throw new BusinessException("INSUFFICIENT_BALANCE", "Requested amount exceeds available balance.");
        }

        LedgerEntryEntity debit = ledgerEntryRepository.save(LedgerEntryEntity.builder()
                .userId(userId)
                .entryType("PERFORMER_PAYOUT")
                .amountEtb(amount)
                .currency("ETB")
                .description("Payout request")
                .build());

        PayoutRequestEntity payout = payoutRequestRepository.save(PayoutRequestEntity.builder()
                .userId(userId)
                .amountEtb(amount)
                .status("REQUESTED")
                .destinationNote(request.destinationNote() == null || request.destinationNote().isBlank()
                        ? null
                        : request.destinationNote().trim())
                .ledgerEntryId(debit.getId())
                .build());

        conciergeNotifyService.notifyOps(
                "VELVET performer payout request",
                "user=%s amount=%s ETB note=%s".formatted(
                        userId,
                        amount.toPlainString(),
                        payout.getDestinationNote() == null ? "-" : payout.getDestinationNote()),
                "PERFORMER_PAYOUT",
                payout.getId().toString()
        );

        return toPayoutItem(payout);
    }

    @Transactional(readOnly = true)
    public List<EarningsDtos.AdminPayoutItem> adminQueue(String status) {
        String filter = status == null || status.isBlank() ? "REQUESTED" : status.trim().toUpperCase();
        return payoutRequestRepository.findByStatusOrderByCreatedAtAsc(filter).stream()
                .map(this::toAdminItem)
                .toList();
    }

    @Transactional
    public EarningsDtos.AdminPayoutItem completePayout(UUID payoutId, UUID staffId, String notes) {
        PayoutRequestEntity payout = requireRequested(payoutId);
        payout.setStatus("PAID");
        payout.setProcessedAt(Instant.now());
        payout.setProcessedBy(staffId);
        if (notes != null && !notes.isBlank()) {
            payout.setAdminNotes(notes.trim());
        }
        payoutRequestRepository.save(payout);

        memberNotifyService.notifyUser(
                payout.getUserId(),
                "Payout sent",
                payout.getAmountEtb().toPlainString() + " ETB was marked paid.",
                "PERFORMER_PAYOUT",
                payout.getId().toString()
        );
        return toAdminItem(payout);
    }

    @Transactional
    public EarningsDtos.AdminPayoutItem rejectPayout(UUID payoutId, UUID staffId, String notes) {
        PayoutRequestEntity payout = requireRequested(payoutId);
        payout.setStatus("REJECTED");
        payout.setProcessedAt(Instant.now());
        payout.setProcessedBy(staffId);
        payout.setAdminNotes(notes == null || notes.isBlank() ? "Rejected by ops" : notes.trim());
        payoutRequestRepository.save(payout);

        // Restore balance — debit was applied at request time.
        ledgerEntryRepository.save(LedgerEntryEntity.builder()
                .userId(payout.getUserId())
                .entryType("PERFORMER_PAYOUT_REVERSAL")
                .amountEtb(payout.getAmountEtb())
                .currency("ETB")
                .description("Payout rejected — balance restored")
                .build());

        memberNotifyService.notifyUser(
                payout.getUserId(),
                "Payout rejected",
                "Your payout request was rejected. The amount is back in your available balance.",
                "PERFORMER_PAYOUT",
                payout.getId().toString()
        );
        return toAdminItem(payout);
    }

    private PayoutRequestEntity requireRequested(UUID payoutId) {
        PayoutRequestEntity payout = payoutRequestRepository.findById(payoutId)
                .orElseThrow(() -> new BusinessException("PAYOUT_NOT_FOUND", "Payout request not found."));
        if (!"REQUESTED".equals(payout.getStatus())) {
            throw new BusinessException("PAYOUT_CLOSED", "Payout is already " + payout.getStatus() + ".");
        }
        return payout;
    }

    private EarningsDtos.PayoutItem toPayoutItem(PayoutRequestEntity payout) {
        return new EarningsDtos.PayoutItem(
                payout.getId().toString(),
                payout.getAmountEtb(),
                payout.getStatus(),
                payout.getDestinationNote(),
                payout.getCreatedAt(),
                payout.getProcessedAt()
        );
    }

    private EarningsDtos.AdminPayoutItem toAdminItem(PayoutRequestEntity payout) {
        UserEntity user = userRepository.findById(payout.getUserId()).orElse(null);
        return new EarningsDtos.AdminPayoutItem(
                payout.getId().toString(),
                payout.getUserId().toString(),
                user == null ? null : user.getDisplayName(),
                user == null ? null : user.getPhoneE164(),
                payout.getAmountEtb(),
                payout.getStatus(),
                payout.getDestinationNote(),
                payout.getAdminNotes(),
                payout.getCreatedAt(),
                payout.getProcessedAt()
        );
    }

    private UUID resolvePerformerId(BookingEntity booking) {
        ConnectionEntity match = connectionRepository.findById(booking.getConnectionId()).orElse(null);
        if (match == null) {
            return null;
        }
        UserEntity a = userRepository.findById(match.getMemberAId()).orElse(null);
        UserEntity b = userRepository.findById(match.getMemberBId()).orElse(null);
        if (isPerformer(a)) {
            return a.getId();
        }
        if (isPerformer(b)) {
            return b.getId();
        }
        if (a != null && a.getGender() == Gender.FEMALE) {
            return a.getId();
        }
        if (b != null && b.getGender() == Gender.FEMALE) {
            return b.getId();
        }
        return null;
    }

    private void requirePerformer(UUID userId) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (!isPerformer(user)) {
            throw new BusinessException("PERFORMER_ONLY", "Earnings are available to performers.");
        }
    }

    private static boolean isPerformer(UserEntity user) {
        return user != null && user.getRole() == UserRole.PERFORMER;
    }
}
