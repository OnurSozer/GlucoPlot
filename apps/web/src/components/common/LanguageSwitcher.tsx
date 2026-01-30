/**
 * Language Switcher Component
 * Allows users to switch between English and Turkish
 */

import { useTranslation } from 'react-i18next';
import { Globe } from 'lucide-react';

const languages = [
  { code: 'en', label: 'EN' },
  { code: 'tr', label: 'TR' },
];

export function LanguageSwitcher() {
  const { i18n } = useTranslation();

  const handleLanguageChange = (langCode: string) => {
    i18n.changeLanguage(langCode);
  };

  return (
    <div className="flex items-center gap-2 px-3 py-2">
      <Globe size={16} className="text-gray-400" />
      <div className="flex rounded-lg bg-gray-100 p-0.5">
        {languages.map((lang) => (
          <button
            key={lang.code}
            onClick={() => handleLanguageChange(lang.code)}
            className={`
              px-3 py-1 text-xs font-medium rounded-md transition-all
              ${i18n.language === lang.code || (i18n.language.startsWith(lang.code) && lang.code === 'en')
                ? 'bg-white text-primary-dark shadow-sm'
                : 'text-gray-500 hover:text-gray-700'
              }
            `}
          >
            {lang.label}
          </button>
        ))}
      </div>
    </div>
  );
}
