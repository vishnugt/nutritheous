-- Remove unused columns from meals table
-- analysis_json: Never populated, individual fields are used instead
-- image_url: Never populated, presigned URLs are generated dynamically

ALTER TABLE meals DROP COLUMN IF EXISTS analysis_json;
ALTER TABLE meals DROP COLUMN IF EXISTS image_url;

-- Add comments
COMMENT ON TABLE meals IS 'Meal entries with nutritional information. Images stored in GCS referenced by object_name.';
