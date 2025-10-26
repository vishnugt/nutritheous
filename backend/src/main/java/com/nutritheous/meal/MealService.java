package com.nutritheous.meal;

import com.nutritheous.analyzer.AnalyzerService;
import com.nutritheous.auth.User;
import com.nutritheous.auth.UserRepository;
import com.nutritheous.common.dto.AnalysisResponse;
import com.nutritheous.common.dto.MealResponse;
import com.nutritheous.common.exception.AnalyzerException;
import com.nutritheous.common.exception.ResourceNotFoundException;
import com.nutritheous.meal.dto.MealUpdateRequest;
import com.nutritheous.storage.GoogleCloudStorageService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
public class MealService {

    private static final Logger logger = LoggerFactory.getLogger(MealService.class);

    @Autowired
    private MealRepository mealRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private GoogleCloudStorageService storageService;

    @Autowired
    private AnalyzerService analyzerService;

    @Transactional
    public MealResponse uploadMeal(
            UUID userId,
            MultipartFile image,
            Meal.MealType mealType,
            LocalDateTime mealTime,
            String description
    ) {
        // Validate user exists
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));

        String objectName = null;
        String tempAnalyzerUrl = null;
        boolean hasImage = image != null && !image.isEmpty();

        // Upload image to storage if provided
        if (hasImage) {
            logger.info("Uploading image to storage for user: {}", userId);
            objectName = storageService.uploadFile(image, userId);
            // Generate temporary presigned URL for the AI analyzer
            tempAnalyzerUrl = storageService.getPresignedUrl(objectName);
        } else {
            logger.info("No image provided, creating text-only meal entry");
        }

        // Create meal entity with pending status
        Meal meal = Meal.builder()
                .user(user)
                .mealTime(mealTime != null ? mealTime : LocalDateTime.now())
                .mealType(mealType)
                .objectName(objectName)
                .description(description)
                .analysisStatus(Meal.AnalysisStatus.PENDING)
                .build();

        meal = mealRepository.save(meal);
        logger.info("Created meal with id: {}", meal.getId());

        // Analyze the meal (with or without image)
        UUID mealId = meal.getId();
        try {
            if (hasImage) {
                logger.info("Sending image to AI analyzer with user description: {}", description);
                AnalysisResponse analysisResponse = analyzerService.analyzeImage(tempAnalyzerUrl, description);
                updateMealWithAnalysis(meal, analysisResponse);
            } else if (description != null && !description.isBlank()) {
                logger.info("Analyzing text-only meal description: {}", description);
                AnalysisResponse analysisResponse = analyzerService.analyzeTextOnly(description);
                updateMealWithAnalysis(meal, analysisResponse);
            } else {
                // This shouldn't happen due to validation in controller, but handle it
                logger.warn("Meal {} has neither image nor description", mealId);
                meal.setAnalysisStatus(Meal.AnalysisStatus.FAILED);
            }

            meal = mealRepository.save(meal);
            logger.info("Updated meal {} with analysis results", mealId);

        } catch (AnalyzerException e) {
            logger.error("Failed to analyze meal {}", mealId, e);
            meal.setAnalysisStatus(Meal.AnalysisStatus.FAILED);
            meal = mealRepository.save(meal);
        }

        return MealResponse.fromMeal(meal, storageService);
    }

    private void updateMealWithAnalysis(Meal meal, AnalysisResponse analysisResponse) {
        // Update meal with analysis results - map all fields (note: description is kept from user input, not AI)
        meal.setServingSize(analysisResponse.getServingSize());
        meal.setCalories(analysisResponse.getCalories());
        meal.setProteinG(analysisResponse.getProteinG());
        meal.setFatG(analysisResponse.getFatG());
        meal.setSaturatedFatG(analysisResponse.getSaturatedFatG());
        meal.setCarbohydratesG(analysisResponse.getCarbohydratesG());
        meal.setFiberG(analysisResponse.getFiberG());
        meal.setSugarG(analysisResponse.getSugarG());
        meal.setSodiumMg(analysisResponse.getSodiumMg());
        meal.setCholesterolMg(analysisResponse.getCholesterolMg());
        meal.setIngredients(analysisResponse.getIngredients());
        meal.setAllergens(analysisResponse.getAllergens());
        meal.setHealthNotes(analysisResponse.getHealthNotes());
        meal.setConfidence(analysisResponse.getConfidence());
        meal.setAnalysisStatus(Meal.AnalysisStatus.COMPLETED);
    }

    public MealResponse getMealById(UUID mealId, UUID userId) {
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new ResourceNotFoundException("Meal not found with id: " + mealId));

        // Ensure the meal belongs to the user
        if (!meal.getUser().getId().equals(userId)) {
            throw new ResourceNotFoundException("Meal not found with id: " + mealId);
        }

        return MealResponse.fromMeal(meal, storageService);
    }

    public List<MealResponse> getUserMeals(UUID userId) {
        return mealRepository.findByUserIdOrderByMealTimeDesc(userId)
                .stream()
                .map(meal -> MealResponse.fromMeal(meal, storageService))
                .collect(Collectors.toList());
    }

    public List<MealResponse> getUserMealsByDateRange(
            UUID userId,
            LocalDateTime startDate,
            LocalDateTime endDate
    ) {
        return mealRepository.findByUserIdAndMealTimeBetweenOrderByMealTimeDesc(userId, startDate, endDate)
                .stream()
                .map(meal -> MealResponse.fromMeal(meal, storageService))
                .collect(Collectors.toList());
    }

    public List<MealResponse> getUserMealsByType(UUID userId, Meal.MealType mealType) {
        return mealRepository.findByUserIdAndMealTypeOrderByMealTimeDesc(userId, mealType)
                .stream()
                .map(meal -> MealResponse.fromMeal(meal, storageService))
                .collect(Collectors.toList());
    }

    @Transactional
    public MealResponse updateMeal(UUID mealId, UUID userId, MealUpdateRequest request) {
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new ResourceNotFoundException("Meal not found with id: " + mealId));

        // Ensure the meal belongs to the user
        if (!meal.getUser().getId().equals(userId)) {
            throw new ResourceNotFoundException("Meal not found with id: " + mealId);
        }

        // Update meal metadata (only update non-null fields)
        if (request.getMealType() != null) {
            meal.setMealType(request.getMealType());
        }
        if (request.getMealTime() != null) {
            meal.setMealTime(request.getMealTime());
        }
        if (request.getDescription() != null) {
            meal.setDescription(request.getDescription());
        }
        if (request.getServingSize() != null) {
            meal.setServingSize(request.getServingSize());
        }

        // Update nutritional information
        if (request.getCalories() != null) {
            meal.setCalories(request.getCalories());
        }
        if (request.getProteinG() != null) {
            meal.setProteinG(request.getProteinG());
        }
        if (request.getFatG() != null) {
            meal.setFatG(request.getFatG());
        }
        if (request.getSaturatedFatG() != null) {
            meal.setSaturatedFatG(request.getSaturatedFatG());
        }
        if (request.getCarbohydratesG() != null) {
            meal.setCarbohydratesG(request.getCarbohydratesG());
        }
        if (request.getFiberG() != null) {
            meal.setFiberG(request.getFiberG());
        }
        if (request.getSugarG() != null) {
            meal.setSugarG(request.getSugarG());
        }
        if (request.getSodiumMg() != null) {
            meal.setSodiumMg(request.getSodiumMg());
        }
        if (request.getCholesterolMg() != null) {
            meal.setCholesterolMg(request.getCholesterolMg());
        }

        // Update additional metadata
        if (request.getIngredients() != null) {
            meal.setIngredients(request.getIngredients());
        }
        if (request.getAllergens() != null) {
            meal.setAllergens(request.getAllergens());
        }
        if (request.getHealthNotes() != null) {
            meal.setHealthNotes(request.getHealthNotes());
        }

        meal = mealRepository.save(meal);
        logger.info("Updated meal with id: {}", mealId);

        return MealResponse.fromMeal(meal, storageService);
    }

    @Transactional
    public void deleteMeal(UUID mealId, UUID userId) {
        Meal meal = mealRepository.findById(mealId)
                .orElseThrow(() -> new ResourceNotFoundException("Meal not found with id: " + mealId));

        // Ensure the meal belongs to the user
        if (!meal.getUser().getId().equals(userId)) {
            throw new ResourceNotFoundException("Meal not found with id: " + mealId);
        }

        // Delete image from storage
        try {
            if (meal.getObjectName() != null) {
                storageService.deleteFile(meal.getObjectName());
            }
        } catch (Exception e) {
            logger.error("Failed to delete image from storage for meal {}", mealId, e);
        }

        // Delete meal from database
        mealRepository.delete(meal);
        logger.info("Deleted meal with id: {}", mealId);
    }
}
