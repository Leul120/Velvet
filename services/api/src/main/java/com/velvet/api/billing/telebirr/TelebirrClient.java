package com.velvet.api.billing.telebirr;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.PrivateKey;
import java.security.Signature;
import java.security.spec.PKCS8EncodedKeySpec;
import java.util.Base64;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Telebirr H5 C2B client.
 * <ul>
 *   <li>{@code mock} — local checkout URL; no Ethio Telecom calls</li>
 *   <li>{@code live} — Fabric token + preOrder against configured base URL</li>
 * </ul>
 */
@Component
public class TelebirrClient {

    private static final Logger log = LoggerFactory.getLogger(TelebirrClient.class);

    private final VelvetProperties properties;
    private final RestClient restClient;

    public TelebirrClient(VelvetProperties properties) {
        this.properties = properties;
        this.restClient = RestClient.create();
    }

    public record CheckoutResult(String checkoutUrl, String providerRef) {}

    public CheckoutResult createCheckout(String merchantOrderId, String title, BigDecimal amountEtb) {
        VelvetProperties.Telebirr cfg = properties.telebirr();
        if (cfg == null || "mock".equalsIgnoreCase(cfg.mode())) {
            String url = cfg != null && cfg.mockBaseUrl() != null
                    ? cfg.mockBaseUrl().replaceAll("/$", "") + "/v1/billing/telebirr/mock-pay?orderId=" + merchantOrderId
                    : "http://localhost:8080/v1/billing/telebirr/mock-pay?orderId=" + merchantOrderId;
            log.info("Telebirr MOCK checkout for order {}", merchantOrderId);
            return new CheckoutResult(url, "MOCK-" + merchantOrderId);
        }
        return createLiveCheckout(merchantOrderId, title, amountEtb, cfg);
    }

    private CheckoutResult createLiveCheckout(
            String merchantOrderId,
            String title,
            BigDecimal amountEtb,
            VelvetProperties.Telebirr cfg
    ) {
        requireLiveConfig(cfg);
        String token = applyFabricToken(cfg);
        Map<String, Object> biz = new LinkedHashMap<>();
        biz.put("nonce_str", merchantOrderId.replace("-", ""));
        biz.put("method", "payment.preorder");
        biz.put("timestamp", String.valueOf(System.currentTimeMillis()));
        biz.put("version", "1.0");
        biz.put("biz_content", Map.of(
                "notify_url", cfg.notifyUrl(),
                "trade_type", "InApp",
                "appid", cfg.merchantAppId(),
                "merch_code", cfg.merchantCode(),
                "merch_order_id", merchantOrderId,
                "title", title,
                "total_amount", amountEtb.toPlainString(),
                "trans_currency", "ETB",
                "timeout_express", "120m"
        ));

        String rawToSign = biz.entrySet().stream()
                .filter(e -> !"sign".equals(e.getKey()) && e.getValue() != null)
                .sorted(Map.Entry.comparingByKey())
                .map(e -> e.getKey() + "=" + stringify(e.getValue()))
                .collect(Collectors.joining("&"));
        String sign = signSha256Rsa(rawToSign, cfg.privateKeyPem());
        biz.put("sign", sign);
        biz.put("sign_type", "SHA256WithRSA");

        @SuppressWarnings("unchecked")
        Map<String, Object> response = restClient.post()
                .uri(cfg.baseUrl().replaceAll("/$", "") + "/payment/v1/merchant/preOrder")
                .contentType(MediaType.APPLICATION_JSON)
                .header("X-APP-Key", cfg.fabricAppId())
                .header("Authorization", token)
                .body(biz)
                .retrieve()
                .body(Map.class);

        if (response == null) {
            throw new BusinessException("TELEBIRR_ERROR", "Empty response from Telebirr.");
        }
        Object result = response.get("biz_content");
        String prepayId = null;
        if (result instanceof Map<?, ?> map) {
            Object id = map.get("prepay_id");
            if (id != null) {
                prepayId = id.toString();
            }
        }
        if (prepayId == null) {
            log.error("Telebirr preOrder unexpected response: {}", response);
            throw new BusinessException("TELEBIRR_ERROR", "Telebirr did not return prepay_id. Check credentials/logs.");
        }
        String checkout = cfg.webBaseUrl().replaceAll("/$", "")
                + "?appid=" + cfg.merchantAppId()
                + "&merch_code=" + cfg.merchantCode()
                + "&prepay_id=" + prepayId;
        return new CheckoutResult(checkout, prepayId);
    }

    private String applyFabricToken(VelvetProperties.Telebirr cfg) {
        @SuppressWarnings("unchecked")
        Map<String, Object> response = restClient.post()
                .uri(cfg.baseUrl().replaceAll("/$", "") + "/payment/v1/token")
                .contentType(MediaType.APPLICATION_JSON)
                .body(Map.of(
                        "appSecret", cfg.appSecret()
                ))
                .header("X-APP-Key", cfg.fabricAppId())
                .retrieve()
                .body(Map.class);
        if (response == null || response.get("token") == null) {
            throw new BusinessException("TELEBIRR_TOKEN", "Could not obtain Telebirr fabric token.");
        }
        return response.get("token").toString();
    }

    private static void requireLiveConfig(VelvetProperties.Telebirr cfg) {
        if (isBlank(cfg.fabricAppId()) || isBlank(cfg.appSecret()) || isBlank(cfg.merchantAppId())
                || isBlank(cfg.merchantCode()) || isBlank(cfg.privateKeyPem())
                || isBlank(cfg.baseUrl()) || isBlank(cfg.webBaseUrl()) || isBlank(cfg.notifyUrl())) {
            throw new BusinessException(
                    "TELEBIRR_CONFIG",
                    "Telebirr live mode requires fabricAppId, appSecret, merchantAppId, merchantCode, privateKeyPem, baseUrl, webBaseUrl, notifyUrl."
            );
        }
    }

    private static boolean isBlank(String s) {
        return s == null || s.isBlank();
    }

    private static String stringify(Object value) {
        if (value instanceof Map<?, ?> map) {
            return map.entrySet().stream()
                    .sorted(Map.Entry.comparingByKey(Comparator.comparing(Object::toString)))
                    .map(e -> e.getKey() + "=" + stringify(e.getValue()))
                    .collect(Collectors.joining("&", "{", "}"));
        }
        return String.valueOf(value);
    }

    private static String signSha256Rsa(String data, String privateKeyPem) {
        try {
            String normalized = privateKeyPem
                    .replace("-----BEGIN PRIVATE KEY-----", "")
                    .replace("-----END PRIVATE KEY-----", "")
                    .replaceAll("\\s", "");
            byte[] decoded = Base64.getDecoder().decode(normalized);
            PrivateKey key = KeyFactory.getInstance("RSA").generatePrivate(new PKCS8EncodedKeySpec(decoded));
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initSign(key);
            signature.update(data.getBytes(StandardCharsets.UTF_8));
            return Base64.getEncoder().encodeToString(signature.sign());
        } catch (Exception e) {
            throw new BusinessException("TELEBIRR_SIGN", "Failed to sign Telebirr payload.");
        }
    }
}
