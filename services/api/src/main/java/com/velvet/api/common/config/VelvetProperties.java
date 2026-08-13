package com.velvet.api.common.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "velvet")
public record VelvetProperties(
        String env,
        Jwt jwt,
        Otp otp,
        Invites invites,
        Cors cors,
        Admin admin,
        Jobs jobs,
        Storage storage,
        Telebirr telebirr,
        Concierge concierge,
        Sms sms,
        Push push,
        RateLimits rateLimits,
        Moderation moderation,
        Billing billing,
        CbeVerifier cbeVerifier,
        CbePayment cbePayment,
        Legal legal,
        Retention retention,
        Seed seed
) {
    public record Jwt(String secret, long accessTokenMinutes, long refreshTokenDays) {}
    public record Otp(int length, long ttlSeconds, int maxAttempts, boolean exposeInResponse) {}
    public record Invites(String bootstrapCode) {}
    public record Cors(String allowedOrigins) {}
    public record Admin(String bootstrapPhone) {}
    public record Jobs(long matchExpiryMs, long subscriptionExpiryMs, long bookingReminderMs, long dataRetentionMs) {}
    public record Storage(
            String endpoint,
            String region,
            String accessKey,
            String secretKey,
            String bucket,
            String publicBaseUrl
    ) {}
    public record Telebirr(
            String mode,
            String mockBaseUrl,
            String baseUrl,
            String webBaseUrl,
            String fabricAppId,
            String appSecret,
            String merchantAppId,
            String merchantCode,
            String privateKeyPem,
            String publicKeyPem,
            String notifyUrl,
            String returnUrl
    ) {}
    public record Concierge(String smsPhones, boolean requireGeofence) {}
    public record Sms(String provider, String httpUrl, String apiKey, String senderId) {}
    public record Push(String provider, String httpUrl, String apiKey) {}
    public record RateLimits(int otpPerHour, int chatPerMinute, int panicPerHour, int reportPerHour) {}
    public record Moderation(String provider, String httpUrl, String apiKey) {}
    /** cbe | telebirr — default membership payment rails */
    public record Billing(String provider) {}
    /** mock | live — Leul verifier-api integration */
    public record CbeVerifier(String mode, String baseUrl, String apiKey) {}
    public record CbePayment(String accountName, String accountNumber, String accountSuffix, String bankName) {}
    /** Soft-launch legal document set version members must accept. */
    public record Legal(String documentSetVersion) {}
    /** PDPP-aligned retention windows (days). */
    public record Retention(int locationDays) {}
    /** Local demo roster — wipe + reseed on API boot when enabled. */
    public record Seed(boolean resetOnStartup) {}

    public boolean isProduction() {
        return env != null && "production".equalsIgnoreCase(env.trim());
    }

    public boolean shouldResetDemoSeed() {
        return seed != null && seed.resetOnStartup() && !isProduction();
    }
}
