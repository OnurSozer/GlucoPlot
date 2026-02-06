/**
 * Measurement Chart - Line chart for patient measurements
 * For glucose measurements, shows separate lines for fasting/post_meal/other
 */

import { useState, useEffect } from 'react';
import {
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    ResponsiveContainer,
    Area,
    AreaChart
} from 'recharts';
import { measurementsService } from '../../services/measurements.service';
import { formatDate, getMeasurementColor } from '../../utils/format';
import type { MeasurementType, Measurement, MealTiming } from '../../types/database.types';

interface MeasurementChartProps {
    patientId: string;
    type: MeasurementType;
    days?: number;
}

interface ChartDataPoint {
    date: string;
    value: number;
    secondary?: number;
    fullDate: string;
}

interface GlucoseChartDataPoint {
    timestamp: number; // Unix timestamp for sorting
    date: string; // Formatted for x-axis (e.g., "Jan 15 08:30")
    fasting?: number;
    post_meal?: number;
    other?: number;
    fullDate: string; // Full date for tooltip
}

// Meal timing display configuration
const MEAL_TIMING_CONFIG: Record<MealTiming, { color: string; label: string }> = {
    fasting: { color: '#3B82F6', label: 'Fasting' },
    post_meal: { color: '#F97316', label: 'After Meal' },
    other: { color: '#6B7280', label: 'Other' },
};

export function MeasurementChart({ patientId, type, days = 14 }: MeasurementChartProps) {
    const [data, setData] = useState<ChartDataPoint[]>([]);
    const [glucoseData, setGlucoseData] = useState<GlucoseChartDataPoint[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [stats, setStats] = useState<{ min: number; max: number; avg: number } | null>(null);
    const [glucoseStats, setGlucoseStats] = useState<Record<MealTiming | 'all', { min: number; max: number; avg: number; count: number } | null> | null>(null);

    // Visibility state for glucose meal timing lines (default: show fasting and post_meal)
    const [visibleTimings, setVisibleTimings] = useState<Set<MealTiming>>(
        new Set(['fasting', 'post_meal'])
    );

    const isGlucoseChart = type === 'glucose';

    useEffect(() => {
        const abortController = new AbortController();

        const loadChartData = async () => {
            try {
                setIsLoading(true);

                if (isGlucoseChart) {
                    // Load glucose data with meal timing
                    const result = await measurementsService.getGlucoseChartData(patientId, days);

                    if (abortController.signal.aborted) return;

                    if (result.data && result.data.length > 0) {
                        // Create individual data points for each measurement (no grouping)
                        const chartPoints: GlucoseChartDataPoint[] = result.data.map((m) => {
                            const timing = m.meal_timing || 'other';
                            const timestamp = new Date(m.measured_at).getTime();

                            const point: GlucoseChartDataPoint = {
                                timestamp,
                                date: formatDate(m.measured_at, 'MMM d HH:mm'),
                                fullDate: formatDate(m.measured_at, 'MMM d, yyyy h:mm a'),
                            };

                            // Set only the value for this measurement's timing
                            point[timing] = m.value_primary;

                            return point;
                        });

                        // Sort by timestamp to ensure correct line connections
                        chartPoints.sort((a, b) => a.timestamp - b.timestamp);

                        setGlucoseData(chartPoints);
                        setGlucoseStats(result.stats);
                    } else {
                        setGlucoseData([]);
                        setGlucoseStats(null);
                    }
                } else {
                    // Load regular measurement data
                    const { data: measurements, stats: measurementStats } = await measurementsService.getMeasurementStats(
                        patientId,
                        type,
                        days
                    );

                    if (abortController.signal.aborted) return;

                    if (measurements) {
                        const chartData: ChartDataPoint[] = measurements.map((m: Measurement) => ({
                            date: formatDate(m.measured_at, 'MMM d'),
                            value: m.value_primary,
                            secondary: m.value_secondary || undefined,
                            fullDate: formatDate(m.measured_at, 'MMM d, yyyy h:mm a'),
                        }));

                        setData(chartData);
                        setStats(measurementStats);
                    } else {
                        setData([]);
                        setStats(null);
                    }
                }
            } catch (error) {
                if (abortController.signal.aborted) return;
                console.error('Error loading chart data:', error);
                setData([]);
                setGlucoseData([]);
            } finally {
                if (!abortController.signal.aborted) {
                    setIsLoading(false);
                }
            }
        };

        loadChartData();

        return () => {
            abortController.abort();
        };
    }, [patientId, type, days, isGlucoseChart]);

    const toggleTiming = (timing: MealTiming) => {
        setVisibleTimings(prev => {
            const next = new Set(prev);
            if (next.has(timing)) {
                next.delete(timing);
            } else {
                next.add(timing);
            }
            return next;
        });
    };

    const color = getMeasurementColor(type);
    const chartData = isGlucoseChart ? glucoseData : data;
    const hasData = chartData.length > 0;

    if (isLoading) {
        return (
            <div className="h-64 bg-gray-50 rounded-xl animate-pulse flex items-center justify-center">
                <p className="text-gray-400">Loading chart...</p>
            </div>
        );
    }

    if (!hasData) {
        return (
            <div className="h-64 bg-gray-50 rounded-xl flex flex-col items-center justify-center">
                <p className="text-gray-500">No measurement data available</p>
                <p className="text-sm text-gray-400 mt-1">Measurements will appear here once recorded</p>
            </div>
        );
    }

    return (
        <div>
            {/* Meal Timing Toggles (glucose only) */}
            {isGlucoseChart && (
                <div className="flex flex-wrap items-center gap-4 mb-4">
                    {(Object.keys(MEAL_TIMING_CONFIG) as MealTiming[]).map((timing) => {
                        const config = MEAL_TIMING_CONFIG[timing];
                        const isVisible = visibleTimings.has(timing);
                        const timingStats = glucoseStats?.[timing];

                        return (
                            <label
                                key={timing}
                                className={`flex items-center gap-2 cursor-pointer px-3 py-1.5 rounded-full transition-colors ${
                                    isVisible
                                        ? 'bg-gray-100 hover:bg-gray-200'
                                        : 'bg-gray-50 opacity-60 hover:opacity-80'
                                }`}
                            >
                                <input
                                    type="checkbox"
                                    checked={isVisible}
                                    onChange={() => toggleTiming(timing)}
                                    className="sr-only"
                                />
                                <span
                                    className="w-3 h-3 rounded-full flex-shrink-0"
                                    style={{ backgroundColor: config.color, opacity: isVisible ? 1 : 0.4 }}
                                />
                                <span className={`text-sm font-medium ${isVisible ? 'text-gray-700' : 'text-gray-400'}`}>
                                    {config.label}
                                </span>
                                {timingStats && (
                                    <span className="text-xs text-gray-400 ml-1">
                                        ({timingStats.count})
                                    </span>
                                )}
                            </label>
                        );
                    })}
                </div>
            )}

            {/* Stats Bar */}
            {isGlucoseChart ? (
                glucoseStats?.all && (
                    <div className="flex items-center gap-6 mb-6 text-sm">
                        <div>
                            <span className="text-gray-500">Min:</span>
                            <span className="ml-2 font-medium text-gray-900">{glucoseStats.all.min.toFixed(0)}</span>
                        </div>
                        <div>
                            <span className="text-gray-500">Max:</span>
                            <span className="ml-2 font-medium text-gray-900">{glucoseStats.all.max.toFixed(0)}</span>
                        </div>
                        <div>
                            <span className="text-gray-500">Avg:</span>
                            <span className="ml-2 font-medium text-gray-900">{glucoseStats.all.avg.toFixed(0)}</span>
                        </div>
                    </div>
                )
            ) : (
                stats && (
                    <div className="flex items-center gap-6 mb-6 text-sm">
                        <div>
                            <span className="text-gray-500">Min:</span>
                            <span className="ml-2 font-medium text-gray-900">{stats.min.toFixed(1)}</span>
                        </div>
                        <div>
                            <span className="text-gray-500">Max:</span>
                            <span className="ml-2 font-medium text-gray-900">{stats.max.toFixed(1)}</span>
                        </div>
                        <div>
                            <span className="text-gray-500">Avg:</span>
                            <span className="ml-2 font-medium text-gray-900">{stats.avg.toFixed(1)}</span>
                        </div>
                    </div>
                )
            )}

            {/* Chart */}
            <div className={isGlucoseChart ? "h-80" : "h-64"}>
                <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={chartData} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                        <defs>
                            {isGlucoseChart ? (
                                <>
                                    <linearGradient id="gradient-fasting" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor={MEAL_TIMING_CONFIG.fasting.color} stopOpacity={0.3} />
                                        <stop offset="95%" stopColor={MEAL_TIMING_CONFIG.fasting.color} stopOpacity={0} />
                                    </linearGradient>
                                    <linearGradient id="gradient-post_meal" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor={MEAL_TIMING_CONFIG.post_meal.color} stopOpacity={0.3} />
                                        <stop offset="95%" stopColor={MEAL_TIMING_CONFIG.post_meal.color} stopOpacity={0} />
                                    </linearGradient>
                                    <linearGradient id="gradient-other" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor={MEAL_TIMING_CONFIG.other.color} stopOpacity={0.3} />
                                        <stop offset="95%" stopColor={MEAL_TIMING_CONFIG.other.color} stopOpacity={0} />
                                    </linearGradient>
                                </>
                            ) : (
                                <linearGradient id={`gradient-${type}`} x1="0" y1="0" x2="0" y2="1">
                                    <stop offset="5%" stopColor={color} stopOpacity={0.3} />
                                    <stop offset="95%" stopColor={color} stopOpacity={0} />
                                </linearGradient>
                            )}
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" vertical={false} />
                        <XAxis
                            dataKey="date"
                            tick={{ fontSize: isGlucoseChart ? 11 : 12, fill: '#6B7280' }}
                            tickLine={false}
                            axisLine={{ stroke: '#E5E7EB' }}
                            {...(isGlucoseChart ? {
                                interval: 'preserveStartEnd',
                                angle: -45,
                                textAnchor: 'end',
                                height: 60,
                            } : {})}
                        />
                        <YAxis
                            tick={{ fontSize: 12, fill: '#6B7280' }}
                            tickLine={false}
                            axisLine={false}
                            width={40}
                        />
                        <Tooltip
                            content={({ active, payload }) => {
                                if (active && payload && payload.length) {
                                    if (isGlucoseChart) {
                                        const point = payload[0].payload as GlucoseChartDataPoint;
                                        return (
                                            <div className="bg-white p-3 rounded-lg shadow-lg border border-gray-100">
                                                <p className="text-xs text-gray-500 mb-2">{point.fullDate}</p>
                                                {payload.map((entry, index) => {
                                                    const timing = entry.dataKey as MealTiming;
                                                    const config = MEAL_TIMING_CONFIG[timing];
                                                    return (
                                                        <div key={index} className="flex items-center gap-2">
                                                            <span
                                                                className="w-2 h-2 rounded-full"
                                                                style={{ backgroundColor: config.color }}
                                                            />
                                                            <span className="text-sm text-gray-600">{config.label}:</span>
                                                            <span className="text-sm font-medium text-gray-900">
                                                                {entry.value} mg/dL
                                                            </span>
                                                        </div>
                                                    );
                                                })}
                                            </div>
                                        );
                                    } else {
                                        const point = payload[0].payload as ChartDataPoint;
                                        return (
                                            <div className="bg-white p-3 rounded-lg shadow-lg border border-gray-100">
                                                <p className="text-sm font-medium text-gray-900">
                                                    {point.value}
                                                    {point.secondary && `/${point.secondary}`}
                                                </p>
                                                <p className="text-xs text-gray-500 mt-1">{point.fullDate}</p>
                                            </div>
                                        );
                                    }
                                }
                                return null;
                            }}
                        />
                        {isGlucoseChart ? (
                            <>
                                {visibleTimings.has('fasting') && (
                                    <Area
                                        type="monotone"
                                        dataKey="fasting"
                                        name="Fasting"
                                        stroke={MEAL_TIMING_CONFIG.fasting.color}
                                        strokeWidth={2}
                                        fill="url(#gradient-fasting)"
                                        dot={{ r: 4, fill: MEAL_TIMING_CONFIG.fasting.color, strokeWidth: 2, stroke: '#fff' }}
                                        activeDot={{ r: 6, fill: MEAL_TIMING_CONFIG.fasting.color, strokeWidth: 2, stroke: '#fff' }}
                                        connectNulls
                                    />
                                )}
                                {visibleTimings.has('post_meal') && (
                                    <Area
                                        type="monotone"
                                        dataKey="post_meal"
                                        name="After Meal"
                                        stroke={MEAL_TIMING_CONFIG.post_meal.color}
                                        strokeWidth={2}
                                        fill="url(#gradient-post_meal)"
                                        dot={{ r: 4, fill: MEAL_TIMING_CONFIG.post_meal.color, strokeWidth: 2, stroke: '#fff' }}
                                        activeDot={{ r: 6, fill: MEAL_TIMING_CONFIG.post_meal.color, strokeWidth: 2, stroke: '#fff' }}
                                        connectNulls
                                    />
                                )}
                                {visibleTimings.has('other') && (
                                    <Area
                                        type="monotone"
                                        dataKey="other"
                                        name="Other"
                                        stroke={MEAL_TIMING_CONFIG.other.color}
                                        strokeWidth={2}
                                        fill="url(#gradient-other)"
                                        dot={{ r: 4, fill: MEAL_TIMING_CONFIG.other.color, strokeWidth: 2, stroke: '#fff' }}
                                        activeDot={{ r: 6, fill: MEAL_TIMING_CONFIG.other.color, strokeWidth: 2, stroke: '#fff' }}
                                        connectNulls
                                    />
                                )}
                            </>
                        ) : (
                            <Area
                                type="monotone"
                                dataKey="value"
                                stroke={color}
                                strokeWidth={2}
                                fill={`url(#gradient-${type})`}
                                dot={{ r: 4, fill: color, strokeWidth: 2, stroke: '#fff' }}
                                activeDot={{ r: 6, fill: color, strokeWidth: 2, stroke: '#fff' }}
                            />
                        )}
                    </AreaChart>
                </ResponsiveContainer>
            </div>
        </div>
    );
}
