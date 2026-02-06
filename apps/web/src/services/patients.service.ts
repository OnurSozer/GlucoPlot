/**
 * Patients service - patient CRUD operations
 */

import { supabase } from '../lib/supabase';
import type {
    Patient,
    CreatePatientRequest,
    CreatePatientResponse
} from '../types/database.types';

export const patientsService = {
    /**
     * Get all patients for the current doctor
     */
    async getPatients() {
        const { data, error } = await supabase
            .from('patients')
            .select('*')
            .order('created_at', { ascending: false });

        return { data: data as Patient[] | null, error };
    },

    /**
     * Get patients with filters
     */
    async getPatientsFiltered(options: {
        status?: string;
        search?: string;
        limit?: number;
        offset?: number;
    }) {
        let query = supabase
            .from('patients')
            .select('*', { count: 'exact' });

        if (options.status && options.status !== 'all') {
            query = query.eq('status', options.status);
        }

        if (options.search) {
            query = query.ilike('full_name', `%${options.search}%`);
        }

        query = query.order('created_at', { ascending: false });

        if (options.limit) {
            query = query.range(
                options.offset || 0,
                (options.offset || 0) + options.limit - 1
            );
        }

        const result = await query;
        return { data: result.data as Patient[] | null, error: result.error, count: result.count };
    },

    /**
     * Get a single patient by ID
     */
    async getPatientById(patientId: string) {
        const { data, error } = await supabase
            .from('patients')
            .select('*')
            .eq('id', patientId)
            .single();

        return { data: data as Patient | null, error };
    },

    /**
     * Create a new patient with direct database insert
     * (Bypasses Edge Function due to auth issues)
     */
    async createPatient(patientData: CreatePatientRequest): Promise<{ data: CreatePatientResponse | null; error: Error | null }> {
        try {
            // Get current user (doctor)
            const { data: { user } } = await supabase.auth.getUser();
            if (!user) {
                return { data: null, error: new Error('Not authenticated') };
            }

            // Insert patient
            const { data: patient, error: patientError } = await supabase
                .from('patients')
                .insert({
                    doctor_id: user.id,
                    full_name: patientData.full_name,
                    date_of_birth: patientData.date_of_birth || null,
                    gender: patientData.gender || null,
                    phone: patientData.phone || null,
                    medical_notes: patientData.medical_notes || null,
                    status: 'pending'
                } as any)
                .select()
                .single();

            if (patientError || !patient) {
                return { data: null, error: new Error(patientError?.message || 'Failed to create patient') };
            }

            // Create invite token (simple random string)
            const token = crypto.randomUUID() + crypto.randomUUID();
            const expiresAt = new Date();
            expiresAt.setDate(expiresAt.getDate() + 7);

            const { data: invite, error: inviteError } = await supabase
                .from('patient_invites')
                .insert({
                    patient_id: patient.id,
                    doctor_id: user.id,
                    token: token,
                    status: 'pending',
                    expires_at: expiresAt.toISOString()
                } as any)
                .select()
                .single();

            if (inviteError) {
                console.error('Failed to create invite:', inviteError);
            }

            return {
                data: {
                    patient: patient as Patient,
                    invite: invite ? {
                        id: invite.id,
                        token: invite.token,
                        expires_at: invite.expires_at
                    } : { id: '', token: token, expires_at: expiresAt.toISOString() },
                    qr_data: token
                },
                error: null
            };
        } catch (err) {
            return {
                data: null,
                error: err instanceof Error ? err : new Error('Unknown error')
            };
        }
    },

    /**
     * Get the invite token for a patient (for displaying QR code)
     */
    async getPatientInvite(patientId: string) {
        const { data, error } = await supabase
            .from('patient_invites')
            .select('id, token, status, expires_at')
            .eq('patient_id', patientId)
            .order('created_at', { ascending: false })
            .limit(1)
            .single();

        return { data, error };
    },

    /**
     * Update a patient
     */
    async updatePatient(patientId: string, updates: Partial<Patient>) {
        return supabase
            .from('patients')
            .update(updates as any)
            .eq('id', patientId)
            .select()
            .single();
    },

    /**
     * Delete a patient and all related data
     */
    async deletePatient(patientId: string) {
        try {
            // Delete related records first (invites, measurements, logs, etc.)
            // Due to RLS and cascading, we can just delete the patient
            const { error } = await supabase
                .from('patients')
                .delete()
                .eq('id', patientId);

            if (error) {
                return { success: false, error: new Error(error.message) };
            }

            return { success: true, error: null };
        } catch (err) {
            return {
                success: false,
                error: err instanceof Error ? err : new Error('Unknown error'),
            };
        }
    },

    /**
     * Get patient count by status
     */
    async getPatientCounts() {
        const { data, error } = await supabase
            .from('patients')
            .select('status');

        if (error || !data) {
            return { total: 0, active: 0, pending: 0, inactive: 0, error };
        }

        const patients = data as { status: string }[];

        const counts = {
            total: patients.length,
            active: patients.filter(p => p.status === 'active').length,
            pending: patients.filter(p => p.status === 'pending').length,
            inactive: patients.filter(p => p.status === 'inactive').length,
            error: null,
        };

        return counts;
    },
};
