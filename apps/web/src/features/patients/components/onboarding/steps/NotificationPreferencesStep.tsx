/**
 * Notification Preferences Step - Step 2 of patient onboarding
 */

import { useTranslation } from 'react-i18next';
import { NotificationMatrix } from '../shared/NotificationMatrix';
import type { NotificationPreferencesData } from '../../../../../types/onboarding.types';

interface NotificationPreferencesStepProps {
  data: NotificationPreferencesData;
  onChange: (data: NotificationPreferencesData) => void;
}

export function NotificationPreferencesStep({
  data,
  onChange,
}: NotificationPreferencesStepProps) {
  const { t } = useTranslation('onboarding');

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('notifications.title')}
        </h3>
        <p className="text-sm text-gray-500">
          {t('notifications.description')}
        </p>
      </div>

      <NotificationMatrix
        preferences={data.preferences}
        onChange={(preferences) => onChange({ preferences })}
      />
    </div>
  );
}
