/**
 * Alerts service - risk alert operations
 */

import { supabase } from '../lib/supabase';
import type { AlertStatus } from '../types/database.types';

export interface AlertFilters {
    status?: AlertStatus | 'all';
    severity?: string;
    patientId?: string;
    limit?: number;
}

export const alertsService = {
    /**
     * Get all alerts for the doctor with optional filters
     */
    async getAlerts(filters: AlertFilters = {}) {
        let query = supabase
            .from('risk_alerts')
            .select(`
        *,
        patients (id, full_name)
      `)
            .order('created_at', { ascending: false });

        if (filters.status && filters.status !== 'all') {
            query = query.eq('status', filters.status);
        }

        if (filters.severity) {
            query = query.eq('severity', filters.severity);
        }

        if (filters.patientId) {
            query = query.eq('patient_id', filters.patientId);
        }

        if (filters.limit) {
            query = query.limit(filters.limit);
        }

        return query;
    },

    /**
     * Get count of new alerts
     */
    async getNewAlertCount() {
        const { count, error } = await supabase
            .from('risk_alerts')
            .select('*', { count: 'exact', head: true })
            .eq('status', 'new');

        return { count: count || 0, error };
    },

    /**
     * Get alert counts by status
     */
    async getAlertCounts() {
        const { data, error } = await supabase
            .from('risk_alerts')
            .select('status');

        if (error || !data) {
            return { new: 0, acknowledged: 0, resolved: 0, total: 0, error };
        }

        const alerts = data as { status: string }[];

        return {
            new: alerts.filter(a => a.status === 'new').length,
            acknowledged: alerts.filter(a => a.status === 'acknowledged').length,
            resolved: alerts.filter(a => a.status === 'resolved').length,
            total: alerts.length,
            error: null,
        };
    },

    /**
     * Acknowledge an alert
     */
    async acknowledgeAlert(alertId: string) {
        return supabase
            .from('risk_alerts')
            .update({
                status: 'acknowledged',
                acknowledged_at: new Date().toISOString(),
            } as any)
            .eq('id', alertId)
            .select()
            .single();
    },

    /**
     * Resolve an alert
     */
    async resolveAlert(alertId: string) {
        return supabase
            .from('risk_alerts')
            .update({
                status: 'resolved',
                resolved_at: new Date().toISOString(),
            } as any)
            .eq('id', alertId)
            .select()
            .single();
    },

    /**
     * Get alert by ID
     */
    async getAlertById(alertId: string) {
        return supabase
            .from('risk_alerts')
            .select(`
        *,
        patients (id, full_name),
        measurements (*)
      `)
            .eq('id', alertId)
            .single();
    },
};
