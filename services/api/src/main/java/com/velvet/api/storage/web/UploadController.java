package com.velvet.api.storage.web;

import com.velvet.api.identity.security.VelvetPrincipal;
import com.velvet.api.identity.service.PhotoQualityService;
import com.velvet.api.storage.ObjectStorageService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.LinkedHashMap;
import java.util.Map;

@RestController
@RequestMapping("/v1/uploads")
public class UploadController {

    private final ObjectStorageService storageService;
    private final PhotoQualityService photoQualityService;

    public UploadController(ObjectStorageService storageService, PhotoQualityService photoQualityService) {
        this.storageService = storageService;
        this.photoQualityService = photoQualityService;
    }

    @PostMapping(value = "/verification", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, String>> uploadVerification(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @RequestParam("kind") String kind,
            @RequestParam("file") MultipartFile file
    ) {
        String normalized = kind == null ? "doc" : kind.trim().toLowerCase();
        if (!normalized.equals("id") && !normalized.equals("selfie")) {
            normalized = "doc";
        }
        String url = storageService.uploadVerificationImage(principal.getUserId(), normalized, file);
        return ResponseEntity.ok(Map.of("url", url, "kind", normalized));
    }

    @PostMapping(value = "/profile", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, String>> uploadProfile(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @RequestParam("file") MultipartFile file
    ) {
        PhotoQualityService.Result quality = photoQualityService.evaluate(file);
        if (quality.status() == PhotoQualityService.Status.REJECTED) {
            throw new com.velvet.api.common.api.BusinessException("PHOTO_QUALITY", quality.reason());
        }
        String url = storageService.uploadProfileImage(principal.getUserId(), file);
        Map<String, String> body = new LinkedHashMap<>();
        body.put("url", url);
        body.put("qualityStatus", quality.status().name());
        body.put("qualityReason", quality.reason() == null ? "" : quality.reason());
        return ResponseEntity.ok(body);
    }

    @PostMapping(value = "/chat", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, String>> uploadChat(
            @AuthenticationPrincipal VelvetPrincipal principal,
            @RequestParam("file") MultipartFile file
    ) {
        var stored = storageService.uploadChatMedia(principal.getUserId(), file);
        return ResponseEntity.ok(Map.of(
                "url", stored.url(),
                "mediaType", stored.mediaType(),
                "mime", stored.mime(),
                "fileName", stored.fileName() == null ? "file" : stored.fileName()
        ));
    }
}
