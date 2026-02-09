/**
 * Doctors Query Hooks (Admin)
 * SWR pattern: show cached data instantly, refresh in background
 */

import { useQuery, useQueryClient } from '@tanstack/react-query';
import { doctorsService, DoctorFilters } from '../../services/doctors.service';

// Query keys for cache management
export const doctorsKeys = {
    all: ['doctors'] as const,
    lists: () => [...doctorsKeys.all, 'list'] as const,
    list: (filters: DoctorFilters) => [...doctorsKeys.lists(), filters] as const,
    detail: (doctorId: string) => [...doctorsKeys.all, 'detail', doctorId] as const,
    patients: (doctorId: string) => [...doctorsKeys.all, 'patients', doctorId] as const,
    stats: () => [...doctorsKeys.all, 'stats'] as const,
    totalPatients: () => [...doctorsKeys.all, 'totalPatients'] as const,
};

/**
 * Hook for fetching all doctors
 */
export function useDoctors(enabled = true) {
    return useQuery({
        queryKey: doctorsKeys.lists(),
        queryFn: async () => {
            const { data, error } = await doctorsService.getDoctors();
            if (error) throw error;
            return data ?? [];
        },
        enabled,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching doctors with filters
 */
export function useDoctorsFiltered(filters: DoctorFilters = {}, enabled = true) {
    return useQuery({
        queryKey: doctorsKeys.list(filters),
        queryFn: async () => {
            const { data, error } = await doctorsService.getDoctorsFiltered(filters);
            if (error) throw error;
            return data ?? [];
        },
        enabled,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching a single doctor
 */
export function useDoctor(doctorId: string, enabled = true) {
    return useQuery({
        queryKey: doctorsKeys.detail(doctorId),
        queryFn: async () => {
            const { data, error } = await doctorsService.getDoctorById(doctorId);
            if (error) throw error;
            return data;
        },
        enabled: enabled && !!doctorId,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching patients of a doctor
 */
export function useDoctorPatients(doctorId: string, enabled = true) {
    return useQuery({
        queryKey: doctorsKeys.patients(doctorId),
        queryFn: async () => {
            const { data, error } = await doctorsService.getPatientsForDoctor(doctorId);
            if (error) throw error;
            return data ?? [];
        },
        enabled: enabled && !!doctorId,
        staleTime: 30 * 1000,
    });
}

/**
 * Hook for fetching doctor statistics
 */
export function useDoctorStats(enabled = true) {
    return useQuery({
        queryKey: doctorsKeys.stats(),
        queryFn: async () => {
            const { total, error } = await doctorsService.getDoctorStats();
            if (error) throw error;
            return { total };
        },
        enabled,
        staleTime: 60 * 1000,
    });
}

/**
 * Hook for fetching total patient count
 */
export function useTotalPatientCount(enabled = true) {
    return useQuery({
        queryKey: doctorsKeys.totalPatients(),
        queryFn: async () => {
            const { total, error } = await doctorsService.getTotalPatientCount();
            if (error) throw error;
            return total;
        },
        enabled,
        staleTime: 60 * 1000,
    });
}

/**
 * Hook for invalidating doctors cache
 */
export function useInvalidateDoctors() {
    const queryClient = useQueryClient();

    return {
        invalidateAll: () => queryClient.invalidateQueries({ queryKey: doctorsKeys.all }),
        invalidateDoctor: (doctorId: string) =>
            queryClient.invalidateQueries({ queryKey: doctorsKeys.detail(doctorId) }),
        invalidatePatients: (doctorId: string) =>
            queryClient.invalidateQueries({ queryKey: doctorsKeys.patients(doctorId) }),
    };
}
