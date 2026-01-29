-- ============================================================
-- GlucoPlot: Risk Alerts
-- Auto-generated when measurements breach clinical thresholds.
-- ============================================================

create type alert_severity as enum ('low', 'medium', 'high', 'critical');
create type alert_status   as enum ('new', 'acknowledged', 'resolved');

create table risk_alerts (
  id              uuid           primary key default uuid_generate_v4(),
  patient_id      uuid           not null references patients (id) on delete cascade,
  doctor_id       uuid           not null references doctors  (id) on delete cascade,
  measurement_id  uuid           references measurements (id) on delete set null,
  severity        alert_severity not null,
  title           text           not null,
  description     text,
  status          alert_status   not null default 'new',
  acknowledged_at timestamptz,
  resolved_at     timestamptz,
  created_at      timestamptz    not null default now()
);

comment on table  risk_alerts                is 'Alerts generated when patient measurements breach thresholds.';
comment on column risk_alerts.measurement_id is 'The measurement that triggered this alert (nullable for manual alerts).';

create index idx_alerts_patient on risk_alerts (patient_id);
create index idx_alerts_doctor  on risk_alerts (doctor_id);
create index idx_alerts_status  on risk_alerts (doctor_id, status);
create index idx_alerts_created on risk_alerts (doctor_id, created_at desc);

-- ============================================================
-- Measurement Thresholds (configurable per doctor)
-- Doctors can set custom thresholds for each measurement type.
-- ============================================================
create table measurement_thresholds (
  id               uuid             primary key default uuid_generate_v4(),
  doctor_id        uuid             not null references doctors (id) on delete cascade,
  measurement_type measurement_type not null,
  min_critical     numeric,
  min_warning      numeric,
  max_warning      numeric,
  max_critical     numeric,
  unit             text             not null,
  created_at       timestamptz      not null default now(),
  updated_at       timestamptz      not null default now(),

  unique (doctor_id, measurement_type)
);

comment on table  measurement_thresholds is 'Per-doctor configurable thresholds for measurement alerts.';

create trigger trg_thresholds_updated_at
  before update on measurement_thresholds
  for each row execute function set_updated_at();

-- ============================================================
-- Insert default thresholds (applied per doctor on creation)
-- These are standard clinical ranges.
-- ============================================================
-- Note: Default thresholds are inserted by the create-patient-v1
-- Edge Function when a doctor first signs up, or can be seeded.
