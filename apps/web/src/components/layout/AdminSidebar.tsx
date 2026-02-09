/**
 * Admin Sidebar navigation component
 */

import { NavLink, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import {
    LayoutDashboard,
    Stethoscope,
    LogOut,
    Shield,
} from 'lucide-react';
import { useAuthStore } from '../../stores/auth-store';
import { LanguageSwitcher } from '../common/LanguageSwitcher';

const navItems = [
    { to: '/admin', labelKey: 'admin.nav.dashboard', icon: LayoutDashboard, exact: true },
    { to: '/admin/doctors', labelKey: 'admin.nav.doctors', icon: Stethoscope, exact: false },
];

export function AdminSidebar() {
    const { t } = useTranslation();
    const location = useLocation();
    const { admin, signOut } = useAuthStore();

    return (
        <aside className="fixed left-0 top-0 h-screen w-64 bg-slate-900/95 backdrop-blur-md border-r border-slate-800 flex flex-col z-40">
            {/* Logo */}
            <div className="p-6 border-b border-slate-800">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-indigo-500 to-indigo-700 flex items-center justify-center">
                        <Shield size={24} className="text-white" />
                    </div>
                    <div>
                        <h1 className="font-bold text-lg text-white">{t('app.name')}</h1>
                        <p className="text-xs text-slate-400">{t('admin.portal')}</p>
                    </div>
                </div>
            </div>

            {/* Navigation */}
            <nav className="flex-1 p-4">
                <ul className="space-y-1">
                    {navItems.map(({ to, labelKey, icon: Icon, exact }) => {
                        const isActive = exact
                            ? location.pathname === to
                            : location.pathname === to || location.pathname.startsWith(to + '/');
                        const label = t(labelKey);

                        return (
                            <li key={to}>
                                <NavLink
                                    to={to}
                                    className={`
                                        flex items-center gap-3 px-4 py-3 rounded-xl
                                        transition-all duration-200
                                        ${isActive
                                            ? 'bg-indigo-600/20 text-indigo-300 font-medium'
                                            : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
                                        }
                                    `}
                                >
                                    <Icon size={20} />
                                    <span>{label}</span>
                                </NavLink>
                            </li>
                        );
                    })}
                </ul>
            </nav>

            {/* Language Switcher */}
            <div className="px-4 py-2 border-t border-slate-800">
                <LanguageSwitcher variant="dark" />
            </div>

            {/* Admin Profile & Sign Out */}
            <div className="p-4 border-t border-slate-800">
                {/* Admin Profile */}
                <div className="flex items-center gap-3 p-3 rounded-xl bg-slate-800 mb-3">
                    <div className="w-10 h-10 rounded-full bg-gradient-to-br from-indigo-500 to-indigo-700 flex items-center justify-center">
                        <span className="text-white font-medium text-sm">
                            {admin?.full_name?.split(' ').map(n => n[0]).join('').slice(0, 2) || 'AD'}
                        </span>
                    </div>
                    <div className="flex-1 min-w-0">
                        <p className="text-sm font-medium text-white truncate">
                            {admin?.full_name || 'Admin'}
                        </p>
                        <p className="text-xs text-slate-400 truncate">
                            {t('admin.administrator')}
                        </p>
                    </div>
                </div>

                {/* Sign Out Button */}
                <button
                    onClick={signOut}
                    className="flex items-center gap-3 w-full px-4 py-3 rounded-xl text-slate-400 hover:bg-red-900/30 hover:text-red-400 transition-colors"
                >
                    <LogOut size={20} />
                    <span>{t('nav.signOut')}</span>
                </button>
            </div>
        </aside>
    );
}
