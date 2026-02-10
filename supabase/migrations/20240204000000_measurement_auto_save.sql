-- ============================================================
-- GlucoPlot: Add is_auto_saved flag to measurements
-- ============================================================
-- When a glucose reading is received from the USB device, it is
-- immediately saved with is_auto_saved = true. If the user
-- selects meal timing and explicitly saves, we update the record
-- and set is_auto_saved = false.
-- ============================================================

-- Add is_auto_saved column (default true for backward compat with device readings)
ALTER TABLE measurements ADD COLUMN is_auto_saved boolean NOT NULL DEFAULT false;

-- Add comment for documentation
COMMENT ON COLUMN measurements.is_auto_saved IS 'True if measurement was auto-saved by device without user confirmation. False if user explicitly saved with meal timing.';

-- Index for filtering auto-saved measurements
CREATE INDEX idx_measurements_auto_saved ON measurements (patient_id, is_auto_saved)
WHERE is_auto_saved = true;
