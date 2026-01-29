-- ============================================================
-- GlucoPlot: Measurements & Daily Logs
-- ============================================================

-- ============================================================
-- Custom types
-- ============================================================
create type measurement_type   as enum ('glucose', 'blood_pressure', 'heart_rate', 'weight', 'temperature', 'spo2');
create type measurement_source as enum ('device', 'manual');
create type log_type           as enum ('food', 'sleep', 'exercise', 'medication', 'symptom', 'note');

-- ============================================================
-- Measurements
-- Captures readings from the GlucoPlot device or manual entry.
-- ============================================================
create table measurements (
  id              uuid               primary key default uuid_generate_v4(),
  patient_id      uuid               not null references patients (id) on delete cascade,
  type            measurement_type   not null,
  value_primary   numeric            not null,
  value_secondary numeric,
  unit            text               not null,
  measured_at     timestamptz        not null default now(),
  source          measurement_source not null default 'manual',
  notes           text,
  created_at      timestamptz        not null default now()
);

comment on table  measurements                 is 'Patient health measurements.';
comment on column measurements.value_primary   is 'Main value: glucose mg/dL, systolic mmHg, bpm, kg, C, %.';
comment on column measurements.value_secondary is 'Secondary value when needed: diastolic BP.';
comment on column measurements.unit            is 'Display unit string, e.g. mg/dL, mmHg, bpm.';
comment on column measurements.source          is 'device = GlucoPlot hardware, manual = patient entry.';

create index idx_measurements_patient     on measurements (patient_id);
create index idx_measurements_type        on measurements (patient_id, type);
create index idx_measurements_measured_at on measurements (patient_id, measured_at desc);

-- ============================================================
-- Daily Logs
-- Patient-entered events: food, sleep, exercise, medication, symptoms.
-- ============================================================
create table daily_logs (
  id          uuid        primary key default uuid_generate_v4(),
  patient_id  uuid        not null references patients (id) on delete cascade,
  log_date    date        not null default current_date,
  log_type    log_type    not null,
  title       text        not null,
  description text,
  metadata    jsonb,
  logged_at   timestamptz not null default now(),
  created_at  timestamptz not null default now()
);

comment on table  daily_logs          is 'Patient daily event logs (food, sleep, exercise, etc.).';
comment on column daily_logs.metadata is 'Flexible JSON: { calories: 500, duration_min: 30, dose: "500mg" }.';

create index idx_logs_patient  on daily_logs (patient_id);
create index idx_logs_date     on daily_logs (patient_id, log_date desc);
create index idx_logs_type     on daily_logs (patient_id, log_type);
