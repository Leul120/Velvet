package com.velvet.api.storage;

import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import software.amazon.awssdk.core.ResponseInputStream;
import software.amazon.awssdk.core.sync.RequestBody;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.model.CreateBucketRequest;
import software.amazon.awssdk.services.s3.model.DeleteObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectRequest;
import software.amazon.awssdk.services.s3.model.GetObjectResponse;
import software.amazon.awssdk.services.s3.model.HeadBucketRequest;
import software.amazon.awssdk.services.s3.model.NoSuchBucketException;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;

import java.io.IOException;
import java.io.InputStream;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class ObjectStorageService {

    private static final Set<String> IMAGE_TYPES = Set.of("image/jpeg", "image/png", "image/webp", "image/gif");
    private static final Set<String> VIDEO_TYPES = Set.of("video/mp4", "video/quicktime", "video/webm", "video/3gpp");
    private static final Set<String> AUDIO_TYPES = Set.of("audio/mpeg", "audio/mp4", "audio/aac", "audio/wav", "audio/x-wav", "audio/ogg", "audio/webm");
    private static final Set<String> FILE_TYPES = Set.of(
            "application/pdf",
            "application/msword",
            "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "application/vnd.ms-excel",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            "text/plain",
            "application/zip"
    );

    private static final Map<String, String> EXT_MIME = Map.ofEntries(
            Map.entry("jpg", "image/jpeg"),
            Map.entry("jpeg", "image/jpeg"),
            Map.entry("png", "image/png"),
            Map.entry("webp", "image/webp"),
            Map.entry("gif", "image/gif"),
            Map.entry("mp4", "video/mp4"),
            Map.entry("mov", "video/quicktime"),
            Map.entry("webm", "video/webm"),
            Map.entry("3gp", "video/3gpp"),
            Map.entry("mp3", "audio/mpeg"),
            Map.entry("m4a", "audio/mp4"),
            Map.entry("aac", "audio/aac"),
            Map.entry("wav", "audio/wav"),
            Map.entry("ogg", "audio/ogg"),
            Map.entry("pdf", "application/pdf"),
            Map.entry("doc", "application/msword"),
            Map.entry("docx", "application/vnd.openxmlformats-officedocument.wordprocessingml.document"),
            Map.entry("xls", "application/vnd.ms-excel"),
            Map.entry("xlsx", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"),
            Map.entry("txt", "text/plain"),
            Map.entry("zip", "application/zip")
    );

    private final S3Client s3;
    private final VelvetProperties properties;
    private volatile boolean bucketReady;

    public ObjectStorageService(S3Client s3, VelvetProperties properties) {
        this.s3 = s3;
        this.properties = properties;
    }

    public String uploadVerificationImage(UUID userId, String kind, MultipartFile file) {
        return store(userId, "verification/" + kind, file, Allow.IMAGE);
    }

    public String uploadProfileImage(UUID userId, MultipartFile file) {
        return store(userId, "profile", file, Allow.IMAGE);
    }

    /** Ensures a profile photo URL is an upload owned by this member, not an arbitrary remote URL. */
    public void assertOwnedProfileImage(UUID userId, String url) {
        assertOwnedMediaUrl(userId, url, "profile/");
    }

    /** Deletes a member's listing photo as part of account erasure. */
    public void deleteOwnedProfileImage(UUID userId, String url) {
        String key = ownedMediaKey(userId, url, "profile/");
        try {
            s3.deleteObject(DeleteObjectRequest.builder()
                    .bucket(properties.storage().bucket())
                    .key(key)
                    .build());
        } catch (Exception e) {
            throw new BusinessException("MEDIA_DELETE_FAILED", "Could not remove a profile photo during account erasure.");
        }
    }

    /** Chat messages may only attach files uploaded by their sender. */
    public void assertOwnedChatMedia(UUID userId, String url) {
        assertOwnedMediaUrl(userId, url, "chat/");
    }

    private void assertOwnedMediaUrl(UUID userId, String url, String folder) {
        ownedMediaKey(userId, url, folder);
    }

    private String ownedMediaKey(UUID userId, String url, String folder) {
        if (url == null || url.isBlank()) {
            throw new BusinessException("URL_REQUIRED", "Photo URL is required.");
        }
        String path = url.trim();
        int marker = path.indexOf("/v1/media/");
        if (marker >= 0) path = path.substring(marker + "/v1/media/".length());
        else {
            int bucket = path.indexOf("/" + properties.storage().bucket() + "/");
            if (bucket >= 0) path = path.substring(bucket + properties.storage().bucket().length() + 2);
        }
        String ownedPrefix = folder + userId + "/";
        if (!path.startsWith(ownedPrefix) || path.contains("..")) {
            throw new BusinessException("MEDIA_OWNERSHIP", "Media must be uploaded from your account.");
        }
        return path;
    }

    public String uploadPaymentReceipt(UUID userId, MultipartFile file) {
        return store(userId, "payments/cbe", file, Allow.IMAGE);
    }

    public record ChatUpload(String url, String mediaType, String mime, String fileName) {}

    public ChatUpload uploadChatMedia(UUID userId, MultipartFile file) {
        Resolved resolved = resolve(file, Allow.CHAT);
        String url = put(userId, "chat", file, resolved);
        return new ChatUpload(url, resolved.mediaType(), resolved.contentType(), resolved.originalName());
    }

    private enum Allow { IMAGE, CHAT }

    private record Resolved(String contentType, String ext, String mediaType, String originalName) {}

    private String store(UUID userId, String folder, MultipartFile file, Allow allow) {
        Resolved resolved = resolve(file, allow);
        return put(userId, folder, file, resolved);
    }

    private Resolved resolve(MultipartFile file, Allow allow) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("FILE_REQUIRED", "File is required.");
        }
        String original = file.getOriginalFilename() == null ? "upload" : file.getOriginalFilename();
        String ext = extensionOf(original);
        String contentType = file.getContentType() == null ? "" : file.getContentType().toLowerCase(Locale.ROOT);
        if (contentType.isBlank() || contentType.equals("application/octet-stream") || contentType.equals("binary/octet-stream")) {
            contentType = EXT_MIME.getOrDefault(ext, contentType);
        }
        String mediaType;
        if (IMAGE_TYPES.contains(contentType)) {
            mediaType = "IMAGE";
        } else if (VIDEO_TYPES.contains(contentType)) {
            mediaType = "VIDEO";
        } else if (AUDIO_TYPES.contains(contentType)) {
            mediaType = "AUDIO";
        } else if (FILE_TYPES.contains(contentType)) {
            mediaType = "FILE";
        } else if (!ext.isBlank() && EXT_MIME.containsKey(ext)) {
            contentType = EXT_MIME.get(ext);
            mediaType = IMAGE_TYPES.contains(contentType) ? "IMAGE"
                    : VIDEO_TYPES.contains(contentType) ? "VIDEO"
                    : AUDIO_TYPES.contains(contentType) ? "AUDIO" : "FILE";
        } else {
            throw new BusinessException("FILE_TYPE", "Unsupported file type.");
        }
        if (allow == Allow.IMAGE && !"IMAGE".equals(mediaType)) {
            throw new BusinessException("FILE_TYPE", "Only JPEG, PNG, WebP, or GIF images are allowed.");
        }
        if (ext.isBlank()) {
            ext = switch (mediaType) {
                case "VIDEO" -> "mp4";
                case "AUDIO" -> "mp3";
                case "FILE" -> "bin";
                default -> "jpg";
            };
        }
        return new Resolved(contentType, ext, mediaType, original);
    }

    public record MediaStream(InputStream body, String contentType, long contentLength) implements AutoCloseable {
        @Override
        public void close() throws IOException {
            body.close();
        }
    }

    /**
     * Streams an object by storage key. Keys are UUID-scoped paths from uploads.
     */
    public MediaStream open(String key) {
        if (key == null || key.isBlank() || key.contains("..") || key.startsWith("/")) {
            throw new BusinessException("NOT_FOUND", "Media not found.");
        }
        ensureBucket();
        try {
            ResponseInputStream<GetObjectResponse> stream = s3.getObject(
                    GetObjectRequest.builder()
                            .bucket(properties.storage().bucket())
                            .key(key)
                            .build()
            );
            GetObjectResponse meta = stream.response();
            String contentType = meta.contentType() == null ? "application/octet-stream" : meta.contentType();
            long length = meta.contentLength() == null ? -1L : meta.contentLength();
            return new MediaStream(stream, contentType, length);
        } catch (Exception e) {
            throw new BusinessException("NOT_FOUND", "Media not found.");
        }
    }

    private String put(UUID userId, String folder, MultipartFile file, Resolved resolved) {
        ensureBucket();
        String key = "%s/%s/%s.%s".formatted(folder, userId, UUID.randomUUID(), resolved.ext());
        try {
            s3.putObject(
                    PutObjectRequest.builder()
                            .bucket(properties.storage().bucket())
                            .key(key)
                            .contentType(resolved.contentType())
                            .build(),
                    RequestBody.fromBytes(file.getBytes())
            );
        } catch (IOException e) {
            throw new BusinessException("UPLOAD_FAILED", "Could not store file.");
        }
        // Relative API path — clients resolve against API_BASE (works on emulator + LAN phones).
        // Legacy absolute MinIO URLs still work via client rewrite.
        String configured = properties.storage().publicBaseUrl() == null
                ? ""
                : properties.storage().publicBaseUrl().trim();
        if (configured.isBlank() || configured.startsWith("/") || "relative".equalsIgnoreCase(configured)) {
            return "/v1/media/" + key;
        }
        if (configured.contains("/v1/media")) {
            return configured.replaceAll("/$", "") + "/" + key;
        }
        return configured.replaceAll("/$", "")
                + "/" + properties.storage().bucket() + "/" + key;
    }

    private static String extensionOf(String name) {
        int i = name.lastIndexOf('.');
        if (i < 0 || i == name.length() - 1) {
            return "";
        }
        return name.substring(i + 1).toLowerCase(Locale.ROOT);
    }

    private void ensureBucket() {
        if (bucketReady) {
            return;
        }
        synchronized (this) {
            if (bucketReady) {
                return;
            }
            String bucket = properties.storage().bucket();
            try {
                s3.headBucket(HeadBucketRequest.builder().bucket(bucket).build());
            } catch (NoSuchBucketException ex) {
                s3.createBucket(CreateBucketRequest.builder().bucket(bucket).build());
            } catch (Exception ignored) {
                try {
                    s3.createBucket(CreateBucketRequest.builder().bucket(bucket).build());
                } catch (Exception ignored2) {
                    // leave for runtime failure on put
                }
            }
            bucketReady = true;
        }
    }
}
