/**
 * Doctor Detail Page (Admin)
 */

import { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
    ArrowLeft,
    Pencil,
    Trash2,
    Mail,
    Phone,
    Stethoscope,
    Users,
    Calendar,
} from 'lucide-react';
import { useDoctor, useDoctorPatients, useInvalidateDoctors } from '../../hooks/queries/useDoctors';
import { doctorsService } from '../../services/doctors.service';
import { Card, CardContent, CardHeader } from '../../components/common/Card';
import { Button } from '../../components/common/Button';
import { StatusBadge } from '../../components/common/Badge';
import { EditDoctorModal } from './components/EditDoctorModal';

export function DoctorDetailPage() {
    const { id } = useParams<{ id: string }>();
    const navigate = useNavigate();
    const { t } = useTranslation();
    const [showEditModal, setShowEditModal] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);
    const { invalidateAll } = useInvalidateDoctors();

    const { data: doctor, isLoading: doctorLoading } = useDoctor(id || '');
    const { data: patients = [], isLoading: patientsLoading } = useDoctorPatients(id || '');

    const handleDelete = async () => {
        if (!doctor || !id) return;

        const confirmed = window.confirm(t('admin.doctorDetail.confirmDelete'));
        if (!confirmed) return;

        setIsDeleting(true);
        try {
            const result = await doctorsService.deleteDoctor(id);
            if (result.data?.success) {
                invalidateAll();
                navigate('/admin/doctors');
            } else {
                alert(result.data?.error || t('common.error'));
            }
        } catch (error) {
            console.error('Delete error:', error);
            alert(t('common.error'));
        } finally {
            setIsDeleting(false);
        }
    };

    const handleEdited = () => {
        setShowEditModal(false);
        invalidateAll();
    };

    if (doctorLoading) {
        return (
            <div className="space-y-6">
                <div className="h-8 w-48 bg-amber-800/50 rounded animate-pulse" />
                <Card className="bg-amber-900/40 border-amber-700/50 animate-pulse">
                    <CardContent className="p-6">
                        <div className="h-32 bg-amber-800/50 rounded" />
                    </CardContent>
                </Card>
            </div>
        );
    }

    if (!doctor) {
        return (
            <div className="text-center py-12">
                <p className="text-amber-200/70">{t('admin.doctorDetail.notFound')}</p>
                <Button
                    onClick={() => navigate('/admin/doctors')}
                    variant="secondary"
                    className="mt-4 bg-amber-700 hover:bg-amber-600 text-white"
                >
                    <ArrowLeft size={18} className="mr-2" />
                    {t('common.back')}
                </Button>
            </div>
        );
    }

    const initials = doctor.full_name
        .split(' ')
        .map((n) => n[0])
        .join('')
        .slice(0, 2);

    return (
        <div className="space-y-6">
            {/* Back Button */}
            <button
                onClick={() => navigate('/admin/doctors')}
                className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors"
            >
                <ArrowLeft size={20} />
                <span>{t('common.back')}</span>
            </button>

            {/* Doctor Profile Card */}
            <Card className="bg-amber-900/40 border-amber-700/50">
                <CardContent className="p-6">
                    <div className="flex flex-col md:flex-row md:items-start gap-6">
                        {/* Avatar */}
                        <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-amber-500 to-amber-700 flex items-center justify-center flex-shrink-0">
                            <span className="text-2xl font-bold text-white">{initials}</span>
                        </div>

                        {/* Info */}
                        <div className="flex-1 space-y-4">
                            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                                <div>
                                    <h1 className="text-2xl font-bold text-white">{doctor.full_name}</h1>
                                    <div className="flex items-center gap-2 mt-1">
                                        <Stethoscope size={16} className="text-amber-400" />
                                        <span className="text-amber-100">
                                            {doctor.specialty || t('auth.generalPractice')}
                                        </span>
                                    </div>
                                </div>

                                <div className="flex gap-2">
                                    <Button
                                        onClick={() => setShowEditModal(true)}
                                        variant="secondary"
                                        className="bg-amber-700 hover:bg-amber-600 text-white border-amber-600"
                                    >
                                        <Pencil size={16} className="mr-2" />
                                        {t('admin.doctorDetail.edit')}
                                    </Button>
                                    <Button
                                        onClick={handleDelete}
                                        variant="danger"
                                        isLoading={isDeleting}
                                        className="bg-red-900/50 hover:bg-red-900 text-red-400 border-red-900"
                                    >
                                        <Trash2 size={16} className="mr-2" />
                                        {t('admin.doctorDetail.delete')}
                                    </Button>
                                </div>
                            </div>

                            {/* Contact Info */}
                            <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 pt-4 border-t border-amber-700/50">
                                <div className="flex items-center gap-3">
                                    <Mail size={18} className="text-amber-400" />
                                    <span className="text-amber-100">{doctor.email}</span>
                                </div>
                                {doctor.phone && (
                                    <div className="flex items-center gap-3">
                                        <Phone size={18} className="text-amber-400" />
                                        <span className="text-amber-100">{doctor.phone}</span>
                                    </div>
                                )}
                                <div className="flex items-center gap-3">
                                    <Calendar size={18} className="text-amber-400" />
                                    <span className="text-amber-100">
                                        {t('admin.doctorDetail.joinedOn', {
                                            date: new Date(doctor.created_at).toLocaleDateString(),
                                        })}
                                    </span>
                                </div>
                                <div className="flex items-center gap-3">
                                    <Users size={18} className="text-amber-400" />
                                    <span className="text-amber-100">
                                        {t('admin.doctors.patients', { count: patients.length })}
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>
                </CardContent>
            </Card>

            {/* Patients List */}
            <Card className="bg-amber-900/40 border-amber-700/50">
                <CardHeader variant="orange">
                    <h2 className="text-lg font-semibold text-white">
                        {t('admin.doctorDetail.patients')}
                    </h2>
                </CardHeader>
                <CardContent className="p-6 pt-4">
                    {patientsLoading && (
                        <div className="space-y-3">
                            {[...Array(3)].map((_, i) => (
                                <div key={i} className="h-16 bg-amber-800/30 rounded-xl animate-pulse" />
                            ))}
                        </div>
                    )}

                    {!patientsLoading && patients.length === 0 && (
                        <div className="text-center py-8">
                            <Users className="mx-auto text-amber-500 mb-2" size={32} />
                            <p className="text-amber-200/70">{t('admin.doctorDetail.noPatients')}</p>
                        </div>
                    )}

                    {!patientsLoading && patients.length > 0 && (
                        <div className="space-y-3">
                            {patients.map((patient) => (
                                <div
                                    key={patient.id}
                                    className="flex items-center justify-between p-4 bg-amber-800/30 rounded-xl"
                                >
                                    <div className="flex items-center gap-3">
                                        <div className="w-10 h-10 rounded-full bg-amber-700 flex items-center justify-center">
                                            <span className="text-sm font-medium text-white">
                                                {patient.full_name
                                                    .split(' ')
                                                    .map((n) => n[0])
                                                    .join('')
                                                    .slice(0, 2)}
                                            </span>
                                        </div>
                                        <div>
                                            <p className="font-medium text-white">{patient.full_name}</p>
                                            <p className="text-sm text-amber-200">
                                                {patient.phone || t('common.noPhone')}
                                            </p>
                                        </div>
                                    </div>
                                    <StatusBadge status={patient.status} />
                                </div>
                            ))}
                        </div>
                    )}
                </CardContent>
            </Card>

            {/* Edit Modal */}
            {doctor && (
                <EditDoctorModal
                    isOpen={showEditModal}
                    onClose={() => setShowEditModal(false)}
                    onSuccess={handleEdited}
                    doctor={doctor}
                />
            )}
        </div>
    );
}
