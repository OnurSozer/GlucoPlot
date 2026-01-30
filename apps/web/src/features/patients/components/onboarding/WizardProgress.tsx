/**
 * Wizard Progress Component
 * Shows step progress indicator
 */

import { useTranslation } from 'react-i18next';
import { Check } from 'lucide-react';
import type { WizardStep } from '../../../../types/onboarding.types';

interface WizardProgressProps {
  steps: WizardStep[];
  currentStepIndex: number;
  completedSteps: number[];
}

export function WizardProgress({
  steps,
  currentStepIndex,
  completedSteps,
}: WizardProgressProps) {
  const { t } = useTranslation();

  return (
    <div className="w-full">
      {/* Step indicators */}
      <div className="flex items-center justify-between relative">
        {/* Progress line background */}
        <div className="absolute left-0 right-0 top-4 h-0.5 bg-gray-200 -z-10" />

        {/* Progress line filled */}
        <div
          className="absolute left-0 top-4 h-0.5 bg-primary transition-all duration-300 -z-10"
          style={{ width: `${(currentStepIndex / (steps.length - 1)) * 100}%` }}
        />

        {steps.map((step, index) => {
          const isCompleted = completedSteps.includes(index);
          const isCurrent = index === currentStepIndex;
          const isPast = index < currentStepIndex;

          return (
            <div
              key={step.id}
              className="flex flex-col items-center"
            >
              {/* Step circle */}
              <div
                className={`
                  w-8 h-8 rounded-full flex items-center justify-center
                  text-sm font-medium transition-all duration-200
                  ${isCurrent
                    ? 'bg-primary text-white ring-4 ring-primary/20'
                    : isCompleted || isPast
                      ? 'bg-primary text-white'
                      : 'bg-gray-200 text-gray-500'
                  }
                `}
              >
                {isCompleted || isPast ? (
                  <Check size={16} />
                ) : (
                  index + 1
                )}
              </div>

              {/* Step title (show on larger screens) */}
              <span
                className={`
                  mt-2 text-xs text-center max-w-[80px] hidden md:block
                  ${isCurrent ? 'font-medium text-primary-dark' : 'text-gray-500'}
                `}
              >
                {t(step.titleKey)}
              </span>
            </div>
          );
        })}
      </div>

      {/* Current step title (mobile) */}
      <div className="mt-4 text-center md:hidden">
        <span className="text-sm font-medium text-primary-dark">
          {t(steps[currentStepIndex]?.titleKey)}
        </span>
        <span className="text-sm text-gray-500 ml-2">
          ({currentStepIndex + 1}/{steps.length})
        </span>
      </div>
    </div>
  );
}
