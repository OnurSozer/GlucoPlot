-- ============================================================
-- GlucoPlot: Patient Onboarding Data
-- Comprehensive patient onboarding information
-- ============================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- Extend patients table with additional basic info
-- ============================================================
ALTER TABLE patients
ADD COLUMN IF NOT EXISTS national_id text,
ADD COLUMN IF NOT EXISTS emergency_contact_phone text,
ADD COLUMN IF NOT EXISTS emergency_contact_email text,
ADD COLUMN IF NOT EXISTS relative_name text,
ADD COLUMN IF NOT EXISTS relative_phone text,
ADD COLUMN IF NOT EXISTS relative_email text;

-- ============================================================
-- Custom types for onboarding
-- ============================================================
DO $$ BEGIN
    CREATE TYPE diabetes_type AS ENUM (
        'type1', 'type2', 'prediabetes', 'gestational',
        'lada', 'mody', 'secondary', 'chemically_induced'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE medication_class AS ENUM ('insulin', 'oral_hypoglycemic', 'none');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE insulin_type AS ENUM (
        'none', 'nph', 'lente', 'ultralente', 'regular', 'rapid', 'long'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE med_time_period AS ENUM (
        'morning', 'noon', 'evening', 'night', 'other1', 'other2'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE chronic_disease_type AS ENUM (
        'hypertension', 'cardiovascular', 'heart_failure', 'hyperlipidemia',
        'kidney_failure', 'chronic_pain', 'major_depression', 'anxiety',
        'sleep_disorder', 'physical_disability', 'other'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE notification_trigger AS ENUM (
        'hypoglycemia_below_40',
        'survey_not_submitted_12h',
        'glucose_not_measured_3h'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE notification_channel AS ENUM (
        'doctor_sms', 'doctor_email', 'relative_sms', 'relative_email'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- ============================================================
-- Patient Physical Data
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_physical_data (
    id          uuid        PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id  uuid        NOT NULL REFERENCES patients (id) ON DELETE CASCADE UNIQUE,
    height_cm   numeric,
    weight_kg   numeric,
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE patient_physical_data IS 'Patient physical measurements for BMI calculation.';
COMMENT ON COLUMN patient_physical_data.height_cm IS 'Height in centimeters.';
COMMENT ON COLUMN patient_physical_data.weight_kg IS 'Weight in kilograms.';

CREATE INDEX IF NOT EXISTS idx_physical_data_patient ON patient_physical_data (patient_id);

-- ============================================================
-- Patient Habits (JSONB for flexibility)
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_habits (
    id          uuid        PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id  uuid        NOT NULL REFERENCES patients (id) ON DELETE CASCADE UNIQUE,
    habits      jsonb       NOT NULL DEFAULT '{}',
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE patient_habits IS 'Patient lifestyle habits stored as flexible JSON.';
COMMENT ON COLUMN patient_habits.habits IS 'JSON object with habit scores (1-10) and exercise info.';

CREATE INDEX IF NOT EXISTS idx_habits_patient ON patient_habits (patient_id);

-- ============================================================
-- Patient Goals (JSONB for flexibility)
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_goals (
    id          uuid        PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id  uuid        NOT NULL REFERENCES patients (id) ON DELETE CASCADE UNIQUE,
    goals       jsonb       NOT NULL DEFAULT '{}',
    created_at  timestamptz NOT NULL DEFAULT now(),
    updated_at  timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE patient_goals IS 'Patient health goal priorities.';
COMMENT ON COLUMN patient_goals.goals IS 'JSON object with goal priorities (very_important, important, secondary, unimportant).';

CREATE INDEX IF NOT EXISTS idx_goals_patient ON patient_goals (patient_id);

-- ============================================================
-- Patient Medical History
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_medical_history (
    id                   uuid            PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id           uuid            NOT NULL REFERENCES patients (id) ON DELETE CASCADE UNIQUE,
    has_diabetes         boolean         DEFAULT false,
    diabetes_type        diabetes_type,
    diagnosis_date       date,
    medication_type      medication_class DEFAULT 'none',
    created_at           timestamptz     NOT NULL DEFAULT now(),
    updated_at           timestamptz     NOT NULL DEFAULT now()
);

COMMENT ON TABLE patient_medical_history IS 'Patient diabetes and medication history.';

CREATE INDEX IF NOT EXISTS idx_medical_history_patient ON patient_medical_history (patient_id);

-- ============================================================
-- Patient Medication Schedules
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_medication_schedules (
    id                uuid            PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id        uuid            NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    medication_class  medication_class NOT NULL,
    time_period       med_time_period NOT NULL,
    insulin_type      insulin_type,
    medication_name   text,
    dose              numeric,
    dose_unit         text            DEFAULT 'IU',
    scheduled_time    time,
    is_active         boolean         DEFAULT true,
    created_at        timestamptz     NOT NULL DEFAULT now(),
    updated_at        timestamptz     NOT NULL DEFAULT now(),

    UNIQUE (patient_id, medication_class, time_period)
);

COMMENT ON TABLE patient_medication_schedules IS 'Patient insulin and oral medication schedules.';

CREATE INDEX IF NOT EXISTS idx_med_schedules_patient ON patient_medication_schedules (patient_id);

-- ============================================================
-- Patient Chronic Diseases
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_chronic_diseases (
    id            uuid                  PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id    uuid                  NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    disease_type  chronic_disease_type  NOT NULL,
    other_details text,
    created_at    timestamptz           NOT NULL DEFAULT now(),

    UNIQUE (patient_id, disease_type)
);

COMMENT ON TABLE patient_chronic_diseases IS 'Patient chronic disease conditions.';

CREATE INDEX IF NOT EXISTS idx_chronic_diseases_patient ON patient_chronic_diseases (patient_id);

-- ============================================================
-- Patient Lab Information
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_lab_info (
    id                  uuid        PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id          uuid        NOT NULL REFERENCES patients (id) ON DELETE CASCADE UNIQUE,
    hba1c_percentage    numeric,
    hba1c_test_date     date,
    target_glucose_min  numeric,
    target_glucose_max  numeric,
    created_at          timestamptz NOT NULL DEFAULT now(),
    updated_at          timestamptz NOT NULL DEFAULT now()
);

COMMENT ON TABLE patient_lab_info IS 'Patient laboratory test results and glucose targets.';

CREATE INDEX IF NOT EXISTS idx_lab_info_patient ON patient_lab_info (patient_id);

-- ============================================================
-- Patient Notification Preferences
-- ============================================================
CREATE TABLE IF NOT EXISTS patient_notification_preferences (
    id          uuid                  PRIMARY KEY DEFAULT uuid_generate_v4(),
    patient_id  uuid                  NOT NULL REFERENCES patients (id) ON DELETE CASCADE,
    trigger     notification_trigger  NOT NULL,
    channel     notification_channel  NOT NULL,
    enabled     boolean               NOT NULL DEFAULT true,
    created_at  timestamptz           NOT NULL DEFAULT now(),

    UNIQUE (patient_id, trigger, channel)
);

COMMENT ON TABLE patient_notification_preferences IS 'Patient notification preferences for alerts.';

CREATE INDEX IF NOT EXISTS idx_notif_prefs_patient ON patient_notification_preferences (patient_id);

-- ============================================================
-- Add updated_at triggers for new tables
-- ============================================================
CREATE OR REPLACE TRIGGER trg_physical_data_updated_at
    BEFORE UPDATE ON patient_physical_data
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE TRIGGER trg_habits_updated_at
    BEFORE UPDATE ON patient_habits
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE TRIGGER trg_goals_updated_at
    BEFORE UPDATE ON patient_goals
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE TRIGGER trg_medical_history_updated_at
    BEFORE UPDATE ON patient_medical_history
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE TRIGGER trg_med_schedules_updated_at
    BEFORE UPDATE ON patient_medication_schedules
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE TRIGGER trg_lab_info_updated_at
    BEFORE UPDATE ON patient_lab_info
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
