/**
 * Patient Onboarding Types
 * Comprehensive types for the multi-step patient onboarding form
 */

// ============================================================
// Enums matching database
// ============================================================

export type DiabetesType =
  | 'type1'
  | 'type2'
  | 'prediabetes'
  | 'gestational'
  | 'lada'
  | 'mody'
  | 'secondary'
  | 'chemically_induced';

export type MedicationClass = 'insulin' | 'oral_hypoglycemic' | 'none';

export type InsulinType =
  | 'none'
  | 'nph'
  | 'lente'
  | 'ultralente'
  | 'regular'
  | 'rapid'
  | 'long';

export type MedTimePeriod =
  | 'morning'
  | 'noon'
  | 'evening'
  | 'night'
  | 'other1'
  | 'other2';

export type ChronicDiseaseType =
  | 'hypertension'
  | 'cardiovascular'
  | 'heart_failure'
  | 'hyperlipidemia'
  | 'kidney_failure'
  | 'chronic_pain'
  | 'major_depression'
  | 'anxiety'
  | 'sleep_disorder'
  | 'physical_disability'
  | 'other';

export type NotificationTrigger =
  | 'hypoglycemia_below_40'
  | 'survey_not_submitted_12h'
  | 'glucose_not_measured_3h';

export type NotificationChannel =
  | 'doctor_sms'
  | 'doctor_email'
  | 'relative_sms'
  | 'relative_email';

export type GoalPriority =
  | 'very_important'
  | 'important'
  | 'secondary'
  | 'unimportant';

export type ExerciseFrequency = 'daily' | 'weekly' | 'rarely' | 'never';

export type ExerciseDuration = '0-15' | '15-30' | '30-60' | '60+';

// ============================================================
// Form Step Data Interfaces
// ============================================================

export interface BasicInfoData {
  full_name: string;
  national_id?: string;
  gender?: 'male' | 'female' | 'other';
  date_of_birth?: string;
  phone?: string;
  emergency_contact_phone?: string;
  emergency_contact_email?: string;
  relative_name?: string;
  relative_phone?: string;
  relative_email?: string;
  doctor_phone?: string;
  doctor_email?: string;
}

export interface NotificationPreferenceEntry {
  trigger: NotificationTrigger;
  channel: NotificationChannel;
  enabled: boolean;
}

export interface NotificationPreferencesData {
  preferences: NotificationPreferenceEntry[];
}

export interface PhysicalData {
  height_cm?: number;
  weight_kg?: number;
}

export interface HabitsData {
  healthy_eating?: number; // 1-10
  medication_adherence?: number; // 1-10
  disease_monitoring?: number; // 1-10
  activity_level?: number; // 1-10
  stress_level?: number; // 1-10
  hypoglycemic_attacks?: number; // 1-10
  salt_awareness?: number; // 1-10
  exercise_frequency?: ExerciseFrequency;
  exercise_duration?: ExerciseDuration;
}

export interface GoalsData {
  healthy_eating?: GoalPriority;
  regular_medication?: GoalPriority;
  checkups?: GoalPriority;
  regular_exercise?: GoalPriority;
  low_salt?: GoalPriority;
  stress_reduction?: GoalPriority;
}

export interface MedicalHistoryData {
  has_diabetes: boolean;
  diabetes_type?: DiabetesType;
  diagnosis_date?: string;
  medication_type: MedicationClass;
}

export interface MedicationScheduleEntry {
  time_period: MedTimePeriod;
  insulin_type?: InsulinType;
  medication_name?: string;
  dose?: number;
  dose_unit?: string;
  scheduled_time?: string;
  is_active?: boolean;
}

export interface MedicationScheduleData {
  schedules: MedicationScheduleEntry[];
}

export interface ChronicDiseasesData {
  diseases: ChronicDiseaseType[];
  other_details?: string;
}

export interface LabInfoData {
  hba1c_percentage?: number;
  hba1c_test_date?: string;
  target_glucose_min?: number;
  target_glucose_max?: number;
}

// ============================================================
// Complete Onboarding Form Data
// ============================================================

export interface PatientOnboardingData {
  basicInfo: BasicInfoData;
  notificationPreferences: NotificationPreferencesData;
  physical: PhysicalData;
  habits: HabitsData;
  goals: GoalsData;
  medicalHistory: MedicalHistoryData;
  insulinSchedule?: MedicationScheduleData;
  oralMedicationSchedule?: MedicationScheduleData;
  chronicDiseases: ChronicDiseasesData;
  labInfo: LabInfoData;
}

// ============================================================
// Wizard Configuration
// ============================================================

export type OnboardingStepId =
  | 'basic-info'
  | 'notifications'
  | 'physical'
  | 'habits'
  | 'goals'
  | 'medical-history'
  | 'insulin-schedule'
  | 'oral-medication'
  | 'chronic-diseases'
  | 'lab-info';

export interface WizardStep {
  id: OnboardingStepId;
  titleKey: string;
  isConditional?: boolean;
  condition?: (data: PatientOnboardingData) => boolean;
}

export const WIZARD_STEPS: WizardStep[] = [
  { id: 'basic-info', titleKey: 'onboarding:steps.basicInfo' },
  { id: 'notifications', titleKey: 'onboarding:steps.notifications' },
  { id: 'physical', titleKey: 'onboarding:steps.physical' },
  { id: 'habits', titleKey: 'onboarding:steps.habits' },
  { id: 'goals', titleKey: 'onboarding:steps.goals' },
  { id: 'medical-history', titleKey: 'onboarding:steps.medicalHistory' },
  {
    id: 'insulin-schedule',
    titleKey: 'onboarding:steps.insulinSchedule',
    isConditional: true,
    condition: (data) => data.medicalHistory.medication_type === 'insulin',
  },
  {
    id: 'oral-medication',
    titleKey: 'onboarding:steps.oralMedication',
    isConditional: true,
    condition: (data) => data.medicalHistory.medication_type === 'oral_hypoglycemic',
  },
  { id: 'chronic-diseases', titleKey: 'onboarding:steps.chronicDiseases' },
  { id: 'lab-info', titleKey: 'onboarding:steps.labInfo' },
];

// ============================================================
// Helper Functions
// ============================================================

export function getVisibleSteps(data: PatientOnboardingData): WizardStep[] {
  return WIZARD_STEPS.filter((step) => {
    if (!step.isConditional) return true;
    return step.condition ? step.condition(data) : true;
  });
}

export function calculateBMI(heightCm?: number, weightKg?: number): number | null {
  if (!heightCm || !weightKg || heightCm <= 0 || weightKg <= 0) return null;
  const heightM = heightCm / 100;
  return Math.round((weightKg / (heightM * heightM)) * 10) / 10;
}

export function getDefaultOnboardingData(): PatientOnboardingData {
  return {
    basicInfo: {
      full_name: '',
    },
    notificationPreferences: {
      preferences: [],
    },
    physical: {},
    habits: {},
    goals: {},
    medicalHistory: {
      has_diabetes: false,
      medication_type: 'none',
    },
    chronicDiseases: {
      diseases: [],
    },
    labInfo: {},
  };
}

// ============================================================
// Constants
// ============================================================

export const NOTIFICATION_TRIGGERS: NotificationTrigger[] = [
  'hypoglycemia_below_40',
  'survey_not_submitted_12h',
  'glucose_not_measured_3h',
];

export const NOTIFICATION_CHANNELS: NotificationChannel[] = [
  'doctor_sms',
  'doctor_email',
  'relative_sms',
  'relative_email',
];

export const TIME_PERIODS: MedTimePeriod[] = [
  'morning',
  'noon',
  'evening',
  'night',
  'other1',
  'other2',
];

export const CHRONIC_DISEASES: ChronicDiseaseType[] = [
  'hypertension',
  'cardiovascular',
  'heart_failure',
  'hyperlipidemia',
  'kidney_failure',
  'chronic_pain',
  'major_depression',
  'anxiety',
  'sleep_disorder',
  'physical_disability',
  'other',
];

export const DIABETES_TYPES: DiabetesType[] = [
  'type1',
  'type2',
  'prediabetes',
  'gestational',
  'lada',
  'mody',
  'secondary',
  'chemically_induced',
];

export const INSULIN_TYPES: InsulinType[] = [
  'none',
  'nph',
  'lente',
  'ultralente',
  'regular',
  'rapid',
  'long',
];
