/**
 * Badge component for status indicators
 */

import { ReactNode } from 'react';

type BadgeVariant = 'default' | 'success' | 'warning' | 'error' | 'info';
type BadgeSize = 'sm' | 'md';

interface BadgeProps {
    children: ReactNode;
    variant?: BadgeVariant;
    size?: BadgeSize;
    dot?: boolean;
    className?: string;
}

const variantStyles: Record<BadgeVariant, string> = {
    default: 'bg-gray-100 text-gray-700',
    success: 'bg-green-100 text-green-700',
    warning: 'bg-amber-100 text-amber-700',
    error: 'bg-red-100 text-red-700',
    info: 'bg-blue-100 text-blue-700',
};

const dotColors: Record<BadgeVariant, string> = {
    default: 'bg-gray-400',
    success: 'bg-green-500',
    warning: 'bg-amber-500',
    error: 'bg-red-500',
    info: 'bg-blue-500',
};

const sizeStyles: Record<BadgeSize, string> = {
    sm: 'px-2 py-0.5 text-xs',
    md: 'px-2.5 py-1 text-sm',
};

export function Badge({
    children,
    variant = 'default',
    size = 'sm',
    dot = false,
    className = ''
}: BadgeProps) {
    return (
        <span
            className={`
        inline-flex items-center gap-1.5 font-medium rounded-full
        ${variantStyles[variant]}
        ${sizeStyles[size]}
        ${className}
      `}
        >
            {dot && (
                <span className={`w-1.5 h-1.5 rounded-full ${dotColors[variant]}`} />
            )}
            {children}
        </span>
    );
}

/**
 * Convenience components for common badge types
 */

export function StatusBadge({ status }: { status: 'active' | 'pending' | 'inactive' }) {
    const config: Record<string, { variant: BadgeVariant; label: string }> = {
        active: { variant: 'success', label: 'Active' },
        pending: { variant: 'warning', label: 'Pending' },
        inactive: { variant: 'default', label: 'Inactive' },
    };

    const { variant, label } = config[status] || config.inactive;

    return <Badge variant={variant} dot>{label}</Badge>;
}

export function SeverityBadge({ severity }: { severity: 'low' | 'medium' | 'high' | 'critical' }) {
    const config: Record<string, { variant: BadgeVariant; label: string }> = {
        low: { variant: 'info', label: 'Low' },
        medium: { variant: 'warning', label: 'Medium' },
        high: { variant: 'error', label: 'High' },
        critical: { variant: 'error', label: 'Critical' },
    };

    const { variant, label } = config[severity] || config.low;

    return <Badge variant={variant}>{label}</Badge>;
}
