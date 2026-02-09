/**
 * Measurements Query Hooks
 * SWR pattern: show cached data instantly, refresh in background
 */

import { useQuery, useQueryClient } from '@tanstack/react-query';
import { measurementsService, MeasurementFilters } from '../../services/measurements.service';
import type { MeasurementType } from '../../types/database.types';

// Query keys for cache management
export const measurementsKeys = {
    all: ['measurements'] as const,
    lists: () => [...measurementsKeys.all, 'list'] as const,
    list: (filters: MeasurementFilters) => [...measurementsKeys.lists(), filters] as const,
    latest: (patientId: string) => [...measurementsKeys.all, 'latest', patientId] as const,
    stats: (patientId: string, type: MeasurementType, days: number) =>
        [...measurementsKeys.all, 'stats', patientId, type, days] as const,
    glucoseChart: (patientId: string, days: number) =>
        [...measurementsKeys.all, 'glucoseChart', patientId, days] as const,
    totalCount: () => [...measurementsKeys.all, 'totalCount'] as const,
    recent: (limit: number) => [...measurementsKeys.all, 'recent', limit] as const,
};

/**
 * Hook for fetching measurements with filters
 */
export function useMeasurements(filters: MeasurementFilters, enabled = true) {
    return useQuery({
        queryKey: measurementsKeys.list(filters),
        queryFn: async () => {
            const { data, error } = await measurementsService.getMeasurements(filters);
            if (error) throw error;
            return data ?? [];
        },
        enabled: enabled && !!filters.patientId,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching latest measurements of each type
 */
export function useLatestMeasurements(patientId: string, enabled = true) {
    return useQuery({
        queryKey: measurementsKeys.latest(patientId),
        queryFn: () => measurementsService.getLatestMeasurements(patientId),
        enabled: enabled && !!patientId,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching measurement statistics
 */
export function useMeasurementStats(
    patientId: string,
    type: MeasurementType,
    days = 7,
    enabled = true
) {
    return useQuery({
        queryKey: measurementsKeys.stats(patientId, type, days),
        queryFn: async () => {
            const result = await measurementsService.getMeasurementStats(patientId, type, days);
            if (result.error) throw result.error;
            return { data: result.data ?? [], stats: result.stats };
        },
        enabled: enabled && !!patientId,
        staleTime: 60 * 1000, // 1 minute for aggregate data
    });
}

/**
 * Hook for fetching glucose chart data with meal timing
 */
export function useGlucoseChartData(patientId: string, days = 14, enabled = true) {
    return useQuery({
        queryKey: measurementsKeys.glucoseChart(patientId, days),
        queryFn: async () => {
            const result = await measurementsService.getGlucoseChartData(patientId, days);
            if (result.error) throw result.error;
            return result;
        },
        enabled: enabled && !!patientId,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching total measurement count
 */
export function useTotalMeasurementCount(enabled = true) {
    return useQuery({
        queryKey: measurementsKeys.totalCount(),
        queryFn: async () => {
            const { count, error } = await measurementsService.getTotalMeasurementCount();
            if (error) throw error;
            return count;
        },
        enabled,
        staleTime: 60 * 1000,
    });
}

/**
 * Hook for fetching recent measurements across all patients
 */
export function useRecentMeasurements(limit = 10, enabled = true) {
    return useQuery({
        queryKey: measurementsKeys.recent(limit),
        queryFn: async () => {
            const result = await measurementsService.getRecentMeasurements(limit);
            if (result.error) throw result.error;
            return result.data ?? [];
        },
        enabled,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for invalidating measurements cache
 * Use after creating/updating/deleting measurements
 */
export function useInvalidateMeasurements() {
    const queryClient = useQueryClient();

    return {
        invalidateAll: () => queryClient.invalidateQueries({ queryKey: measurementsKeys.all }),
        invalidatePatient: (patientId: string) =>
            queryClient.invalidateQueries({
                queryKey: measurementsKeys.all,
                predicate: (query) => {
                    const key = query.queryKey;
                    // Check if patientId appears in the query key
                    return key.includes(patientId) ||
                        key.some((k) =>
                            typeof k === 'object' && k !== null && 'patientId' in k && k.patientId === patientId
                        );
                },
            }),
        invalidateLatest: (patientId: string) =>
            queryClient.invalidateQueries({ queryKey: measurementsKeys.latest(patientId) }),
    };
}
