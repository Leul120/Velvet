package com.velvet.api.admin.service;

import com.velvet.api.common.config.VelvetProperties;
import org.springframework.stereotype.Service;

import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class OpsReadinessService {

    private final VelvetProperties properties;

    public OpsReadinessService(VelvetProperties properties) {
        this.properties = properties;
    }

    public Map<String, Object> readiness() {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("env", properties.env() == null ? "local" : properties.env());
        out.put("billingProvider", billingProvider());
        out.put("sms", sms());
        out.put("push", push());
        out.put("cbe", cbe());
        out.put("telebirr", telebirr());
        out.put("moderation", moderation());
        out.put("otpExpose", properties.otp() != null && properties.otp().exposeInResponse());
        out.put("geofenceRequired", properties.concierge() != null && properties.concierge().requireGeofence());
        out.put("legalVersion", properties.legal() == null ? null : properties.legal().documentSetVersion());
        out.put("readyForSoftLaunch", softLaunchReady(out));
        out.put("readyForProduction", productionReady(out));
        return out;
    }

    private String billingProvider() {
        VelvetProperties.Billing billing = properties.billing();
        if (billing == null || billing.provider() == null || billing.provider().isBlank()) {
            return "cbe";
        }
        return billing.provider().toLowerCase();
    }

    private Map<String, Object> sms() {
        VelvetProperties.Sms cfg = properties.sms();
        String provider = cfg == null || cfg.provider() == null ? "log" : cfg.provider();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("provider", provider);
        m.put("httpConfigured", cfg != null && notBlank(cfg.httpUrl()));
        m.put("productionReady", "http".equalsIgnoreCase(provider) && notBlank(cfg.httpUrl()));
        return m;
    }

    private Map<String, Object> push() {
        VelvetProperties.Push cfg = properties.push();
        String provider = cfg == null || cfg.provider() == null ? "log" : cfg.provider();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("provider", provider);
        m.put("httpConfigured", cfg != null && notBlank(cfg.httpUrl()));
        m.put("productionReady", "http".equalsIgnoreCase(provider) && notBlank(cfg.httpUrl()));
        return m;
    }

    private Map<String, Object> cbe() {
        VelvetProperties.CbeVerifier verifier = properties.cbeVerifier();
        VelvetProperties.CbePayment payment = properties.cbePayment();
        String mode = verifier == null || verifier.mode() == null ? "mock" : verifier.mode();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("mode", mode);
        m.put("baseUrlSet", verifier != null && notBlank(verifier.baseUrl()));
        m.put("apiKeySet", verifier != null && notBlank(verifier.apiKey()));
        m.put("accountSuffixSet", payment != null && notBlank(payment.accountSuffix()));
        m.put("productionReady", "live".equalsIgnoreCase(mode)
                && Boolean.TRUE.equals(m.get("baseUrlSet"))
                && Boolean.TRUE.equals(m.get("apiKeySet"))
                && Boolean.TRUE.equals(m.get("accountSuffixSet")));
        return m;
    }

    private Map<String, Object> telebirr() {
        VelvetProperties.Telebirr cfg = properties.telebirr();
        String mode = cfg == null || cfg.mode() == null ? "mock" : cfg.mode();
        boolean live = "live".equalsIgnoreCase(mode);
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("mode", mode);
        m.put("notifyUrlSet", cfg != null && notBlank(cfg.notifyUrl()));
        m.put("publicKeySet", cfg != null && notBlank(cfg.publicKeyPem()));
        m.put("merchantConfigured", cfg != null
                && notBlank(cfg.fabricAppId())
                && notBlank(cfg.appSecret())
                && notBlank(cfg.merchantAppId())
                && notBlank(cfg.merchantCode())
                && notBlank(cfg.privateKeyPem())
                && notBlank(cfg.baseUrl())
                && notBlank(cfg.webBaseUrl()));
        m.put("productionReady", live
                && Boolean.TRUE.equals(m.get("merchantConfigured"))
                && Boolean.TRUE.equals(m.get("notifyUrlSet"))
                && Boolean.TRUE.equals(m.get("publicKeySet")));
        return m;
    }

    private Map<String, Object> moderation() {
        VelvetProperties.Moderation cfg = properties.moderation();
        String provider = cfg == null || cfg.provider() == null ? "rule" : cfg.provider();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("provider", provider);
        m.put("httpConfigured", cfg != null && notBlank(cfg.httpUrl()));
        m.put("productionReady", "http".equalsIgnoreCase(provider) && notBlank(cfg.httpUrl())
                || "rule".equalsIgnoreCase(provider));
        return m;
    }

    @SuppressWarnings("unchecked")
    private boolean softLaunchReady(Map<String, Object> out) {
        Map<String, Object> cbe = (Map<String, Object>) out.get("cbe");
        boolean otpSafe = !Boolean.TRUE.equals(out.get("otpExpose")) || !properties.isProduction();
        return cbe != null
                && Boolean.TRUE.equals(cbe.get("accountSuffixSet"))
                && otpSafe;
    }

    @SuppressWarnings("unchecked")
    private boolean productionReady(Map<String, Object> out) {
        if (Boolean.TRUE.equals(out.get("otpExpose"))) {
            return false;
        }
        Map<String, Object> sms = (Map<String, Object>) out.get("sms");
        Map<String, Object> push = (Map<String, Object>) out.get("push");
        String billing = String.valueOf(out.get("billingProvider"));
        boolean paymentsOk;
        if ("telebirr".equalsIgnoreCase(billing)) {
            Map<String, Object> telebirr = (Map<String, Object>) out.get("telebirr");
            paymentsOk = telebirr != null && Boolean.TRUE.equals(telebirr.get("productionReady"));
        } else {
            Map<String, Object> cbe = (Map<String, Object>) out.get("cbe");
            paymentsOk = cbe != null && Boolean.TRUE.equals(cbe.get("productionReady"));
        }
        return paymentsOk
                && sms != null && Boolean.TRUE.equals(sms.get("productionReady"))
                && push != null && Boolean.TRUE.equals(push.get("productionReady"));
    }

    private static boolean notBlank(String s) {
        return s != null && !s.isBlank();
    }
}
