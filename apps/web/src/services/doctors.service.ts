/**
 * Doctors service - admin operations for managing doctors
 */

import { supabase } from '../lib/supabase';
import type { Doctor, Patient } from '../types/database.types';

export interface DoctorFilters {
    search?: string;
    specialty?: string;
    limit?: number;
    offset?: number;
}

export const doctorsService = {
    /**
     * Get all doctors
     */
    async getDoctors() {
        const { data, error } = await supabase
            .from('doctors')
            .select('*')
            .order('created_at', { ascending: false });

        return { data: data as Doctor[] | null, error };
    },

    /**
     * Get doctors with filters
     */
    async getDoctorsFiltered(filters: DoctorFilters = {}) {
        let query = supabase
            .from('doctors')
            .select('*', { count: 'exact' });

        if (filters.search) {
            query = query.or(
                `full_name.ilike.%${filters.search}%,email.ilike.%${filters.search}%`
            );
        }

        if (filters.specialty) {
            query = query.eq('specialty', filters.specialty);
        }

        query = query.order('created_at', { ascending: false });

        if (filters.limit) {
            query = query.range(
                filters.offset || 0,
                (filters.offset || 0) + filters.limit - 1
            );
        }

        const result = await query;
        return {
            data: result.data as Doctor[] | null,
            error: result.error,
            count: result.count,
        };
    },

    /**
     * Get a single doctor by ID
     */
    async getDoctorById(doctorId: string) {
        const { data, error } = await supabase
            .from('doctors')
            .select('*')
            .eq('id', doctorId)
            .single();

        return { data: data as Doctor | null, error };
    },

    /**
     * Get patients for a specific doctor
     */
    async getPatientsForDoctor(doctorId: string) {
        const { data, error } = await supabase
            .from('patients')
            .select('*')
            .eq('doctor_id', doctorId)
            .order('created_at', { ascending: false });

        return { data: data as Patient[] | null, error };
    },

    /**
     * Create a new doctor (calls SQL function)
     */
    async createDoctor(data: {
        email: string;
        password: string;
        full_name: string;
        phone?: string;
        specialty?: string;
    }) {
        const { data: result, error } = await supabase.rpc('create_doctor_with_auth', {
            p_email: data.email,
            p_password: data.password,
            p_full_name: data.full_name,
            p_phone: data.phone || null,
            p_specialty: data.specialty || null,
        });

        return { data: result as { success: boolean; doctor_id?: string; error?: string } | null, error };
    },

    /**
     * Update a doctor's profile
     */
    async updateDoctor(doctorId: string, updates: Partial<Pick<Doctor, 'full_name' | 'phone' | 'specialty'>>) {
        const { data, error } = await supabase
            .from('doctors')
            .update(updates)
            .eq('id', doctorId)
            .select()
            .single();

        return { data: data as Doctor | null, error, success: !error };
    },

    /**
     * Delete a doctor (calls SQL function)
     */
    async deleteDoctor(doctorId: string) {
        const { data, error } = await supabase.rpc('delete_doctor', {
            p_doctor_id: doctorId,
        });

        return { data: data as { success: boolean; error?: string } | null, error };
    },

    /**
     * Get doctor statistics
     */
    async getDoctorStats() {
        const { count, error } = await supabase
            .from('doctors')
            .select('*', { count: 'exact', head: true });

        return { total: count || 0, error };
    },

    /**
     * Get total patient count (across all doctors)
     */
    async getTotalPatientCount() {
        const { count, error } = await supabase
            .from('patients')
            .select('*', { count: 'exact', head: true });

        return { total: count || 0, error };
    },
};
