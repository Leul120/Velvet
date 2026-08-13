package com.velvet.api.billing.cbe;

import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * Fails fast when a configured CBE verification mode lacks its prerequisites.
 */
@Component
public class CbeLiveConfigValidator implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(CbeLiveConfigValidator.class);

    private final VelvetProperties properties;

    public CbeLiveConfigValidator(VelvetProperties properties) {
        this.properties = properties;
    }

    @Override
    public void run(ApplicationArguments args) {
        VelvetProperties.Billing billing = properties.billing();
        if (billing != null && billing.provider() != null && !"cbe".equalsIgnoreCase(billing.provider())) {
            return;
        }
        VelvetProperties.CbeVerifier cfg = properties.cbeVerifier();
        if (cfg == null || "mock".equalsIgnoreCase(cfg.mode())) {
            log.info("CBE verifier mode={}", cfg == null ? "default-mock" : cfg.mode());
            return;
        }
        VelvetProperties.CbePayment pay = properties.cbePayment();
        if (pay == null || pay.accountSuffix() == null || !pay.accountSuffix().matches("\\d{8}")) {
            throw new IllegalStateException("CBE verification requires an 8-digit CBE_ACCOUNT_SUFFIX");
        }
        if ("direct".equalsIgnoreCase(cfg.mode())) {
            log.warn("CBE direct receipt mode enabled (public receipt endpoint; no verifier API key).");
            return;
        }
        if (!"live".equalsIgnoreCase(cfg.mode())) {
            throw new IllegalStateException("CBE_VERIFIER_MODE must be mock, direct, or live");
        }
        if (cfg.apiKey() == null || cfg.apiKey().isBlank()) {
            throw new IllegalStateException("CBE_VERIFIER_MODE=live requires CBE_VERIFIER_API_KEY (https://verify.leul.et)");
        }
        if (cfg.baseUrl() == null || cfg.baseUrl().isBlank()) {
            throw new IllegalStateException("CBE_VERIFIER_MODE=live requires CBE_VERIFIER_BASE_URL");
        }
        log.info("CBE live verifier configuration present.");
    }
}
