package com.nutritheous.analyzer;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.Base64;
import java.util.Iterator;
import java.util.Set;

/**
 * Service for processing and optimizing images for AI analysis.
 * Handles format conversion, resizing, and base64 encoding.
 */
@Service
@Slf4j
public class ImageProcessingService {

    private static final int MAX_DIMENSION = 512; // Max dimension for cost optimization
    private static final Set<String> SUPPORTED_FORMATS = Set.of(
            "jpg", "jpeg", "png", "gif", "bmp", "webp"
    );

    /**
     * Downloads an image from a URL and processes it for AI analysis.
     *
     * @param imageUrl The URL to download the image from
     * @return Base64 encoded image data with data URI prefix (e.g., "data:image/jpeg;base64,...")
     * @throws IOException If image cannot be downloaded or processed
     */
    public String processImageFromUrl(String imageUrl) throws IOException {
        log.info("Downloading and processing image from URL: {}", imageUrl);

        // Download image
        byte[] imageData = downloadImage(imageUrl);

        // Process the image
        return processImageData(imageData);
    }

    /**
     * Processes raw image data for AI analysis.
     *
     * @param imageData Raw image bytes
     * @return Base64 encoded image data with data URI prefix
     * @throws IOException If image cannot be processed
     */
    public String processImageData(byte[] imageData) throws IOException {
        // Detect image format
        String format = detectImageFormat(imageData);
        log.info("Detected image format: {}", format);

        if (!SUPPORTED_FORMATS.contains(format.toLowerCase())) {
            throw new IOException("Unsupported image format: " + format);
        }

        // Read image
        BufferedImage image = readImage(imageData);
        if (image == null) {
            throw new IOException("Failed to read image data");
        }

        log.info("Original image dimensions: {}x{}", image.getWidth(), image.getHeight());

        // Resize if needed
        BufferedImage processedImage = resizeIfNeeded(image);

        // Convert to JPEG for consistency and smaller size
        byte[] optimizedData = convertToJpeg(processedImage);

        // Encode to base64 with data URI prefix
        String base64 = Base64.getEncoder().encodeToString(optimizedData);
        String dataUri = "data:image/jpeg;base64," + base64;

        log.info("Image processed successfully. Final size: {} bytes", optimizedData.length);

        return dataUri;
    }

    /**
     * Downloads an image from a URL.
     */
    private byte[] downloadImage(String imageUrl) throws IOException {
        try (InputStream in = new URL(imageUrl).openStream();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {

            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }

            return out.toByteArray();
        }
    }

    /**
     * Detects the image format from raw bytes.
     */
    private String detectImageFormat(byte[] imageData) throws IOException {
        try (ImageInputStream iis = ImageIO.createImageInputStream(new ByteArrayInputStream(imageData))) {
            Iterator<ImageReader> readers = ImageIO.getImageReaders(iis);
            if (readers.hasNext()) {
                ImageReader reader = readers.next();
                String format = reader.getFormatName();
                reader.dispose();
                return format;
            }
        }
        throw new IOException("Unable to detect image format");
    }

    /**
     * Reads an image from raw bytes.
     */
    private BufferedImage readImage(byte[] imageData) throws IOException {
        try (ByteArrayInputStream bais = new ByteArrayInputStream(imageData)) {
            return ImageIO.read(bais);
        }
    }

    /**
     * Resizes the image if it exceeds MAX_DIMENSION in either width or height.
     * Maintains aspect ratio.
     */
    private BufferedImage resizeIfNeeded(BufferedImage original) {
        int width = original.getWidth();
        int height = original.getHeight();

        // Check if resizing is needed
        if (width <= MAX_DIMENSION && height <= MAX_DIMENSION) {
            log.info("Image dimensions are within limits, no resizing needed");
            return original;
        }

        // Calculate new dimensions maintaining aspect ratio
        double scale;
        if (width > height) {
            scale = (double) MAX_DIMENSION / width;
        } else {
            scale = (double) MAX_DIMENSION / height;
        }

        int newWidth = (int) (width * scale);
        int newHeight = (int) (height * scale);

        log.info("Resizing image from {}x{} to {}x{}", width, height, newWidth, newHeight);

        // Create resized image
        BufferedImage resized = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_INT_RGB);
        Graphics2D g2d = resized.createGraphics();

        // Use high-quality rendering
        g2d.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g2d.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);

        g2d.drawImage(original, 0, 0, newWidth, newHeight, null);
        g2d.dispose();

        return resized;
    }

    /**
     * Converts an image to JPEG format.
     */
    private byte[] convertToJpeg(BufferedImage image) throws IOException {
        try (ByteArrayOutputStream baos = new ByteArrayOutputStream()) {
            // Ensure image is in RGB format (JPEG doesn't support alpha channel)
            BufferedImage rgbImage = image;
            if (image.getType() != BufferedImage.TYPE_INT_RGB) {
                rgbImage = new BufferedImage(image.getWidth(), image.getHeight(), BufferedImage.TYPE_INT_RGB);
                Graphics2D g = rgbImage.createGraphics();
                g.drawImage(image, 0, 0, null);
                g.dispose();
            }

            // Write as JPEG
            if (!ImageIO.write(rgbImage, "jpg", baos)) {
                throw new IOException("Failed to write image as JPEG");
            }

            return baos.toByteArray();
        }
    }
}
