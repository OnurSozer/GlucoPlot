/**
 * Daily Logs service - patient daily activity logs
 */

import { supabase } from '../lib/supabase';
import type { DailyLog, LogType } from '../types/database.types';

export interface DailyLogFilters {
    patientId: string;
    logType?: LogType;
    startDate?: string;
    endDate?: string;
    limit?: number;
}

export const dailyLogsService = {
    /**
     * Get daily logs for a patient with optional filters
     */
    async getDailyLogs(filters: DailyLogFilters) {
        let query = supabase
            .from('daily_logs')
            .select('*')
            .eq('patient_id', filters.patientId)
            .order('logged_at', { ascending: false });

        if (filters.logType) {
            query = query.eq('log_type', filters.logType);
        }

        if (filters.startDate) {
            query = query.gte('log_date', filters.startDate);
        }

        if (filters.endDate) {
            query = query.lte('log_date', filters.endDate);
        }

        if (filters.limit) {
            query = query.limit(filters.limit);
        }

        const result = await query;
        return { data: result.data as DailyLog[] | null, error: result.error };
    },

    /**
     * Get daily logs for a specific date
     */
    async getDailyLogsByDate(patientId: string, logDate: string) {
        const result = await supabase
            .from('daily_logs')
            .select('*')
            .eq('patient_id', patientId)
            .eq('log_date', logDate)
            .order('logged_at', { ascending: false });

        return { data: result.data as DailyLog[] | null, error: result.error };
    },

    /**
     * Get log type counts for a patient
     */
    async getLogTypeCounts(patientId: string, days = 7) {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        const { data, error } = await supabase
            .from('daily_logs')
            .select('log_type')
            .eq('patient_id', patientId)
            .gte('log_date', startDate.toISOString().split('T')[0]);

        if (error || !data) {
            return { counts: null, error };
        }

        const counts: Partial<Record<LogType, number>> = {};
        for (const log of data) {
            const type = log.log_type as LogType;
            counts[type] = (counts[type] || 0) + 1;
        }

        return { counts, error: null };
    },

    /**
     * Get recent logs summary stats
     */
    async getLogsSummary(patientId: string, days = 7) {
        const startDate = new Date();
        startDate.setDate(startDate.getDate() - days);

        const { data, error } = await supabase
            .from('daily_logs')
            .select('*')
            .eq('patient_id', patientId)
            .gte('log_date', startDate.toISOString().split('T')[0])
            .order('logged_at', { ascending: false });

        if (error || !data) {
            return { data: null, error, stats: null };
        }

        const logs = data as DailyLog[];

        // Calculate stats
        const stats = {
            total: logs.length,
            byType: {} as Record<LogType, number>,
            recentDays: days,
        };

        for (const log of logs) {
            stats.byType[log.log_type] = (stats.byType[log.log_type] || 0) + 1;
        }

        return { data: logs, error: null, stats };
    },

    /**
     * Create a new daily log entry
     */
    async createDailyLog(data: {
        patient_id: string;
        log_date: string;
        log_type: LogType;
        title: string;
        description?: string;
        metadata?: Record<string, unknown>;
        logged_at?: string;
    }) {
        const result = await supabase
            .from('daily_logs')
            .insert({
                ...data,
                logged_at: data.logged_at || new Date().toISOString(),
            })
            .select()
            .single();

        return { data: result.data as DailyLog | null, error: result.error };
    },

    /**
     * Update a daily log entry
     */
    async updateDailyLog(logId: string, updates: Partial<Omit<DailyLog, 'id' | 'created_at'>>) {
        const result = await supabase
            .from('daily_logs')
            .update(updates)
            .eq('id', logId)
            .select()
            .single();

        return { data: result.data as DailyLog | null, error: result.error };
    },

    /**
     * Delete a daily log entry
     */
    async deleteDailyLog(logId: string) {
        const result = await supabase
            .from('daily_logs')
            .delete()
            .eq('id', logId);

        return { error: result.error };
    },
};
