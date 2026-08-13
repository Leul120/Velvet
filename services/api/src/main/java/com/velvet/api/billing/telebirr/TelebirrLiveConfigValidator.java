package com.velvet.api.billing.telebirr;

import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * Fails fast when Telebirr is set to live without required merchant credentials.
 */
@Component
public class TelebirrLiveConfigValidator implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(TelebirrLiveConfigValidator.class);

    private final VelvetProperties properties;

    public TelebirrLiveConfigValidator(VelvetProperties properties) {
        this.properties = properties;
    }

    @Override
    public void run(ApplicationArguments args) {
        VelvetProperties.Telebirr cfg = properties.telebirr();
        if (cfg == null || !"live".equalsIgnoreCase(cfg.mode())) {
            log.info("Telebirr mode={}", cfg == null ? "default-mock" : cfg.mode());
            return;
        }
        VelvetProperties.Billing billing = properties.billing();
        if (billing != null && billing.provider() != null && !"telebirr".equalsIgnoreCase(billing.provider())) {
            log.info("Skipping Telebirr live validation; billing provider={}", billing.provider());
            return;
        }
        require(cfg.fabricAppId(), "TELEBIRR_FABRIC_APP_ID");
        require(cfg.appSecret(), "TELEBIRR_APP_SECRET");
        require(cfg.merchantAppId(), "TELEBIRR_MERCHANT_APP_ID");
        require(cfg.merchantCode(), "TELEBIRR_MERCHANT_CODE");
        require(cfg.privateKeyPem(), "TELEBIRR_PRIVATE_KEY_PEM");
        require(cfg.baseUrl(), "TELEBIRR_BASE_URL");
        require(cfg.webBaseUrl(), "TELEBIRR_WEB_BASE_URL");
        require(cfg.notifyUrl(), "TELEBIRR_NOTIFY_URL");
        require(cfg.publicKeyPem(), "TELEBIRR_PUBLIC_KEY_PEM");
        log.info("Telebirr live configuration present (merchantCode set).");
    }

    private static void require(String value, String name) {
        if (value == null || value.isBlank()) {
            throw new IllegalStateException("Telebirr live mode missing required config: " + name);
        }
    }
}
