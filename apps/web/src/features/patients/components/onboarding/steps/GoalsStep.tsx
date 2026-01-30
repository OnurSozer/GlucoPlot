/**
 * Goals Step - Step 5 of patient onboarding
 */

import { useTranslation } from 'react-i18next';
import { PriorityMatrix } from '../shared/PriorityMatrix';
import type { GoalsData, GoalPriority } from '../../../../../types/onboarding.types';

interface GoalsStepProps {
  data: GoalsData;
  onChange: (data: GoalsData) => void;
}

const GOAL_ROWS = [
  { id: 'healthy_eating', labelKey: 'onboarding:goals.healthyEating' },
  { id: 'regular_medication', labelKey: 'onboarding:goals.regularMedication' },
  { id: 'checkups', labelKey: 'onboarding:goals.checkups' },
  { id: 'regular_exercise', labelKey: 'onboarding:goals.regularExercise' },
  { id: 'low_salt', labelKey: 'onboarding:goals.lowSalt' },
  { id: 'stress_reduction', labelKey: 'onboarding:goals.stressReduction' },
];

export function GoalsStep({ data, onChange }: GoalsStepProps) {
  const { t } = useTranslation('onboarding');

  const handlePriorityChange = (goalId: string, priority: GoalPriority) => {
    onChange({ ...data, [goalId]: priority });
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('goals.title')}
        </h3>
        <p className="text-sm text-gray-500">
          {t('goals.description')}
        </p>
      </div>

      <PriorityMatrix
        goals={GOAL_ROWS}
        values={data as Record<string, GoalPriority | undefined>}
        onChange={handlePriorityChange}
      />
    </div>
  );
}
