/**
 * Doctors List Page (Admin)
 */

import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { Search, UserPlus, Stethoscope } from 'lucide-react';
import { useDoctorsFiltered, useInvalidateDoctors } from '../../hooks/queries/useDoctors';
import { Card, CardContent } from '../../components/common/Card';
import { Input } from '../../components/common/Input';
import { Button } from '../../components/common/Button';
import { DoctorCard } from './components/DoctorCard';
import { CreateDoctorModal } from './components/CreateDoctorModal';

export function DoctorsPage() {
    const { t } = useTranslation();
    const [search, setSearch] = useState('');
    const [showCreateModal, setShowCreateModal] = useState(false);
    const { invalidateAll } = useInvalidateDoctors();

    const { data: doctors = [], isLoading, isFetching } = useDoctorsFiltered({ search });

    const handleDoctorCreated = () => {
        setShowCreateModal(false);
        invalidateAll();
    };

    return (
        <div className="space-y-6">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold text-white">{t('admin.doctors.title')}</h1>
                    <p className="text-slate-400 mt-1">{t('admin.doctors.subtitle')}</p>
                </div>
                <Button
                    onClick={() => setShowCreateModal(true)}
                    className="bg-amber-600 hover:bg-amber-500 text-white"
                >
                    <UserPlus size={18} className="mr-2" />
                    {t('admin.doctors.addDoctor')}
                </Button>
            </div>

            {/* Search */}
            <div className="max-w-md">
                <Input
                    placeholder={t('admin.doctors.searchPlaceholder')}
                    value={search}
                    onChange={(e) => setSearch(e.target.value)}
                    leftIcon={<Search size={18} />}
                    variant="orange"
                />
            </div>

            {/* Loading State */}
            {isLoading && (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {[...Array(6)].map((_, i) => (
                        <Card key={i} className="bg-amber-900/40 border-amber-700/50 animate-pulse">
                            <CardContent className="p-6">
                                <div className="flex items-center gap-4">
                                    <div className="w-12 h-12 rounded-full bg-amber-800/50" />
                                    <div className="flex-1">
                                        <div className="h-4 bg-amber-800/50 rounded w-3/4 mb-2" />
                                        <div className="h-3 bg-amber-800/50 rounded w-1/2" />
                                    </div>
                                </div>
                            </CardContent>
                        </Card>
                    ))}
                </div>
            )}

            {/* Doctors Grid */}
            {!isLoading && doctors.length > 0 && (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    {doctors.map((doctor) => (
                        <DoctorCard
                            key={doctor.id}
                            doctor={doctor}
                            onDeleted={invalidateAll}
                        />
                    ))}
                </div>
            )}

            {/* Empty State */}
            {!isLoading && doctors.length === 0 && (
                <Card className="bg-amber-900/40 border-amber-700/50">
                    <CardContent className="p-12 text-center">
                        <div className="w-16 h-16 rounded-full bg-amber-800/50 flex items-center justify-center mx-auto mb-4">
                            <Stethoscope className="text-amber-400" size={32} />
                        </div>
                        <h3 className="text-lg font-medium text-white mb-2">
                            {t('admin.doctors.noDoctors')}
                        </h3>
                        <p className="text-amber-200/70 mb-6">
                            {t('admin.doctors.noDoctorsDesc')}
                        </p>
                        <Button
                            onClick={() => setShowCreateModal(true)}
                            className="bg-amber-600 hover:bg-amber-500 text-white"
                        >
                            <UserPlus size={18} className="mr-2" />
                            {t('admin.doctors.addDoctor')}
                        </Button>
                    </CardContent>
                </Card>
            )}

            {/* Fetching Indicator */}
            {isFetching && !isLoading && (
                <div className="fixed bottom-4 right-4 bg-slate-800 text-slate-300 px-4 py-2 rounded-lg shadow-lg text-sm">
                    {t('common.refreshing')}
                </div>
            )}

            {/* Create Doctor Modal */}
            <CreateDoctorModal
                isOpen={showCreateModal}
                onClose={() => setShowCreateModal(false)}
                onSuccess={handleDoctorCreated}
            />
        </div>
    );
}
