/**
 * Environment configuration
 * Reads from Vite's import.meta.env
 */

export const env = {
    supabase: {
        url: import.meta.env.VITE_SUPABASE_URL as string || 'http://127.0.0.1:54321',
        anonKey: import.meta.env.VITE_SUPABASE_ANON_KEY as string || '',
    },
    isDev: import.meta.env.DEV,
    isProd: import.meta.env.PROD,
} as const;

// Validate required env vars in production
if (env.isProd) {
    if (!env.supabase.url) {
        throw new Error('VITE_SUPABASE_URL is required in production');
    }
    if (!env.supabase.anonKey) {
        throw new Error('VITE_SUPABASE_ANON_KEY is required in production');
    }
}
