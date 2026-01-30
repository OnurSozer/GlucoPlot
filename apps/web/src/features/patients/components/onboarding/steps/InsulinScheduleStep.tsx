/**
 * Insulin Schedule Step - Step 7 of patient onboarding (conditional)
 */

import { useTranslation } from 'react-i18next';
import { MedicationTimeSlot } from '../shared/MedicationTimeSlot';
import type { MedicationScheduleData, MedicationScheduleEntry, MedTimePeriod } from '../../../../../types/onboarding.types';
import { TIME_PERIODS } from '../../../../../types/onboarding.types';

interface InsulinScheduleStepProps {
  data: MedicationScheduleData;
  onChange: (data: MedicationScheduleData) => void;
}

export function InsulinScheduleStep({ data, onChange }: InsulinScheduleStepProps) {
  const { t } = useTranslation('onboarding');

  const getScheduleForPeriod = (period: MedTimePeriod): MedicationScheduleEntry | undefined => {
    return data.schedules.find((s) => s.time_period === period);
  };

  const handlePeriodChange = (period: MedTimePeriod, entry: MedicationScheduleEntry | undefined) => {
    const newSchedules = data.schedules.filter((s) => s.time_period !== period);
    if (entry) {
      newSchedules.push({ ...entry, time_period: period });
    }
    onChange({ schedules: newSchedules });
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('insulinSchedule.title')}
        </h3>
        <p className="text-sm text-gray-500">
          {t('insulinSchedule.description')}
        </p>
      </div>

      <div className="space-y-4">
        {TIME_PERIODS.map((period) => (
          <MedicationTimeSlot
            key={period}
            timePeriod={period}
            value={getScheduleForPeriod(period)}
            onChange={(entry) => handlePeriodChange(period, entry)}
            mode="insulin"
          />
        ))}
      </div>
    </div>
  );
}
