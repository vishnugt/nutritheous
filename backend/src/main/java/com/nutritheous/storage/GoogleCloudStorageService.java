package com.nutritheous.storage;

import com.google.cloud.storage.*;
import com.nutritheous.common.exception.FileStorageException;
import com.nutritheous.image.ImageCompressionService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.FileInputStream;
import java.io.IOException;
import java.net.URL;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

/**
 * Service for managing file uploads to Google Cloud Storage.
 * Replaces MinioService with GCS implementation.
 */
@Service
@Slf4j
public class GoogleCloudStorageService {

    private final Storage storage;
    private final String bucketName;
    private final String projectId;
    private final int urlExpiry;
    private final int imageUrlExpiry;
    private final ImageCompressionService imageCompressionService;

    public GoogleCloudStorageService(
            @Value("${gcs.project-id}") String projectId,
            @Value("${gcs.credentials-json:#{null}}") String credentialsJson,
            @Value("${gcs.credentials-path:#{null}}") String credentialsPath,
            @Value("${gcs.bucket-name}") String bucketName,
            @Value("${gcs.url-expiry:86400}") int urlExpiry,
            @Value("${gcs.image-url-expiry:86400}") int imageUrlExpiry,
            ImageCompressionService imageCompressionService) throws IOException {

        log.info("🚀 Initializing Google Cloud Storage Service...");
        log.info("📋 Configuration:");
        log.info("   Project ID: {}", projectId);
        log.info("   Bucket Name: {}", bucketName);
        log.info("   URL Expiry: {} seconds ({} hours)", urlExpiry, urlExpiry / 3600);
        log.info("   Image URL Expiry: {} seconds ({} hours)", imageUrlExpiry, imageUrlExpiry / 3600);

        this.bucketName = bucketName;
        this.projectId = projectId;
        this.urlExpiry = urlExpiry;
        this.imageUrlExpiry = imageUrlExpiry;
        this.imageCompressionService = imageCompressionService;

        try {
            log.info("🔑 Loading service account credentials...");

            // Priority 1: Use JSON string from environment variable (recommended for production)
            if (credentialsJson != null && !credentialsJson.isEmpty()) {
                log.info("✅ Loading credentials from GCS_CREDENTIALS_JSON environment variable");
                this.storage = StorageOptions.newBuilder()
                        .setProjectId(projectId)
                        .setCredentials(com.google.auth.oauth2.ServiceAccountCredentials.fromStream(
                                new java.io.ByteArrayInputStream(credentialsJson.getBytes(java.nio.charset.StandardCharsets.UTF_8))))
                        .build()
                        .getService();
            }
            // Priority 2: Fallback to file path (for local development)
            else if (credentialsPath != null && !credentialsPath.isEmpty()) {
                log.info("✅ Loading credentials from file: {}", credentialsPath);
                java.io.File credFile = new java.io.File(credentialsPath);
                if (!credFile.exists()) {
                    log.error("❌ Credentials file NOT found at: {}", credentialsPath);
                    throw new IOException("GCS credentials file not found: " + credentialsPath);
                }
                this.storage = StorageOptions.newBuilder()
                        .setProjectId(projectId)
                        .setCredentials(com.google.auth.oauth2.ServiceAccountCredentials.fromStream(
                                new FileInputStream(credentialsPath)))
                        .build()
                        .getService();
            } else {
                log.error("❌ No GCS credentials provided!");
                log.error("   Set either GCS_CREDENTIALS_JSON (JSON string) or GCS_CREDENTIALS_PATH (file path)");
                throw new IOException("GCS credentials not configured. Set GCS_CREDENTIALS_JSON or GCS_CREDENTIALS_PATH");
            }

            log.info("✅ Google Cloud Storage client initialized successfully");
            log.info("📦 Using bucket: {}", bucketName);
            ensureBucketExists();
        } catch (Exception e) {
            log.error("❌ Failed to initialize Google Cloud Storage", e);
            throw e;
        }
    }

    /**
     * Ensures the GCS bucket exists.
     * Note: This method assumes the bucket already exists and the service account
     * has Storage Object Admin permissions. It does not check bucket existence
     * to avoid requiring storage.buckets.get permission.
     */
    public void ensureBucketExists() {
        log.info("Using GCS bucket: {} (assuming bucket exists with proper permissions)", bucketName);
    }

    /**
     * Uploads a file to Google Cloud Storage.
     *
     * @param file   The file to upload
     * @param userId The user ID (used for organizing files in folders)
     * @return The object name (path) in GCS
     */
    public String uploadFile(MultipartFile file, UUID userId) {
        if (file.isEmpty()) {
            throw new FileStorageException("Cannot upload empty file");
        }

        try {
            String originalFilename = file.getOriginalFilename();
            String extension = originalFilename != null && originalFilename.contains(".")
                    ? originalFilename.substring(originalFilename.lastIndexOf("."))
                    : "";

            String filename = String.format("%s/%s%s",
                    userId.toString(),
                    UUID.randomUUID().toString(),
                    extension
            );

            log.info("📤 Starting upload - Original filename: {}, User: {}, Object name: {}",
                originalFilename, userId, filename);

            // Compress image if needed
            byte[] fileBytes = imageCompressionService.compressImageIfNeeded(file);

            BlobId blobId = BlobId.of(bucketName, filename);
            BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                    .setContentType(file.getContentType())
                    .build();

            log.info("📦 Uploading to GCS - Bucket: {}, Object: {}, Content-Type: {}, Size: {} bytes",
                bucketName, filename, file.getContentType(), fileBytes.length);

            storage.create(blobInfo, fileBytes);

            log.info("✅ Upload successful - Object name: {}, Size: {} bytes", filename, fileBytes.length);

            return filename;

        } catch (com.google.cloud.storage.StorageException e) {
            log.error("❌ GCS Storage Exception during upload:");
            log.error("   Error Code: {}", e.getCode());
            log.error("   Error Message: {}", e.getMessage());
            log.error("   Reason: {}", e.getReason());
            log.error("   Bucket: {}", bucketName);
            throw new FileStorageException("GCS upload failed: " + e.getMessage(), e);
        } catch (Exception e) {
            log.error("❌ Failed to upload file to GCS", e);
            log.error("   Exception Type: {}", e.getClass().getName());
            log.error("   Message: {}", e.getMessage());
            throw new FileStorageException("Failed to upload file to storage", e);
        }
    }

    /**
     * Generates a signed URL for temporary access to a file.
     *
     * @param objectName The object name (path) in GCS
     * @return Signed URL valid for the configured duration
     */
    public String getPresignedUrl(String objectName) {
        try {
            log.info("🔗 Generating signed URL for object: {}", objectName);

            BlobId blobId = BlobId.of(bucketName, objectName);
            BlobInfo blobInfo = BlobInfo.newBuilder(blobId).build();

            URL signedUrl = storage.signUrl(
                    blobInfo,
                    urlExpiry,
                    TimeUnit.SECONDS,
                    Storage.SignUrlOption.withV4Signature()
            );

            log.info("✅ Signed URL generated - Expiry: {} seconds", urlExpiry);
            log.info("🌐 URL: {}", signedUrl.toString());

            return signedUrl.toString();

        } catch (com.google.cloud.storage.StorageException e) {
            log.error("❌ GCS Storage Exception during URL generation:");
            log.error("   Error Code: {}", e.getCode());
            log.error("   Error Message: {}", e.getMessage());
            log.error("   Reason: {}", e.getReason());
            log.error("   Object: {}", objectName);
            log.error("   Bucket: {}", bucketName);
            throw new FileStorageException("GCS signed URL generation failed: " + e.getMessage(), e);
        } catch (Exception e) {
            log.error("❌ Failed to generate signed URL for: {}", objectName, e);
            log.error("   Exception Type: {}", e.getClass().getName());
            log.error("   Message: {}", e.getMessage());
            throw new FileStorageException("Failed to generate presigned URL", e);
        }
    }

    /**
     * Generates a signed URL specifically for image display (may have different expiry).
     *
     * @param objectName The object name (path) in GCS
     * @return Signed URL valid for the configured image URL duration
     */
    public String getPresignedImageUrl(String objectName) {
        try {
            log.info("🖼️  Generating signed IMAGE URL for object: {}", objectName);

            BlobId blobId = BlobId.of(bucketName, objectName);
            BlobInfo blobInfo = BlobInfo.newBuilder(blobId).build();

            URL signedUrl = storage.signUrl(
                    blobInfo,
                    imageUrlExpiry,
                    TimeUnit.SECONDS,
                    Storage.SignUrlOption.withV4Signature()
            );

            log.info("✅ Signed IMAGE URL generated - Expiry: {} seconds ({} hours)",
                imageUrlExpiry, imageUrlExpiry / 3600);
            log.info("🌐 IMAGE URL: {}", signedUrl.toString());
            log.info("📋 To test with curl: curl -I \"{}\"", signedUrl.toString());

            return signedUrl.toString();

        } catch (com.google.cloud.storage.StorageException e) {
            log.error("❌ GCS Storage Exception during IMAGE URL generation:");
            log.error("   Error Code: {}", e.getCode());
            log.error("   Error Message: {}", e.getMessage());
            log.error("   Reason: {}", e.getReason());
            log.error("   Object: {}", objectName);
            log.error("   Bucket: {}", bucketName);

            // Common GCS errors
            if (e.getCode() == 403) {
                log.error("💡 SOLUTION: Service account lacks permissions!");
                log.error("   Grant 'Storage Object Admin' role to your service account");
                log.error("   Command: gcloud projects add-iam-policy-binding {} \\", projectId);
                log.error("            --member='serviceAccount:YOUR_SERVICE_ACCOUNT_EMAIL' \\");
                log.error("            --role='roles/storage.objectAdmin'");
            } else if (e.getCode() == 404) {
                log.error("💡 SOLUTION: Object or bucket not found!");
                log.error("   Check bucket name: {}", bucketName);
                log.error("   Check object exists: {}", objectName);
            }

            throw new FileStorageException("GCS signed image URL generation failed: " + e.getMessage(), e);
        } catch (Exception e) {
            log.error("❌ Failed to generate signed image URL for object: {}", objectName, e);
            log.error("   Exception Type: {}", e.getClass().getName());
            log.error("   Message: {}", e.getMessage());
            throw new FileStorageException("Failed to generate presigned image URL", e);
        }
    }

    /**
     * Deletes a file from Google Cloud Storage.
     *
     * @param objectName The object name (path) in GCS
     */
    public void deleteFile(String objectName) {
        try {
            BlobId blobId = BlobId.of(bucketName, objectName);
            boolean deleted = storage.delete(blobId);

            if (deleted) {
                log.info("Deleted file from GCS: {}", objectName);
            } else {
                log.warn("File not found in GCS: {}", objectName);
            }

        } catch (Exception e) {
            log.error("Failed to delete file from GCS: {}", objectName, e);
            throw new FileStorageException("Failed to delete file from storage", e);
        }
    }
}
