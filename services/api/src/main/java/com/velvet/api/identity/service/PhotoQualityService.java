package com.velvet.api.identity.service;

import com.velvet.api.common.api.BusinessException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;

/**
 * Lightweight photo quality gate (Raya/League-style hygiene without heavy ML).
 * Rejects obviously weak uploads; flags ambiguous shots for concierge review.
 */
@Service
public class PhotoQualityService {

    public enum Status { APPROVED, NEEDS_REVIEW, REJECTED }

    public record Result(Status status, String reason, List<String> flags) {}

    public Result evaluate(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException("FILE_REQUIRED", "Photo is required.");
        }
        long size = file.getSize();
        List<String> flags = new ArrayList<>();
        String contentType = file.getContentType() == null ? "" : file.getContentType().toLowerCase(Locale.ROOT);
        if (!contentType.equals("image/jpeg") && !contentType.equals("image/png") && !contentType.equals("image/webp")) {
            throw new BusinessException("PHOTO_TYPE", "Use a JPEG, PNG, or WebP image.");
        }

        BufferedImage image;
        try {
            byte[] bytes = file.getBytes();
            image = ImageIO.read(new ByteArrayInputStream(bytes));
        } catch (IOException e) {
            throw new BusinessException("PHOTO_UNREADABLE", "Could not read this image. Try another photo.");
        }
        if (image == null) {
            throw new BusinessException("PHOTO_UNREADABLE", "Could not read this image. Try JPEG or PNG.");
        }

        int w = image.getWidth();
        int h = image.getHeight();
        // Tiny absolute payloads are almost always thumbnails — reject those.
        // Modern JPEG can be sharp under 35KB at 720p+, so do NOT reject on size alone.
        if (size < 8_000L || (size < 20_000L && (w < 720 || h < 720))) {
            return new Result(Status.REJECTED, "Photo looks too compressed or blurry. Use a clearer close-up.", List.of("TOO_SMALL"));
        }
        if (size > 12_000_000L) {
            flags.add("LARGE_FILE");
        }

        if (w < 720 || h < 720) {
            return new Result(
                    Status.REJECTED,
                    "Photo resolution is too low. Use a clear, well-lit photo (min ~720px).",
                    List.of("LOW_RESOLUTION")
            );
        }

        double aspect = w / (double) h;
        if (aspect > 1.85 || aspect < 0.45) {
            flags.add("EXTREME_ASPECT");
        }

        // Sample luminance — very dark frames often sunglasses-only / night selfies.
        double luminance = sampleLuminance(image);
        if (luminance < 28) {
            flags.add("VERY_DARK");
        } else if (luminance > 230) {
            flags.add("OVEREXPOSED");
        }

        // Very wide images often group / collage shots.
        if (aspect > 1.7 && w > 1400) {
            flags.add("POSSIBLE_GROUP");
        }

        double contrast = sampleContrast(image);
        if (contrast < 18) flags.add("LOW_CONTRAST");
        double sharpness = sampleSharpness(image);
        if (sharpness < 7) flags.add("BLURRY");

        if (flags.contains("VERY_DARK") || flags.contains("POSSIBLE_GROUP") || flags.contains("EXTREME_ASPECT")
                || flags.contains("LOW_CONTRAST") || flags.contains("BLURRY")) {
            return new Result(
                    Status.NEEDS_REVIEW,
                    "Photo saved for concierge review (lighting, group, or crop).",
                    flags
            );
        }
        return new Result(Status.APPROVED, "ok", flags);
    }

    public void assertUploadAllowed(MultipartFile file) {
        Result result = evaluate(file);
        if (result.status() == Status.REJECTED) {
            throw new BusinessException("PHOTO_QUALITY", result.reason());
        }
    }

    public static String mergeStatus(String current, Status next) {
        String cur = current == null || current.isBlank() ? Status.APPROVED.name() : current.trim().toUpperCase(Locale.ROOT);
        if (Status.REJECTED.name().equals(cur) || next == Status.REJECTED) {
            return Status.REJECTED.name();
        }
        if (Status.NEEDS_REVIEW.name().equals(cur) || next == Status.NEEDS_REVIEW) {
            return Status.NEEDS_REVIEW.name();
        }
        return Status.APPROVED.name();
    }

    private static double sampleLuminance(BufferedImage image) {
        int w = image.getWidth();
        int h = image.getHeight();
        int stepX = Math.max(1, w / 24);
        int stepY = Math.max(1, h / 24);
        long sum = 0;
        int n = 0;
        for (int y = 0; y < h; y += stepY) {
            for (int x = 0; x < w; x += stepX) {
                int rgb = image.getRGB(x, y);
                int r = (rgb >> 16) & 0xff;
                int g = (rgb >> 8) & 0xff;
                int b = rgb & 0xff;
                sum += (long) (0.2126 * r + 0.7152 * g + 0.0722 * b);
                n++;
            }
        }
        return n == 0 ? 128 : sum / (double) n;
    }

    private static double sampleContrast(BufferedImage image) {
        int step = Math.max(1, Math.min(image.getWidth(), image.getHeight()) / 32);
        double sum = 0, squared = 0; int n = 0;
        for (int y = 0; y < image.getHeight(); y += step) for (int x = 0; x < image.getWidth(); x += step) {
            int rgb = image.getRGB(x, y); double v = .2126 * ((rgb >> 16) & 255) + .7152 * ((rgb >> 8) & 255) + .0722 * (rgb & 255);
            sum += v; squared += v * v; n++;
        }
        return n == 0 ? 0 : Math.sqrt(Math.max(0, squared / n - Math.pow(sum / n, 2)));
    }

    private static double sampleSharpness(BufferedImage image) {
        int step = Math.max(1, Math.min(image.getWidth(), image.getHeight()) / 48);
        double sum = 0; int n = 0;
        for (int y = step; y < image.getHeight(); y += step) for (int x = step; x < image.getWidth(); x += step) {
            int a = image.getRGB(x, y), b = image.getRGB(x - step, y), c = image.getRGB(x, y - step);
            sum += Math.abs((a & 255) - (b & 255)) + Math.abs((a & 255) - (c & 255)); n++;
        }
        return n == 0 ? 0 : sum / (2 * n);
    }
}
