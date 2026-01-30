/**
 * Auth store using Zustand
 * Manages doctor authentication state
 */

import { create } from 'zustand';
import { supabase } from '../lib/supabase';
import type { User, Subscription } from '@supabase/supabase-js';
import type { Doctor } from '../types/database.types';

interface AuthState {
    user: User | null;
    doctor: Doctor | null;
    isLoading: boolean;
    isInitialized: boolean;
    error: string | null;
    _subscription: Subscription | null;

    // Actions
    initialize: () => Promise<void>;
    signIn: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
    signOut: () => Promise<void>;
    clearError: () => void;
    cleanup: () => void;
}

// Helper to fetch doctor profile
async function fetchDoctorProfile(userId: string): Promise<Doctor | null> {
    const { data } = await supabase
        .from('doctors')
        .select('*')
        .eq('id', userId)
        .single();
    return data || null;
}

export const useAuthStore = create<AuthState>((set, get) => ({
    user: null,
    doctor: null,
    isLoading: false,
    isInitialized: false,
    error: null,
    _subscription: null,

    initialize: async () => {
        // Prevent double initialization
        if (get().isInitialized || get()._subscription) {
            return;
        }

        try {
            set({ isLoading: true });

            // Get current session
            const { data: { session } } = await supabase.auth.getSession();

            if (session?.user) {
                // Fetch doctor profile
                const doctor = await fetchDoctorProfile(session.user.id);

                set({
                    user: session.user,
                    doctor,
                    isLoading: false,
                    isInitialized: true,
                });
            } else {
                set({
                    user: null,
                    doctor: null,
                    isLoading: false,
                    isInitialized: true,
                });
            }

            // Listen for auth changes - handle ALL relevant events
            const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
                console.log('Auth event:', event);

                if (event === 'SIGNED_IN' && session?.user) {
                    const doctor = await fetchDoctorProfile(session.user.id);
                    set({ user: session.user, doctor });
                } else if (event === 'TOKEN_REFRESHED' && session?.user) {
                    // Token refresh doesn't change user data, only the JWT
                    // Only update state if user ID changed (shouldn't happen, but safety check)
                    const currentUser = get().user;
                    if (!currentUser || currentUser.id !== session.user.id) {
                        const doctor = await fetchDoctorProfile(session.user.id);
                        set({ user: session.user, doctor });
                    }
                    // If same user, don't update state - avoids unnecessary re-renders
                } else if (event === 'SIGNED_OUT') {
                    set({ user: null, doctor: null });
                } else if (event === 'USER_UPDATED' && session?.user) {
                    // Refetch doctor profile on user update
                    const doctor = await fetchDoctorProfile(session.user.id);
                    set({ user: session.user, doctor });
                }
            });

            // Store subscription for cleanup
            set({ _subscription: subscription });
        } catch (error) {
            console.error('Auth initialization error:', error);
            set({
                isLoading: false,
                isInitialized: true,
                error: 'Failed to initialize authentication',
            });
        }
    },

    signIn: async (email: string, password: string) => {
        try {
            set({ isLoading: true, error: null });

            const { data, error } = await supabase.auth.signInWithPassword({
                email,
                password,
            });

            if (error) {
                set({ isLoading: false, error: error.message });
                return { success: false, error: error.message };
            }

            if (data.user) {
                // Fetch doctor profile
                const { data: doctor, error: doctorError } = await supabase
                    .from('doctors')
                    .select('*')
                    .eq('id', data.user.id)
                    .single();

                if (doctorError || !doctor) {
                    // User is not a doctor
                    await supabase.auth.signOut();
                    set({
                        isLoading: false,
                        error: 'This account is not registered as a doctor',
                    });
                    return { success: false, error: 'Not a registered doctor' };
                }

                set({
                    user: data.user,
                    doctor,
                    isLoading: false,
                });

                return { success: true };
            }

            set({ isLoading: false });
            return { success: false, error: 'Unknown error' };
        } catch (error) {
            const message = error instanceof Error ? error.message : 'Sign in failed';
            set({ isLoading: false, error: message });
            return { success: false, error: message };
        }
    },

    signOut: async () => {
        try {
            set({ isLoading: true });
            await supabase.auth.signOut();
            set({ user: null, doctor: null, isLoading: false });
        } catch (error) {
            console.error('Sign out error:', error);
            set({ isLoading: false });
        }
    },

    clearError: () => set({ error: null }),

    cleanup: () => {
        const subscription = get()._subscription;
        if (subscription) {
            subscription.unsubscribe();
            set({ _subscription: null });
        }
    },
}));
