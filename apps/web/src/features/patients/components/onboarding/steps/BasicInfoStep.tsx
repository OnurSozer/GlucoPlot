/**
 * Basic Info Step - Step 1 of patient onboarding
 */

import { useState, useEffect, useRef, useCallback } from 'react';
import { useTranslation } from 'react-i18next';
import { User, Mail, Calendar, CreditCard, UserPlus, AlertTriangle, Loader2, Plus, X } from 'lucide-react';
import { Input } from '../../../../../components/common/Input';
import { PhoneInput } from '../../../../../components/common/PhoneInput';
import { onboardingService } from '../../../../../services/onboarding.service';
import type { BasicInfoData, PatientOnboardingData, RelativeInfo } from '../../../../../types/onboarding.types';

interface BasicInfoStepProps {
  data: BasicInfoData;
  onChange: (data: BasicInfoData) => void;
  onExistingPatientFound?: (data: PatientOnboardingData) => void;
  doctorPhone?: string;
  doctorEmail?: string;
}

export function BasicInfoStep({
  data,
  onChange,
  onExistingPatientFound,
  doctorPhone,
  doctorEmail,
}: BasicInfoStepProps) {
  const { t } = useTranslation('onboarding');
  const [duplicatePatient, setDuplicatePatient] = useState<{ patient_id: string; full_name: string } | null>(null);
  const [isChecking, setIsChecking] = useState(false);
  const [isLoadingData, setIsLoadingData] = useState(false);
  const debounceRef = useRef<ReturnType<typeof setTimeout>>();

  const handleChange = (field: keyof BasicInfoData, value: string) => {
    onChange({ ...data, [field]: value || undefined });
  };

  const checkNationalId = useCallback(async (nationalId: string) => {
    if (nationalId.length < 5) {
      setDuplicatePatient(null);
      return;
    }

    setIsChecking(true);
    const { data: found } = await onboardingService.findPatientByNationalId(nationalId);
    setIsChecking(false);

    setDuplicatePatient(found);
  }, []);

  useEffect(() => {
    if (debounceRef.current) {
      clearTimeout(debounceRef.current);
    }

    const nationalId = data.national_id;
    if (!nationalId || nationalId.length < 5) {
      setDuplicatePatient(null);
      return;
    }

    debounceRef.current = setTimeout(() => {
      checkNationalId(nationalId);
    }, 600);

    return () => {
      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }
    };
  }, [data.national_id, checkNationalId]);

  const handleLoadData = async () => {
    if (!duplicatePatient || !onExistingPatientFound) return;

    setIsLoadingData(true);
    const { data: existingData } = await onboardingService.getOnboardingData(duplicatePatient.patient_id);
    setIsLoadingData(false);

    if (existingData) {
      onExistingPatientFound(existingData);
      setDuplicatePatient(null);
    }
  };

  const handleDismiss = () => {
    setDuplicatePatient(null);
  };

  const addRelative = () => {
    onChange({
      ...data,
      relatives: [...data.relatives, { name: '' }],
    });
  };

  const removeRelative = (index: number) => {
    onChange({
      ...data,
      relatives: data.relatives.filter((_, i) => i !== index),
    });
  };

  const updateRelative = (index: number, field: keyof RelativeInfo, value: string) => {
    const updated = data.relatives.map((r, i) =>
      i === index ? { ...r, [field]: value || undefined } : r
    );
    onChange({ ...data, relatives: updated });
  };

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 mb-1">
          {t('basicInfo.title')}
        </h3>
        <p className="text-sm text-gray-500">
          {t('common:common.required')} *
        </p>
      </div>

      {/* Name and ID */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <Input
          label={`${t('basicInfo.fullName')} *`}
          placeholder={t('basicInfo.placeholders.fullName')}
          value={data.full_name}
          onChange={(e) => handleChange('full_name', e.target.value)}
          leftIcon={<User size={18} />}
        />
        <div>
          <Input
            label={t('basicInfo.nationalId')}
            placeholder={t('basicInfo.placeholders.nationalId')}
            value={data.national_id || ''}
            onChange={(e) => handleChange('national_id', e.target.value)}
            leftIcon={<CreditCard size={18} />}
          />
          {isChecking && (
            <p className="mt-1 text-xs text-gray-400 flex items-center gap-1">
              <Loader2 size={12} className="animate-spin" />
              {t('basicInfo.checking')}
            </p>
          )}
        </div>
      </div>

      {/* Duplicate patient inline popup */}
      {duplicatePatient && (
        <div className="p-4 bg-amber-50 border border-amber-200 rounded-xl flex items-start gap-3">
          <AlertTriangle size={20} className="text-amber-500 flex-shrink-0 mt-0.5" />
          <div className="flex-1">
            <p className="text-sm text-amber-800">
              {t('basicInfo.duplicateFound', { name: duplicatePatient.full_name })}
            </p>
            <div className="mt-3 flex gap-2">
              <button
                type="button"
                onClick={handleLoadData}
                disabled={isLoadingData}
                className="px-3 py-1.5 text-sm font-medium rounded-lg bg-amber-600 text-white hover:bg-amber-700 disabled:opacity-50 flex items-center gap-1.5"
              >
                {isLoadingData && <Loader2 size={14} className="animate-spin" />}
                {t('basicInfo.loadData')}
              </button>
              <button
                type="button"
                onClick={handleDismiss}
                className="px-3 py-1.5 text-sm font-medium rounded-lg bg-white text-gray-700 border border-gray-300 hover:bg-gray-50"
              >
                {t('basicInfo.continueAsNew')}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Sex and DOB */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div>
          <label className="block text-sm font-medium text-gray-700 mb-1.5">
            {t('basicInfo.sex')}
          </label>
          <select
            value={data.gender || ''}
            onChange={(e) => handleChange('gender', e.target.value)}
            className="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white/80 backdrop-blur-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary"
          >
            <option value="">{t('common:common.select')}</option>
            <option value="male">{t('common:common.male')}</option>
            <option value="female">{t('common:common.female')}</option>
            <option value="other">{t('common:common.other')}</option>
          </select>
        </div>
        <Input
          label={t('basicInfo.dateOfBirth')}
          type="date"
          value={data.date_of_birth || ''}
          onChange={(e) => handleChange('date_of_birth', e.target.value)}
          leftIcon={<Calendar size={18} />}
        />
      </div>

      {/* Phone */}
      <PhoneInput
        label={t('basicInfo.phone')}
        placeholder="505 555 55 **"
        value={data.phone || ''}
        onChange={(val) => handleChange('phone', val)}
      />

      {/* Emergency Contact Section */}
      <div className="pt-4 border-t border-gray-200">
        <h4 className="text-md font-medium text-gray-900 mb-4 flex items-center gap-2">
          <UserPlus size={18} />
          {t('basicInfo.emergencyContact')}
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <PhoneInput
            label={t('basicInfo.emergencyPhone')}
            placeholder="505 555 55 **"
            value={data.emergency_contact_phone || ''}
            onChange={(val) => handleChange('emergency_contact_phone', val)}
          />
          <Input
            label={t('basicInfo.emergencyEmail')}
            type="email"
            placeholder={t('basicInfo.placeholders.emergencyEmail')}
            value={data.emergency_contact_email || ''}
            onChange={(e) => handleChange('emergency_contact_email', e.target.value)}
            leftIcon={<Mail size={18} />}
          />
        </div>
      </div>

      {/* Relatives Section */}
      <div className="pt-4 border-t border-gray-200">
        <h4 className="text-md font-medium text-gray-900 mb-4">
          {t('basicInfo.relativeTitle')}
        </h4>

        {data.relatives.map((relative, index) => (
          <div key={index} className="mb-4">
            <div className="flex items-center justify-between mb-2">
              <span className="text-sm font-medium text-gray-600">
                {t('basicInfo.relativeIndex', { index: index + 1 })}
              </span>
              {data.relatives.length > 1 && (
                <button
                  type="button"
                  onClick={() => removeRelative(index)}
                  className="text-sm text-red-500 hover:text-red-700 flex items-center gap-1"
                >
                  <X size={14} />
                  {t('basicInfo.removeRelative')}
                </button>
              )}
            </div>
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              <Input
                label={t('basicInfo.relativeName')}
                placeholder={t('basicInfo.placeholders.relativeName')}
                value={relative.name || ''}
                onChange={(e) => updateRelative(index, 'name', e.target.value)}
                leftIcon={<User size={18} />}
              />
              <PhoneInput
                label={t('basicInfo.relativePhone')}
                placeholder="505 555 55 **"
                value={relative.phone || ''}
                onChange={(val) => updateRelative(index, 'phone', val)}
              />
              <Input
                label={t('basicInfo.relativeEmail')}
                type="email"
                placeholder={t('basicInfo.placeholders.relativeEmail')}
                value={relative.email || ''}
                onChange={(e) => updateRelative(index, 'email', e.target.value)}
                leftIcon={<Mail size={18} />}
              />
            </div>
          </div>
        ))}

        <button
          type="button"
          onClick={addRelative}
          className="mt-2 px-4 py-2 text-sm font-medium text-primary hover:text-primary/80 border border-dashed border-gray-300 hover:border-primary rounded-xl flex items-center gap-2 transition-colors"
        >
          <Plus size={16} />
          {t('basicInfo.addRelative')}
        </button>
      </div>

      {/* Doctor Contact Section */}
      <div className="pt-4 border-t border-gray-200">
        <h4 className="text-md font-medium text-gray-900 mb-4">
          {t('basicInfo.doctorPhone')}
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <PhoneInput
            label={t('basicInfo.doctorPhone')}
            placeholder="505 555 55 **"
            value={data.doctor_phone || doctorPhone || ''}
            onChange={(val) => handleChange('doctor_phone', val)}
          />
          <Input
            label={t('basicInfo.doctorEmail')}
            type="email"
            placeholder={t('basicInfo.placeholders.doctorEmail')}
            value={data.doctor_email || doctorEmail || ''}
            onChange={(e) => handleChange('doctor_email', e.target.value)}
            leftIcon={<Mail size={18} />}
          />
        </div>
      </div>
    </div>
  );
}
