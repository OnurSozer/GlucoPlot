/**
 * Measurements service - patient measurement data
 */

import { supabase } from '../lib/supabase';
import type { Measurement, MeasurementType } from '../types/database.types';

export interface MeasurementFilters {
    patientId: string;
    type?: MeasurementType;
    startDate?: string;
    endDate?: string;
    limit?: number;
}

export const measurementsService = {
    /**
     * Get measurements for a patient with optional filters
     */
    async getMeasurements(filters: MeasurementFilters) {
        let query = supabase
            .from('measurements')
            .select('*')
            .eq('patient_id', filters.patientId)
            .order('measured_at', { ascending: false });

        if (filters.type) {
            query = query.eq('type', filters.type);
        }

        if (filters.startDate) {
            query = query.gte('measured_at', filters.startDate);
        }

        if (filters.endDate) {
            query = query.lte('measured_at', filters.endDate);
        }

        if (filters.limit) {
            query = query.limit(filters.limit);
        }

        const result = await query;
        return { data: result.data as Measurement[] | null, error: result.error };
    },

    /**
     * Get latest measurement of each type for a patient
     */
    async getLatestMeasurements(patientId: string) {
        // Get the most recent measurement of each type
        const types: MeasurementType[] = ['glucose', 'blood_pressure', 'heart_rate', 'weight', 'temperature', 'spo2'];

        const results: Partial<Record<MeasurementType, Measurement>> = {};

        for (const type of types) {
            const { data } = await supabase
                .from('measurements')
                .select('*')
                .eq('patient_id', patientId)
                .eq('type', type)
                .order('measured_at', { ascending: false })
                .limit(1)
                .maybeSingle();

            if (data) {
                results[type] = data as Measurement;
            }
        }

        return results;
    },

    /**
     * Get measurement statistics for a patient
     */
    async getMeasurementStats(patientId: string, type: MeasurementType, days = 7) {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        const { data, error } = await supabase
            .from('measurements')
            .select('*')
            .eq('patient_id', patientId)
            .eq('type', type)
            .gte('measured_at', startDate.toISOString())
            .order('measured_at', { ascending: true });

        if (error || !data || data.length === 0) {
            return { data: null, error, stats: null };
        }

        const measurements = data as Measurement[];

        // Calculate stats
        const values = measurements.map(m => m.value_primary);
        const stats = {
            min: Math.min(...values),
            max: Math.max(...values),
            avg: values.reduce((a, b) => a + b, 0) / values.length,
            latest: values[values.length - 1],
            count: values.length,
        };

        return { data: measurements, error: null, stats };
    },

    /**
     * Get total measurement count for dashboard
     */
    async getTotalMeasurementCount() {
        const { count, error } = await supabase
            .from('measurements')
            .select('*', { count: 'exact', head: true });

        return { count: count || 0, error };
    },

    /**
     * Get recent measurements across all patients
     */
    async getRecentMeasurements(limit = 10) {
        const result = await supabase
            .from('measurements')
            .select(`
        *,
        patients (id, full_name)
      `)
            .order('measured_at', { ascending: false })
            .limit(limit);

        return result;
    },
};
