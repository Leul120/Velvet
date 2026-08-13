package com.velvet.api.chat.moderation;

import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Pattern;

/**
 * Rule-based EN + Amharic filter for the adult marketplace.
 * Blocks CSAE cues, coercion/trafficking signals, and off-platform contact.
 * Adult booking language (rates, hotels, private meets) is allowed between consenting adults.
 */
@Component
public class ContentModerator {

    private static final List<Pattern> BLOCK = List.of(
            // Minors / CSAE
            Pattern.compile("\\b(child|underage|teen\\s*girl|loli|cp\\b|minor)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("ልጅ|ሕፃን|ታዳጊ"),
            // Coercion / trafficking
            Pattern.compile("\\b(force(d)?\\s*sex|traffick\\w*|pimp\\b|sell\\s*her)\\b", Pattern.CASE_INSENSITIVE),
            // Off-platform contact — keep blocked so bookings stay in-app
            Pattern.compile("https?://\\S+|www\\.\\S+", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b[\\w.+-]+@[\\w.-]+\\.[a-z]{2,}\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\+?251[\\s-]*9[\\d\\s-]{8}|\\b09[\\d\\s-]{8}\\b"),
            Pattern.compile("\\b(\\d[\\s.-]*){9,}\\b"),
            Pattern.compile("\\b(telegram|whatsapp|imo|signal|viber|tiktok)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("\\b(call me|phone me|my number|dm me|text me)\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("ስልኬ|የስልክ ቁጥሬ|ቴሌግራም|ዋትስአፕ|ኢሜይል")
    );

    private static final List<Pattern> HOLD = List.of(
            Pattern.compile("\\b(\\d+\\s+\\w+\\s+(st|street|ave|road|kebele|woreda))\\b", Pattern.CASE_INSENSITIVE),
            Pattern.compile("ቀበሌ|ወረዳ|ቤት ቁጥር|አድራሻ")
    );

    public record Result(boolean blocked, boolean held, List<String> flags) {}

    public Result evaluate(String body) {
        if (body == null || body.isBlank()) {
            return new Result(true, false, List.of("EMPTY"));
        }
        String text = body.trim();
        List<String> flags = new ArrayList<>();
        for (Pattern p : BLOCK) {
            if (p.matcher(text).find()) {
                if (p.pattern().contains("http") || p.pattern().contains("@") || p.pattern().contains("251")
                        || p.pattern().contains("telegram") || p.pattern().contains("call me")
                        || p.pattern().contains("ስልኬ")) {
                    if (!flags.contains("OFFPLATFORM_CONTACT")) {
                        flags.add("OFFPLATFORM_CONTACT");
                    }
                } else if (p.pattern().toLowerCase(Locale.ROOT).contains("child")
                        || p.pattern().contains("ልጅ")
                        || p.pattern().contains("traffick")
                        || p.pattern().contains("force")) {
                    if (!flags.contains("SAFETY_BLOCK")) {
                        flags.add("SAFETY_BLOCK");
                    }
                } else if (!flags.contains("BLOCK")) {
                    flags.add("BLOCK");
                }
            }
        }
        for (Pattern p : HOLD) {
            if (p.matcher(text).find()) {
                flags.add("PRIVATE_ADDRESS_SUSPECT");
            }
        }
        boolean blocked = flags.contains("BLOCK")
                || flags.contains("SAFETY_BLOCK")
                || flags.contains("EMPTY")
                || flags.contains("OFFPLATFORM_CONTACT");
        boolean held = !blocked && !flags.isEmpty();
        return new Result(blocked, held, flags);
    }

    public boolean matchesIcebreaker(String body, List<String> allowedTexts) {
        if (body == null) {
            return false;
        }
        String normalized = normalize(body);
        return allowedTexts.stream().map(this::normalize).anyMatch(normalized::equals);
    }

    private String normalize(String s) {
        return s.trim().toLowerCase(Locale.ROOT).replaceAll("\\s+", " ");
    }
}
