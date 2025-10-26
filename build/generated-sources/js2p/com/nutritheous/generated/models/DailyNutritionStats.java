
package com.nutritheous.generated.models;

import java.time.LocalDate;
import javax.annotation.processing.Generated;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * DailyNutritionStats
 * <p>
 * Daily nutrition statistics for a single day
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
    "date",
    "totalCalories",
    "totalProteinG",
    "totalFatG",
    "totalSaturatedFatG",
    "totalCarbohydratesG",
    "totalFiberG",
    "totalSugarG",
    "totalSodiumMg",
    "totalCholesterolMg",
    "mealCount"
})
@Generated("jsonschema2pojo")
public class DailyNutritionStats {

    /**
     * Date for these statistics (YYYY-MM-DD)
     * (Required)
     * 
     */
    @JsonProperty("date")
    @JsonPropertyDescription("Date for these statistics (YYYY-MM-DD)")
    private LocalDate date;
    /**
     * Total calories consumed this day
     * (Required)
     * 
     */
    @JsonProperty("totalCalories")
    @JsonPropertyDescription("Total calories consumed this day")
    private Integer totalCalories;
    /**
     * Total protein in grams
     * (Required)
     * 
     */
    @JsonProperty("totalProteinG")
    @JsonPropertyDescription("Total protein in grams")
    private Double totalProteinG;
    /**
     * Total fat in grams
     * (Required)
     * 
     */
    @JsonProperty("totalFatG")
    @JsonPropertyDescription("Total fat in grams")
    private Double totalFatG;
    /**
     * Total saturated fat in grams
     * 
     */
    @JsonProperty("totalSaturatedFatG")
    @JsonPropertyDescription("Total saturated fat in grams")
    private Double totalSaturatedFatG;
    /**
     * Total carbohydrates in grams
     * (Required)
     * 
     */
    @JsonProperty("totalCarbohydratesG")
    @JsonPropertyDescription("Total carbohydrates in grams")
    private Double totalCarbohydratesG;
    /**
     * Total dietary fiber in grams
     * 
     */
    @JsonProperty("totalFiberG")
    @JsonPropertyDescription("Total dietary fiber in grams")
    private Double totalFiberG;
    /**
     * Total sugars in grams
     * 
     */
    @JsonProperty("totalSugarG")
    @JsonPropertyDescription("Total sugars in grams")
    private Double totalSugarG;
    /**
     * Total sodium in milligrams
     * 
     */
    @JsonProperty("totalSodiumMg")
    @JsonPropertyDescription("Total sodium in milligrams")
    private Double totalSodiumMg;
    /**
     * Total cholesterol in milligrams
     * 
     */
    @JsonProperty("totalCholesterolMg")
    @JsonPropertyDescription("Total cholesterol in milligrams")
    private Double totalCholesterolMg;
    /**
     * Number of meals logged this day
     * (Required)
     * 
     */
    @JsonProperty("mealCount")
    @JsonPropertyDescription("Number of meals logged this day")
    private Integer mealCount;

    /**
     * No args constructor for use in serialization
     * 
     */
    public DailyNutritionStats() {
    }

    /**
     * 
     * @param date
     *     Date for these statistics (YYYY-MM-DD).
     * @param totalProteinG
     *     Total protein in grams.
     * @param totalFatG
     *     Total fat in grams.
     * @param totalCholesterolMg
     *     Total cholesterol in milligrams.
     * @param totalSugarG
     *     Total sugars in grams.
     * @param totalSodiumMg
     *     Total sodium in milligrams.
     * @param totalFiberG
     *     Total dietary fiber in grams.
     * @param totalSaturatedFatG
     *     Total saturated fat in grams.
     * @param mealCount
     *     Number of meals logged this day.
     * @param totalCalories
     *     Total calories consumed this day.
     * @param totalCarbohydratesG
     *     Total carbohydrates in grams.
     */
    public DailyNutritionStats(LocalDate date, Integer totalCalories, Double totalProteinG, Double totalFatG, Double totalSaturatedFatG, Double totalCarbohydratesG, Double totalFiberG, Double totalSugarG, Double totalSodiumMg, Double totalCholesterolMg, Integer mealCount) {
        super();
        this.date = date;
        this.totalCalories = totalCalories;
        this.totalProteinG = totalProteinG;
        this.totalFatG = totalFatG;
        this.totalSaturatedFatG = totalSaturatedFatG;
        this.totalCarbohydratesG = totalCarbohydratesG;
        this.totalFiberG = totalFiberG;
        this.totalSugarG = totalSugarG;
        this.totalSodiumMg = totalSodiumMg;
        this.totalCholesterolMg = totalCholesterolMg;
        this.mealCount = mealCount;
    }

    /**
     * Date for these statistics (YYYY-MM-DD)
     * (Required)
     * 
     */
    @JsonProperty("date")
    public LocalDate getDate() {
        return date;
    }

    /**
     * Date for these statistics (YYYY-MM-DD)
     * (Required)
     * 
     */
    @JsonProperty("date")
    public void setDate(LocalDate date) {
        this.date = date;
    }

    public DailyNutritionStats withDate(LocalDate date) {
        this.date = date;
        return this;
    }

    /**
     * Total calories consumed this day
     * (Required)
     * 
     */
    @JsonProperty("totalCalories")
    public Integer getTotalCalories() {
        return totalCalories;
    }

    /**
     * Total calories consumed this day
     * (Required)
     * 
     */
    @JsonProperty("totalCalories")
    public void setTotalCalories(Integer totalCalories) {
        this.totalCalories = totalCalories;
    }

    public DailyNutritionStats withTotalCalories(Integer totalCalories) {
        this.totalCalories = totalCalories;
        return this;
    }

    /**
     * Total protein in grams
     * (Required)
     * 
     */
    @JsonProperty("totalProteinG")
    public Double getTotalProteinG() {
        return totalProteinG;
    }

    /**
     * Total protein in grams
     * (Required)
     * 
     */
    @JsonProperty("totalProteinG")
    public void setTotalProteinG(Double totalProteinG) {
        this.totalProteinG = totalProteinG;
    }

    public DailyNutritionStats withTotalProteinG(Double totalProteinG) {
        this.totalProteinG = totalProteinG;
        return this;
    }

    /**
     * Total fat in grams
     * (Required)
     * 
     */
    @JsonProperty("totalFatG")
    public Double getTotalFatG() {
        return totalFatG;
    }

    /**
     * Total fat in grams
     * (Required)
     * 
     */
    @JsonProperty("totalFatG")
    public void setTotalFatG(Double totalFatG) {
        this.totalFatG = totalFatG;
    }

    public DailyNutritionStats withTotalFatG(Double totalFatG) {
        this.totalFatG = totalFatG;
        return this;
    }

    /**
     * Total saturated fat in grams
     * 
     */
    @JsonProperty("totalSaturatedFatG")
    public Double getTotalSaturatedFatG() {
        return totalSaturatedFatG;
    }

    /**
     * Total saturated fat in grams
     * 
     */
    @JsonProperty("totalSaturatedFatG")
    public void setTotalSaturatedFatG(Double totalSaturatedFatG) {
        this.totalSaturatedFatG = totalSaturatedFatG;
    }

    public DailyNutritionStats withTotalSaturatedFatG(Double totalSaturatedFatG) {
        this.totalSaturatedFatG = totalSaturatedFatG;
        return this;
    }

    /**
     * Total carbohydrates in grams
     * (Required)
     * 
     */
    @JsonProperty("totalCarbohydratesG")
    public Double getTotalCarbohydratesG() {
        return totalCarbohydratesG;
    }

    /**
     * Total carbohydrates in grams
     * (Required)
     * 
     */
    @JsonProperty("totalCarbohydratesG")
    public void setTotalCarbohydratesG(Double totalCarbohydratesG) {
        this.totalCarbohydratesG = totalCarbohydratesG;
    }

    public DailyNutritionStats withTotalCarbohydratesG(Double totalCarbohydratesG) {
        this.totalCarbohydratesG = totalCarbohydratesG;
        return this;
    }

    /**
     * Total dietary fiber in grams
     * 
     */
    @JsonProperty("totalFiberG")
    public Double getTotalFiberG() {
        return totalFiberG;
    }

    /**
     * Total dietary fiber in grams
     * 
     */
    @JsonProperty("totalFiberG")
    public void setTotalFiberG(Double totalFiberG) {
        this.totalFiberG = totalFiberG;
    }

    public DailyNutritionStats withTotalFiberG(Double totalFiberG) {
        this.totalFiberG = totalFiberG;
        return this;
    }

    /**
     * Total sugars in grams
     * 
     */
    @JsonProperty("totalSugarG")
    public Double getTotalSugarG() {
        return totalSugarG;
    }

    /**
     * Total sugars in grams
     * 
     */
    @JsonProperty("totalSugarG")
    public void setTotalSugarG(Double totalSugarG) {
        this.totalSugarG = totalSugarG;
    }

    public DailyNutritionStats withTotalSugarG(Double totalSugarG) {
        this.totalSugarG = totalSugarG;
        return this;
    }

    /**
     * Total sodium in milligrams
     * 
     */
    @JsonProperty("totalSodiumMg")
    public Double getTotalSodiumMg() {
        return totalSodiumMg;
    }

    /**
     * Total sodium in milligrams
     * 
     */
    @JsonProperty("totalSodiumMg")
    public void setTotalSodiumMg(Double totalSodiumMg) {
        this.totalSodiumMg = totalSodiumMg;
    }

    public DailyNutritionStats withTotalSodiumMg(Double totalSodiumMg) {
        this.totalSodiumMg = totalSodiumMg;
        return this;
    }

    /**
     * Total cholesterol in milligrams
     * 
     */
    @JsonProperty("totalCholesterolMg")
    public Double getTotalCholesterolMg() {
        return totalCholesterolMg;
    }

    /**
     * Total cholesterol in milligrams
     * 
     */
    @JsonProperty("totalCholesterolMg")
    public void setTotalCholesterolMg(Double totalCholesterolMg) {
        this.totalCholesterolMg = totalCholesterolMg;
    }

    public DailyNutritionStats withTotalCholesterolMg(Double totalCholesterolMg) {
        this.totalCholesterolMg = totalCholesterolMg;
        return this;
    }

    /**
     * Number of meals logged this day
     * (Required)
     * 
     */
    @JsonProperty("mealCount")
    public Integer getMealCount() {
        return mealCount;
    }

    /**
     * Number of meals logged this day
     * (Required)
     * 
     */
    @JsonProperty("mealCount")
    public void setMealCount(Integer mealCount) {
        this.mealCount = mealCount;
    }

    public DailyNutritionStats withMealCount(Integer mealCount) {
        this.mealCount = mealCount;
        return this;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(DailyNutritionStats.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("date");
        sb.append('=');
        sb.append(((this.date == null)?"<null>":this.date));
        sb.append(',');
        sb.append("totalCalories");
        sb.append('=');
        sb.append(((this.totalCalories == null)?"<null>":this.totalCalories));
        sb.append(',');
        sb.append("totalProteinG");
        sb.append('=');
        sb.append(((this.totalProteinG == null)?"<null>":this.totalProteinG));
        sb.append(',');
        sb.append("totalFatG");
        sb.append('=');
        sb.append(((this.totalFatG == null)?"<null>":this.totalFatG));
        sb.append(',');
        sb.append("totalSaturatedFatG");
        sb.append('=');
        sb.append(((this.totalSaturatedFatG == null)?"<null>":this.totalSaturatedFatG));
        sb.append(',');
        sb.append("totalCarbohydratesG");
        sb.append('=');
        sb.append(((this.totalCarbohydratesG == null)?"<null>":this.totalCarbohydratesG));
        sb.append(',');
        sb.append("totalFiberG");
        sb.append('=');
        sb.append(((this.totalFiberG == null)?"<null>":this.totalFiberG));
        sb.append(',');
        sb.append("totalSugarG");
        sb.append('=');
        sb.append(((this.totalSugarG == null)?"<null>":this.totalSugarG));
        sb.append(',');
        sb.append("totalSodiumMg");
        sb.append('=');
        sb.append(((this.totalSodiumMg == null)?"<null>":this.totalSodiumMg));
        sb.append(',');
        sb.append("totalCholesterolMg");
        sb.append('=');
        sb.append(((this.totalCholesterolMg == null)?"<null>":this.totalCholesterolMg));
        sb.append(',');
        sb.append("mealCount");
        sb.append('=');
        sb.append(((this.mealCount == null)?"<null>":this.mealCount));
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
        result = ((result* 31)+((this.date == null)? 0 :this.date.hashCode()));
        result = ((result* 31)+((this.totalProteinG == null)? 0 :this.totalProteinG.hashCode()));
        result = ((result* 31)+((this.totalFatG == null)? 0 :this.totalFatG.hashCode()));
        result = ((result* 31)+((this.totalCholesterolMg == null)? 0 :this.totalCholesterolMg.hashCode()));
        result = ((result* 31)+((this.totalSugarG == null)? 0 :this.totalSugarG.hashCode()));
        result = ((result* 31)+((this.totalSodiumMg == null)? 0 :this.totalSodiumMg.hashCode()));
        result = ((result* 31)+((this.totalFiberG == null)? 0 :this.totalFiberG.hashCode()));
        result = ((result* 31)+((this.totalSaturatedFatG == null)? 0 :this.totalSaturatedFatG.hashCode()));
        result = ((result* 31)+((this.mealCount == null)? 0 :this.mealCount.hashCode()));
        result = ((result* 31)+((this.totalCalories == null)? 0 :this.totalCalories.hashCode()));
        result = ((result* 31)+((this.totalCarbohydratesG == null)? 0 :this.totalCarbohydratesG.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof DailyNutritionStats) == false) {
            return false;
        }
        DailyNutritionStats rhs = ((DailyNutritionStats) other);
        return ((((((((((((this.date == rhs.date)||((this.date!= null)&&this.date.equals(rhs.date)))&&((this.totalProteinG == rhs.totalProteinG)||((this.totalProteinG!= null)&&this.totalProteinG.equals(rhs.totalProteinG))))&&((this.totalFatG == rhs.totalFatG)||((this.totalFatG!= null)&&this.totalFatG.equals(rhs.totalFatG))))&&((this.totalCholesterolMg == rhs.totalCholesterolMg)||((this.totalCholesterolMg!= null)&&this.totalCholesterolMg.equals(rhs.totalCholesterolMg))))&&((this.totalSugarG == rhs.totalSugarG)||((this.totalSugarG!= null)&&this.totalSugarG.equals(rhs.totalSugarG))))&&((this.totalSodiumMg == rhs.totalSodiumMg)||((this.totalSodiumMg!= null)&&this.totalSodiumMg.equals(rhs.totalSodiumMg))))&&((this.totalFiberG == rhs.totalFiberG)||((this.totalFiberG!= null)&&this.totalFiberG.equals(rhs.totalFiberG))))&&((this.totalSaturatedFatG == rhs.totalSaturatedFatG)||((this.totalSaturatedFatG!= null)&&this.totalSaturatedFatG.equals(rhs.totalSaturatedFatG))))&&((this.mealCount == rhs.mealCount)||((this.mealCount!= null)&&this.mealCount.equals(rhs.mealCount))))&&((this.totalCalories == rhs.totalCalories)||((this.totalCalories!= null)&&this.totalCalories.equals(rhs.totalCalories))))&&((this.totalCarbohydratesG == rhs.totalCarbohydratesG)||((this.totalCarbohydratesG!= null)&&this.totalCarbohydratesG.equals(rhs.totalCarbohydratesG))));
    }

}
