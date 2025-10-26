package com.nutritheous.statistics;

import com.nutritheous.meal.Meal;
import com.nutritheous.meal.MealRepository;
import com.nutritheous.statistics.dto.DailyNutritionStats;
import com.nutritheous.statistics.dto.MealTypeDistribution;
import com.nutritheous.statistics.dto.NutritionSummary;
import com.nutritheous.statistics.dto.PeriodicSummaryStats;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StatisticsService {

    private final MealRepository mealRepository;

    public List<DailyNutritionStats> getDailyNutritionStats(UUID userId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Meal> meals = mealRepository.findByUserIdAndMealTimeBetweenOrderByMealTimeDesc(userId, startDate, endDate);

        // Group meals by date
        Map<LocalDate, List<Meal>> mealsByDate = meals.stream()
                .collect(Collectors.groupingBy(meal -> meal.getMealTime().toLocalDate()));

        // Calculate stats for each day
        return mealsByDate.entrySet().stream()
                .map(entry -> calculateDailyStats(entry.getKey(), entry.getValue()))
                .sorted(Comparator.comparing(DailyNutritionStats::getDate))
                .collect(Collectors.toList());
    }

    public NutritionSummary getNutritionSummary(UUID userId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Meal> meals = mealRepository.findByUserIdAndMealTimeBetweenOrderByMealTimeDesc(userId, startDate, endDate);

        if (meals.isEmpty()) {
            return NutritionSummary.builder()
                    .totalMeals(0L)
                    .avgCaloriesPerDay(0.0)
                    .avgProteinPerDay(0.0)
                    .avgCarbsPerDay(0.0)
                    .avgFatPerDay(0.0)
                    .dailyStats(Collections.emptyList())
                    .mealTypeDistribution(Collections.emptyList())
                    .build();
        }

        // Calculate daily stats
        List<DailyNutritionStats> dailyStats = getDailyNutritionStats(userId, startDate, endDate);

        // Calculate averages
        long numberOfDays = dailyStats.size();
        double avgCalories = dailyStats.stream()
                .mapToInt(stats -> stats.getTotalCalories() != null ? stats.getTotalCalories() : 0)
                .average()
                .orElse(0.0);

        double avgProtein = dailyStats.stream()
                .mapToDouble(stats -> stats.getTotalProteinG() != null ? stats.getTotalProteinG() : 0.0)
                .average()
                .orElse(0.0);

        double avgCarbs = dailyStats.stream()
                .mapToDouble(stats -> stats.getTotalCarbohydratesG() != null ? stats.getTotalCarbohydratesG() : 0.0)
                .average()
                .orElse(0.0);

        double avgFat = dailyStats.stream()
                .mapToDouble(stats -> stats.getTotalFatG() != null ? stats.getTotalFatG() : 0.0)
                .average()
                .orElse(0.0);

        // Calculate meal type distribution
        List<MealTypeDistribution> mealTypeDistribution = calculateMealTypeDistribution(meals);

        return NutritionSummary.builder()
                .totalMeals((long) meals.size())
                .avgCaloriesPerDay(avgCalories)
                .avgProteinPerDay(avgProtein)
                .avgCarbsPerDay(avgCarbs)
                .avgFatPerDay(avgFat)
                .dailyStats(dailyStats)
                .mealTypeDistribution(mealTypeDistribution)
                .build();
    }

    public List<MealTypeDistribution> getMealTypeDistribution(UUID userId, LocalDateTime startDate, LocalDateTime endDate) {
        List<Meal> meals = mealRepository.findByUserIdAndMealTimeBetweenOrderByMealTimeDesc(userId, startDate, endDate);
        return calculateMealTypeDistribution(meals);
    }

    private DailyNutritionStats calculateDailyStats(LocalDate date, List<Meal> meals) {
        int totalCalories = meals.stream()
                .mapToInt(meal -> meal.getCalories() != null ? meal.getCalories() : 0)
                .sum();

        double totalProtein = meals.stream()
                .mapToDouble(meal -> meal.getProteinG() != null ? meal.getProteinG() : 0.0)
                .sum();

        double totalFat = meals.stream()
                .mapToDouble(meal -> meal.getFatG() != null ? meal.getFatG() : 0.0)
                .sum();

        double totalSaturatedFat = meals.stream()
                .mapToDouble(meal -> meal.getSaturatedFatG() != null ? meal.getSaturatedFatG() : 0.0)
                .sum();

        double totalCarbs = meals.stream()
                .mapToDouble(meal -> meal.getCarbohydratesG() != null ? meal.getCarbohydratesG() : 0.0)
                .sum();

        double totalFiber = meals.stream()
                .mapToDouble(meal -> meal.getFiberG() != null ? meal.getFiberG() : 0.0)
                .sum();

        double totalSugar = meals.stream()
                .mapToDouble(meal -> meal.getSugarG() != null ? meal.getSugarG() : 0.0)
                .sum();

        double totalSodium = meals.stream()
                .mapToDouble(meal -> meal.getSodiumMg() != null ? meal.getSodiumMg() : 0.0)
                .sum();

        double totalCholesterol = meals.stream()
                .mapToDouble(meal -> meal.getCholesterolMg() != null ? meal.getCholesterolMg() : 0.0)
                .sum();

        return DailyNutritionStats.builder()
                .date(date)
                .totalCalories(totalCalories)
                .totalProteinG(totalProtein)
                .totalFatG(totalFat)
                .totalSaturatedFatG(totalSaturatedFat)
                .totalCarbohydratesG(totalCarbs)
                .totalFiberG(totalFiber)
                .totalSugarG(totalSugar)
                .totalSodiumMg(totalSodium)
                .totalCholesterolMg(totalCholesterol)
                .mealCount(meals.size())
                .build();
    }

    private List<MealTypeDistribution> calculateMealTypeDistribution(List<Meal> meals) {
        if (meals.isEmpty()) {
            return Collections.emptyList();
        }

        long totalMeals = meals.size();

        Map<Meal.MealType, Long> countByType = meals.stream()
                .filter(meal -> meal.getMealType() != null)
                .collect(Collectors.groupingBy(Meal::getMealType, Collectors.counting()));

        return countByType.entrySet().stream()
                .map(entry -> MealTypeDistribution.builder()
                        .mealType(entry.getKey().name())
                        .count(entry.getValue())
                        .percentage((entry.getValue() * 100.0) / totalMeals)
                        .build())
                .sorted(Comparator.comparing(MealTypeDistribution::getMealType))
                .collect(Collectors.toList());
    }

    /**
     * Get combined summary stats for multiple periods (week, month, 6 months)
     */
    public PeriodicSummaryStats getPeriodicSummaryStats(UUID userId) {
        LocalDate now = LocalDate.now();

        // Calculate stats for each period
        PeriodicSummaryStats.PeriodStats weekStats = calculatePeriodStats(
                userId,
                now.minusDays(6).atStartOfDay(),
                now.atTime(LocalTime.MAX),
                7
        );

        PeriodicSummaryStats.PeriodStats monthStats = calculatePeriodStats(
                userId,
                now.minusDays(29).atStartOfDay(),
                now.atTime(LocalTime.MAX),
                30
        );

        PeriodicSummaryStats.PeriodStats sixMonthsStats = calculatePeriodStats(
                userId,
                now.minusMonths(6).atStartOfDay(),
                now.atTime(LocalTime.MAX),
                180
        );

        return PeriodicSummaryStats.builder()
                .week(weekStats)
                .month(monthStats)
                .sixMonths(sixMonthsStats)
                .build();
    }

    private PeriodicSummaryStats.PeriodStats calculatePeriodStats(
            UUID userId,
            LocalDateTime startDate,
            LocalDateTime endDate,
            int totalDays
    ) {
        List<DailyNutritionStats> dailyStats = getDailyNutritionStats(userId, startDate, endDate);

        if (dailyStats.isEmpty()) {
            return PeriodicSummaryStats.PeriodStats.builder()
                    .totalMeals(0)
                    .totalDays(totalDays)
                    .activeDays(0)
                    .avgCalories(0.0)
                    .totalCalories(0.0)
                    .avgProtein(0.0)
                    .avgCarbs(0.0)
                    .avgFat(0.0)
                    .build();
        }

        int totalMeals = dailyStats.stream()
                .mapToInt(DailyNutritionStats::getMealCount)
                .sum();

        int activeDays = (int) dailyStats.stream()
                .filter(stats -> stats.getMealCount() > 0)
                .count();

        double totalCalories = dailyStats.stream()
                .mapToDouble(stats -> stats.getTotalCalories() != null ? stats.getTotalCalories() : 0.0)
                .sum();

        double avgCalories = dailyStats.stream()
                .mapToDouble(stats -> stats.getTotalCalories() != null ? stats.getTotalCalories() : 0.0)
                .average()
                .orElse(0.0);

        double avgProtein = dailyStats.stream()
                .mapToDouble(stats -> stats.getTotalProteinG() != null ? stats.getTotalProteinG() : 0.0)
                .average()
                .orElse(0.0);

        double avgCarbs = dailyStats.stream()
                .mapToDouble(stats -> stats.getTotalCarbohydratesG() != null ? stats.getTotalCarbohydratesG() : 0.0)
                .average()
                .orElse(0.0);

        double avgFat = dailyStats.stream()
                .mapToDouble(stats -> stats.getTotalFatG() != null ? stats.getTotalFatG() : 0.0)
                .average()
                .orElse(0.0);

        return PeriodicSummaryStats.PeriodStats.builder()
                .totalMeals(totalMeals)
                .totalDays(totalDays)
                .activeDays(activeDays)
                .avgCalories(avgCalories)
                .totalCalories(totalCalories)
                .avgProtein(avgProtein)
                .avgCarbs(avgCarbs)
                .avgFat(avgFat)
                .build();
    }
}
