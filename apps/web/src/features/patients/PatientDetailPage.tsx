/**
 * Patient Detail Page - View patient info, measurements, and logs
 */

import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import {
    ArrowLeft,
    Activity,
    Heart,
    Droplets,
    Thermometer,
    Scale,
    Wind,
    Calendar,
    Phone,
    FileText
} from 'lucide-react';
import { Card, CardContent, CardHeader } from '../../components/common/Card';
import { StatusBadge } from '../../components/common/Badge';
import { MeasurementChart } from './MeasurementChart';
import { PatientProfileView } from './PatientProfileView';
import { patientsService } from '../../services/patients.service';
import { measurementsService } from '../../services/measurements.service';
import {
    formatDate,
    calculateAge,
    formatMeasurement,
    getMeasurementColor,
    getMeasurementLabel
} from '../../utils/format';
import type { Patient, Measurement, MeasurementType } from '../../types/database.types';

const measurementIcons: Record<MeasurementType, typeof Activity> = {
    glucose: Droplets,
    blood_pressure: Heart,
    heart_rate: Activity,
    weight: Scale,
    temperature: Thermometer,
    spo2: Wind,
};

export function PatientDetailPage() {
    const { id } = useParams<{ id: string }>();
    const [patient, setPatient] = useState<Patient | null>(null);
    const [latestMeasurements, setLatestMeasurements] = useState<Partial<Record<MeasurementType, Measurement>>>({});
    const [selectedMeasurementType, setSelectedMeasurementType] = useState<MeasurementType>('glucose');
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
                <p className="text-gray-500">Patient not found</p>
                <Link to="/patients" className="text-primary-dark hover:text-primary mt-2 inline-block">
                    Back to patients
                </Link>
            </div>
        );
    }

    const age = calculateAge(patient.date_of_birth);

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Back button */}
            <Link
                to="/patients"
                className="inline-flex items-center gap-2 text-gray-500 hover:text-gray-700 transition-colors"
            >
                <ArrowLeft size={18} />
                <span>Back to patients</span>
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
                                        {age} years old
                                    </span>
                                )}
                                {patient.gender && (
                                    <span className="capitalize">{patient.gender}</span>
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
                                        <span className="font-medium">Medical Notes</span>
                                    </div>
                                    <p className="text-gray-700 text-sm">{patient.medical_notes}</p>
                                </div>
                            )}
                        </div>

                        <div className="text-right text-sm text-gray-500">
                            <p>Patient since</p>
                            <p className="font-medium text-gray-700">{formatDate(patient.created_at)}</p>
                        </div>
                    </div>
                </CardContent>
            </Card>

            {/* Latest Measurements Grid */}
            <div>
                <h2 className="text-lg font-semibold text-gray-900 mb-4">Latest Measurements</h2>
                <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-4">
                    {(['glucose', 'blood_pressure', 'heart_rate', 'weight', 'temperature', 'spo2'] as MeasurementType[]).map((type) => {
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
                                <p className="text-xs text-gray-500 mb-1">{getMeasurementLabel(type)}</p>
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
                        {getMeasurementLabel(selectedMeasurementType)} Trend
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
        </div>
    );
}
