package com.nutritheous.statistics.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

/**
 * Combined statistics for multiple time periods
 * Returns stats for week, month, and 6 months in a single response
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PeriodicSummaryStats {
    private PeriodStats week;
    private PeriodStats month;
    private PeriodStats sixMonths;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class PeriodStats {
        private int totalMeals;
        private int totalDays;
        private int activeDays;
        private double avgCalories;
        private double totalCalories;
        private double avgProtein;
        private double avgCarbs;
        private double avgFat;
    }
}
