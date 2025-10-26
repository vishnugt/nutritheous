-- Initial database schema for Nutritheous
-- Consolidated all migrations into single file

-- ============================================
-- USERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'USER',
    age INTEGER,
    height_cm DOUBLE PRECISION,
    weight_kg DOUBLE PRECISION,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add check constraints for user profile fields
ALTER TABLE users ADD CONSTRAINT check_age_valid CHECK (age IS NULL OR (age >= 0 AND age <= 150));
ALTER TABLE users ADD CONSTRAINT check_height_valid CHECK (height_cm IS NULL OR (height_cm >= 50 AND height_cm <= 300));
ALTER TABLE users ADD CONSTRAINT check_weight_valid CHECK (weight_kg IS NULL OR (weight_kg >= 10 AND weight_kg <= 500));

-- Add comments for user table
COMMENT ON COLUMN users.age IS 'User age in years';
COMMENT ON COLUMN users.height_cm IS 'User height in centimeters';
COMMENT ON COLUMN users.weight_kg IS 'User weight in kilograms';

-- ============================================
-- MEALS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS meals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    meal_time TIMESTAMP NOT NULL,
    meal_type VARCHAR(20) CHECK(meal_type IN ('BREAKFAST','LUNCH','DINNER','SNACK')),
    image_url VARCHAR(1024),
    object_name VARCHAR(500),
    description VARCHAR(500),
    serving_size VARCHAR(255),
    analysis_json JSONB,

    -- Nutrition fields
    calories INTEGER,
    protein_g DOUBLE PRECISION,
    fat_g DOUBLE PRECISION,
    saturated_fat_g DOUBLE PRECISION,
    carbohydrates_g DOUBLE PRECISION,
    fiber_g DOUBLE PRECISION,
    sugar_g DOUBLE PRECISION,
    sodium_mg DOUBLE PRECISION,
    cholesterol_mg DOUBLE PRECISION,

    -- Additional analysis fields
    ingredients JSONB,
    allergens JSONB,
    health_notes VARCHAR(1000),
    confidence DOUBLE PRECISION,

    -- Status and timestamps
    analysis_status VARCHAR(20) DEFAULT 'PENDING' CHECK(analysis_status IN ('PENDING','COMPLETED','FAILED')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_meals_user_id ON meals(user_id);
CREATE INDEX IF NOT EXISTS idx_meals_meal_time ON meals(meal_time);
CREATE INDEX IF NOT EXISTS idx_meals_analysis_status ON meals(analysis_status);
CREATE INDEX IF NOT EXISTS idx_meals_user_meal_time ON meals(user_id, meal_time DESC);

-- Add comments for meals table
COMMENT ON COLUMN meals.serving_size IS 'Estimated serving size (e.g., 1 plate, 2 slices, 300g)';
COMMENT ON COLUMN meals.protein_g IS 'Protein content in grams';
COMMENT ON COLUMN meals.fat_g IS 'Total fat content in grams';
COMMENT ON COLUMN meals.saturated_fat_g IS 'Saturated fat content in grams';
COMMENT ON COLUMN meals.carbohydrates_g IS 'Total carbohydrates in grams';
COMMENT ON COLUMN meals.fiber_g IS 'Dietary fiber in grams';
COMMENT ON COLUMN meals.sugar_g IS 'Total sugars in grams';
COMMENT ON COLUMN meals.sodium_mg IS 'Sodium content in milligrams';
COMMENT ON COLUMN meals.cholesterol_mg IS 'Cholesterol content in milligrams';
COMMENT ON COLUMN meals.ingredients IS 'List of main ingredients detected (JSON array)';
COMMENT ON COLUMN meals.allergens IS 'List of potential allergens (JSON array)';
COMMENT ON COLUMN meals.health_notes IS 'Brief health insights and nutritional highlights';
COMMENT ON COLUMN meals.confidence IS 'AI confidence level for the analysis (0.0 to 1.0)';
