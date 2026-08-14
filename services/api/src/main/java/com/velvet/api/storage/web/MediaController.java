package com.velvet.api.storage.web;

import com.velvet.api.storage.ObjectStorageService;
import com.velvet.api.chat.domain.ChatThreadEntity;
import com.velvet.api.chat.repo.ChatThreadRepository;
import com.velvet.api.chat.repo.MessageRepository;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.identity.domain.UserRole;
import com.velvet.api.identity.security.VelvetPrincipal;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.AntPathMatcher;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.HandlerMapping;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.UUID;

@RestController
@RequestMapping("/v1/media")
public class MediaController {

    private static final Logger log = LoggerFactory.getLogger(MediaController.class);

    private final ObjectStorageService storageService;
    private final MessageRepository messageRepository;
    private final ChatThreadRepository threadRepository;
    private final AntPathMatcher pathMatcher = new AntPathMatcher();

    public MediaController(
            ObjectStorageService storageService,
            MessageRepository messageRepository,
            ChatThreadRepository threadRepository
    ) {
        this.storageService = storageService;
        this.messageRepository = messageRepository;
        this.threadRepository = threadRepository;
    }

    @GetMapping("/**")
    public ResponseEntity<StreamingResponseBody> get(
            HttpServletRequest request,
            @AuthenticationPrincipal VelvetPrincipal principal
    ) {
        String full = (String) request.getAttribute(HandlerMapping.PATH_WITHIN_HANDLER_MAPPING_ATTRIBUTE);
        String pattern = (String) request.getAttribute(HandlerMapping.BEST_MATCHING_PATTERN_ATTRIBUTE);
        String key = pathMatcher.extractPathWithinPattern(pattern == null ? "/v1/media/**" : pattern, full);
        if (key == null || key.isBlank()) {
            return ResponseEntity.notFound().build();
        }
        assertCanRead(key, principal);

        ObjectStorageService.MediaStream media;
        try {
            media = storageService.open(key);
        } catch (BusinessException ex) {
            if ("NOT_FOUND".equals(ex.getCode())) {
                return ResponseEntity.notFound().build();
            }
            throw ex;
        }
        StreamingResponseBody body = output -> {
            try (media) {
                media.body().transferTo(output);
            } catch (IOException ex) {
                // Headers are already image/jpeg; do not rethrow or the JSON error mapper fails.
                log.debug("Media stream ended early for {}: {}", key, ex.getMessage());
            }
        };

        ResponseEntity.BodyBuilder builder = ResponseEntity.ok()
                .header(HttpHeaders.CACHE_CONTROL, "private, max-age=3600")
                .header("X-Content-Type-Options", "nosniff")
                .contentType(MediaType.parseMediaType(media.contentType()));
        if (media.contentLength() >= 0) {
            builder.header(HttpHeaders.CONTENT_LENGTH, Long.toString(media.contentLength()));
        }
        return builder.body(body);
    }

    private void assertCanRead(String key, VelvetPrincipal principal) {
        if (key.startsWith("profile/")) {
            // Listing photos are the sole public media class.
            return;
        }
        if (principal == null) {
            throw new BusinessException("FORBIDDEN", "Sign in required to view media.");
        }
        if (isStaff(principal)) {
            return;
        }
        UUID userId = principal.getUserId();
        if (key.startsWith("verification/") || key.startsWith("payments/")) {
            if (key.contains("/" + userId + "/")) {
                return;
            }
            throw new BusinessException("FORBIDDEN", "You do not have access to this media.");
        }
        if (key.startsWith("chat/")) {
            String relativeUrl = "/v1/media/" + key;
            boolean participant = messageRepository.findForMediaKey(relativeUrl, key).stream()
                    .map(message -> threadRepository.findById(message.getThreadId()).orElse(null))
                    .filter(java.util.Objects::nonNull)
                    .anyMatch(thread -> isParticipant(thread, userId));
            if (participant) {
                return;
            }
        }
        throw new BusinessException("FORBIDDEN", "You do not have access to this media.");
    }

    private static boolean isParticipant(ChatThreadEntity thread, UUID userId) {
        return userId.equals(thread.getMemberAId()) || userId.equals(thread.getMemberBId());
    }

    private static boolean isStaff(VelvetPrincipal principal) {
        return principal.getRole() == UserRole.ADMIN || principal.getRole() == UserRole.CONCIERGE;
    }

}
