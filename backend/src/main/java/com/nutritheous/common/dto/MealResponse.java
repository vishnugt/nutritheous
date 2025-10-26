package com.nutritheous.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import com.nutritheous.meal.Meal;
import com.nutritheous.storage.GoogleCloudStorageService;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealResponse {

    private UUID id;
    private LocalDateTime mealTime;
    private Meal.MealType mealType;
    private String imageUrl;
    private String objectName;
    private String description;

    @JsonProperty("serving_size")
    private String servingSize;

    private Integer calories;

    @JsonProperty("protein_g")
    private Double proteinG;

    @JsonProperty("fat_g")
    private Double fatG;

    @JsonProperty("saturated_fat_g")
    private Double saturatedFatG;

    @JsonProperty("carbohydrates_g")
    private Double carbohydratesG;

    @JsonProperty("fiber_g")
    private Double fiberG;

    @JsonProperty("sugar_g")
    private Double sugarG;

    @JsonProperty("sodium_mg")
    private Double sodiumMg;

    @JsonProperty("cholesterol_mg")
    private Double cholesterolMg;

    private List<String> ingredients;
    private List<String> allergens;

    @JsonProperty("health_notes")
    private String healthNotes;

    private Double confidence;
    private Meal.AnalysisStatus analysisStatus;
    private LocalDateTime createdAt;

    public static MealResponse fromMeal(Meal meal, GoogleCloudStorageService storageService) {
        // Generate fresh presigned URL from object name
        String imageUrl = "";
        if (meal.getObjectName() != null) {
            imageUrl = storageService.getPresignedImageUrl(meal.getObjectName());
        }

        return MealResponse.builder()
                .id(meal.getId())
                .mealTime(meal.getMealTime())
                .mealType(meal.getMealType())
                .imageUrl(imageUrl)
                .objectName(meal.getObjectName())
                .description(meal.getDescription())
                .servingSize(meal.getServingSize())
                .calories(meal.getCalories())
                .proteinG(meal.getProteinG())
                .fatG(meal.getFatG())
                .saturatedFatG(meal.getSaturatedFatG())
                .carbohydratesG(meal.getCarbohydratesG())
                .fiberG(meal.getFiberG())
                .sugarG(meal.getSugarG())
                .sodiumMg(meal.getSodiumMg())
                .cholesterolMg(meal.getCholesterolMg())
                .ingredients(meal.getIngredients())
                .allergens(meal.getAllergens())
                .healthNotes(meal.getHealthNotes())
                .confidence(meal.getConfidence())
                .analysisStatus(meal.getAnalysisStatus())
                .createdAt(meal.getCreatedAt())
                .build();
    }
}
