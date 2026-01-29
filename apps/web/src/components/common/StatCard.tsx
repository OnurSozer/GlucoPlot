/**
 * StatCard component for dashboard statistics
 */

import { ReactNode } from 'react';
import { TrendingUp, TrendingDown, Minus } from 'lucide-react';

interface StatCardProps {
    title: string;
    value: string | number;
    subtitle?: string;
    icon?: ReactNode;
    trend?: {
        value: number;
        label?: string;
    };
    color?: string;
    className?: string;
}

export function StatCard({
    title,
    value,
    subtitle,
    icon,
    trend,
    color = '#E8A87C',
    className = '',
}: StatCardProps) {
    const trendDirection = trend ? (trend.value > 0 ? 'up' : trend.value < 0 ? 'down' : 'neutral') : null;

    return (
        <div
            className={`
        bg-white/80 backdrop-blur-sm rounded-2xl border border-white/50 shadow-md
        p-6 transition-all duration-200 hover:shadow-lg
        ${className}
      `}
        >
            <div className="flex items-start justify-between">
                <div className="flex-1">
                    <p className="text-sm font-medium text-gray-500 mb-1">{title}</p>
                    <p className="text-3xl font-bold text-gray-900">{value}</p>
                    {subtitle && (
                        <p className="text-sm text-gray-500 mt-1">{subtitle}</p>
                    )}
                    {trend && (
                        <div className="flex items-center gap-1 mt-2">
                            {trendDirection === 'up' && (
                                <TrendingUp size={16} className="text-green-500" />
                            )}
                            {trendDirection === 'down' && (
                                <TrendingDown size={16} className="text-red-500" />
                            )}
                            {trendDirection === 'neutral' && (
                                <Minus size={16} className="text-gray-400" />
                            )}
                            <span
                                className={`text-sm font-medium ${trendDirection === 'up'
                                        ? 'text-green-600'
                                        : trendDirection === 'down'
                                            ? 'text-red-600'
                                            : 'text-gray-500'
                                    }`}
                            >
                                {trend.value > 0 ? '+' : ''}{trend.value}%
                            </span>
                            {trend.label && (
                                <span className="text-sm text-gray-400 ml-1">{trend.label}</span>
                            )}
                        </div>
                    )}
                </div>

                {icon && (
                    <div
                        className="p-3 rounded-xl"
                        style={{ backgroundColor: `${color}20` }}
                    >
                        <div style={{ color }}>
                            {icon}
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}
