/**
 * i18n configuration for GlucoPlot
 * Supports Turkish (default) and English
 */

import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// Import translation files
import enCommon from './locales/en/common.json';
import enPatients from './locales/en/patients.json';
import enOnboarding from './locales/en/onboarding.json';
import enDailyLogs from './locales/en/dailyLogs.json';
import trCommon from './locales/tr/common.json';
import trPatients from './locales/tr/patients.json';
import trOnboarding from './locales/tr/onboarding.json';
import trDailyLogs from './locales/tr/dailyLogs.json';

const resources = {
  en: {
    common: enCommon,
    patients: enPatients,
    onboarding: enOnboarding,
    dailyLogs: enDailyLogs,
  },
  tr: {
    common: trCommon,
    patients: trPatients,
    onboarding: trOnboarding,
    dailyLogs: trDailyLogs,
  },
};

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: 'tr',
    defaultNS: 'common',
    ns: ['common', 'patients', 'onboarding', 'dailyLogs'],

    detection: {
      order: ['localStorage'],
      caches: ['localStorage'],
      lookupLocalStorage: 'glucoplot_language',
    },

    interpolation: {
      escapeValue: false, // React already escapes values
    },
  });

export default i18n;
