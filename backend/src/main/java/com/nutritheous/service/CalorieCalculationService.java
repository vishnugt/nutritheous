package com.nutritheous.service;

import com.nutritheous.auth.ActivityLevel;
import com.nutritheous.auth.Sex;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * Service for calculating calorie requirements based on user profile.
 * Uses the Mifflin-St Jeor equation for BMR and activity multipliers for TDEE.
 */
@Service
@Slf4j
public class CalorieCalculationService {

    /**
     * Calculates Basal Metabolic Rate (BMR) using the Mifflin-St Jeor equation.
     * This is the most accurate modern formula for BMR calculation.
     *
     * For men: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) + 5
     * For women: BMR = 10 × weight(kg) + 6.25 × height(cm) - 5 × age(years) - 161
     * For other: BMR = average of male and female calculations
     *
     * @param weightKg Weight in kilograms
     * @param heightCm Height in centimeters
     * @param age Age in years
     * @param sex Sex (MALE, FEMALE, or OTHER)
     * @return BMR in calories per day
     */
    public int calculateBMR(double weightKg, double heightCm, int age, Sex sex) {
        double baseBmr = (10 * weightKg) + (6.25 * heightCm) - (5 * age);
        double bmr;

        if (sex == Sex.MALE) {
            bmr = baseBmr + 5;
        } else if (sex == Sex.FEMALE) {
            bmr = baseBmr - 161;
        } else { // Sex.OTHER
            // Calculate average of male and female BMR
            double maleBmr = baseBmr + 5;
            double femaleBmr = baseBmr - 161;
            bmr = (maleBmr + femaleBmr) / 2.0;
        }

        log.debug("Calculated BMR: {} for weight={}kg, height={}cm, age={}, sex={}",
                  (int) Math.round(bmr), weightKg, heightCm, age, sex);

        return (int) Math.round(bmr);
    }

    /**
     * Calculates Total Daily Energy Expenditure (TDEE) by applying
     * activity level multiplier to BMR.
     *
     * @param bmr Basal Metabolic Rate
     * @param activityLevel Activity level
     * @return TDEE in calories per day
     */
    public int calculateTDEE(int bmr, ActivityLevel activityLevel) {
        double tdee = bmr * activityLevel.getMultiplier();

        log.debug("Calculated TDEE: {} (BMR: {}, Activity: {})",
                  (int) Math.round(tdee), bmr, activityLevel);

        return (int) Math.round(tdee);
    }

    /**
     * Calculates estimated daily calories burnt (TDEE) from user profile data.
     *
     * @param weightKg Weight in kilograms
     * @param heightCm Height in centimeters
     * @param age Age in years
     * @param sex Biological sex
     * @param activityLevel Activity level
     * @return Estimated daily calorie burn (TDEE)
     * @throws IllegalArgumentException if any required field is null
     */
    public int calculateEstimatedDailyCalories(Double weightKg, Double heightCm,
                                               Integer age, Sex sex,
                                               ActivityLevel activityLevel) {
        if (weightKg == null || heightCm == null || age == null ||
            sex == null || activityLevel == null) {
            throw new IllegalArgumentException(
                "All profile fields (weight, height, age, sex, activity level) " +
                "must be provided to calculate daily calories"
            );
        }

        int bmr = calculateBMR(weightKg, heightCm, age, sex);
        int tdee = calculateTDEE(bmr, activityLevel);

        log.info("Calculated estimated daily calories: {} for user profile " +
                 "(weight={}kg, height={}cm, age={}, sex={}, activity={})",
                 tdee, weightKg, heightCm, age, sex, activityLevel);

        return tdee;
    }

    /**
     * Validates if profile is complete enough for calorie calculation.
     *
     * @param weightKg Weight in kilograms
     * @param heightCm Height in centimeters
     * @param age Age in years
     * @param sex Biological sex
     * @param activityLevel Activity level
     * @return true if all required fields are present
     */
    public boolean canCalculateCalories(Double weightKg, Double heightCm,
                                       Integer age, Sex sex,
                                       ActivityLevel activityLevel) {
        return weightKg != null && heightCm != null && age != null &&
               sex != null && activityLevel != null;
    }
}
