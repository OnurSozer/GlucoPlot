/**
 * Phone Input with Country Code Selector
 */

import { useState, useRef, useEffect } from 'react';
import { ChevronDown } from 'lucide-react';

interface Country {
  code: string;
  dialCode: string;
  flag: string;
  name: string;
}

const countries: Country[] = [
  { code: 'TR', dialCode: '+90', flag: '🇹🇷', name: 'Türkiye' },
  { code: 'DE', dialCode: '+49', flag: '🇩🇪', name: 'Germany' },
  { code: 'GB', dialCode: '+44', flag: '🇬🇧', name: 'United Kingdom' },
  { code: 'US', dialCode: '+1', flag: '🇺🇸', name: 'United States' },
  { code: 'NL', dialCode: '+31', flag: '🇳🇱', name: 'Netherlands' },
  { code: 'FR', dialCode: '+33', flag: '🇫🇷', name: 'France' },
  { code: 'AZ', dialCode: '+994', flag: '🇦🇿', name: 'Azerbaijan' },
  { code: 'AT', dialCode: '+43', flag: '🇦🇹', name: 'Austria' },
  { code: 'BE', dialCode: '+32', flag: '🇧🇪', name: 'Belgium' },
  { code: 'BG', dialCode: '+359', flag: '🇧🇬', name: 'Bulgaria' },
  { code: 'GR', dialCode: '+30', flag: '🇬🇷', name: 'Greece' },
  { code: 'IT', dialCode: '+39', flag: '🇮🇹', name: 'Italy' },
  { code: 'ES', dialCode: '+34', flag: '🇪🇸', name: 'Spain' },
  { code: 'SE', dialCode: '+46', flag: '🇸🇪', name: 'Sweden' },
  { code: 'CH', dialCode: '+41', flag: '🇨🇭', name: 'Switzerland' },
  { code: 'RU', dialCode: '+7', flag: '🇷🇺', name: 'Russia' },
  { code: 'SA', dialCode: '+966', flag: '🇸🇦', name: 'Saudi Arabia' },
  { code: 'AE', dialCode: '+971', flag: '🇦🇪', name: 'UAE' },
  { code: 'IR', dialCode: '+98', flag: '🇮🇷', name: 'Iran' },
  { code: 'IQ', dialCode: '+964', flag: '🇮🇶', name: 'Iraq' },
];

function parsePhoneValue(value: string): { country: Country; number: string } {
  const defaultCountry = countries[0]; // Turkey
  if (!value) return { country: defaultCountry, number: '' };

  // Try to match the dial code from the value (longest match first)
  const sorted = [...countries].sort((a, b) => b.dialCode.length - a.dialCode.length);
  for (const country of sorted) {
    if (value.startsWith(country.dialCode)) {
      return { country, number: value.slice(country.dialCode.length) };
    }
  }

  return { country: defaultCountry, number: value };
}

interface PhoneInputProps {
  label?: string;
  placeholder?: string;
  value: string;
  onChange: (value: string) => void;
}

export function PhoneInput({ label, placeholder, value, onChange }: PhoneInputProps) {
  const parsed = parsePhoneValue(value);
  const [selectedCountry, setSelectedCountry] = useState<Country>(parsed.country);
  const [phoneNumber, setPhoneNumber] = useState(parsed.number);
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Sync from external value changes (e.g. form reset / load data)
  useEffect(() => {
    const p = parsePhoneValue(value);
    setSelectedCountry(p.country);
    setPhoneNumber(p.number);
  }, [value]);

  // Click outside to close
  useEffect(() => {
    function handleClickOutside(e: MouseEvent) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target as Node)) {
        setIsOpen(false);
      }
    }
    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside);
      return () => document.removeEventListener('mousedown', handleClickOutside);
    }
  }, [isOpen]);

  const emitChange = (country: Country, number: string) => {
    const full = number ? `${country.dialCode}${number}` : '';
    onChange(full);
  };

  const handleCountrySelect = (country: Country) => {
    setSelectedCountry(country);
    setIsOpen(false);
    emitChange(country, phoneNumber);
  };

  const handleNumberChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const num = e.target.value;
    setPhoneNumber(num);
    emitChange(selectedCountry, num);
  };

  return (
    <div className="w-full">
      {label && (
        <label className="block text-sm font-medium text-gray-700 mb-1.5">
          {label}
        </label>
      )}
      <div className="relative flex" ref={dropdownRef}>
        {/* Country code button */}
        <button
          type="button"
          onClick={() => setIsOpen(!isOpen)}
          className="flex items-center gap-1 px-3 py-2.5 rounded-l-xl border border-r-0 border-gray-200 bg-white/80 backdrop-blur-sm hover:bg-gray-50 transition-colors flex-shrink-0"
        >
          <span className="text-base">{selectedCountry.flag}</span>
          <span className="text-sm text-gray-700">{selectedCountry.dialCode}</span>
          <ChevronDown size={14} className="text-gray-400" />
        </button>

        {/* Phone number input */}
        <input
          type="tel"
          value={phoneNumber}
          onChange={handleNumberChange}
          placeholder={placeholder}
          className="w-full px-4 py-2.5 rounded-r-xl border border-gray-200 bg-white/80 backdrop-blur-sm transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary"
        />

        {/* Dropdown */}
        {isOpen && (
          <div className="absolute top-full left-0 mt-1 w-72 max-h-60 overflow-y-auto bg-white border border-gray-200 rounded-xl shadow-lg z-50">
            {countries.map((country) => (
              <button
                key={country.code}
                type="button"
                onClick={() => handleCountrySelect(country)}
                className={`w-full flex items-center gap-3 px-3 py-2 text-sm hover:bg-gray-50 transition-colors ${
                  selectedCountry.code === country.code ? 'bg-primary/5 text-primary' : 'text-gray-700'
                }`}
              >
                <span className="text-base">{country.flag}</span>
                <span className="flex-1 text-left">{country.name}</span>
                <span className="text-gray-400">{country.dialCode}</span>
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
