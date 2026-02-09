/**
 * Route definitions for GlucoPlot Web Portal
 */

import { createBrowserRouter, Navigate } from 'react-router-dom';
import { Layout } from '../components/layout/Layout';
import { AdminLayout } from '../components/layout/AdminLayout';
import { LoginPage } from '../features/auth/LoginPage';
import { DashboardPage } from '../features/dashboard/DashboardPage';
import { PatientsPage } from '../features/patients/PatientsPage';
import { PatientDetailPage } from '../features/patients/PatientDetailPage';
import { AlertsPage } from '../features/alerts/AlertsPage';
import { AdminDashboardPage } from '../features/admin/AdminDashboardPage';
import { DoctorsPage } from '../features/admin/DoctorsPage';
import { DoctorDetailPage } from '../features/admin/DoctorDetailPage';

export const router = createBrowserRouter([
    {
        path: '/login',
        element: <LoginPage />,
    },
    // Doctor routes
    {
        path: '/',
        element: <Layout />,
        children: [
            {
                index: true,
                element: <DashboardPage />,
            },
            {
                path: 'patients',
                element: <PatientsPage />,
            },
            {
                path: 'patients/:id',
                element: <PatientDetailPage />,
            },
            {
                path: 'alerts',
                element: <AlertsPage />,
            },
        ],
    },
    // Admin routes
    {
        path: '/admin',
        element: <AdminLayout />,
        children: [
            {
                index: true,
                element: <AdminDashboardPage />,
            },
            {
                path: 'doctors',
                element: <DoctorsPage />,
            },
            {
                path: 'doctors/:id',
                element: <DoctorDetailPage />,
            },
        ],
    },
    {
        path: '*',
        element: <Navigate to="/" replace />,
    },
]);
