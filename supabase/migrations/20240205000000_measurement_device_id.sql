-- ============================================================
-- GlucoPlot: Add device_id to measurements + UPDATE RLS policy
-- ============================================================
-- Tracks which physical device produced each measurement for
-- traceability (e.g. identifying faulty devices).
-- Also adds the missing UPDATE policy so auto-saved measurements
-- can be updated with meal timing by the patient.
-- ============================================================

-- Add device_id column (nullable - manual entries won't have one)
ALTER TABLE measurements ADD COLUMN device_id text;

COMMENT ON COLUMN measurements.device_id IS 'Physical device ID that produced this measurement (e.g. GlP-000034). Null for manual entries.';

-- Index for future device-level queries (find all readings from a specific device)
CREATE INDEX idx_measurements_device_id ON measurements (device_id)
WHERE device_id IS NOT NULL;

-- Ensure helper function exists (may be missing on remote)
CREATE OR REPLACE FUNCTION get_patient_id()
RETURNS uuid AS $$
BEGIN
  RETURN (SELECT id FROM patients WHERE auth_user_id = auth.uid() LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- Add missing UPDATE policy: patients can update their own measurements
-- (needed for auto-save override flow where meal timing is added later)
CREATE POLICY "Patients can update own measurements"
  ON measurements FOR UPDATE
  USING (patient_id = get_patient_id());
