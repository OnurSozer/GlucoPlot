/**
 * Supabase client singleton
 */

import { createClient } from '@supabase/supabase-js';
import { env } from '../config/env';

// Create client without strict Database typing to allow flexible updates
// This is a trade-off for development speed - in production, consider generating types
export const supabase = createClient(
    env.supabase.url,
    env.supabase.anonKey,
    {
        auth: {
            autoRefreshToken: true,
            persistSession: true,
            detectSessionInUrl: true,
        },
    }
);

/**
 * Call an Edge Function with authorization
 */
export async function invokeFunction<T = unknown>(
    functionName: string,
    body?: Record<string, unknown>
): Promise<{ data: T | null; error: Error | null }> {
    try {
        // Get the current session to include auth header
        const { data: { session } } = await supabase.auth.getSession();

        const { data, error } = await supabase.functions.invoke(functionName, {
            body,
            headers: session?.access_token ? {
                Authorization: `Bearer ${session.access_token}`
            } : undefined
        });

        if (error) {
            return { data: null, error: new Error(error.message) };
        }

        return { data: data as T, error: null };
    } catch (err) {
        return {
            data: null,
            error: err instanceof Error ? err : new Error('Unknown error')
        };
    }
}
