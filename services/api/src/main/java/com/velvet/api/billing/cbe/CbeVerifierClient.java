package com.velvet.api.billing.cbe;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Client for Leul's verifier-api (https://github.com/Vixen878/verifier-api).
 * Verifies CBE transfer receipts by screenshot and/or reference + account suffix.
 */
@Component
public class CbeVerifierClient {

    private static final Logger log = LoggerFactory.getLogger(CbeVerifierClient.class);
    /** CBE fund-transfer codes are exactly twelve alphanumeric characters beginning FT. */
    private static final Pattern CBE_REFERENCE = Pattern.compile("FT[A-Z0-9]{10}(?![A-Z0-9])");
    private static final Pattern CBE_AMOUNT = Pattern.compile("(?:Transferred Amount|Amount Credited)\\s*:?\\s*([\\d,]+(?:\\.\\d{1,2})?)\\s*ETB", Pattern.CASE_INSENSITIVE);
    private static final Pattern CBE_PAYER = Pattern.compile("Payer\\s*:?\\s*(.*?)\\s+Account", Pattern.CASE_INSENSITIVE);
    private static final Pattern CBE_RECEIVER = Pattern.compile("Receiver\\s*:?\\s*(.*?)\\s+Account", Pattern.CASE_INSENSITIVE);
    private static final Pattern CBE_ACCOUNT = Pattern.compile("Account\\s*:?\\s*([A-Z0-9*]+\\d{4})", Pattern.CASE_INSENSITIVE);

    private final VelvetProperties properties;
    private final RestClient restClient;

    public CbeVerifierClient(VelvetProperties properties) {
        this.properties = properties;
        // The mobile app should receive a clear provider-outage result rather
        // than exhaust its own request timeout while a verifier is unhealthy.
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(Duration.ofSeconds(8));
        requestFactory.setReadTimeout(Duration.ofSeconds(12));
        this.restClient = RestClient.builder().requestFactory(requestFactory).build();
    }

    public record VerificationResult(
            boolean success,
            String reference,
            BigDecimal amountEtb,
            String payerName,
            String receiverName,
            String receiverAccount,
            Map<String, Object> raw
    ) {}

    public boolean isMock() {
        VelvetProperties.CbeVerifier cfg = properties.cbeVerifier();
        return cfg == null || cfg.mode() == null || "mock".equalsIgnoreCase(cfg.mode());
    }

    public boolean isDirect() {
        VelvetProperties.CbeVerifier cfg = properties.cbeVerifier();
        return cfg != null && "direct".equalsIgnoreCase(cfg.mode());
    }

    public VerificationResult verifyImage(MultipartFile file, String accountSuffix) {
        if (isDirect()) {
            throw new BusinessException(
                    "CBE_REFERENCE_REQUIRED",
                    "Enter the 12-character CBE transaction code beginning with FT to verify this receipt."
            );
        }
        if (isMock()) {
            log.info("CBE verifier MOCK image verify suffix={}", accountSuffix);
            return new VerificationResult(
                    true,
                    "MOCK-FT" + System.currentTimeMillis(),
                    null,
                    "Mock Payer",
                    properties.cbePayment() == null ? "VELVET" : properties.cbePayment().accountName(),
                    accountSuffix,
                    Map.of("source", "mock", "mode", "image")
            );
        }
        VelvetProperties.CbeVerifier cfg = requireCfg();
        try {
            MultipartBodyBuilder body = new MultipartBodyBuilder();
            body.part("file", new ByteArrayResource(file.getBytes()) {
                @Override
                public String getFilename() {
                    return file.getOriginalFilename() == null ? "receipt.jpg" : file.getOriginalFilename();
                }
            }).contentType(MediaType.parseMediaType(
                    file.getContentType() == null ? "image/jpeg" : file.getContentType()
            ));
            if (accountSuffix != null && !accountSuffix.isBlank()) {
                body.part("suffix", accountSuffix.trim());
            }

            @SuppressWarnings("unchecked")
            Map<String, Object> response = restClient.post()
                    .uri(base(cfg) + "/verify-image?autoVerify=true")
                    .header("x-api-key", cfg.apiKey())
                    .contentType(MediaType.MULTIPART_FORM_DATA)
                    .body(body.build())
                    .retrieve()
                    .body(Map.class);
            return parse(response);
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw verifierFailure(e, "image");
        }
    }

    public VerificationResult verifyReference(String reference, String accountSuffix) {
        if (isMock()) {
            log.info("CBE verifier MOCK reference={} suffix={}", reference, accountSuffix);
            return new VerificationResult(
                    true,
                    reference,
                    null,
                    "Mock Payer",
                    properties.cbePayment() == null ? "VELVET" : properties.cbePayment().accountName(),
                    accountSuffix,
                    Map.of("source", "mock", "mode", "reference")
            );
        }
        String exactReference = requireExactCbeReference(reference);
        if (isDirect()) {
            return verifyDirectCbeReceipt(exactReference, accountSuffix);
        }
        VelvetProperties.CbeVerifier cfg = requireCfg();
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restClient.post()
                    .uri(base(cfg) + "/verify-cbe")
                    .header("x-api-key", cfg.apiKey())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of(
                            "reference", exactReference,
                            "accountSuffix", accountSuffix.trim()
                    ))
                    .retrieve()
                    .body(Map.class);
            return parse(response);
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw verifierFailure(e, "reference");
        }
    }

    /**
     * Direct, keyless verification against CBE's public legacy receipt PDF.
     * This is deliberately opt-in (CBE_VERIFIER_MODE=direct): it is not a
     * contracted CBE merchant API and may be unavailable or changed by CBE.
     */
    private VerificationResult verifyDirectCbeReceipt(String reference, String accountSuffix) {
        String suffix = accountSuffix == null ? "" : accountSuffix.trim();
        if (!suffix.matches("\\d{8}")) {
            throw new BusinessException("CBE_SUFFIX_REQUIRED", "A valid 8-digit CBE account suffix is required.");
        }
        try {
            byte[] pdf = restClient.get()
                    .uri("https://apps.cbe.com.et:100/?id={id}", reference + suffix)
                    .header("Accept", "application/pdf")
                    .header("User-Agent", "Mozilla/5.0 (compatible; VelvetPaymentVerifier/1.0)")
                    .retrieve()
                    .body(byte[].class);
            if (pdf == null || pdf.length == 0) {
                throw new BusinessException("CBE_VERIFY_EMPTY", "CBE did not return a receipt for this transaction.");
            }
            return parseDirectPdf(pdf, reference);
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.warn("Direct CBE receipt lookup failed: {}", e.getMessage());
            throw new BusinessException(
                    "CBE_VERIFIER_UNAVAILABLE",
                    "CBE receipt verification is temporarily unavailable. Please try again shortly."
            );
        }
    }

    static VerificationResult parseDirectPdf(byte[] pdf, String requestedReference) {
        try (PDDocument document = PDDocument.load(pdf)) {
            String text = new PDFTextStripper().getText(document).replaceAll("\\s+", " ").trim();
            String payer = firstGroup(CBE_PAYER, text);
            String receiver = firstGroup(CBE_RECEIVER, text);
            Matcher amountMatch = CBE_AMOUNT.matcher(text);
            BigDecimal amount = amountMatch.find()
                    ? new BigDecimal(amountMatch.group(1).replace(",", ""))
                    : null;
            Matcher accounts = CBE_ACCOUNT.matcher(text);
            String payerAccount = accounts.find() ? accounts.group(1) : null;
            String receiverAccount = accounts.find() ? accounts.group(1) : null;
            String receiptReference = extractExactCbeReference(text);
            boolean complete = payer != null && receiver != null && amount != null
                    && receiptReference != null && receiverAccount != null;
            return new VerificationResult(
                    complete && requestedReference.equals(receiptReference),
                    receiptReference == null ? requestedReference : receiptReference,
                    amount,
                    payer,
                    receiver,
                    receiverAccount,
                    Map.of("source", "cbe-public-receipt", "payerAccount", payerAccount == null ? "" : payerAccount)
            );
        } catch (Exception e) {
            log.warn("Could not parse direct CBE receipt PDF: {}", e.getMessage());
            throw new BusinessException("CBE_VERIFY_REJECTED", "CBE returned a receipt that could not be verified.");
        }
    }

    private static String firstGroup(Pattern pattern, String value) {
        Matcher matcher = pattern.matcher(value);
        return matcher.find() ? matcher.group(1).trim() : null;
    }

    private BusinessException verifierFailure(Exception error, String proofType) {
        if (error instanceof ResourceAccessException) {
            log.warn("CBE verifier {} request timed out or could not connect: {}", proofType, error.getMessage());
            return new BusinessException(
                    "CBE_VERIFIER_UNAVAILABLE",
                    "CBE verification is temporarily unavailable. Please try again shortly."
            );
        }
        if (error instanceof HttpClientErrorException clientError) {
            String response = clientError.getResponseBodyAsString();
            if (response.contains("Could not find Chrome") || response.contains("Puppeteer")) {
                log.warn("CBE verifier {} service is unhealthy: {}", proofType, clientError.getStatusCode());
                return new BusinessException(
                        "CBE_VERIFIER_UNAVAILABLE",
                        "CBE verification is temporarily unavailable. Please try again shortly."
                );
            }
        }
        log.error("CBE {} verification failed", proofType, error);
        return new BusinessException(
                "CBE_VERIFY_FAILED",
                proofType.equals("image")
                        ? "Could not verify CBE receipt screenshot."
                        : "Could not verify CBE transaction reference."
        );
    }

    private VelvetProperties.CbeVerifier requireCfg() {
        VelvetProperties.CbeVerifier cfg = properties.cbeVerifier();
        if (cfg == null || cfg.apiKey() == null || cfg.apiKey().isBlank()
                || cfg.baseUrl() == null || cfg.baseUrl().isBlank()) {
            throw new BusinessException(
                    "CBE_VERIFIER_CONFIG",
                    "CBE verifier requires CBE_VERIFIER_BASE_URL and CBE_VERIFIER_API_KEY (get a key at https://verify.leul.et)."
            );
        }
        return cfg;
    }

    private static String base(VelvetProperties.CbeVerifier cfg) {
        return cfg.baseUrl().replaceAll("/$", "");
    }

    @SuppressWarnings("unchecked")
    private VerificationResult parse(Map<String, Object> response) {
        if (response == null) {
            throw new BusinessException("CBE_VERIFY_EMPTY", "Empty response from CBE verifier.");
        }
        Map<String, Object> raw = new LinkedHashMap<>(response);
        boolean success = Boolean.TRUE.equals(response.get("success"));
        if (!success && response.get("success") == null) {
            // Some responses omit success when fields are present
            success = response.get("error") == null;
        }

        // Nested payloads from autoVerify
        Object data = response.get("data");
        if (data instanceof Map<?, ?> nested) {
            raw.put("data", nested);
            Map<String, Object> n = (Map<String, Object>) nested;
            if (n.get("success") != null) {
                success = Boolean.TRUE.equals(n.get("success"));
            }
            response = n;
        }

        if (response.get("error") != null || "error".equalsIgnoreCase(String.valueOf(response.get("status")))) {
            success = false;
        }

        String reference = extractExactCbeReference(response);
        if (reference == null) {
            reference = extractExactCbeReference(raw);
        }
        if (reference == null) {
            reference = first(response,
                "reference", "referenceNumber", "transactionReference", "transactionId", "transaction_id",
                "receiptNumber", "ftNumber", "FTNumber");
        }
        BigDecimal amount = firstDecimal(response,
                "transactionAmount", "amount", "settledAmount", "totalPaid", "total", "creditedAmount");
        String payer = first(response, "payerName", "senderName", "payer", "customerName");
        String receiver = first(response, "receiverName", "creditedPartyName", "beneficiaryName");
        String receiverAccount = first(response,
                "receiverAccount", "receiverAccountNumber", "creditedAccount", "accountNumber", "beneficiaryAccount");

        if (!success && reference == null && amount == null) {
            throw new BusinessException("CBE_VERIFY_REJECTED", "CBE verifier could not read a valid receipt.");
        }
        return new VerificationResult(
                success || (reference != null && amount != null),
                reference,
                amount,
                payer,
                receiver,
                receiverAccount,
                raw
        );
    }

    /**
     * Normalizes harmless OCR separators, then requires the complete CBE FT code.
     * We intentionally never accept a truncated value or an arbitrary user-supplied
     * string as a transaction reference.
     */
    public static String requireExactCbeReference(String value) {
        String exact = extractExactCbeReference(value);
        if (exact == null) {
            throw new BusinessException(
                    "CBE_REFERENCE_INVALID",
                    "Enter the complete 12-character CBE transaction code beginning with FT."
            );
        }
        return exact;
    }

    @SuppressWarnings("unchecked")
    private static String extractExactCbeReference(Object value) {
        if (value == null) return null;
        if (value instanceof Map<?, ?> map) {
            String[] preferred = {
                    "reference", "referenceNumber", "transactionReference",
                    "transactionId", "transaction_id", "transactionID",
                    "ftNumber", "FTNumber", "receiptNumber"
            };
            for (String key : preferred) {
                String found = extractExactCbeReference(map.get(key));
                if (found != null) return found;
            }
            for (Object nested : map.values()) {
                String found = extractExactCbeReference(nested);
                if (found != null) return found;
            }
            return null;
        }
        if (value instanceof Iterable<?> values) {
            for (Object nested : values) {
                String found = extractExactCbeReference(nested);
                if (found != null) return found;
            }
            return null;
        }
        String normalized = value.toString().toUpperCase()
                .replaceAll("[\\s:.-]", "");
        Matcher matcher = CBE_REFERENCE.matcher(normalized);
        return matcher.find() ? matcher.group() : null;
    }

    private static String first(Map<String, Object> map, String... keys) {
        for (String key : keys) {
            Object v = map.get(key);
            if (v != null && !v.toString().isBlank()) {
                return v.toString().trim();
            }
        }
        return null;
    }

    private static BigDecimal firstDecimal(Map<String, Object> map, String... keys) {
        for (String key : keys) {
            Object v = map.get(key);
            if (v == null) {
                continue;
            }
            try {
                String s = v.toString().replace(",", "").replaceAll("[^0-9.]", "").trim();
                if (!s.isEmpty()) {
                    return new BigDecimal(s);
                }
            } catch (Exception ignored) {
                // try next
            }
        }
        return null;
    }
}
