/**
 * Edit Doctor Modal Component
 */

import { useState, useEffect } from 'react';
import { useTranslation } from 'react-i18next';
import { X, User, Phone, Stethoscope } from 'lucide-react';
import type { Doctor } from '../../../types/database.types';
import { doctorsService } from '../../../services/doctors.service';
import { Button } from '../../../components/common/Button';
import { Input } from '../../../components/common/Input';

interface EditDoctorModalProps {
    isOpen: boolean;
    onClose: () => void;
    onSuccess: () => void;
    doctor: Doctor;
}

export function EditDoctorModal({ isOpen, onClose, onSuccess, doctor }: EditDoctorModalProps) {
    const { t } = useTranslation();
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const [formData, setFormData] = useState({
        full_name: '',
        phone: '',
        specialty: '',
    });

    // Initialize form data when doctor changes
    useEffect(() => {
        if (doctor) {
            setFormData({
                full_name: doctor.full_name || '',
                phone: doctor.phone || '',
                specialty: doctor.specialty || '',
            });
        }
    }, [doctor]);

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        setFormData((prev) => ({
            ...prev,
            [e.target.name]: e.target.value,
        }));
        setError(null);
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setError(null);

        // Validation
        if (!formData.full_name.trim()) {
            setError(t('admin.createDoctor.nameRequired'));
            return;
        }

        setIsSubmitting(true);
        try {
            const result = await doctorsService.updateDoctor(doctor.id, {
                full_name: formData.full_name.trim(),
                phone: formData.phone.trim() || null,
                specialty: formData.specialty.trim() || null,
            });

            if (result.data?.success || result.data) {
                onSuccess();
            } else {
                setError(result.data?.error || t('admin.editDoctor.error'));
            }
        } catch (err) {
            console.error('Update doctor error:', err);
            setError(t('admin.editDoctor.error'));
        } finally {
            setIsSubmitting(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
            {/* Backdrop */}
            <div
                className="absolute inset-0 bg-black/60 backdrop-blur-sm"
                onClick={onClose}
            />

            {/* Modal */}
            <div className="relative w-full max-w-md mx-4 bg-amber-950 rounded-2xl shadow-2xl border border-amber-800">
                {/* Header */}
                <div className="flex items-center justify-between p-6 border-b border-amber-800">
                    <h2 className="text-xl font-semibold text-white">
                        {t('admin.editDoctor.title')}
                    </h2>
                    <button
                        onClick={onClose}
                        className="p-2 rounded-lg text-amber-400 hover:text-white hover:bg-amber-800 transition-colors"
                    >
                        <X size={20} />
                    </button>
                </div>

                {/* Form */}
                <form onSubmit={handleSubmit} className="p-6 space-y-4">
                    {error && (
                        <div className="p-3 bg-red-900/30 border border-red-800 rounded-lg text-red-400 text-sm">
                            {error}
                        </div>
                    )}

                    {/* Email (read-only) */}
                    <div>
                        <label className="block text-sm font-medium text-amber-200 mb-1.5">
                            {t('admin.createDoctor.email')}
                        </label>
                        <p className="px-4 py-2.5 bg-amber-900/50 border border-amber-700 rounded-xl text-amber-300">
                            {doctor.email}
                        </p>
                        <p className="text-xs text-amber-400 mt-1">
                            {t('admin.editDoctor.emailReadOnly')}
                        </p>
                    </div>

                    <Input
                        name="full_name"
                        label={t('admin.createDoctor.fullName')}
                        placeholder={t('admin.createDoctor.fullNamePlaceholder')}
                        value={formData.full_name}
                        onChange={handleChange}
                        leftIcon={<User size={18} />}
                        variant="orange"
                        required
                    />

                    <Input
                        name="phone"
                        type="tel"
                        label={t('admin.createDoctor.phone')}
                        placeholder={t('admin.createDoctor.phonePlaceholder')}
                        value={formData.phone}
                        onChange={handleChange}
                        leftIcon={<Phone size={18} />}
                        variant="orange"
                    />

                    <Input
                        name="specialty"
                        label={t('admin.createDoctor.specialty')}
                        placeholder={t('admin.createDoctor.specialtyPlaceholder')}
                        value={formData.specialty}
                        onChange={handleChange}
                        leftIcon={<Stethoscope size={18} />}
                        variant="orange"
                    />

                    {/* Actions */}
                    <div className="flex gap-3 pt-4">
                        <Button
                            type="button"
                            variant="secondary"
                            onClick={onClose}
                            className="flex-1 bg-amber-800 hover:bg-amber-700 text-white border-amber-700"
                        >
                            {t('common.cancel')}
                        </Button>
                        <Button
                            type="submit"
                            isLoading={isSubmitting}
                            className="flex-1 bg-amber-600 hover:bg-amber-500 text-white"
                        >
                            {t('admin.editDoctor.save')}
                        </Button>
                    </div>
                </form>
            </div>
        </div>
    );
}
