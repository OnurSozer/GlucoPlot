/**
 * Admin Layout component with sidebar and content area
 */

import { Navigate, Outlet } from 'react-router-dom';
import { AdminSidebar } from './AdminSidebar';
import { useAuthStore } from '../../stores/auth-store';

export function AdminLayout() {
    const { user, admin } = useAuthStore();

    // Redirect to login if not authenticated or not an admin
    if (!user || !admin) {
        return <Navigate to="/login" replace />;
    }

    return (
        <div className="min-h-screen bg-gradient-to-b from-slate-950 to-slate-900">
            <AdminSidebar />

            {/* Main Content */}
            <main className="ml-64 min-h-screen">
                <div className="p-8">
                    <Outlet />
                </div>
            </main>
        </div>
    );
}
