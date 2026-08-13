package com.velvet.api.notify.web;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;
import java.util.UUID;

/**
 * Local FCM-proxy stand-in for {@code PUSH_PROVIDER=http}.
 * Point {@code PUSH_HTTP_URL} at {@code http://localhost:8080/v1/internal/push/deliver}.
 */
@RestController
@RequestMapping("/v1/internal/push")
public class LocalPushProxyController {

    private static final Logger log = LoggerFactory.getLogger(LocalPushProxyController.class);
    private final VelvetProperties properties;

    public LocalPushProxyController(VelvetProperties properties) {
        this.properties = properties;
    }

    @PostMapping("/deliver")
    public ResponseEntity<Map<String, String>> deliver(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody Map<String, Object> body
    ) {
        assertServiceKey(authorization);
        String id = "local-" + UUID.randomUUID();
        log.info("Local push proxy deliver id={} tokenSuffix={} title={} body={}",
                id,
                suffix(String.valueOf(body.get("token"))),
                body.get("title"),
                body.get("body"));
        return ResponseEntity.ok(Map.of("id", id, "messageId", id));
    }

    private static String suffix(String token) {
        if (token == null || token.length() < 4) return "****";
        return token.substring(token.length() - 4);
    }

    private void assertServiceKey(String authorization) {
        String expected = properties.push() == null ? null : properties.push().apiKey();
        if (expected == null || expected.isBlank() || !("Bearer " + expected).equals(authorization)) {
            throw new BusinessException("FORBIDDEN", "Internal push authentication failed.");
        }
    }
}
