package com.nutritheous.auth;

import com.nutritheous.common.dto.AuthResponse;
import com.nutritheous.common.dto.LoginRequest;
import com.nutritheous.common.dto.RegisterRequest;
import com.nutritheous.common.exception.InvalidCredentialsException;
import com.nutritheous.common.exception.UserAlreadyExistsException;
import com.nutritheous.service.CalorieCalculationService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@Slf4j
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtService jwtService;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private CalorieCalculationService calorieCalculationService;

    public AuthResponse register(RegisterRequest request) {
        log.info("📝 Registration attempt for email: {}", request.getEmail());

        if (userRepository.existsByEmail(request.getEmail())) {
            log.warn("❌ Registration failed - Email already exists: {}", request.getEmail());
            throw new UserAlreadyExistsException("User with email " + request.getEmail() + " already exists");
        }

        // Calculate estimated daily calories
        int estimatedCalories = calorieCalculationService.calculateEstimatedDailyCalories(
                request.getWeightKg(),
                request.getHeightCm(),
                request.getAge(),
                request.getSex(),
                request.getActivityLevel()
        );

        User user = User.builder()
                .email(request.getEmail())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role("USER")
                .age(request.getAge())
                .heightCm(request.getHeightCm())
                .weightKg(request.getWeightKg())
                .sex(request.getSex())
                .activityLevel(request.getActivityLevel())
                .estimatedCaloriesBurntPerDay(estimatedCalories)
                .build();

        user = userRepository.save(user);

        String token = jwtService.generateToken(user);

        log.info("✅ Registration successful - User: {}, ID: {}", user.getEmail(), user.getId());
        log.info("🎫 Generated JWT token (length: {} chars)", token.length());

        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .role(user.getRole())
                .userId(user.getId())
                .build();
    }

    public AuthResponse login(LoginRequest request) {
        log.info("🔐 Login attempt for email: {}", request.getEmail());

        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );
        } catch (AuthenticationException e) {
            log.warn("❌ Login failed - Invalid credentials for: {}", request.getEmail());
            throw new InvalidCredentialsException("Invalid email or password");
        }

        User user = userRepository.findByEmail(request.getEmail())
                .orElseThrow(() -> new InvalidCredentialsException("Invalid email or password"));

        String token = jwtService.generateToken(user);

        log.info("✅ Login successful - User: {}, ID: {}", user.getEmail(), user.getId());
        log.info("🎫 Generated JWT token (length: {} chars)", token.length());
        log.info("📋 Authorization header for curl:");
        log.info("   -H \"Authorization: Bearer {}\"", token);

        return AuthResponse.builder()
                .token(token)
                .email(user.getEmail())
                .role(user.getRole())
                .userId(user.getId())
                .build();
    }
}
