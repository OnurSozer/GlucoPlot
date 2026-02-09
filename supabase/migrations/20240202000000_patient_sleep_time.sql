-- ============================================================
-- GlucoPlot: Patient Sleep Time Setting
-- Adds usual_sleep_time column for notifications and calculations
-- ============================================================

-- Add usual_sleep_time column to patients table
-- Stored as TIME, defaults to 23:00 (11 PM)
alter table patients
  add column usual_sleep_time time not null default '23:00:00';

comment on column patients.usual_sleep_time is 'Patient usual sleep time for notifications and calculations. Defaults to 11 PM.';

-- Create function to update patient sleep time
create or replace function update_patient_sleep_time(p_sleep_time time)
returns json as $$
declare
  v_patient_id uuid;
begin
  -- Get patient ID from auth user
  select id into v_patient_id
  from patients
  where auth_user_id = auth.uid();

  if v_patient_id is null then
    return json_build_object(
      'success', false,
      'error', 'Patient not found'
    );
  end if;

  -- Update sleep time
  update patients
  set usual_sleep_time = p_sleep_time,
      updated_at = now()
  where id = v_patient_id;

  return json_build_object(
    'success', true,
    'sleep_time', p_sleep_time::text
  );
exception
  when others then
    return json_build_object(
      'success', false,
      'error', sqlerrm
    );
end;
$$ language plpgsql security definer;

-- Grant execute permission
grant execute on function update_patient_sleep_time(time) to authenticated;
