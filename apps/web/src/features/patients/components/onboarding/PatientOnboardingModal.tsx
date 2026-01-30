/**
 * Patient Onboarding Modal
 * XL Modal wrapper for the patient onboarding wizard
 */

import { useTranslation } from 'react-i18next';
import { X } from 'lucide-react';

import { PatientOnboardingWizard } from './PatientOnboardingWizard';
import type { PatientOnboardingData } from '../../../../types/onboarding.types';

interface PatientOnboardingModalProps {
    isOpen: boolean;
    onClose: () => void;
    onComplete: (data: PatientOnboardingData) => Promise<void>;
}

export function PatientOnboardingModal({
    isOpen,
    onClose,
    onComplete,
}: PatientOnboardingModalProps) {
    const { t } = useTranslation('onboarding');

    if (!isOpen) return null;

    const handleComplete = async (data: PatientOnboardingData) => {
        await onComplete(data);
        onClose();
    };

    return (
        <>
            {/* Backdrop */}
            <div
                className="fixed inset-0 bg-black/50 z-40 transition-opacity"
                onClick={onClose}
            />

            {/* Modal */}
            <div className="fixed inset-4 md:inset-8 lg:inset-12 z-50 flex items-center justify-center">
                <div
                    className="
            bg-white rounded-2xl shadow-2xl
            w-full h-full max-w-6xl max-h-[90vh]
            flex flex-col overflow-hidden
            animate-in fade-in zoom-in-95 duration-200
          "
                    onClick={(e) => e.stopPropagation()}
                >
                    {/* Header */}
                    <div className="flex items-center justify-between px-6 py-4 border-b border-gray-200">
                        <div>
                            <h2 className="text-xl font-semibold text-gray-900">
                                {t('title')}
                            </h2>
                            <p className="text-sm text-gray-500 mt-1">
                                {t('subtitle')}
                            </p>
                        </div>
                        <button
                            type="button"
                            onClick={onClose}
                            className="
                p-2 rounded-lg text-gray-400 hover:text-gray-600
                hover:bg-gray-100 transition-colors
              "
                            aria-label={t('navigation.cancel')}
                        >
                            <X size={24} />
                        </button>
                    </div>

                    {/* Wizard Content */}
                    <div className="flex-1 overflow-hidden">
                        <PatientOnboardingWizard
                            onComplete={handleComplete}
                            onCancel={onClose}
                        />
                    </div>
                </div>
            </div>
        </>
    );
}
