import { useTranslation } from 'react-i18next';
import { FileText, Calendar, AlertCircle } from 'lucide-react';
import { ProfileSection } from './ProfileSection';
import { Badge } from '../../../../components/common/Badge';
import type { MedicalHistoryData, ChronicDiseasesData } from '../../../../types/onboarding.types';

interface MedicalHistoryCardProps {
    history: MedicalHistoryData;
    diseases: ChronicDiseasesData;
}

export function MedicalHistoryCard({ history, diseases }: MedicalHistoryCardProps) {
    const { t } = useTranslation('onboarding');

    // Convert snake_case to camelCase for translation keys
    const toCamelCase = (str: string) =>
        str.replace(/_([a-z])/g, (_, letter) => letter.toUpperCase());

    return (
        <ProfileSection title={t('steps.medicalHistory')} icon={FileText}>
            <div className="space-y-6">
                {/* Diabetes Information */}
                <div className="grid grid-cols-2 gap-4">
                    <div className="space-y-1">
                        <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                            {t('medicalHistory.diabetesType')}
                        </span>
                        <p className="text-base font-semibold text-gray-900">
                            {history.diabetes_type
                                ? t(`medicalHistory.types.${history.diabetes_type}`)
                                : '-'}
                        </p>
                    </div>

                    <div className="space-y-1">
                        <span className="text-xs font-medium text-gray-500 uppercase tracking-wider">
                            {t('medicalHistory.diagnosisDate')}
                        </span>
                        <div className="flex items-center gap-1.5 text-gray-900">
                            <Calendar size={16} className="text-gray-400" />
                            <span className="text-base font-medium">
                                {history.diagnosis_date || '-'}
                            </span>
                        </div>
                    </div>
                </div>

                {/* Chronic Diseases */}
                {diseases.diseases.length > 0 && (
                    <div className="pt-4 border-t border-gray-100/50">
                        <div className="flex items-center gap-2 mb-3 text-gray-500 text-sm font-medium">
                            <AlertCircle size={14} />
                            <span>{t('steps.chronicDiseases')}</span>
                        </div>
                        <div className="flex flex-wrap gap-2">
                            {diseases.diseases.map((disease) => (
                                <Badge key={disease} variant="warning" className="bg-orange-50 text-orange-700 border-orange-200">
                                    {t(`chronicDiseases.diseases.${toCamelCase(disease)}`)}
                                </Badge>
                            ))}
                            {diseases.other_details && (
                                <Badge variant="default" className="bg-gray-50 text-gray-700">
                                    {diseases.other_details}
                                </Badge>
                            )}
                        </div>
                    </div>
                )}
            </div>
        </ProfileSection>
    );
}
