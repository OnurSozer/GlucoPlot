import { useState, useEffect } from 'react';
import { onboardingService } from '../../services/onboarding.service';
import type { PatientOnboardingData } from '../../types/onboarding.types';
import { PhysicalInfoCard } from './components/profile/PhysicalInfoCard';
import { MedicalHistoryCard } from './components/profile/MedicalHistoryCard';
import { MedicationCard } from './components/profile/MedicationCard';
import { HabitsCard } from './components/profile/HabitsCard';
import { GoalsCard } from './components/profile/GoalsCard';

interface PatientProfileViewProps {
    patientId: string;
}

export function PatientProfileView({ patientId }: PatientProfileViewProps) {
    const [data, setData] = useState<PatientOnboardingData | null>(null);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        if (!patientId) return;

        const abortController = new AbortController();

        const loadData = async () => {
            try {
                setIsLoading(true);
                const { data: onboardingData } = await onboardingService.getOnboardingData(patientId);

                if (abortController.signal.aborted) return;

                setData(onboardingData);
            } catch (error) {
                if (abortController.signal.aborted) return;
                console.error('Failed to load profile data', error);
            } finally {
                if (!abortController.signal.aborted) {
                    setIsLoading(false);
                }
            }
        };

        loadData();

        return () => {
            abortController.abort();
        };
    }, [patientId]);

    if (isLoading) {
        return (
            <div className="space-y-6 animate-pulse">
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {[1, 2, 3].map((i) => (
                        <div key={i} className="h-64 bg-gray-100 rounded-2xl" />
                    ))}
                </div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                    {[4, 5].map((i) => (
                        <div key={i} className="h-64 bg-gray-100 rounded-2xl" />
                    ))}
                </div>
            </div>
        );
    }

    if (!data) return null;

    return (
        <div className="space-y-6">
            <h2 className="text-lg font-semibold text-gray-900">Patient Profile</h2>

            {/* Top row: Physical Data, Medical History, Medication Schedule */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                <PhysicalInfoCard
                    data={data.physical}
                    patientId={patientId}
                    gender={data.basicInfo.gender}
                    onUpdate={(newData) => setData(prev => prev ? { ...prev, physical: newData } : null)}
                />

                <MedicalHistoryCard
                    history={data.medicalHistory}
                    diseases={data.chronicDiseases}
                />

                <MedicationCard
                    type={data.medicalHistory.medication_type}
                    insulin={data.insulinSchedule}
                    oral={data.oralMedicationSchedule}
                />
            </div>

            {/* Bottom row: Health Habits & Health Goals (half-half) */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <HabitsCard data={data.habits} />
                <GoalsCard data={data.goals} />
            </div>
        </div>
    );
}
