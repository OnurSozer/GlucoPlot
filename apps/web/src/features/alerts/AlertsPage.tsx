/**
 * Alerts Page - Risk alert management
 */

import { useState, useEffect } from 'react';
import { AlertCircle, Check, CheckCircle, Clock } from 'lucide-react';
import { Card, CardContent } from '../../components/common/Card';
import { Button } from '../../components/common/Button';
import { SeverityBadge, Badge } from '../../components/common/Badge';
import { alertsService } from '../../services/alerts.service';
import { formatRelativeTime } from '../../utils/format';
import type { RiskAlert, Patient, AlertStatus } from '../../types/database.types';

interface AlertWithPatient extends RiskAlert {
    patients?: Pick<Patient, 'id' | 'full_name'>;
}

const statusFilters: { value: AlertStatus | 'all'; label: string; icon: typeof AlertCircle }[] = [
    { value: 'all', label: 'All Alerts', icon: AlertCircle },
    { value: 'new', label: 'New', icon: AlertCircle },
    { value: 'acknowledged', label: 'Acknowledged', icon: Clock },
    { value: 'resolved', label: 'Resolved', icon: CheckCircle },
];

export function AlertsPage() {
    const [alerts, setAlerts] = useState<AlertWithPatient[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [statusFilter, setStatusFilter] = useState<AlertStatus | 'all'>('new');
    const [actionLoading, setActionLoading] = useState<string | null>(null);

    useEffect(() => {
        loadAlerts();
    }, [statusFilter]);

    const loadAlerts = async () => {
        try {
            setIsLoading(true);
            const { data, error } = await alertsService.getAlerts({
                status: statusFilter,
            });

            if (error) {
                console.error('Error loading alerts:', error);
            } else {
                setAlerts(data || []);
            }
        } finally {
            setIsLoading(false);
        }
    };

    const handleAcknowledge = async (alertId: string) => {
        try {
            setActionLoading(alertId);
            await alertsService.acknowledgeAlert(alertId);
            loadAlerts();
        } catch (error) {
            console.error('Error acknowledging alert:', error);
        } finally {
            setActionLoading(null);
        }
    };

    const handleResolve = async (alertId: string) => {
        try {
            setActionLoading(alertId);
            await alertsService.resolveAlert(alertId);
            loadAlerts();
        } catch (error) {
            console.error('Error resolving alert:', error);
        } finally {
            setActionLoading(null);
        }
    };

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div>
                <h1 className="text-2xl font-bold text-gray-900">Risk Alerts</h1>
                <p className="text-gray-500 mt-1">Manage and respond to patient health alerts</p>
            </div>

            {/* Status Filter Tabs */}
            <div className="flex items-center gap-2 bg-white/80 backdrop-blur-sm rounded-xl p-1 border border-gray-200 w-fit">
                {statusFilters.map(({ value, label, icon: Icon }) => (
                    <button
                        key={value}
                        onClick={() => setStatusFilter(value)}
                        className={`
              flex items-center gap-2 px-4 py-2 text-sm font-medium rounded-lg transition-all
              ${statusFilter === value
                                ? 'bg-primary text-white shadow-sm'
                                : 'text-gray-600 hover:bg-gray-100'
                            }
            `}
                    >
                        <Icon size={16} />
                        {label}
                    </button>
                ))}
            </div>

            {/* Alerts List */}
            {isLoading ? (
                <div className="space-y-4">
                    {[1, 2, 3].map(i => (
                        <div key={i} className="h-24 bg-gray-200 rounded-2xl animate-pulse" />
                    ))}
                </div>
            ) : alerts.length === 0 ? (
                <Card>
                    <CardContent className="py-12 text-center">
                        <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                            <CheckCircle size={32} className="text-green-500" />
                        </div>
                        <h3 className="text-lg font-medium text-gray-900 mb-1">No alerts</h3>
                        <p className="text-gray-500">
                            {statusFilter === 'new'
                                ? 'Great! All alerts have been addressed.'
                                : `No ${statusFilter} alerts to show.`
                            }
                        </p>
                    </CardContent>
                </Card>
            ) : (
                <div className="space-y-4">
                    {alerts.map((alert) => (
                        <AlertCard
                            key={alert.id}
                            alert={alert}
                            onAcknowledge={() => handleAcknowledge(alert.id)}
                            onResolve={() => handleResolve(alert.id)}
                            isLoading={actionLoading === alert.id}
                        />
                    ))}
                </div>
            )}
        </div>
    );
}

interface AlertCardProps {
    alert: AlertWithPatient;
    onAcknowledge: () => void;
    onResolve: () => void;
    isLoading: boolean;
}

function AlertCard({ alert, onAcknowledge, onResolve, isLoading }: AlertCardProps) {
    const severityColors = {
        critical: 'border-l-red-500 bg-red-50/50',
        high: 'border-l-orange-500 bg-orange-50/50',
        medium: 'border-l-amber-500 bg-amber-50/50',
        low: 'border-l-green-500 bg-green-50/50',
    };

    return (
        <Card className={`border-l-4 ${severityColors[alert.severity]}`}>
            <CardContent>
                <div className="flex items-start justify-between gap-4">
                    <div className="flex-1">
                        <div className="flex items-center gap-3 mb-2">
                            <h3 className="font-semibold text-gray-900">{alert.title}</h3>
                            <SeverityBadge severity={alert.severity} />
                            {alert.status === 'acknowledged' && (
                                <Badge variant="info" size="sm">Acknowledged</Badge>
                            )}
                            {alert.status === 'resolved' && (
                                <Badge variant="success" size="sm">Resolved</Badge>
                            )}
                        </div>

                        <p className="text-gray-600 text-sm mb-3">{alert.description}</p>

                        <div className="flex items-center gap-4 text-sm text-gray-500">
                            <span>
                                Patient: <span className="font-medium text-gray-700">{alert.patients?.full_name || 'Unknown'}</span>
                            </span>
                            <span>{formatRelativeTime(alert.created_at)}</span>
                        </div>
                    </div>

                    {/* Actions */}
                    {alert.status === 'new' && (
                        <div className="flex items-center gap-2">
                            <Button
                                variant="secondary"
                                size="sm"
                                onClick={onAcknowledge}
                                isLoading={isLoading}
                                leftIcon={<Check size={16} />}
                            >
                                Acknowledge
                            </Button>
                            <Button
                                variant="primary"
                                size="sm"
                                onClick={onResolve}
                                isLoading={isLoading}
                                leftIcon={<CheckCircle size={16} />}
                            >
                                Resolve
                            </Button>
                        </div>
                    )}

                    {alert.status === 'acknowledged' && (
                        <Button
                            variant="primary"
                            size="sm"
                            onClick={onResolve}
                            isLoading={isLoading}
                            leftIcon={<CheckCircle size={16} />}
                        >
                            Resolve
                        </Button>
                    )}
                </div>
            </CardContent>
        </Card>
    );
}
