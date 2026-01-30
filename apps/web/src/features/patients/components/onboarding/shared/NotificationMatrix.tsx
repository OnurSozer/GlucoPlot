/**
 * Notification Matrix Component
 * A checkbox matrix for notification preferences (trigger × channel)
 */

import { useTranslation } from 'react-i18next';
import { Check } from 'lucide-react';
import type {
  NotificationTrigger,
  NotificationChannel,
  NotificationPreferenceEntry,
} from '../../../../../types/onboarding.types';
import {
  NOTIFICATION_TRIGGERS,
  NOTIFICATION_CHANNELS,
} from '../../../../../types/onboarding.types';

interface NotificationMatrixProps {
  preferences: NotificationPreferenceEntry[];
  onChange: (preferences: NotificationPreferenceEntry[]) => void;
  disabled?: boolean;
}

export function NotificationMatrix({
  preferences,
  onChange,
  disabled = false,
}: NotificationMatrixProps) {
  const { t } = useTranslation();

  const isEnabled = (trigger: NotificationTrigger, channel: NotificationChannel): boolean => {
    return preferences.some(
      (p) => p.trigger === trigger && p.channel === channel && p.enabled
    );
  };

  const handleToggle = (trigger: NotificationTrigger, channel: NotificationChannel) => {
    if (disabled) return;

    const existingIndex = preferences.findIndex(
      (p) => p.trigger === trigger && p.channel === channel
    );

    let newPreferences: NotificationPreferenceEntry[];

    if (existingIndex >= 0) {
      // Toggle existing preference
      newPreferences = preferences.map((p, i) =>
        i === existingIndex ? { ...p, enabled: !p.enabled } : p
      );
    } else {
      // Add new preference (enabled)
      newPreferences = [...preferences, { trigger, channel, enabled: true }];
    }

    onChange(newPreferences);
  };

  const getTriggerLabel = (trigger: NotificationTrigger): string => {
    const keyMap: Record<NotificationTrigger, string> = {
      hypoglycemia_below_40: 'onboarding:notifications.triggers.hypoglycemia',
      survey_not_submitted_12h: 'onboarding:notifications.triggers.surveyNotSubmitted',
      glucose_not_measured_3h: 'onboarding:notifications.triggers.glucoseNotMeasured',
    };
    return t(keyMap[trigger]);
  };

  const getChannelLabel = (channel: NotificationChannel): string => {
    const keyMap: Record<NotificationChannel, string> = {
      doctor_sms: 'onboarding:notifications.channels.doctorSms',
      doctor_email: 'onboarding:notifications.channels.doctorEmail',
      relative_sms: 'onboarding:notifications.channels.relativeSms',
      relative_email: 'onboarding:notifications.channels.relativeEmail',
    };
    return t(keyMap[channel]);
  };

  return (
    <div className="overflow-x-auto">
      <table className="w-full">
        <thead>
          <tr className="border-b border-gray-200 bg-purple-700">
            <th className="text-left py-3 px-4 text-sm font-medium text-white rounded-tl-lg" />
            {NOTIFICATION_CHANNELS.map((channel, index) => (
              <th
                key={channel}
                className={`py-3 px-4 text-center text-sm font-medium text-white ${index === NOTIFICATION_CHANNELS.length - 1 ? 'rounded-tr-lg' : ''
                  }`}
              >
                {getChannelLabel(channel)}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {NOTIFICATION_TRIGGERS.map((trigger, rowIndex) => (
            <tr
              key={trigger}
              className={`border-b border-gray-100 ${rowIndex % 2 === 0 ? 'bg-white' : 'bg-gray-50'
                }`}
            >
              <td className="py-4 px-4 text-sm text-gray-700 min-w-[200px]">
                {getTriggerLabel(trigger)}
              </td>
              {NOTIFICATION_CHANNELS.map((channel) => (
                <td key={channel} className="py-4 px-4 text-center">
                  <button
                    type="button"
                    onClick={() => handleToggle(trigger, channel)}
                    disabled={disabled}
                    className={`
                      w-5 h-5 rounded border-2 transition-all duration-200
                      flex items-center justify-center mx-auto
                      ${isEnabled(trigger, channel)
                        ? 'border-primary bg-primary text-white'
                        : 'border-gray-300 bg-white hover:border-primary/50'
                      }
                      ${disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}
                    `}
                  >
                    {isEnabled(trigger, channel) && <Check size={12} />}
                  </button>
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  );
}
