/**
 * Patient Detail Page - View patient info, measurements, and logs
 */

import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
    ArrowLeft,
    Heart,
    Droplets,
    Calendar,
    Phone,
    FileText,
    BarChart3,
    ClipboardList,
    Ruler,
    Scale
} from 'lucide-react';
import { Card, CardContent, CardHeader } from '../../components/common/Card';
import { StatusBadge } from '../../components/common/Badge';
import { MeasurementChart } from './MeasurementChart';
import { PatientProfileView } from './PatientProfileView';
import { DailyLogsTab } from './components/DailyLogsTab';
import { patientsService } from '../../services/patients.service';
import { measurementsService } from '../../services/measurements.service';
import { onboardingService } from '../../services/onboarding.service';
import {
    formatDate,
    calculateAge,
    formatMeasurement,
    getMeasurementColor
} from '../../utils/format';
import type { Patient, Measurement, MeasurementType } from '../../types/database.types';
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
    const { t, i18n } = useTranslation(['patients', 'dailyLogs', 'common']);
    const [patient, setPatient] = useState<Patient | null>(null);
    const [onboardingData, setOnboardingData] = useState<PatientOnboardingData | null>(null);
    const [latestMeasurements, setLatestMeasurements] = useState<Partial<Record<MeasurementType, Measurement>>>({});
    const [selectedMeasurementType, setSelectedMeasurementType] = useState<MeasurementType>('glucose');
    const [activeTab, setActiveTab] = useState<TabType>('measurements');
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        if (!id) return;

        const abortController = new AbortController();

        const loadPatientData = async () => {
            try {
                setIsLoading(true);

                // Load patient
                const { data: patientData } = await patientsService.getPatientById(id);

                if (abortController.signal.aborted) return;

                if (patientData) {
                    setPatient(patientData);
                }

                // Load latest measurements
                const latest = await measurementsService.getLatestMeasurements(id);

                if (abortController.signal.aborted) return;

                setLatestMeasurements(latest);

                // Load onboarding data for height/weight
                const { data: onboarding } = await onboardingService.getOnboardingData(id);

                if (abortController.signal.aborted) return;

                setOnboardingData(onboarding);

            } catch (error) {
                if (abortController.signal.aborted) return;
                console.error('Error loading patient data:', error);
            } finally {
                if (!abortController.signal.aborted) {
                    setIsLoading(false);
                }
            }
        };

        loadPatientData();

        return () => {
            abortController.abort();
        };
    }, [id]);

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
                                {patient.phone && (
                                    <span className="flex items-center gap-1.5">
                                        <Phone size={16} />
                                        {patient.phone}
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
        </div>
    );
}
