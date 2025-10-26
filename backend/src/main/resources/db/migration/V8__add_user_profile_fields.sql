-- Add user profile fields for calorie tracking
-- Sex, activity level, and estimated daily calorie burn

-- Add sex column (MALE/FEMALE)
ALTER TABLE users ADD COLUMN sex VARCHAR(10);

-- Add activity level column
ALTER TABLE users ADD COLUMN activity_level VARCHAR(30);

-- Add estimated calories burnt per day (calculated from BMR and activity level)
ALTER TABLE users ADD COLUMN estimated_calories_burnt_per_day INTEGER;

-- Add check constraints
ALTER TABLE users ADD CONSTRAINT check_sex_valid CHECK (sex IS NULL OR sex IN ('MALE', 'FEMALE'));
ALTER TABLE users ADD CONSTRAINT check_activity_level_valid CHECK (activity_level IS NULL OR activity_level IN ('SEDENTARY', 'LIGHTLY_ACTIVE', 'MODERATELY_ACTIVE', 'VERY_ACTIVE', 'EXTREMELY_ACTIVE'));
ALTER TABLE users ADD CONSTRAINT check_calories_valid CHECK (estimated_calories_burnt_per_day IS NULL OR (estimated_calories_burnt_per_day >= 800 AND estimated_calories_burnt_per_day <= 10000));

-- Add comments for new columns
COMMENT ON COLUMN users.sex IS 'User biological sex for calorie calculation (MALE/FEMALE)';
COMMENT ON COLUMN users.activity_level IS 'Daily activity level: SEDENTARY (little/no exercise), LIGHTLY_ACTIVE (1-3 days/week), MODERATELY_ACTIVE (3-5 days/week), VERY_ACTIVE (6-7 days/week), EXTREMELY_ACTIVE (physical job + exercise)';
COMMENT ON COLUMN users.estimated_calories_burnt_per_day IS 'Estimated total daily energy expenditure (TDEE) in calories, calculated from BMR and activity level';
