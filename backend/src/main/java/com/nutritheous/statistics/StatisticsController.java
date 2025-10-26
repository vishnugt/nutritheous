package com.nutritheous.statistics;

import com.nutritheous.auth.User;
import com.nutritheous.statistics.dto.DailyNutritionStats;
import com.nutritheous.statistics.dto.MealTypeDistribution;
import com.nutritheous.statistics.dto.NutritionSummary;
import com.nutritheous.statistics.dto.PeriodicSummaryStats;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@RestController
@RequestMapping("/api/statistics")
@RequiredArgsConstructor
@Tag(name = "Statistics", description = "Nutrition and meal statistics endpoints")
@SecurityRequirement(name = "bearerAuth")
public class StatisticsController {

    private final StatisticsService statisticsService;

    @GetMapping("/daily")
    @Operation(
            summary = "Get daily nutrition statistics",
            description = "Returns daily nutrition breakdown for plotting (calories, protein, carbs, fat, etc.) within a date range"
    )
    public ResponseEntity<List<DailyNutritionStats>> getDailyNutritionStats(
            @AuthenticationPrincipal User user,
            @Parameter(description = "Start date (defaults to 30 days ago)", example = "2024-01-01")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "End date (defaults to today)", example = "2024-01-31")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        LocalDateTime start = (startDate != null ? startDate : LocalDate.now().minusDays(30))
                .atStartOfDay();
        LocalDateTime end = (endDate != null ? endDate : LocalDate.now())
                .atTime(LocalTime.MAX);

        List<DailyNutritionStats> stats = statisticsService.getDailyNutritionStats(user.getId(), start, end);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/summary")
    @Operation(
            summary = "Get nutrition summary",
            description = "Returns comprehensive nutrition summary including averages, daily breakdown, and meal type distribution"
    )
    public ResponseEntity<NutritionSummary> getNutritionSummary(
            @AuthenticationPrincipal User user,
            @Parameter(description = "Start date (defaults to 30 days ago)", example = "2024-01-01")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "End date (defaults to today)", example = "2024-01-31")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        LocalDateTime start = (startDate != null ? startDate : LocalDate.now().minusDays(30))
                .atStartOfDay();
        LocalDateTime end = (endDate != null ? endDate : LocalDate.now())
                .atTime(LocalTime.MAX);

        NutritionSummary summary = statisticsService.getNutritionSummary(user.getId(), start, end);
        return ResponseEntity.ok(summary);
    }

    @GetMapping("/meal-distribution")
    @Operation(
            summary = "Get meal type distribution",
            description = "Returns the distribution of meals by type (breakfast, lunch, dinner, snack) with counts and percentages"
    )
    public ResponseEntity<List<MealTypeDistribution>> getMealTypeDistribution(
            @AuthenticationPrincipal User user,
            @Parameter(description = "Start date (defaults to 30 days ago)", example = "2024-01-01")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @Parameter(description = "End date (defaults to today)", example = "2024-01-31")
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate
    ) {
        LocalDateTime start = (startDate != null ? startDate : LocalDate.now().minusDays(30))
                .atStartOfDay();
        LocalDateTime end = (endDate != null ? endDate : LocalDate.now())
                .atTime(LocalTime.MAX);

        List<MealTypeDistribution> distribution = statisticsService.getMealTypeDistribution(user.getId(), start, end);
        return ResponseEntity.ok(distribution);
    }

    @GetMapping("/weekly")
    @Operation(
            summary = "Get weekly nutrition statistics",
            description = "Returns daily nutrition breakdown for the past 7 days (convenient shortcut for weekly view)"
    )
    public ResponseEntity<List<DailyNutritionStats>> getWeeklyStats(@AuthenticationPrincipal User user) {
        LocalDateTime start = LocalDate.now().minusDays(7).atStartOfDay();
        LocalDateTime end = LocalDate.now().atTime(LocalTime.MAX);

        List<DailyNutritionStats> stats = statisticsService.getDailyNutritionStats(user.getId(), start, end);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/monthly")
    @Operation(
            summary = "Get monthly nutrition statistics",
            description = "Returns daily nutrition breakdown for the past 30 days (convenient shortcut for monthly view)"
    )
    public ResponseEntity<List<DailyNutritionStats>> getMonthlyStats(@AuthenticationPrincipal User user) {
        LocalDateTime start = LocalDate.now().minusDays(30).atStartOfDay();
        LocalDateTime end = LocalDate.now().atTime(LocalTime.MAX);

        List<DailyNutritionStats> stats = statisticsService.getDailyNutritionStats(user.getId(), start, end);
        return ResponseEntity.ok(stats);
    }

    @GetMapping("/periodic-summary")
    @Operation(
            summary = "Get combined summary stats for all periods",
            description = "Returns summary statistics for week, month, and 6 months in a single API call"
    )
    public ResponseEntity<PeriodicSummaryStats> getPeriodicSummaryStats(@AuthenticationPrincipal User user) {
        PeriodicSummaryStats stats = statisticsService.getPeriodicSummaryStats(user.getId());
        return ResponseEntity.ok(stats);
    }
}
