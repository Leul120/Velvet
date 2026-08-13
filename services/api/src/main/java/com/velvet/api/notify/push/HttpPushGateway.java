package com.velvet.api.notify.push;

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
 * Posts to a configurable FCM proxy / Cloud Function:
 * { "token", "title", "body" } with optional Bearer api-key.
 */
@Component
@ConditionalOnProperty(name = "velvet.push.provider", havingValue = "http")
public class HttpPushGateway implements PushGateway {

    private static final Logger log = LoggerFactory.getLogger(HttpPushGateway.class);

    private final VelvetProperties properties;
    private final RestClient restClient = RestClient.create();

    public HttpPushGateway(VelvetProperties properties) {
        this.properties = properties;
    }

    @Override
    public String send(String deviceToken, String title, String body) {
        VelvetProperties.Push cfg = properties.push();
        if (cfg == null || cfg.httpUrl() == null || cfg.httpUrl().isBlank()) {
            throw new BusinessException("PUSH_CONFIG", "velvet.push.http-url is required for http provider.");
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
                            "token", deviceToken,
                            "title", title,
                            "body", body
                    ))
                    .retrieve()
                    .body(Map.class);
            Object id = response == null ? null : response.getOrDefault("id", response.get("messageId"));
            log.info("Push sent via HTTP tokenSuffix={} id={}",
                    deviceToken.length() > 4 ? deviceToken.substring(deviceToken.length() - 4) : "****", id);
            return id == null ? "HTTP_OK" : id.toString();
        } catch (Exception e) {
            log.error("Push HTTP send failed", e);
            throw new BusinessException("PUSH_FAILED", "Could not send push notification.");
        }
    }
}
