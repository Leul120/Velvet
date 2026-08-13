package com.velvet.api.billing.web;

import com.velvet.api.billing.service.BillingService;
import com.velvet.api.billing.web.dto.BillingDtos;
import com.velvet.api.identity.security.VelvetPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/v1/billing")
public class BillingController {

    private final BillingService billingService;

    public BillingController(BillingService billingService) {
        this.billingService = billingService;
    }

    @GetMapping("/plans")
    public ResponseEntity<List<BillingDtos.PlanResponse>> plans() {
        return ResponseEntity.ok(billingService.listPlans());
    }

    @GetMapping("/subscription")
    public ResponseEntity<BillingDtos.SubscriptionResponse> current(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        BillingDtos.SubscriptionResponse sub = billingService.currentSubscription(principal.getUserId());
        return sub == null ? ResponseEntity.noContent().build() : ResponseEntity.ok(sub);
    }

    @GetMapping("/pending-cbe")
    public ResponseEntity<BillingDtos.CheckoutResponse> pendingCbe(
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        BillingDtos.CheckoutResponse checkout = billingService.pendingCbeCheckout(principal.getUserId());
        return checkout == null ? ResponseEntity.noContent().build() : ResponseEntity.ok(checkout);
    }

    @PostMapping("/subscribe")
    public ResponseEntity<BillingDtos.CheckoutResponse> subscribe(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @Valid @RequestBody BillingDtos.SubscribeRequest request
    ) {
        return ResponseEntity.ok(billingService.startSubscription(principal.getUserId(), request));
    }

    @PostMapping("/bookings/{bookingId}/pay")
    public ResponseEntity<BillingDtos.CheckoutResponse> payBooking(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID bookingId
    ) {
        return ResponseEntity.ok(billingService.startBookingPayment(principal.getUserId(), bookingId));
    }

    /**
     * Returns the current pending CBE checkout for a booking so the mobile app can restore
     * the upload panel after backgrounding or cold launch. Returns 204 when none is active.
     */
    @GetMapping("/bookings/{bookingId}/pending-payment")
    public ResponseEntity<BillingDtos.CheckoutResponse> pendingBookingPayment(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID bookingId
    ) {
        BillingDtos.CheckoutResponse checkout =
                billingService.getPendingBookingCheckout(principal.getUserId(), bookingId);
        return checkout == null ? ResponseEntity.noContent().build() : ResponseEntity.ok(checkout);
    }

    /**
     * Upload a CBE receipt screenshot (preferred) and/or FT reference for verifier-api confirmation.
     */
    @PostMapping(value = "/payments/{paymentIntentId}/cbe-proof", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> cbeProof(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID paymentIntentId,
            @RequestPart(value = "file", required = false) MultipartFile file,
            @RequestParam(value = "reference", required = false) String reference
    ) {
        return ResponseEntity.ok(billingService.submitCbeProof(
                principal.getUserId(),
                paymentIntentId,
                file,
                reference
        ));
    }

    /** Local/dev: mark a CBE payment paid without calling verifier-api. */
    @PostMapping("/payments/{paymentIntentId}/cbe-mock-complete")
    public ResponseEntity<?> cbeMockComplete(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @PathVariable UUID paymentIntentId
    ) {
        return ResponseEntity.ok(billingService.completeMockCbe(principal.getUserId(), paymentIntentId));
    }

    /** Legacy Telebirr async notify (only when BILLING_PROVIDER=telebirr). */
    @PostMapping("/telebirr/notify")
    public ResponseEntity<Map<String, String>> notify(@RequestBody Map<String, Object> payload) {
        billingService.handleTelebirrNotify(payload);
        return ResponseEntity.ok(Map.of("code", "0", "msg", "success"));
    }

    @PostMapping("/telebirr/mock-complete")
    public ResponseEntity<BillingDtos.SubscriptionResponse> mockComplete(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @RequestParam("orderId") String orderId
    ) {
        return ResponseEntity.ok(billingService.completeMockPayment(principal.getUserId(), orderId));
    }

    @GetMapping(value = "/telebirr/mock-pay", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> mockPayPage(@RequestParam("orderId") String orderId) {
        String html = """
                <!DOCTYPE html>
                <html><head><meta charset="utf-8"><title>Telebirr Mock</title>
                <style>body{font-family:Georgia,serif;background:#f7f2ea;padding:2rem;color:#1a1614}
                button{background:#0f5c4c;color:#f7f2ea;border:0;padding:.8rem 1.2rem;border-radius:10px;font:inherit;cursor:pointer}
                </style></head><body>
                <h1>Telebirr (mock)</h1>
                <p>Order: <code>%s</code></p>
                <p>Legacy mock checkout — prefer CBE screenshot verification.</p>
                <button onclick="pay()">Pay with Telebirr</button>
                <pre id="out"></pre>
                <script>
                async function pay(){
                  document.getElementById('out').textContent = 'Use the signed-in mobile app to complete this local mock payment.';
                }
                </script>
                </body></html>
                """.formatted(orderId);
        return ResponseEntity.ok(html);
    }
}
