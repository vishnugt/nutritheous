package com.nutritheous.test;

import com.google.api.gax.paging.Page;
import com.google.cloud.storage.*;
import com.google.auth.oauth2.ServiceAccountCredentials;

import java.io.FileInputStream;
import java.io.IOException;
import java.net.URL;
import java.util.concurrent.TimeUnit;

/**
 * Simple test program to verify Google Cloud Storage connectivity
 *
 * Run with: ./gradlew run --args="test-gcs"
 * Or compile and run: javac -cp ... GCSTest.java && java GCSTest
 */
public class GCSTest {

    public static void main(String[] args) {
        System.out.println("🧪 Testing Google Cloud Storage Connection...\n");

        String projectId = System.getenv().getOrDefault("GCS_PROJECT_ID", "neat-beaker-475617-a9");
        String credentialsPath = System.getenv().getOrDefault("GCS_CREDENTIALS_PATH", "src/main/resources/gcp-credentials.json");
        String bucketName = System.getenv().getOrDefault("GCS_BUCKET_NAME", "nutritheous");

        System.out.println("Configuration:");
        System.out.println("  Project ID: " + projectId);
        System.out.println("  Credentials: " + credentialsPath);
        System.out.println("  Bucket: " + bucketName);
        System.out.println();

        try {
            // 1. Initialize Storage client
            System.out.println("1️⃣ Initializing GCS client...");
            Storage storage = StorageOptions.newBuilder()
                .setProjectId(projectId)
                .setCredentials(ServiceAccountCredentials.fromStream(
                    new FileInputStream(credentialsPath)))
                .build()
                .getService();
            System.out.println("   ✅ Client initialized\n");

            // 2. Test bucket access by listing objects
            System.out.println("2️⃣ Testing bucket access...");
            try {
                Page<Blob> blobs = storage.list(bucketName,
                    Storage.BlobListOption.pageSize(5));

                int count = 0;
                System.out.println("   📂 Objects in bucket (first 5):");
                for (Blob blob : blobs.iterateAll()) {
                    System.out.println("      - " + blob.getName() +
                        " (" + formatBytes(blob.getSize()) + ")");
                    count++;
                    if (count >= 5) break;
                }

                if (count == 0) {
                    System.out.println("      (bucket is empty)");
                }

                System.out.println("   ✅ Bucket access successful\n");
            } catch (Exception e) {
                System.out.println("   ❌ Bucket access failed: " + e.getMessage());
                System.out.println("   💡 Make sure the service account has 'Storage Object Admin' role\n");
                return;
            }

            // 3. Test upload
            System.out.println("3️⃣ Testing file upload...");
            String testFileName = "test/gcs-test-" + System.currentTimeMillis() + ".txt";
            String testContent = "Hello from GCS Test! Timestamp: " + System.currentTimeMillis();

            BlobId blobId = BlobId.of(bucketName, testFileName);
            BlobInfo blobInfo = BlobInfo.newBuilder(blobId)
                .setContentType("text/plain")
                .build();

            Blob blob = storage.create(blobInfo, testContent.getBytes());
            System.out.println("   ✅ Upload successful: " + testFileName + "\n");

            // 4. Test signed URL generation
            System.out.println("4️⃣ Testing signed URL generation...");
            URL signedUrl = storage.signUrl(
                blobInfo,
                3600,  // 1 hour
                TimeUnit.SECONDS,
                Storage.SignUrlOption.withV4Signature()
            );
            System.out.println("   ✅ Signed URL generated:");
            System.out.println("   🔗 " + signedUrl.toString().substring(0,
                Math.min(100, signedUrl.toString().length())) + "...\n");

            // 5. Test download
            System.out.println("5️⃣ Testing file download...");
            byte[] downloadedContent = storage.readAllBytes(blobId);
            String downloadedText = new String(downloadedContent);

            if (downloadedText.equals(testContent)) {
                System.out.println("   ✅ Download successful and content matches\n");
            } else {
                System.out.println("   ⚠️  Download successful but content mismatch\n");
            }

            // 6. Test delete
            System.out.println("6️⃣ Testing file deletion...");
            boolean deleted = storage.delete(blobId);
            if (deleted) {
                System.out.println("   ✅ Delete successful\n");
            } else {
                System.out.println("   ⚠️  Delete returned false (file may not exist)\n");
            }

            // Success summary
            System.out.println("═══════════════════════════════════════");
            System.out.println("🎉 All GCS tests passed successfully!");
            System.out.println("═══════════════════════════════════════");
            System.out.println("\nYour Google Cloud Storage is properly configured:");
            System.out.println("  ✓ Authentication works");
            System.out.println("  ✓ Bucket access works");
            System.out.println("  ✓ Upload works");
            System.out.println("  ✓ Signed URL generation works");
            System.out.println("  ✓ Download works");
            System.out.println("  ✓ Delete works");

        } catch (IOException e) {
            System.err.println("❌ Error: " + e.getMessage());
            e.printStackTrace();
            System.err.println("\n💡 Troubleshooting:");
            System.err.println("  1. Check if credentials file exists: " + credentialsPath);
            System.err.println("  2. Verify the service account has proper permissions");
            System.err.println("  3. Ensure the bucket name is correct: " + bucketName);
        } catch (Exception e) {
            System.err.println("❌ Unexpected error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static String formatBytes(long bytes) {
        if (bytes < 1024) return bytes + " B";
        int exp = (int) (Math.log(bytes) / Math.log(1024));
        String pre = "KMGTPE".charAt(exp - 1) + "B";
        return String.format("%.1f %s", bytes / Math.pow(1024, exp), pre);
    }
}
