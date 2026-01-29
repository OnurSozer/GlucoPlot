/**
 * Dashboard Page - Overview of patients and alerts
 */

import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { Users, Bell, Activity, TrendingUp, ChevronRight, AlertCircle } from 'lucide-react';
import { useAuthStore } from '../../stores/auth-store';
import { StatCard } from '../../components/common/StatCard';
import { Card, CardContent, CardHeader } from '../../components/common/Card';
import { SeverityBadge } from '../../components/common/Badge';
import { patientsService } from '../../services/patients.service';
import { alertsService } from '../../services/alerts.service';
import { formatRelativeTime } from '../../utils/format';
import type { RiskAlert, Patient } from '../../types/database.types';

interface DashboardStats {
    totalPatients: number;
    activePatients: number;
    pendingPatients: number;
    newAlerts: number;
}

interface AlertWithPatient extends RiskAlert {
    patients?: Pick<Patient, 'id' | 'full_name'>;
}

export function DashboardPage() {
    const { doctor } = useAuthStore();
    const [stats, setStats] = useState<DashboardStats>({
        totalPatients: 0,
        activePatients: 0,
        pendingPatients: 0,
        newAlerts: 0,
    });
    const [recentAlerts, setRecentAlerts] = useState<AlertWithPatient[]>([]);
    const [isLoading, setIsLoading] = useState(true);

    useEffect(() => {
        loadDashboardData();
    }, []);

    const loadDashboardData = async () => {
        try {
            setIsLoading(true);

            // Load patient counts
            const patientCounts = await patientsService.getPatientCounts();

            // Load alert counts
            const alertCounts = await alertsService.getAlertCounts();

            // Load recent alerts
            const { data: alerts } = await alertsService.getAlerts({
                status: 'new',
                limit: 5
            });

            setStats({
                totalPatients: patientCounts.total,
                activePatients: patientCounts.active,
                pendingPatients: patientCounts.pending,
                newAlerts: alertCounts.new,
            });

            setRecentAlerts(alerts || []);
        } catch (error) {
            console.error('Error loading dashboard data:', error);
        } finally {
            setIsLoading(false);
        }
    };

    if (isLoading) {
        return (
            <div className="animate-pulse space-y-6">
                <div className="h-8 bg-gray-200 rounded w-48" />
                <div className="grid grid-cols-4 gap-6">
                    {[1, 2, 3, 4].map(i => (
                        <div key={i} className="h-32 bg-gray-200 rounded-2xl" />
                    ))}
                </div>
            </div>
        );
    }

    return (
        <div className="space-y-8 animate-fade-in">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900">
                    Welcome back, {doctor?.full_name?.split(' ')[0] || 'Doctor'}
                </h1>
                <p className="text-gray-500 mt-1">Here's an overview of your patients today</p>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <StatCard
                    title="Total Patients"
                    value={stats.totalPatients}
                    icon={<Users size={24} />}
                    color="#E8A87C"
                />
                <StatCard
                    title="Active Patients"
                    value={stats.activePatients}
                    subtitle="Currently monitoring"
                    icon={<Activity size={24} />}
                    color="#4CAF50"
                />
                <StatCard
                    title="Pending Activation"
                    value={stats.pendingPatients}
                    subtitle="Awaiting QR scan"
                    icon={<TrendingUp size={24} />}
                    color="#FF9800"
                />
                <StatCard
                    title="New Alerts"
                    value={stats.newAlerts}
                    subtitle="Requires attention"
                    icon={<Bell size={24} />}
                    color={stats.newAlerts > 0 ? '#E53935' : '#9CA3AF'}
                />
            </div>

            {/* Main Content Grid */}
            <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
                {/* Recent Alerts */}
                <div className="lg:col-span-2">
                    <Card>
                        <CardHeader className="flex items-center justify-between">
                            <div className="flex items-center gap-2">
                                <AlertCircle size={20} className="text-red-500" />
                                <h2 className="text-lg font-semibold text-gray-900">Recent Alerts</h2>
                            </div>
                            <Link
                                to="/alerts"
                                className="text-sm text-primary-dark hover:text-primary flex items-center gap-1"
                            >
                                View all <ChevronRight size={16} />
                            </Link>
                        </CardHeader>
                        <CardContent className="p-0">
                            {recentAlerts.length === 0 ? (
                                <div className="p-8 text-center">
                                    <div className="w-12 h-12 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-3">
                                        <Bell size={24} className="text-green-500" />
                                    </div>
                                    <p className="text-gray-500">No new alerts</p>
                                    <p className="text-sm text-gray-400 mt-1">All patients are within normal ranges</p>
                                </div>
                            ) : (
                                <div className="divide-y divide-gray-100">
                                    {recentAlerts.map((alert) => (
                                        <div
                                            key={alert.id}
                                            className="flex items-center justify-between p-4 hover:bg-gray-50 transition-colors"
                                        >
                                            <div className="flex items-center gap-4">
                                                <div
                                                    className={`
                            w-2 h-2 rounded-full
                            ${alert.severity === 'critical' ? 'bg-red-500' : ''}
                            ${alert.severity === 'high' ? 'bg-orange-500' : ''}
                            ${alert.severity === 'medium' ? 'bg-amber-500' : ''}
                            ${alert.severity === 'low' ? 'bg-green-500' : ''}
                          `}
                                                />
                                                <div>
                                                    <p className="font-medium text-gray-900">{alert.title}</p>
                                                    <p className="text-sm text-gray-500">
                                                        {alert.patients?.full_name || 'Unknown patient'}
                                                    </p>
                                                </div>
                                            </div>
                                            <div className="flex items-center gap-3">
                                                <SeverityBadge severity={alert.severity} />
                                                <span className="text-sm text-gray-400">
                                                    {formatRelativeTime(alert.created_at)}
                                                </span>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            )}
                        </CardContent>
                    </Card>
                </div>

                {/* Quick Actions */}
                <div>
                    <Card>
                        <CardHeader>
                            <h2 className="text-lg font-semibold text-gray-900">Quick Actions</h2>
                        </CardHeader>
                        <CardContent className="space-y-3">
                            <Link
                                to="/patients"
                                className="flex items-center gap-3 p-4 rounded-xl bg-gradient-to-r from-primary/10 to-primary/5 hover:from-primary/20 hover:to-primary/10 transition-colors"
                            >
                                <div className="w-10 h-10 rounded-lg bg-primary/20 flex items-center justify-center">
                                    <Users size={20} className="text-primary-dark" />
                                </div>
                                <div>
                                    <p className="font-medium text-gray-900">Add New Patient</p>
                                    <p className="text-sm text-gray-500">Create patient & generate QR</p>
                                </div>
                            </Link>

                            <Link
                                to="/alerts"
                                className="flex items-center gap-3 p-4 rounded-xl bg-gradient-to-r from-red-50 to-red-50/50 hover:from-red-100 hover:to-red-50 transition-colors"
                            >
                                <div className="w-10 h-10 rounded-lg bg-red-100 flex items-center justify-center">
                                    <Bell size={20} className="text-red-500" />
                                </div>
                                <div>
                                    <p className="font-medium text-gray-900">Review Alerts</p>
                                    <p className="text-sm text-gray-500">{stats.newAlerts} pending review</p>
                                </div>
                            </Link>
                        </CardContent>
                    </Card>
                </div>
            </div>
        </div>
    );
}
