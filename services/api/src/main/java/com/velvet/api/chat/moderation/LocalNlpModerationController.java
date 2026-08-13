package com.velvet.api.chat.moderation;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

/**
 * Local Amharic/NLP assist stub for calibration.
 * Point {@code MODERATION_HTTP_URL} here when {@code MODERATION_PROVIDER=http}.
 *
 * Contract: POST { "text", "lang"? } → { "blocked", "held", "flags": [] }
 */
@RestController
@RequestMapping("/v1/internal/moderation")
public class LocalNlpModerationController {

    private final VelvetProperties properties;

    public LocalNlpModerationController(VelvetProperties properties) {
        this.properties = properties;
    }

    private static final List<Pattern> BLOCK = List.of(
            Pattern.compile("ልጅ|ሕፃን|ታዳጊ"),
            Pattern.compile("\\b(child|underage|traffick\\w*|pimp)\\b", Pattern.CASE_INSENSITIVE)
    );
    private static final List<Pattern> HOLD = List.of(
            Pattern.compile("ቴሌግራም|ዋትስአፕ|ስልኬ"),
            Pattern.compile("\\b(telegram|whatsapp|imo)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\+?251\\s*9\\d{8}|09\\d{8}")
    );

    @PostMapping("/score")
    public ResponseEntity<Map<String, Object>> score(
            @RequestHeader(value = "Authorization", required = false) String authorization,
            @RequestBody Map<String, Object> body
    ) {
        assertServiceKey(authorization);
        String text = body.get("text") == null ? "" : body.get("text").toString();
        String lang = body.get("lang") == null ? "am" : body.get("lang").toString().toLowerCase(Locale.ROOT);
        List<String> flags = new ArrayList<>();
        boolean blocked = false;
        boolean held = false;

        for (Pattern p : BLOCK) {
            if (p.matcher(text).find()) {
                blocked = true;
                flags.add("NLP_STUB_BLOCK");
                break;
            }
        }
        if (!blocked) {
            for (Pattern p : HOLD) {
                if (p.matcher(text).find()) {
                    held = true;
                    flags.add("NLP_STUB_HOLD");
                    break;
                }
            }
        }
        // Lightweight Amharic script density signal for calibration dashboards
        long amChars = text.codePoints().filter(cp -> cp >= 0x1200 && cp <= 0x137F).count();
        if (amChars > 0 && "am".equals(lang)) {
            flags.add("LANG_AM_DETECTED");
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("blocked", blocked);
        response.put("held", held);
        response.put("flags", flags);
        response.put("provider", "velvet-local-nlp-stub");
        return ResponseEntity.ok(response);
    }

    private void assertServiceKey(String authorization) {
        String expected = properties.moderation() == null ? null : properties.moderation().apiKey();
        if (expected == null || expected.isBlank() || !("Bearer " + expected).equals(authorization)) {
            throw new BusinessException("FORBIDDEN", "Internal moderation authentication failed.");
        }
    }
}
