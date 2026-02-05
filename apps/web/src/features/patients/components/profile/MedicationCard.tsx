import { useTranslation } from 'react-i18next';
import { Pill, Clock, Syringe } from 'lucide-react';
import { ProfileSection } from './ProfileSection';
import { TIME_PERIODS } from '../../../../types/onboarding.types';
import type { MedicationScheduleData, MedicationClass } from '../../../../types/onboarding.types';

interface MedicationCardProps {
    insulin?: MedicationScheduleData;
    oral?: MedicationScheduleData;
    type: MedicationClass;
}

export function MedicationCard({ insulin, oral, type }: MedicationCardProps) {
    const { t } = useTranslation('onboarding');

    if (type === 'none') {
        return (
            <ProfileSection title={t('steps.insulinSchedule')} icon={Pill}>
                {/* Note: Title might be generic "Medications" if type is none, but 'recard' implies we check type prop. 
                    Actually, if type is 'none', this card might simply say "No medication". 
                    Let's use a generic title like "Medication". 
                    But onboarding.json separate titles. I'll use "Medication Plan" as generic title for this card? 
                    Or reuse "Insulin Schedule" / "Oral Medication" depending on content?
                    Let's stick to "Medications". 
                */}
                <div className="text-gray-500 text-sm py-2">
                    {t('medicalHistory.medicationOptions.none')}
                </div>
            </ProfileSection>
        );
    }

    const title = type === 'insulin' ? t('steps.insulinSchedule') : t('steps.oralMedication');
    const Icon = type === 'insulin' ? Syringe : Pill;
    const items = type === 'insulin' ? insulin?.schedules : oral?.schedules;

    // Sort items by TIME_PERIODS order
    const sortedItems = [...(items || [])].sort((a, b) => {
        return TIME_PERIODS.indexOf(a.time_period) - TIME_PERIODS.indexOf(b.time_period);
    });

    return (
        <ProfileSection title={title} icon={Icon}>
            <div className="space-y-3">
                {sortedItems.length === 0 ? (
                    <p className="text-gray-400 text-sm italic">{t('insulinSchedule.noActiveSchedule')}</p>
                ) : (
                    sortedItems.map((item, index) => (
                        <div key={index} className="flex items-center justify-between p-3 bg-gray-50 rounded-xl border border-gray-100">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 rounded-full bg-white flex items-center justify-center text-gray-400 shadow-sm text-xs font-bold border border-gray-100">
                                    {/* Icon based on time period? Simple clock is fine */}
                                    <Clock size={14} />
                                </div>
                                <div>
                                    <p className="font-semibold text-gray-900 text-sm">
                                        {t(`insulinSchedule.timePeriods.${item.time_period}`)}
                                    </p>
                                    <p className="text-xs text-gray-500">
                                        {item.scheduled_time || t('insulinSchedule.noTimeSet')}
                                    </p>
                                </div>
                            </div>

                            <div className="text-right">
                                <p className="font-bold text-primary">
                                    {item.dose} <span className="text-xs font-normal text-gray-500">{item.dose_unit || 'IU'}</span>
                                </p>
                                <p className="text-xs text-gray-500 dark:text-gray-400">
                                    {type === 'insulin'
                                        ? t(`insulinSchedule.insulinTypes.${item.insulin_type}`)
                                        : item.medication_name || t('insulinSchedule.medication')}
                                </p>
                            </div>
                        </div>
                    ))
                )}
            </div>
        </ProfileSection>
    );
}
