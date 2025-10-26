
package com.nutritheous.generated.models;

import java.net.URI;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import javax.annotation.processing.Generated;
import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyDescription;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.annotation.JsonValue;


/**
 * Meal
 * <p>
 * A meal entry with nutritional analysis
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@JsonPropertyOrder({
    "id",
    "mealTime",
    "mealType",
    "imageUrl",
    "description",
    "serving_size",
    "analysisJson",
    "calories",
    "protein_g",
    "fat_g",
    "saturated_fat_g",
    "carbohydrates_g",
    "fiber_g",
    "sugar_g",
    "sodium_mg",
    "cholesterol_mg",
    "ingredients",
    "allergens",
    "health_notes",
    "confidence",
    "analysisStatus",
    "createdAt"
})
@Generated("jsonschema2pojo")
public class Meal {

    /**
     * Unique identifier for the meal
     * (Required)
     * 
     */
    @JsonProperty("id")
    @JsonPropertyDescription("Unique identifier for the meal")
    private UUID id;
    /**
     * Timestamp when the meal was consumed (ISO 8601)
     * (Required)
     * 
     */
    @JsonProperty("mealTime")
    @JsonPropertyDescription("Timestamp when the meal was consumed (ISO 8601)")
    private LocalDateTime mealTime;
    /**
     * MealType
     * <p>
     * Type/category of meal
     * (Required)
     * 
     */
    @JsonProperty("mealType")
    @JsonPropertyDescription("Type/category of meal")
    private Meal.MealType mealType = Meal.MealType.fromValue("SNACK");
    /**
     * URL to the meal image in storage
     * (Required)
     * 
     */
    @JsonProperty("imageUrl")
    @JsonPropertyDescription("URL to the meal image in storage")
    private URI imageUrl;
    /**
     * AI-generated description of the food
     * 
     */
    @JsonProperty("description")
    @JsonPropertyDescription("AI-generated description of the food")
    private String description;
    /**
     * Estimated serving size (e.g., '1 plate', '2 slices', '300g')
     * 
     */
    @JsonProperty("serving_size")
    @JsonPropertyDescription("Estimated serving size (e.g., '1 plate', '2 slices', '300g')")
    private String servingSize;
    /**
     * Full JSON response from AI analysis (for debugging/backup)
     * 
     */
    @JsonProperty("analysisJson")
    @JsonPropertyDescription("Full JSON response from AI analysis (for debugging/backup)")
    private AnalysisJson analysisJson;
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
     * List of identified ingredients
     * 
     */
    @JsonProperty("ingredients")
    @JsonPropertyDescription("List of identified ingredients")
    private List<String> ingredients = new ArrayList<String>();
    /**
     * List of potential allergens (dairy, nuts, gluten, etc.)
     * 
     */
    @JsonProperty("allergens")
    @JsonPropertyDescription("List of potential allergens (dairy, nuts, gluten, etc.)")
    private List<String> allergens = new ArrayList<String>();
    /**
     * Brief health insights (high protein, low carb, etc.)
     * 
     */
    @JsonProperty("health_notes")
    @JsonPropertyDescription("Brief health insights (high protein, low carb, etc.)")
    private String healthNotes;
    /**
     * AI confidence score (0.0-1.0) based on image clarity and food recognition
     * 
     */
    @JsonProperty("confidence")
    @JsonPropertyDescription("AI confidence score (0.0-1.0) based on image clarity and food recognition")
    private Double confidence;
    /**
     * AnalysisStatus
     * <p>
     * Status of AI nutritional analysis for a meal
     * (Required)
     * 
     */
    @JsonProperty("analysisStatus")
    @JsonPropertyDescription("Status of AI nutritional analysis for a meal")
    private Meal.AnalysisStatus analysisStatus = Meal.AnalysisStatus.fromValue("PENDING");
    /**
     * Timestamp when the meal was created (ISO 8601)
     * 
     */
    @JsonProperty("createdAt")
    @JsonPropertyDescription("Timestamp when the meal was created (ISO 8601)")
    private LocalDateTime createdAt;

    /**
     * No args constructor for use in serialization
     * 
     */
    public Meal() {
    }

    /**
     * 
     * @param fatG
     *     Total fat in grams.
     * @param cholesterolMg
     *     Cholesterol in milligrams.
     * @param analysisJson
     *     Full JSON response from AI analysis (for debugging/backup).
     * @param proteinG
     *     Protein in grams.
     * @param mealTime
     *     Timestamp when the meal was consumed (ISO 8601).
     * @param confidence
     *     AI confidence score (0.0-1.0) based on image clarity and food recognition.
     * @param mealType
     *     Type/category of the meal.
     * @param description
     *     AI-generated description of the food.
     * @param calories
     *     Total calories (kcal).
     * @param carbohydratesG
     *     Total carbohydrates in grams.
     * @param sodiumMg
     *     Sodium in milligrams.
     * @param sugarG
     *     Total sugars in grams.
     * @param allergens
     *     List of potential allergens (dairy, nuts, gluten, etc.).
     * @param createdAt
     *     Timestamp when the meal was created (ISO 8601).
     * @param saturatedFatG
     *     Saturated fat in grams.
     * @param imageUrl
     *     URL to the meal image in storage.
     * @param ingredients
     *     List of identified ingredients.
     * @param id
     *     Unique identifier for the meal.
     * @param healthNotes
     *     Brief health insights (high protein, low carb, etc.).
     * @param servingSize
     *     Estimated serving size (e.g., '1 plate', '2 slices', '300g').
     * @param analysisStatus
     *     Status of the AI analysis.
     * @param fiberG
     *     Dietary fiber in grams.
     */
    public Meal(UUID id, LocalDateTime mealTime, Meal.MealType mealType, URI imageUrl, String description, String servingSize, AnalysisJson analysisJson, Integer calories, Double proteinG, Double fatG, Double saturatedFatG, Double carbohydratesG, Double fiberG, Double sugarG, Double sodiumMg, Double cholesterolMg, List<String> ingredients, List<String> allergens, String healthNotes, Double confidence, Meal.AnalysisStatus analysisStatus, LocalDateTime createdAt) {
        super();
        this.id = id;
        this.mealTime = mealTime;
        this.mealType = mealType;
        this.imageUrl = imageUrl;
        this.description = description;
        this.servingSize = servingSize;
        this.analysisJson = analysisJson;
        this.calories = calories;
        this.proteinG = proteinG;
        this.fatG = fatG;
        this.saturatedFatG = saturatedFatG;
        this.carbohydratesG = carbohydratesG;
        this.fiberG = fiberG;
        this.sugarG = sugarG;
        this.sodiumMg = sodiumMg;
        this.cholesterolMg = cholesterolMg;
        this.ingredients = ingredients;
        this.allergens = allergens;
        this.healthNotes = healthNotes;
        this.confidence = confidence;
        this.analysisStatus = analysisStatus;
        this.createdAt = createdAt;
    }

    /**
     * Unique identifier for the meal
     * (Required)
     * 
     */
    @JsonProperty("id")
    public UUID getId() {
        return id;
    }

    /**
     * Unique identifier for the meal
     * (Required)
     * 
     */
    @JsonProperty("id")
    public void setId(UUID id) {
        this.id = id;
    }

    public Meal withId(UUID id) {
        this.id = id;
        return this;
    }

    /**
     * Timestamp when the meal was consumed (ISO 8601)
     * (Required)
     * 
     */
    @JsonProperty("mealTime")
    public LocalDateTime getMealTime() {
        return mealTime;
    }

    /**
     * Timestamp when the meal was consumed (ISO 8601)
     * (Required)
     * 
     */
    @JsonProperty("mealTime")
    public void setMealTime(LocalDateTime mealTime) {
        this.mealTime = mealTime;
    }

    public Meal withMealTime(LocalDateTime mealTime) {
        this.mealTime = mealTime;
        return this;
    }

    /**
     * MealType
     * <p>
     * Type/category of meal
     * (Required)
     * 
     */
    @JsonProperty("mealType")
    public Meal.MealType getMealType() {
        return mealType;
    }

    /**
     * MealType
     * <p>
     * Type/category of meal
     * (Required)
     * 
     */
    @JsonProperty("mealType")
    public void setMealType(Meal.MealType mealType) {
        this.mealType = mealType;
    }

    public Meal withMealType(Meal.MealType mealType) {
        this.mealType = mealType;
        return this;
    }

    /**
     * URL to the meal image in storage
     * (Required)
     * 
     */
    @JsonProperty("imageUrl")
    public URI getImageUrl() {
        return imageUrl;
    }

    /**
     * URL to the meal image in storage
     * (Required)
     * 
     */
    @JsonProperty("imageUrl")
    public void setImageUrl(URI imageUrl) {
        this.imageUrl = imageUrl;
    }

    public Meal withImageUrl(URI imageUrl) {
        this.imageUrl = imageUrl;
        return this;
    }

    /**
     * AI-generated description of the food
     * 
     */
    @JsonProperty("description")
    public String getDescription() {
        return description;
    }

    /**
     * AI-generated description of the food
     * 
     */
    @JsonProperty("description")
    public void setDescription(String description) {
        this.description = description;
    }

    public Meal withDescription(String description) {
        this.description = description;
        return this;
    }

    /**
     * Estimated serving size (e.g., '1 plate', '2 slices', '300g')
     * 
     */
    @JsonProperty("serving_size")
    public String getServingSize() {
        return servingSize;
    }

    /**
     * Estimated serving size (e.g., '1 plate', '2 slices', '300g')
     * 
     */
    @JsonProperty("serving_size")
    public void setServingSize(String servingSize) {
        this.servingSize = servingSize;
    }

    public Meal withServingSize(String servingSize) {
        this.servingSize = servingSize;
        return this;
    }

    /**
     * Full JSON response from AI analysis (for debugging/backup)
     * 
     */
    @JsonProperty("analysisJson")
    public AnalysisJson getAnalysisJson() {
        return analysisJson;
    }

    /**
     * Full JSON response from AI analysis (for debugging/backup)
     * 
     */
    @JsonProperty("analysisJson")
    public void setAnalysisJson(AnalysisJson analysisJson) {
        this.analysisJson = analysisJson;
    }

    public Meal withAnalysisJson(AnalysisJson analysisJson) {
        this.analysisJson = analysisJson;
        return this;
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

    public Meal withCalories(Integer calories) {
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

    public Meal withProteinG(Double proteinG) {
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

    public Meal withFatG(Double fatG) {
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

    public Meal withSaturatedFatG(Double saturatedFatG) {
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

    public Meal withCarbohydratesG(Double carbohydratesG) {
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

    public Meal withFiberG(Double fiberG) {
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

    public Meal withSugarG(Double sugarG) {
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

    public Meal withSodiumMg(Double sodiumMg) {
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

    public Meal withCholesterolMg(Double cholesterolMg) {
        this.cholesterolMg = cholesterolMg;
        return this;
    }

    /**
     * List of identified ingredients
     * 
     */
    @JsonProperty("ingredients")
    public List<String> getIngredients() {
        return ingredients;
    }

    /**
     * List of identified ingredients
     * 
     */
    @JsonProperty("ingredients")
    public void setIngredients(List<String> ingredients) {
        this.ingredients = ingredients;
    }

    public Meal withIngredients(List<String> ingredients) {
        this.ingredients = ingredients;
        return this;
    }

    /**
     * List of potential allergens (dairy, nuts, gluten, etc.)
     * 
     */
    @JsonProperty("allergens")
    public List<String> getAllergens() {
        return allergens;
    }

    /**
     * List of potential allergens (dairy, nuts, gluten, etc.)
     * 
     */
    @JsonProperty("allergens")
    public void setAllergens(List<String> allergens) {
        this.allergens = allergens;
    }

    public Meal withAllergens(List<String> allergens) {
        this.allergens = allergens;
        return this;
    }

    /**
     * Brief health insights (high protein, low carb, etc.)
     * 
     */
    @JsonProperty("health_notes")
    public String getHealthNotes() {
        return healthNotes;
    }

    /**
     * Brief health insights (high protein, low carb, etc.)
     * 
     */
    @JsonProperty("health_notes")
    public void setHealthNotes(String healthNotes) {
        this.healthNotes = healthNotes;
    }

    public Meal withHealthNotes(String healthNotes) {
        this.healthNotes = healthNotes;
        return this;
    }

    /**
     * AI confidence score (0.0-1.0) based on image clarity and food recognition
     * 
     */
    @JsonProperty("confidence")
    public Double getConfidence() {
        return confidence;
    }

    /**
     * AI confidence score (0.0-1.0) based on image clarity and food recognition
     * 
     */
    @JsonProperty("confidence")
    public void setConfidence(Double confidence) {
        this.confidence = confidence;
    }

    public Meal withConfidence(Double confidence) {
        this.confidence = confidence;
        return this;
    }

    /**
     * AnalysisStatus
     * <p>
     * Status of AI nutritional analysis for a meal
     * (Required)
     * 
     */
    @JsonProperty("analysisStatus")
    public Meal.AnalysisStatus getAnalysisStatus() {
        return analysisStatus;
    }

    /**
     * AnalysisStatus
     * <p>
     * Status of AI nutritional analysis for a meal
     * (Required)
     * 
     */
    @JsonProperty("analysisStatus")
    public void setAnalysisStatus(Meal.AnalysisStatus analysisStatus) {
        this.analysisStatus = analysisStatus;
    }

    public Meal withAnalysisStatus(Meal.AnalysisStatus analysisStatus) {
        this.analysisStatus = analysisStatus;
        return this;
    }

    /**
     * Timestamp when the meal was created (ISO 8601)
     * 
     */
    @JsonProperty("createdAt")
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    /**
     * Timestamp when the meal was created (ISO 8601)
     * 
     */
    @JsonProperty("createdAt")
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public Meal withCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
        return this;
    }

    @Override
    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(Meal.class.getName()).append('@').append(Integer.toHexString(System.identityHashCode(this))).append('[');
        sb.append("id");
        sb.append('=');
        sb.append(((this.id == null)?"<null>":this.id));
        sb.append(',');
        sb.append("mealTime");
        sb.append('=');
        sb.append(((this.mealTime == null)?"<null>":this.mealTime));
        sb.append(',');
        sb.append("mealType");
        sb.append('=');
        sb.append(((this.mealType == null)?"<null>":this.mealType));
        sb.append(',');
        sb.append("imageUrl");
        sb.append('=');
        sb.append(((this.imageUrl == null)?"<null>":this.imageUrl));
        sb.append(',');
        sb.append("description");
        sb.append('=');
        sb.append(((this.description == null)?"<null>":this.description));
        sb.append(',');
        sb.append("servingSize");
        sb.append('=');
        sb.append(((this.servingSize == null)?"<null>":this.servingSize));
        sb.append(',');
        sb.append("analysisJson");
        sb.append('=');
        sb.append(((this.analysisJson == null)?"<null>":this.analysisJson));
        sb.append(',');
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
        sb.append("ingredients");
        sb.append('=');
        sb.append(((this.ingredients == null)?"<null>":this.ingredients));
        sb.append(',');
        sb.append("allergens");
        sb.append('=');
        sb.append(((this.allergens == null)?"<null>":this.allergens));
        sb.append(',');
        sb.append("healthNotes");
        sb.append('=');
        sb.append(((this.healthNotes == null)?"<null>":this.healthNotes));
        sb.append(',');
        sb.append("confidence");
        sb.append('=');
        sb.append(((this.confidence == null)?"<null>":this.confidence));
        sb.append(',');
        sb.append("analysisStatus");
        sb.append('=');
        sb.append(((this.analysisStatus == null)?"<null>":this.analysisStatus));
        sb.append(',');
        sb.append("createdAt");
        sb.append('=');
        sb.append(((this.createdAt == null)?"<null>":this.createdAt));
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
        result = ((result* 31)+((this.analysisJson == null)? 0 :this.analysisJson.hashCode()));
        result = ((result* 31)+((this.proteinG == null)? 0 :this.proteinG.hashCode()));
        result = ((result* 31)+((this.mealTime == null)? 0 :this.mealTime.hashCode()));
        result = ((result* 31)+((this.confidence == null)? 0 :this.confidence.hashCode()));
        result = ((result* 31)+((this.mealType == null)? 0 :this.mealType.hashCode()));
        result = ((result* 31)+((this.description == null)? 0 :this.description.hashCode()));
        result = ((result* 31)+((this.calories == null)? 0 :this.calories.hashCode()));
        result = ((result* 31)+((this.carbohydratesG == null)? 0 :this.carbohydratesG.hashCode()));
        result = ((result* 31)+((this.sodiumMg == null)? 0 :this.sodiumMg.hashCode()));
        result = ((result* 31)+((this.sugarG == null)? 0 :this.sugarG.hashCode()));
        result = ((result* 31)+((this.allergens == null)? 0 :this.allergens.hashCode()));
        result = ((result* 31)+((this.createdAt == null)? 0 :this.createdAt.hashCode()));
        result = ((result* 31)+((this.saturatedFatG == null)? 0 :this.saturatedFatG.hashCode()));
        result = ((result* 31)+((this.imageUrl == null)? 0 :this.imageUrl.hashCode()));
        result = ((result* 31)+((this.ingredients == null)? 0 :this.ingredients.hashCode()));
        result = ((result* 31)+((this.id == null)? 0 :this.id.hashCode()));
        result = ((result* 31)+((this.healthNotes == null)? 0 :this.healthNotes.hashCode()));
        result = ((result* 31)+((this.servingSize == null)? 0 :this.servingSize.hashCode()));
        result = ((result* 31)+((this.analysisStatus == null)? 0 :this.analysisStatus.hashCode()));
        result = ((result* 31)+((this.fiberG == null)? 0 :this.fiberG.hashCode()));
        return result;
    }

    @Override
    public boolean equals(Object other) {
        if (other == this) {
            return true;
        }
        if ((other instanceof Meal) == false) {
            return false;
        }
        Meal rhs = ((Meal) other);
        return (((((((((((((((((((((((this.fatG == rhs.fatG)||((this.fatG!= null)&&this.fatG.equals(rhs.fatG)))&&((this.cholesterolMg == rhs.cholesterolMg)||((this.cholesterolMg!= null)&&this.cholesterolMg.equals(rhs.cholesterolMg))))&&((this.analysisJson == rhs.analysisJson)||((this.analysisJson!= null)&&this.analysisJson.equals(rhs.analysisJson))))&&((this.proteinG == rhs.proteinG)||((this.proteinG!= null)&&this.proteinG.equals(rhs.proteinG))))&&((this.mealTime == rhs.mealTime)||((this.mealTime!= null)&&this.mealTime.equals(rhs.mealTime))))&&((this.confidence == rhs.confidence)||((this.confidence!= null)&&this.confidence.equals(rhs.confidence))))&&((this.mealType == rhs.mealType)||((this.mealType!= null)&&this.mealType.equals(rhs.mealType))))&&((this.description == rhs.description)||((this.description!= null)&&this.description.equals(rhs.description))))&&((this.calories == rhs.calories)||((this.calories!= null)&&this.calories.equals(rhs.calories))))&&((this.carbohydratesG == rhs.carbohydratesG)||((this.carbohydratesG!= null)&&this.carbohydratesG.equals(rhs.carbohydratesG))))&&((this.sodiumMg == rhs.sodiumMg)||((this.sodiumMg!= null)&&this.sodiumMg.equals(rhs.sodiumMg))))&&((this.sugarG == rhs.sugarG)||((this.sugarG!= null)&&this.sugarG.equals(rhs.sugarG))))&&((this.allergens == rhs.allergens)||((this.allergens!= null)&&this.allergens.equals(rhs.allergens))))&&((this.createdAt == rhs.createdAt)||((this.createdAt!= null)&&this.createdAt.equals(rhs.createdAt))))&&((this.saturatedFatG == rhs.saturatedFatG)||((this.saturatedFatG!= null)&&this.saturatedFatG.equals(rhs.saturatedFatG))))&&((this.imageUrl == rhs.imageUrl)||((this.imageUrl!= null)&&this.imageUrl.equals(rhs.imageUrl))))&&((this.ingredients == rhs.ingredients)||((this.ingredients!= null)&&this.ingredients.equals(rhs.ingredients))))&&((this.id == rhs.id)||((this.id!= null)&&this.id.equals(rhs.id))))&&((this.healthNotes == rhs.healthNotes)||((this.healthNotes!= null)&&this.healthNotes.equals(rhs.healthNotes))))&&((this.servingSize == rhs.servingSize)||((this.servingSize!= null)&&this.servingSize.equals(rhs.servingSize))))&&((this.analysisStatus == rhs.analysisStatus)||((this.analysisStatus!= null)&&this.analysisStatus.equals(rhs.analysisStatus))))&&((this.fiberG == rhs.fiberG)||((this.fiberG!= null)&&this.fiberG.equals(rhs.fiberG))));
    }


    /**
     * AnalysisStatus
     * <p>
     * Status of AI nutritional analysis for a meal
     * 
     */
    @Generated("jsonschema2pojo")
    public enum AnalysisStatus {

        PENDING("PENDING"),
        COMPLETED("COMPLETED"),
        FAILED("FAILED");
        private final String value;
        private final static Map<String, Meal.AnalysisStatus> CONSTANTS = new HashMap<String, Meal.AnalysisStatus>();

        static {
            for (Meal.AnalysisStatus c: values()) {
                CONSTANTS.put(c.value, c);
            }
        }

        AnalysisStatus(String value) {
            this.value = value;
        }

        @Override
        public String toString() {
            return this.value;
        }

        @JsonValue
        public String value() {
            return this.value;
        }

        @JsonCreator
        public static Meal.AnalysisStatus fromValue(String value) {
            Meal.AnalysisStatus constant = CONSTANTS.get(value);
            if (constant == null) {
                throw new IllegalArgumentException(value);
            } else {
                return constant;
            }
        }

    }


    /**
     * MealType
     * <p>
     * Type/category of meal
     * 
     */
    @Generated("jsonschema2pojo")
    public enum MealType {

        BREAKFAST("BREAKFAST"),
        LUNCH("LUNCH"),
        DINNER("DINNER"),
        SNACK("SNACK");
        private final String value;
        private final static Map<String, Meal.MealType> CONSTANTS = new HashMap<String, Meal.MealType>();

        static {
            for (Meal.MealType c: values()) {
                CONSTANTS.put(c.value, c);
            }
        }

        MealType(String value) {
            this.value = value;
        }

        @Override
        public String toString() {
            return this.value;
        }

        @JsonValue
        public String value() {
            return this.value;
        }

        @JsonCreator
        public static Meal.MealType fromValue(String value) {
            Meal.MealType constant = CONSTANTS.get(value);
            if (constant == null) {
                throw new IllegalArgumentException(value);
            } else {
                return constant;
            }
        }

    }

}
