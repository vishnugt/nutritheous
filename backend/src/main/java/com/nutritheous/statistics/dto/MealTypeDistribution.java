package com.nutritheous.statistics.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Distribution of meals by type")
public class MealTypeDistribution {

    @Schema(description = "Meal type", example = "BREAKFAST")
    private String mealType;

    @Schema(description = "Number of meals of this type", example = "15")
    private Long count;

    @Schema(description = "Percentage of total meals", example = "25.5")
    private Double percentage;
}
