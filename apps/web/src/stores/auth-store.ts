/**
 * Auth store using Zustand
 * Manages doctor authentication state
 */

import { create } from 'zustand';
import { supabase } from '../lib/supabase';
import type { User } from '@supabase/supabase-js';
import type { Doctor } from '../types/database.types';

interface AuthState {
    user: User | null;
    doctor: Doctor | null;
    isLoading: boolean;
    isInitialized: boolean;
    error: string | null;

    // Actions
    initialize: () => Promise<void>;
    signIn: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
    signOut: () => Promise<void>;
    clearError: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
    user: null,
    doctor: null,
    isLoading: false,
    isInitialized: false,
    error: null,

    initialize: async () => {
        try {
            set({ isLoading: true });

            // Get current session
            const { data: { session } } = await supabase.auth.getSession();

            if (session?.user) {
                // Fetch doctor profile
                const { data: doctor } = await supabase
                    .from('doctors')
                    .select('*')
                    .eq('id', session.user.id)
                    .single();

                set({
                    user: session.user,
                    doctor: doctor || null,
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
            supabase.auth.onAuthStateChange(async (event, session) => {
                if (event === 'SIGNED_IN' && session?.user) {
                    const { data: doctor } = await supabase
                        .from('doctors')
                        .select('*')
                        .eq('id', session.user.id)
                        .single();

                    set({ user: session.user, doctor: doctor || null });
                } else if (event === 'SIGNED_OUT') {
                    set({ user: null, doctor: null });
                }
            });
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
}));
