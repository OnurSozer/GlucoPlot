/**
 * Habits Step - Step 4 of patient onboarding
 */

import { useTranslation } from 'react-i18next';
import { ScaleSelector } from '../shared/ScaleSelector';
import type { HabitsData, ExerciseFrequency, ExerciseDuration } from '../../../../../types/onboarding.types';

interface HabitsStepProps {
  data: HabitsData;
  onChange: (data: HabitsData) => void;
}

export function HabitsStep({ data, onChange }: HabitsStepProps) {
  const { t } = useTranslation('onboarding');

  const handleScaleChange = (field: keyof HabitsData, value: number) => {
    onChange({ ...data, [field]: value });
  };

  const handleSelectChange = (field: keyof HabitsData, value: string) => {
    onChange({ ...data, [field]: value || undefined });
  };

  return (
    <div className="space-y-8">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('habits.title')}
        </h3>
        <p className="text-sm text-gray-500">
          {t('habits.description')}
        </p>
      </div>

      {/* Scale-based habits */}
      <div className="space-y-6">
        <ScaleSelector
          label={t('habits.healthyEating')}
          value={data.healthy_eating}
          onChange={(v) => handleScaleChange('healthy_eating', v)}
          leftLabel={t('habits.scaleLow')}
          rightLabel={t('habits.scaleHigh')}
        />

        <ScaleSelector
          label={t('habits.medicationAdherence')}
          value={data.medication_adherence}
          onChange={(v) => handleScaleChange('medication_adherence', v)}
          leftLabel={t('habits.scaleLow')}
          rightLabel={t('habits.scaleHigh')}
        />

        <ScaleSelector
          label={t('habits.diseaseMonitoring')}
          value={data.disease_monitoring}
          onChange={(v) => handleScaleChange('disease_monitoring', v)}
          leftLabel={t('habits.scaleLow')}
          rightLabel={t('habits.scaleHigh')}
        />

        <ScaleSelector
          label={t('habits.activityLevel')}
          value={data.activity_level}
          onChange={(v) => handleScaleChange('activity_level', v)}
          leftLabel={t('habits.scaleLow')}
          rightLabel={t('habits.scaleHigh')}
        />

        <ScaleSelector
          label={t('habits.stressLevel')}
          value={data.stress_level}
          onChange={(v) => handleScaleChange('stress_level', v)}
          leftLabel={t('habits.stressLow')}
          rightLabel={t('habits.stressHigh')}
        />

        <ScaleSelector
          label={t('habits.hypoglycemicAttacks')}
          value={data.hypoglycemic_attacks}
          onChange={(v) => handleScaleChange('hypoglycemic_attacks', v)}
          leftLabel={t('habits.attacksFrequent')}
          rightLabel={t('habits.attacksNone')}
        />

        <ScaleSelector
          label={t('habits.saltAwareness')}
          value={data.salt_awareness}
          onChange={(v) => handleScaleChange('salt_awareness', v)}
          leftLabel={t('habits.saltLow')}
          rightLabel={t('habits.saltHigh')}
        />
      </div>

      {/* Dropdown-based habits */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-4 border-t border-gray-200">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1.5">
            {t('habits.exerciseFrequency')}
          </label>
          <select
            value={data.exercise_frequency || ''}
            onChange={(e) => handleSelectChange('exercise_frequency', e.target.value as ExerciseFrequency)}
            className="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white/80 backdrop-blur-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary"
          >
            <option value="">{t('common:common.select')}</option>
            <option value="daily">{t('habits.exerciseOptions.daily')}</option>
            <option value="weekly">{t('habits.exerciseOptions.weekly')}</option>
            <option value="rarely">{t('habits.exerciseOptions.rarely')}</option>
            <option value="never">{t('habits.exerciseOptions.never')}</option>
          </select>
        </div>

        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1.5">
            {t('habits.exerciseDuration')}
          </label>
          <select
            value={data.exercise_duration || ''}
            onChange={(e) => handleSelectChange('exercise_duration', e.target.value as ExerciseDuration)}
            className="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white/80 backdrop-blur-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary"
          >
            <option value="">{t('common:common.select')}</option>
            <option value="0-15">{t('habits.durationOptions.0-15')}</option>
            <option value="15-30">{t('habits.durationOptions.15-30')}</option>
            <option value="30-60">{t('habits.durationOptions.30-60')}</option>
            <option value="60+">{t('habits.durationOptions.60+')}</option>
          </select>
        </div>
      </div>
    </div>
  );
}
