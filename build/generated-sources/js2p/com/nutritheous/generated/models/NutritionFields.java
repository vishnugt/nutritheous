
package com.nutritheous.generated.models;

import javax.annotation.processing.Generated;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * NutritionFields
 * <p>
 * Common nutritional information fields shared across models
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
    "calories",
    "protein_g",
    "fat_g",
    "saturated_fat_g",
    "carbohydrates_g",
    "fiber_g",
    "sugar_g",
    "sodium_mg",
    "cholesterol_mg"
})
@Generated("jsonschema2pojo")
public class NutritionFields {

    /**
     * Total calories (kcal)
     * 
     */
    @JsonProperty("calories")
    @JsonPropertyDescription("Total calories (kcal)")
    private Integer calories;
    /**
     * Protein in grams
     * 
     */
    @JsonProperty("protein_g")
    @JsonPropertyDescription("Protein in grams")
    private Double proteinG;
    /**
     * Total fat in grams
     * 
     */
    @JsonProperty("fat_g")
    @JsonPropertyDescription("Total fat in grams")
    private Double fatG;
    /**
     * Saturated fat in grams
     * 
     */
    @JsonProperty("saturated_fat_g")
    @JsonPropertyDescription("Saturated fat in grams")
    private Double saturatedFatG;
    /**
     * Total carbohydrates in grams
     * 
     */
    @JsonProperty("carbohydrates_g")
    @JsonPropertyDescription("Total carbohydrates in grams")
    private Double carbohydratesG;
    /**
     * Dietary fiber in grams
     * 
     */
    @JsonProperty("fiber_g")
    @JsonPropertyDescription("Dietary fiber in grams")
    private Double fiberG;
    /**
     * Total sugars in grams
     * 
     */
    @JsonProperty("sugar_g")
    @JsonPropertyDescription("Total sugars in grams")
    private Double sugarG;
    /**
     * Sodium in milligrams
     * 
     */
    @JsonProperty("sodium_mg")
    @JsonPropertyDescription("Sodium in milligrams")
    private Double sodiumMg;
    /**
     * Cholesterol in milligrams
     * 
     */
    @JsonProperty("cholesterol_mg")
    @JsonPropertyDescription("Cholesterol in milligrams")
    private Double cholesterolMg;

    /**
     * No args constructor for use in serialization
     * 
     */
    public NutritionFields() {
    }

    /**
     * 
     * @param fatG
     *     Total fat in grams.
     * @param cholesterolMg
     *     Cholesterol in milligrams.
     * @param proteinG
     *     Protein in grams.
     * @param saturatedFatG
     *     Saturated fat in grams.
     * @param calories
     *     Total calories (kcal).
     * @param carbohydratesG
     *     Total carbohydrates in grams.
     * @param sodiumMg
     *     Sodium in milligrams.
     * @param fiberG
     *     Dietary fiber in grams.
     * @param sugarG
     *     Total sugars in grams.
     */
    public NutritionFields(Integer calories, Double proteinG, Double fatG, Double saturatedFatG, Double carbohydratesG, Double fiberG, Double sugarG, Double sodiumMg, Double cholesterolMg) {
        super();
        this.calories = calories;
        this.proteinG = proteinG;
        this.fatG = fatG;
        this.saturatedFatG = saturatedFatG;
        this.carbohydratesG = carbohydratesG;
        this.fiberG = fiberG;
        this.sugarG = sugarG;
        this.sodiumMg = sodiumMg;
        this.cholesterolMg = cholesterolMg;
    }

    /**
     * Total calories (kcal)
     * 
     */
    @JsonProperty("calories")
    public Integer getCalories() {
        return calories;
    }

    /**
     * Total calories (kcal)
     * 
     */
    @JsonProperty("calories")
    public void setCalories(Integer calories) {
        this.calories = calories;
    }

    public NutritionFields withCalories(Integer calories) {
        this.calories = calories;
        return this;
    }

    /**
     * Protein in grams
     * 
     */
    @JsonProperty("protein_g")
    public Double getProteinG() {
        return proteinG;
    }

    /**
     * Protein in grams
     * 
     */
    @JsonProperty("protein_g")
    public void setProteinG(Double proteinG) {
        this.proteinG = proteinG;
    }

    public NutritionFields withProteinG(Double proteinG) {
        this.proteinG = proteinG;
        return this;
    }

    /**
     * Total fat in grams
     * 
     */
    @JsonProperty("fat_g")
    public Double getFatG() {
        return fatG;
    }

    /**
     * Total fat in grams
     * 
     */
    @JsonProperty("fat_g")
    public void setFatG(Double fatG) {
        this.fatG = fatG;
    }

    public NutritionFields withFatG(Double fatG) {
        this.fatG = fatG;
        return this;
    }

    /**
     * Saturated fat in grams
     * 
     */
    @JsonProperty("saturated_fat_g")
    public Double getSaturatedFatG() {
        return saturatedFatG;
    }

    /**
     * Saturated fat in grams
     * 
     */
    @JsonProperty("saturated_fat_g")
    public void setSaturatedFatG(Double saturatedFatG) {
        this.saturatedFatG = saturatedFatG;
    }

    public NutritionFields withSaturatedFatG(Double saturatedFatG) {
        this.saturatedFatG = saturatedFatG;
        return this;
    }

    /**
     * Total carbohydrates in grams
     * 
     */
    @JsonProperty("carbohydrates_g")
    public Double getCarbohydratesG() {
        return carbohydratesG;
    }

    /**
     * Total carbohydrates in grams
     * 
     */
    @JsonProperty("carbohydrates_g")
    public void setCarbohydratesG(Double carbohydratesG) {
        this.carbohydratesG = carbohydratesG;
    }

    public NutritionFields withCarbohydratesG(Double carbohydratesG) {
        this.carbohydratesG = carbohydratesG;
        return this;
    }

    /**
     * Dietary fiber in grams
     * 
     */
    @JsonProperty("fiber_g")
    public Double getFiberG() {
        return fiberG;
    }

    /**
     * Dietary fiber in grams
     * 
     */
    @JsonProperty("fiber_g")
    public void setFiberG(Double fiberG) {
        this.fiberG = fiberG;
    }

    public NutritionFields withFiberG(Double fiberG) {
        this.fiberG = fiberG;
        return this;
    }

    /**
     * Total sugars in grams
     * 
     */
    @JsonProperty("sugar_g")
    public Double getSugarG() {
        return sugarG;
    }

    /**
     * Total sugars in grams
     * 
     */
    @JsonProperty("sugar_g")
    public void setSugarG(Double sugarG) {
        this.sugarG = sugarG;
    }

    public NutritionFields withSugarG(Double sugarG) {
        this.sugarG = sugarG;
        return this;
    }

    /**
     * Sodium in milligrams
     * 
     */
    @JsonProperty("sodium_mg")
    public Double getSodiumMg() {
        return sodiumMg;
    }

    /**
     * Sodium in milligrams
     * 
     */
    @JsonProperty("sodium_mg")
    public void setSodiumMg(Double sodiumMg) {
        this.sodiumMg = sodiumMg;
    }

    public NutritionFields withSodiumMg(Double sodiumMg) {
        this.sodiumMg = sodiumMg;
        return this;
    }

    /**
     * Cholesterol in milligrams
     * 
     */
    @JsonProperty("cholesterol_mg")
    public Double getCholesterolMg() {
        return cholesterolMg;
    }

    /**
     * Cholesterol in milligrams
     * 
     */
    @JsonProperty("cholesterol_mg")
    public void setCholesterolMg(Double cholesterolMg) {
        this.cholesterolMg = cholesterolMg;
    }

    public NutritionFields withCholesterolMg(Double cholesterolMg) {
        this.cholesterolMg = cholesterolMg;
        return this;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(NutritionFields.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("calories");
        sb.append('=');
        sb.append(((this.calories == null)?"<null>":this.calories));
        sb.append(',');
        sb.append("proteinG");
        sb.append('=');
        sb.append(((this.proteinG == null)?"<null>":this.proteinG));
        sb.append(',');
        sb.append("fatG");
        sb.append('=');
        sb.append(((this.fatG == null)?"<null>":this.fatG));
        sb.append(',');
        sb.append("saturatedFatG");
        sb.append('=');
        sb.append(((this.saturatedFatG == null)?"<null>":this.saturatedFatG));
        sb.append(',');
        sb.append("carbohydratesG");
        sb.append('=');
        sb.append(((this.carbohydratesG == null)?"<null>":this.carbohydratesG));
        sb.append(',');
        sb.append("fiberG");
        sb.append('=');
        sb.append(((this.fiberG == null)?"<null>":this.fiberG));
        sb.append(',');
        sb.append("sugarG");
        sb.append('=');
        sb.append(((this.sugarG == null)?"<null>":this.sugarG));
        sb.append(',');
        sb.append("sodiumMg");
        sb.append('=');
        sb.append(((this.sodiumMg == null)?"<null>":this.sodiumMg));
        sb.append(',');
        sb.append("cholesterolMg");
        sb.append('=');
        sb.append(((this.cholesterolMg == null)?"<null>":this.cholesterolMg));
        sb.append(',');
        if (sb.charAt((sb.length()- 1)) == ',') {
            sb.setCharAt((sb.length()- 1), ']');
        } else {
            sb.append(']');
        }
        return sb.toString();
    }

    @Override
    public int hashCode() {
        int result = 1;
        result = ((result* 31)+((this.fatG == null)? 0 :this.fatG.hashCode()));
        result = ((result* 31)+((this.cholesterolMg == null)? 0 :this.cholesterolMg.hashCode()));
        result = ((result* 31)+((this.proteinG == null)? 0 :this.proteinG.hashCode()));
        result = ((result* 31)+((this.saturatedFatG == null)? 0 :this.saturatedFatG.hashCode()));
        result = ((result* 31)+((this.calories == null)? 0 :this.calories.hashCode()));
        result = ((result* 31)+((this.carbohydratesG == null)? 0 :this.carbohydratesG.hashCode()));
        result = ((result* 31)+((this.sodiumMg == null)? 0 :this.sodiumMg.hashCode()));
        result = ((result* 31)+((this.fiberG == null)? 0 :this.fiberG.hashCode()));
        result = ((result* 31)+((this.sugarG == null)? 0 :this.sugarG.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof NutritionFields) == false) {
            return false;
        }
        NutritionFields rhs = ((NutritionFields) other);
        return ((((((((((this.fatG == rhs.fatG)||((this.fatG!= null)&&this.fatG.equals(rhs.fatG)))&&((this.cholesterolMg == rhs.cholesterolMg)||((this.cholesterolMg!= null)&&this.cholesterolMg.equals(rhs.cholesterolMg))))&&((this.proteinG == rhs.proteinG)||((this.proteinG!= null)&&this.proteinG.equals(rhs.proteinG))))&&((this.saturatedFatG == rhs.saturatedFatG)||((this.saturatedFatG!= null)&&this.saturatedFatG.equals(rhs.saturatedFatG))))&&((this.calories == rhs.calories)||((this.calories!= null)&&this.calories.equals(rhs.calories))))&&((this.carbohydratesG == rhs.carbohydratesG)||((this.carbohydratesG!= null)&&this.carbohydratesG.equals(rhs.carbohydratesG))))&&((this.sodiumMg == rhs.sodiumMg)||((this.sodiumMg!= null)&&this.sodiumMg.equals(rhs.sodiumMg))))&&((this.fiberG == rhs.fiberG)||((this.fiberG!= null)&&this.fiberG.equals(rhs.fiberG))))&&((this.sugarG == rhs.sugarG)||((this.sugarG!= null)&&this.sugarG.equals(rhs.sugarG))));
    }

}
