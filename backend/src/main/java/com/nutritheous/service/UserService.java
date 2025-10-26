package com.nutritheous.service;

import com.nutritheous.auth.User;
import com.nutritheous.auth.UserRepository;
import com.nutritheous.dto.UserProfileRequest;
import com.nutritheous.dto.UserProfileResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

/**
 * Service for managing user profile data.
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class UserService {

    private final UserRepository userRepository;
    private final CalorieCalculationService calorieCalculationService;

    /**
     * Gets user profile by user ID.
     *
     * @param userId User ID
     * @return User profile response
     * @throws RuntimeException if user not found
     */
    public UserProfileResponse getUserProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        log.debug("Retrieved profile for user: {}", userId);
        return UserProfileResponse.fromUser(user);
    }

    /**
     * Updates user profile and automatically recalculates estimated daily calories
     * if all required fields are present.
     *
     * @param userId User ID
     * @param request Profile update request
     * @return Updated user profile response
     * @throws RuntimeException if user not found
     */
    @Transactional
    public UserProfileResponse updateUserProfile(UUID userId, UserProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Update profile fields if provided
        if (request.getAge() != null) {
            user.setAge(request.getAge());
        }
        if (request.getHeightCm() != null) {
            user.setHeightCm(request.getHeightCm());
        }
        if (request.getWeightKg() != null) {
            user.setWeightKg(request.getWeightKg());
        }
        if (request.getSex() != null) {
            user.setSex(request.getSex());
        }
        if (request.getActivityLevel() != null) {
            user.setActivityLevel(request.getActivityLevel());
        }

        // Recalculate estimated daily calories if all required fields are present
        if (calorieCalculationService.canCalculateCalories(
                user.getWeightKg(),
                user.getHeightCm(),
                user.getAge(),
                user.getSex(),
                user.getActivityLevel())) {

            int estimatedCalories = calorieCalculationService.calculateEstimatedDailyCalories(
                    user.getWeightKg(),
                    user.getHeightCm(),
                    user.getAge(),
                    user.getSex(),
                    user.getActivityLevel()
            );

            user.setEstimatedCaloriesBurntPerDay(estimatedCalories);

            log.info("Updated profile for user {} with estimated daily calories: {}",
                     userId, estimatedCalories);
        } else {
            log.debug("Cannot calculate calories for user {} - missing required profile fields", userId);
        }

        User savedUser = userRepository.save(user);
        return UserProfileResponse.fromUser(savedUser);
    }
}
