-- ============================================================
-- GlucoPlot: Add meal_timing to measurements
-- ============================================================

-- Create enum for meal timing
CREATE TYPE meal_timing AS ENUM ('fasting', 'post_meal', 'other');

-- Add meal_timing column to measurements table (nullable for backward compatibility)
ALTER TABLE measurements ADD COLUMN meal_timing meal_timing;

-- Add comment for documentation
COMMENT ON COLUMN measurements.meal_timing IS 'Meal timing context for glucose measurements: fasting, post_meal, or other';

-- Add index for efficient filtering (only for glucose type)
CREATE INDEX idx_measurements_meal_timing ON measurements (patient_id, type, meal_timing)
WHERE type = 'glucose';
