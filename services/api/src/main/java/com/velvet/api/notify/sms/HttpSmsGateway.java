package com.velvet.api.notify.sms;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.Map;

/**
 * Generic HTTP SMS provider (Ethio Telecom / aggregator webhook style).
 * Configure velvet.sms.http-url + api-key from your SMS vendor.
 */
@Component
@ConditionalOnProperty(name = "velvet.sms.provider", havingValue = "http")
public class HttpSmsGateway implements SmsGateway {

    private static final Logger log = LoggerFactory.getLogger(HttpSmsGateway.class);

    private final VelvetProperties properties;
    private final RestClient restClient = RestClient.create();

    public HttpSmsGateway(VelvetProperties properties) {
        this.properties = properties;
    }

    @Override
    public String send(String e164Phone, String message) {
        VelvetProperties.Sms cfg = properties.sms();
        if (cfg == null || cfg.httpUrl() == null || cfg.httpUrl().isBlank()) {
            throw new BusinessException("SMS_CONFIG", "velvet.sms.http-url is required for http provider.");
        }
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> response = restClient.post()
                    .uri(cfg.httpUrl())
                    .contentType(MediaType.APPLICATION_JSON)
                    .headers(h -> {
                        if (cfg.apiKey() != null && !cfg.apiKey().isBlank()) {
                            h.setBearerAuth(cfg.apiKey());
                        }
                    })
                    .body(Map.of(
                            "to", e164Phone,
                            "from", cfg.senderId() == null ? "VELVET" : cfg.senderId(),
                            "message", message
                    ))
                    .retrieve()
                    .body(Map.class);
            Object id = response == null ? null : response.getOrDefault("id", response.get("messageId"));
            log.info("SMS sent via HTTP to={} id={}", e164Phone, id);
            return id == null ? "HTTP_OK" : id.toString();
        } catch (Exception e) {
            log.error("SMS HTTP send failed to={}", e164Phone, e);
            throw new BusinessException("SMS_FAILED", "Could not send SMS via provider.");
        }
    }
}
