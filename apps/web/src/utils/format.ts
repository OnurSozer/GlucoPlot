/**
 * Formatting utilities
 * Date formatting, measurement display, etc.
 */

import { format, formatDistanceToNow, parseISO, isValid } from 'date-fns';

// ============================================================
// Date Formatting
// ============================================================

/**
 * Format a date string to a readable format
 */
export function formatDate(date: string | Date | null | undefined, formatStr = 'MMM d, yyyy'): string {
    if (!date) return '-';

    const dateObj = typeof date === 'string' ? parseISO(date) : date;

    if (!isValid(dateObj)) return '-';

    return format(dateObj, formatStr);
}

/**
 * Format a date to show time
 */
export function formatDateTime(date: string | Date | null | undefined): string {
    return formatDate(date, 'MMM d, yyyy h:mm a');
}

/**
 * Format a date to show only time
 */
export function formatTime(date: string | Date | null | undefined): string {
    return formatDate(date, 'h:mm a');
}

/**
 * Format a date as relative time (e.g., "2 hours ago")
 */
export function formatRelativeTime(date: string | Date | null | undefined): string {
    if (!date) return '-';

    const dateObj = typeof date === 'string' ? parseISO(date) : date;

    if (!isValid(dateObj)) return '-';

    return formatDistanceToNow(dateObj, { addSuffix: true });
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
 * Format phone number for display
 */
export function formatPhone(phone: string | null | undefined): string {
    if (!phone) return '-';
    return phone;
}
