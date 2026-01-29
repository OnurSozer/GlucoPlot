-- ============================================================
-- GlucoPlot: Row Level Security Policies
-- ============================================================

-- ============================================================
-- Helper functions to determine user role
-- ============================================================
create or replace function is_doctor()
returns boolean as $$
begin
  return exists (select 1 from doctors where id = auth.uid());
end;
$$ language plpgsql security definer stable;

create or replace function is_patient()
returns boolean as $$
begin
  return exists (select 1 from patients where auth_user_id = auth.uid());
end;
$$ language plpgsql security definer stable;

create or replace function get_patient_id()
returns uuid as $$
begin
  return (select id from patients where auth_user_id = auth.uid() limit 1);
end;
$$ language plpgsql security definer stable;

-- ============================================================
-- Enable RLS on all tables
-- ============================================================
alter table doctors                enable row level security;
alter table patients               enable row level security;
alter table patient_invites        enable row level security;
alter table measurements           enable row level security;
alter table daily_logs             enable row level security;
alter table risk_alerts            enable row level security;
alter table measurement_thresholds enable row level security;

-- ============================================================
-- DOCTORS table policies
-- ============================================================

-- Doctors can read their own profile
create policy "Doctors can view own profile"
  on doctors for select
  using (id = auth.uid());

-- Doctors can update their own profile
create policy "Doctors can update own profile"
  on doctors for update
  using (id = auth.uid());

-- ============================================================
-- PATIENTS table policies
-- ============================================================

-- Doctors can view all patients they created
create policy "Doctors can view their patients"
  on patients for select
  using (doctor_id = auth.uid());

-- Doctors can create patients
create policy "Doctors can create patients"
  on patients for insert
  with check (doctor_id = auth.uid());

-- Doctors can update their patients
create policy "Doctors can update their patients"
  on patients for update
  using (doctor_id = auth.uid());

-- Patients can view their own record
create policy "Patients can view own record"
  on patients for select
  using (auth_user_id = auth.uid());

-- ============================================================
-- PATIENT_INVITES table policies
-- ============================================================

-- Doctors can view invites they created
create policy "Doctors can view their invites"
  on patient_invites for select
  using (doctor_id = auth.uid());

-- Doctors can create invites for their patients
create policy "Doctors can create invites"
  on patient_invites for insert
  with check (doctor_id = auth.uid());

-- ============================================================
-- MEASUREMENTS table policies
-- ============================================================

-- Doctors can view measurements for their patients
create policy "Doctors can view patient measurements"
  on measurements for select
  using (
    exists (
      select 1 from patients
      where patients.id = measurements.patient_id
        and patients.doctor_id = auth.uid()
    )
  );

-- Patients can view their own measurements
create policy "Patients can view own measurements"
  on measurements for select
  using (patient_id = get_patient_id());

-- Patients can insert their own measurements
create policy "Patients can insert own measurements"
  on measurements for insert
  with check (patient_id = get_patient_id());

-- ============================================================
-- DAILY_LOGS table policies
-- ============================================================

-- Doctors can view logs for their patients
create policy "Doctors can view patient logs"
  on daily_logs for select
  using (
    exists (
      select 1 from patients
      where patients.id = daily_logs.patient_id
        and patients.doctor_id = auth.uid()
    )
  );

-- Patients can view their own logs
create policy "Patients can view own logs"
  on daily_logs for select
  using (patient_id = get_patient_id());

-- Patients can insert their own logs
create policy "Patients can insert own logs"
  on daily_logs for insert
  with check (patient_id = get_patient_id());

-- Patients can update their own logs
create policy "Patients can update own logs"
  on daily_logs for update
  using (patient_id = get_patient_id());

-- Patients can delete their own logs
create policy "Patients can delete own logs"
  on daily_logs for delete
  using (patient_id = get_patient_id());

-- ============================================================
-- RISK_ALERTS table policies
-- ============================================================

-- Doctors can view alerts for their patients
create policy "Doctors can view their alerts"
  on risk_alerts for select
  using (doctor_id = auth.uid());

-- Doctors can update alert status (acknowledge/resolve)
create policy "Doctors can update alert status"
  on risk_alerts for update
  using (doctor_id = auth.uid());

-- Patients can view their own alerts
create policy "Patients can view own alerts"
  on risk_alerts for select
  using (patient_id = get_patient_id());

-- ============================================================
-- MEASUREMENT_THRESHOLDS table policies
-- ============================================================

-- Doctors can view their thresholds
create policy "Doctors can view own thresholds"
  on measurement_thresholds for select
  using (doctor_id = auth.uid());

-- Doctors can manage their thresholds
create policy "Doctors can insert thresholds"
  on measurement_thresholds for insert
  with check (doctor_id = auth.uid());

create policy "Doctors can update thresholds"
  on measurement_thresholds for update
  using (doctor_id = auth.uid());

create policy "Doctors can delete thresholds"
  on measurement_thresholds for delete
  using (doctor_id = auth.uid());
