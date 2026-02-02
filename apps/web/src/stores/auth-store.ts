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

            // Listen for auth changes
            // Note: SIGNED_IN is handled by signIn() directly to avoid race conditions
            const { data: { subscription } } = supabase.auth.onAuthStateChange(async (event, session) => {
                console.log('Auth event:', event);

                try {
                    if (event === 'SIGNED_IN' && session?.user) {
                        // Skip if signIn() already set the user (avoid race condition)
                        const currentUser = get().user;
                        if (currentUser?.id === session.user.id) {
                            return;
                        }
                        // Only fetch if user changed (e.g., OAuth, magic link, page reload)
                        const doctor = await fetchDoctorProfile(session.user.id);
                        set({ user: session.user, doctor, isLoading: false });
                    } else if (event === 'TOKEN_REFRESHED' && session?.user) {
                        // Token refresh doesn't change user data, only the JWT
                        // Don't update state - avoids unnecessary re-renders
                        console.log('Token refreshed for user:', session.user.id);
                    } else if (event === 'SIGNED_OUT') {
                        set({ user: null, doctor: null, isLoading: false });
                    } else if (event === 'USER_UPDATED' && session?.user) {
                        const doctor = await fetchDoctorProfile(session.user.id);
                        set({ user: session.user, doctor });
                    }
                } catch (error) {
                    console.error('Auth state change error:', error);
                    set({ isLoading: false });
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
        // Clear local state immediately for instant UI feedback
        set({ user: null, doctor: null, isLoading: false });

        // Sign out from Supabase in background (don't block UI)
        try {
            await supabase.auth.signOut();
        } catch (error) {
            console.error('Sign out error:', error);
            // State already cleared, user sees login screen regardless
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
