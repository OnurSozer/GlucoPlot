/**
 * Admin Dashboard Page
 */

import { useTranslation } from 'react-i18next';
import { UserPlus, Stethoscope, Users } from 'lucide-react';
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
                <h1 className="text-2xl font-bold text-white">
                    {t('admin.dashboard.welcome', { name: admin?.full_name || 'Admin' })}
                </h1>
                <p className="text-slate-400 mt-1">{t('admin.dashboard.overview')}</p>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {/* Total Doctors */}
                <Card className="bg-amber-900/40 border-amber-700/50">
                    <CardContent className="p-6">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-xl bg-amber-500/20 flex items-center justify-center">
                                <Stethoscope className="text-amber-400" size={24} />
                            </div>
                            <div>
                                <p className="text-sm text-amber-200/70">{t('admin.dashboard.totalDoctors')}</p>
                                <p className="text-2xl font-bold text-white">
                                    {doctorStats?.total ?? '-'}
                                </p>
                            </div>
                        </div>
                    </CardContent>
                </Card>

                {/* Total Patients */}
                <Card className="bg-amber-900/40 border-amber-700/50">
                    <CardContent className="p-6">
                        <div className="flex items-center gap-4">
                            <div className="w-12 h-12 rounded-xl bg-amber-500/20 flex items-center justify-center">
                                <Users className="text-amber-400" size={24} />
                            </div>
                            <div>
                                <p className="text-sm text-amber-200/70">{t('admin.dashboard.totalPatients')}</p>
                                <p className="text-2xl font-bold text-white">
                                    {patientCount ?? '-'}
                                </p>
                            </div>
                        </div>
                    </CardContent>
                </Card>
            </div>

            {/* Quick Actions */}
            <Card className="bg-amber-900/40 border-amber-700/50">
                <CardHeader variant="orange">
                    <h2 className="text-lg font-semibold text-white">{t('admin.dashboard.quickActions')}</h2>
                </CardHeader>
                <CardContent className="p-6 pt-4">
                    <div className="flex flex-wrap gap-3">
                        <Link to="/admin/doctors">
                            <Button variant="secondary" className="bg-amber-700 hover:bg-amber-600 text-white border-amber-600">
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
