/**
 * i18n configuration for GlucoPlot
 * Supports English (default) and Turkish
 */

import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// Import translation files
import enCommon from './locales/en/common.json';
import enPatients from './locales/en/patients.json';
import enOnboarding from './locales/en/onboarding.json';
import trCommon from './locales/tr/common.json';
import trPatients from './locales/tr/patients.json';
import trOnboarding from './locales/tr/onboarding.json';

const resources = {
  en: {
    common: enCommon,
    patients: enPatients,
    onboarding: enOnboarding,
  },
  tr: {
    common: trCommon,
    patients: trPatients,
    onboarding: trOnboarding,
  },
};

i18n
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    resources,
    fallbackLng: 'en',
    defaultNS: 'common',
    ns: ['common', 'patients', 'onboarding'],

    detection: {
      order: ['localStorage', 'navigator'],
      caches: ['localStorage'],
      lookupLocalStorage: 'glucoplot_language',
    },

    interpolation: {
      escapeValue: false, // React already escapes values
    },
  });

export default i18n;
