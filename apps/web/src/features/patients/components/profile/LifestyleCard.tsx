import { useTranslation } from 'react-i18next';
import { Heart, Target } from 'lucide-react';
import { ProfileSection } from './ProfileSection';
import { Badge } from '../../../../components/common/Badge';
import type { HabitsData, GoalsData } from '../../../../types/onboarding.types';

interface LifestyleCardProps {
    habits: HabitsData;
    goals: GoalsData;
}

export function LifestyleCard({ habits, goals }: LifestyleCardProps) {
    const { t } = useTranslation('onboarding');

    // Helper to render habit score bar
    const renderHabitBar = (labelKey: string, value?: number) => {
        if (value === undefined) return null;

        // Color based on value (assuming 10 is good for most, but Stress is inverse? 
        // onboarding.json says "I don't feel stressed" -> 10? 
        // Let's assume higher is better/healthier for simplicity or consistent with label "Healthy Eating")
        const percentage = (value / 10) * 100;
        let color = 'bg-primary';
        if (value < 4) color = 'bg-red-500';
        else if (value < 7) color = 'bg-orange-500';
        else color = 'bg-green-500';

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

    return (
        <ProfileSection title={t('steps.habits')} icon={Heart}>
            <div className="space-y-6">
                {/* Habits Section */}
                <div>
                    {renderHabitBar('healthyEating', habits.healthy_eating)}
                    {renderHabitBar('activityLevel', habits.activity_level)}
                    {renderHabitBar('medicationAdherence', habits.medication_adherence)}
                    {/* Only showing top 3 for compactness? Or all? Let's show key ones */}
                </div>

                {/* Goals Section */}
                <div className="pt-4 border-t border-gray-100/50">
                    <div className="flex items-center gap-2 mb-3 text-gray-500 text-sm font-medium">
                        <Target size={14} />
                        <span>{t('steps.goals')}</span>
                    </div>

                    <div className="space-y-2">
                        {Object.entries(goals).map(([key, priority]) => {
                            if (!priority || priority === 'unimportant') return null;

                            // Map priority to badge variant
                            let variant: 'success' | 'warning' | 'info' | 'default' = 'default';

                            if (priority === 'very_important') {
                                variant = 'default';
                                // Add custom styling for error/critical look since 'error' variant might be missing in types
                            }
                            else if (priority === 'important') variant = 'warning';
                            else if (priority === 'secondary') variant = 'info';

                            // Convert snake_case key to camelCase for translation lookup
                            const camelKey = key.replace(/_([a-z])/g, (g) => g[1].toUpperCase());

                            return (
                                <div key={key} className="flex items-center justify-between text-sm">
                                    <span className="text-gray-700">{t(`goals.${camelKey}`)}</span>
                                    <Badge
                                        variant={variant}
                                        className={priority === 'very_important' ? 'bg-red-100 text-red-700' : ''}
                                    >
                                        {t(`goals.priorities.${priority.replace(/_([a-z])/g, (g: string) => g[1].toUpperCase())}`)}
                                    </Badge>
                                </div>
                            );
                        })}
                        {/* If no goals, show dashes */}
                        {Object.keys(goals).length === 0 && <span className="text-gray-400 text-xs">-</span>}
                    </div>
                </div>
            </div>
        </ProfileSection>
    );
}
