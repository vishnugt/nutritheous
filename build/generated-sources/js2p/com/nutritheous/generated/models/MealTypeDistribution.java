
package com.nutritheous.generated.models;

import javax.annotation.processing.Generated;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * MealTypeDistribution
 * <p>
 * Distribution of meals by type (breakfast, lunch, dinner, snack)
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
    "mealType",
    "count",
    "percentage"
})
@Generated("jsonschema2pojo")
public class MealTypeDistribution {

    /**
     * Type of meal (BREAKFAST, LUNCH, DINNER, SNACK)
     * (Required)
     * 
     */
    @JsonProperty("mealType")
    @JsonPropertyDescription("Type of meal (BREAKFAST, LUNCH, DINNER, SNACK)")
    private String mealType;
    /**
     * Number of meals of this type
     * (Required)
     * 
     */
    @JsonProperty("count")
    @JsonPropertyDescription("Number of meals of this type")
    private Integer count;
    /**
     * Percentage of total meals
     * (Required)
     * 
     */
    @JsonProperty("percentage")
    @JsonPropertyDescription("Percentage of total meals")
    private Double percentage;

    /**
     * No args constructor for use in serialization
     * 
     */
    public MealTypeDistribution() {
    }

    /**
     * 
     * @param percentage
     *     Percentage of total meals.
     * @param mealType
     *     Type of meal (BREAKFAST, LUNCH, DINNER, SNACK).
     * @param count
     *     Number of meals of this type.
     */
    public MealTypeDistribution(String mealType, Integer count, Double percentage) {
        super();
        this.mealType = mealType;
        this.count = count;
        this.percentage = percentage;
    }

    /**
     * Type of meal (BREAKFAST, LUNCH, DINNER, SNACK)
     * (Required)
     * 
     */
    @JsonProperty("mealType")
    public String getMealType() {
        return mealType;
    }

    /**
     * Type of meal (BREAKFAST, LUNCH, DINNER, SNACK)
     * (Required)
     * 
     */
    @JsonProperty("mealType")
    public void setMealType(String mealType) {
        this.mealType = mealType;
    }

    public MealTypeDistribution withMealType(String mealType) {
        this.mealType = mealType;
        return this;
    }

    /**
     * Number of meals of this type
     * (Required)
     * 
     */
    @JsonProperty("count")
    public Integer getCount() {
        return count;
    }

    /**
     * Number of meals of this type
     * (Required)
     * 
     */
    @JsonProperty("count")
    public void setCount(Integer count) {
        this.count = count;
    }

    public MealTypeDistribution withCount(Integer count) {
        this.count = count;
        return this;
    }

    /**
     * Percentage of total meals
     * (Required)
     * 
     */
    @JsonProperty("percentage")
    public Double getPercentage() {
        return percentage;
    }

    /**
     * Percentage of total meals
     * (Required)
     * 
     */
    @JsonProperty("percentage")
    public void setPercentage(Double percentage) {
        this.percentage = percentage;
    }

    public MealTypeDistribution withPercentage(Double percentage) {
        this.percentage = percentage;
        return this;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(MealTypeDistribution.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("mealType");
        sb.append('=');
        sb.append(((this.mealType == null)?"<null>":this.mealType));
        sb.append(',');
        sb.append("count");
        sb.append('=');
        sb.append(((this.count == null)?"<null>":this.count));
        sb.append(',');
        sb.append("percentage");
        sb.append('=');
        sb.append(((this.percentage == null)?"<null>":this.percentage));
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
        result = ((result* 31)+((this.mealType == null)? 0 :this.mealType.hashCode()));
        result = ((result* 31)+((this.count == null)? 0 :this.count.hashCode()));
        result = ((result* 31)+((this.percentage == null)? 0 :this.percentage.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof MealTypeDistribution) == false) {
            return false;
        }
        MealTypeDistribution rhs = ((MealTypeDistribution) other);
        return ((((this.mealType == rhs.mealType)||((this.mealType!= null)&&this.mealType.equals(rhs.mealType)))&&((this.count == rhs.count)||((this.count!= null)&&this.count.equals(rhs.count))))&&((this.percentage == rhs.percentage)||((this.percentage!= null)&&this.percentage.equals(rhs.percentage))));
    }

}
