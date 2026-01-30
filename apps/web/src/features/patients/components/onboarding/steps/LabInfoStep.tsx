/**
 * Lab Info Step - Step 10 of patient onboarding
 */

import { useTranslation } from 'react-i18next';
import { Calendar, Target } from 'lucide-react';
import { Input } from '../../../../../components/common/Input';
import type { LabInfoData } from '../../../../../types/onboarding.types';

interface LabInfoStepProps {
  data: LabInfoData;
  onChange: (data: LabInfoData) => void;
}

export function LabInfoStep({ data, onChange }: LabInfoStepProps) {
  const { t } = useTranslation('onboarding');

  const handleChange = (field: keyof LabInfoData, value: string) => {
    const numericFields = ['hba1c_percentage', 'target_glucose_min', 'target_glucose_max'];
    onChange({
      ...data,
      [field]: numericFields.includes(field)
        ? (value ? parseFloat(value) : undefined)
        : (value || undefined),
    });
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('labInfo.title')}
        </h3>
      </div>

      {/* HbA1c Section */}
      <div className="p-4 bg-purple-50/50 rounded-xl border border-purple-100 space-y-4">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            label={t('labInfo.hba1c')}
            type="number"
            step="0.1"
            placeholder={t('labInfo.hba1cPlaceholder')}
            value={data.hba1c_percentage?.toString() || ''}
            onChange={(e) => handleChange('hba1c_percentage', e.target.value)}
          />
          <Input
            label={t('labInfo.testDate')}
            type="date"
            value={data.hba1c_test_date || ''}
            onChange={(e) => handleChange('hba1c_test_date', e.target.value)}
            leftIcon={<Calendar size={18} />}
          />
        </div>
      </div>

      {/* Target Glucose Range */}
      <div className="p-4 bg-green-50/50 rounded-xl border border-green-100 space-y-4">
        <div className="flex items-center gap-2 mb-2">
          <Target size={18} className="text-green-600" />
          <span className="font-medium text-gray-900">Target Glucose Range</span>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            label={t('labInfo.targetGlucoseMin')}
            type="number"
            placeholder="70"
            value={data.target_glucose_min?.toString() || ''}
            onChange={(e) => handleChange('target_glucose_min', e.target.value)}
          />
          <Input
            label={t('labInfo.targetGlucoseMax')}
            type="number"
            placeholder="180"
            value={data.target_glucose_max?.toString() || ''}
            onChange={(e) => handleChange('target_glucose_max', e.target.value)}
          />
        </div>

        <p className="text-xs text-gray-500 mt-2">
          {t('labInfo.glucoseRangeHint')}
        </p>
      </div>

      {/* Visual Range Preview */}
      {(data.target_glucose_min || data.target_glucose_max) && (
        <div className="p-4 bg-white rounded-xl border border-gray-200">
          <p className="text-sm font-medium text-gray-700 mb-3">Target Range Preview</p>
          <div className="relative h-8 bg-gray-100 rounded-full overflow-hidden">
            {/* Low zone (red) */}
            <div
              className="absolute h-full bg-red-300"
              style={{
                left: '0%',
                width: `${Math.min(((data.target_glucose_min || 70) / 300) * 100, 100)}%`,
              }}
            />
            {/* Target zone (green) */}
            <div
              className="absolute h-full bg-green-400"
              style={{
                left: `${Math.min(((data.target_glucose_min || 70) / 300) * 100, 100)}%`,
                width: `${Math.min((((data.target_glucose_max || 180) - (data.target_glucose_min || 70)) / 300) * 100, 100)}%`,
              }}
            />
            {/* High zone (yellow) */}
            <div
              className="absolute h-full bg-yellow-300"
              style={{
                left: `${Math.min(((data.target_glucose_max || 180) / 300) * 100, 100)}%`,
                right: '0%',
              }}
            />
          </div>
          <div className="flex justify-between text-xs text-gray-500 mt-1">
            <span>0</span>
            <span className="text-green-600 font-medium">
              {data.target_glucose_min || 70} - {data.target_glucose_max || 180} mg/dL
            </span>
            <span>300+</span>
          </div>
        </div>
      )}
    </div>
  );
}
