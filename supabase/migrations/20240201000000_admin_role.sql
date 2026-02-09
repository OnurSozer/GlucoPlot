-- ============================================================
-- GlucoPlot: Admin Role Schema
-- Creates admins table, helper functions, and RLS policies
-- ============================================================

-- ============================================================
-- Admins Table
-- Linked 1:1 to auth.users (same pattern as doctors)
-- ============================================================
create table admins (
  id         uuid primary key references auth.users (id) on delete cascade,
  full_name  text        not null,
  email      text        not null unique,
  phone      text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table  admins    is 'Admin profiles linked to Supabase Auth users.';
comment on column admins.id is 'Same UUID as auth.users.id.';

-- Trigger for updated_at
create trigger trg_admins_updated_at
  before update on admins
  for each row execute function set_updated_at();

-- ============================================================
-- Helper function to check if current user is admin
-- ============================================================
create or replace function is_admin()
returns boolean as $$
begin
  return exists (select 1 from admins where id = auth.uid());
end;
$$ language plpgsql security definer stable;

-- ============================================================
-- Enable RLS on admins table
-- ============================================================
alter table admins enable row level security;

-- Admins can view their own profile
create policy "Admins can view own profile"
  on admins for select
  using (id = auth.uid());

-- Admins can update their own profile
create policy "Admins can update own profile"
  on admins for update
  using (id = auth.uid());

-- ============================================================
-- Admin policies for viewing doctors (read-only access)
-- ============================================================
create policy "Admins can view all doctors"
  on doctors for select
  using (is_admin());

-- Admins can update doctors
create policy "Admins can update doctors"
  on doctors for update
  using (is_admin());

-- Admins can delete doctors
create policy "Admins can delete doctors"
  on doctors for delete
  using (is_admin());

-- ============================================================
-- Admin policies for viewing patients (read-only access)
-- ============================================================
create policy "Admins can view all patients"
  on patients for select
  using (is_admin());

-- ============================================================
-- Admin policies for viewing measurements (read-only)
-- ============================================================
create policy "Admins can view all measurements"
  on measurements for select
  using (is_admin());

-- ============================================================
-- Admin policies for viewing daily logs (read-only)
-- ============================================================
create policy "Admins can view all daily_logs"
  on daily_logs for select
  using (is_admin());

-- ============================================================
-- Admin policies for viewing risk alerts (read-only)
-- ============================================================
create policy "Admins can view all risk_alerts"
  on risk_alerts for select
  using (is_admin());

-- ============================================================
-- Function to create a doctor with auth user
-- Uses SECURITY DEFINER to access auth.users
-- ============================================================
create or replace function create_doctor_with_auth(
  p_email text,
  p_password text,
  p_full_name text,
  p_phone text default null,
  p_specialty text default null
)
returns json as $$
declare
  v_user_id uuid;
  v_doctor record;
begin
  -- Check if caller is admin
  if not is_admin() then
    raise exception 'Only admins can create doctors';
  end if;

  -- Check if email already exists
  if exists (select 1 from auth.users where email = p_email) then
    return json_build_object(
      'success', false,
      'error', 'Email already exists'
    );
  end if;

  -- Generate a new UUID for the user
  v_user_id := gen_random_uuid();

  -- Create auth user
  insert into auth.users (
    id,
    instance_id,
    email,
    encrypted_password,
    email_confirmed_at,
    raw_app_meta_data,
    raw_user_meta_data,
    aud,
    role,
    created_at,
    updated_at,
    confirmation_token,
    recovery_token
  ) values (
    v_user_id,
    '00000000-0000-0000-0000-000000000000',
    p_email,
    crypt(p_password, gen_salt('bf')),
    now(),
    '{"provider":"email","providers":["email"]}',
    jsonb_build_object('full_name', p_full_name),
    'authenticated',
    'authenticated',
    now(),
    now(),
    '',
    ''
  );

  -- Create identity record (required for Supabase Auth to work)
  insert into auth.identities (
    id,
    user_id,
    identity_data,
    provider,
    provider_id,
    last_sign_in_at,
    created_at,
    updated_at
  ) values (
    gen_random_uuid(),
    v_user_id,
    jsonb_build_object(
      'sub', v_user_id::text,
      'email', p_email,
      'email_verified', true,
      'provider', 'email'
    ),
    'email',
    v_user_id::text,
    now(),
    now(),
    now()
  );

  -- Create doctor profile
  insert into doctors (id, full_name, email, phone, specialty)
  values (v_user_id, p_full_name, p_email, p_phone, p_specialty)
  returning * into v_doctor;

  return json_build_object(
    'success', true,
    'doctor_id', v_doctor.id,
    'email', v_doctor.email,
    'full_name', v_doctor.full_name
  );
exception
  when others then
    return json_build_object(
      'success', false,
      'error', sqlerrm
    );
end;
$$ language plpgsql security definer;

-- ============================================================
-- Function to update a doctor's profile (admin use)
-- ============================================================
create or replace function update_doctor_profile(
  p_doctor_id uuid,
  p_full_name text default null,
  p_phone text default null,
  p_specialty text default null
)
returns json as $$
declare
  v_doctor record;
begin
  -- Check if caller is admin
  if not is_admin() then
    raise exception 'Only admins can update doctors';
  end if;

  -- Update doctor profile
  update doctors
  set
    full_name = coalesce(p_full_name, full_name),
    phone = coalesce(p_phone, phone),
    specialty = coalesce(p_specialty, specialty),
    updated_at = now()
  where id = p_doctor_id
  returning * into v_doctor;

  if v_doctor is null then
    return json_build_object(
      'success', false,
      'error', 'Doctor not found'
    );
  end if;

  return json_build_object(
    'success', true,
    'doctor', row_to_json(v_doctor)
  );
exception
  when others then
    return json_build_object(
      'success', false,
      'error', sqlerrm
    );
end;
$$ language plpgsql security definer;

-- ============================================================
-- Function to delete a doctor (and their auth user)
-- ============================================================
create or replace function delete_doctor(p_doctor_id uuid)
returns json as $$
begin
  -- Check if caller is admin
  if not is_admin() then
    raise exception 'Only admins can delete doctors';
  end if;

  -- Check if doctor exists
  if not exists (select 1 from doctors where id = p_doctor_id) then
    return json_build_object(
      'success', false,
      'error', 'Doctor not found'
    );
  end if;

  -- Delete from doctors table (patients will cascade due to FK)
  delete from doctors where id = p_doctor_id;

  -- Delete from auth.users
  delete from auth.users where id = p_doctor_id;

  return json_build_object('success', true);
exception
  when others then
    return json_build_object(
      'success', false,
      'error', sqlerrm
    );
end;
$$ language plpgsql security definer;

-- ============================================================
-- Grant execute permissions on functions
-- ============================================================
grant execute on function is_admin() to authenticated;
grant execute on function create_doctor_with_auth(text, text, text, text, text) to authenticated;
grant execute on function update_doctor_profile(uuid, text, text, text) to authenticated;
grant execute on function delete_doctor(uuid) to authenticated;

-- ============================================================
-- MANUAL: Create first admin (run after migration)
-- ============================================================
--
-- Run these commands in Supabase SQL Editor to create first admin:
--
-- DO $$
-- DECLARE
--   v_user_id uuid := gen_random_uuid();
-- BEGIN
--   INSERT INTO auth.users (
--     id, instance_id, email, encrypted_password, email_confirmed_at,
--     raw_app_meta_data, raw_user_meta_data, aud, role, created_at, updated_at,
--     confirmation_token, recovery_token
--   ) VALUES (
--     v_user_id,
--     '00000000-0000-0000-0000-000000000000',
--     'admin@glucoplot.com',
--     crypt('YourSecurePassword123!', gen_salt('bf')),
--     now(),
--     '{"provider":"email","providers":["email"]}',
--     '{"full_name":"Admin User"}',
--     'authenticated',
--     'authenticated',
--     now(),
--     now(),
--     '',
--     ''
--   );
--
--   INSERT INTO auth.identities (id, user_id, identity_data, provider, provider_id, last_sign_in_at, created_at, updated_at)
--   VALUES (
--     gen_random_uuid(),
--     v_user_id,
--     jsonb_build_object('sub', v_user_id::text, 'email', 'admin@glucoplot.com', 'email_verified', true, 'provider', 'email'),
--     'email',
--     v_user_id::text,
--     now(),
--     now(),
--     now()
--   );
--
--   INSERT INTO admins (id, full_name, email)
--   VALUES (v_user_id, 'Admin User', 'admin@glucoplot.com');
-- END $$;
