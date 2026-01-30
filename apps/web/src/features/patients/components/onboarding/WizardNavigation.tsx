/**
 * Wizard Navigation Component
 * Back/Next/Submit buttons for the onboarding wizard
 */

import { useTranslation } from 'react-i18next';
import { ArrowLeft, ArrowRight, Check, Loader2 } from 'lucide-react';

interface WizardNavigationProps {
    currentStepIndex: number;
    totalSteps: number;
    onBack: () => void;
    onNext: () => void;
    onSubmit: () => void;
    isSubmitting?: boolean;
    isNextDisabled?: boolean;
}

export function WizardNavigation({
    currentStepIndex,
    totalSteps,
    onBack,
    onNext,
    onSubmit,
    isSubmitting = false,
    isNextDisabled = false,
}: WizardNavigationProps) {
    const { t } = useTranslation('onboarding');

    const isFirstStep = currentStepIndex === 0;
    const isLastStep = currentStepIndex === totalSteps - 1;

    return (
        <div className="flex items-center justify-between pt-6 border-t border-gray-200">
            {/* Back Button */}
            <button
                type="button"
                onClick={onBack}
                disabled={isFirstStep || isSubmitting}
                className={`
          flex items-center gap-2 px-4 py-2 rounded-lg
          text-sm font-medium transition-all duration-200
          ${isFirstStep
                        ? 'invisible'
                        : 'text-gray-600 hover:text-gray-800 hover:bg-gray-100'
                    }
          disabled:opacity-50 disabled:cursor-not-allowed
        `}
            >
                <ArrowLeft size={18} />
                {t('navigation.back')}
            </button>

            {/* Step Counter */}
            <span className="text-sm text-gray-500">
                {currentStepIndex + 1} / {totalSteps}
            </span>

            {/* Next/Submit Button */}
            {isLastStep ? (
                <button
                    type="button"
                    onClick={onSubmit}
                    disabled={isSubmitting || isNextDisabled}
                    className={`
            flex items-center gap-2 px-6 py-2.5 rounded-lg
            text-sm font-medium transition-all duration-200
            bg-green-600 text-white hover:bg-green-700
            disabled:opacity-50 disabled:cursor-not-allowed
            shadow-sm hover:shadow-md
          `}
                >
                    {isSubmitting ? (
                        <>
                            <Loader2 size={18} className="animate-spin" />
                            {t('navigation.submitting')}
                        </>
                    ) : (
                        <>
                            <Check size={18} />
                            {t('navigation.submit')}
                        </>
                    )}
                </button>
            ) : (
                <button
                    type="button"
                    onClick={onNext}
                    disabled={isSubmitting || isNextDisabled}
                    className={`
            flex items-center gap-2 px-6 py-2.5 rounded-lg
            text-sm font-medium transition-all duration-200
            bg-primary text-white hover:bg-primary-dark
            disabled:opacity-50 disabled:cursor-not-allowed
            shadow-sm hover:shadow-md
          `}
                >
                    {t('navigation.next')}
                    <ArrowRight size={18} />
                </button>
            )}
        </div>
    );
}
