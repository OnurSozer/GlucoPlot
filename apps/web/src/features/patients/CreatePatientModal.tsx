/**
 * Create Patient Modal - Form to create a new patient
 */

import { useState, FormEvent } from 'react';
import { useTranslation } from 'react-i18next';
import { QrCode, User, Phone } from 'lucide-react';
import { QRCodeSVG } from 'qrcode.react';
import { Modal, ModalFooter } from '../../components/common/Modal';
import { Button } from '../../components/common/Button';
import { Input } from '../../components/common/Input';
import { patientsService } from '../../services/patients.service';

interface CreatePatientModalProps {
    isOpen: boolean;
    onClose: () => void;
    onCreated: () => void;
}

export function CreatePatientModal({ isOpen, onClose, onCreated }: CreatePatientModalProps) {
    const { t } = useTranslation('patients');
    const [isLoading, setIsLoading] = useState(false);
    const [step, setStep] = useState<'form' | 'qr'>('form');
    const [error, setError] = useState('');
    const [qrToken, setQrToken] = useState('');

    // Form state
    const [fullName, setFullName] = useState('');
    const [phone, setPhone] = useState('');
    const [dateOfBirth, setDateOfBirth] = useState('');
    const [gender, setGender] = useState('');
    const [medicalNotes, setMedicalNotes] = useState('');

    const resetForm = () => {
        setFullName('');
        setPhone('');
        setDateOfBirth('');
        setGender('');
        setMedicalNotes('');
        setError('');
        setStep('form');
        setQrToken('');
    };

    const handleClose = () => {
        resetForm();
        onClose();
    };

    const handleSubmit = async (e: FormEvent) => {
        e.preventDefault();
        setError('');

        if (!fullName.trim()) {
            setError(t('createModal.nameRequired'));
            return;
        }

        try {
            setIsLoading(true);

            const { data, error: apiError } = await patientsService.createPatient({
                full_name: fullName.trim(),
                phone: phone.trim() || undefined,
                date_of_birth: dateOfBirth || undefined,
                gender: gender || undefined,
                medical_notes: medicalNotes.trim() || undefined,
            });

            if (apiError) {
                setError(apiError.message);
                return;
            }

            if (data?.qr_data) {
                setQrToken(data.qr_data);
                setStep('qr');
            } else {
                onCreated();
                handleClose();
            }
        } catch (err) {
            setError(t('createModal.createFailed'));
        } finally {
            setIsLoading(false);
        }
    };

    const handleDone = () => {
        onCreated();
        handleClose();
    };

    return (
        <Modal
            isOpen={isOpen}
            onClose={handleClose}
            title={step === 'form' ? t('createModal.title') : t('createModal.titleSuccess')}
            size="md"
        >
            {step === 'form' ? (
                <form onSubmit={handleSubmit} className="space-y-4">
                    {error && (
                        <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-red-600 text-sm">
                            {error}
                        </div>
                    )}

                    <Input
                        label={`${t('createModal.fullName')} *`}
                        placeholder={t('createModal.fullNamePlaceholder')}
                        value={fullName}
                        onChange={(e) => setFullName(e.target.value)}
                        leftIcon={<User size={18} />}
                    />

                    <Input
                        label={t('createModal.phone')}
                        placeholder={t('createModal.phonePlaceholder')}
                        value={phone}
                        onChange={(e) => setPhone(e.target.value)}
                        leftIcon={<Phone size={18} />}
                    />

                    <div className="grid grid-cols-2 gap-4">
                        <Input
                            label={t('createModal.dateOfBirth')}
                            type="date"
                            value={dateOfBirth}
                            onChange={(e) => setDateOfBirth(e.target.value)}
                        />

                        <div>
                            <label className="block text-sm font-medium text-gray-700 mb-1.5">
                                {t('createModal.gender')}
                            </label>
                            <select
                                value={gender}
                                onChange={(e) => setGender(e.target.value)}
                                className="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white/80 backdrop-blur-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary"
                            >
                                <option value="">{t('createModal.genderSelect')}</option>
                                <option value="male">{t('createModal.genderMale')}</option>
                                <option value="female">{t('createModal.genderFemale')}</option>
                            </select>
                        </div>
                    </div>

                    <div>
                        <label className="block text-sm font-medium text-gray-700 mb-1.5">
                            {t('createModal.medicalNotes')}
                        </label>
                        <textarea
                            value={medicalNotes}
                            onChange={(e) => setMedicalNotes(e.target.value)}
                            placeholder={t('createModal.medicalNotesPlaceholder')}
                            rows={3}
                            className="w-full px-4 py-2.5 rounded-xl border border-gray-200 bg-white/80 backdrop-blur-sm focus:outline-none focus:ring-2 focus:ring-primary/50 focus:border-primary resize-none"
                        />
                    </div>

                    <ModalFooter>
                        <Button variant="secondary" type="button" onClick={handleClose}>
                            {t('createModal.cancel')}
                        </Button>
                        <Button type="submit" isLoading={isLoading}>
                            {t('createModal.createButton')}
                        </Button>
                    </ModalFooter>
                </form>
            ) : (
                <div className="text-center py-4">
                    <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                        <QrCode size={32} className="text-green-600" />
                    </div>

                    <h3 className="text-lg font-semibold text-gray-900 mb-2">
                        {t('createModal.successTitle')}
                    </h3>

                    <p className="text-gray-500 mb-6">
                        {t('createModal.successDesc')}
                    </p>

                    {/* QR Code Display - Actual scannable QR code */}
                    <div className="bg-white p-6 rounded-2xl border border-gray-200 inline-block mb-6">
                        <div className="w-48 h-48 bg-white rounded-xl flex items-center justify-center p-2">
                            <QRCodeSVG
                                value={qrToken}
                                size={176}
                                level="M"
                                includeMargin={false}
                            />
                        </div>
                        <p className="text-xs text-gray-400 font-mono mt-2 break-all px-2 max-w-[200px]">
                            {qrToken.slice(0, 16)}...
                        </p>
                    </div>

                    <p className="text-sm text-gray-400 mb-6">
                        {t('createModal.token')}: <code className="bg-gray-100 px-2 py-1 rounded">{qrToken.slice(0, 20)}...</code>
                    </p>

                    <Button onClick={handleDone} fullWidth>
                        {t('createModal.done')}
                    </Button>
                </div>
            )}
        </Modal>
    );
}
