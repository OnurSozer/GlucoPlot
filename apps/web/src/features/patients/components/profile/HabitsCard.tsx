import { useTranslation } from 'react-i18next';
import { Heart, Dumbbell } from 'lucide-react';
import { ProfileSection } from './ProfileSection';
import type { HabitsData } from '../../../../types/onboarding.types';

interface HabitsCardProps {
    data: HabitsData;
}

export function HabitsCard({ data }: HabitsCardProps) {
    const { t } = useTranslation('onboarding');

    // Helper to render habit score bar
    const renderHabitBar = (labelKey: string, value?: number, invertColor = false) => {
        if (value === undefined) return null;

        const percentage = (value / 10) * 100;
        let color = 'bg-green-500';

        if (invertColor) {
            // For stress/attacks: lower is better
            if (value > 7) color = 'bg-red-500';
            else if (value > 4) color = 'bg-orange-500';
            else color = 'bg-green-500';
        } else {
            // Higher is better
            if (value < 4) color = 'bg-red-500';
            else if (value < 7) color = 'bg-orange-500';
            else color = 'bg-green-500';
        }

        return (
            <div className="mb-3">
                <div className="flex justify-between text-xs mb-1">
                    <span className="text-gray-600 font-medium">{t(`habits.${labelKey}`)}</span>
                    <span className="font-bold text-gray-900">{value}/10</span>
                </div>
                <div className="h-2 w-full bg-gray-100 rounded-full overflow-hidden">
                    <div
                        className={`h-full rounded-full ${color}`}
                        style={{ width: `${percentage}%` }}
                    />
                </div>
            </div>
        );
    };

    const hasAnyHabit = Object.values(data).some(v => v !== undefined);

    return (
        <ProfileSection title={t('steps.habits')} icon={Heart}>
            <div className="space-y-4">
                {/* Scale-based habits */}
                <div>
                    {renderHabitBar('healthyEating', data.healthy_eating)}
                    {renderHabitBar('medicationAdherence', data.medication_adherence)}
                    {renderHabitBar('diseaseMonitoring', data.disease_monitoring)}
                    {renderHabitBar('activityLevel', data.activity_level)}
                    {renderHabitBar('stressLevel', data.stress_level, true)}
                    {renderHabitBar('hypoglycemicAttacks', data.hypoglycemic_attacks, true)}
                    {renderHabitBar('saltAwareness', data.salt_awareness)}
                </div>

                {/* Exercise info */}
                {(data.exercise_frequency || data.exercise_duration) && (
                    <div className="pt-3 border-t border-gray-100/50">
                        <div className="flex items-center gap-2 mb-2 text-gray-500 text-sm font-medium">
                            <Dumbbell size={14} />
                            <span>{t('habits.exerciseFrequency')}</span>
                        </div>
                        <div className="grid grid-cols-2 gap-2 text-sm">
                            {data.exercise_frequency && (
                                <div className="bg-gray-50 rounded-lg px-3 py-2">
                                    <span className="text-gray-500 text-xs">{t('habits.exerciseFrequency')}</span>
                                    <p className="font-medium text-gray-900">
                                        {t(`habits.exerciseOptions.${data.exercise_frequency}`)}
                                    </p>
                                </div>
                            )}
                            {data.exercise_duration && (
                                <div className="bg-gray-50 rounded-lg px-3 py-2">
                                    <span className="text-gray-500 text-xs">{t('habits.exerciseDuration')}</span>
                                    <p className="font-medium text-gray-900">
                                        {t(`habits.durationOptions.${data.exercise_duration}`)}
                                    </p>
                                </div>
                            )}
                        </div>
                    </div>
                )}

                {!hasAnyHabit && (
                    <span className="text-gray-400 text-sm">-</span>
                )}
            </div>
        </ProfileSection>
    );
}
