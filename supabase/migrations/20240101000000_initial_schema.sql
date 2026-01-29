-- ============================================================
-- GlucoPlot: Initial Schema
-- Creates core tables: doctors, patients, patient_invites
-- ============================================================

-- Enable required extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- ============================================================
-- Custom types
-- ============================================================
create type patient_status as enum ('pending', 'active', 'inactive');
create type invite_status  as enum ('pending', 'redeemed', 'expired');

-- ============================================================
-- Doctors
-- Linked 1:1 to auth.users (email/password sign-in).
-- ============================================================
create table doctors (
  id         uuid primary key references auth.users (id) on delete cascade,
  full_name  text        not null,
  email      text        not null unique,
  phone      text,
  specialty  text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table  doctors            is 'Doctor profiles linked to Supabase Auth users.';
comment on column doctors.id         is 'Same UUID as auth.users.id.';
comment on column doctors.specialty  is 'Medical specialty, e.g. Endocrinology.';

-- ============================================================
-- Patients
-- Created by a doctor. auth_user_id is set when the patient
-- redeems the QR invite and completes OTP activation.
-- ============================================================
create table patients (
  id            uuid           primary key default uuid_generate_v4(),
  doctor_id     uuid           not null references doctors (id) on delete cascade,
  auth_user_id  uuid           unique references auth.users (id) on delete set null,
  full_name     text           not null,
  date_of_birth date,
  gender        text,
  phone         text,
  medical_notes text,
  status        patient_status not null default 'pending',
  created_at    timestamptz    not null default now(),
  updated_at    timestamptz    not null default now()
);

comment on table  patients              is 'Patient records created by doctors.';
comment on column patients.auth_user_id is 'Set after the patient activates via QR + OTP.';
comment on column patients.status       is 'pending = awaiting activation, active = activated, inactive = deactivated.';

create index idx_patients_doctor    on patients (doctor_id);
create index idx_patients_auth_user on patients (auth_user_id) where auth_user_id is not null;
create index idx_patients_status    on patients (status);

-- ============================================================
-- Patient Invites
-- QR token + OTP flow for patient onboarding.
-- ============================================================
create table patient_invites (
  id             uuid          primary key default uuid_generate_v4(),
  patient_id     uuid          not null references patients (id) on delete cascade,
  doctor_id      uuid          not null references doctors  (id) on delete cascade,
  token          text          not null unique default encode(gen_random_bytes(32), 'hex'),
  otp_code       text,
  otp_expires_at timestamptz,
  status         invite_status not null default 'pending',
  expires_at     timestamptz   not null default (now() + interval '7 days'),
  redeemed_at    timestamptz,
  created_at     timestamptz   not null default now()
);

comment on table  patient_invites       is 'QR invite tokens for patient activation.';
comment on column patient_invites.token is '64-char hex token encoded in the QR code.';

create index idx_invites_patient on patient_invites (patient_id);
create index idx_invites_token   on patient_invites (token);
create index idx_invites_status  on patient_invites (status);

-- ============================================================
-- Automatic updated_at trigger
-- ============================================================
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_doctors_updated_at
  before update on doctors
  for each row execute function set_updated_at();

create trigger trg_patients_updated_at
  before update on patients
  for each row execute function set_updated_at();
