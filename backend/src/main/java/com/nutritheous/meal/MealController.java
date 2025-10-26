package com.nutritheous.meal;

import com.nutritheous.auth.User;
import com.nutritheous.common.dto.MealResponse;
import com.nutritheous.meal.dto.MealUpdateRequest;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/meals")
@Tag(name = "Meals", description = "Meal management and nutritional analysis endpoints")
@SecurityRequirement(name = "bearerAuth")
@Slf4j
public class MealController {

    @Autowired
    private MealService mealService;

    @PostMapping(value = "/upload", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @Operation(summary = "Upload meal", description = "Upload a food image and/or description for nutritional analysis. Either image or description (or both) is required.")
    public ResponseEntity<MealResponse> uploadMeal(
            @AuthenticationPrincipal User user,
            @RequestParam(value = "image", required = false) MultipartFile image,
            @RequestParam(value = "mealType", required = false) Meal.MealType mealType,
            @RequestParam(value = "mealTime", required = false)
            @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime mealTime,
            @RequestParam(value = "description", required = false) String description
    ) {
        // Validate that at least one of image or description is provided
        if ((image == null || image.isEmpty()) && (description == null || description.isBlank())) {
            log.warn("❌ Meal upload rejected - neither image nor description provided");
            return ResponseEntity.badRequest().build();
        }

        log.info("🍽️  Received meal upload request - User: {}, Type: {}, Has Image: {}, Has Description: {}",
                user.getEmail(), mealType, image != null && !image.isEmpty(), description != null && !description.isBlank());

        MealResponse response = mealService.uploadMeal(
                user.getId(),
                image,
                mealType,
                mealTime,
                description
        );

        log.info("✅ Meal upload complete - ID: {}, Image URL available: {}",
                response.getId(), response.getImageUrl() != null);

        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }

    @GetMapping("/{mealId}")
    @Operation(summary = "Get meal by ID", description = "Retrieve a specific meal by its ID")
    public ResponseEntity<MealResponse> getMealById(
            @AuthenticationPrincipal User user,
            @PathVariable UUID mealId
    ) {
        MealResponse response = mealService.getMealById(mealId, user.getId());
        return ResponseEntity.ok(response);
    }

    @GetMapping
    @Operation(summary = "Get all user meals", description = "Retrieve all meals for the authenticated user")
    public ResponseEntity<List<MealResponse>> getUserMeals(
            @AuthenticationPrincipal User user
    ) {
        log.info("📋 Fetching all meals for user: {}", user.getEmail());

        List<MealResponse> meals = mealService.getUserMeals(user.getId());

        log.info("✅ Retrieved {} meals for user: {}", meals.size(), user.getEmail());
        log.info("📊 Each meal response contains fresh signed URLs (valid for 24 hours)");

        return ResponseEntity.ok(meals);
    }

    @GetMapping("/range")
    @Operation(summary = "Get meals by date range", description = "Retrieve meals within a specific date range")
    public ResponseEntity<List<MealResponse>> getMealsByDateRange(
            @AuthenticationPrincipal User user,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime endDate
    ) {
        List<MealResponse> meals = mealService.getUserMealsByDateRange(user.getId(), startDate, endDate);
        return ResponseEntity.ok(meals);
    }

    @GetMapping("/type/{mealType}")
    @Operation(summary = "Get meals by type", description = "Retrieve meals filtered by meal type")
    public ResponseEntity<List<MealResponse>> getMealsByType(
            @AuthenticationPrincipal User user,
            @PathVariable Meal.MealType mealType
    ) {
        List<MealResponse> meals = mealService.getUserMealsByType(user.getId(), mealType);
        return ResponseEntity.ok(meals);
    }

    @PutMapping("/{mealId}")
    @Operation(summary = "Update meal metadata", description = "Update meal details and nutritional information")
    public ResponseEntity<MealResponse> updateMeal(
            @AuthenticationPrincipal User user,
            @PathVariable UUID mealId,
            @Valid @RequestBody MealUpdateRequest request
    ) {
        MealResponse response = mealService.updateMeal(mealId, user.getId(), request);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{mealId}")
    @Operation(summary = "Delete meal", description = "Delete a specific meal")
    public ResponseEntity<Void> deleteMeal(
            @AuthenticationPrincipal User user,
            @PathVariable UUID mealId
    ) {
        mealService.deleteMeal(mealId, user.getId());
        return ResponseEntity.noContent().build();
    }
}
