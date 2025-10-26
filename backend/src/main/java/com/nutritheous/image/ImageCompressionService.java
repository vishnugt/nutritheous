package com.nutritheous.image;

import com.nutritheous.common.exception.FileStorageException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Iterator;

/**
 * Service for compressing images to reduce file size while maintaining quality.
 * Uses iterative resizing and quality reduction to achieve target file sizes.
 */
@Service
@Slf4j
public class ImageCompressionService {

    private final int maxImageSizeKb;

    public ImageCompressionService(@Value("${gcs.max-image-size-kb:300}") int maxImageSizeKb) {
        this.maxImageSizeKb = maxImageSizeKb;
        log.info("ImageCompressionService initialized with max size: {} KB", maxImageSizeKb);
    }

    /**
     * Compresses image if it exceeds the maximum size limit.
     * Uses iterative resizing and quality reduction to achieve target size.
     *
     * @param file The image file to compress
     * @return Compressed image bytes, or original bytes if already under limit
     * @throws IOException If image processing fails
     */
    public byte[] compressImageIfNeeded(MultipartFile file) throws IOException {
        long maxSizeBytes = maxImageSizeKb * 1024L;

        // If file is already under the limit, return original bytes
        if (file.getSize() <= maxSizeBytes) {
            log.debug("File size {} bytes is under limit {} bytes, no compression needed",
                    file.getSize(), maxSizeBytes);
            return file.getBytes();
        }

        log.info("File size {} bytes exceeds limit {} bytes, compressing image",
                file.getSize(), maxSizeBytes);

        // Read the image
        BufferedImage originalImage = ImageIO.read(file.getInputStream());
        if (originalImage == null) {
            throw new FileStorageException("Failed to read image file");
        }

        // Get the format (jpg, png, etc.)
        String format = detectImageFormat(file.getContentType());

        int originalWidth = originalImage.getWidth();
        int originalHeight = originalImage.getHeight();
        int currentWidth = originalWidth;
        int currentHeight = originalHeight;

        byte[] compressedBytes = null;
        float quality = 0.85f;
        int attempts = 0;
        int maxAttempts = 10;

        // Iteratively resize and compress until we're under the size limit
        while (attempts < maxAttempts) {
            // Resize image
            BufferedImage resizedImage = resizeImage(
                    originalImage,
                    currentWidth,
                    currentHeight,
                    format
            );

            // Compress the image
            compressedBytes = compressImage(resizedImage, format, quality);
            long compressedSize = compressedBytes.length;

            log.debug("Compression attempt {}: dimensions={}x{}, quality={}, size={} bytes",
                    attempts + 1, currentWidth, currentHeight, quality, compressedSize);

            if (compressedSize <= maxSizeBytes) {
                log.info("Successfully compressed image from {} bytes to {} bytes ({}x{})",
                        file.getSize(), compressedSize, currentWidth, currentHeight);
                break;
            }

            // Reduce dimensions by 10% for next attempt
            currentWidth = (int) (currentWidth * 0.9);
            currentHeight = (int) (currentHeight * 0.9);

            // Also reduce quality slightly for JPEG
            if (format.equals("jpg") && quality > 0.5f) {
                quality -= 0.05f;
            }

            attempts++;
        }

        if (compressedBytes != null && compressedBytes.length <= maxSizeBytes) {
            return compressedBytes;
        }

        // If we still can't compress it enough, return the last attempt
        log.warn("Could not compress image below {} bytes after {} attempts. Final size: {} bytes",
                maxSizeBytes, maxAttempts, compressedBytes != null ? compressedBytes.length : 0);
        return compressedBytes != null ? compressedBytes : file.getBytes();
    }

    /**
     * Detects image format from content type.
     *
     * @param contentType The MIME type of the image
     * @return Image format string (jpg, png, etc.)
     */
    private String detectImageFormat(String contentType) {
        if (contentType == null) {
            return "jpg"; // default
        }

        if (contentType.contains("png")) {
            return "png";
        } else if (contentType.contains("jpeg") || contentType.contains("jpg")) {
            return "jpg";
        } else if (contentType.contains("gif")) {
            return "gif";
        } else if (contentType.contains("bmp")) {
            return "bmp";
        } else if (contentType.contains("webp")) {
            return "webp";
        }

        return "jpg"; // default
    }

    /**
     * Resizes an image to the specified dimensions.
     *
     * @param originalImage The original buffered image
     * @param targetWidth   Target width in pixels
     * @param targetHeight  Target height in pixels
     * @param format        Image format (affects color model)
     * @return Resized buffered image
     */
    private BufferedImage resizeImage(
            BufferedImage originalImage,
            int targetWidth,
            int targetHeight,
            String format
    ) {
        if (targetWidth == originalImage.getWidth() && targetHeight == originalImage.getHeight()) {
            return originalImage;
        }

        int imageType = format.equals("png")
                ? BufferedImage.TYPE_INT_ARGB
                : BufferedImage.TYPE_INT_RGB;

        BufferedImage resizedImage = new BufferedImage(
                targetWidth,
                targetHeight,
                imageType
        );

        Graphics2D graphics = resizedImage.createGraphics();
        graphics.setRenderingHint(
                RenderingHints.KEY_INTERPOLATION,
                RenderingHints.VALUE_INTERPOLATION_BILINEAR
        );
        graphics.setRenderingHint(
                RenderingHints.KEY_RENDERING,
                RenderingHints.VALUE_RENDER_QUALITY
        );
        graphics.setRenderingHint(
                RenderingHints.KEY_ANTIALIASING,
                RenderingHints.VALUE_ANTIALIAS_ON
        );
        graphics.drawImage(originalImage, 0, 0, targetWidth, targetHeight, null);
        graphics.dispose();

        return resizedImage;
    }

    /**
     * Compresses an image to bytes with specified format and quality.
     *
     * @param image   The buffered image to compress
     * @param format  Image format (jpg, png, etc.)
     * @param quality Compression quality (0.0 to 1.0, only applies to JPEG)
     * @return Compressed image bytes
     * @throws IOException If compression fails
     */
    private byte[] compressImage(
            BufferedImage image,
            String format,
            float quality
    ) throws IOException {
        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();

        if (format.equals("jpg")) {
            // Use JPEG compression with quality control
            Iterator<ImageWriter> writers = ImageIO.getImageWritersByFormatName("jpg");
            if (!writers.hasNext()) {
                throw new FileStorageException("No JPEG writer found");
            }

            ImageWriter writer = writers.next();
            ImageWriteParam param = writer.getDefaultWriteParam();
            param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
            param.setCompressionQuality(quality);

            ImageOutputStream ios = ImageIO.createImageOutputStream(outputStream);
            writer.setOutput(ios);
            writer.write(null, new javax.imageio.IIOImage(image, null, null), param);
            writer.dispose();
            ios.close();
        } else {
            // For PNG and other formats, use standard compression
            ImageIO.write(image, format, outputStream);
        }

        return outputStream.toByteArray();
    }
}
