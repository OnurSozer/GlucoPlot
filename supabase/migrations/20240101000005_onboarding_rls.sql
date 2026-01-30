-- ============================================================
-- GlucoPlot: RLS Policies for Patient Onboarding Tables
-- Doctors can CRUD their patients' data
-- Patients can view their own data
-- ============================================================

-- ============================================================
-- Enable RLS on new tables
-- ============================================================
ALTER TABLE patient_physical_data ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_medical_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_medication_schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_chronic_diseases ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_lab_info ENABLE ROW LEVEL SECURITY;
ALTER TABLE patient_notification_preferences ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Helper function to check if user is the doctor of a patient
-- ============================================================
CREATE OR REPLACE FUNCTION is_patient_doctor(p_patient_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM patients
        WHERE patients.id = p_patient_id
        AND patients.doctor_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- Helper function to check if user is the patient
-- ============================================================
CREATE OR REPLACE FUNCTION is_own_patient_data(p_patient_id uuid)
RETURNS boolean AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM patients
        WHERE patients.id = p_patient_id
        AND patients.auth_user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- Patient Physical Data Policies
-- ============================================================
CREATE POLICY "Doctors can view patient physical data"
    ON patient_physical_data FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient physical data"
    ON patient_physical_data FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient physical data"
    ON patient_physical_data FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient physical data"
    ON patient_physical_data FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own physical data"
    ON patient_physical_data FOR SELECT
    USING (is_own_patient_data(patient_id));

-- ============================================================
-- Patient Habits Policies
-- ============================================================
CREATE POLICY "Doctors can view patient habits"
    ON patient_habits FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient habits"
    ON patient_habits FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient habits"
    ON patient_habits FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient habits"
    ON patient_habits FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own habits"
    ON patient_habits FOR SELECT
    USING (is_own_patient_data(patient_id));

-- ============================================================
-- Patient Goals Policies
-- ============================================================
CREATE POLICY "Doctors can view patient goals"
    ON patient_goals FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient goals"
    ON patient_goals FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient goals"
    ON patient_goals FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient goals"
    ON patient_goals FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own goals"
    ON patient_goals FOR SELECT
    USING (is_own_patient_data(patient_id));

-- ============================================================
-- Patient Medical History Policies
-- ============================================================
CREATE POLICY "Doctors can view patient medical history"
    ON patient_medical_history FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient medical history"
    ON patient_medical_history FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient medical history"
    ON patient_medical_history FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient medical history"
    ON patient_medical_history FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own medical history"
    ON patient_medical_history FOR SELECT
    USING (is_own_patient_data(patient_id));

-- ============================================================
-- Patient Medication Schedules Policies
-- ============================================================
CREATE POLICY "Doctors can view patient medication schedules"
    ON patient_medication_schedules FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient medication schedules"
    ON patient_medication_schedules FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient medication schedules"
    ON patient_medication_schedules FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient medication schedules"
    ON patient_medication_schedules FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own medication schedules"
    ON patient_medication_schedules FOR SELECT
    USING (is_own_patient_data(patient_id));

-- ============================================================
-- Patient Chronic Diseases Policies
-- ============================================================
CREATE POLICY "Doctors can view patient chronic diseases"
    ON patient_chronic_diseases FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient chronic diseases"
    ON patient_chronic_diseases FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient chronic diseases"
    ON patient_chronic_diseases FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient chronic diseases"
    ON patient_chronic_diseases FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own chronic diseases"
    ON patient_chronic_diseases FOR SELECT
    USING (is_own_patient_data(patient_id));

-- ============================================================
-- Patient Lab Info Policies
-- ============================================================
CREATE POLICY "Doctors can view patient lab info"
    ON patient_lab_info FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient lab info"
    ON patient_lab_info FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient lab info"
    ON patient_lab_info FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient lab info"
    ON patient_lab_info FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own lab info"
    ON patient_lab_info FOR SELECT
    USING (is_own_patient_data(patient_id));

-- ============================================================
-- Patient Notification Preferences Policies
-- ============================================================
CREATE POLICY "Doctors can view patient notification preferences"
    ON patient_notification_preferences FOR SELECT
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can insert patient notification preferences"
    ON patient_notification_preferences FOR INSERT
    WITH CHECK (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can update patient notification preferences"
    ON patient_notification_preferences FOR UPDATE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Doctors can delete patient notification preferences"
    ON patient_notification_preferences FOR DELETE
    USING (is_patient_doctor(patient_id));

CREATE POLICY "Patients can view own notification preferences"
    ON patient_notification_preferences FOR SELECT
    USING (is_own_patient_data(patient_id));
