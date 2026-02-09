/**
 * Patients Query Hooks
 * SWR pattern: show cached data instantly, refresh in background
 */

import { useQuery, useQueryClient } from '@tanstack/react-query';
import { patientsService } from '../../services/patients.service';

// Query keys for cache management
export const patientsKeys = {
    all: ['patients'] as const,
    lists: () => [...patientsKeys.all, 'list'] as const,
    list: (filters?: { status?: string; search?: string; limit?: number; offset?: number }) =>
        [...patientsKeys.lists(), filters ?? {}] as const,
    detail: (patientId: string) => [...patientsKeys.all, 'detail', patientId] as const,
    counts: () => [...patientsKeys.all, 'counts'] as const,
    invite: (patientId: string) => [...patientsKeys.all, 'invite', patientId] as const,
};

export interface PatientListFilters {
    status?: string;
    search?: string;
    limit?: number;
    offset?: number;
}

/**
 * Hook for fetching all patients
 */
export function usePatients(enabled = true) {
    return useQuery({
        queryKey: patientsKeys.lists(),
        queryFn: async () => {
            const { data, error } = await patientsService.getPatients();
            if (error) throw error;
            return data ?? [];
        },
        enabled,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching patients with filters and pagination
 */
export function usePatientsFiltered(filters: PatientListFilters = {}, enabled = true) {
    return useQuery({
        queryKey: patientsKeys.list(filters),
        queryFn: async () => {
            const { data, error, count } = await patientsService.getPatientsFiltered(filters);
            if (error) throw error;
            return { data: data ?? [], count: count ?? 0 };
        },
        enabled,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching a single patient by ID
 */
export function usePatient(patientId: string, enabled = true) {
    return useQuery({
        queryKey: patientsKeys.detail(patientId),
        queryFn: async () => {
            const { data, error } = await patientsService.getPatientById(patientId);
            if (error) throw error;
            return data;
        },
        enabled: enabled && !!patientId,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching patient counts by status
 */
export function usePatientCounts(enabled = true) {
    return useQuery({
        queryKey: patientsKeys.counts(),
        queryFn: async () => {
            const result = await patientsService.getPatientCounts();
            if (result.error) throw result.error;
            return result;
        },
        enabled,
        staleTime: 60 * 1000, // 1 minute for aggregate data
    });
}

/**
 * Hook for fetching patient invite/QR token
 */
export function usePatientInvite(patientId: string, enabled = true) {
    return useQuery({
        queryKey: patientsKeys.invite(patientId),
        queryFn: async () => {
            const { data, error } = await patientsService.getPatientInvite(patientId);
            if (error) throw error;
            return data;
        },
        enabled: enabled && !!patientId,
        staleTime: 5 * 60 * 1000, // 5 minutes - invites don't change often
    });
}

/**
 * Hook for invalidating patients cache
 * Use after creating/updating/deleting patients
 */
export function useInvalidatePatients() {
    const queryClient = useQueryClient();

    return {
        invalidateAll: () => queryClient.invalidateQueries({ queryKey: patientsKeys.all }),
        invalidateLists: () => queryClient.invalidateQueries({ queryKey: patientsKeys.lists() }),
        invalidatePatient: (patientId: string) =>
            queryClient.invalidateQueries({ queryKey: patientsKeys.detail(patientId) }),
        invalidateCounts: () =>
            queryClient.invalidateQueries({ queryKey: patientsKeys.counts() }),
    };
}
