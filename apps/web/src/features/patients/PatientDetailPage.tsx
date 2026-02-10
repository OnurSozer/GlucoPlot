/**
 * Patient Detail Page - View patient info, measurements, and logs
 * Uses SWR pattern via TanStack Query for instant cached data display
 */

import { useState, useEffect } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
    ArrowLeft,
    Heart,
    Droplets,
    Calendar,
    Phone,
    CreditCard,
    FileText,
    BarChart3,
    ClipboardList,
    Ruler,
    Scale,
    Trash2,
    AlertTriangle,
    X,
    Pencil,
    Check,
    Loader2
} from 'lucide-react';
import { Card, CardContent, CardHeader } from '../../components/common/Card';
import { PhoneInput } from '../../components/common/PhoneInput';
import { Button } from '../../components/common/Button';
import { StatusBadge } from '../../components/common/Badge';
import { MeasurementChart } from './MeasurementChart';
import { PatientProfileView } from './PatientProfileView';
import { DailyLogsTab } from './components/DailyLogsTab';
import { patientsService } from '../../services/patients.service';
import { onboardingService } from '../../services/onboarding.service';
import { usePatient, useLatestMeasurements, useInvalidatePatients } from '../../hooks/queries';
import {
    formatDate,
    calculateAge,
    formatMeasurement,
    getMeasurementColor,
    formatPhone
} from '../../utils/format';
import type { MeasurementType } from '../../types/database.types';
import type { PatientOnboardingData } from '../../types/onboarding.types';

type TabType = 'measurements' | 'dailyLogs';

// Show glucose, blood pressure, and weight measurements
const DISPLAYED_MEASUREMENTS: MeasurementType[] = ['glucose', 'blood_pressure', 'weight'];

const measurementIcons: Record<string, typeof Droplets> = {
    glucose: Droplets,
    blood_pressure: Heart,
    weight: Scale,
};

export function PatientDetailPage() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { t, i18n } = useTranslation(['patients', 'dailyLogs', 'common']);
    const [onboardingData, setOnboardingData] = useState<PatientOnboardingData | null>(null);
    const [selectedMeasurementType, setSelectedMeasurementType] = useState<MeasurementType>('glucose');
    const [activeTab, setActiveTab] = useState<TabType>('measurements');
    const [showDeleteModal, setShowDeleteModal] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);
    const [isEditingPhone, setIsEditingPhone] = useState(false);
    const [editPhone, setEditPhone] = useState('');
    const [isSavingPhone, setIsSavingPhone] = useState(false);
    const { invalidateAll: invalidatePatients, invalidatePatient } = useInvalidatePatients();

    // SWR pattern: cached data shows instantly, refreshes in background
    const {
        data: patient,
        isLoading: patientLoading,
    } = usePatient(id || '', !!id);

    const {
        data: latestMeasurements = {},
        isLoading: measurementsLoading,
    } = useLatestMeasurements(id || '', !!id);

    const isLoading = patientLoading || measurementsLoading;

    // Load onboarding data (not using query hook yet - less critical)
    useEffect(() => {
        if (!id) return;

        const loadOnboarding = async () => {
            try {
                const { data: onboarding } = await onboardingService.getOnboardingData(id);
                setOnboardingData(onboarding);
            } catch (error) {
                console.error('Error loading onboarding data:', error);
            }
        };

        loadOnboarding();
    }, [id]);

    const handleDeletePatient = async () => {
        if (!id) return;

        setIsDeleting(true);
        try {
            const result = await patientsService.deletePatient(id);
            if (result.success) {
                invalidatePatients(); // Clear cache
                navigate('/patients', { replace: true });
            } else {
                console.error('Failed to delete patient:', result.error);
                alert(t('patients:deleteModal.failed'));
            }
        } catch (error) {
            console.error('Error deleting patient:', error);
            alert(t('patients:deleteModal.failed'));
        } finally {
            setIsDeleting(false);
            setShowDeleteModal(false);
        }
    };

    const handleEditPhone = () => {
        setEditPhone(patient?.phone || '');
        setIsEditingPhone(true);
    };

    const handleCancelPhone = () => {
        setIsEditingPhone(false);
        setEditPhone('');
    };

    const handleSavePhone = async () => {
        if (!id) return;
        setIsSavingPhone(true);
        try {
            const { error } = await patientsService.updatePatient(id, { phone: editPhone || null });
            if (error) throw error;
            invalidatePatient(id);
            setIsEditingPhone(false);
        } catch (error) {
            console.error('Failed to update phone:', error);
            alert(t('patients:editPhone.failed'));
        } finally {
            setIsSavingPhone(false);
        }
    };

    if (isLoading) {
        return (
            <div className="animate-pulse space-y-6">
                <div className="h-8 bg-gray-200 rounded w-48" />
                <div className="h-48 bg-gray-200 rounded-2xl" />
                <div className="grid grid-cols-3 gap-4">
                    {[1, 2, 3].map(i => (
                        <div key={i} className="h-24 bg-gray-200 rounded-2xl" />
                    ))}
                </div>
            </div>
        );
    }

    if (!patient) {
        return (
            <div className="text-center py-12">
                <p className="text-gray-500">{t('patients:notFound')}</p>
                <Link to="/patients" className="text-primary-dark hover:text-primary mt-2 inline-block">
                    {t('patients:backToPatients')}
                </Link>
            </div>
        );
    }

    const age = calculateAge(patient.date_of_birth);
    const height = onboardingData?.physical?.height_cm;
    const weight = onboardingData?.physical?.weight_kg;

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Back button */}
            <Link
                to="/patients"
                className="inline-flex items-center gap-2 text-gray-500 hover:text-gray-700 transition-colors"
            >
                <ArrowLeft size={18} />
                <span>{t('patients:backToPatients')}</span>
            </Link>

            {/* Patient Header */}
            <Card>
                <CardContent>
                    <div className="flex items-start gap-6">
                        <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-secondary to-secondary-dark flex items-center justify-center">
                            <span className="text-white font-bold text-2xl">
                                {patient.full_name.split(' ').map(n => n[0]).join('').slice(0, 2)}
                            </span>
                        </div>

                        <div className="flex-1">
                            <div className="flex items-center gap-3 mb-2">
                                <h1 className="text-2xl font-bold text-gray-900">{patient.full_name}</h1>
                                <StatusBadge status={patient.status} />
                            </div>

                            <div className="flex items-center gap-6 text-gray-500">
                                {age && (
                                    <span className="flex items-center gap-1.5">
                                        <Calendar size={16} />
                                        {age} {t('patients:yearsOld')}
                                    </span>
                                )}
                                {patient.gender && (
                                    <span>{t(`common:common.${patient.gender}`)}</span>
                                )}
                                {patient.national_id && (
                                    <span className="flex items-center gap-1.5">
                                        <CreditCard size={16} />
                                        {patient.national_id}
                                    </span>
                                )}
                                {isEditingPhone ? (
                                    <span className="flex items-center gap-2">
                                        <Phone size={16} />
                                        <div className="w-56">
                                            <PhoneInput
                                                value={editPhone}
                                                onChange={setEditPhone}
                                            />
                                        </div>
                                        <button
                                            onClick={handleCancelPhone}
                                            disabled={isSavingPhone}
                                            className="p-1.5 text-gray-500 hover:text-gray-700 hover:bg-gray-100 rounded-lg transition-colors"
                                        >
                                            <X size={16} />
                                        </button>
                                        <button
                                            onClick={handleSavePhone}
                                            disabled={isSavingPhone}
                                            className="p-1.5 text-green-600 hover:text-green-700 hover:bg-green-50 rounded-lg transition-colors"
                                        >
                                            {isSavingPhone ? <Loader2 size={16} className="animate-spin" /> : <Check size={16} />}
                                        </button>
                                    </span>
                                ) : (
                                    <span className="flex items-center gap-1.5 group">
                                        <Phone size={16} />
                                        {patient.phone ? formatPhone(patient.phone) : '-'}
                                        <button
                                            onClick={handleEditPhone}
                                            className="p-1 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors opacity-0 group-hover:opacity-100"
                                        >
                                            <Pencil size={14} />
                                        </button>
                                    </span>
                                )}
                            </div>

                            {patient.medical_notes && (
                                <div className="mt-4 p-3 bg-gray-50 rounded-xl">
                                    <div className="flex items-center gap-2 text-gray-600 text-sm mb-1">
                                        <FileText size={14} />
                                        <span className="font-medium">{t('patients:medicalNotes')}</span>
                                    </div>
                                    <p className="text-gray-700 text-sm">{patient.medical_notes}</p>
                                </div>
                            )}
                        </div>

                        <div className="text-right text-sm space-y-3">
                            {/* Patient Since */}
                            <div className="text-gray-500">
                                <p>{t('patients:patientSince')}</p>
                                <p className="font-medium text-gray-700">{formatDate(patient.created_at, 'd MMM yyyy', i18n.language)}</p>
                            </div>

                            {/* Height & Weight */}
                            {(height || weight) && (
                                <div className="flex gap-4 justify-end">
                                    {height && (
                                        <div className="flex items-center gap-1.5 text-gray-500">
                                            <Ruler size={14} />
                                            <span className="font-medium text-gray-700">{height} cm</span>
                                        </div>
                                    )}
                                    {weight && (
                                        <div className="flex items-center gap-1.5 text-gray-500">
                                            <Scale size={14} />
                                            <span className="font-medium text-gray-700">{weight} kg</span>
                                        </div>
                                    )}
                                </div>
                            )}

                            {/* Delete Button */}
                            <button
                                onClick={() => setShowDeleteModal(true)}
                                className="flex items-center gap-1.5 text-red-500 hover:text-red-600 hover:bg-red-50 px-3 py-1.5 rounded-lg transition-colors ml-auto"
                            >
                                <Trash2 size={14} />
                                <span>{t('patients:deleteModal.title')}</span>
                            </button>
                        </div>
                    </div>
                </CardContent>
            </Card>

            {/* Tab Navigation */}
            <div className="flex gap-2 border-b border-gray-200">
                <button
                    onClick={() => setActiveTab('measurements')}
                    className={`flex items-center gap-2 px-4 py-3 border-b-2 transition-colors ${
                        activeTab === 'measurements'
                            ? 'border-primary text-primary font-medium'
                            : 'border-transparent text-gray-500 hover:text-gray-700'
                    }`}
                >
                    <BarChart3 size={18} />
                    {t('patients:measurements')}
                </button>
                <button
                    onClick={() => setActiveTab('dailyLogs')}
                    className={`flex items-center gap-2 px-4 py-3 border-b-2 transition-colors ${
                        activeTab === 'dailyLogs'
                            ? 'border-primary text-primary font-medium'
                            : 'border-transparent text-gray-500 hover:text-gray-700'
                    }`}
                >
                    <ClipboardList size={18} />
                    {t('dailyLogs:title')}
                </button>
            </div>

            {/* Tab Content */}
            {activeTab === 'measurements' ? (
                <>
                    {/* Latest Measurements Grid - Glucose, Blood Pressure, and Weight */}
                    <div>
                        <h2 className="text-lg font-semibold text-gray-900 mb-4">{t('patients:latestMeasurements')}</h2>
                        <div className="grid grid-cols-3 gap-4">
                            {DISPLAYED_MEASUREMENTS.map((type) => {
                                const measurement = latestMeasurements[type];
                                const Icon = measurementIcons[type];
                                const color = getMeasurementColor(type);
                                const isSelected = selectedMeasurementType === type;

                                return (
                                    <button
                                        key={type}
                                        onClick={() => setSelectedMeasurementType(type)}
                                        className={`
                                            p-4 rounded-2xl border-2 transition-all text-left
                                            ${isSelected
                                                ? 'border-primary bg-primary/5'
                                                : 'border-transparent bg-white/80 hover:bg-white shadow-sm'
                                            }
                                        `}
                                    >
                                        <div className="flex items-center gap-2 mb-2">
                                            <div
                                                className="w-8 h-8 rounded-lg flex items-center justify-center"
                                                style={{ backgroundColor: `${color}20` }}
                                            >
                                                <Icon size={16} style={{ color }} />
                                            </div>
                                        </div>
                                        <p className="text-xs text-gray-500 mb-1">{t(`patients:measurementTypes.${type}`)}</p>
                                        <p className="text-lg font-bold text-gray-900">
                                            {measurement
                                                ? formatMeasurement(measurement.value_primary, measurement.unit, measurement.value_secondary)
                                                : '-'
                                            }
                                        </p>
                                    </button>
                                );
                            })}
                        </div>
                    </div>

                    {/* Measurement Chart */}
                    <Card>
                        <CardHeader>
                            <h2 className="text-lg font-semibold text-gray-900">
                                {t(`patients:measurementTypes.${selectedMeasurementType}`)} {t('patients:trend')}
                                <span className="text-sm font-normal text-gray-500 ml-2">
                                    ({selectedMeasurementType === 'glucose' ? 'mg/dL' : selectedMeasurementType === 'blood_pressure' ? 'mmHg' : 'kg'})
                                </span>
                            </h2>
                        </CardHeader>
                        <CardContent>
                            <MeasurementChart
                                patientId={patient.id}
                                type={selectedMeasurementType}
                            />
                        </CardContent>
                    </Card>

                    {/* Comprehensive Patient Profile */}
                    <PatientProfileView patientId={patient.id} />
                </>
            ) : (
                <DailyLogsTab patientId={patient.id} />
            )}

            {/* Delete Confirmation Modal */}
            {showDeleteModal && (
                <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 animate-fade-in">
                    <div className="bg-white rounded-2xl p-6 max-w-md w-full mx-4 shadow-xl">
                        <div className="flex items-center justify-between mb-4">
                            <div className="flex items-center gap-3">
                                <div className="w-10 h-10 rounded-full bg-red-100 flex items-center justify-center">
                                    <AlertTriangle className="text-red-600" size={20} />
                                </div>
                                <h3 className="text-lg font-semibold text-gray-900">
                                    {t('patients:deleteModal.title')}
                                </h3>
                            </div>
                            <button
                                onClick={() => setShowDeleteModal(false)}
                                className="text-gray-400 hover:text-gray-600 transition-colors"
                            >
                                <X size={20} />
                            </button>
                        </div>

                        <p className="text-gray-600 mb-4">
                            {t('patients:deleteModal.message')}
                        </p>

                        <ul className="space-y-2 mb-6 ml-4">
                            <li className="text-sm text-gray-500 flex items-center gap-2">
                                <span className="w-1.5 h-1.5 bg-red-400 rounded-full" />
                                {t('patients:deleteModal.dataList.measurements')}
                            </li>
                            <li className="text-sm text-gray-500 flex items-center gap-2">
                                <span className="w-1.5 h-1.5 bg-red-400 rounded-full" />
                                {t('patients:deleteModal.dataList.logs')}
                            </li>
                            <li className="text-sm text-gray-500 flex items-center gap-2">
                                <span className="w-1.5 h-1.5 bg-red-400 rounded-full" />
                                {t('patients:deleteModal.dataList.profile')}
                            </li>
                        </ul>

                        <div className="flex gap-3">
                            <Button
                                variant="secondary"
                                onClick={() => setShowDeleteModal(false)}
                                className="flex-1"
                                disabled={isDeleting}
                            >
                                {t('patients:deleteModal.cancelButton')}
                            </Button>
                            <Button
                                variant="danger"
                                onClick={handleDeletePatient}
                                className="flex-1"
                                isLoading={isDeleting}
                            >
                                {t('patients:deleteModal.confirmButton')}
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
