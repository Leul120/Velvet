package com.velvet.api.storage;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import com.velvet.api.common.api.BusinessException;
import com.velvet.api.common.config.VelvetProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
import java.net.HttpURLConnection;
import java.net.URI;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

@Service
public class ObjectStorageService {

    private static final Logger log = LoggerFactory.getLogger(ObjectStorageService.class);

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
    private final Cloudinary cloudinary;
    private final VelvetProperties properties;
    private volatile boolean bucketReady;

    public ObjectStorageService(S3Client s3, Cloudinary cloudinary, VelvetProperties properties) {
        this.s3 = s3;
        this.cloudinary = cloudinary;
        this.properties = properties;
    }

    public String uploadVerificationImage(UUID userId, String kind, MultipartFile file) {
        return store(userId, "verification/" + kind, file, Allow.IMAGE);
    }

    public String uploadProfileImage(UUID userId, MultipartFile file) {
        return store(userId, "profile", file, Allow.IMAGE);
    }

    public String uploadVaultImage(UUID userId, MultipartFile file) {
        return store(userId, "vault", file, Allow.IMAGE);
    }

    public String uploadVoiceIntro(UUID userId, MultipartFile file) {
        return store(userId, "voice", file, Allow.AUDIO);
    }

    /** Ensures a profile photo URL is an upload owned by this member, not an arbitrary remote URL. */
    public void assertOwnedProfileImage(UUID userId, String url) {
        assertOwnedMediaUrl(userId, url, "profile/");
    }

    /** Deletes a member's listing photo as part of account erasure. */
    public void deleteOwnedProfileImage(UUID userId, String url) {
        String key = ownedMediaKey(userId, url, "profile/");
        boolean deleted = false;
        if (properties.storage() != null && properties.storage().usesCloudinary()) {
            try {
                cloudinary.uploader().destroy("velvet/" + key, ObjectUtils.asMap("resource_type", "image"));
                deleted = true;
            } catch (Exception e) {
                log.warn("Cloudinary delete failed for {}: {}", key, e.getMessage());
            }
        }
        try {
            s3.deleteObject(DeleteObjectRequest.builder()
                    .bucket(properties.storage().bucket())
                    .key(key)
                    .build());
            deleted = true;
        } catch (Exception e) {
            if (!deleted) {
                throw new BusinessException("MEDIA_DELETE_FAILED", "Could not remove a profile photo during account erasure.");
            }
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

    private enum Allow { IMAGE, AUDIO, CHAT }

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
        if (allow == Allow.AUDIO && !"AUDIO".equals(mediaType)) {
            throw new BusinessException("FILE_TYPE", "Only audio files (MP3, M4A, AAC, WAV, OGG) are allowed.");
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

        boolean useCloudinary = properties.storage() != null && properties.storage().usesCloudinary();
        if (useCloudinary) {
            MediaStream stream = openFromCloudinary(key);
            if (stream != null) {
                return stream;
            }
            return openFromS3(key);
        } else {
            try {
                return openFromS3(key);
            } catch (BusinessException ex) {
                if (properties.storage() != null && properties.storage().isCloudinaryConfigured()) {
                    MediaStream stream = openFromCloudinary(key);
                    if (stream != null) {
                        return stream;
                    }
                }
                throw ex;
            }
        }
    }

    private MediaStream openFromS3(String key) {
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

    private MediaStream openFromCloudinary(String key) {
        String ext = extensionOf(key);
        String resourceType = resourceTypeFromExtension(ext);
        String cloudinaryUrl = cloudinary.url().resourceType(resourceType).secure(true).generate("velvet/" + key);

        try {
            HttpURLConnection conn = (HttpURLConnection) URI.create(cloudinaryUrl).toURL().openConnection();
            conn.setRequestMethod("GET");
            conn.setConnectTimeout(5000);
            conn.setReadTimeout(15000);
            int code = conn.getResponseCode();
            if (code >= 200 && code < 300) {
                InputStream in = conn.getInputStream();
                String contentType = conn.getContentType();
                if (contentType == null || contentType.isBlank()) {
                    contentType = EXT_MIME.getOrDefault(ext, "application/octet-stream");
                }
                long length = conn.getContentLengthLong();
                return new MediaStream(in, contentType, length);
            }
            // If not found with inferred type, check other resource types
            if (code == 404) {
                for (String altType : new String[]{"image", "video", "raw"}) {
                    if (altType.equals(resourceType)) continue;
                    String altUrl = cloudinary.url().resourceType(altType).secure(true).generate("velvet/" + key);
                    HttpURLConnection altConn = (HttpURLConnection) URI.create(altUrl).toURL().openConnection();
                    altConn.setRequestMethod("GET");
                    altConn.setConnectTimeout(3000);
                    altConn.setReadTimeout(10000);
                    if (altConn.getResponseCode() >= 200 && altConn.getResponseCode() < 300) {
                        String cType = altConn.getContentType();
                        if (cType == null || cType.isBlank()) {
                            cType = EXT_MIME.getOrDefault(ext, "application/octet-stream");
                        }
                        return new MediaStream(altConn.getInputStream(), cType, altConn.getContentLengthLong());
                    }
                }
            }
        } catch (Exception e) {
            log.debug("Cloudinary open failed for key {}: {}", key, e.getMessage());
        }
        return null;
    }

    private String put(UUID userId, String folder, MultipartFile file, Resolved resolved) {
        String key = "%s/%s/%s.%s".formatted(folder, userId, UUID.randomUUID(), resolved.ext());
        boolean useCloudinary = properties.storage() != null && properties.storage().usesCloudinary();

        if (useCloudinary) {
            putCloudinary(key, file, resolved);
        } else {
            putS3(key, file, resolved);
        }

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

    private void putCloudinary(String key, MultipartFile file, Resolved resolved) {
        try {
            String resourceType = cloudinaryResourceType(resolved.mediaType());
            Map<String, Object> params = ObjectUtils.asMap(
                    "public_id", "velvet/" + key,
                    "resource_type", resourceType,
                    "overwrite", true
            );
            cloudinary.uploader().upload(file.getBytes(), params);
            log.info("Uploaded to Cloudinary (type={}): velvet/{}", resourceType, key);
        } catch (Exception e) {
            log.error("Cloudinary upload failed for key: {}", key, e);
            // Fallback to S3 if Cloudinary upload fails
            try {
                log.warn("Attempting fallback to S3 for key: {}", key);
                putS3(key, file, resolved);
            } catch (Exception s3Ex) {
                throw new BusinessException("UPLOAD_FAILED", "Could not store file.");
            }
        }
    }

    private void putS3(String key, MultipartFile file, Resolved resolved) {
        ensureBucket();
        try {
            s3.putObject(
                    PutObjectRequest.builder()
                            .bucket(properties.storage().bucket())
                            .key(key)
                            .contentType(resolved.contentType())
                            .build(),
                    RequestBody.fromBytes(file.getBytes())
            );
        } catch (Exception e) {
            // If S3 fails and Cloudinary is configured, fallback to Cloudinary
            if (properties.storage() != null && properties.storage().isCloudinaryConfigured()) {
                log.warn("S3 put failed, falling back to Cloudinary for key {}: {}", key, e.getMessage());
                putCloudinary(key, file, resolved);
                return;
            }
            throw new BusinessException("UPLOAD_FAILED", "Could not store file.");
        }
    }

    private String cloudinaryResourceType(String mediaType) {
        return switch (mediaType) {
            case "VIDEO", "AUDIO" -> "video";
            case "IMAGE" -> "image";
            default -> "raw";
        };
    }

    private String resourceTypeFromExtension(String ext) {
        String mime = EXT_MIME.getOrDefault(ext, "");
        if (IMAGE_TYPES.contains(mime)) return "image";
        if (VIDEO_TYPES.contains(mime) || AUDIO_TYPES.contains(mime)) return "video";
        return "raw";
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
