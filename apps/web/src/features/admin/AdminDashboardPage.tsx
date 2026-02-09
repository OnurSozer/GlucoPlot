/**
 * Admin Dashboard Page
 */

import { useTranslation } from 'react-i18next';
import { Stethoscope, Users } from 'lucide-react';
import { Link } from 'react-router-dom';
import { useAuthStore } from '../../stores/auth-store';
import { useDoctorStats, useTotalPatientCount } from '../../hooks/queries/useDoctors';
import { Card, CardContent, CardHeader } from '../../components/common/Card';
import { Button } from '../../components/common/Button';

export function AdminDashboardPage() {
    const { t } = useTranslation();
    const { admin } = useAuthStore();
    const { data: doctorStats } = useDoctorStats();
    const { data: patientCount } = useTotalPatientCount();

    return (
        <div className="space-y-8">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900">
                    {t('admin.dashboard.welcome', { name: admin?.full_name || 'Admin' })}
                </h1>
                <p className="text-gray-500 mt-1">{t('admin.dashboard.overview')}</p>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {/* Total Doctors */}
                <Card>
                    <CardContent className="p-6">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-xl bg-primary/20 flex items-center justify-center">
                                <Stethoscope className="text-primary-dark" size={24} />
                            </div>
                            <div>
                                <p className="text-sm text-gray-500">{t('admin.dashboard.totalDoctors')}</p>
                                <p className="text-2xl font-bold text-gray-900">
                                    {doctorStats?.total ?? '-'}
                                </p>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                {/* Total Patients */}
                <Card>
                    <CardContent className="p-6">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-xl bg-secondary/20 flex items-center justify-center">
                                <Users className="text-secondary-dark" size={24} />
                            </div>
                            <div>
                                <p className="text-sm text-gray-500">{t('admin.dashboard.totalPatients')}</p>
                                <p className="text-2xl font-bold text-gray-900">
                                    {patientCount ?? '-'}
                                </p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Quick Actions */}
            <Card>
                <CardHeader>
                    <h2 className="text-lg font-semibold text-gray-900">{t('admin.dashboard.quickActions')}</h2>
                </CardHeader>
                <CardContent className="pt-4">
                    <div className="flex flex-wrap gap-3">
                        <Link to="/admin/doctors">
                            <Button>
                                <Stethoscope size={18} className="mr-2" />
                                {t('admin.nav.doctors')}
                            </Button>
                        </Link>
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
