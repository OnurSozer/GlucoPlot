/**
 * Database types for GlucoPlot
 * Matches Supabase schema defined in migrations
 */

// ============================================================
// Enums (matching PostgreSQL enums)
// ============================================================

export type PatientStatus = 'pending' | 'active' | 'inactive';
export type InviteStatus = 'pending' | 'redeemed' | 'expired';
export type MeasurementType = 'glucose' | 'blood_pressure' | 'heart_rate' | 'weight' | 'temperature' | 'spo2';
export type MeasurementSource = 'device' | 'manual';
export type MealTiming = 'fasting' | 'post_meal' | 'other';
export type LogType = 'food' | 'sleep' | 'exercise' | 'medication' | 'symptom' | 'note';
export type AlertSeverity = 'low' | 'medium' | 'high' | 'critical';
export type AlertStatus = 'new' | 'acknowledged' | 'resolved';

// ============================================================
// Table Types
// ============================================================

export interface Admin {
    id: string;
    full_name: string;
    email: string;
    phone: string | null;
    created_at: string;
    updated_at: string;
}

export interface Doctor {
    id: string;
    full_name: string;
    email: string;
    phone: string | null;
    specialty: string | null;
    avatar_url: string | null;
    created_at: string;
    updated_at: string;
}

export interface Patient {
    id: string;
    doctor_id: string;
    auth_user_id: string | null;
    full_name: string;
    national_id: string | null;
    date_of_birth: string | null;
    gender: string | null;
    phone: string | null;
    medical_notes: string | null;
    status: PatientStatus;
    created_at: string;
    updated_at: string;
}

export interface PatientInvite {
    id: string;
    patient_id: string;
    doctor_id: string;
    token: string;
    otp_code: string | null;
    otp_expires_at: string | null;
    status: InviteStatus;
    expires_at: string;
    redeemed_at: string | null;
    created_at: string;
}

export interface Measurement {
    id: string;
    patient_id: string;
    type: MeasurementType;
    value_primary: number;
    value_secondary: number | null;
    unit: string;
    measured_at: string;
    source: MeasurementSource;
    meal_timing: MealTiming | null;
    notes: string | null;
    created_at: string;
}

export interface DailyLog {
    id: string;
    patient_id: string;
    log_date: string;
    log_type: LogType;
    title: string;
    description: string | null;
    metadata: Record<string, unknown> | null;
    logged_at: string;
    created_at: string;
}

export interface RiskAlert {
    id: string;
    patient_id: string;
    doctor_id: string;
    measurement_id: string | null;
    severity: AlertSeverity;
    title: string;
    description: string | null;
    status: AlertStatus;
    acknowledged_at: string | null;
    resolved_at: string | null;
    created_at: string;
}

export interface MeasurementThreshold {
    id: string;
    doctor_id: string;
    measurement_type: MeasurementType;
    min_critical: number | null;
    min_warning: number | null;
    max_warning: number | null;
    max_critical: number | null;
    unit: string;
    created_at: string;
    updated_at: string;
}

// ============================================================
// Join Types (for queries with relations)
// ============================================================

export interface PatientWithDoctor extends Patient {
    doctors?: Doctor;
}

export interface MeasurementWithPatient extends Measurement {
    patients?: Patient;
}

export interface RiskAlertWithPatient extends RiskAlert {
    patients?: Patient;
}

export interface RiskAlertWithMeasurement extends RiskAlert {
    patients?: Patient;
    measurements?: Measurement;
}

// ============================================================
// Supabase Database Schema Type
// Used for typed client
// ============================================================

export interface Database {
    public: {
        Tables: {
            admins: {
                Row: Admin;
                Insert: Omit<Admin, 'created_at' | 'updated_at'>;
                Update: Partial<Omit<Admin, 'id' | 'created_at'>>;
            };
            doctors: {
                Row: Doctor;
                Insert: Omit<Doctor, 'created_at' | 'updated_at'>;
                Update: Partial<Omit<Doctor, 'id' | 'created_at'>>;
            };
            patients: {
                Row: Patient;
                Insert: Omit<Patient, 'id' | 'created_at' | 'updated_at'> & { id?: string };
                Update: Partial<Omit<Patient, 'id' | 'created_at'>>;
            };
            patient_invites: {
                Row: PatientInvite;
                Insert: Omit<PatientInvite, 'id' | 'token' | 'created_at' | 'expires_at'> & { id?: string };
                Update: Partial<Omit<PatientInvite, 'id' | 'token' | 'created_at'>>;
            };
            measurements: {
                Row: Measurement;
                Insert: Omit<Measurement, 'id' | 'created_at'> & { id?: string };
                Update: Partial<Omit<Measurement, 'id' | 'created_at'>>;
            };
            daily_logs: {
                Row: DailyLog;
                Insert: Omit<DailyLog, 'id' | 'created_at'> & { id?: string };
                Update: Partial<Omit<DailyLog, 'id' | 'created_at'>>;
            };
            risk_alerts: {
                Row: RiskAlert;
                Insert: Omit<RiskAlert, 'id' | 'created_at'> & { id?: string };
                Update: Partial<Omit<RiskAlert, 'id' | 'created_at'>>;
            };
            measurement_thresholds: {
                Row: MeasurementThreshold;
                Insert: Omit<MeasurementThreshold, 'id' | 'created_at' | 'updated_at'> & { id?: string };
                Update: Partial<Omit<MeasurementThreshold, 'id' | 'created_at'>>;
            };
        };
        Enums: {
            patient_status: PatientStatus;
            invite_status: InviteStatus;
            measurement_type: MeasurementType;
            measurement_source: MeasurementSource;
            meal_timing: MealTiming;
            log_type: LogType;
            alert_severity: AlertSeverity;
            alert_status: AlertStatus;
        };
    };
}

// ============================================================
// Edge Function Types
// ============================================================

export interface CreatePatientRequest {
    full_name: string;
    date_of_birth?: string;
    gender?: string;
    phone?: string;
    medical_notes?: string;
}

export interface CreatePatientResponse {
    patient: Patient;
    invite: {
        id: string;
        token: string;
        expires_at: string;
    };
    qr_data: string;
}
