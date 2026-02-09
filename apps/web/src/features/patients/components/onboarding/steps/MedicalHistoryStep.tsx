/**
 * Medical History Step - Step 6 of patient onboarding
 */

import { useTranslation } from 'react-i18next';
import { Calendar } from 'lucide-react';
import { Input } from '../../../../../components/common/Input';
import type { MedicalHistoryData, DiabetesType, MedicationClass } from '../../../../../types/onboarding.types';
import { DIABETES_TYPES } from '../../../../../types/onboarding.types';

interface MedicalHistoryStepProps {
  data: MedicalHistoryData;
  onChange: (data: MedicalHistoryData) => void;
}

export function MedicalHistoryStep({ data, onChange }: MedicalHistoryStepProps) {
  const { t } = useTranslation('onboarding');

  const getDiabetesTypeLabel = (type: DiabetesType): string => {
    const keyMap: Record<DiabetesType, string> = {
      type1: 'medicalHistory.types.type1',
      type2: 'medicalHistory.types.type2',
      prediabetes: 'medicalHistory.types.prediabetes',
      gestational: 'medicalHistory.types.gestational',
      lada: 'medicalHistory.types.lada',
      mody: 'medicalHistory.types.mody',
      secondary: 'medicalHistory.types.secondary',
      chemically_induced: 'medicalHistory.types.chemicallyInduced',
    };
    return t(keyMap[type]);
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('medicalHistory.title')}
        </h3>
      </div>

      {/* Diabetes Diagnosis */}
      <div className="p-4 bg-purple-50/50 rounded-xl border border-purple-100">
        <label className="block text-sm font-medium text-gray-700 mb-3">
          {t('medicalHistory.hasDiabetes')}
        </label>
        <div className="flex gap-4">
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="radio"
              name="hasDiabetes"
              checked={data.has_diabetes === true}
              onChange={() => onChange({ ...data, has_diabetes: true })}
              className="w-4 h-4 text-primary border-gray-300 focus:ring-primary"
            />
            <span>{t('common:common.yes')}</span>
          </label>
          <label className="flex items-center gap-2 cursor-pointer">
            <input
              type="radio"
              name="hasDiabetes"
              checked={data.has_diabetes === false}
              onChange={() => onChange({ ...data, has_diabetes: false, diabetes_type: undefined })}
              className="w-4 h-4 text-primary border-gray-300 focus:ring-primary"
            />
            <span>{t('common:common.no')}</span>
          </label>
        </div>
      </div>

      {/* Diabetes Type (shown if has_diabetes is true) */}
      {data.has_diabetes && (
        <div className="p-4 bg-purple-50/50 rounded-xl border border-purple-100">
          <label className="block text-sm font-medium text-gray-700 mb-3">
            {t('medicalHistory.diabetesType')}
          </label>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-2">
            {DIABETES_TYPES.map((type) => (
              <label key={type} className="flex items-center gap-2 cursor-pointer p-2 hover:bg-white rounded-lg transition-colors">
                <input
                  type="radio"
                  name="diabetesType"
                  checked={data.diabetes_type === type}
                  onChange={() => onChange({ ...data, diabetes_type: type })}
                  className="w-4 h-4 text-primary border-gray-300 focus:ring-primary"
                />
                <span className="text-sm">{getDiabetesTypeLabel(type)}</span>
              </label>
            ))}
          </div>
        </div>
      )}

      {/* Diagnosis Year */}
      {data.has_diabetes && (
        <div>
          <Input
            label={t('medicalHistory.diagnosisDate')}
            type="number"
            placeholder={t('medicalHistory.diagnosisYearPlaceholder')}
            value={data.diagnosis_date || ''}
            onChange={(e) => {
              const val = e.target.value;
              if (val === '' || (val.length <= 4 && /^\d*$/.test(val))) {
                onChange({ ...data, diagnosis_date: val || undefined });
              }
            }}
            leftIcon={<Calendar size={18} />}
          />
        </div>
      )}

      {/* Medication Type */}
      <div className="p-4 bg-purple-50/50 rounded-xl border border-purple-100">
        <label className="block text-sm font-medium text-gray-700 mb-3">
          {t('medicalHistory.medicationType')}
        </label>
        <div className="flex flex-col gap-2">
          {(['oral_hypoglycemic', 'insulin', 'none'] as MedicationClass[]).map((type) => (
            <label key={type} className="flex items-center gap-2 cursor-pointer p-2 hover:bg-white rounded-lg transition-colors">
              <input
                type="radio"
                name="medicationType"
                checked={data.medication_type === type}
                onChange={() => onChange({ ...data, medication_type: type })}
                className="w-4 h-4 text-primary border-gray-300 focus:ring-primary"
              />
              <span className="text-sm">{t(`medicalHistory.medicationOptions.${type === 'oral_hypoglycemic' ? 'oralHypoglycemic' : type}`)}</span>
            </label>
          ))}
        </div>
      </div>
    </div>
  );
}
