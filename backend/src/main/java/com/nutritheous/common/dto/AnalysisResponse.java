package com.nutritheous.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AnalysisResponse {

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
}
