import { useTranslation } from 'react-i18next';
import { Target } from 'lucide-react';
import { ProfileSection } from './ProfileSection';
import { Badge } from '../../../../components/common/Badge';
import type { GoalsData, GoalPriority } from '../../../../types/onboarding.types';

interface GoalsCardProps {
    data: GoalsData;
}

// Priority order for sorting (highest priority first)
const PRIORITY_ORDER: GoalPriority[] = [
    'very_important',
    'important',
    'secondary',
    'unimportant',
];

// Goal keys for iteration
const GOAL_KEYS = [
    'healthy_eating',
    'regular_medication',
    'checkups',
    'regular_exercise',
    'low_salt',
    'stress_reduction',
] as const;

export function GoalsCard({ data }: GoalsCardProps) {
    const { t } = useTranslation('onboarding');

    // Convert snake_case to camelCase for translation lookup
    const toCamelCase = (str: string) =>
        str.replace(/_([a-z])/g, (g) => g[1].toUpperCase());

    // Get badge variant based on priority
    const getBadgeVariant = (priority: GoalPriority): 'success' | 'warning' | 'info' | 'default' => {
        switch (priority) {
            case 'very_important':
                return 'default'; // Will add custom styling
            case 'important':
                return 'warning';
            case 'secondary':
                return 'info';
            default:
                return 'default';
        }
    };

    // Get custom badge styling for very_important
    const getBadgeClassName = (priority: GoalPriority): string => {
        if (priority === 'very_important') {
            return 'bg-red-100 text-red-700';
        }
        return '';
    };

    // Sort goals by priority
    const sortedGoals = GOAL_KEYS
        .map((key) => ({
            key,
            priority: data[key as keyof GoalsData],
        }))
        .filter((goal) => goal.priority !== undefined)
        .sort((a, b) => {
            const aIndex = PRIORITY_ORDER.indexOf(a.priority!);
            const bIndex = PRIORITY_ORDER.indexOf(b.priority!);
            return aIndex - bIndex;
        });

    const hasAnyGoal = sortedGoals.length > 0;

    return (
        <ProfileSection title={t('steps.goals')} icon={Target}>
            <div className="space-y-3">
                {sortedGoals.map(({ key, priority }) => {
                    if (!priority) return null;

                    const camelKey = toCamelCase(key);
                    const variant = getBadgeVariant(priority);
                    const customClass = getBadgeClassName(priority);

                    return (
                        <div key={key} className="flex items-center justify-between text-sm">
                            <span className="text-gray-700 font-medium">
                                {t(`goals.${camelKey}`)}
                            </span>
                            <Badge
                                variant={variant}
                                className={customClass}
                            >
                                {t(`goals.priorities.${toCamelCase(priority)}`)}
                            </Badge>
                        </div>
                    );
                })}

                {!hasAnyGoal && (
                    <span className="text-gray-400 text-sm">-</span>
                )}
            </div>
        </ProfileSection>
    );
}
