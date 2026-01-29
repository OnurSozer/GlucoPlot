/**
 * Main Layout component with sidebar and content area
 */

import { Navigate, Outlet } from 'react-router-dom';
import { Sidebar } from './Sidebar';
import { useAuthStore } from '../../stores/auth-store';

export function Layout() {
    const { user, doctor } = useAuthStore();

    // Redirect to login if not authenticated or not a doctor
    if (!user || !doctor) {
        return <Navigate to="/login" replace />;
    }

    return (
        <div className="min-h-screen bg-gradient-to-b from-[#FDF6F0] to-[#F5EDE6]">
            <Sidebar />

            {/* Main Content */}
            <main className="ml-64 min-h-screen">
                <div className="p-8">
                    <Outlet />
                </div>
            </main>
        </div>
    );
}
