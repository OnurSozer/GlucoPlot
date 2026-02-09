/**
 * Card component with glassmorphism effect
 */

import { ReactNode } from 'react';

interface CardProps {
    children: ReactNode;
    className?: string;
    onClick?: () => void;
    hover?: boolean;
}

export function Card({ children, className = '', onClick, hover = false }: CardProps) {
    const baseClasses = 'bg-white/80 backdrop-blur-sm rounded-2xl border border-white/50 shadow-md';
    const hoverClasses = hover ? 'transition-all duration-200 hover:shadow-lg hover:scale-[1.01] cursor-pointer' : '';

    return (
        <div
            className={`${baseClasses} ${hoverClasses} ${className}`}
            onClick={onClick}
            role={onClick ? 'button' : undefined}
            tabIndex={onClick ? 0 : undefined}
        >
            {children}
        </div>
    );
}

interface CardHeaderProps {
    children: ReactNode;
    className?: string;
    variant?: 'light' | 'dark' | 'orange';
}

export function CardHeader({ children, className = '', variant = 'light' }: CardHeaderProps) {
    const borderColors = {
        light: 'border-gray-100',
        dark: 'border-slate-700',
        orange: 'border-amber-700/50',
    };
    return (
        <div className={`px-6 py-4 border-b ${borderColors[variant]} ${className}`}>
            {children}
        </div>
    );
}

interface CardContentProps {
    children: ReactNode;
    className?: string;
}

export function CardContent({ children, className = '' }: CardContentProps) {
    return (
        <div className={`p-6 ${className}`}>
            {children}
        </div>
    );
}
