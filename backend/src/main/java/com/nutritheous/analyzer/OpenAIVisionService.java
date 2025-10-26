package com.nutritheous.analyzer;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nutritheous.common.dto.AnalysisResponse;
import com.nutritheous.common.exception.AnalyzerException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.io.IOException;
import java.util.*;

/**
 * Service for analyzing food images using OpenAI's Vision API.
 * Uses direct HTTP calls to support the vision multi-content message format.
 */
@Service
@Slf4j
public class OpenAIVisionService {

    private static final String OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final String apiKey;
    private final String model;
    private final int maxTokens;

    public OpenAIVisionService(
            RestTemplate restTemplate,
            @Value("${openai.api.key}") String apiKey,
            @Value("${openai.api.model:gpt-4o-mini}") String model,
            @Value("${openai.api.max-tokens:800}") int maxTokens) {

        this.restTemplate = restTemplate;
        this.objectMapper = new ObjectMapper();
        this.apiKey = apiKey;
        this.model = model;
        this.maxTokens = maxTokens;

        log.info("OpenAI Vision Service initialized with model: {}, max tokens: {}",
                model, maxTokens);
    }

    /**
     * Analyzes a food image and returns nutritional information.
     *
     * @param imageDataUri Base64 encoded image with data URI prefix (e.g., "data:image/jpeg;base64,...")
     * @param userDescription Optional user-provided description to help with analysis
     * @return AnalysisResponse with nutritional information
     * @throws AnalyzerException If analysis fails
     */
    public AnalysisResponse analyzeImage(String imageDataUri, String userDescription) throws AnalyzerException {
        log.info("Starting OpenAI Vision analysis with user description: {}", userDescription);

        try {
            // Build the request payload with multi-content format
            Map<String, Object> imageUrlContent = Map.of(
                "type", "image_url",
                "image_url", Map.of("url", imageDataUri)
            );

            Map<String, Object> textContent = Map.of(
                "type", "text",
                "text", getAnalysisPrompt(userDescription)
            );

            Map<String, Object> message = Map.of(
                "role", "user",
                "content", Arrays.asList(textContent, imageUrlContent)
            );

            Map<String, Object> requestBody = Map.of(
                "model", model,
                "max_tokens", maxTokens,
                "messages", Arrays.asList(message)
            );

            // Set up headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            // Create HTTP entity
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            // Make the API call
            log.debug("Calling OpenAI API: {}", OPENAI_API_URL);
            ResponseEntity<String> response = restTemplate.exchange(
                    OPENAI_API_URL,
                    HttpMethod.POST,
                    entity,
                    String.class
            );

            if (!response.getStatusCode().is2xxSuccessful()) {
                throw new AnalyzerException("OpenAI API returned error: " + response.getStatusCode());
            }

            // Parse the response
            JsonNode responseJson = objectMapper.readTree(response.getBody());

            if (!responseJson.has("choices") || responseJson.get("choices").isEmpty()) {
                throw new AnalyzerException("No response from OpenAI API");
            }

            // Extract the content
            String content = responseJson.get("choices").get(0)
                    .get("message")
                    .get("content")
                    .asText();

            log.info("Received OpenAI response");
            log.debug("Response content: {}", content);

            // Parse and return the analysis
            return parseResponse(content);

        } catch (AnalyzerException e) {
            throw e;
        } catch (Exception e) {
            log.error("OpenAI Vision analysis failed", e);
            throw new AnalyzerException("OpenAI analysis failed: " + e.getMessage(), e);
        }
    }

    /**
     * Parses the OpenAI response and converts it to AnalysisResponse.
     */
    private AnalysisResponse parseResponse(String content) throws AnalyzerException {
        try {
            // Clean up the response (remove markdown code blocks if present)
            String cleanedContent = cleanJsonResponse(content);
            log.debug("Cleaned response: {}", cleanedContent);

            // Parse JSON
            JsonNode jsonNode = objectMapper.readTree(cleanedContent);

            // Check for error response
            if (jsonNode.has("error")) {
                throw new AnalyzerException("AI returned error: " + jsonNode.get("error").asText());
            }

            // Map to AnalysisResponse
            AnalysisResponse response = AnalysisResponse.builder()
                    .servingSize(getStringValue(jsonNode, "serving_size"))
                    .calories(getIntValue(jsonNode, "calories"))
                    .proteinG(getDoubleValue(jsonNode, "protein_g"))
                    .fatG(getDoubleValue(jsonNode, "fat_g"))
                    .saturatedFatG(getDoubleValue(jsonNode, "saturated_fat_g"))
                    .carbohydratesG(getDoubleValue(jsonNode, "carbohydrates_g"))
                    .fiberG(getDoubleValue(jsonNode, "fiber_g"))
                    .sugarG(getDoubleValue(jsonNode, "sugar_g"))
                    .sodiumMg(getDoubleValue(jsonNode, "sodium_mg"))
                    .cholesterolMg(getDoubleValue(jsonNode, "cholesterol_mg"))
                    .ingredients(getStringList(jsonNode, "ingredients"))
                    .allergens(getStringList(jsonNode, "allergens"))
                    .healthNotes(getStringValue(jsonNode, "health_notes"))
                    .confidence(getDoubleValue(jsonNode, "confidence"))
                    .build();

            log.info("Successfully parsed nutrition response");
            return response;

        } catch (IOException e) {
            log.error("Failed to parse AI response", e);
            throw new AnalyzerException("Failed to parse AI response: " + e.getMessage(), e);
        }
    }

    /**
     * Cleans JSON response by removing markdown code blocks.
     */
    private String cleanJsonResponse(String content) {
        if (content == null) {
            return "";
        }

        content = content.trim();

        // Remove markdown code blocks
        if (content.startsWith("```json")) {
            content = content.substring(7);
        } else if (content.startsWith("```")) {
            content = content.substring(3);
        }

        if (content.endsWith("```")) {
            content = content.substring(0, content.length() - 3);
        }

        return content.trim();
    }

    /**
     * Helper method to safely extract string values from JSON.
     */
    private String getStringValue(JsonNode node, String fieldName) {
        return node.has(fieldName) ? node.get(fieldName).asText() : null;
    }

    /**
     * Helper method to safely extract integer values from JSON.
     */
    private Integer getIntValue(JsonNode node, String fieldName) {
        return node.has(fieldName) ? node.get(fieldName).asInt() : null;
    }

    /**
     * Helper method to safely extract double values from JSON.
     */
    private Double getDoubleValue(JsonNode node, String fieldName) {
        if (!node.has(fieldName)) {
            return null;
        }

        JsonNode fieldNode = node.get(fieldName);
        if (fieldNode.isNull()) {
            return null;
        }

        return fieldNode.asDouble();
    }

    /**
     * Helper method to safely extract string lists from JSON.
     */
    private List<String> getStringList(JsonNode node, String fieldName) {
        if (!node.has(fieldName) || !node.get(fieldName).isArray()) {
            return new ArrayList<>();
        }

        List<String> list = new ArrayList<>();
        for (JsonNode item : node.get(fieldName)) {
            list.add(item.asText());
        }
        return list;
    }

    /**
     * Analyzes a text description only (no image) and returns nutritional information.
     *
     * @param description User-provided description of the meal
     * @return AnalysisResponse with nutritional information
     * @throws AnalyzerException If analysis fails
     */
    public AnalysisResponse analyzeTextOnly(String description) throws AnalyzerException {
        log.info("Starting OpenAI text-only analysis for: {}", description);

        try {
            // Build the request payload with text-only format
            Map<String, Object> message = Map.of(
                "role", "user",
                "content", getTextOnlyPrompt(description)
            );

            Map<String, Object> requestBody = Map.of(
                "model", model,
                "max_tokens", maxTokens,
                "messages", Arrays.asList(message)
            );

            // Set up headers
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            // Create HTTP entity
            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

            // Make the API call
            log.debug("Calling OpenAI API for text-only analysis: {}", OPENAI_API_URL);
            ResponseEntity<String> response = restTemplate.exchange(
                    OPENAI_API_URL,
                    HttpMethod.POST,
                    entity,
                    String.class
            );

            if (!response.getStatusCode().is2xxSuccessful()) {
                throw new AnalyzerException("OpenAI API returned error: " + response.getStatusCode());
            }

            // Parse the response
            JsonNode responseJson = objectMapper.readTree(response.getBody());

            if (!responseJson.has("choices") || responseJson.get("choices").isEmpty()) {
                throw new AnalyzerException("No response from OpenAI API");
            }

            // Extract the content
            String content = responseJson.get("choices").get(0)
                    .get("message")
                    .get("content")
                    .asText();

            log.info("Received OpenAI text-only response");
            log.debug("Response content: {}", content);

            // Parse and return the analysis
            return parseResponse(content);

        } catch (AnalyzerException e) {
            throw e;
        } catch (Exception e) {
            log.error("OpenAI text-only analysis failed", e);
            throw new AnalyzerException("OpenAI text analysis failed: " + e.getMessage(), e);
        }
    }

    /**
     * Returns the AI prompt for nutritional analysis.
     * Incorporates user-provided description if available.
     */
    private String getAnalysisPrompt(String userDescription) {
        String userContext = "";
        if (userDescription != null && !userDescription.isBlank()) {
            userContext = "\n\nUSER'S DESCRIPTION: \"" + userDescription + "\"\n" +
                         "Use this description to better understand the food. For example, if they mention 'with sugar' or 'black coffee', " +
                         "adjust your nutritional analysis accordingly. The user's description provides important context about preparation, " +
                         "ingredients, or portions that may not be visible in the image.\n";
        }

        return """
                You are a nutrition analysis expert. Analyze the food in this image and provide detailed nutritional information.
                """ + userContext + """

                CRITICAL: Return ONLY a valid JSON object. No markdown, no code blocks, no explanation - just pure JSON.

                Required JSON structure:
                {
                  "serving_size": "estimated serving size (e.g., '1 plate', '2 slices', '300g')",
                  "calories": 0,
                  "protein_g": 0.0,
                  "fat_g": 0.0,
                  "saturated_fat_g": 0.0,
                  "carbohydrates_g": 0.0,
                  "fiber_g": 0.0,
                  "sugar_g": 0.0,
                  "sodium_mg": 0.0,
                  "cholesterol_mg": 0.0,
                  "ingredients": ["main ingredient 1", "ingredient 2"],
                  "allergens": ["potential allergen 1", "allergen 2"],
                  "health_notes": "brief health insights (high protein, low carb, etc.)",
                  "confidence": 0.85
                }

                Rules:
                - All numeric fields must be numbers (not strings)
                - Use 0 for unknown values (never use null or omit required fields)
                - serving_size must be a string describing the portion
                - ingredients should list main components you can identify
                - allergens should list common allergens (dairy, nuts, gluten, etc.)
                - health_notes should be 1-2 sentences about nutritional highlights
                - confidence should be 0.0-1.0 based on image clarity and food recognition

                If this is NOT a food image, return exactly:
                {"error": "Not a food item"}

                Remember: Return ONLY the JSON object, nothing else.
                If unsure about exact values, provide approximate estimates based on similar foods rather than leaving fields empty.
                """;
    }

    /**
     * Returns the AI prompt for text-only nutritional analysis.
     */
    private String getTextOnlyPrompt(String description) {
        return """
                You are a nutrition analysis expert. Based on the text description provided by the user, estimate the nutritional information for the meal.

                USER'S MEAL DESCRIPTION: "%s"

                Analyze this description and provide your best estimate of the nutritional content. Consider typical portion sizes and preparation methods.

                CRITICAL: Return ONLY a valid JSON object. No markdown, no code blocks, no explanation - just pure JSON.

                Required JSON structure:
                {
                  "serving_size": "estimated serving size (e.g., '1 plate', '2 slices', '300g')",
                  "calories": 0,
                  "protein_g": 0.0,
                  "fat_g": 0.0,
                  "saturated_fat_g": 0.0,
                  "carbohydrates_g": 0.0,
                  "fiber_g": 0.0,
                  "sugar_g": 0.0,
                  "sodium_mg": 0.0,
                  "cholesterol_mg": 0.0,
                  "ingredients": ["main ingredient 1", "ingredient 2"],
                  "allergens": ["potential allergen 1", "allergen 2"],
                  "health_notes": "brief health insights (high protein, low carb, etc.)",
                  "confidence": 0.65
                }

                Rules:
                - All numeric fields must be numbers (not strings)
                - Use 0 for unknown values (never use null or omit required fields)
                - serving_size should be estimated from the description or use typical portions
                - ingredients should list components mentioned or implied in the description
                - allergens should list common allergens (dairy, nuts, gluten, etc.) based on the description
                - health_notes should be 1-2 sentences about nutritional highlights
                - confidence should be 0.0-1.0 (use lower values like 0.5-0.7 for text-only estimates)

                Remember: Return ONLY the JSON object, nothing else.
                Provide reasonable estimates based on typical nutritional values for similar foods.
                """.formatted(description);
    }
}
