/**
 * Priority Matrix Component
 * A matrix selector for goal priorities
 */

import { useTranslation } from 'react-i18next';
import type { GoalPriority } from '../../../../../types/onboarding.types';

interface PriorityOption {
  value: GoalPriority;
  labelKey: string;
}

const PRIORITY_OPTIONS: PriorityOption[] = [
  { value: 'very_important', labelKey: 'onboarding:goals.priorities.veryImportant' },
  { value: 'important', labelKey: 'onboarding:goals.priorities.important' },
  { value: 'secondary', labelKey: 'onboarding:goals.priorities.secondary' },
  { value: 'unimportant', labelKey: 'onboarding:goals.priorities.unimportant' },
];

interface GoalRow {
  id: string;
  labelKey: string;
}

interface PriorityMatrixProps {
  goals: GoalRow[];
  values: Record<string, GoalPriority | undefined>;
  onChange: (goalId: string, priority: GoalPriority) => void;
  disabled?: boolean;
}

export function PriorityMatrix({
  goals,
  values,
  onChange,
  disabled = false,
}: PriorityMatrixProps) {
  const { t } = useTranslation();

  return (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr className="border-b border-gray-200">
            <th className="text-left py-3 px-2 text-sm font-medium text-gray-500 w-1/3" />
            {PRIORITY_OPTIONS.map((option) => (
              <th
                key={option.value}
                className="py-3 px-2 text-center text-sm font-medium text-gray-700"
              >
                {t(option.labelKey)}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {goals.map((goal) => (
            <tr key={goal.id} className="border-b border-gray-100 hover:bg-gray-50">
              <td className="py-4 px-2 text-sm text-gray-700">
                {t(goal.labelKey)}
              </td>
              {PRIORITY_OPTIONS.map((option) => (
                <td key={option.value} className="py-4 px-2 text-center">
                  <button
                    type="button"
                    onClick={() => !disabled && onChange(goal.id, option.value)}
                    disabled={disabled}
                    className={`
                      w-5 h-5 rounded-full border-2 transition-all duration-200
                      ${values[goal.id] === option.value
                        ? 'border-primary bg-primary'
                        : 'border-gray-300 bg-white hover:border-primary/50'
                      }
                      ${disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}
                    `}
                  >
                    {values[goal.id] === option.value && (
                      <span className="block w-2 h-2 bg-white rounded-full mx-auto" />
                    )}
                  </button>
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
