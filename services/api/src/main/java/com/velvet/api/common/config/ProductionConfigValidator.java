package com.velvet.api.common.config;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

/**
 * When {@code velvet.env=production}, refuse to boot with mock/log shortcuts.
 */
@Component
public class ProductionConfigValidator implements ApplicationRunner {

    private static final Logger log = LoggerFactory.getLogger(ProductionConfigValidator.class);

    private final VelvetProperties properties;

    public ProductionConfigValidator(VelvetProperties properties) {
        this.properties = properties;
    }

    @Override
    public void run(ApplicationArguments args) {
        if (!properties.isProduction()) {
            log.info("VELVET_ENV={} (non-production; mock/log providers allowed)", properties.env());
            return;
        }
        log.info("Production config validation starting…");

        if (properties.otp() != null && properties.otp().exposeInResponse()) {
            fail("OTP_EXPOSE must be false in production");
        }
        if (properties.cors() == null || blank(properties.cors().allowedOrigins())
                || "*".equals(properties.cors().allowedOrigins().trim())) {
            fail("CORS_ORIGINS must name explicit trusted origins in production");
        }
        String jwt = properties.jwt() == null ? null : properties.jwt().secret();
        if (jwt == null || jwt.isBlank() || jwt.contains("change-me") || jwt.length() < 32) {
            fail("JWT_SECRET must be a strong secret (≥32 chars, not the default) in production");
        }
        String billing = properties.billing() == null || properties.billing().provider() == null
                ? "cbe"
                : properties.billing().provider();
        if ("cbe".equalsIgnoreCase(billing)) {
            VelvetProperties.CbeVerifier v = properties.cbeVerifier();
            if (v == null || (!"live".equalsIgnoreCase(v.mode()) && !"direct".equalsIgnoreCase(v.mode()))) {
                fail("CBE_VERIFIER_MODE=live or direct is required in production when BILLING_PROVIDER=cbe");
            }
            if ("live".equalsIgnoreCase(v.mode())) {
                require(v.apiKey(), "CBE_VERIFIER_API_KEY");
                require(v.baseUrl(), "CBE_VERIFIER_BASE_URL");
            }
            VelvetProperties.CbePayment pay = properties.cbePayment();
            if (pay == null || blank(pay.accountSuffix()) || blank(pay.accountNumber())) {
                fail("CBE_ACCOUNT_NUMBER and CBE_ACCOUNT_SUFFIX are required in production");
            }
        } else if ("telebirr".equalsIgnoreCase(billing)) {
            VelvetProperties.Telebirr telebirr = properties.telebirr();
            if (telebirr == null || !"live".equalsIgnoreCase(telebirr.mode())) {
                fail("TELEBIRR_MODE=live is required in production when BILLING_PROVIDER=telebirr");
            }
            require(telebirr.fabricAppId(), "TELEBIRR_FABRIC_APP_ID");
            require(telebirr.appSecret(), "TELEBIRR_APP_SECRET");
            require(telebirr.merchantAppId(), "TELEBIRR_MERCHANT_APP_ID");
            require(telebirr.merchantCode(), "TELEBIRR_MERCHANT_CODE");
            require(telebirr.privateKeyPem(), "TELEBIRR_PRIVATE_KEY_PEM");
            require(telebirr.publicKeyPem(), "TELEBIRR_PUBLIC_KEY_PEM");
            require(telebirr.baseUrl(), "TELEBIRR_BASE_URL");
            require(telebirr.webBaseUrl(), "TELEBIRR_WEB_BASE_URL");
            require(telebirr.notifyUrl(), "TELEBIRR_NOTIFY_URL");
        } else {
            fail("BILLING_PROVIDER must be cbe or telebirr in production");
        }

        VelvetProperties.Sms sms = properties.sms();
        if (sms == null || !"http".equalsIgnoreCase(sms.provider()) || blank(sms.httpUrl()) || blank(sms.apiKey())) {
            fail("SMS_PROVIDER=http, SMS_HTTP_URL, and SMS_API_KEY are required in production");
        }
        VelvetProperties.Push push = properties.push();
        if (push == null || !"http".equalsIgnoreCase(push.provider()) || blank(push.httpUrl()) || blank(push.apiKey())) {
            fail("PUSH_PROVIDER=http, PUSH_HTTP_URL, and PUSH_API_KEY are required in production");
        }
        VelvetProperties.Moderation moderation = properties.moderation();
        if (moderation != null && "http".equalsIgnoreCase(moderation.provider())
                && (blank(moderation.httpUrl()) || blank(moderation.apiKey()))) {
            fail("MODERATION_HTTP_URL and MODERATION_API_KEY are required when MODERATION_PROVIDER=http in production");
        }

        if (properties.seed() != null && properties.seed().resetOnStartup()) {
            fail("VELVET_SEED_RESET must be false in production");
        }
        String bootstrapPhone = properties.admin() == null ? null : properties.admin().bootstrapPhone();
        if ("+251911000000".equals(bootstrapPhone)) {
            fail("ADMIN_BOOTSTRAP_PHONE must not use the development default in production");
        }

        log.info("Production configuration validation passed.");
    }

    private static void require(String value, String name) {
        if (blank(value)) {
            fail("Missing required production config: " + name);
        }
    }

    private static boolean blank(String s) {
        return s == null || s.isBlank();
    }

    private static void fail(String message) {
        throw new IllegalStateException(message);
    }
}
