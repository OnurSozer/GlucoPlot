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

interface LanguageSwitcherProps {
  variant?: 'light' | 'dark';
}

export function LanguageSwitcher({ variant = 'light' }: LanguageSwitcherProps) {
  const { i18n } = useTranslation();

  const handleLanguageChange = (langCode: string) => {
    i18n.changeLanguage(langCode);
  };

  const isDark = variant === 'dark';

  return (
    <div className="flex items-center gap-2 px-3 py-2">
      <Globe size={16} className={isDark ? 'text-slate-500' : 'text-gray-400'} />
      <div className={`flex rounded-lg p-0.5 ${isDark ? 'bg-slate-800' : 'bg-gray-100'}`}>
        {languages.map((lang) => {
          const isActive = i18n.language === lang.code || (i18n.language.startsWith(lang.code) && lang.code === 'en');
          return (
            <button
              key={lang.code}
              onClick={() => handleLanguageChange(lang.code)}
              className={`
                px-3 py-1 text-xs font-medium rounded-md transition-all
                ${isActive
                  ? isDark
                    ? 'bg-slate-700 text-indigo-300 shadow-sm'
                    : 'bg-white text-primary-dark shadow-sm'
                  : isDark
                    ? 'text-slate-400 hover:text-slate-200'
                    : 'text-gray-500 hover:text-gray-700'
                }
              `}
            >
              {lang.label}
            </button>
          );
        })}
      </div>
    </div>
  );
}
