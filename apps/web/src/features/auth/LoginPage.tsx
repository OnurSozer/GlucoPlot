/**
 * Login Page - Doctor authentication
 */

import { useState, FormEvent } from 'react';
import { Navigate } from 'react-router-dom';
import { Activity, Mail, Lock, Eye, EyeOff } from 'lucide-react';
import { useAuthStore } from '../../stores/auth-store';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';

export function LoginPage() {
    const { user, doctor, signIn, isLoading, error, clearError } = useAuthStore();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [formError, setFormError] = useState('');

    // Redirect if already logged in
    if (user && doctor) {
        return <Navigate to="/" replace />;
    }

    const handleSubmit = async (e: FormEvent) => {
        e.preventDefault();
        setFormError('');
        clearError();

        // Validate
        if (!email.trim()) {
            setFormError('Email is required');
            return;
        }
        if (!password) {
            setFormError('Password is required');
            return;
        }

        const result = await signIn(email.trim(), password);

        if (!result.success && result.error) {
            setFormError(result.error);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-[#FDF6F0] via-[#F8D4B4] to-[#E8A87C] p-4">
            {/* Background decoration */}
            <div className="absolute inset-0 overflow-hidden">
                <div className="absolute -top-40 -right-40 w-80 h-80 bg-white/20 rounded-full blur-3xl" />
                <div className="absolute -bottom-40 -left-40 w-96 h-96 bg-primary/20 rounded-full blur-3xl" />
            </div>

            {/* Login Card */}
            <div className="relative w-full max-w-md">
                <div className="bg-white/90 backdrop-blur-xl rounded-3xl shadow-2xl p-8 animate-slide-up">
                    {/* Logo */}
                    <div className="flex flex-col items-center mb-8">
                        <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-primary to-primary-dark flex items-center justify-center mb-4 shadow-lg">
                            <Activity size={32} className="text-white" />
                        </div>
                        <h1 className="text-2xl font-bold text-gray-900">GlucoPlot</h1>
                        <p className="text-gray-500 text-sm mt-1">Doctor Portal</p>
                    </div>

                    {/* Welcome text */}
                    <div className="text-center mb-8">
                        <h2 className="text-xl font-semibold text-gray-900">Welcome back</h2>
                        <p className="text-gray-500 text-sm mt-1">Sign in to manage your patients</p>
                    </div>

                    {/* Error message */}
                    {(formError || error) && (
                        <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-xl">
                            <p className="text-red-600 text-sm">{formError || error}</p>
                        </div>
                    )}

                    {/* Login form */}
                    <form onSubmit={handleSubmit} className="space-y-5">
                        <Input
                            type="email"
                            label="Email"
                            placeholder="doctor@example.com"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            leftIcon={<Mail size={18} />}
                            autoComplete="email"
                        />

                        <Input
                            type={showPassword ? 'text' : 'password'}
                            label="Password"
                            placeholder="••••••••"
                            value={password}
                            onChange={(e) => setPassword(e.target.value)}
                            leftIcon={<Lock size={18} />}
                            rightIcon={
                                <button
                                    type="button"
                                    onClick={() => setShowPassword(!showPassword)}
                                    className="p-1 hover:bg-gray-100 rounded-lg transition-colors"
                                    tabIndex={-1}
                                >
                                    {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                                </button>
                            }
                            autoComplete="current-password"
                        />

                        <Button
                            type="submit"
                            fullWidth
                            size="lg"
                            isLoading={isLoading}
                        >
                            Sign In
                        </Button>
                    </form>

                    {/* Help text */}
                    <p className="text-center text-sm text-gray-500 mt-6">
                        Contact your administrator if you need access
                    </p>
                </div>

                {/* Footer */}
                <p className="text-center text-sm text-white/80 mt-6">
                    © 2024 GlucoPlot. All rights reserved.
                </p>
            </div>
        </div>
    );
}
