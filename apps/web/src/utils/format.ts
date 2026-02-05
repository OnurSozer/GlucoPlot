/**
 * Formatting utilities
 * Date formatting, measurement display, etc.
 */

import { format, formatDistanceToNow, parseISO, isValid } from 'date-fns';
import { tr, enUS } from 'date-fns/locale';

// Map of language codes to date-fns locales
const locales: Record<string, typeof enUS> = {
    en: enUS,
    tr: tr,
};

/**
 * Get the date-fns locale for the current language
 */
export function getDateLocale(lang: string): typeof enUS {
    return locales[lang] || enUS;
}

// ============================================================
// Date Formatting
// ============================================================

/**
 * Format a date string to a readable format
 */
export function formatDate(date: string | Date | null | undefined, formatStr = 'MMM d, yyyy', lang = 'en'): string {
    if (!date) return '-';

    const dateObj = typeof date === 'string' ? parseISO(date) : date;

    if (!isValid(dateObj)) return '-';

    return format(dateObj, formatStr, { locale: getDateLocale(lang) });
}

/**
 * Format a date to show time
 */
export function formatDateTime(date: string | Date | null | undefined): string {
    return formatDate(date, 'MMM d, yyyy h:mm a');
}

/**
 * Format a date to show only time (converts UTC to local timezone)
 */
export function formatTime(date: string | Date | null | undefined): string {
    return formatDate(date, 'h:mm a');
}

/**
 * Format a date as relative time (e.g., "2 hours ago")
 */
export function formatRelativeTime(date: string | Date | null | undefined, lang = 'en'): string {
    if (!date) return '-';

    const dateObj = typeof date === 'string' ? parseISO(date) : date;

    if (!isValid(dateObj)) return '-';

    return formatDistanceToNow(dateObj, { addSuffix: true, locale: getDateLocale(lang) });
}

// ============================================================
// Measurement Formatting
// ============================================================

/**
 * Format a measurement value with unit
 */
export function formatMeasurement(
    value: number | null | undefined,
    unit: string,
    secondaryValue?: number | null
): string {
    if (value === null || value === undefined) return '-';

    // Blood pressure: show systolic/diastolic
    if (secondaryValue !== null && secondaryValue !== undefined) {
        return `${value}/${secondaryValue} ${unit}`;
    }

    return `${value} ${unit}`;
}

/**
 * Get color for measurement type
 */
export function getMeasurementColor(type: string): string {
    const colors: Record<string, string> = {
        glucose: '#FF6B6B',
        blood_pressure: '#E76F51',
        heart_rate: '#FF8FA3',
        weight: '#9B8FD9',
        temperature: '#FFB347',
        spo2: '#4ECDC4',
    };

    return colors[type] || '#6B7280';
}

/**
 * Get label for measurement type
 */
export function getMeasurementLabel(type: string): string {
    const labels: Record<string, string> = {
        glucose: 'Blood Glucose',
        blood_pressure: 'Blood Pressure',
        heart_rate: 'Heart Rate',
        weight: 'Weight',
        temperature: 'Temperature',
        spo2: 'Oxygen Saturation',
    };

    return labels[type] || type;
}

// ============================================================
// Alert Formatting
// ============================================================

/**
 * Get color for alert severity
 */
export function getAlertSeverityColor(severity: string): string {
    const colors: Record<string, string> = {
        critical: '#D32F2F',
        high: '#F57C00',
        medium: '#FFB300',
        low: '#43A047',
    };

    return colors[severity] || '#6B7280';
}

/**
 * Get background color for alert severity (lighter shade)
 */
export function getAlertSeverityBgColor(severity: string): string {
    const colors: Record<string, string> = {
        critical: '#FFEBEE',
        high: '#FFF3E0',
        medium: '#FFFDE7',
        low: '#E8F5E9',
    };

    return colors[severity] || '#F3F4F6';
}

// ============================================================
// Patient Formatting
// ============================================================

/**
 * Get status badge color
 */
export function getPatientStatusColor(status: string): { bg: string; text: string } {
    const colors: Record<string, { bg: string; text: string }> = {
        active: { bg: '#E8F5E9', text: '#2E7D32' },
        pending: { bg: '#FFF8E1', text: '#F57C00' },
        inactive: { bg: '#FAFAFA', text: '#757575' },
    };

    return colors[status] || { bg: '#F3F4F6', text: '#6B7280' };
}

/**
 * Calculate age from date of birth
 */
export function calculateAge(dateOfBirth: string | null | undefined): number | null {
    if (!dateOfBirth) return null;

    const dob = parseISO(dateOfBirth);
    if (!isValid(dob)) return null;

    const today = new Date();
    let age = today.getFullYear() - dob.getFullYear();
    const monthDiff = today.getMonth() - dob.getMonth();

    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dob.getDate())) {
        age--;
    }

    return age;
}

// ============================================================
// General Formatting
// ============================================================

/**
 * Truncate text with ellipsis
 */
export function truncate(text: string, maxLength: number): string {
    if (text.length <= maxLength) return text;
    return text.slice(0, maxLength - 3) + '...';
}

/**
 * Format phone number for display (Turkish format: +90 505 540 80 09)
 */
export function formatPhone(phone: string | null | undefined): string {
    if (!phone) return '-';

    // Remove all non-digit characters except +
    const cleaned = phone.replace(/[^\d+]/g, '');

    // Handle Turkish numbers: +905055408009 or 905055408009 or 5055408009
    if (cleaned.startsWith('+90') && cleaned.length === 13) {
        // +905055408009 -> +90 505 540 80 09
        return `+90 ${cleaned.slice(3, 6)} ${cleaned.slice(6, 9)} ${cleaned.slice(9, 11)} ${cleaned.slice(11)}`;
    } else if (cleaned.startsWith('90') && cleaned.length === 12) {
        // 905055408009 -> +90 505 540 80 09
        return `+90 ${cleaned.slice(2, 5)} ${cleaned.slice(5, 8)} ${cleaned.slice(8, 10)} ${cleaned.slice(10)}`;
    } else if (cleaned.length === 10 && cleaned.startsWith('5')) {
        // 5055408009 -> +90 505 540 80 09
        return `+90 ${cleaned.slice(0, 3)} ${cleaned.slice(3, 6)} ${cleaned.slice(6, 8)} ${cleaned.slice(8)}`;
    }

    // Return original if doesn't match Turkish format
    return phone;
}

// ============================================================
// Daily Log Formatting
// ============================================================

/**
 * Get color for log type
 */
export function getLogTypeColor(type: string): string {
    const colors: Record<string, string> = {
        food: '#FF9F43',
        sleep: '#6C5CE7',
        exercise: '#00B894',
        medication: '#E84393',
        symptom: '#FD79A8',
        note: '#636E72',
    };

    return colors[type] || '#6B7280';
}

/**
 * Get label for log type
 */
export function getLogTypeLabel(type: string): string {
    const labels: Record<string, string> = {
        food: 'Meal',
        sleep: 'Sleep',
        exercise: 'Exercise',
        medication: 'Medication',
        symptom: 'Symptom',
        note: 'Note',
    };

    return labels[type] || type;
}

/**
 * Get icon name for log type (for lucide-react)
 */
export function getLogTypeIcon(type: string): string {
    const icons: Record<string, string> = {
        food: 'UtensilsCrossed',
        sleep: 'Moon',
        exercise: 'Dumbbell',
        medication: 'Pill',
        symptom: 'Stethoscope',
        note: 'FileText',
    };

    return icons[type] || 'FileText';
}
