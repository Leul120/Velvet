package com.velvet.api.storage;

import com.cloudinary.Cloudinary;
import com.velvet.api.common.config.VelvetProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import software.amazon.awssdk.auth.credentials.AwsBasicCredentials;
import software.amazon.awssdk.auth.credentials.StaticCredentialsProvider;
import software.amazon.awssdk.regions.Region;
import software.amazon.awssdk.services.s3.S3Client;
import software.amazon.awssdk.services.s3.S3Configuration;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

@Configuration
public class StorageConfig {

    @Bean
    S3Client s3Client(VelvetProperties properties) {
        VelvetProperties.Storage storage = properties.storage();
        String endpoint = (storage != null && storage.endpoint() != null && !storage.endpoint().isBlank())
                ? storage.endpoint().trim()
                : "http://localhost:9000";
        String region = (storage != null && storage.region() != null && !storage.region().isBlank())
                ? storage.region().trim()
                : "us-east-1";
        String accessKey = (storage != null && storage.accessKey() != null && !storage.accessKey().isBlank())
                ? storage.accessKey().trim()
                : "velvet";
        String secretKey = (storage != null && storage.secretKey() != null && !storage.secretKey().isBlank())
                ? storage.secretKey().trim()
                : "velvetsecret";

        return S3Client.builder()
                .endpointOverride(URI.create(endpoint))
                .region(Region.of(region))
                .credentialsProvider(StaticCredentialsProvider.create(
                        AwsBasicCredentials.create(accessKey, secretKey)
                ))
                .serviceConfiguration(S3Configuration.builder()
                        .pathStyleAccessEnabled(true)
                        .build())
                .build();
    }

    @Bean
    Cloudinary cloudinary(VelvetProperties properties) {
        VelvetProperties.Storage storage = properties.storage();
        if (storage != null && storage.cloudinaryUrl() != null && !storage.cloudinaryUrl().isBlank()) {
            return new Cloudinary(storage.cloudinaryUrl().trim());
        }
        if (storage != null && storage.cloudName() != null && !storage.cloudName().isBlank()) {
            Map<String, Object> config = new HashMap<>();
            config.put("cloud_name", storage.cloudName().trim());
            if (storage.cloudinaryApiKey() != null) config.put("api_key", storage.cloudinaryApiKey().trim());
            if (storage.cloudinaryApiSecret() != null) config.put("api_secret", storage.cloudinaryApiSecret().trim());
            return new Cloudinary(config);
        }
        String envUrl = System.getenv("CLOUDINARY_URL");
        if (envUrl != null && !envUrl.isBlank()) {
            return new Cloudinary(envUrl.trim());
        }
        return new Cloudinary();
    }
}
