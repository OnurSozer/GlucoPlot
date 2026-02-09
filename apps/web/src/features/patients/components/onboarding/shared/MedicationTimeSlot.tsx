/**
 * Medication Time Slot Component
 * Form for a single medication time period (morning, noon, etc.)
 */

import { useTranslation } from 'react-i18next';
import { Input } from '../../../../../components/common/Input';
import type {
  MedTimePeriod,
  InsulinType,
  MedicationScheduleEntry,
} from '../../../../../types/onboarding.types';
import { INSULIN_TYPES } from '../../../../../types/onboarding.types';

interface MedicationTimeSlotProps {
  timePeriod: MedTimePeriod;
  value: MedicationScheduleEntry | undefined;
  onChange: (entry: MedicationScheduleEntry | undefined) => void;
  mode: 'insulin' | 'oral';
  disabled?: boolean;
}

export function MedicationTimeSlot({
  timePeriod,
  value,
  onChange,
  mode,
  disabled = false,
}: MedicationTimeSlotProps) {
  const { t } = useTranslation();

  const getTimePeriodLabel = (period: MedTimePeriod): string => {
    const keyMap: Record<MedTimePeriod, string> = {
      morning: 'onboarding:insulinSchedule.timePeriods.morning',
      noon: 'onboarding:insulinSchedule.timePeriods.noon',
      evening: 'onboarding:insulinSchedule.timePeriods.evening',
      night: 'onboarding:insulinSchedule.timePeriods.night',
      other1: 'onboarding:insulinSchedule.timePeriods.other1',
      other2: 'onboarding:insulinSchedule.timePeriods.other2',
    };
    return t(keyMap[period]);
  };

  const getInsulinTypeLabel = (type: InsulinType): string => {
    const keyMap: Record<InsulinType, string> = {
      nph: 'onboarding:insulinSchedule.insulinTypes.nph',
      lente: 'onboarding:insulinSchedule.insulinTypes.lente',
      ultralente: 'onboarding:insulinSchedule.insulinTypes.ultralente',
    };
    return t(keyMap[type]);
  };

  const handleTypeChange = (selectedType: string) => {
    if (selectedType === '') {
      onChange(undefined);
    } else {
      onChange({
        time_period: timePeriod,
        insulin_type: mode === 'insulin' ? (selectedType as InsulinType) : undefined,
        medication_name: mode === 'oral' && selectedType === 'yes' ? value?.medication_name : undefined,
        dose: value?.dose,
        scheduled_time: value?.scheduled_time,
        is_active: true,
      });
    }
  };

  const handleDoseChange = (dose: string) => {
    if (!value) return;
    onChange({
      ...value,
      dose: dose ? parseFloat(dose) : undefined,
    });
  };

  const handleTimeChange = (time: string) => {
    if (!value) return;
    onChange({
      ...value,
      scheduled_time: time || undefined,
    });
  };

  const isActive = value?.is_active !== false && (
    mode === 'insulin' ? !!value?.insulin_type : true
  );

  return (
    <div className="p-4 bg-purple-50/50 rounded-xl border border-purple-100 space-y-4">
      <h4 className="font-medium text-gray-900">{getTimePeriodLabel(timePeriod)}</h4>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        {/* Type Selection */}
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1.5">
            {mode === 'insulin' ? t('common:common.select') : t('onboarding:oralMedication.hasmedication')}
          </label>
          <select
            value={
              mode === 'insulin'
                ? value?.insulin_type || ''
                : value?.is_active ? 'yes' : 'none'
            }
            onChange={(e) => handleTypeChange(e.target.value)}
            disabled={disabled}
            className="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white/80 backdrop-blur-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary"
          >
            {mode === 'insulin' ? (
              <>
                <option value="">{t('onboarding:insulinSchedule.insulinTypes.none')}</option>
                {INSULIN_TYPES.map((type) => (
                  <option key={type} value={type}>
                    {getInsulinTypeLabel(type)}
                  </option>
                ))}
              </>
            ) : (
              <>
                <option value="none">{t('onboarding:oralMedication.medicationOptions.none')}</option>
                <option value="yes">{t('onboarding:oralMedication.medicationOptions.yes')}</option>
              </>
            )}
          </select>
        </div>

        {/* Dose */}
        {isActive && (
          <div>
            <Input
              label={mode === 'insulin'
                ? t('onboarding:insulinSchedule.dose')
                : t('onboarding:oralMedication.dose')
              }
              type="number"
              value={value?.dose?.toString() || ''}
              onChange={(e) => handleDoseChange(e.target.value)}
              placeholder="0"
              disabled={disabled}
            />
          </div>
        )}

        {/* Time */}
        {isActive && (
          <div>
            <Input
              label={mode === 'insulin'
                ? t('onboarding:insulinSchedule.time')
                : t('onboarding:oralMedication.time')
              }
              type="time"
              value={value?.scheduled_time || ''}
              onChange={(e) => handleTimeChange(e.target.value)}
              disabled={disabled}
            />
          </div>
        )}
      </div>
    </div>
  );
}
