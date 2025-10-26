package com.nutritheous.statistics.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Summary of nutrition statistics over a time period")
public class NutritionSummary {

    @Schema(description = "Total number of meals tracked")
    private Long totalMeals;

    @Schema(description = "Average calories per day")
    private Double avgCaloriesPerDay;

    @Schema(description = "Average protein per day in grams")
    private Double avgProteinPerDay;

    @Schema(description = "Average carbohydrates per day in grams")
    private Double avgCarbsPerDay;

    @Schema(description = "Average fat per day in grams")
    private Double avgFatPerDay;

    @Schema(description = "Daily nutrition breakdown (for plotting)")
    private List<DailyNutritionStats> dailyStats;

    @Schema(description = "Distribution of meals by type")
    private List<MealTypeDistribution> mealTypeDistribution;
}
