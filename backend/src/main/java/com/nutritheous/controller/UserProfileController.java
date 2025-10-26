package com.nutritheous.controller;

import com.nutritheous.auth.User;
import com.nutritheous.dto.UserProfileRequest;
import com.nutritheous.dto.UserProfileResponse;
import com.nutritheous.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * REST controller for user profile management.
 * Requires authentication via JWT.
 */
@RestController
@RequestMapping("/api/users")
@RequiredArgsConstructor
@Slf4j
public class UserProfileController {

    private final UserService userService;

    /**
     * Get current user's profile.
     *
     * @param user Authenticated user from JWT token
     * @return User profile data
     */
    @GetMapping("/profile")
    public ResponseEntity<UserProfileResponse> getUserProfile(
            @AuthenticationPrincipal User user) {

        log.info("GET /api/users/profile - User: {}", user.getId());

        UserProfileResponse profile = userService.getUserProfile(user.getId());
        return ResponseEntity.ok(profile);
    }

    /**
     * Update current user's profile.
     * Automatically recalculates estimated daily calories if all required fields are provided.
     *
     * @param user Authenticated user from JWT token
     * @param request Profile update request
     * @return Updated user profile data
     */
    @PutMapping("/profile")
    public ResponseEntity<UserProfileResponse> updateUserProfile(
            @AuthenticationPrincipal User user,
            @Valid @RequestBody UserProfileRequest request) {

        log.info("PUT /api/users/profile - User: {}, Request: {}", user.getId(), request);

        UserProfileResponse updatedProfile = userService.updateUserProfile(user.getId(), request);

        log.info("Profile updated successfully for user: {}, Estimated calories: {}",
                 user.getId(), updatedProfile.getEstimatedCaloriesBurntPerDay());

        return ResponseEntity.ok(updatedProfile);
    }
}
