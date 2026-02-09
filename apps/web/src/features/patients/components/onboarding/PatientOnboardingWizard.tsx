/**
 * Patient Onboarding Wizard
 * Main orchestrator component for the multi-step onboarding form
 */

import { useState, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { AlertCircle } from 'lucide-react';

import type {
    PatientOnboardingData,
    OnboardingStepId,
} from '../../../../types/onboarding.types';
import {
    getVisibleSteps,
    getDefaultOnboardingData,
} from '../../../../types/onboarding.types';
import { useAuthStore } from '../../../../stores/auth-store';

import { WizardProgress } from './WizardProgress';
import { WizardNavigation } from './WizardNavigation';

// Step Components
import { BasicInfoStep } from './steps/BasicInfoStep';
import { NotificationPreferencesStep } from './steps/NotificationPreferencesStep';
import { PhysicalDataStep } from './steps/PhysicalDataStep';
import { HabitsStep } from './steps/HabitsStep';
import { GoalsStep } from './steps/GoalsStep';
import { MedicalHistoryStep } from './steps/MedicalHistoryStep';
import { InsulinScheduleStep } from './steps/InsulinScheduleStep';
import { OralMedicationStep } from './steps/OralMedicationStep';
import { ChronicDiseasesStep } from './steps/ChronicDiseasesStep';
import { LabInfoStep } from './steps/LabInfoStep';

interface PatientOnboardingWizardProps {
    initialData?: Partial<PatientOnboardingData>;
    onComplete: (data: PatientOnboardingData) => Promise<void>;
    onCancel: () => void;
}

export function PatientOnboardingWizard({
    initialData,
    onComplete,
}: PatientOnboardingWizardProps) {
    const { t } = useTranslation('onboarding');
    const doctor = useAuthStore((state) => state.doctor);

    // Form data state
    const [formData, setFormData] = useState<PatientOnboardingData>(() => ({
        ...getDefaultOnboardingData(),
        ...initialData,
    }));

    // Wizard state
    const [currentStepIndex, setCurrentStepIndex] = useState(0);
    const [completedSteps, setCompletedSteps] = useState<number[]>([]);
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);

    // Get visible steps based on current form data
    const visibleSteps = getVisibleSteps(formData);
    const currentStep = visibleSteps[currentStepIndex];

    // Navigation handlers
    const handleNext = useCallback(() => {
        // Mark current step as completed
        if (!completedSteps.includes(currentStepIndex)) {
            setCompletedSteps((prev) => [...prev, currentStepIndex]);
        }

        // Recalculate visible steps after data update
        const newVisibleSteps = getVisibleSteps(formData);

        if (currentStepIndex < newVisibleSteps.length - 1) {
            setCurrentStepIndex(currentStepIndex + 1);
        }

        setError(null);
    }, [currentStepIndex, completedSteps, formData]);

    const handleBack = useCallback(() => {
        if (currentStepIndex > 0) {
            setCurrentStepIndex(currentStepIndex - 1);
            setError(null);
        }
    }, [currentStepIndex]);

    // Handle loading data from an existing patient (duplicate national ID)
    const handleExistingPatientFound = useCallback((data: PatientOnboardingData) => {
        setFormData(data);
    }, []);

    const handleSubmit = useCallback(async () => {
        setIsSubmitting(true);
        setError(null);

        try {
            await onComplete(formData);
        } catch (err) {
            console.error('Onboarding submission error:', err);
            setError(err instanceof Error ? err.message : t('errors.submissionFailed'));
        } finally {
            setIsSubmitting(false);
        }
    }, [formData, onComplete, t]);

    // Render the current step component
    const renderStep = () => {
        if (!currentStep) return null;

        switch (currentStep.id as OnboardingStepId) {
            case 'basic-info':
                return (
                    <BasicInfoStep
                        data={formData.basicInfo}
                        onChange={(data) => setFormData((prev) => ({ ...prev, basicInfo: data }))}
                        onExistingPatientFound={handleExistingPatientFound}
                        doctorPhone={doctor?.phone ?? undefined}
                        doctorEmail={doctor?.email ?? undefined}
                    />
                );
            case 'notifications':
                return (
                    <NotificationPreferencesStep
                        data={formData.notificationPreferences}
                        onChange={(data) =>
                            setFormData((prev) => ({ ...prev, notificationPreferences: data }))
                        }
                    />
                );
            case 'physical':
                return (
                    <PhysicalDataStep
                        data={formData.physical}
                        onChange={(data) => setFormData((prev) => ({ ...prev, physical: data }))}
                    />
                );
            case 'habits':
                return (
                    <HabitsStep
                        data={formData.habits}
                        onChange={(data) => setFormData((prev) => ({ ...prev, habits: data }))}
                    />
                );
            case 'goals':
                return (
                    <GoalsStep
                        data={formData.goals}
                        onChange={(data) => setFormData((prev) => ({ ...prev, goals: data }))}
                    />
                );
            case 'medical-history':
                return (
                    <MedicalHistoryStep
                        data={formData.medicalHistory}
                        onChange={(data) =>
                            setFormData((prev) => ({ ...prev, medicalHistory: data }))
                        }
                    />
                );
            case 'insulin-schedule':
                return (
                    <InsulinScheduleStep
                        data={formData.insulinSchedule || { schedules: [] }}
                        onChange={(data) =>
                            setFormData((prev) => ({ ...prev, insulinSchedule: data }))
                        }
                    />
                );
            case 'oral-medication':
                return (
                    <OralMedicationStep
                        data={formData.oralMedicationSchedule || { schedules: [] }}
                        onChange={(data) =>
                            setFormData((prev) => ({ ...prev, oralMedicationSchedule: data }))
                        }
                    />
                );
            case 'chronic-diseases':
                return (
                    <ChronicDiseasesStep
                        data={formData.chronicDiseases}
                        onChange={(data) =>
                            setFormData((prev) => ({ ...prev, chronicDiseases: data }))
                        }
                    />
                );
            case 'lab-info':
                return (
                    <LabInfoStep
                        data={formData.labInfo}
                        onChange={(data) => setFormData((prev) => ({ ...prev, labInfo: data }))}
                    />
                );
            default:
                return null;
        }
    };

    return (
        <div className="flex flex-col h-full">
            {/* Header with progress */}
            <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
                <WizardProgress
                    steps={visibleSteps}
                    currentStepIndex={currentStepIndex}
                    completedSteps={completedSteps}
                />
            </div>

            {/* Step Content */}
            <div className="flex-1 overflow-y-auto px-6 py-6">
                {/* Error message */}
                {error && (
                    <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-lg flex items-start gap-3">
                        <AlertCircle size={20} className="text-red-500 flex-shrink-0 mt-0.5" />
                        <div>
                            <p className="text-sm font-medium text-red-800">{t('errors.title')}</p>
                            <p className="text-sm text-red-600 mt-1">{error}</p>
                        </div>
                    </div>
                )}

                {/* Current step component */}
                {renderStep()}
            </div>

            {/* Navigation */}
            <div className="px-6 py-4 bg-white border-t border-gray-100">
                <WizardNavigation
                    currentStepIndex={currentStepIndex}
                    totalSteps={visibleSteps.length}
                    onBack={handleBack}
                    onNext={handleNext}
                    onSubmit={handleSubmit}
                    isSubmitting={isSubmitting}
                />
            </div>
        </div>
    );
}
