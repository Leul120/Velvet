package com.velvet.api.common.ratelimit;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
public class RateLimitService {

    private final StringRedisTemplate redis;
    private final VelvetProperties properties;

    public RateLimitService(StringRedisTemplate redis, VelvetProperties properties) {
        this.redis = redis;
        this.properties = properties;
    }

    public void checkOtp(String phoneE164) {
        VelvetProperties.RateLimits cfg = limits();
        enforce("rl:otp:" + phoneE164, cfg.otpPerHour(), Duration.ofHours(1), "OTP_RATE_LIMIT");
    }

    public void checkChat(String userId) {
        VelvetProperties.RateLimits cfg = limits();
        enforce("rl:chat:" + userId, cfg.chatPerMinute(), Duration.ofMinutes(1), "CHAT_RATE_LIMIT");
    }

    public void checkPanic(String userId) {
        VelvetProperties.RateLimits cfg = limits();
        enforce("rl:panic:" + userId, cfg.panicPerHour(), Duration.ofHours(1), "PANIC_RATE_LIMIT");
    }

    public void checkReport(String userId) {
        VelvetProperties.RateLimits cfg = limits();
        enforce("rl:report:" + userId, cfg.reportPerHour(), Duration.ofHours(1), "REPORT_RATE_LIMIT");
    }

    public void checkWaitlist(String phone) {
        enforce("rl:waitlist:" + phone, 5, Duration.ofHours(1), "WAITLIST_RATE_LIMIT");
    }

    private void enforce(String key, int max, Duration window, String code) {
        if (max <= 0) {
            return;
        }
        Long count = redis.opsForValue().increment(key);
        if (count != null && count == 1L) {
            redis.expire(key, window);
        }
        if (count != null && count > max) {
            throw new BusinessException(code, "Too many requests. Please wait and try again.");
        }
    }

    private VelvetProperties.RateLimits limits() {
        VelvetProperties.RateLimits cfg = properties.rateLimits();
        if (cfg == null) {
            return new VelvetProperties.RateLimits(10, 30, 3, 10);
        }
        return cfg;
    }
}
