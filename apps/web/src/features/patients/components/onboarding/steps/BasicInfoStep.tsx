/**
 * Basic Info Step - Step 1 of patient onboarding
 */

import { useTranslation } from 'react-i18next';
import { User, Phone, Mail, Calendar, CreditCard, UserPlus } from 'lucide-react';
import { Input } from '../../../../../components/common/Input';
import type { BasicInfoData } from '../../../../../types/onboarding.types';

interface BasicInfoStepProps {
  data: BasicInfoData;
  onChange: (data: BasicInfoData) => void;
  doctorPhone?: string;
  doctorEmail?: string;
}

export function BasicInfoStep({
  data,
  onChange,
  doctorPhone,
  doctorEmail,
}: BasicInfoStepProps) {
  const { t } = useTranslation('onboarding');

  const handleChange = (field: keyof BasicInfoData, value: string) => {
    onChange({ ...data, [field]: value || undefined });
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
          placeholder="John Smith"
          value={data.full_name}
          onChange={(e) => handleChange('full_name', e.target.value)}
          leftIcon={<User size={18} />}
        />
        <Input
          label={t('basicInfo.nationalId')}
          placeholder="12345678901"
          value={data.national_id || ''}
          onChange={(e) => handleChange('national_id', e.target.value)}
          leftIcon={<CreditCard size={18} />}
        />
      </div>

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
      <Input
        label={t('basicInfo.phone')}
        placeholder="+90-555-0123"
        value={data.phone || ''}
        onChange={(e) => handleChange('phone', e.target.value)}
        leftIcon={<Phone size={18} />}
      />

      {/* Emergency Contact Section */}
      <div className="pt-4 border-t border-gray-200">
        <h4 className="text-md font-medium text-gray-900 mb-4 flex items-center gap-2">
          <UserPlus size={18} />
          {t('basicInfo.emergencyContact')}
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            label={t('basicInfo.emergencyPhone')}
            placeholder="+90-555-0124"
            value={data.emergency_contact_phone || ''}
            onChange={(e) => handleChange('emergency_contact_phone', e.target.value)}
            leftIcon={<Phone size={18} />}
          />
          <Input
            label={t('basicInfo.emergencyEmail')}
            type="email"
            placeholder="emergency@email.com"
            value={data.emergency_contact_email || ''}
            onChange={(e) => handleChange('emergency_contact_email', e.target.value)}
            leftIcon={<Mail size={18} />}
          />
        </div>
      </div>

      {/* Relative Contact Section */}
      <div className="pt-4 border-t border-gray-200">
        <h4 className="text-md font-medium text-gray-900 mb-4">
          {t('basicInfo.relativeName')}
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Input
            label={t('basicInfo.relativeName')}
            placeholder="Jane Smith"
            value={data.relative_name || ''}
            onChange={(e) => handleChange('relative_name', e.target.value)}
            leftIcon={<User size={18} />}
          />
          <Input
            label={t('basicInfo.relativePhone')}
            placeholder="+90-555-0125"
            value={data.relative_phone || ''}
            onChange={(e) => handleChange('relative_phone', e.target.value)}
            leftIcon={<Phone size={18} />}
          />
          <Input
            label={t('basicInfo.relativeEmail')}
            type="email"
            placeholder="relative@email.com"
            value={data.relative_email || ''}
            onChange={(e) => handleChange('relative_email', e.target.value)}
            leftIcon={<Mail size={18} />}
          />
        </div>
      </div>

      {/* Doctor Contact Section */}
      <div className="pt-4 border-t border-gray-200">
        <h4 className="text-md font-medium text-gray-900 mb-4">
          {t('basicInfo.doctorPhone')}
        </h4>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <Input
            label={t('basicInfo.doctorPhone')}
            placeholder="+90-555-0126"
            value={data.doctor_phone || doctorPhone || ''}
            onChange={(e) => handleChange('doctor_phone', e.target.value)}
            leftIcon={<Phone size={18} />}
          />
          <Input
            label={t('basicInfo.doctorEmail')}
            type="email"
            placeholder="doctor@email.com"
            value={data.doctor_email || doctorEmail || ''}
            onChange={(e) => handleChange('doctor_email', e.target.value)}
            leftIcon={<Mail size={18} />}
          />
        </div>
      </div>
    </div>
  );
}
