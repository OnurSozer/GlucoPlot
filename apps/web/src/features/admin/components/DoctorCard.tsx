/**
 * Doctor Card Component
 */

import { useState } from 'react';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { Stethoscope, Users, Trash2, MoreVertical } from 'lucide-react';
import type { Doctor } from '../../../types/database.types';
import { doctorsService } from '../../../services/doctors.service';
import { useDoctorPatients } from '../../../hooks/queries/useDoctors';
import { Card, CardContent } from '../../../components/common/Card';

interface DoctorCardProps {
    doctor: Doctor;
    onDeleted?: () => void;
}

export function DoctorCard({ doctor, onDeleted }: DoctorCardProps) {
    const { t } = useTranslation();
    const [showMenu, setShowMenu] = useState(false);
    const [isDeleting, setIsDeleting] = useState(false);
    const { data: patients = [] } = useDoctorPatients(doctor.id);

    const initials = doctor.full_name
        .split(' ')
        .map((n) => n[0])
        .join('')
        .slice(0, 2);

    const handleDelete = async (e: React.MouseEvent) => {
        e.preventDefault();
        e.stopPropagation();

        const confirmed = window.confirm(t('admin.doctorDetail.confirmDelete'));
        if (!confirmed) return;

        setIsDeleting(true);
        try {
            const result = await doctorsService.deleteDoctor(doctor.id);
            if (result.data?.success) {
                onDeleted?.();
            } else {
                alert(result.data?.error || t('common.error'));
            }
        } catch (error) {
            console.error('Delete error:', error);
            alert(t('common.error'));
        } finally {
            setIsDeleting(false);
            setShowMenu(false);
        }
    };

    return (
        <Link to={`/admin/doctors/${doctor.id}`}>
            <Card className="bg-amber-900/40 border-amber-700/50 hover:bg-amber-900/60 transition-colors cursor-pointer group relative">
                <CardContent className="p-6">
                    <div className="flex items-start gap-4">
                        {/* Avatar */}
                        <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-amber-500 to-amber-700 flex items-center justify-center flex-shrink-0">
                            <span className="text-lg font-bold text-white">{initials}</span>
                        </div>

                        {/* Info */}
                        <div className="flex-1 min-w-0">
                            <h3 className="font-semibold text-white truncate group-hover:text-amber-300 transition-colors">
                                {doctor.full_name}
                            </h3>
                            <div className="flex items-center gap-1.5 mt-1">
                                <Stethoscope size={14} className="text-amber-400" />
                                <span className="text-sm text-amber-100 truncate">
                                    {doctor.specialty || t('auth.generalPractice')}
                                </span>
                            </div>
                            <div className="flex items-center gap-1.5 mt-2">
                                <Users size={14} className="text-amber-400" />
                                <span className="text-sm text-amber-100">
                                    {t('admin.doctors.patients', { count: patients.length })}
                                </span>
                            </div>
                        </div>

                        {/* Menu Button */}
                        <div className="relative">
                            <button
                                onClick={(e) => {
                                    e.preventDefault();
                                    e.stopPropagation();
                                    setShowMenu(!showMenu);
                                }}
                                className="p-2 rounded-lg text-amber-400 hover:text-white hover:bg-amber-700 transition-colors"
                            >
                                <MoreVertical size={18} />
                            </button>

                            {showMenu && (
                                <>
                                    <div
                                        className="fixed inset-0 z-10"
                                        onClick={(e) => {
                                            e.preventDefault();
                                            e.stopPropagation();
                                            setShowMenu(false);
                                        }}
                                    />
                                    <div className="absolute right-0 top-full mt-1 w-40 bg-amber-800 rounded-lg shadow-xl border border-amber-700 z-20 overflow-hidden">
                                        <button
                                            onClick={handleDelete}
                                            disabled={isDeleting}
                                            className="w-full flex items-center gap-2 px-4 py-2.5 text-sm text-red-400 hover:bg-red-900/30 transition-colors disabled:opacity-50"
                                        >
                                            <Trash2 size={16} />
                                            {isDeleting ? t('common.deleting') : t('admin.doctorDetail.delete')}
                                        </button>
                                    </div>
                                </>
                            )}
                        </div>
                    </div>

                    {/* Email */}
                    <p className="text-sm text-amber-200 mt-3 truncate">{doctor.email}</p>
                </CardContent>
            </Card>
        </Link>
    );
}
