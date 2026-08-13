package com.velvet.api.notify.sms;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(name = "velvet.sms.provider", havingValue = "log", matchIfMissing = true)
public class LoggingSmsGateway implements SmsGateway {

    private static final Logger log = LoggerFactory.getLogger(LoggingSmsGateway.class);

    @Override
    public String send(String e164Phone, String message) {
        log.warn("[SMS:LOG] to={} body={}", e164Phone, message);
        return "LOGGED";
    }
}
