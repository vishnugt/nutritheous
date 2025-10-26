package com.nutritheous.auth;

import lombok.Getter;

/**
 * Activity level for TDEE (Total Daily Energy Expenditure) calculation.
 * Each level has a multiplier applied to BMR.
 */
@Getter
public enum ActivityLevel {
    SEDENTARY(1.2, "Little or no exercise"),
    LIGHTLY_ACTIVE(1.375, "Light exercise 1-3 days/week"),
    MODERATELY_ACTIVE(1.55, "Moderate exercise 3-5 days/week"),
    VERY_ACTIVE(1.725, "Hard exercise 6-7 days/week"),
    EXTREMELY_ACTIVE(1.9, "Very hard exercise and physical job");

    private final double multiplier;
    private final String description;

    ActivityLevel(double multiplier, String description) {
        this.multiplier = multiplier;
        this.description = description;
    }
}
