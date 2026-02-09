/**
 * TanStack Query client configuration
 * Implements SWR (Stale-While-Revalidate) pattern for optimal UX
 */

import { QueryClient } from '@tanstack/react-query';

export const queryClient = new QueryClient({
    defaultOptions: {
        queries: {
            // Data is considered fresh for 30 seconds
            staleTime: 30 * 1000,
            // Cache data for 5 minutes before garbage collection
            gcTime: 5 * 60 * 1000,
            // Refresh data when window regains focus
            refetchOnWindowFocus: true,
            // Don't refetch on mount if data is fresh
            refetchOnMount: true,
            // Retry failed requests once
            retry: 1,
            // Retry delay: 1 second
            retryDelay: 1000,
        },
    },
});
