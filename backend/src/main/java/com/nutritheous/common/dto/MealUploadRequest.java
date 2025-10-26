package com.nutritheous.common.dto;

import com.nutritheous.meal.Meal;
import jakarta.validation.constraints.NotNull;
import lombok.Data;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Data
public class MealUploadRequest {

    @NotNull(message = "Image file is required")
    private MultipartFile image;

    private Meal.MealType mealType;

    private LocalDateTime mealTime;

    private String description;
}
