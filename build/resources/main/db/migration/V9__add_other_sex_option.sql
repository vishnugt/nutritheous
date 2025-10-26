-- Add OTHER option to sex column constraint

-- Drop old constraint
ALTER TABLE users DROP CONSTRAINT IF EXISTS check_sex_valid;

-- Add new constraint with OTHER option
ALTER TABLE users ADD CONSTRAINT check_sex_valid CHECK (sex IS NULL OR sex IN ('MALE', 'FEMALE', 'OTHER'));

-- Update comment
COMMENT ON COLUMN users.sex IS 'User sex for calorie calculation (MALE/FEMALE/OTHER). OTHER uses average of male and female BMR calculations.';
