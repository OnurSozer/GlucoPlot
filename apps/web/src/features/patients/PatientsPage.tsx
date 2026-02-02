/**
 * Patients Page - List all patients
 */

import { useState, useEffect, useCallback } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Search, Plus, ChevronRight, QrCode } from 'lucide-react';
import { Card, CardContent } from '../../components/common/Card';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { StatusBadge } from '../../components/common/Badge';
import { PatientOnboardingModal } from './components/onboarding';
import { ViewQRModal } from './ViewQRModal';
import { patientsService } from '../../services/patients.service';
import { onboardingService } from '../../services/onboarding.service';
import { useAuthStore } from '../../stores/auth-store';
import { calculateAge } from '../../utils/format';
import type { Patient, PatientStatus } from '../../types/database.types';
import type { PatientOnboardingData } from '../../types/onboarding.types';

export function PatientsPage() {
    const { t } = useTranslation(['patients', 'common']);
    const [patients, setPatients] = useState<Patient[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState<PatientStatus | 'all'>('all');
    const [showOnboardingModal, setShowOnboardingModal] = useState(false);
    const [viewQrPatient, setViewQrPatient] = useState<Patient | null>(null);
    const [_newPatientQr, setNewPatientQr] = useState<{ id: string; name: string; qr: string } | null>(null);

    const statusFilters: { value: PatientStatus | 'all'; labelKey: string }[] = [
        { value: 'all', labelKey: 'common:common.all' },
        { value: 'active', labelKey: 'status.active' },
        { value: 'pending', labelKey: 'status.pending' },
        { value: 'inactive', labelKey: 'status.inactive' },
    ];

    const { user, isInitialized } = useAuthStore();
    const userId = user?.id; // Use primitive for stable dependency

    const loadPatients = useCallback(async (signal?: AbortSignal) => {
        try {
            setIsLoading(true);
            const { data, error } = await patientsService.getPatientsFiltered({
                status: statusFilter,
                search: searchQuery,
            });

            if (signal?.aborted) return;

            if (error) {
                console.error('Error loading patients:', error);
            } else {
                setPatients(data || []);
            }
        } finally {
            if (!signal?.aborted) {
                setIsLoading(false);
            }
        }
    }, [statusFilter, searchQuery]);

    useEffect(() => {
        if (!isInitialized || !userId) return;

        const abortController = new AbortController();
        loadPatients(abortController.signal);

        return () => {
            abortController.abort();
        };
    }, [isInitialized, userId, loadPatients]);

    const handlePatientCreated = async (data: PatientOnboardingData) => {
        const result = await onboardingService.createPatientWithOnboarding(data);
        if (result.data) {
            setNewPatientQr({
                id: result.data.patient_id,
                name: data.basicInfo.full_name,
                qr: result.data.qr_data,
            });
        }
        loadPatients();
    };

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">{t('title')}</h1>
                    <p className="text-gray-500 mt-1">{t('subtitle')}</p>
                </div>
                <Button
                    leftIcon={<Plus size={18} />}
                    onClick={() => setShowOnboardingModal(true)}
                >
                    {t('addPatient')}
                </Button>
            </div>

            {/* Filters */}
            <div className="flex items-center gap-4">
                <div className="flex-1 max-w-md">
                    <Input
                        placeholder={t('searchPlaceholder')}
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        leftIcon={<Search size={18} />}
                    />
                </div>

                <div className="flex items-center gap-2 bg-white/80 backdrop-blur-sm rounded-xl p-1 border border-gray-200">
                    {statusFilters.map(({ value, labelKey }) => (
                        <button
                            key={value}
                            onClick={() => setStatusFilter(value)}
                            className={`
                px-4 py-2 text-sm font-medium rounded-lg transition-all
                ${statusFilter === value
                                    ? 'bg-primary text-white shadow-sm'
                                    : 'text-gray-600 hover:bg-gray-100'
                                }
              `}
                        >
                            {t(labelKey)}
                        </button>
                    ))}
                </div>
            </div>

            {/* Patients List */}
            {isLoading ? (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {[1, 2, 3, 4, 5, 6].map(i => (
                        <div key={i} className="h-32 bg-gray-200 rounded-2xl animate-pulse" />
                    ))}
                </div>
            ) : patients.length === 0 ? (
                <Card>
                    <CardContent className="py-12 text-center">
                        <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                            <Search size={24} className="text-gray-400" />
                        </div>
                        <h3 className="text-lg font-medium text-gray-900 mb-1">
                            {searchQuery || statusFilter !== 'all' ? t('noMatchingPatients') : t('noPatients')}
                        </h3>
                        <p className="text-gray-500 mb-4">
                            {searchQuery || statusFilter !== 'all'
                                ? t('noMatchingPatientsDesc')
                                : t('noPatientsDesc')
                            }
                        </p>
                        <Button onClick={() => setShowOnboardingModal(true)} leftIcon={<Plus size={18} />}>
                            {t('addPatient')}
                        </Button>
                    </CardContent>
                </Card>
            ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    {patients.map((patient) => (
                        <PatientCard
                            key={patient.id}
                            patient={patient}
                            onViewQr={() => setViewQrPatient(patient)}
                        />
                    ))}
                </div>
            )}

            {/* Patient Onboarding Modal */}
            <PatientOnboardingModal
                isOpen={showOnboardingModal}
                onClose={() => setShowOnboardingModal(false)}
                onComplete={handlePatientCreated}
            />

            {/* View QR Modal */}
            <ViewQRModal
                isOpen={!!viewQrPatient}
                onClose={() => setViewQrPatient(null)}
                patientId={viewQrPatient?.id || ''}
                patientName={viewQrPatient?.full_name || ''}
            />
        </div>
    );
}

function PatientCard({ patient, onViewQr }: { patient: Patient; onViewQr: () => void }) {
    const { t, i18n } = useTranslation('common');
    const age = calculateAge(patient.date_of_birth);

    // Get localized gender label
    const getGenderLabel = (gender: string | undefined | null) => {
        if (!gender) return '';
        const genderMap: Record<string, string> = {
            male: t('common.male'),
            female: t('common.female'),
            other: t('common.other'),
        };
        return genderMap[gender] || gender;
    };

    // Format date based on current locale
    const formatLocalizedDate = (date: string) => {
        const dateObj = new Date(date);
        return dateObj.toLocaleDateString(i18n.language === 'tr' ? 'tr-TR' : 'en-US', {
            year: 'numeric',
            month: 'short',
            day: 'numeric',
        });
    };

    return (
        <Card hover className="h-full flex flex-col">
            <Link to={`/patients/${patient.id}`} className="flex-1 block">
                <CardContent>
                    <div className="flex items-start justify-between">
                        <div className="flex items-center gap-3">
                            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-secondary to-secondary-dark flex items-center justify-center">
                                <span className="text-white font-medium">
                                    {patient.full_name.split(' ').map(n => n[0]).join('').slice(0, 2)}
                                </span>
                            </div>
                            <div>
                                <h3 className="font-semibold text-gray-900">{patient.full_name}</h3>
                                <p className="text-sm text-gray-500">
                                    {age ? `${age} ${t('common.years')}` : t('common.ageUnknown')}
                                    {patient.gender ? ` • ${getGenderLabel(patient.gender)}` : ''}
                                </p>
                            </div>
                        </div>
                        <StatusBadge status={patient.status} />
                    </div>
                </CardContent>
            </Link>

            <div className="px-5 pb-5 mt-auto flex items-center justify-between border-t border-gray-100 pt-4">
                <span className="text-sm text-gray-500">
                    {formatLocalizedDate(patient.created_at)}
                </span>

                <div className="flex items-center gap-2">
                    <button
                        onClick={(e) => {
                            e.preventDefault();
                            e.stopPropagation();
                            onViewQr();
                        }}
                        className="p-2 text-gray-400 hover:text-primary hover:bg-primary/5 rounded-lg transition-colors"
                        title="View QR Code"
                    >
                        <QrCode size={18} />
                    </button>
                    <Link
                        to={`/patients/${patient.id}`}
                        className="p-2 text-gray-400 hover:text-primary hover:bg-primary/5 rounded-lg transition-colors"
                    >
                        <ChevronRight size={18} />
                    </Link>
                </div>
            </div>
        </Card>
    );
}
