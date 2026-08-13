package com.velvet.api.chat.moderation;

import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Combines local rules with optional HTTP Amharic/NLP moderation service.
 * HTTP provider posts { "text" } and expects { "blocked", "held", "flags": [] }.
 */
@Component
public class ModerationPipeline {

    private static final Logger log = LoggerFactory.getLogger(ModerationPipeline.class);

    private final ContentModerator rules;
    private final VelvetProperties properties;
    private final RestClient restClient = RestClient.create();

    public ModerationPipeline(ContentModerator rules, VelvetProperties properties) {
        this.rules = rules;
        this.properties = properties;
    }

    public ContentModerator.Result evaluate(String body) {
        ContentModerator.Result local = rules.evaluate(body);
        if (local.blocked()) {
            return local;
        }
        VelvetProperties.Moderation cfg = properties.moderation();
        if (cfg == null || cfg.provider() == null || !"http".equalsIgnoreCase(cfg.provider())) {
            return local;
        }
        if (cfg.httpUrl() == null || cfg.httpUrl().isBlank()) {
            return local;
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
                    .body(Map.of("text", body == null ? "" : body, "lang", "am"))
                    .retrieve()
                    .body(Map.class);
            if (response == null) {
                return local;
            }
            boolean blocked = Boolean.TRUE.equals(response.get("blocked"));
            boolean held = Boolean.TRUE.equals(response.get("held"));
            List<String> flags = new ArrayList<>(local.flags());
            Object rawFlags = response.get("flags");
            if (rawFlags instanceof List<?> list) {
                list.forEach(f -> flags.add(String.valueOf(f)));
            }
            if (blocked) {
                flags.add("NLP_BLOCK");
            } else if (held) {
                flags.add("NLP_HOLD");
            }
            return new ContentModerator.Result(blocked || local.blocked(), held || local.held(), flags);
        } catch (Exception e) {
            log.warn("External moderation failed; using local rules only", e);
            return local;
        }
    }

    public boolean matchesIcebreaker(String body, List<String> allowed) {
        return rules.matchesIcebreaker(body, allowed);
    }
}
