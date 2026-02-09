-- Migration: Create patient_relatives table
-- Moves relative data from flat columns on patients to a proper junction table

-- 1. Create patient_relatives table
CREATE TABLE IF NOT EXISTS patient_relatives (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patients(id) ON DELETE CASCADE,
    name text NOT NULL,
    phone text,
    email text,
    is_primary boolean DEFAULT false,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now()
);

-- 2. Index on patient_id for fast lookups
CREATE INDEX idx_patient_relatives_patient_id ON patient_relatives(patient_id);

-- 3. updated_at trigger
CREATE OR REPLACE TRIGGER trg_patient_relatives_updated_at
    BEFORE UPDATE ON patient_relatives
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- 4. Enable RLS
ALTER TABLE patient_relatives ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies (same pattern as other onboarding tables)
CREATE POLICY "Doctors can view patient relatives"
    ON patient_relatives FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient relatives"
    ON patient_relatives FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient relatives"
    ON patient_relatives FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient relatives"
    ON patient_relatives FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own relatives"
    ON patient_relatives FOR SELECT
    USING (is_own_patient_data(patient_id));

-- 6. Data migration: move existing relative data into the new table
INSERT INTO patient_relatives (patient_id, name, phone, email, is_primary)
SELECT id, relative_name, relative_phone, relative_email, true
FROM patients
WHERE relative_name IS NOT NULL AND relative_name <> '';

-- 7. Drop old columns from patients table
ALTER TABLE patients
    DROP COLUMN IF EXISTS relative_name,
    DROP COLUMN IF EXISTS relative_phone,
    DROP COLUMN IF EXISTS relative_email;
