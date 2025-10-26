package com.nutritheous.meal.dto;

import com.nutritheous.meal.Meal;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DTO for updating meal metadata
 * Allows users to edit meal details and nutritional information
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MealUpdateRequest {

    // Basic meal metadata
    private Meal.MealType mealType;
    private LocalDateTime mealTime;

    @Size(max = 500, message = "Description cannot exceed 500 characters")
    private String description;

    @Size(max = 255, message = "Serving size cannot exceed 255 characters")
    private String servingSize;

    // Nutritional information
    @Min(value = 0, message = "Calories must be non-negative")
    @Max(value = 10000, message = "Calories must be less than 10000")
    private Integer calories;

    @DecimalMin(value = "0.0", message = "Protein must be non-negative")
    @DecimalMax(value = "1000.0", message = "Protein must be less than 1000g")
    private Double proteinG;

    @DecimalMin(value = "0.0", message = "Fat must be non-negative")
    @DecimalMax(value = "1000.0", message = "Fat must be less than 1000g")
    private Double fatG;

    @DecimalMin(value = "0.0", message = "Saturated fat must be non-negative")
    @DecimalMax(value = "1000.0", message = "Saturated fat must be less than 1000g")
    private Double saturatedFatG;

    @DecimalMin(value = "0.0", message = "Carbohydrates must be non-negative")
    @DecimalMax(value = "1000.0", message = "Carbohydrates must be less than 1000g")
    private Double carbohydratesG;

    @DecimalMin(value = "0.0", message = "Fiber must be non-negative")
    @DecimalMax(value = "1000.0", message = "Fiber must be less than 1000g")
    private Double fiberG;

    @DecimalMin(value = "0.0", message = "Sugar must be non-negative")
    @DecimalMax(value = "1000.0", message = "Sugar must be less than 1000g")
    private Double sugarG;

    @DecimalMin(value = "0.0", message = "Sodium must be non-negative")
    @DecimalMax(value = "100000.0", message = "Sodium must be less than 100000mg")
    private Double sodiumMg;

    @DecimalMin(value = "0.0", message = "Cholesterol must be non-negative")
    @DecimalMax(value = "10000.0", message = "Cholesterol must be less than 10000mg")
    private Double cholesterolMg;

    // Additional metadata
    private List<String> ingredients;
    private List<String> allergens;

    @Size(max = 1000, message = "Health notes cannot exceed 1000 characters")
    private String healthNotes;
}
