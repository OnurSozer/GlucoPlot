-- ============================================================
-- Secure Patients Table
-- Enable RLS and add policies for doctors
-- ============================================================

-- Enable RLS
ALTER TABLE patients ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Doctors can view own patients" ON patients
  FOR SELECT
  USING (doctor_id = auth.uid());

CREATE POLICY "Doctors can insert patients" ON patients
  FOR INSERT
  WITH CHECK (doctor_id = auth.uid());

CREATE POLICY "Doctors can update own patients" ON patients
  FOR UPDATE
  USING (doctor_id = auth.uid());

CREATE POLICY "Doctors can delete own patients" ON patients
  FOR DELETE
  USING (doctor_id = auth.uid());
