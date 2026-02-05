/**
 * View QR Code Modal - Display QR code for existing patients
 */

import { useState, useEffect } from 'react';
import { QRCodeSVG } from 'qrcode.react';
import { Modal } from '../../components/common/Modal';
import { Button } from '../../components/common/Button';
import { patientsService } from '../../services/patients.service';
import { AlertCircle, RefreshCw, CheckCircle } from 'lucide-react';

interface ViewQRModalProps {
    isOpen: boolean;
    onClose: () => void;
    patientId: string;
    patientName: string;
}

export function ViewQRModal({ isOpen, onClose, patientId, patientName }: ViewQRModalProps) {
    const [isLoading, setIsLoading] = useState(true);
    const [token, setToken] = useState<string | null>(null);
    const [inviteStatus, setInviteStatus] = useState<string | null>(null);
    const [expiresAt, setExpiresAt] = useState<string | null>(null);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (isOpen && patientId) {
            loadInvite();
        }
    }, [isOpen, patientId]);

    const loadInvite = async () => {
        setIsLoading(true);
        setError(null);

        const { data, error: fetchError } = await patientsService.getPatientInvite(patientId);

        if (fetchError || !data) {
            setError('No QR code found for this patient. They may have already activated their account.');
            setToken(null);
        } else {
            setToken(data.token);
            setInviteStatus(data.status);
            setExpiresAt(data.expires_at);
        }

        setIsLoading(false);
    };

    const isExpired = expiresAt ? new Date(expiresAt) < new Date() : false;

    return (
        <Modal
            isOpen={isOpen}
            onClose={onClose}
            title={`QR Code for ${patientName}`}
            size="md"
        >
            <div className="text-center py-4">
                {isLoading ? (
                    <div className="py-12">
                        <RefreshCw className="w-8 h-8 text-gray-400 animate-spin mx-auto" />
                        <p className="text-gray-500 mt-4">Loading QR code...</p>
                    </div>
                ) : error ? (
                    <div className="py-8">
                        <div className="w-16 h-16 bg-amber-100 rounded-full flex items-center justify-center mx-auto mb-4">
                            <AlertCircle size={32} className="text-amber-600" />
                        </div>
                        <p className="text-gray-600">{error}</p>
                    </div>
                ) : token ? (
                    <>
                        {inviteStatus === 'redeemed' && (
                            <div className="bg-blue-50 border border-blue-200 rounded-xl p-3 mb-4">
                                <p className="text-blue-700 text-sm font-medium flex items-center gap-2 justify-center">
                                    <CheckCircle size={16} />
                                    Active Account • Scan to Log In
                                </p>
                            </div>
                        )}

                        {isExpired && inviteStatus !== 'redeemed' && (
                            <div className="bg-amber-50 border border-amber-200 rounded-xl p-3 mb-4">
                                <p className="text-amber-700 text-sm font-medium">
                                    ⚠ This QR code has expired
                                </p>
                            </div>
                        )}

                        <p className="text-gray-500 mb-6">
                            {inviteStatus === 'redeemed'
                                ? "Scan this QR code to log in to the patient app"
                                : "Share this QR code with the patient to activate their account"}
                        </p>

                        {/* QR Code Display */}
                        <div className="bg-white p-6 rounded-2xl border border-gray-200 inline-block mb-6">
                            <div className="w-48 h-48 bg-white rounded-xl flex items-center justify-center p-2">
                                <QRCodeSVG
                                    value={token}
                                    size={176}
                                    level="M"
                                    includeMargin={false}
                                />
                            </div>
                        </div>

                        {expiresAt && inviteStatus === 'pending' && !isExpired && (
                            <p className="text-sm text-gray-400 mb-4">
                                Expires: {new Date(expiresAt).toLocaleDateString()}
                            </p>
                        )}
                    </>
                ) : null}

                <Button onClick={onClose} fullWidth>
                    Close
                </Button>
            </div>
        </Modal>
    );
}
