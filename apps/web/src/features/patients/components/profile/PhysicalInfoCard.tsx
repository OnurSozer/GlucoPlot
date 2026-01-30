import { useTranslation } from 'react-i18next';
import { Activity, Ruler, Weight } from 'lucide-react';
import { ProfileSection } from './ProfileSection';
import { calculateBMI } from '../../../../types/onboarding.types';
import type { PhysicalData } from '../../../../types/onboarding.types';

interface PhysicalInfoCardProps {
    data: PhysicalData;
}

export function PhysicalInfoCard({ data }: PhysicalInfoCardProps) {
    const { t } = useTranslation('onboarding');
    const bmi = calculateBMI(data.height_cm, data.weight_kg);

    const getBMICategory = (bmi: number) => {
        if (bmi < 18.5) return { label: 'Underweight', color: 'text-blue-600', bg: 'bg-blue-100', width: '25%' };
        if (bmi < 25) return { label: 'Normal', color: 'text-green-600', bg: 'bg-green-100', width: '50%' };
        if (bmi < 30) return { label: 'Overweight', color: 'text-orange-600', bg: 'bg-orange-100', width: '75%' };
        return { label: 'Obese', color: 'text-red-600', bg: 'bg-red-100', width: '100%' };
    };

    const bmiInfo = bmi ? getBMICategory(bmi) : null;

    return (
        <ProfileSection title={t('steps.physical')} icon={Activity}>
            <div className="grid grid-cols-2 gap-4">
                {/* Height */}
                <div className="p-4 bg-gray-50 rounded-xl space-y-1">
                    <div className="flex items-center gap-2 text-gray-500 text-sm">
                        <Ruler size={14} />
                        <span>{t('physical.height')}</span>
                    </div>
                    <p className="text-xl font-bold text-gray-900">
                        {data.height_cm ? `${data.height_cm} cm` : '-'}
                    </p>
                </div>

                {/* Weight */}
                <div className="p-4 bg-gray-50 rounded-xl space-y-1">
                    <div className="flex items-center gap-2 text-gray-500 text-sm">
                        <Weight size={14} />
                        <span>{t('physical.weight')}</span>
                    </div>
                    <p className="text-xl font-bold text-gray-900">
                        {data.weight_kg ? `${data.weight_kg} kg` : '-'}
                    </p>
                </div>

                {/* BMI Section - Full Width */}
                {bmi && bmiInfo && (
                    <div className="col-span-2 p-4 bg-gray-50 rounded-xl space-y-3">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2 text-gray-500 text-sm">
                                <Activity size={14} />
                                <span>{t('physical.bmi')}</span>
                            </div>
                            <span className={`text-sm font-medium px-2 py-0.5 rounded-full ${bmiInfo.bg} ${bmiInfo.color}`}>
                                {bmiInfo.label}
                            </span>
                        </div>

                        <div className="flex items-end gap-2">
                            <p className="text-2xl font-bold text-gray-900">{bmi}</p>
                            <p className="text-xs text-gray-400 mb-1">{t('physical.bmiCalculated')}</p>
                        </div>

                        {/* Visual Indicator */}
                        <div className="h-2 w-full bg-gray-200 rounded-full overflow-hidden">
                            <div
                                className={`h-full rounded-full transition-all duration-500 ${bmiInfo.bg.replace('bg-', 'bg-opacity-100 bg-')}`}
                                style={{ width: bmiInfo.width, backgroundColor: 'currentColor', color: 'inherit' }}
                            />
                            {/* Note: Tailwind dynamic classes might not work perfectly with replace, defining styles directly or explicit classes is safer. 
                                 Using inline style for width. For color, let's just use the text color class logic or mapped colors.
                             */}
                            <div
                                className={`h-full rounded-full transition-all duration-500 ${bmiInfo.color.replace('text-', 'bg-')}`}
                                style={{ width: bmiInfo.width }}
                            />
                        </div>
                    </div>
                )}
            </div>
        </ProfileSection>
    );
}
