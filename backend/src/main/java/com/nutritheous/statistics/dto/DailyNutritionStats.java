package com.nutritheous.statistics.dto;

import com.fasterxml.jackson.annotation.JsonFormat;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Daily nutrition statistics for a single day")
public class DailyNutritionStats {

    @Schema(description = "Date of the statistics", example = "2024-01-15")
    @JsonFormat(pattern = "yyyy-MM-dd")
    private LocalDate date;

    @Schema(description = "Total calories consumed", example = "2150")
    private Integer totalCalories;

    @Schema(description = "Total protein in grams", example = "85.5")
    private Double totalProteinG;

    @Schema(description = "Total fat in grams", example = "65.2")
    private Double totalFatG;

    @Schema(description = "Total saturated fat in grams", example = "20.5")
    private Double totalSaturatedFatG;

    @Schema(description = "Total carbohydrates in grams", example = "250.0")
    private Double totalCarbohydratesG;

    @Schema(description = "Total fiber in grams", example = "30.5")
    private Double totalFiberG;

    @Schema(description = "Total sugar in grams", example = "45.5")
    private Double totalSugarG;

    @Schema(description = "Total sodium in milligrams", example = "2200.0")
    private Double totalSodiumMg;

    @Schema(description = "Total cholesterol in milligrams", example = "180.0")
    private Double totalCholesterolMg;

    @Schema(description = "Number of meals on this day", example = "4")
    private Integer mealCount;
}
