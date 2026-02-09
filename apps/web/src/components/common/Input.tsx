/**
 * Input component with label and error state
 */

import { InputHTMLAttributes, forwardRef, ReactNode } from 'react';

type InputVariant = 'light' | 'dark' | 'orange';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
    label?: string;
    error?: string;
    helperText?: string;
    leftIcon?: ReactNode;
    rightIcon?: ReactNode;
    variant?: InputVariant;
}

const variantStyles = {
    light: {
        label: 'text-gray-700',
        input: 'bg-white/80 border-gray-200 hover:border-gray-300 text-gray-900 placeholder:text-gray-400',
        inputError: 'border-red-300 focus:ring-red-200 focus:border-red-400',
        icon: 'text-gray-400',
        helper: 'text-gray-500',
        error: 'text-red-500',
    },
    dark: {
        label: 'text-slate-300',
        input: 'bg-slate-700 border-slate-600 hover:border-slate-500 text-white placeholder:text-slate-400',
        inputError: 'border-red-500 focus:ring-red-500/30 focus:border-red-500',
        icon: 'text-slate-400',
        helper: 'text-slate-400',
        error: 'text-red-400',
    },
    orange: {
        label: 'text-amber-200',
        input: 'bg-amber-900/50 border-amber-700 hover:border-amber-600 text-white placeholder:text-amber-400',
        inputError: 'border-red-500 focus:ring-red-500/30 focus:border-red-500',
        icon: 'text-amber-400',
        helper: 'text-amber-400',
        error: 'text-red-400',
    },
};

export const Input = forwardRef<HTMLInputElement, InputProps>(
    ({ label, error, helperText, leftIcon, rightIcon, variant = 'light', className = '', id, ...props }, ref) => {
        const inputId = id || `input-${Math.random().toString(36).substr(2, 9)}`;
        const styles = variantStyles[variant];

        return (
            <div className="w-full">
                {label && (
                    <label
                        htmlFor={inputId}
                        className={`block text-sm font-medium mb-1.5 ${styles.label}`}
                    >
                        {label}
                    </label>
                )}
                <div className="relative">
                    {leftIcon && (
                        <div className={`absolute left-3 top-1/2 -translate-y-1/2 ${styles.icon}`}>
                            {leftIcon}
                        </div>
                    )}
                    <input
                        ref={ref}
                        id={inputId}
                        className={`
              w-full px-4 py-2.5 rounded-xl border backdrop-blur-sm
              transition-all duration-200
              focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary
              ${leftIcon ? 'pl-10' : ''}
              ${rightIcon ? 'pr-10' : ''}
              ${error ? styles.inputError : styles.input}
              ${className}
            `}
                        {...props}
                    />
                    {rightIcon && (
                        <div className={`absolute right-3 top-1/2 -translate-y-1/2 ${styles.icon}`}>
                            {rightIcon}
                        </div>
                    )}
                </div>
                {error && (
                    <p className={`mt-1.5 text-sm ${styles.error}`}>{error}</p>
                )}
                {!error && helperText && (
                    <p className={`mt-1.5 text-sm ${styles.helper}`}>{helperText}</p>
                )}
            </div>
        );
    }
);

Input.displayName = 'Input';
