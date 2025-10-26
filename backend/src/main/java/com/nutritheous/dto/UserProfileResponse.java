package com.nutritheous.dto;

import com.nutritheous.auth.ActivityLevel;
import com.nutritheous.auth.Sex;
import com.nutritheous.auth.User;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Response DTO containing user profile information.
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserProfileResponse {

    private UUID id;
    private String email;
    private String role;

    // Profile fields
    private Integer age;
    private Double heightCm;
    private Double weightKg;
    private Sex sex;
    private ActivityLevel activityLevel;

    // Calculated field
    private Integer estimatedCaloriesBurntPerDay;

    private LocalDateTime createdAt;

    /**
     * Converts a User entity to a UserProfileResponse DTO.
     */
    public static UserProfileResponse fromUser(User user) {
        return UserProfileResponse.builder()
                .id(user.getId())
                .email(user.getEmail())
                .role(user.getRole())
                .age(user.getAge())
                .heightCm(user.getHeightCm())
                .weightKg(user.getWeightKg())
                .sex(user.getSex())
                .activityLevel(user.getActivityLevel())
                .estimatedCaloriesBurntPerDay(user.getEstimatedCaloriesBurntPerDay())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
