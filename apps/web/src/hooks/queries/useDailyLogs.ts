/**
 * Daily Logs Query Hooks
 * SWR pattern: show cached data instantly, refresh in background
 */

import { useQuery, useQueryClient } from '@tanstack/react-query';
import { dailyLogsService, DailyLogFilters } from '../../services/daily-logs.service';

// Query keys for cache management
export const dailyLogsKeys = {
    all: ['dailyLogs'] as const,
    lists: () => [...dailyLogsKeys.all, 'list'] as const,
    list: (filters: DailyLogFilters) => [...dailyLogsKeys.lists(), filters] as const,
    byDate: (patientId: string, date: string) => [...dailyLogsKeys.all, 'byDate', patientId, date] as const,
    summary: (patientId: string, days: number) => [...dailyLogsKeys.all, 'summary', patientId, days] as const,
    typeCounts: (patientId: string, days: number) => [...dailyLogsKeys.all, 'typeCounts', patientId, days] as const,
};

/**
 * Hook for fetching daily logs with filters
 */
export function useDailyLogs(filters: DailyLogFilters, enabled = true) {
    return useQuery({
        queryKey: dailyLogsKeys.list(filters),
        queryFn: async () => {
            const { data, error } = await dailyLogsService.getDailyLogs(filters);
            if (error) throw error;
            return data ?? [];
        },
        enabled,
        staleTime: 30 * 1000, // 30 seconds
    });
}

/**
 * Hook for fetching daily logs for a specific date
 */
export function useDailyLogsByDate(patientId: string, logDate: string, enabled = true) {
    return useQuery({
        queryKey: dailyLogsKeys.byDate(patientId, logDate),
        queryFn: async () => {
            const { data, error } = await dailyLogsService.getDailyLogsByDate(patientId, logDate);
            if (error) throw error;
            return data ?? [];
        },
        enabled: enabled && !!patientId && !!logDate,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching log type counts
 */
export function useLogTypeCounts(patientId: string, days = 7, enabled = true) {
    return useQuery({
        queryKey: dailyLogsKeys.typeCounts(patientId, days),
        queryFn: async () => {
            const { counts, error } = await dailyLogsService.getLogTypeCounts(patientId, days);
            if (error) throw error;
            return counts ?? {};
        },
        enabled: enabled && !!patientId,
        staleTime: 60 * 1000, // 1 minute for aggregate data
    });
}

/**
 * Hook for fetching logs summary with stats
 */
export function useLogsSummary(patientId: string, days = 7, enabled = true) {
    return useQuery({
        queryKey: dailyLogsKeys.summary(patientId, days),
        queryFn: async () => {
            const result = await dailyLogsService.getLogsSummary(patientId, days);
            if (result.error) throw result.error;
            return { data: result.data ?? [], stats: result.stats };
        },
        enabled: enabled && !!patientId,
        staleTime: 60 * 1000,
    });
}

/**
 * Hook for invalidating daily logs cache
 * Use after creating/updating/deleting logs
 */
export function useInvalidateDailyLogs() {
    const queryClient = useQueryClient();

    return {
        invalidateAll: () => queryClient.invalidateQueries({ queryKey: dailyLogsKeys.all }),
        invalidatePatient: (patientId: string) =>
            queryClient.invalidateQueries({
                queryKey: dailyLogsKeys.all,
                predicate: (query) => {
                    const key = query.queryKey;
                    return key.some((k) =>
                        typeof k === 'object' && k !== null && 'patientId' in k && k.patientId === patientId
                    );
                },
            }),
    };
}
