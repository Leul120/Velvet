package com.velvet.api.billing.service;

import com.velvet.api.billing.cbe.CbeVerifierClient;
import com.velvet.api.billing.domain.*;
import com.velvet.api.billing.repo.*;
import com.velvet.api.billing.telebirr.TelebirrClient;
import com.velvet.api.billing.telebirr.TelebirrNotifyVerifier;
import com.velvet.api.billing.web.dto.BillingDtos;
import com.velvet.api.booking.domain.BookingEntity;
import com.velvet.api.booking.domain.BookingStatus;
import com.velvet.api.booking.repo.BookingRepository;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import com.velvet.api.identity.domain.UserEntity;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.domain.UserStatus;
import com.velvet.api.identity.repo.UserRepository;
import com.velvet.api.matching.domain.ConnectionEntity;
import com.velvet.api.matching.repo.ConnectionRepository;
import com.velvet.api.storage.ObjectStorageService;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Service
public class BillingService {

    private static final org.slf4j.Logger log = org.slf4j.LoggerFactory.getLogger(BillingService.class);

    private final SubscriptionPlanRepository planRepository;
    private final PaymentIntentRepository paymentIntentRepository;
    private final SubscriptionRepository subscriptionRepository;
    private final LedgerEntryRepository ledgerEntryRepository;
    private final UserRepository userRepository;
    private final BookingRepository bookingRepository;
    private final ConnectionRepository connectionRepository;
    private final EarningsService earningsService;
    private final TelebirrClient telebirrClient;
    private final TelebirrNotifyVerifier notifyVerifier;
    private final CbeVerifierClient cbeVerifierClient;
    private final ObjectStorageService storageService;
    private final VelvetProperties properties;

    public BillingService(
            SubscriptionPlanRepository planRepository,
            PaymentIntentRepository paymentIntentRepository,
            SubscriptionRepository subscriptionRepository,
            LedgerEntryRepository ledgerEntryRepository,
            UserRepository userRepository,
            BookingRepository bookingRepository,
            ConnectionRepository connectionRepository,
            EarningsService earningsService,
            TelebirrClient telebirrClient,
            TelebirrNotifyVerifier notifyVerifier,
            CbeVerifierClient cbeVerifierClient,
            ObjectStorageService storageService,
            VelvetProperties properties
    ) {
        this.planRepository = planRepository;
        this.paymentIntentRepository = paymentIntentRepository;
        this.subscriptionRepository = subscriptionRepository;
        this.ledgerEntryRepository = ledgerEntryRepository;
        this.userRepository = userRepository;
        this.bookingRepository = bookingRepository;
        this.connectionRepository = connectionRepository;
        this.earningsService = earningsService;
        this.telebirrClient = telebirrClient;
        this.notifyVerifier = notifyVerifier;
        this.cbeVerifierClient = cbeVerifierClient;
        this.storageService = storageService;
        this.properties = properties;
    }

    @Transactional(readOnly = true)
    public List<BillingDtos.PlanResponse> listPlans() {
        return List.of();
    }

    @Transactional(readOnly = true)
    public BillingDtos.SubscriptionResponse currentSubscription(UUID userId) {
        return null;
    }

    /** Restores an unfinished CBE transfer after the member leaves the payment screen. */
    @Transactional(readOnly = true)
    public BillingDtos.CheckoutResponse pendingCbeCheckout(UUID userId) {
        return null;
    }

    @Transactional
    public BillingDtos.CheckoutResponse startBookingPayment(UUID userId, UUID bookingId) {
        BookingEntity booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking not found."));
        ConnectionEntity match = connectionRepository.findById(booking.getConnectionId())
                .orElseThrow(() -> new BusinessException("MATCH_NOT_FOUND", "Match not found."));
        if (!match.getMemberAId().equals(userId) && !match.getMemberBId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not a participant.");
        }
        UserEntity payer = userRepository.findById(userId)
                .orElseThrow(() -> new BusinessException("USER_NOT_FOUND", "User not found."));
        if (payer.getGender() != com.velvet.api.identity.domain.Gender.MALE
                || payer.getRole() == UserRole.PERFORMER) {
            throw new BusinessException("BOOKING_PAYER_REQUIRED", "Only the client may pay for a booking.");
        }
        if (booking.getStatus() != BookingStatus.CONFIRMED) {
            throw new BusinessException("BOOKING_NOT_CONFIRMED", "A booking must be confirmed before payment.");
        }
        if (!booking.getStartsAt().isAfter(Instant.now())) {
            throw new BusinessException("BOOKING_STARTED", "Cannot start payment after the booking start time.");
        }
        if ("PAID".equals(booking.getPaymentStatus()) || "WAIVED".equals(booking.getPaymentStatus())) {
            throw new BusinessException("BOOKING_ALREADY_PAID", "This booking is already paid.");
        }
        if (booking.getAmountEtb() == null || booking.getAmountEtb() <= 0) {
            throw new BusinessException("BOOKING_NO_AMOUNT", "This booking has no rate set — negotiate in chat first.");
        }
        if ("PENDING".equals(booking.getPaymentStatus())) {
            throw new BusinessException("BOOKING_PAYMENT_PENDING", "A payment is already awaiting verification.");
        }

        BigDecimal amount = BigDecimal.valueOf(booking.getAmountEtb()).setScale(2, RoundingMode.HALF_UP);
        String orderId = "VLB-" + UUID.randomUUID().toString().replace("-", "").substring(0, 20).toUpperCase();

        if (isCbeProvider()) {
            VelvetProperties.CbePayment pay = requireCbePaymentConfig();
            PaymentIntentEntity intent = paymentIntentRepository.save(PaymentIntentEntity.builder()
                    .userId(userId)
                    .planId(null)
                    .purpose("BOOKING")
                    .bookingId(booking.getId())
                    .provider("CBE")
                    .merchantOrderId(orderId)
                    .amountEtb(amount)
                    .currency("ETB")
                    .status(PaymentStatus.PENDING)
                    .build());
            intent.setStatus(PaymentStatus.CHECKOUT);
            paymentIntentRepository.save(intent);
            booking.setPaymentStatus("PENDING");
            booking.setPaymentIntentId(intent.getId());
            bookingRepository.save(booking);

            String note = "Transfer " + amount.toPlainString()
                    + " ETB to " + pay.accountName()
                    + " for booking. Put order " + orderId
                    + " in the reason, then upload your CBE receipt screenshot.";
            return new BillingDtos.CheckoutResponse(
                    intent.getId().toString(),
                    intent.getMerchantOrderId(),
                    null,
                    "CBE",
                    intent.getAmountEtb(),
                    intent.getCurrency(),
                    intent.getStatus().name(),
                    cbeVerifierClient.isMock(),
                    new BillingDtos.CbeInstructions(
                            pay.accountName(),
                            pay.accountNumber(),
                            pay.accountSuffix(),
                            blankTo(pay.bankName(), "Commercial Bank of Ethiopia"),
                            note
                    )
            );
        }

        PaymentIntentEntity intent = paymentIntentRepository.save(PaymentIntentEntity.builder()
                .userId(userId)
                .planId(null)
                .purpose("BOOKING")
                .bookingId(booking.getId())
                .provider("TELEBIRR")
                .merchantOrderId(orderId)
                .amountEtb(amount)
                .currency("ETB")
                .status(PaymentStatus.PENDING)
                .build());
        TelebirrClient.CheckoutResult checkout = telebirrClient.createCheckout(
                orderId, "VELVET booking", amount);
        intent.setCheckoutUrl(checkout.checkoutUrl());
        intent.setProviderRef(checkout.providerRef());
        intent.setStatus(PaymentStatus.CHECKOUT);
        paymentIntentRepository.save(intent);
        booking.setPaymentStatus("PENDING");
        booking.setPaymentIntentId(intent.getId());
        bookingRepository.save(booking);
        boolean mock = properties.telebirr() == null
                || "mock".equalsIgnoreCase(properties.telebirr().mode());
        return new BillingDtos.CheckoutResponse(
                intent.getId().toString(),
                intent.getMerchantOrderId(),
                intent.getCheckoutUrl(),
                "TELEBIRR",
                intent.getAmountEtb(),
                intent.getCurrency(),
                intent.getStatus().name(),
                mock,
                null
        );
    }

    @Transactional
    public BillingDtos.CheckoutResponse startSubscription(UUID userId, BillingDtos.SubscribeRequest request) {
        throw new BusinessException("SESSION_PAYMENTS_ONLY", "Membership checkout is retired. Payment is collected for each confirmed session.");
    }

    private BillingDtos.CheckoutResponse startCbeSubscription(UUID userId, BillingDtos.SubscribeRequest request) {
        SubscriptionPlanEntity plan = requirePlan(request.planCode());
        VelvetProperties.CbePayment pay = requireCbePaymentConfig();

        String orderId = "VLV-" + UUID.randomUUID().toString().replace("-", "").substring(0, 20).toUpperCase();
        PaymentIntentEntity intent = paymentIntentRepository.save(PaymentIntentEntity.builder()
                .userId(userId)
                .planId(plan.getId())
                .purpose("MEMBERSHIP")
                .provider("CBE")
                .merchantOrderId(orderId)
                .amountEtb(plan.getPriceEtb())
                .currency("ETB")
                .status(PaymentStatus.PENDING)
                .build());
        intent.setStatus(PaymentStatus.CHECKOUT);
        paymentIntentRepository.save(intent);

        String note = "Transfer " + plan.getPriceEtb().toPlainString()
                + " ETB to " + pay.accountName()
                + ". Put order " + orderId + " in the reason, then upload your CBE receipt screenshot.";

        return new BillingDtos.CheckoutResponse(
                intent.getId().toString(),
                intent.getMerchantOrderId(),
                null,
                "CBE",
                intent.getAmountEtb(),
                intent.getCurrency(),
                intent.getStatus().name(),
                cbeVerifierClient.isMock(),
                new BillingDtos.CbeInstructions(
                        pay.accountName(),
                        pay.accountNumber(),
                        pay.accountSuffix(),
                        blankTo(pay.bankName(), "Commercial Bank of Ethiopia"),
                        note
                )
        );
    }

    private BillingDtos.CheckoutResponse startTelebirrSubscription(UUID userId, BillingDtos.SubscribeRequest request) {
        SubscriptionPlanEntity plan = requirePlan(request.planCode());
        String orderId = "VLV-" + UUID.randomUUID().toString().replace("-", "").substring(0, 20).toUpperCase();
        PaymentIntentEntity intent = paymentIntentRepository.save(PaymentIntentEntity.builder()
                .userId(userId)
                .planId(plan.getId())
                .purpose("MEMBERSHIP")
                .provider("TELEBIRR")
                .merchantOrderId(orderId)
                .amountEtb(plan.getPriceEtb())
                .currency("ETB")
                .status(PaymentStatus.PENDING)
                .build());

        TelebirrClient.CheckoutResult checkout = telebirrClient.createCheckout(
                orderId,
                "VELVET " + plan.getCode() + " membership",
                plan.getPriceEtb()
        );
        intent.setCheckoutUrl(checkout.checkoutUrl());
        intent.setProviderRef(checkout.providerRef());
        intent.setStatus(PaymentStatus.CHECKOUT);
        paymentIntentRepository.save(intent);

        boolean mock = properties.telebirr() == null
                || "mock".equalsIgnoreCase(properties.telebirr().mode());
        return new BillingDtos.CheckoutResponse(
                intent.getId().toString(),
                intent.getMerchantOrderId(),
                intent.getCheckoutUrl(),
                "TELEBIRR",
                intent.getAmountEtb(),
                intent.getCurrency(),
                intent.getStatus().name(),
                mock,
                null
        );
    }

    /**
     * Submit a CBE receipt screenshot (and optional FT reference) for verifier-api confirmation.
     * <p>
     * Re-upload is allowed even after a prior rejected proof — the intent is reset back to
     * {@code CHECKOUT} so users can try again with a clearer screenshot. The intent is only
     * permanently {@code FAILED} if the verifier call itself throws (network error, bad key).
     * </p>
     */
    @Transactional
    public Object submitCbeProof(
            UUID userId,
            UUID paymentIntentId,
            MultipartFile receipt,
            String reference
    ) {
        PaymentIntentEntity intent = paymentIntentRepository.findById(paymentIntentId)
                .orElseThrow(() -> new BusinessException("PAYMENT_NOT_FOUND", "Unknown payment order."));
        if (!intent.getUserId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not your payment.");
        }
        if (!"CBE".equalsIgnoreCase(intent.getProvider())) {
            throw new BusinessException("WRONG_PROVIDER", "This payment is not a CBE transfer order.");
        }
        if (!"BOOKING".equals(intent.getPurpose())) {
            throw new BusinessException("SESSION_PAYMENTS_ONLY", "Membership payments are retired. Use the booking payment flow.");
        }
        if (intent.getStatus() == PaymentStatus.PAID) {
            if ("BOOKING".equals(intent.getPurpose())) {
                return toCheckout(intent, null);
            }
            return currentSubscription(userId);
        }
        // Allow retry even when status=FAILED (prior rejected proof); reset to CHECKOUT so the
        // duplicate-ref guard and amount-check run against fresh verifier output.
        if (intent.getStatus() != PaymentStatus.PENDING
                && intent.getStatus() != PaymentStatus.CHECKOUT
                && intent.getStatus() != PaymentStatus.FAILED) {
            throw new BusinessException("PAYMENT_CLOSED", "This payment can no longer accept proof.");
        }
        if (intent.getStatus() == PaymentStatus.FAILED) {
            intent.setStatus(PaymentStatus.CHECKOUT);
            paymentIntentRepository.save(intent);
        }

        VelvetProperties.CbePayment pay = requireCbePaymentConfig();
        String suffix = pay.accountSuffix();
        if (suffix == null || suffix.isBlank()) {
            throw new BusinessException("CBE_SUFFIX_REQUIRED", "CBE account suffix (last 8 digits) is required.");
        }

        CbeVerifierClient.VerificationResult verified;
        String receiptUrl = null;
        if (receipt != null && !receipt.isEmpty()) {
            receiptUrl = storageService.uploadPaymentReceipt(userId, receipt);
            intent.setReceiptUrl(receiptUrl);
        }
        if (reference != null && !reference.isBlank()) {
            verified = cbeVerifierClient.verifyReference(reference, suffix);
        } else if (receipt != null && !receipt.isEmpty()) {
            // Compatibility fallback for verifier deployments that support image OCR directly.
            verified = cbeVerifierClient.verifyImage(receipt, suffix);
        } else {
            throw new BusinessException("PROOF_REQUIRED", "Upload a CBE receipt screenshot or provide a transaction reference.");
        }

        if (!verified.success()) {
            // Verifier returned a definitive rejection (not a transient error). Keep the
            // intent at CHECKOUT so the user can retry with a better screenshot.
            Map<String, Object> rejRaw = new HashMap<>(verified.raw() == null ? Map.of() : verified.raw());
            if (receiptUrl != null) rejRaw.put("receiptUrl", receiptUrl);
            intent.setRawNotify(rejRaw);
            paymentIntentRepository.save(intent);
            throw new BusinessException("CBE_VERIFY_REJECTED",
                    "CBE receipt could not be verified. Please re-upload a clear screenshot and try again.");
        }

        if (verified.reference() == null || verified.reference().isBlank()) {
            throw new BusinessException("CBE_REFERENCE_MISSING", "The receipt OCR did not return a CBE FT transaction code. Enter the code and try again.");
        }
        String ref = cbeVerifierClient.isMock()
                ? verified.reference().trim().toUpperCase(Locale.ROOT)
                : CbeVerifierClient.requireExactCbeReference(verified.reference());

        paymentIntentRepository.findByProviderAndProviderRefIgnoreCase("CBE", ref)
                .filter(existing -> existing.getStatus() == PaymentStatus.PAID)
                .ifPresent(existing -> {
                    throw new BusinessException("CBE_REFERENCE_USED", "This CBE transaction was already used for a payment.");
                });

        if (!cbeVerifierClient.isMock()) {
            assertAmountMatches(intent.getAmountEtb(), verified.amountEtb());
            assertReceiverMatches(pay, verified);
        } else if (verified.amountEtb() == null) {
            // mock image path — treat expected amount as paid
            verified = new CbeVerifierClient.VerificationResult(
                    true,
                    ref,
                    intent.getAmountEtb(),
                    verified.payerName(),
                    verified.receiverName(),
                    verified.receiverAccount(),
                    verified.raw()
            );
        }

        Map<String, Object> raw = new HashMap<>(verified.raw() == null ? Map.of() : verified.raw());
        raw.put("receiptUrl", receiptUrl);
        raw.put("accountSuffix", suffix);
        intent.setRawNotify(raw);
        intent.setProviderRef(ref);
        markPaidAndActivate(intent, ref, "CBE transfer " + ref);

        if ("BOOKING".equals(intent.getPurpose())) {
            return toCheckout(intent, null);
        }
        return currentSubscription(userId);
    }

    /**
     * Returns the current pending CBE payment checkout for a given booking so the
     * booking screen can restore its upload panel after resume / cold launch.
     */
    @Transactional(readOnly = true)
    public BillingDtos.CheckoutResponse getPendingBookingCheckout(UUID userId, UUID bookingId) {
        return paymentIntentRepository
                .findFirstByBookingIdAndStatusInOrderByCreatedAtDesc(
                        bookingId, List.of(PaymentStatus.PENDING, PaymentStatus.CHECKOUT, PaymentStatus.FAILED))
                .filter(intent -> intent.getUserId().equals(userId))
                .map(intent -> {
                    BillingDtos.CbeInstructions cbeInfo = null;
                    if ("CBE".equalsIgnoreCase(intent.getProvider())) {
                        VelvetProperties.CbePayment pay = properties.cbePayment();
                        if (pay != null) {
                            String note = "Transfer " + intent.getAmountEtb().toPlainString()
                                    + " ETB to " + pay.accountName()
                                    + " for booking. Put order " + intent.getMerchantOrderId()
                                    + " in the reason, then upload your CBE receipt screenshot.";
                            cbeInfo = new BillingDtos.CbeInstructions(
                                    pay.accountName(), pay.accountNumber(), pay.accountSuffix(),
                                    blankTo(pay.bankName(), "Commercial Bank of Ethiopia"), note);
                        }
                    }
                    return new BillingDtos.CheckoutResponse(
                            intent.getId().toString(),
                            intent.getMerchantOrderId(),
                            intent.getCheckoutUrl(),
                            intent.getProvider(),
                            intent.getAmountEtb(),
                            intent.getCurrency(),
                            intent.getStatus().name(),
                            "CBE".equalsIgnoreCase(intent.getProvider()) && cbeVerifierClient.isMock(),
                            cbeInfo
                    );
                })
                .orElse(null);
    }

    @Transactional
    public void initiateRefund(UUID bookingId, String reason) {
        paymentIntentRepository.findFirstByBookingIdAndStatusInOrderByCreatedAtDesc(
                bookingId, List.of(PaymentStatus.PAID)
        ).ifPresent(intent -> {
            intent.setStatus(PaymentStatus.REFUND_PENDING);
            Map<String, Object> raw = new HashMap<>(intent.getRawNotify() == null ? Map.of() : intent.getRawNotify());
            raw.put("refundReason", reason == null ? "Booking Cancelled" : reason);
            intent.setRawNotify(raw);
            paymentIntentRepository.save(intent);
        });
    }

    /** Closes unpaid checkout attempts when their booking is cancelled or replaced. */
    @Transactional
    public void cancelPendingBookingPayments(UUID bookingId, String reason) {
        paymentIntentRepository.findByBookingIdAndStatusIn(
                        bookingId, List.of(PaymentStatus.PENDING, PaymentStatus.CHECKOUT, PaymentStatus.FAILED))
                .forEach(intent -> {
                    Map<String, Object> raw = new HashMap<>(intent.getRawNotify() == null ? Map.of() : intent.getRawNotify());
                    raw.put("cancelledReason", reason == null || reason.isBlank() ? "Booking cancelled" : reason.trim());
                    raw.put("cancelledAt", Instant.now().toString());
                    intent.setRawNotify(raw);
                    intent.setStatus(PaymentStatus.CANCELLED);
                });
    }

    // ── Admin ─────────────────────────────────────────────────────────────────

    @Transactional(readOnly = true)
    public List<BillingDtos.PaymentIntentAdminItem> listPaymentsForAdmin(String statusFilter, int page, int size) {
        var pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        if (statusFilter != null && !statusFilter.isBlank()) {
            PaymentStatus status;
            try {
                status = PaymentStatus.valueOf(statusFilter.toUpperCase(Locale.ROOT));
            } catch (IllegalArgumentException e) {
                throw new BusinessException("INVALID_STATUS", "Unknown payment status: " + statusFilter);
            }
            return paymentIntentRepository.findAllByStatusOrderByCreatedAtDesc(status, pageable)
                    .stream().map(this::toAdminItem).toList();
        }
        return paymentIntentRepository.findAllByOrderByCreatedAtDesc(pageable)
                .stream().map(this::toAdminItem).toList();
    }

    @Transactional
    public BillingDtos.PaymentIntentAdminItem approvePaymentByAdmin(
            UUID paymentIntentId, UUID adminUserId, String notes) {
        PaymentIntentEntity intent = paymentIntentRepository.findById(paymentIntentId)
                .orElseThrow(() -> new BusinessException("PAYMENT_NOT_FOUND", "Unknown payment order."));
        if (intent.getStatus() == PaymentStatus.PAID) {
            return toAdminItem(intent);
        }
        Map<String, Object> raw = new HashMap<>(intent.getRawNotify() == null ? Map.of() : intent.getRawNotify());
        raw.put("adminApprovedBy", adminUserId.toString());
        raw.put("adminNotes", notes == null ? "" : notes);
        intent.setRawNotify(raw);
        markPaidAndActivate(intent, "ADMIN-OVERRIDE-" + adminUserId, "Admin approved");
        return toAdminItem(intent);
    }

    @Transactional
    public BillingDtos.PaymentIntentAdminItem rejectPaymentByAdmin(
            UUID paymentIntentId, UUID adminUserId, String notes) {
        PaymentIntentEntity intent = paymentIntentRepository.findById(paymentIntentId)
                .orElseThrow(() -> new BusinessException("PAYMENT_NOT_FOUND", "Unknown payment order."));
        if (intent.getStatus() == PaymentStatus.PAID) {
            throw new BusinessException("PAYMENT_ALREADY_PAID", "Cannot reject an already paid payment.");
        }
        Map<String, Object> raw = new HashMap<>(intent.getRawNotify() == null ? Map.of() : intent.getRawNotify());
        raw.put("adminRejectedBy", adminUserId.toString());
        raw.put("adminNotes", notes == null ? "" : notes);
        intent.setRawNotify(raw);
        intent.setStatus(PaymentStatus.FAILED);
        paymentIntentRepository.save(intent);
        return toAdminItem(intent);
    }

    @Transactional
    public BillingDtos.PaymentIntentAdminItem markRefundedByAdmin(
            UUID paymentIntentId, UUID adminUserId, String notes) {
        PaymentIntentEntity intent = paymentIntentRepository.findById(paymentIntentId)
                .orElseThrow(() -> new BusinessException("PAYMENT_NOT_FOUND", "Unknown payment order."));
        if (intent.getStatus() == PaymentStatus.REFUNDED) {
            return toAdminItem(intent);
        }
        if (intent.getStatus() != PaymentStatus.REFUND_PENDING) {
            throw new BusinessException("INVALID_STATE", "Payment must be REFUND_PENDING.");
        }
        Map<String, Object> raw = new HashMap<>(intent.getRawNotify() == null ? Map.of() : intent.getRawNotify());
        raw.put("adminRefundedBy", adminUserId.toString());
        raw.put("adminRefundNotes", notes == null ? "" : notes);
        intent.setRawNotify(raw);
        intent.setStatus(PaymentStatus.REFUNDED);
        paymentIntentRepository.save(intent);
        if ("BOOKING".equals(intent.getPurpose()) && intent.getBookingId() != null) {
            bookingRepository.findById(intent.getBookingId())
                    .ifPresent(booking -> earningsService.reversePerformerCreditForRefund(booking, intent));
        }
        return toAdminItem(intent);
    }

    @Transactional
    public void processPendingRefunds() {
        // A CBE refund requires an actual outgoing bank transfer. Never mark it
        // refunded merely because a background job ran; finance staff must record
        // the bank reference through the admin refund action after sending funds.
        int pending = paymentIntentRepository
                .findAllByStatusInOrderByCreatedAtDesc(List.of(PaymentStatus.REFUND_PENDING)).size();
        if (pending > 0) {
            log.warn("{} CBE refunds awaiting manual bank transfer and reconciliation", pending);
        }
    }

    @Transactional
    public Object completeMockCbe(UUID userId, UUID paymentIntentId) {
        if (properties.isProduction() || !cbeVerifierClient.isMock()) {
            throw new BusinessException("MOCK_DISABLED", "Mock CBE proof is only available in CBE_VERIFIER_MODE=mock.");
        }
        PaymentIntentEntity intent = paymentIntentRepository.findById(paymentIntentId)
                .orElseThrow(() -> new BusinessException("PAYMENT_NOT_FOUND", "Unknown payment order."));
        if (!intent.getUserId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not your payment.");
        }
        if (intent.getStatus() != PaymentStatus.PAID) {
            String ref = "MOCK-" + intent.getMerchantOrderId();
            intent.setRawNotify(Map.of("source", "mock-complete"));
            intent.setProviderRef(ref);
            markPaidAndActivate(intent, ref, "CBE mock payment");
        }
        if ("BOOKING".equals(intent.getPurpose())) {
            return toCheckout(intent, null);
        }
        return currentSubscription(userId);
    }

    private void assertAmountMatches(BigDecimal expected, BigDecimal actual) {
        if (actual == null) {
            throw new BusinessException("CBE_AMOUNT_MISSING", "Verifier did not return a paid amount.");
        }
        BigDecimal exp = expected.setScale(2, RoundingMode.HALF_UP);
        BigDecimal act = actual.setScale(2, RoundingMode.HALF_UP);
        if (act.subtract(exp).abs().compareTo(new BigDecimal("1.00")) > 0) {
            throw new BusinessException(
                    "CBE_AMOUNT_MISMATCH",
                    "Paid amount " + act + " ETB does not match plan price " + exp + " ETB."
            );
        }
    }

    private void assertReceiverMatches(VelvetProperties.CbePayment pay, CbeVerifierClient.VerificationResult verified) {
        String suffix = pay.accountSuffix() == null ? "" : pay.accountSuffix().trim();
        String account = verified.receiverAccount() == null ? "" : verified.receiverAccount().replaceAll("\\s", "");
        if (suffix.isBlank() || account.isBlank()) {
            throw new BusinessException("CBE_RECEIVER_MISSING", "Verifier did not return the receiving CBE account.");
        }
        String configured = pay.accountNumber() == null ? "" : pay.accountNumber().replaceAll("\\s", "");
        boolean suffixMatches = account.endsWith(suffix);
        boolean accountMatches = !configured.isBlank() && account.equals(configured);
        // CBE's public legacy PDF may disclose only the final four account
        // digits (for example ****5656). In direct mode that visible suffix is
        // still checked against the configured receiving account; it is never
        // treated as a missing or unchecked receiver.
        boolean directReceipt = "cbe-public-receipt".equals(String.valueOf(verified.raw().get("source")));
        String visibleDigits = account.replaceAll("[^0-9]", "");
        boolean maskedDirectSuffixMatches = directReceipt
                && account.contains("*")
                && visibleDigits.length() == 4
                && suffix.endsWith(visibleDigits);
        if (!suffixMatches && !accountMatches && !maskedDirectSuffixMatches) {
            throw new BusinessException(
                    "CBE_RECEIVER_MISMATCH",
                    "Receipt does not appear to credit the VELVET CBE account."
            );
        }
    }

    @Transactional
    public void handleTelebirrNotify(Map<String, Object> payload) {
        notifyVerifier.verifyOrThrow(payload);
        String orderId = firstString(payload, "merch_order_id", "merchOrderId", "outTradeNo");
        if (orderId == null || orderId.isBlank()) {
            throw new BusinessException("NOTIFY_INVALID", "Missing merchant order id.");
        }
        String tradeStatus = firstString(payload, "trade_status", "tradeStatus", "status");
        PaymentIntentEntity intent = paymentIntentRepository.findByMerchantOrderId(orderId)
                .orElseThrow(() -> new BusinessException("PAYMENT_NOT_FOUND", "Unknown payment order."));

        Map<String, Object> raw = new HashMap<>(payload);
        intent.setRawNotify(raw);

        if (intent.getStatus() == PaymentStatus.PAID) {
            return;
        }

        boolean success = tradeStatus == null
                || tradeStatus.equalsIgnoreCase("Completed")
                || tradeStatus.equalsIgnoreCase("Success")
                || tradeStatus.equalsIgnoreCase("PAID")
                || "mock".equalsIgnoreCase(String.valueOf(payload.get("source")));

        if (!success) {
            intent.setStatus(PaymentStatus.FAILED);
            paymentIntentRepository.save(intent);
            return;
        }

        markPaidAndActivate(
                intent,
                firstString(payload, "payment_order_id", "transactionId", "provider_ref"),
                "Telebirr membership"
        );
    }

    @Transactional
    public BillingDtos.SubscriptionResponse completeMockPayment(UUID userId, String merchantOrderId) {
        if (properties.isProduction() || (properties.telebirr() != null && !"mock".equalsIgnoreCase(properties.telebirr().mode()))) {
            throw new BusinessException("MOCK_DISABLED", "Mock Telebirr pay is only available in mock mode.");
        }
        PaymentIntentEntity intent = paymentIntentRepository.findByMerchantOrderId(merchantOrderId)
                .orElseThrow(() -> new BusinessException("PAYMENT_NOT_FOUND", "Unknown payment order."));
        if (!intent.getUserId().equals(userId)) {
            throw new BusinessException("FORBIDDEN", "Not your payment.");
        }
        if (!"MEMBERSHIP".equals(intent.getPurpose())) {
            throw new BusinessException("WRONG_PAYMENT_PURPOSE", "Use the booking payment flow for this order.");
        }
        if (intent.getStatus() != PaymentStatus.PAID) {
            Map<String, Object> payload = Map.of(
                    "merch_order_id", merchantOrderId,
                    "trade_status", "Completed",
                    "source", "mock"
            );
            handleTelebirrNotify(payload);
            intent = paymentIntentRepository.findByMerchantOrderId(merchantOrderId).orElseThrow();
        }
        SubscriptionEntity sub = subscriptionRepository
                .findFirstByUserIdAndStatusAndEndsAtAfterOrderByEndsAtDesc(intent.getUserId(), "ACTIVE", Instant.now())
                .orElseThrow(() -> new BusinessException("SUBSCRIPTION_MISSING", "Subscription not activated."));
        SubscriptionPlanEntity plan = planRepository.findById(sub.getPlanId()).orElseThrow();
        return toSubscription(sub, plan);
    }

    private void markPaidAndActivate(PaymentIntentEntity intent, String providerRef, String ledgerDescription) {
        intent.setStatus(PaymentStatus.PAID);
        intent.setPaidAt(Instant.now());
        if (providerRef != null) {
            intent.setProviderRef(providerRef);
        }
        paymentIntentRepository.save(intent);

        if ("BOOKING".equals(intent.getPurpose())) {
            UUID bookingId = intent.getBookingId();
            if (bookingId != null) {
                BookingEntity booking = bookingRepository.findById(bookingId)
                        .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking payment has no booking."));
                if (booking.getStatus() != BookingStatus.CONFIRMED
                        || !intent.getId().equals(booking.getPaymentIntentId())) {
                    throw new BusinessException(
                            "BOOKING_PAYMENT_CLOSED",
                            "This booking is no longer eligible for payment. Start payment again from the current booking."
                    );
                }
                booking.setPaymentStatus("PAID");
                bookingRepository.save(booking);
            }
            ledgerEntryRepository.save(LedgerEntryEntity.builder()
                    .userId(intent.getUserId())
                    .paymentIntentId(intent.getId())
                    .bookingId(bookingId)
                    .entryType("BOOKING_CHARGE")
                    .amountEtb(intent.getAmountEtb())
                    .currency("ETB")
                    .description(ledgerDescription + " booking")
                    .build());
            return;
        }

        SubscriptionPlanEntity plan = planRepository.findById(intent.getPlanId()).orElseThrow();
        Instant now = Instant.now();
        subscriptionRepository.save(SubscriptionEntity.builder()
                .userId(intent.getUserId())
                .planId(plan.getId())
                .status("ACTIVE")
                .startsAt(now)
                .endsAt(now.plus(plan.getDurationDays(), ChronoUnit.DAYS))
                .connectionsUsed(0)
                .paymentIntentId(intent.getId())
                .build());

        ledgerEntryRepository.save(LedgerEntryEntity.builder()
                .userId(intent.getUserId())
                .paymentIntentId(intent.getId())
                .entryType("SUBSCRIPTION_CHARGE")
                .amountEtb(intent.getAmountEtb())
                .currency("ETB")
                .description(ledgerDescription + " " + plan.getCode())
                .build());

        UserEntity user = userRepository.findById(intent.getUserId()).orElseThrow();
        if (user.getRole() == UserRole.MEMBER || user.getRole() == UserRole.CLIENT) {
            user.setRole(UserRole.SUBSCRIBER);
        }
        // Keep performers VERIFIED so listings stay discoverable after any membership side-effect.
        if (user.getStatus() == UserStatus.VERIFIED && user.getRole() != UserRole.PERFORMER) {
            user.setStatus(UserStatus.ACTIVE);
        }
        userRepository.save(user);
    }

    /** Credits the performer only after a paid booking reaches COMPLETED. */
    @Transactional
    public void settleCompletedBooking(UUID bookingId) {
        BookingEntity booking = bookingRepository.findById(bookingId)
                .orElseThrow(() -> new BusinessException("BOOKING_NOT_FOUND", "Booking not found."));
        if (booking.getStatus() != BookingStatus.COMPLETED || !"PAID".equals(booking.getPaymentStatus())
                || booking.getPaymentIntentId() == null) {
            return;
        }
        PaymentIntentEntity intent = paymentIntentRepository.findById(booking.getPaymentIntentId())
                .orElseThrow(() -> new BusinessException("PAYMENT_NOT_FOUND", "Booking payment not found."));
        if (intent.getStatus() == PaymentStatus.PAID) {
            earningsService.creditPerformerForPaidBooking(booking, intent);
        }
    }

    private BillingDtos.CheckoutResponse toCheckout(PaymentIntentEntity intent, BillingDtos.CbeInstructions cbe) {
        return new BillingDtos.CheckoutResponse(
                intent.getId().toString(),
                intent.getMerchantOrderId(),
                intent.getCheckoutUrl(),
                intent.getProvider(),
                intent.getAmountEtb(),
                intent.getCurrency(),
                intent.getStatus().name(),
                "CBE".equalsIgnoreCase(intent.getProvider()) && cbeVerifierClient.isMock(),
                cbe
        );
    }

    private BillingDtos.PaymentIntentAdminItem toAdminItem(PaymentIntentEntity i) {
        return new BillingDtos.PaymentIntentAdminItem(
                i.getId().toString(),
                i.getUserId().toString(),
                i.getPurpose(),
                i.getBookingId() == null ? null : i.getBookingId().toString(),
                i.getProvider(),
                i.getMerchantOrderId(),
                i.getAmountEtb(),
                i.getCurrency(),
                i.getStatus().name(),
                i.getReceiptUrl(),
                i.getProviderRef(),
                i.getCreatedAt(),
                i.getPaidAt()
        );
    }

    private SubscriptionPlanEntity requirePlan(String planCode) {
        return planRepository.findByCodeIgnoreCase(planCode.trim())
                .filter(SubscriptionPlanEntity::isActive)
                .orElseThrow(() -> new BusinessException("PLAN_NOT_FOUND", "Subscription plan not found."));
    }

    private boolean isCbeProvider() {
        VelvetProperties.Billing billing = properties.billing();
        if (billing == null || billing.provider() == null || billing.provider().isBlank()) {
            return true;
        }
        return "cbe".equalsIgnoreCase(billing.provider());
    }

    private VelvetProperties.CbePayment requireCbePaymentConfig() {
        VelvetProperties.CbePayment pay = properties.cbePayment();
        if (pay == null || pay.accountSuffix() == null || pay.accountSuffix().isBlank()) {
            throw new BusinessException(
                    "CBE_PAYMENT_CONFIG",
                    "Set CBE_ACCOUNT_SUFFIX (last 8 digits of the receiving CBE account) for membership transfers."
            );
        }
        return pay;
    }

    private BillingDtos.PlanResponse toPlan(SubscriptionPlanEntity plan) {
        return new BillingDtos.PlanResponse(
                plan.getId().toString(),
                plan.getCode(),
                plan.getNameEn(),
                plan.getNameAm(),
                plan.getPriceEtb(),
                plan.getMatchQuota(),
                plan.getDurationDays()
        );
    }

    private BillingDtos.SubscriptionResponse toSubscription(SubscriptionEntity sub, SubscriptionPlanEntity plan) {
        return new BillingDtos.SubscriptionResponse(
                sub.getId().toString(),
                plan.getCode(),
                plan.getNameEn(),
                sub.getStatus(),
                sub.getStartsAt(),
                sub.getEndsAt(),
                plan.getMatchQuota(),
                sub.getConnectionsUsed()
        );
    }

    private static String firstString(Map<String, Object> map, String... keys) {
        for (String key : keys) {
            Object v = map.get(key);
            if (v != null && !v.toString().isBlank()) {
                return v.toString();
            }
        }
        return null;
    }

    private static String blankTo(String value, String fallback) {
        return value == null || value.isBlank() ? fallback : value;
    }
}
