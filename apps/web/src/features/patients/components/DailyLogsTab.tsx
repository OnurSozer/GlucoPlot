/**
 * DailyLogsTab - Tab content for viewing patient daily logs and measurements
 * Uses SWR pattern via TanStack Query for instant cached data display
 */

import { useState, useRef, useMemo } from 'react';
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
    Brain,
    Activity,
    Heart,
    RefreshCw
} from 'lucide-react';
import { format, subDays, addDays, isToday, parseISO } from 'date-fns';
import { tr, enUS } from 'date-fns/locale';
import { Card, CardContent } from '../../../components/common/Card';
import { DailyLogCard } from './DailyLogCard';
import { useDailyLogs, useMeasurements } from '../../../hooks/queries';
import type { DailyLog, Measurement, MealTiming } from '../../../types/database.types';

interface DailyLogsTabProps {
    patientId: string;
}

// Filter types including subtypes and measurements
type FilterType = 'glucose' | 'blood_pressure' | 'food' | 'sleep' | 'exercise' | 'medication' | 'water' | 'alcohol' | 'toilet' | 'stress';

// Unified item type for both logs and measurements
interface UnifiedItem {
    id: string;
    type: 'log' | 'measurement';
    timestamp: Date;
    data: DailyLog | Measurement;
}

interface FilterConfig {
    id: FilterType;
    label: string;
    icon: typeof FileText;
    color: string;
    // Type of item this filter applies to
    itemType: 'log' | 'measurement' | 'both';
    // How to match this filter
    matcher: (item: UnifiedItem) => boolean;
}

// Meal timing display configuration
const MEAL_TIMING_CONFIG: Record<MealTiming, { color: string; label: string; labelTr: string }> = {
    fasting: { color: '#3B82F6', label: 'Fasting', labelTr: 'Açlık' },
    post_meal: { color: '#F97316', label: 'After Meal', labelTr: 'Tokluk' },
    other: { color: '#6B7280', label: 'Other', labelTr: 'Diğer' },
};

const FILTER_CONFIGS: FilterConfig[] = [
    {
        id: 'glucose',
        label: 'Glucose',
        icon: Activity,
        color: '#EF4444',
        itemType: 'measurement',
        matcher: (item) => item.type === 'measurement' && (item.data as Measurement).type === 'glucose',
    },
    {
        id: 'blood_pressure',
        label: 'Blood Pressure',
        icon: Heart,
        color: '#EC4899',
        itemType: 'measurement',
        matcher: (item) => item.type === 'measurement' && (item.data as Measurement).type === 'blood_pressure',
    },
    {
        id: 'food',
        label: 'Meal',
        icon: UtensilsCrossed,
        color: '#FF9F43',
        itemType: 'log',
        matcher: (item) => item.type === 'log' && (item.data as DailyLog).log_type === 'food',
    },
    {
        id: 'sleep',
        label: 'Sleep',
        icon: Moon,
        color: '#6C5CE7',
        itemType: 'log',
        matcher: (item) => item.type === 'log' && (item.data as DailyLog).log_type === 'sleep',
    },
    {
        id: 'exercise',
        label: 'Exercise',
        icon: Dumbbell,
        color: '#00B894',
        itemType: 'log',
        matcher: (item) => item.type === 'log' && (item.data as DailyLog).log_type === 'exercise',
    },
    {
        id: 'medication',
        label: 'Medication',
        icon: Pill,
        color: '#E84393',
        itemType: 'log',
        matcher: (item) => item.type === 'log' && (item.data as DailyLog).log_type === 'medication',
    },
    {
        id: 'water',
        label: 'Water',
        icon: Droplets,
        color: '#0984E3',
        itemType: 'log',
        matcher: (item) => {
            if (item.type !== 'log') return false;
            const log = item.data as DailyLog;
            return log.log_type === 'note' && (log.metadata?.type === 'water' || log.metadata?.sub_type === 'water');
        },
    },
    {
        id: 'alcohol',
        label: 'Alcohol',
        icon: Wine,
        color: '#D63031',
        itemType: 'log',
        matcher: (item) => {
            if (item.type !== 'log') return false;
            const log = item.data as DailyLog;
            return log.log_type === 'note' && (log.metadata?.type === 'alcohol' || log.metadata?.sub_type === 'alcohol');
        },
    },
    {
        id: 'toilet',
        label: 'Toilet',
        icon: Bath,
        color: '#636E72',
        itemType: 'log',
        matcher: (item) => {
            if (item.type !== 'log') return false;
            const log = item.data as DailyLog;
            return log.log_type === 'note' && (log.metadata?.type === 'toilet' || log.metadata?.sub_type === 'toilet');
        },
    },
    {
        id: 'stress',
        label: 'Stress',
        icon: Brain,
        color: '#FD79A8',
        itemType: 'log',
        matcher: (item) => item.type === 'log' && (item.data as DailyLog).log_type === 'symptom',
    },
];

// Component to render a measurement card
function MeasurementCard({ measurement, locale }: { measurement: Measurement; locale: string }) {
    const isGlucose = measurement.type === 'glucose';
    const isBloodPressure = measurement.type === 'blood_pressure';

    const config = FILTER_CONFIGS.find(c =>
        (isGlucose && c.id === 'glucose') || (isBloodPressure && c.id === 'blood_pressure')
    );

    const Icon = config?.icon || Activity;
    const color = config?.color || '#6B7280';

    const time = format(parseISO(measurement.measured_at), 'HH:mm');

    // Format value
    let valueDisplay: string;
    if (isBloodPressure && measurement.value_secondary) {
        valueDisplay = `${measurement.value_primary}/${measurement.value_secondary}`;
    } else {
        valueDisplay = `${measurement.value_primary}`;
    }

    // Unit display
    const unit = measurement.unit || (isGlucose ? 'mg/dL' : 'mmHg');

    // Meal timing badge for glucose
    const mealTiming = measurement.meal_timing;
    const mealTimingConfig = mealTiming ? MEAL_TIMING_CONFIG[mealTiming] : null;

    return (
        <Card className="overflow-hidden">
            <CardContent className="py-3">
                <div className="flex items-center gap-3">
                    <div
                        className="w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0"
                        style={{ backgroundColor: `${color}15` }}
                    >
                        <Icon size={20} style={{ color }} />
                    </div>

                    <div className="flex-1 min-w-0">
                        <div className="flex items-center gap-2">
                            <h4 className="font-medium text-gray-900">
                                {isGlucose
                                    ? (locale === 'tr' ? 'Kan Şekeri' : 'Blood Glucose')
                                    : (locale === 'tr' ? 'Tansiyon' : 'Blood Pressure')
                                }
                            </h4>
                            {mealTimingConfig && (
                                <span
                                    className="text-xs px-2 py-0.5 rounded-full text-white"
                                    style={{ backgroundColor: mealTimingConfig.color }}
                                >
                                    {locale === 'tr' ? mealTimingConfig.labelTr : mealTimingConfig.label}
                                </span>
                            )}
                        </div>
                        <p className="text-sm text-gray-500">{time}</p>
                    </div>

                    <div className="text-right">
                        <p className="text-lg font-bold text-gray-900">{valueDisplay}</p>
                        <p className="text-xs text-gray-500">{unit}</p>
                    </div>
                </div>
            </CardContent>
        </Card>
    );
}

export function DailyLogsTab({ patientId }: DailyLogsTabProps) {
    const { t, i18n } = useTranslation('dailyLogs');
    const dateLocale = i18n.language === 'tr' ? tr : enUS;

    // Get translated filter label
    const getFilterLabel = (id: FilterType): string => {
        // Use translation for types that have translations, fallback to existing translations
        const translationMap: Record<FilterType, string> = {
            glucose: i18n.language === 'tr' ? 'Şeker' : 'Glucose',
            blood_pressure: i18n.language === 'tr' ? 'Tansiyon' : 'Blood Pressure',
            food: t('types.food'),
            sleep: t('types.sleep'),
            exercise: t('types.exercise'),
            medication: t('types.medication'),
            water: t('water'),
            alcohol: t('alcohol'),
            toilet: t('types.toilet'),
            stress: t('types.stress'),
        };
        return translationMap[id];
    };
    const [selectedDate, setSelectedDate] = useState<Date>(new Date());
    const [selectedFilter, setSelectedFilter] = useState<FilterType | null>(null);
    const dateInputRef = useRef<HTMLInputElement>(null);

    // Date strings for queries - memoized to ensure stable references
    const dateStr = format(selectedDate, 'yyyy-MM-dd');
    const startOfDay = `${dateStr}T00:00:00`;
    const endOfDay = `${dateStr}T23:59:59`;

    // Memoize filter objects to ensure stable query keys for caching
    const logsFilters = useMemo(() => ({
        patientId,
        startDate: dateStr,
        endDate: dateStr,
        limit: 100,
    }), [patientId, dateStr]);

    const measurementsFilters = useMemo(() => ({
        patientId,
        startDate: startOfDay,
        endDate: endOfDay,
        limit: 100,
    }), [patientId, startOfDay, endOfDay]);

    // SWR pattern: cached data shows instantly, refreshes in background
    const {
        data: allLogs = [],
        isLoading: logsLoading,
        isFetching: logsFetching,
        error: logsError,
    } = useDailyLogs(logsFilters);

    const {
        data: rawMeasurements = [],
        isLoading: measurementsLoading,
        isFetching: measurementsFetching,
        error: measurementsError,
    } = useMeasurements(measurementsFilters);

    // Filter measurements to only glucose and blood_pressure
    const allMeasurements = useMemo(
        () => rawMeasurements.filter(m => m.type === 'glucose' || m.type === 'blood_pressure'),
        [rawMeasurements]
    );

    const isLoading = logsLoading || measurementsLoading;
    const isFetching = logsFetching || measurementsFetching;
    const error = logsError?.message || measurementsError?.message || null;

    // Create unified items from logs and measurements
    const allItems = useMemo((): UnifiedItem[] => {
        const logItems: UnifiedItem[] = allLogs.map(log => ({
            id: log.id,
            type: 'log' as const,
            timestamp: new Date(log.logged_at),
            data: log,
        }));

        const measurementItems: UnifiedItem[] = allMeasurements.map(m => ({
            id: m.id,
            type: 'measurement' as const,
            timestamp: new Date(m.measured_at),
            data: m,
        }));

        return [...logItems, ...measurementItems].sort(
            (a, b) => b.timestamp.getTime() - a.timestamp.getTime()
        );
    }, [allLogs, allMeasurements]);

    // Filter items client-side based on selected filter
    const filteredItems = useMemo(() => {
        if (!selectedFilter) return allItems;

        const config = FILTER_CONFIGS.find(c => c.id === selectedFilter);
        if (!config) return allItems;

        return allItems.filter(config.matcher);
    }, [allItems, selectedFilter]);

    // Count items for each filter type
    const filterCounts = useMemo(() => {
        const counts: Record<FilterType, number> = {
            glucose: 0,
            blood_pressure: 0,
            food: 0,
            sleep: 0,
            exercise: 0,
            medication: 0,
            water: 0,
            alcohol: 0,
            toilet: 0,
            stress: 0,
        };

        for (const item of allItems) {
            for (const config of FILTER_CONFIGS) {
                if (config.matcher(item)) {
                    counts[config.id]++;
                    break; // Each item only counts once
                }
            }
        }

        return counts;
    }, [allItems]);

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

    // Group items by time of day
    const groupedItems = filteredItems.reduce((acc, item) => {
        const hour = item.timestamp.getHours();
        let period: string;
        if (hour < 12) period = 'morning';
        else if (hour < 17) period = 'afternoon';
        else period = 'evening';

        if (!acc[period]) acc[period] = [];
        acc[period].push(item);
        return acc;
    }, {} as Record<string, UnifiedItem[]>);

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

                        {/* Background refresh indicator */}
                        {isFetching && !isLoading && (
                            <RefreshCw size={14} className="absolute right-4 top-4 text-gray-400 animate-spin" />
                        )}

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
                                    {format(selectedDate, 'EEEE, d MMMM yyyy', { locale: dateLocale })}
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
                            {getFilterLabel(config.id)}
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
            ) : filteredItems.length === 0 ? (
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
                    <div className="grid grid-cols-5 md:grid-cols-10 gap-2">
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
                                    <p className="text-xs text-gray-500 truncate">{getFilterLabel(config.id)}</p>
                                </button>
                            );
                        })}
                    </div>

                    {/* Grouped items */}
                    {['morning', 'afternoon', 'evening'].map(period => {
                        const periodItems = groupedItems[period];
                        if (!periodItems || periodItems.length === 0) return null;

                        return (
                            <div key={period}>
                                <h3 className="text-sm font-medium text-gray-500 mb-3 uppercase tracking-wide">
                                    {periodLabels[period]} ({periodItems.length})
                                </h3>
                                <div className="space-y-2">
                                    {periodItems.map(item => (
                                        item.type === 'log' ? (
                                            <DailyLogCard key={item.id} log={item.data as DailyLog} />
                                        ) : (
                                            <MeasurementCard
                                                key={item.id}
                                                measurement={item.data as Measurement}
                                                locale={i18n.language}
                                            />
                                        )
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
