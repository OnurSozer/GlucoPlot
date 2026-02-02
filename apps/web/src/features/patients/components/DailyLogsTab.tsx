/**
 * DailyLogsTab - Tab content for viewing patient daily logs
 */

import { useState, useEffect, useRef, useMemo } from 'react';
import { useTranslation } from 'react-i18next';
import {
    UtensilsCrossed,
    Moon,
    Dumbbell,
    Pill,
    FileText,
    CalendarDays,
    ChevronLeft,
    ChevronRight,
    ChevronDown,
    Filter,
    Droplets,
    Wine,
    Bath,
    Brain
} from 'lucide-react';
import { format, subDays, addDays, isToday, parseISO } from 'date-fns';
import { Card, CardContent } from '../../../components/common/Card';
import { DailyLogCard } from './DailyLogCard';
import { dailyLogsService } from '../../../services/daily-logs.service';
import type { DailyLog } from '../../../types/database.types';

interface DailyLogsTabProps {
    patientId: string;
}

// Filter types including subtypes
type FilterType = 'food' | 'sleep' | 'exercise' | 'medication' | 'water' | 'alcohol' | 'toilet' | 'stress';

interface FilterConfig {
    id: FilterType;
    label: string;
    icon: typeof FileText;
    color: string;
    // How to match this filter
    matcher: (log: DailyLog) => boolean;
}

const FILTER_CONFIGS: FilterConfig[] = [
    {
        id: 'food',
        label: 'Meal',
        icon: UtensilsCrossed,
        color: '#FF9F43',
        matcher: (log) => log.log_type === 'food',
    },
    {
        id: 'sleep',
        label: 'Sleep',
        icon: Moon,
        color: '#6C5CE7',
        matcher: (log) => log.log_type === 'sleep',
    },
    {
        id: 'exercise',
        label: 'Exercise',
        icon: Dumbbell,
        color: '#00B894',
        matcher: (log) => log.log_type === 'exercise',
    },
    {
        id: 'medication',
        label: 'Medication',
        icon: Pill,
        color: '#E84393',
        matcher: (log) => log.log_type === 'medication',
    },
    {
        id: 'water',
        label: 'Water',
        icon: Droplets,
        color: '#0984E3',
        matcher: (log) => log.log_type === 'note' && (log.metadata?.type === 'water' || log.metadata?.sub_type === 'water'),
    },
    {
        id: 'alcohol',
        label: 'Alcohol',
        icon: Wine,
        color: '#D63031',
        matcher: (log) => log.log_type === 'note' && (log.metadata?.type === 'alcohol' || log.metadata?.sub_type === 'alcohol'),
    },
    {
        id: 'toilet',
        label: 'Toilet',
        icon: Bath,
        color: '#636E72',
        matcher: (log) => log.log_type === 'note' && (log.metadata?.type === 'toilet' || log.metadata?.sub_type === 'toilet'),
    },
    {
        id: 'stress',
        label: 'Stress',
        icon: Brain,
        color: '#FD79A8',
        matcher: (log) => log.log_type === 'symptom',
    },
];

export function DailyLogsTab({ patientId }: DailyLogsTabProps) {
    const { t } = useTranslation('dailyLogs');
    const [allLogs, setAllLogs] = useState<DailyLog[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [selectedDate, setSelectedDate] = useState<Date>(new Date());
    const [selectedFilter, setSelectedFilter] = useState<FilterType | null>(null);
    const [error, setError] = useState<string | null>(null);
    const dateInputRef = useRef<HTMLInputElement>(null);

    useEffect(() => {
        const abortController = new AbortController();

        const loadLogs = async () => {
            try {
                setIsLoading(true);
                setError(null);

                const dateStr = format(selectedDate, 'yyyy-MM-dd');

                // Load all logs for the date (no type filter at API level)
                const { data, error: fetchError } = await dailyLogsService.getDailyLogs({
                    patientId,
                    startDate: dateStr,
                    endDate: dateStr,
                    limit: 100,
                });

                if (abortController.signal.aborted) return;

                if (fetchError) {
                    setError(fetchError.message);
                } else {
                    setAllLogs(data || []);
                }
            } catch (err) {
                if (abortController.signal.aborted) return;
                setError('Failed to load logs');
                console.error('Error loading daily logs:', err);
            } finally {
                if (!abortController.signal.aborted) {
                    setIsLoading(false);
                }
            }
        };

        loadLogs();

        return () => {
            abortController.abort();
        };
    }, [patientId, selectedDate]);

    // Filter logs client-side based on selected filter
    const filteredLogs = useMemo(() => {
        if (!selectedFilter) return allLogs;

        const config = FILTER_CONFIGS.find(c => c.id === selectedFilter);
        if (!config) return allLogs;

        return allLogs.filter(config.matcher);
    }, [allLogs, selectedFilter]);

    // Count logs for each filter type
    const filterCounts = useMemo(() => {
        const counts: Record<FilterType, number> = {
            food: 0,
            sleep: 0,
            exercise: 0,
            medication: 0,
            water: 0,
            alcohol: 0,
            toilet: 0,
            stress: 0,
        };

        for (const log of allLogs) {
            for (const config of FILTER_CONFIGS) {
                if (config.matcher(log)) {
                    counts[config.id]++;
                    break; // Each log only counts once
                }
            }
        }

        return counts;
    }, [allLogs]);

    const handlePrevDay = () => {
        setSelectedDate(prev => subDays(prev, 1));
    };

    const handleNextDay = () => {
        if (!isToday(selectedDate)) {
            setSelectedDate(prev => addDays(prev, 1));
        }
    };

    const handleFilterClick = (filter: FilterType | null) => {
        setSelectedFilter(prev => prev === filter ? null : filter);
    };

    const handleDatePickerClick = () => {
        dateInputRef.current?.showPicker();
    };

    const handleDateChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        if (e.target.value) {
            const newDate = parseISO(e.target.value);
            if (newDate <= new Date()) {
                setSelectedDate(newDate);
            }
        }
    };

    // Group logs by time of day
    const groupedLogs = filteredLogs.reduce((acc, log) => {
        const hour = new Date(log.logged_at).getHours();
        let period: string;
        if (hour < 12) period = 'morning';
        else if (hour < 17) period = 'afternoon';
        else period = 'evening';

        if (!acc[period]) acc[period] = [];
        acc[period].push(log);
        return acc;
    }, {} as Record<string, DailyLog[]>);

    const periodLabels: Record<string, string> = {
        morning: t('morning'),
        afternoon: t('afternoon'),
        evening: t('evening'),
    };

    return (
        <div className="space-y-4">
            {/* Date Picker */}
            <Card>
                <CardContent className="py-3">
                    <div className="flex items-center justify-between">
                        <button
                            onClick={handlePrevDay}
                            className="p-2 hover:bg-gray-100 rounded-lg transition-colors"
                        >
                            <ChevronLeft size={20} className="text-gray-500" />
                        </button>

                        <button
                            onClick={handleDatePickerClick}
                            className="flex items-center gap-3 px-4 py-2 hover:bg-gray-50 rounded-lg transition-colors cursor-pointer"
                        >
                            <CalendarDays size={18} className="text-primary" />
                            <div className="text-center">
                                {isToday(selectedDate) && (
                                    <p className="text-sm font-medium text-primary">{t('today')}</p>
                                )}
                                <p className={`text-sm ${isToday(selectedDate) ? 'text-gray-500' : 'font-medium text-gray-900'}`}>
                                    {format(selectedDate, 'EEEE, MMMM d, yyyy')}
                                </p>
                            </div>
                            <ChevronDown size={16} className="text-gray-400" />
                            <input
                                ref={dateInputRef}
                                type="date"
                                value={format(selectedDate, 'yyyy-MM-dd')}
                                max={format(new Date(), 'yyyy-MM-dd')}
                                onChange={handleDateChange}
                                className="absolute opacity-0 w-0 h-0 pointer-events-none"
                            />
                        </button>

                        <button
                            onClick={handleNextDay}
                            disabled={isToday(selectedDate)}
                            className={`p-2 rounded-lg transition-colors ${
                                isToday(selectedDate)
                                    ? 'text-gray-300 cursor-not-allowed'
                                    : 'hover:bg-gray-100 text-gray-500'
                            }`}
                        >
                            <ChevronRight size={20} />
                        </button>
                    </div>
                </CardContent>
            </Card>

            {/* Type Filters */}
            <div className="flex items-center gap-2 overflow-x-auto pb-2">
                <div className="flex items-center gap-1 text-gray-500 shrink-0">
                    <Filter size={14} />
                    <span className="text-xs">{t('filter')}:</span>
                </div>
                <button
                    onClick={() => handleFilterClick(null)}
                    className={`px-3 py-1.5 rounded-full text-xs font-medium transition-colors shrink-0 ${
                        selectedFilter === null
                            ? 'bg-primary text-white'
                            : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                    }`}
                >
                    {t('all')}
                </button>
                {FILTER_CONFIGS.map(config => {
                    const Icon = config.icon;
                    const isSelected = selectedFilter === config.id;

                    return (
                        <button
                            key={config.id}
                            onClick={() => handleFilterClick(config.id)}
                            className={`px-3 py-1.5 rounded-full text-xs font-medium transition-colors shrink-0 flex items-center gap-1.5 ${
                                isSelected
                                    ? 'text-white'
                                    : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                            }`}
                            style={isSelected ? { backgroundColor: config.color } : undefined}
                        >
                            <Icon size={12} />
                            {config.label}
                        </button>
                    );
                })}
            </div>

            {/* Content */}
            {isLoading ? (
                <div className="space-y-3">
                    {[1, 2, 3].map(i => (
                        <div key={i} className="h-20 bg-gray-100 rounded-xl animate-pulse" />
                    ))}
                </div>
            ) : error ? (
                <Card>
                    <CardContent className="py-8 text-center">
                        <p className="text-red-500">{error}</p>
                        <button
                            onClick={() => setSelectedDate(new Date(selectedDate))}
                            className="mt-2 text-sm text-primary hover:underline"
                        >
                            {t('retry')}
                        </button>
                    </CardContent>
                </Card>
            ) : filteredLogs.length === 0 ? (
                <Card>
                    <CardContent className="py-12 text-center">
                        <div className="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
                            <FileText size={24} className="text-gray-400" />
                        </div>
                        <h3 className="text-lg font-medium text-gray-900 mb-1">
                            {t('noLogs')}
                        </h3>
                        <p className="text-gray-500 text-sm">
                            {isToday(selectedDate) ? t('noLogsToday') : t('noLogsDate')}
                        </p>
                    </CardContent>
                </Card>
            ) : (
                <div className="space-y-6">
                    {/* Summary stats */}
                    <div className="grid grid-cols-4 md:grid-cols-8 gap-2">
                        {FILTER_CONFIGS.map(config => {
                            const Icon = config.icon;
                            const count = filterCounts[config.id];

                            return (
                                <button
                                    key={config.id}
                                    onClick={() => handleFilterClick(config.id)}
                                    className={`p-3 rounded-xl border text-center transition-colors ${
                                        selectedFilter === config.id
                                            ? 'border-gray-300 bg-gray-50'
                                            : 'border-gray-100 bg-white hover:bg-gray-50'
                                    }`}
                                >
                                    <Icon size={18} style={{ color: config.color }} className="mx-auto mb-1" />
                                    <p className="text-lg font-bold text-gray-900">{count}</p>
                                    <p className="text-xs text-gray-500">{config.label}</p>
                                </button>
                            );
                        })}
                    </div>

                    {/* Grouped logs */}
                    {['morning', 'afternoon', 'evening'].map(period => {
                        const periodLogs = groupedLogs[period];
                        if (!periodLogs || periodLogs.length === 0) return null;

                        return (
                            <div key={period}>
                                <h3 className="text-sm font-medium text-gray-500 mb-3 uppercase tracking-wide">
                                    {periodLabels[period]} ({periodLogs.length})
                                </h3>
                                <div className="space-y-2">
                                    {periodLogs.map(log => (
                                        <DailyLogCard key={log.id} log={log} />
                                    ))}
                                </div>
                            </div>
                        );
                    })}
                </div>
            )}
        </div>
    );
}
