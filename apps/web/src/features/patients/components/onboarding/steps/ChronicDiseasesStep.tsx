/**
 * Chronic Diseases Step - Step 9 of patient onboarding
 */

import { useTranslation } from 'react-i18next';
import { Check } from 'lucide-react';
import type { ChronicDiseasesData, ChronicDiseaseType } from '../../../../../types/onboarding.types';
import { CHRONIC_DISEASES } from '../../../../../types/onboarding.types';

interface ChronicDiseasesStepProps {
  data: ChronicDiseasesData;
  onChange: (data: ChronicDiseasesData) => void;
}

export function ChronicDiseasesStep({ data, onChange }: ChronicDiseasesStepProps) {
  const { t } = useTranslation('onboarding');

  const getDiseaseLabel = (disease: ChronicDiseaseType): string => {
    const keyMap: Record<ChronicDiseaseType, string> = {
      hypertension: 'chronicDiseases.diseases.hypertension',
      cardiovascular: 'chronicDiseases.diseases.cardiovascular',
      heart_failure: 'chronicDiseases.diseases.heartFailure',
      hyperlipidemia: 'chronicDiseases.diseases.hyperlipidemia',
      kidney_failure: 'chronicDiseases.diseases.kidneyFailure',
      chronic_pain: 'chronicDiseases.diseases.chronicPain',
      major_depression: 'chronicDiseases.diseases.majorDepression',
      anxiety: 'chronicDiseases.diseases.anxiety',
      sleep_disorder: 'chronicDiseases.diseases.sleepDisorder',
      physical_disability: 'chronicDiseases.diseases.physicalDisability',
      other: 'chronicDiseases.diseases.other',
    };
    return t(keyMap[disease]);
  };

  const toggleDisease = (disease: ChronicDiseaseType) => {
    const isSelected = data.diseases.includes(disease);
    const newDiseases = isSelected
      ? data.diseases.filter((d) => d !== disease)
      : [...data.diseases, disease];

    onChange({
      ...data,
      diseases: newDiseases,
      // Clear other_details if 'other' is deselected
      other_details: disease === 'other' && isSelected ? undefined : data.other_details,
    });
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('chronicDiseases.title')}
        </h3>
        <p className="text-sm text-gray-500">
          {t('chronicDiseases.description')}
        </p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
        {CHRONIC_DISEASES.map((disease) => {
          const isSelected = data.diseases.includes(disease);
          return (
            <button
              key={disease}
              type="button"
              onClick={() => toggleDisease(disease)}
              className={`
                flex items-center gap-3 p-4 rounded-xl border-2 text-left
                transition-all duration-200
                ${isSelected
                  ? 'border-primary bg-primary/5'
                  : 'border-gray-200 hover:border-primary/50'
                }
              `}
            >
              <div
                className={`
                  w-5 h-5 rounded border-2 flex items-center justify-center flex-shrink-0
                  transition-all duration-200
                  ${isSelected
                    ? 'border-primary bg-primary'
                    : 'border-gray-300'
                  }
                `}
              >
                {isSelected && <Check size={12} className="text-white" />}
              </div>
              <span className={`text-sm ${isSelected ? 'font-medium text-gray-900' : 'text-gray-700'}`}>
                {getDiseaseLabel(disease)}
              </span>
            </button>
          );
        })}
      </div>

      {/* Other details input (shown when 'other' is selected) */}
      {data.diseases.includes('other') && (
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1.5">
            {t('chronicDiseases.otherDetails')}
          </label>
          <textarea
            value={data.other_details || ''}
            onChange={(e) => onChange({ ...data, other_details: e.target.value || undefined })}
            placeholder={t('chronicDiseases.otherDetails')}
            rows={3}
            className="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white/80 backdrop-blur-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary resize-none"
          />
        </div>
      )}
    </div>
  );
}
