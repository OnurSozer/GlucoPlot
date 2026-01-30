/**
 * Measurement Chart - Line chart for patient measurements
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
import type { MeasurementType, Measurement } from '../../types/database.types';

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

export function MeasurementChart({ patientId, type, days = 14 }: MeasurementChartProps) {
    const [data, setData] = useState<ChartDataPoint[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [stats, setStats] = useState<{ min: number; max: number; avg: number } | null>(null);

    useEffect(() => {
        const abortController = new AbortController();

        const loadChartData = async () => {
            try {
                setIsLoading(true);

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
            } catch (error) {
                if (abortController.signal.aborted) return;
                console.error('Error loading chart data:', error);
                setData([]);
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
    }, [patientId, type, days]);

    const color = getMeasurementColor(type);

    if (isLoading) {
        return (
            <div className="h-64 bg-gray-50 rounded-xl animate-pulse flex items-center justify-center">
                <p className="text-gray-400">Loading chart...</p>
            </div>
        );
    }

    if (data.length === 0) {
        return (
            <div className="h-64 bg-gray-50 rounded-xl flex flex-col items-center justify-center">
                <p className="text-gray-500">No measurement data available</p>
                <p className="text-sm text-gray-400 mt-1">Measurements will appear here once recorded</p>
            </div>
        );
    }

    return (
        <div>
            {/* Stats Bar */}
            {stats && (
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
            )}

            {/* Chart */}
            <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                    <AreaChart data={data} margin={{ top: 10, right: 10, left: 0, bottom: 0 }}>
                        <defs>
                            <linearGradient id={`gradient-${type}`} x1="0" y1="0" x2="0" y2="1">
                                <stop offset="5%" stopColor={color} stopOpacity={0.3} />
                                <stop offset="95%" stopColor={color} stopOpacity={0} />
                            </linearGradient>
                        </defs>
                        <CartesianGrid strokeDasharray="3 3" stroke="#E5E7EB" vertical={false} />
                        <XAxis
                            dataKey="date"
                            tick={{ fontSize: 12, fill: '#6B7280' }}
                            tickLine={false}
                            axisLine={{ stroke: '#E5E7EB' }}
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
                                    const data = payload[0].payload as ChartDataPoint;
                                    return (
                                        <div className="bg-white p-3 rounded-lg shadow-lg border border-gray-100">
                                            <p className="text-sm font-medium text-gray-900">
                                                {data.value}
                                                {data.secondary && `/${data.secondary}`}
                                            </p>
                                            <p className="text-xs text-gray-500 mt-1">{data.fullDate}</p>
                                        </div>
                                    );
                                }
                                return null;
                            }}
                        />
                        <Area
                            type="monotone"
                            dataKey="value"
                            stroke={color}
                            strokeWidth={2}
                            fill={`url(#gradient-${type})`}
                            dot={{ r: 4, fill: color, strokeWidth: 2, stroke: '#fff' }}
                            activeDot={{ r: 6, fill: color, strokeWidth: 2, stroke: '#fff' }}
                        />
                    </AreaChart>
                </ResponsiveContainer>
            </div>
        </div>
    );
}
