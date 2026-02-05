/**
 * Physical Data Step - Step 3 of patient onboarding
 */

import { useTranslation } from 'react-i18next';
import { Ruler, Scale } from 'lucide-react';
import { Input } from '../../../../../components/common/Input';
import { calculateBMI } from '../../../../../types/onboarding.types';
import type { PhysicalData } from '../../../../../types/onboarding.types';

interface PhysicalDataStepProps {
  data: PhysicalData;
  onChange: (data: PhysicalData) => void;
}

export function PhysicalDataStep({ data, onChange }: PhysicalDataStepProps) {
  const { t } = useTranslation('onboarding');
  const bmi = calculateBMI(data.height_cm, data.weight_kg);

  const handleChange = (field: keyof PhysicalData, value: string) => {
    onChange({
      ...data,
      [field]: value ? parseFloat(value) : undefined,
    });
  };

  const getBMICategory = (bmi: number): { labelKey: string; color: string } => {
    if (bmi < 18.5) return { labelKey: 'underweight', color: 'text-blue-600' };
    if (bmi < 25) return { labelKey: 'normal', color: 'text-green-600' };
    if (bmi < 30) return { labelKey: 'overweight', color: 'text-yellow-600' };
    return { labelKey: 'obese', color: 'text-red-600' };
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('physical.title')}
        </h3>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <Input
          label={t('physical.height')}
          type="number"
          placeholder="170"
          value={data.height_cm?.toString() || ''}
          onChange={(e) => handleChange('height_cm', e.target.value)}
          leftIcon={<Ruler size={18} />}
        />
        <Input
          label={t('physical.weight')}
          type="number"
          placeholder="70"
          value={data.weight_kg?.toString() || ''}
          onChange={(e) => handleChange('weight_kg', e.target.value)}
          leftIcon={<Scale size={18} />}
        />
      </div>

      {/* BMI Display */}
      <div className="bg-gradient-to-r from-primary/10 to-primary/5 rounded-xl p-6">
        <div className="flex items-center justify-between">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              {t('physical.bmi')}
            </label>
            <p className="text-xs text-gray-500">{t('physical.bmiCalculated')}</p>
          </div>
          <div className="text-right">
            {bmi ? (
              <>
                <p className="text-3xl font-bold text-primary-dark">{bmi}</p>
                <p className={`text-sm font-medium ${getBMICategory(bmi).color}`}>
                  {t(`physical.bmiCategories.${getBMICategory(bmi).labelKey}`)}
                </p>
              </>
            ) : (
              <p className="text-2xl font-medium text-gray-400">--</p>
            )}
          </div>
        </div>

        {/* BMI Scale */}
        <div className="mt-4">
          <div className="h-2 bg-gradient-to-r from-blue-400 via-green-400 via-yellow-400 to-red-400 rounded-full" />
          <div className="flex justify-between text-xs text-gray-500 mt-1">
            <span>18.5</span>
            <span>25</span>
            <span>30</span>
            <span>35+</span>
          </div>
        </div>
      </div>
    </div>
  );
}
