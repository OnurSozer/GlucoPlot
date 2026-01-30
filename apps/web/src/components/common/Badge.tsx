/**
 * Badge component for status indicators
 */

import { ReactNode } from 'react';
import { useTranslation } from 'react-i18next';

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
    const { t } = useTranslation('patients');

    const config: Record<string, { variant: BadgeVariant; labelKey: string }> = {
        active: { variant: 'success', labelKey: 'status.active' },
        pending: { variant: 'warning', labelKey: 'status.pending' },
        inactive: { variant: 'default', labelKey: 'status.inactive' },
    };

    const { variant, labelKey } = config[status] || config.inactive;

    return <Badge variant={variant} dot>{t(labelKey)}</Badge>;
}

export function SeverityBadge({ severity }: { severity: 'low' | 'medium' | 'high' | 'critical' }) {
    const { t } = useTranslation('common');

    const config: Record<string, { variant: BadgeVariant; labelKey: string }> = {
        low: { variant: 'info', labelKey: 'severity.low' },
        medium: { variant: 'warning', labelKey: 'severity.medium' },
        high: { variant: 'error', labelKey: 'severity.high' },
        critical: { variant: 'error', labelKey: 'severity.critical' },
    };

    const { variant, labelKey } = config[severity] || config.low;

    return <Badge variant={variant}>{t(labelKey)}</Badge>;
}
