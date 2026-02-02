/**
 * DailyLogCard - Individual daily log entry display
 */

import {
    UtensilsCrossed,
    Moon,
    Dumbbell,
    Pill,
    Stethoscope,
    FileText,
    Droplets,
    Wine,
    Bath
} from 'lucide-react';
import { useTranslation } from 'react-i18next';
import { formatTime, formatDate, getLogTypeColor } from '../../../utils/format';
import type { DailyLog, LogType } from '../../../types/database.types';

interface DailyLogCardProps {
    log: DailyLog;
}

const logTypeIcons: Record<LogType, typeof FileText> = {
    food: UtensilsCrossed,
    sleep: Moon,
    exercise: Dumbbell,
    medication: Pill,
    symptom: Stethoscope,
    note: FileText,
};

function getSubTypeIcon(log: DailyLog) {
    const subType = (log.metadata?.type as string) || (log.metadata?.sub_type as string);
    if (!subType) return null;

    if (subType === 'water') return Droplets;
    if (subType === 'alcohol') return Wine;
    if (subType === 'toilet') return Bath;

    return null;
}

function getLogDescription(log: DailyLog, t: (key: string) => string): string {
    const parts: string[] = [];

    // Add user description if available
    if (log.description) {
        parts.push(log.description);
    }

    // Add metadata based on log type
    const meta = log.metadata || {};

    switch (log.log_type) {
        case 'food': {
            const carbs = meta.carbs_grams as number | undefined;
            const calories = meta.calories as number | undefined;
            if (carbs) parts.push(`${carbs}g carbs`);
            if (calories) parts.push(`${calories} cal`);
            if (parts.length === 0) parts.push(t('mealLogged'));
            break;
        }
        case 'exercise': {
            const duration = meta.exercise_duration as number | undefined;
            const intensity = meta.exercise_intensity as string | undefined;
            if (duration) parts.push(`${duration} min`);
            if (intensity) parts.push(intensity);
            if (parts.length === 0) parts.push(t('exerciseLogged'));
            break;
        }
        case 'sleep': {
            const hours = meta.sleep_hours as number | undefined;
            const quality = meta.sleep_quality as string | undefined;
            if (hours) parts.push(`${hours.toFixed(1)} hours`);
            if (quality) parts.push(`Quality: ${quality}`);
            if (parts.length === 0) parts.push(t('sleepLogged'));
            break;
        }
        case 'medication': {
            const dosage = meta.dosage as string | undefined;
            if (dosage) parts.push(dosage);
            if (parts.length === 0) parts.push(t('medicationTaken'));
            break;
        }
        case 'symptom': {
            const stressLevel = meta.stress_level as number | undefined;
            if (stressLevel) parts.push(`Stress: ${stressLevel}/10`);
            if (parts.length === 0) parts.push(t('symptomLogged'));
            break;
        }
        case 'note': {
            const subType = meta.type as string | undefined;
            if (subType === 'water') {
                const amount = meta.amount_ml as number | undefined;
                if (amount) parts.push(`${amount} ml`);
                if (parts.length === 0) parts.push(t('waterLogged'));
            } else if (subType === 'alcohol') {
                const amount = meta.amount_ml as number | undefined;
                const alcoholType = meta.alcohol_type as string | undefined;
                if (amount) parts.push(`${amount} ml`);
                if (alcoholType) parts.push(alcoholType);
                if (parts.length === 0) parts.push(t('alcoholLogged'));
            } else if (subType === 'toilet') {
                const toiletType = meta.toilet_type as string | undefined;
                if (toiletType) parts.push(toiletType);
                if (parts.length === 0) parts.push(t('bathroomVisit'));
            } else {
                if (parts.length === 0) parts.push(t('noteLogged'));
            }
            break;
        }
    }

    return parts.join(' · ');
}

export function DailyLogCard({ log }: DailyLogCardProps) {
    const { t } = useTranslation('dailyLogs');
    const color = getLogTypeColor(log.log_type);
    const SubTypeIcon = getSubTypeIcon(log);
    const Icon = SubTypeIcon || logTypeIcons[log.log_type] || FileText;
    const description = getLogDescription(log, t);

    // Get display title - use sub_type for notes, otherwise use title
    const subType = (log.metadata?.type as string) || (log.metadata?.sub_type as string);
    let displayTitle = log.title;
    if (log.log_type === 'note' && subType) {
        if (subType === 'water') displayTitle = t('water');
        else if (subType === 'alcohol') displayTitle = t('alcohol');
        else if (subType === 'toilet') displayTitle = t('bathroom');
    }

    return (
        <div className="p-4 bg-white rounded-xl border border-gray-100 hover:shadow-sm transition-shadow">
            <div className="flex items-start gap-4">
                {/* Icon */}
                <div
                    className="w-10 h-10 rounded-xl flex items-center justify-center shrink-0"
                    style={{ backgroundColor: `${color}20` }}
                >
                    <Icon size={20} style={{ color }} />
                </div>

                {/* Content */}
                <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                        <span
                            className="text-xs font-medium px-2 py-0.5 rounded-full"
                            style={{ backgroundColor: `${color}15`, color }}
                        >
                            {log.log_type === 'note' && subType
                                ? t(subType)
                                : t(`types.${log.log_type === 'symptom' ? 'stress' : log.log_type}`)}
                        </span>
                    </div>

                    <h4 className="font-medium text-gray-900 mb-0.5 truncate">
                        {displayTitle}
                    </h4>

                    <p className="text-sm text-gray-500 line-clamp-2">
                        {description}
                    </p>
                </div>

                {/* Time */}
                <div className="text-right shrink-0">
                    <p className="text-sm font-medium text-gray-700">
                        {formatTime(log.logged_at)}
                    </p>
                    <p className="text-xs text-gray-400">
                        {formatDate(log.log_date, 'MMM d')}
                    </p>
                </div>
            </div>
        </div>
    );
}
