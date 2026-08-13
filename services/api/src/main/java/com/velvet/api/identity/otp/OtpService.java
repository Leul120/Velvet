package com.velvet.api.identity.otp;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import com.velvet.api.notify.sms.SmsGateway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.concurrent.TimeUnit;

@Service
public class OtpService {

    private static final Logger log = LoggerFactory.getLogger(OtpService.class);
    private static final String KEY_PREFIX = "otp:";
    private static final String ATTEMPTS_PREFIX = "otp:attempts:";

    private final StringRedisTemplate redis;
    private final VelvetProperties properties;
    private final SmsGateway smsGateway;
    private final SecureRandom random = new SecureRandom();

    public OtpService(StringRedisTemplate redis, VelvetProperties properties, SmsGateway smsGateway) {
        this.redis = redis;
        this.properties = properties;
        this.smsGateway = smsGateway;
    }

    public String issue(String phoneE164) {
        String code = generateCode(properties.otp().length());
        String key = KEY_PREFIX + phoneE164;
        redis.opsForValue().set(key, code, Duration.ofSeconds(properties.otp().ttlSeconds()));
        redis.delete(ATTEMPTS_PREFIX + phoneE164);
        log.info("OTP issued for phone ending {}", mask(phoneE164));

        String message = "VELVET code: " + code + ". Valid for a few minutes. Do not share.";
        try {
            smsGateway.send(phoneE164, message);
        } catch (Exception e) {
            log.error("OTP SMS failed for {}", mask(phoneE164), e);
            if (!properties.otp().exposeInResponse()) {
                throw new BusinessException("OTP_SMS_FAILED", "Could not send verification SMS. Try again.");
            }
        }
        return code;
    }

    public void verify(String phoneE164, String code) {
        String attemptsKey = ATTEMPTS_PREFIX + phoneE164;
        Long attempts = redis.opsForValue().increment(attemptsKey);
        if (attempts != null && attempts == 1L) {
            redis.expire(attemptsKey, properties.otp().ttlSeconds(), TimeUnit.SECONDS);
        }
        if (attempts != null && attempts > properties.otp().maxAttempts()) {
            throw new BusinessException("OTP_LOCKED", "Too many OTP attempts. Request a new code.");
        }

        String key = KEY_PREFIX + phoneE164;
        String expected = redis.opsForValue().get(key);
        if (expected == null) {
            throw new BusinessException("OTP_EXPIRED", "OTP expired or not requested.");
        }
        if (!expected.equals(code)) {
            throw new BusinessException("OTP_INVALID", "Invalid OTP code.");
        }
        redis.delete(key);
        redis.delete(attemptsKey);
    }

    private String generateCode(int length) {
        int bound = (int) Math.pow(10, length);
        int min = bound / 10;
        int value = min + random.nextInt(bound - min);
        return String.valueOf(value);
    }

    private static String mask(String phone) {
        if (phone == null || phone.length() < 4) {
            return "****";
        }
        return "****" + phone.substring(phone.length() - 4);
    }
}
