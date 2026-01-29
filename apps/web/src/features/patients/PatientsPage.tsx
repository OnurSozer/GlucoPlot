/**
 * Patients Page - List all patients
 */

import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { Search, Plus, ChevronRight, QrCode } from 'lucide-react';
import { Card, CardContent } from '../../components/common/Card';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { StatusBadge } from '../../components/common/Badge';
import { CreatePatientModal } from './CreatePatientModal';
import { ViewQRModal } from './ViewQRModal';
import { patientsService } from '../../services/patients.service';
import { formatDate, calculateAge } from '../../utils/format';
import type { Patient, PatientStatus } from '../../types/database.types';

const statusFilters: { value: PatientStatus | 'all'; label: string }[] = [
    { value: 'all', label: 'All Patients' },
    { value: 'active', label: 'Active' },
    { value: 'pending', label: 'Pending' },
    { value: 'inactive', label: 'Inactive' },
];

export function PatientsPage() {
    const [patients, setPatients] = useState<Patient[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [searchQuery, setSearchQuery] = useState('');
    const [statusFilter, setStatusFilter] = useState<PatientStatus | 'all'>('all');
    const [showCreateModal, setShowCreateModal] = useState(false);
    const [viewQrPatient, setViewQrPatient] = useState<Patient | null>(null);

    useEffect(() => {
        loadPatients();
    }, [statusFilter, searchQuery]);

    const loadPatients = async () => {
        try {
            setIsLoading(true);
            const { data, error } = await patientsService.getPatientsFiltered({
                status: statusFilter,
                search: searchQuery,
            });

            if (error) {
                console.error('Error loading patients:', error);
            } else {
                setPatients(data || []);
            }
        } finally {
            setIsLoading(false);
        }
    };

    const handlePatientCreated = () => {
        setShowCreateModal(false);
        loadPatients();
    };

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div>
                    <h1 className="text-2xl font-bold text-gray-900">Patients</h1>
                    <p className="text-gray-500 mt-1">Manage and monitor your patients</p>
                </div>
                <Button
                    leftIcon={<Plus size={18} />}
                    onClick={() => setShowCreateModal(true)}
                >
                    Add Patient
                </Button>
            </div>

            {/* Filters */}
            <div className="flex items-center gap-4">
                <div className="flex-1 max-w-md">
                    <Input
                        placeholder="Search patients..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        leftIcon={<Search size={18} />}
                    />
                </div>

                <div className="flex items-center gap-2 bg-white/80 backdrop-blur-sm rounded-xl p-1 border border-gray-200">
                    {statusFilters.map(({ value, label }) => (
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
                            {label}
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
                        <h3 className="text-lg font-medium text-gray-900 mb-1">No patients found</h3>
                        <p className="text-gray-500 mb-4">
                            {searchQuery || statusFilter !== 'all'
                                ? 'Try adjusting your filters'
                                : 'Get started by adding your first patient'
                            }
                        </p>
                        <Button onClick={() => setShowCreateModal(true)} leftIcon={<Plus size={18} />}>
                            Add Patient
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

            {/* Create Patient Modal */}
            <CreatePatientModal
                isOpen={showCreateModal}
                onClose={() => setShowCreateModal(false)}
                onCreated={handlePatientCreated}
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
    const age = calculateAge(patient.date_of_birth);

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
                                    {age ? `${age} years` : 'Age unknown'}
                                    {patient.gender ? ` • ${patient.gender}` : ''}
                                </p>
                            </div>
                        </div>
                        <StatusBadge status={patient.status} />
                    </div>
                </CardContent>
            </Link>

            <div className="px-5 pb-5 mt-auto flex items-center justify-between border-t border-gray-100 pt-4">
                <span className="text-sm text-gray-500">
                    {formatDate(patient.created_at)}
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
