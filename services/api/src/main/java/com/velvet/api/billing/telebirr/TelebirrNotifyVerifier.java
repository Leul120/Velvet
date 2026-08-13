package com.velvet.api.billing.telebirr;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.Signature;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Verifies Telebirr notify signatures in live mode when a public key is configured.
 */
@Component
public class TelebirrNotifyVerifier {

    private static final Logger log = LoggerFactory.getLogger(TelebirrNotifyVerifier.class);

    private final VelvetProperties properties;

    public TelebirrNotifyVerifier(VelvetProperties properties) {
        this.properties = properties;
    }

    public void verifyOrThrow(Map<String, Object> payload) {
        VelvetProperties.Telebirr cfg = properties.telebirr();
        if (cfg == null || "mock".equalsIgnoreCase(cfg.mode())) {
            return;
        }
        String publicKeyPem = cfg.publicKeyPem();
        if (publicKeyPem == null || publicKeyPem.isBlank()) {
            log.warn("Telebirr live notify received without publicKeyPem configured — skipping signature check");
            return;
        }
        Object signObj = payload.get("sign");
        if (signObj == null) {
            signObj = payload.get("signature");
        }
        if (signObj == null || signObj.toString().isBlank()) {
            throw new BusinessException("TELEBIRR_SIGN_MISSING", "Notify signature missing.");
        }
        String raw = payload.entrySet().stream()
                .filter(e -> e.getValue() != null)
                .filter(e -> !"sign".equals(e.getKey()) && !"signature".equals(e.getKey()) && !"sign_type".equals(e.getKey()))
                .sorted(Map.Entry.comparingByKey())
                .map(e -> e.getKey() + "=" + e.getValue())
                .collect(Collectors.joining("&"));
        if (!verifySha256Rsa(raw, signObj.toString(), publicKeyPem)) {
            throw new BusinessException("TELEBIRR_SIGN_INVALID", "Notify signature verification failed.");
        }
    }

    private static boolean verifySha256Rsa(String data, String signatureBase64, String publicKeyPem) {
        try {
            String normalized = publicKeyPem
                    .replace("-----BEGIN PUBLIC KEY-----", "")
                    .replace("-----END PUBLIC KEY-----", "")
                    .replaceAll("\\s", "");
            byte[] decoded = Base64.getDecoder().decode(normalized);
            PublicKey key = KeyFactory.getInstance("RSA").generatePublic(new X509EncodedKeySpec(decoded));
            Signature signature = Signature.getInstance("SHA256withRSA");
            signature.initVerify(key);
            signature.update(data.getBytes(StandardCharsets.UTF_8));
            return signature.verify(Base64.getDecoder().decode(signatureBase64));
        } catch (Exception e) {
            log.error("Telebirr signature verify error", e);
            return false;
        }
    }
}
