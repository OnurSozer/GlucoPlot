/**
 * Auth service - authentication operations
 */

import { supabase } from '../lib/supabase';
import type { Doctor } from '../types/database.types';

export const authService = {
    /**
     * Sign in with email and password
     */
    async signIn(email: string, password: string) {
        return supabase.auth.signInWithPassword({ email, password });
    },

    /**
     * Sign out current user
     */
    async signOut() {
        return supabase.auth.signOut();
    },

    /**
     * Get current session
     */
    async getSession() {
        return supabase.auth.getSession();
    },

    /**
     * Get current user
     */
    async getCurrentUser() {
        const { data: { user } } = await supabase.auth.getUser();
        return user;
    },

    /**
     * Fetch doctor profile by ID
     */
    async getDoctorProfile(userId: string): Promise<Doctor | null> {
        const { data, error } = await supabase
            .from('doctors')
            .select('*')
            .eq('id', userId)
            .single();

        if (error) {
            console.error('Error fetching doctor profile:', error);
            return null;
        }

        return data as Doctor;
    },

    /**
     * Update doctor profile
     */
    async updateDoctorProfile(userId: string, updates: Partial<Doctor>) {
        return supabase
            .from('doctors')
            .update(updates as any)
            .eq('id', userId)
            .select()
            .single();
    },

    /**
     * Subscribe to auth state changes
     */
    onAuthStateChange(callback: (event: string, session: unknown) => void) {
        return supabase.auth.onAuthStateChange(callback);
    },
};
