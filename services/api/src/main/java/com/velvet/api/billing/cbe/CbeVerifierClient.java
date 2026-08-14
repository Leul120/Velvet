package com.velvet.api.billing.cbe;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.MediaType;
import org.springframework.http.client.JdkClientHttpRequestFactory;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.multipart.MultipartFile;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManager;
import javax.net.ssl.X509TrustManager;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.http.HttpClient;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.security.cert.X509Certificate;
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
    private final RestClient cbeReceiptClient;

    public CbeVerifierClient(VelvetProperties properties) {
        this.properties = properties;
        // Hosted verifier scrapes CBE with Puppeteer; receipts often take 20–45s.
        HttpClient httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(15))
                .build();
        JdkClientHttpRequestFactory requestFactory = new JdkClientHttpRequestFactory(httpClient);
        requestFactory.setReadTimeout(Duration.ofSeconds(60));
        this.restClient = RestClient.builder().requestFactory(requestFactory).build();

        // CBE's public receipt host often presents a cert Java will not trust.
        CbeReceiptRequestFactory cbeFactory = new CbeReceiptRequestFactory();
        cbeFactory.setConnectTimeout(Duration.ofSeconds(15));
        cbeFactory.setReadTimeout(Duration.ofSeconds(30));
        this.cbeReceiptClient = RestClient.builder().requestFactory(cbeFactory).build();
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
            return verifyLiveReference(exactReference, accountSuffix, cfg);
        } catch (BusinessException live) {
            if (shouldFallbackToDirect(live)) {
                log.warn("Live CBE verifier unavailable ({}), trying CBE public receipt", live.getCode());
                try {
                    VerificationResult direct = verifyDirectCbeReceipt(exactReference, accountSuffix);
                    if (direct.success()) {
                        return direct;
                    }
                    log.warn("CBE public receipt did not confirm FT {}", exactReference);
                } catch (BusinessException direct) {
                    log.warn("CBE public receipt fallback failed: {} {}", direct.getCode(), direct.getMessage());
                    if ("CBE_VERIFY_REJECTED".equals(direct.getCode()) || "CBE_VERIFY_EMPTY".equals(direct.getCode())) {
                        throw direct;
                    }
                }
            }
            throw live;
        } catch (Exception e) {
            throw verifierFailure(e, "reference");
        }
    }

    private record RawHttpResponse(HttpStatusCode status, HttpHeaders headers, byte[] body) {}

    private VerificationResult verifyLiveReference(
            String exactReference,
            String accountSuffix,
            VelvetProperties.CbeVerifier cfg
    ) {
        try {
            RawHttpResponse response = restClient.post()
                    .uri(base(cfg) + "/verify-cbe")
                    .header("x-api-key", cfg.apiKey())
                    .header("Accept", "application/json, application/pdf, application/octet-stream")
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(Map.of(
                            "reference", exactReference,
                            "accountSuffix", accountSuffix.trim()
                    ))
                    .exchange(this::readRawResponse);
            if (response.status().isError()) {
                throw mapVerifierHttpError(response.status(), response.body());
            }
            if (response.body().length == 0) {
                throw new BusinessException("CBE_VERIFY_EMPTY", "Empty response from CBE verifier.");
            }
            return decodeVerifierBody(response.body(), response.headers().getContentType(), exactReference);
        } catch (BusinessException e) {
            throw e;
        } catch (HttpClientErrorException clientError) {
            throw mapVerifierHttpError(clientError.getStatusCode(), clientError.getResponseBodyAsByteArray());
        } catch (Exception e) {
            throw verifierFailure(e, "reference");
        }
    }

    private RawHttpResponse readRawResponse(
            org.springframework.http.HttpRequest request,
            RestClient.RequestHeadersSpec.ConvertibleClientHttpResponse response
    ) throws IOException {
        HttpStatusCode status = response.getStatusCode();
        HttpHeaders headers = response.getHeaders();
        try {
            byte[] body = readBodyBytes(response);
            return new RawHttpResponse(status, headers, body);
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            log.warn("CBE verifier response read failed status={} type={}: {}",
                    status, headers.getContentType(), e.toString());
            throw verifierFailure(e, "reference");
        }
    }

    private static byte[] readBodyBytes(
            RestClient.RequestHeadersSpec.ConvertibleClientHttpResponse response
    ) throws IOException {
        try (InputStream in = response.getBody()) {
            return in.readAllBytes();
        } catch (IOException e) {
            // 4xx/5xx bodies can still be missing after a transport reset.
            if (response.getStatusCode().isError()) {
                return new byte[0];
            }
            throw e;
        }
    }

    static VerificationResult decodeVerifierBody(byte[] body, MediaType contentType, String exactReference) {
        if (looksLikePdf(contentType, body)) {
            return parseDirectPdf(body, exactReference);
        }
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> json = new ObjectMapper().readValue(body, Map.class);
            Object err = json.get("error");
            if (Boolean.FALSE.equals(json.get("success")) && err != null && !err.toString().isBlank()) {
                String message = err.toString();
                if (message.toLowerCase().contains("api key")) {
                    throw new BusinessException("CBE_VERIFIER_CONFIG", "CBE verifier API key was rejected.");
                }
                throw new BusinessException("CBE_VERIFY_REJECTED", message);
            }
            return parse(json);
        } catch (BusinessException e) {
            throw e;
        } catch (Exception e) {
            throw new BusinessException("CBE_VERIFY_REJECTED", "CBE verifier returned an unreadable response.");
        }
    }

    private static boolean looksLikePdf(MediaType contentType, byte[] body) {
        if (body.length < 4 || body[0] != '%' || body[1] != 'P' || body[2] != 'D' || body[3] != 'F') {
            return false;
        }
        if (contentType == null) {
            return true;
        }
        return MediaType.APPLICATION_PDF.includes(contentType)
                || MediaType.APPLICATION_OCTET_STREAM.includes(contentType);
    }

    /**
     * 422 from verifier-api means the receipt could not be verified (missing PDF,
     * unknown FT code, wrong suffix). That is not the same as Chrome/Puppeteer being down.
     */
    static BusinessException mapVerifierHttpError(HttpStatusCode status, byte[] body) {
        String raw = body == null ? "" : new String(body, StandardCharsets.UTF_8);
        String errorText = extractVerifierErrorMessage(raw);

        if (errorText != null && errorText.toLowerCase().contains("api key")) {
            return new BusinessException("CBE_VERIFIER_CONFIG", "CBE verifier API key was rejected.");
        }
        if (isVerifierInfrastructureFailure(status, errorText)) {
            log.warn("CBE verifier service is unhealthy: {} {}", status, abbreviate(errorText));
            return new BusinessException(
                    "CBE_VERIFIER_UNAVAILABLE",
                    "CBE verification is temporarily unavailable. Please try again shortly."
            );
        }
        log.warn("CBE verifier rejected proof: {} {}", status, abbreviate(errorText));
        return new BusinessException("CBE_VERIFY_REJECTED", userFacingVerifierRejection(errorText));
    }

    private static String extractVerifierErrorMessage(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> json = new ObjectMapper().readValue(raw, Map.class);
            Object err = json.get("error");
            if (err != null && !err.toString().isBlank()) {
                return err.toString().trim();
            }
            Object message = json.get("message");
            if (message != null && !message.toString().isBlank()) {
                return message.toString().trim();
            }
        } catch (Exception ignored) {
            // plain-text verifier errors still surface to the member
        }
        String trimmed = raw.trim();
        return trimmed.isEmpty() ? null : trimmed;
    }

    private static boolean isVerifierInfrastructureFailure(HttpStatusCode status, String errorText) {
        if (status != null && status.is5xxServerError()) {
            return true;
        }
        if (errorText == null) {
            return false;
        }
        String lower = errorText.toLowerCase();
        return lower.contains("could not find chrome")
                || lower.contains("failed to launch")
                || lower.contains("executable doesn't exist");
    }

    private static String userFacingVerifierRejection(String errorText) {
        if (errorText == null || errorText.isBlank()) {
            return "CBE could not verify this transfer. Check the FT code and try again.";
        }
        String lower = errorText.toLowerCase();
        if (lower.contains("pdf") || lower.contains("puppeteer") || lower.contains("not found")
                || lower.contains("invalid") || lower.contains("expired")) {
            return "CBE could not find this transfer. Confirm the 12-character FT code and that you paid the VELVET CBE account.";
        }
        if (errorText.length() < 160 && !lower.contains("stack") && !lower.contains(" at ")) {
            return errorText;
        }
        return "CBE could not verify this transfer. Check the FT code and try again.";
    }

    private static String abbreviate(String value) {
        if (value == null) {
            return "";
        }
        String compact = value.replaceAll("\\s+", " ").trim();
        return compact.length() <= 180 ? compact : compact.substring(0, 180) + "…";
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
            byte[] pdf = cbeReceiptClient.get()
                    .uri("https://apps.cbe.com.et:100/?id={id}", reference + suffix)
                    .header("Accept", "application/pdf, application/octet-stream")
                    .header("User-Agent", "Mozilla/5.0 (compatible; VelvetPaymentVerifier/1.0)")
                    .exchange((request, response) -> {
                        try (InputStream in = response.getBody()) {
                            return in.readAllBytes();
                        }
                    });
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
        if (isTransientVerifierError(error)) {
            log.warn("CBE verifier {} request timed out or could not connect: {}", proofType, error.toString());
            return new BusinessException(
                    "CBE_VERIFIER_UNAVAILABLE",
                    "CBE verification is taking too long. Please wait a moment and try again."
            );
        }
        if (error instanceof HttpClientErrorException clientError) {
            return mapVerifierHttpError(clientError.getStatusCode(), clientError.getResponseBodyAsByteArray());
        }
        log.error("CBE {} verification failed", proofType, error);
        return new BusinessException(
                "CBE_VERIFY_FAILED",
                proofType.equals("image")
                        ? "Could not verify CBE receipt screenshot."
                        : "Could not verify CBE transaction reference."
        );
    }

    private static boolean isTransientVerifierError(Throwable error) {
        for (Throwable current = error; current != null; current = current.getCause()) {
            if (current instanceof ResourceAccessException
                    || current instanceof SocketTimeoutException
                    || current instanceof java.net.http.HttpTimeoutException
                    || current instanceof java.net.ConnectException
                    || current instanceof java.net.UnknownHostException) {
                return true;
            }
            if (current instanceof IOException message
                    && message.getMessage() != null
                    && message.getMessage().toLowerCase().contains("timed out")) {
                return true;
            }
        }
        return false;
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
    private static VerificationResult parse(Map<String, Object> response) {
        if (response == null) {
            throw new BusinessException("CBE_VERIFY_EMPTY", "Empty response from CBE verifier.");
        }
        Map<String, Object> raw = new LinkedHashMap<>(response);
        boolean success = Boolean.TRUE.equals(response.get("success"));
        if (!success && response.get("success") == null) {
            // Some responses omit success when fields are present
            success = response.get("error") == null;
        }

        // Nested payloads from autoVerify or verifier-api v2 list responses
        Object data = response.get("data");
        if (data instanceof Iterable<?> values && !(data instanceof Map<?, ?>)) {
            for (Object item : values) {
                if (item instanceof Map<?, ?> nested) {
                    Map<String, Object> n = (Map<String, Object>) nested;
                    if (Boolean.TRUE.equals(n.get("verified")) || Boolean.TRUE.equals(n.get("success"))) {
                        success = true;
                    }
                    response = n;
                    break;
                }
            }
        } else if (data instanceof Map<?, ?> nested) {
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
        String receiver = first(response, "receiverName", "receiver", "creditedPartyName", "beneficiaryName");
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

    static boolean shouldFallbackToDirect(BusinessException error) {
        String code = error.getCode();
        return "CBE_VERIFIER_UNAVAILABLE".equals(code) || "CBE_VERIFY_FAILED".equals(code);
    }

    /**
     * CBE's public receipt TLS is often untrusted by the JVM. Scope the exception
     * to this client only — never the hosted verifier HTTPS calls.
     */
    private static final class CbeReceiptRequestFactory extends SimpleClientHttpRequestFactory {
        private static final SSLContext TRUST_ALL;

        static {
            try {
                TrustManager[] trustAll = {
                        new X509TrustManager() {
                            @Override
                            public void checkClientTrusted(X509Certificate[] chain, String authType) {}

                            @Override
                            public void checkServerTrusted(X509Certificate[] chain, String authType) {}

                            @Override
                            public X509Certificate[] getAcceptedIssuers() {
                                return new X509Certificate[0];
                            }
                        }
                };
                SSLContext context = SSLContext.getInstance("TLS");
                context.init(null, trustAll, new SecureRandom());
                TRUST_ALL = context;
            } catch (Exception e) {
                throw new IllegalStateException("Could not initialize CBE receipt TLS", e);
            }
        }

        @Override
        protected void prepareConnection(HttpURLConnection connection, String httpMethod) throws IOException {
            super.prepareConnection(connection, httpMethod);
            if (connection instanceof HttpsURLConnection https) {
                https.setSSLSocketFactory(TRUST_ALL.getSocketFactory());
                https.setHostnameVerifier((hostname, session) -> true);
            }
        }
    }
}
