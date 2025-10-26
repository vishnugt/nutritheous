package com.nutritheous.meal;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Repository
public interface MealRepository extends JpaRepository<Meal, UUID> {

    List<Meal> findByUserIdOrderByMealTimeDesc(UUID userId);

    List<Meal> findByUserIdAndMealTimeBetweenOrderByMealTimeDesc(
            UUID userId, LocalDateTime startTime, LocalDateTime endTime);

    List<Meal> findByUserIdAndMealTypeOrderByMealTimeDesc(UUID userId, Meal.MealType mealType);

    List<Meal> findByAnalysisStatus(Meal.AnalysisStatus status);
}
