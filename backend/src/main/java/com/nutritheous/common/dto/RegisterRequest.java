package com.nutritheous.common.dto;

import com.nutritheous.auth.ActivityLevel;
import com.nutritheous.auth.Sex;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class RegisterRequest {

    @NotBlank(message = "Email is required")
    @Email(message = "Email should be valid")
    private String email;

    @NotBlank(message = "Password is required")
    @Size(min = 5, message = "Password must be at least 5 characters long")
    private String password;

    @NotNull(message = "Age is required")
    @Min(value = 10, message = "Age must be at least 10")
    @Max(value = 150, message = "Age must be at most 150")
    private Integer age;

    @NotNull(message = "Height is required")
    @DecimalMin(value = "30.0", message = "Height must be at least 30 cm")
    @DecimalMax(value = "300.0", message = "Height must be at most 300 cm")
    private Double heightCm;

    @NotNull(message = "Weight is required")
    @DecimalMin(value = "1.0", message = "Weight must be at least 1 kg")
    @DecimalMax(value = "500.0", message = "Weight must be at most 500 kg")
    private Double weightKg;

    @NotNull(message = "Sex is required")
    private Sex sex;

    @NotNull(message = "Activity level is required")
    private ActivityLevel activityLevel;
}
