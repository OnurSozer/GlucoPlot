import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { Activity, Ruler, Weight, Pencil, X, Check, Loader2, User } from 'lucide-react';
import { ProfileSection } from './ProfileSection';
import { calculateBMI } from '../../../../types/onboarding.types';
import { onboardingService } from '../../../../services/onboarding.service';
import type { PhysicalData } from '../../../../types/onboarding.types';

interface PhysicalInfoCardProps {
    data: PhysicalData;
    patientId: string;
    gender?: 'male' | 'female';
    onUpdate?: (data: PhysicalData) => void;
}

export function PhysicalInfoCard({ data, patientId, gender, onUpdate }: PhysicalInfoCardProps) {
    const { t } = useTranslation(['onboarding', 'common']);
    const [isEditing, setIsEditing] = useState(false);
    const [isSaving, setIsSaving] = useState(false);
    const [height, setHeight] = useState(data.height_cm?.toString() || '');
    const [weight, setWeight] = useState(data.weight_kg?.toString() || '');

    // Update local state when data prop changes
    useEffect(() => {
        setHeight(data.height_cm?.toString() || '');
        setWeight(data.weight_kg?.toString() || '');
    }, [data]);

    const displayBmi = calculateBMI(data.height_cm, data.weight_kg);
    const editBmi = calculateBMI(
        height ? parseFloat(height) : undefined,
        weight ? parseFloat(weight) : undefined
    );
    const bmi = isEditing ? editBmi : displayBmi;

    const getBMICategory = (bmi: number) => {
        if (bmi < 18.5) return { labelKey: 'underweight', color: 'text-blue-600', bg: 'bg-blue-100', barBg: 'bg-blue-600', width: '25%' };
        if (bmi < 25) return { labelKey: 'normal', color: 'text-green-600', bg: 'bg-green-100', barBg: 'bg-green-600', width: '50%' };
        if (bmi < 30) return { labelKey: 'overweight', color: 'text-orange-600', bg: 'bg-orange-100', barBg: 'bg-orange-600', width: '75%' };
        return { labelKey: 'obese', color: 'text-red-600', bg: 'bg-red-100', barBg: 'bg-red-600', width: '100%' };
    };

    const bmiInfo = bmi ? getBMICategory(bmi) : null;

    const handleSave = async () => {
        setIsSaving(true);
        try {
            const newData: PhysicalData = {
                height_cm: height ? parseFloat(height) : undefined,
                weight_kg: weight ? parseFloat(weight) : undefined,
            };
            await onboardingService.savePhysicalData(patientId, newData);
            onUpdate?.(newData);
            setIsEditing(false);
        } catch (error) {
            console.error('Failed to save physical data:', error);
        } finally {
            setIsSaving(false);
        }
    };

    const handleCancel = () => {
        setHeight(data.height_cm?.toString() || '');
        setWeight(data.weight_kg?.toString() || '');
        setIsEditing(false);
    };

    const editButton = isEditing ? (
        <div className="flex items-center gap-1">
            <button
                onClick={handleCancel}
                disabled={isSaving}
                className="p-1.5 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
                title="Cancel"
            >
                <X size={16} />
            </button>
            <button
                onClick={handleSave}
                disabled={isSaving}
                className="p-1.5 text-green-600 hover:text-green-700 hover:bg-green-50 rounded-lg transition-colors"
                title="Save"
            >
                {isSaving ? <Loader2 size={16} className="animate-spin" /> : <Check size={16} />}
            </button>
        </div>
    ) : (
        <button
            onClick={() => setIsEditing(true)}
            className="p-1.5 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
            title="Edit"
        >
            <Pencil size={16} />
        </button>
    );

    return (
        <ProfileSection title={t('onboarding:steps.physical')} icon={Activity} action={editButton}>
            <div className="grid grid-cols-3 gap-4">
                {/* Gender */}
                <div className="p-4 bg-gray-50 rounded-xl space-y-1">
                    <div className="flex items-center gap-2 text-gray-500 text-sm">
                        <User size={14} />
                        <span>{t('onboarding:physical.sex')}</span>
                    </div>
                    <p className="text-xl font-bold text-gray-900">
                        {gender ? t(`common:common.${gender}`) : '-'}
                    </p>
                </div>

                {/* Height */}
                <div className="p-4 bg-gray-50 rounded-xl space-y-1">
                    <div className="flex items-center gap-2 text-gray-500 text-sm">
                        <Ruler size={14} />
                        <span>{t('onboarding:physical.height')}</span>
                    </div>
                    {isEditing ? (
                        <div className="flex items-center gap-1">
                            <input
                                type="number"
                                value={height}
                                onChange={(e) => setHeight(e.target.value)}
                                className="w-20 px-2 py-1 text-lg font-bold text-gray-900 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                placeholder="170"
                                step="0.1"
                            />
                            <span className="text-gray-500">cm</span>
                        </div>
                    ) : (
                        <p className="text-xl font-bold text-gray-900">
                            {data.height_cm ? `${data.height_cm} cm` : '-'}
                        </p>
                    )}
                </div>

                {/* Weight */}
                <div className="p-4 bg-gray-50 rounded-xl space-y-1">
                    <div className="flex items-center gap-2 text-gray-500 text-sm">
                        <Weight size={14} />
                        <span>{t('onboarding:physical.weight')}</span>
                    </div>
                    {isEditing ? (
                        <div className="flex items-center gap-1">
                            <input
                                type="number"
                                value={weight}
                                onChange={(e) => setWeight(e.target.value)}
                                className="w-20 px-2 py-1 text-lg font-bold text-gray-900 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent"
                                placeholder="70"
                                step="0.1"
                            />
                            <span className="text-gray-500">kg</span>
                        </div>
                    ) : (
                        <p className="text-xl font-bold text-gray-900">
                            {data.weight_kg ? `${data.weight_kg} kg` : '-'}
                        </p>
                    )}
                </div>

                {/* BMI Section - Full Width */}
                {bmi && bmiInfo && (
                    <div className="col-span-3 p-4 bg-gray-50 rounded-xl space-y-3">
                        <div className="flex items-center justify-between">
                            <div className="flex items-center gap-2 text-gray-500 text-sm">
                                <Activity size={14} />
                                <span>{t('onboarding:physical.bmi')}</span>
                            </div>
                            <span className={`text-sm font-medium px-2 py-0.5 rounded-full ${bmiInfo.bg} ${bmiInfo.color}`}>
                                {t(`onboarding:physical.bmiCategories.${bmiInfo.labelKey}`)}
                            </span>
                        </div>

                        <div className="flex items-end gap-2">
                            <p className="text-2xl font-bold text-gray-900">{bmi}</p>
                            <p className="text-xs text-gray-400 mb-1">{t('onboarding:physical.bmiCalculated')}</p>
                        </div>

                        {/* Visual Indicator */}
                        <div className="h-2 w-full bg-gray-200 rounded-full overflow-hidden">
                            <div
                                className={`h-full rounded-full transition-all duration-500 ${bmiInfo.barBg}`}
                                style={{ width: bmiInfo.width }}
                            />
                        </div>
                    </div>
                )}
            </div>
        </ProfileSection>
    );
}
