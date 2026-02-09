/**
 * Patient Onboarding Service
 * Handles saving and loading comprehensive patient onboarding data
 */

import { supabase } from '../lib/supabase';
import type {
  PatientOnboardingData,
  PhysicalData,
  HabitsData,
  GoalsData,
  MedicalHistoryData,
  MedicationScheduleEntry,
  ChronicDiseaseType,
  LabInfoData,
  NotificationPreferenceEntry,
  MedicationClass,
} from '../types/onboarding.types';

// ============================================================
// Main Service
// ============================================================

export const onboardingService = {
  /**
   * Find an existing patient by national ID for the current doctor
   */
  async findPatientByNationalId(nationalId: string): Promise<{
    data: { patient_id: string; full_name: string } | null;
    error: Error | null;
  }> {
    try {
      const { data: { user }, error: authError } = await supabase.auth.getUser();
      if (authError || !user) {
        return { data: null, error: new Error('Not authenticated') };
      }

      const { data: patient, error } = await supabase
        .from('patients')
        .select('id, full_name')
        .eq('doctor_id', user.id)
        .eq('national_id', nationalId)
        .maybeSingle();

      if (error) {
        return { data: null, error };
      }

      if (!patient) {
        return { data: null, error: null };
      }

      return {
        data: { patient_id: patient.id, full_name: patient.full_name },
        error: null,
      };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  },

  /**
   * Create a new patient with all onboarding data
   */
  async createPatientWithOnboarding(data: PatientOnboardingData): Promise<{
    data: { patient_id: string; qr_data: string } | null;
    error: Error | null;
  }> {
    try {
      // Get current user (doctor)
      const { data: { user }, error: authError } = await supabase.auth.getUser();
      if (authError || !user) {
        return { data: null, error: new Error('Not authenticated') };
      }

      // 1. Create the patient record
      const { data: patient, error: patientError } = await supabase
        .from('patients')
        .insert({
          doctor_id: user.id,
          full_name: data.basicInfo.full_name,
          national_id: data.basicInfo.national_id,
          gender: data.basicInfo.gender,
          date_of_birth: data.basicInfo.date_of_birth || null,
          phone: data.basicInfo.phone,
          emergency_contact_phone: data.basicInfo.emergency_contact_phone,
          emergency_contact_email: data.basicInfo.emergency_contact_email,
          relative_name: data.basicInfo.relative_name,
          relative_phone: data.basicInfo.relative_phone,
          relative_email: data.basicInfo.relative_email,
          status: 'pending',
        })
        .select()
        .single();

      if (patientError || !patient) {
        return { data: null, error: patientError || new Error('Failed to create patient') };
      }

      const patientId = patient.id;

      // 2. Create patient invite token
      const token = crypto.randomUUID() + crypto.randomUUID();
      const expiresAt = new Date();
      expiresAt.setDate(expiresAt.getDate() + 7);

      const { error: inviteError } = await supabase
        .from('patient_invites')
        .insert({
          patient_id: patientId,
          doctor_id: user.id,
          token,
          expires_at: expiresAt.toISOString(),
        });

      if (inviteError) {
        console.error('Error creating invite:', inviteError);
      }

      // 3. Save all onboarding data in parallel
      await Promise.all([
        this.savePhysicalData(patientId, data.physical),
        this.saveHabits(patientId, data.habits),
        this.saveGoals(patientId, data.goals),
        this.saveMedicalHistory(patientId, data.medicalHistory),
        this.saveChronicDiseases(patientId, data.chronicDiseases.diseases, data.chronicDiseases.other_details),
        this.saveLabInfo(patientId, data.labInfo),
        this.saveNotificationPreferences(patientId, data.notificationPreferences.preferences),
        data.medicalHistory.medication_type === 'insulin' && data.insulinSchedule
          ? this.saveMedicationSchedules(patientId, data.insulinSchedule.schedules, 'insulin')
          : Promise.resolve(),
        data.medicalHistory.medication_type === 'oral_hypoglycemic' && data.oralMedicationSchedule
          ? this.saveMedicationSchedules(patientId, data.oralMedicationSchedule.schedules, 'oral_hypoglycemic')
          : Promise.resolve(),
      ]);

      return {
        data: { patient_id: patientId, qr_data: token },
        error: null,
      };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  },

  /**
   * Load complete onboarding data for a patient
   */
  async getOnboardingData(patientId: string): Promise<{
    data: PatientOnboardingData | null;
    error: Error | null;
  }> {
    try {
      // Fetch all data in parallel
      const [
        patientResult,
        physicalResult,
        habitsResult,
        goalsResult,
        medicalHistoryResult,
        medicationSchedulesResult,
        chronicDiseasesResult,
        labInfoResult,
        notificationPrefsResult,
      ] = await Promise.all([
        supabase.from('patients').select('*').eq('id', patientId).single(),
        supabase.from('patient_physical_data').select('*').eq('patient_id', patientId).single(),
        supabase.from('patient_habits').select('*').eq('patient_id', patientId).single(),
        supabase.from('patient_goals').select('*').eq('patient_id', patientId).single(),
        supabase.from('patient_medical_history').select('*').eq('patient_id', patientId).single(),
        supabase.from('patient_medication_schedules').select('*').eq('patient_id', patientId),
        supabase.from('patient_chronic_diseases').select('*').eq('patient_id', patientId),
        supabase.from('patient_lab_info').select('*').eq('patient_id', patientId).single(),
        supabase.from('patient_notification_preferences').select('*').eq('patient_id', patientId),
      ]);

      const patient = patientResult.data;
      if (!patient) {
        return { data: null, error: new Error('Patient not found') };
      }

      // Build the onboarding data object
      const onboardingData: PatientOnboardingData = {
        basicInfo: {
          full_name: patient.full_name,
          national_id: patient.national_id,
          gender: patient.gender,
          date_of_birth: patient.date_of_birth,
          phone: patient.phone,
          emergency_contact_phone: patient.emergency_contact_phone,
          emergency_contact_email: patient.emergency_contact_email,
          relative_name: patient.relative_name,
          relative_phone: patient.relative_phone,
          relative_email: patient.relative_email,
        },
        notificationPreferences: {
          preferences: (notificationPrefsResult.data || []).map((p: any) => ({
            trigger: p.trigger,
            channel: p.channel,
            enabled: p.enabled,
          })),
        },
        physical: physicalResult.data
          ? {
              height_cm: physicalResult.data.height_cm,
              weight_kg: physicalResult.data.weight_kg,
            }
          : {},
        habits: habitsResult.data?.habits || {},
        goals: goalsResult.data?.goals || {},
        medicalHistory: medicalHistoryResult.data
          ? {
              has_diabetes: medicalHistoryResult.data.has_diabetes,
              diabetes_type: medicalHistoryResult.data.diabetes_type,
              diagnosis_date: medicalHistoryResult.data.diagnosis_date,
              medication_type: medicalHistoryResult.data.medication_type,
            }
          : { has_diabetes: false, medication_type: 'none' },
        chronicDiseases: {
          diseases: (chronicDiseasesResult.data || []).map((d: any) => d.disease_type),
          other_details: chronicDiseasesResult.data?.find((d: any) => d.disease_type === 'other')?.other_details,
        },
        labInfo: labInfoResult.data
          ? {
              hba1c_percentage: labInfoResult.data.hba1c_percentage,
              hba1c_test_date: labInfoResult.data.hba1c_test_date,
              target_glucose_min: labInfoResult.data.target_glucose_min,
              target_glucose_max: labInfoResult.data.target_glucose_max,
            }
          : {},
      };

      // Add medication schedules based on medication type
      const schedules = medicationSchedulesResult.data || [];
      const insulinSchedules = schedules.filter((s: any) => s.medication_class === 'insulin');
      const oralSchedules = schedules.filter((s: any) => s.medication_class === 'oral_hypoglycemic');

      if (insulinSchedules.length > 0) {
        onboardingData.insulinSchedule = {
          schedules: insulinSchedules.map((s: any) => ({
            time_period: s.time_period,
            insulin_type: s.insulin_type,
            dose: s.dose,
            dose_unit: s.dose_unit,
            scheduled_time: s.scheduled_time,
            is_active: s.is_active,
          })),
        };
      }

      if (oralSchedules.length > 0) {
        onboardingData.oralMedicationSchedule = {
          schedules: oralSchedules.map((s: any) => ({
            time_period: s.time_period,
            medication_name: s.medication_name,
            dose: s.dose,
            dose_unit: s.dose_unit,
            scheduled_time: s.scheduled_time,
            is_active: s.is_active,
          })),
        };
      }

      return { data: onboardingData, error: null };
    } catch (error) {
      return { data: null, error: error as Error };
    }
  },

  // ============================================================
  // Individual Section Save Methods
  // ============================================================

  async savePhysicalData(patientId: string, data: PhysicalData): Promise<void> {
    if (!data.height_cm && !data.weight_kg) return;

    await supabase
      .from('patient_physical_data')
      .upsert({
        patient_id: patientId,
        height_cm: data.height_cm,
        weight_kg: data.weight_kg,
      }, { onConflict: 'patient_id' });
  },

  async saveHabits(patientId: string, data: HabitsData): Promise<void> {
    if (Object.keys(data).length === 0) return;

    await supabase
      .from('patient_habits')
      .upsert({
        patient_id: patientId,
        habits: data,
      }, { onConflict: 'patient_id' });
  },

  async saveGoals(patientId: string, data: GoalsData): Promise<void> {
    if (Object.keys(data).length === 0) return;

    await supabase
      .from('patient_goals')
      .upsert({
        patient_id: patientId,
        goals: data,
      }, { onConflict: 'patient_id' });
  },

  async saveMedicalHistory(patientId: string, data: MedicalHistoryData): Promise<void> {
    await supabase
      .from('patient_medical_history')
      .upsert({
        patient_id: patientId,
        has_diabetes: data.has_diabetes,
        diabetes_type: data.diabetes_type,
        diagnosis_date: data.diagnosis_date || null,
        medication_type: data.medication_type,
      }, { onConflict: 'patient_id' });
  },

  async saveMedicationSchedules(
    patientId: string,
    schedules: MedicationScheduleEntry[],
    medicationClass: MedicationClass
  ): Promise<void> {
    if (schedules.length === 0) return;

    // Delete existing schedules for this class
    await supabase
      .from('patient_medication_schedules')
      .delete()
      .eq('patient_id', patientId)
      .eq('medication_class', medicationClass);

    // Insert new schedules
    const records = schedules
      .filter((s) => s.is_active !== false)
      .map((s) => ({
        patient_id: patientId,
        medication_class: medicationClass,
        time_period: s.time_period,
        insulin_type: s.insulin_type,
        medication_name: s.medication_name,
        dose: s.dose,
        dose_unit: s.dose_unit || 'IU',
        scheduled_time: s.scheduled_time,
        is_active: s.is_active ?? true,
      }));

    if (records.length > 0) {
      await supabase.from('patient_medication_schedules').insert(records);
    }
  },

  async saveChronicDiseases(
    patientId: string,
    diseases: ChronicDiseaseType[],
    otherDetails?: string
  ): Promise<void> {
    // Delete existing diseases
    await supabase
      .from('patient_chronic_diseases')
      .delete()
      .eq('patient_id', patientId);

    if (diseases.length === 0) return;

    // Insert new diseases
    const records = diseases.map((disease) => ({
      patient_id: patientId,
      disease_type: disease,
      other_details: disease === 'other' ? otherDetails : null,
    }));

    await supabase.from('patient_chronic_diseases').insert(records);
  },

  async saveLabInfo(patientId: string, data: LabInfoData): Promise<void> {
    if (
      !data.hba1c_percentage &&
      !data.hba1c_test_date &&
      !data.target_glucose_min &&
      !data.target_glucose_max
    ) {
      return;
    }

    await supabase
      .from('patient_lab_info')
      .upsert({
        patient_id: patientId,
        hba1c_percentage: data.hba1c_percentage,
        hba1c_test_date: data.hba1c_test_date || null,
        target_glucose_min: data.target_glucose_min,
        target_glucose_max: data.target_glucose_max,
      }, { onConflict: 'patient_id' });
  },

  async saveNotificationPreferences(
    patientId: string,
    preferences: NotificationPreferenceEntry[]
  ): Promise<void> {
    // Delete existing preferences
    await supabase
      .from('patient_notification_preferences')
      .delete()
      .eq('patient_id', patientId);

    if (preferences.length === 0) return;

    // Insert new preferences (only enabled ones)
    const records = preferences
      .filter((p) => p.enabled)
      .map((p) => ({
        patient_id: patientId,
        trigger: p.trigger,
        channel: p.channel,
        enabled: true,
      }));

    if (records.length > 0) {
      await supabase.from('patient_notification_preferences').insert(records);
    }
  },
};
