/**
 * GlucoPlot Web Portal - Root App Component
 */

import { useEffect } from 'react';
import { RouterProvider } from 'react-router-dom';
import { router } from './routes';
import { useAuthStore } from './stores/auth-store';

function App() {
    const { initialize, isInitialized, isLoading } = useAuthStore();

    useEffect(() => {
        initialize();
    }, [initialize]);

    // Show loading screen while initializing auth
    if (!isInitialized || isLoading) {
        return (
            <div className="min-h-screen flex items-center justify-center bg-gradient-to-b from-[#FDF6F0] to-[#F5EDE6]">
                <div className="flex flex-col items-center gap-4">
                    <div className="w-12 h-12 border-4 border-primary border-t-transparent rounded-full animate-spin" />
                    <p className="text-gray-500 text-sm">Loading GlucoPlot...</p>
                </div>
            </div>
        );
    }

    return <RouterProvider router={router} future={{ v7_startTransition: true }} />;
}

export default App;
