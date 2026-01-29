-- ============================================================
-- GlucoPlot: Seed Data for Local Development
-- ============================================================
--
-- IMPORTANT: Before running this seed, create test users in Supabase:
--
-- 1. Doctor user: test.doctor@glucoplot.dev (password: testpassword123)
--    Note the UUID from auth.users after creation
--
-- 2. Replace the UUIDs below with the actual UUIDs from auth.users
--
-- To run: supabase db seed
-- ============================================================

-- Placeholder UUIDs (replace with actual auth.users IDs)
-- These are deterministic UUIDs for reproducible seeding
do $$
declare
  v_doctor_id   uuid := '00000000-0000-0000-0000-000000000001';
  v_patient1_id uuid;
  v_patient2_id uuid;
  v_patient3_id uuid;
begin

  -- ============================================================
  -- Create test doctor
  -- ============================================================
  insert into doctors (id, full_name, email, phone, specialty)
  values (
    v_doctor_id,
    'Dr. Sarah Johnson',
    'test.doctor@glucoplot.dev',
    '+1-555-0100',
    'Endocrinology'
  )
  on conflict (id) do nothing;

  -- ============================================================
  -- Create default thresholds for the doctor
  -- ============================================================
  insert into measurement_thresholds (doctor_id, measurement_type, min_critical, min_warning, max_warning, max_critical, unit)
  values
    (v_doctor_id, 'glucose',        40,  70,   140,  250,  'mg/dL'),
    (v_doctor_id, 'blood_pressure', 60,  90,   140,  180,  'mmHg'),
    (v_doctor_id, 'heart_rate',     40,  50,   100,  150,  'bpm'),
    (v_doctor_id, 'weight',         null, null, null, null, 'kg'),
    (v_doctor_id, 'temperature',    35,  36,   37.5, 39,   'C'),
    (v_doctor_id, 'spo2',           85,  92,   100,  100,  '%')
  on conflict (doctor_id, measurement_type) do nothing;

  -- ============================================================
  -- Create test patients
  -- ============================================================
  insert into patients (id, doctor_id, full_name, date_of_birth, gender, phone, status, medical_notes)
  values
    (uuid_generate_v4(), v_doctor_id, 'John Smith',     '1985-03-15', 'male',   '+1-555-0201', 'active', 'Type 2 Diabetes, well-controlled on metformin'),
    (uuid_generate_v4(), v_doctor_id, 'Maria Garcia',   '1972-09-22', 'female', '+1-555-0202', 'active', 'Pre-diabetic, lifestyle intervention'),
    (uuid_generate_v4(), v_doctor_id, 'Robert Chen',    '1990-11-08', 'male',   '+1-555-0203', 'pending', 'New patient, awaiting activation')
  returning id into v_patient1_id;

  -- Get the patient IDs
  select id into v_patient1_id from patients where full_name = 'John Smith';
  select id into v_patient2_id from patients where full_name = 'Maria Garcia';
  select id into v_patient3_id from patients where full_name = 'Robert Chen';

  -- ============================================================
  -- Create sample measurements for active patients
  -- ============================================================

  -- John Smith's glucose readings (past week)
  insert into measurements (patient_id, type, value_primary, unit, measured_at, source, notes)
  values
    (v_patient1_id, 'glucose', 95,  'mg/dL', now() - interval '6 days' + interval '7 hours',  'device', 'Fasting'),
    (v_patient1_id, 'glucose', 142, 'mg/dL', now() - interval '6 days' + interval '13 hours', 'device', 'Post-lunch'),
    (v_patient1_id, 'glucose', 88,  'mg/dL', now() - interval '5 days' + interval '7 hours',  'device', 'Fasting'),
    (v_patient1_id, 'glucose', 156, 'mg/dL', now() - interval '5 days' + interval '13 hours', 'device', 'Post-lunch'),
    (v_patient1_id, 'glucose', 102, 'mg/dL', now() - interval '4 days' + interval '7 hours',  'device', 'Fasting'),
    (v_patient1_id, 'glucose', 168, 'mg/dL', now() - interval '4 days' + interval '13 hours', 'device', 'Post-lunch - high carb meal'),
    (v_patient1_id, 'glucose', 91,  'mg/dL', now() - interval '3 days' + interval '7 hours',  'device', 'Fasting'),
    (v_patient1_id, 'glucose', 135, 'mg/dL', now() - interval '3 days' + interval '13 hours', 'device', 'Post-lunch'),
    (v_patient1_id, 'glucose', 98,  'mg/dL', now() - interval '2 days' + interval '7 hours',  'device', 'Fasting'),
    (v_patient1_id, 'glucose', 148, 'mg/dL', now() - interval '2 days' + interval '13 hours', 'device', 'Post-lunch'),
    (v_patient1_id, 'glucose', 86,  'mg/dL', now() - interval '1 day'  + interval '7 hours',  'device', 'Fasting'),
    (v_patient1_id, 'glucose', 138, 'mg/dL', now() - interval '1 day'  + interval '13 hours', 'device', 'Post-lunch'),
    (v_patient1_id, 'glucose', 94,  'mg/dL', now() - interval '1 hour',                       'device', 'Fasting');

  -- John Smith's blood pressure readings
  insert into measurements (patient_id, type, value_primary, value_secondary, unit, measured_at, source)
  values
    (v_patient1_id, 'blood_pressure', 128, 82, 'mmHg', now() - interval '6 days', 'manual'),
    (v_patient1_id, 'blood_pressure', 132, 85, 'mmHg', now() - interval '4 days', 'manual'),
    (v_patient1_id, 'blood_pressure', 125, 80, 'mmHg', now() - interval '2 days', 'manual'),
    (v_patient1_id, 'blood_pressure', 130, 84, 'mmHg', now() - interval '1 hour', 'manual');

  -- Maria Garcia's glucose readings
  insert into measurements (patient_id, type, value_primary, unit, measured_at, source, notes)
  values
    (v_patient2_id, 'glucose', 108, 'mg/dL', now() - interval '5 days' + interval '7 hours',  'device', 'Fasting'),
    (v_patient2_id, 'glucose', 135, 'mg/dL', now() - interval '5 days' + interval '13 hours', 'device', 'Post-lunch'),
    (v_patient2_id, 'glucose', 112, 'mg/dL', now() - interval '3 days' + interval '7 hours',  'device', 'Fasting'),
    (v_patient2_id, 'glucose', 128, 'mg/dL', now() - interval '3 days' + interval '13 hours', 'device', 'Post-lunch'),
    (v_patient2_id, 'glucose', 105, 'mg/dL', now() - interval '1 day'  + interval '7 hours',  'device', 'Fasting'),
    (v_patient2_id, 'glucose', 142, 'mg/dL', now() - interval '1 day'  + interval '13 hours', 'device', 'Post-lunch');

  -- ============================================================
  -- Create sample daily logs
  -- ============================================================
  insert into daily_logs (patient_id, log_date, log_type, title, description, metadata)
  values
    (v_patient1_id, current_date - 2, 'food', 'Breakfast', 'Oatmeal with berries', '{"calories": 350, "carbs_g": 45}'),
    (v_patient1_id, current_date - 2, 'food', 'Lunch', 'Grilled chicken salad', '{"calories": 450, "carbs_g": 15}'),
    (v_patient1_id, current_date - 2, 'exercise', 'Morning walk', '30 minute walk around the neighborhood', '{"duration_min": 30, "type": "walking"}'),
    (v_patient1_id, current_date - 1, 'medication', 'Metformin', 'Took morning dose', '{"dose": "500mg"}'),
    (v_patient1_id, current_date - 1, 'food', 'Breakfast', 'Eggs and toast', '{"calories": 400, "carbs_g": 30}'),
    (v_patient1_id, current_date,     'sleep', 'Night sleep', 'Good quality sleep', '{"duration_hours": 7.5, "quality": "good"}'),
    (v_patient2_id, current_date - 1, 'exercise', 'Yoga session', 'Online yoga class', '{"duration_min": 45, "type": "yoga"}'),
    (v_patient2_id, current_date,     'food', 'Breakfast', 'Smoothie bowl', '{"calories": 380, "carbs_g": 52}');

  -- ============================================================
  -- Create sample risk alerts
  -- ============================================================
  insert into risk_alerts (patient_id, doctor_id, severity, title, description, status)
  values
    (v_patient1_id, v_doctor_id, 'medium', 'Elevated post-meal glucose', 'Post-lunch glucose of 168 mg/dL exceeds warning threshold of 140 mg/dL', 'acknowledged'),
    (v_patient1_id, v_doctor_id, 'low', 'Slightly elevated glucose trend', 'Average post-meal glucose trending upward over past 3 days', 'new');

  -- ============================================================
  -- Create pending invite for new patient
  -- ============================================================
  insert into patient_invites (patient_id, doctor_id, token, status)
  values
    (v_patient3_id, v_doctor_id, 'test_invite_token_abc123def456', 'pending');

end $$;
