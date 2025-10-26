
package com.nutritheous.generated.models;

import java.util.ArrayList;
import java.util.List;
import javax.annotation.processing.Generated;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * NutritionSummary
 * <p>
 * Summary of nutrition statistics over a time period
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
    "totalMeals",
    "avgCaloriesPerDay",
    "avgProteinPerDay",
    "avgCarbsPerDay",
    "avgFatPerDay",
    "dailyStats",
    "mealTypeDistribution"
})
@Generated("jsonschema2pojo")
public class NutritionSummary {

    /**
     * Total number of meals in the period
     * (Required)
     * 
     */
    @JsonProperty("totalMeals")
    @JsonPropertyDescription("Total number of meals in the period")
    private Integer totalMeals;
    /**
     * Average calories consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgCaloriesPerDay")
    @JsonPropertyDescription("Average calories consumed per day")
    private Double avgCaloriesPerDay;
    /**
     * Average protein (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgProteinPerDay")
    @JsonPropertyDescription("Average protein (g) consumed per day")
    private Double avgProteinPerDay;
    /**
     * Average carbohydrates (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgCarbsPerDay")
    @JsonPropertyDescription("Average carbohydrates (g) consumed per day")
    private Double avgCarbsPerDay;
    /**
     * Average fat (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgFatPerDay")
    @JsonPropertyDescription("Average fat (g) consumed per day")
    private Double avgFatPerDay;
    /**
     * Daily breakdown of nutrition statistics
     * (Required)
     * 
     */
    @JsonProperty("dailyStats")
    @JsonPropertyDescription("Daily breakdown of nutrition statistics")
    private List<DailyNutritionStats> dailyStats = new ArrayList<DailyNutritionStats>();
    /**
     * Distribution of meals by type
     * (Required)
     * 
     */
    @JsonProperty("mealTypeDistribution")
    @JsonPropertyDescription("Distribution of meals by type")
    private List<MealTypeDistribution> mealTypeDistribution = new ArrayList<MealTypeDistribution>();

    /**
     * No args constructor for use in serialization
     * 
     */
    public NutritionSummary() {
    }

    /**
     * 
     * @param mealTypeDistribution
     *     Distribution of meals by type.
     * @param avgProteinPerDay
     *     Average protein (g) consumed per day.
     * @param avgCarbsPerDay
     *     Average carbohydrates (g) consumed per day.
     * @param avgCaloriesPerDay
     *     Average calories consumed per day.
     * @param dailyStats
     *     Daily breakdown of nutrition statistics.
     * @param totalMeals
     *     Total number of meals in the period.
     * @param avgFatPerDay
     *     Average fat (g) consumed per day.
     */
    public NutritionSummary(Integer totalMeals, Double avgCaloriesPerDay, Double avgProteinPerDay, Double avgCarbsPerDay, Double avgFatPerDay, List<DailyNutritionStats> dailyStats, List<MealTypeDistribution> mealTypeDistribution) {
        super();
        this.totalMeals = totalMeals;
        this.avgCaloriesPerDay = avgCaloriesPerDay;
        this.avgProteinPerDay = avgProteinPerDay;
        this.avgCarbsPerDay = avgCarbsPerDay;
        this.avgFatPerDay = avgFatPerDay;
        this.dailyStats = dailyStats;
        this.mealTypeDistribution = mealTypeDistribution;
    }

    /**
     * Total number of meals in the period
     * (Required)
     * 
     */
    @JsonProperty("totalMeals")
    public Integer getTotalMeals() {
        return totalMeals;
    }

    /**
     * Total number of meals in the period
     * (Required)
     * 
     */
    @JsonProperty("totalMeals")
    public void setTotalMeals(Integer totalMeals) {
        this.totalMeals = totalMeals;
    }

    public NutritionSummary withTotalMeals(Integer totalMeals) {
        this.totalMeals = totalMeals;
        return this;
    }

    /**
     * Average calories consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgCaloriesPerDay")
    public Double getAvgCaloriesPerDay() {
        return avgCaloriesPerDay;
    }

    /**
     * Average calories consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgCaloriesPerDay")
    public void setAvgCaloriesPerDay(Double avgCaloriesPerDay) {
        this.avgCaloriesPerDay = avgCaloriesPerDay;
    }

    public NutritionSummary withAvgCaloriesPerDay(Double avgCaloriesPerDay) {
        this.avgCaloriesPerDay = avgCaloriesPerDay;
        return this;
    }

    /**
     * Average protein (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgProteinPerDay")
    public Double getAvgProteinPerDay() {
        return avgProteinPerDay;
    }

    /**
     * Average protein (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgProteinPerDay")
    public void setAvgProteinPerDay(Double avgProteinPerDay) {
        this.avgProteinPerDay = avgProteinPerDay;
    }

    public NutritionSummary withAvgProteinPerDay(Double avgProteinPerDay) {
        this.avgProteinPerDay = avgProteinPerDay;
        return this;
    }

    /**
     * Average carbohydrates (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgCarbsPerDay")
    public Double getAvgCarbsPerDay() {
        return avgCarbsPerDay;
    }

    /**
     * Average carbohydrates (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgCarbsPerDay")
    public void setAvgCarbsPerDay(Double avgCarbsPerDay) {
        this.avgCarbsPerDay = avgCarbsPerDay;
    }

    public NutritionSummary withAvgCarbsPerDay(Double avgCarbsPerDay) {
        this.avgCarbsPerDay = avgCarbsPerDay;
        return this;
    }

    /**
     * Average fat (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgFatPerDay")
    public Double getAvgFatPerDay() {
        return avgFatPerDay;
    }

    /**
     * Average fat (g) consumed per day
     * (Required)
     * 
     */
    @JsonProperty("avgFatPerDay")
    public void setAvgFatPerDay(Double avgFatPerDay) {
        this.avgFatPerDay = avgFatPerDay;
    }

    public NutritionSummary withAvgFatPerDay(Double avgFatPerDay) {
        this.avgFatPerDay = avgFatPerDay;
        return this;
    }

    /**
     * Daily breakdown of nutrition statistics
     * (Required)
     * 
     */
    @JsonProperty("dailyStats")
    public List<DailyNutritionStats> getDailyStats() {
        return dailyStats;
    }

    /**
     * Daily breakdown of nutrition statistics
     * (Required)
     * 
     */
    @JsonProperty("dailyStats")
    public void setDailyStats(List<DailyNutritionStats> dailyStats) {
        this.dailyStats = dailyStats;
    }

    public NutritionSummary withDailyStats(List<DailyNutritionStats> dailyStats) {
        this.dailyStats = dailyStats;
        return this;
    }

    /**
     * Distribution of meals by type
     * (Required)
     * 
     */
    @JsonProperty("mealTypeDistribution")
    public List<MealTypeDistribution> getMealTypeDistribution() {
        return mealTypeDistribution;
    }

    /**
     * Distribution of meals by type
     * (Required)
     * 
     */
    @JsonProperty("mealTypeDistribution")
    public void setMealTypeDistribution(List<MealTypeDistribution> mealTypeDistribution) {
        this.mealTypeDistribution = mealTypeDistribution;
    }

    public NutritionSummary withMealTypeDistribution(List<MealTypeDistribution> mealTypeDistribution) {
        this.mealTypeDistribution = mealTypeDistribution;
        return this;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(NutritionSummary.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("totalMeals");
        sb.append('=');
        sb.append(((this.totalMeals == null)?"<null>":this.totalMeals));
        sb.append(',');
        sb.append("avgCaloriesPerDay");
        sb.append('=');
        sb.append(((this.avgCaloriesPerDay == null)?"<null>":this.avgCaloriesPerDay));
        sb.append(',');
        sb.append("avgProteinPerDay");
        sb.append('=');
        sb.append(((this.avgProteinPerDay == null)?"<null>":this.avgProteinPerDay));
        sb.append(',');
        sb.append("avgCarbsPerDay");
        sb.append('=');
        sb.append(((this.avgCarbsPerDay == null)?"<null>":this.avgCarbsPerDay));
        sb.append(',');
        sb.append("avgFatPerDay");
        sb.append('=');
        sb.append(((this.avgFatPerDay == null)?"<null>":this.avgFatPerDay));
        sb.append(',');
        sb.append("dailyStats");
        sb.append('=');
        sb.append(((this.dailyStats == null)?"<null>":this.dailyStats));
        sb.append(',');
        sb.append("mealTypeDistribution");
        sb.append('=');
        sb.append(((this.mealTypeDistribution == null)?"<null>":this.mealTypeDistribution));
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
        result = ((result* 31)+((this.mealTypeDistribution == null)? 0 :this.mealTypeDistribution.hashCode()));
        result = ((result* 31)+((this.avgProteinPerDay == null)? 0 :this.avgProteinPerDay.hashCode()));
        result = ((result* 31)+((this.avgCarbsPerDay == null)? 0 :this.avgCarbsPerDay.hashCode()));
        result = ((result* 31)+((this.avgCaloriesPerDay == null)? 0 :this.avgCaloriesPerDay.hashCode()));
        result = ((result* 31)+((this.dailyStats == null)? 0 :this.dailyStats.hashCode()));
        result = ((result* 31)+((this.totalMeals == null)? 0 :this.totalMeals.hashCode()));
        result = ((result* 31)+((this.avgFatPerDay == null)? 0 :this.avgFatPerDay.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof NutritionSummary) == false) {
            return false;
        }
        NutritionSummary rhs = ((NutritionSummary) other);
        return ((((((((this.mealTypeDistribution == rhs.mealTypeDistribution)||((this.mealTypeDistribution!= null)&&this.mealTypeDistribution.equals(rhs.mealTypeDistribution)))&&((this.avgProteinPerDay == rhs.avgProteinPerDay)||((this.avgProteinPerDay!= null)&&this.avgProteinPerDay.equals(rhs.avgProteinPerDay))))&&((this.avgCarbsPerDay == rhs.avgCarbsPerDay)||((this.avgCarbsPerDay!= null)&&this.avgCarbsPerDay.equals(rhs.avgCarbsPerDay))))&&((this.avgCaloriesPerDay == rhs.avgCaloriesPerDay)||((this.avgCaloriesPerDay!= null)&&this.avgCaloriesPerDay.equals(rhs.avgCaloriesPerDay))))&&((this.dailyStats == rhs.dailyStats)||((this.dailyStats!= null)&&this.dailyStats.equals(rhs.dailyStats))))&&((this.totalMeals == rhs.totalMeals)||((this.totalMeals!= null)&&this.totalMeals.equals(rhs.totalMeals))))&&((this.avgFatPerDay == rhs.avgFatPerDay)||((this.avgFatPerDay!= null)&&this.avgFatPerDay.equals(rhs.avgFatPerDay))));
    }

}
