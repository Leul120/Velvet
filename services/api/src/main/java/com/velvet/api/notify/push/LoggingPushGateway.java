package com.velvet.api.notify.push;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(name = "velvet.push.provider", havingValue = "log", matchIfMissing = true)
public class LoggingPushGateway implements PushGateway {

    private static final Logger log = LoggerFactory.getLogger(LoggingPushGateway.class);

    @Override
    public String send(String deviceToken, String title, String body) {
        log.warn("[PUSH:LOG] token={} title={} body={}", mask(deviceToken), title, body);
        return "LOGGED";
    }

    private static String mask(String token) {
        if (token == null || token.length() < 8) {
            return "****";
        }
        return token.substring(0, 4) + "…" + token.substring(token.length() - 4);
    }
}
