package com.nutritheous.analyzer;

import com.nutritheous.common.dto.AnalysisResponse;
import com.nutritheous.common.exception.AnalyzerException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Service for analyzing food images using local Java implementation.
 * This replaces the previous HTTP-based approach that called a separate Go service.
 *
 * IMPORTANT: This service only accepts image URLs (typically presigned URLs from GCS).
 * It does NOT accept multipart file uploads directly - use MealService.uploadMeal() for that.
 */
@Service
@Slf4j
public class AnalyzerService {

    private final ImageProcessingService imageProcessingService;
    private final OpenAIVisionService openAIVisionService;

    public AnalyzerService(
            ImageProcessingService imageProcessingService,
            OpenAIVisionService openAIVisionService) {
        this.imageProcessingService = imageProcessingService;
        this.openAIVisionService = openAIVisionService;
        log.info("AnalyzerService initialized with local Java implementation");
    }

    /**
     * Analyzes an image from a URL and returns nutritional information.
     *
     * @param imageUrl The URL of the image to analyze (must be a valid image URL, typically a presigned GCS URL)
     * @param userDescription Optional user-provided description to help with analysis
     * @return AnalysisResponse containing nutritional information
     * @throws AnalyzerException If analysis fails
     */
    public AnalysisResponse analyzeImage(String imageUrl, String userDescription) throws AnalyzerException {
        try {
            log.info("Starting local image analysis for URL: {} with description: {}", imageUrl, userDescription);

            // Step 1: Download and process the image (resize, convert to JPEG, encode to base64)
            String imageDataUri = imageProcessingService.processImageFromUrl(imageUrl);
            log.debug("Image processed successfully, data URI length: {}", imageDataUri.length());

            // Step 2: Analyze with OpenAI Vision API
            AnalysisResponse response = openAIVisionService.analyzeImage(imageDataUri, userDescription);
            log.info("Analysis completed successfully");

            return response;

        } catch (AnalyzerException e) {
            throw e;
        } catch (Exception e) {
            log.error("Unexpected error during image analysis", e);
            throw new AnalyzerException("Failed to analyze image: " + e.getMessage(), e);
        }
    }

    /**
     * Analyzes a text description only (no image) and returns estimated nutritional information.
     *
     * @param description User-provided description of the meal
     * @return AnalysisResponse containing estimated nutritional information
     * @throws AnalyzerException If analysis fails
     */
    public AnalysisResponse analyzeTextOnly(String description) throws AnalyzerException {
        try {
            log.info("Starting text-only analysis for description: {}", description);

            // Analyze with OpenAI (text-only)
            AnalysisResponse response = openAIVisionService.analyzeTextOnly(description);
            log.info("Text-only analysis completed successfully");

            return response;

        } catch (AnalyzerException e) {
            throw e;
        } catch (Exception e) {
            log.error("Unexpected error during text-only analysis", e);
            throw new AnalyzerException("Failed to analyze text: " + e.getMessage(), e);
        }
    }
}
