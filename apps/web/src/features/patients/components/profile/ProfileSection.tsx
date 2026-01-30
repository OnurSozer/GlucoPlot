import { ReactNode } from 'react';
import { LucideIcon } from 'lucide-react';
import { Card, CardHeader, CardContent } from '../../../../components/common/Card';

interface ProfileSectionProps {
    title: string;
    icon: LucideIcon;
    children: ReactNode;
    className?: string;
    action?: ReactNode;
}

export function ProfileSection({ title, icon: Icon, children, className = '', action }: ProfileSectionProps) {
    return (
        <Card className={`h-full border-0 shadow-sm bg-white/50 backdrop-blur-sm ${className}`}>
            <CardHeader className="pb-3 border-b border-gray-100/50">
                <div className="flex items-center justify-between">
                    <div className="flex items-center gap-3">
                        <div className="p-2.5 bg-primary/10 rounded-xl text-primary ring-1 ring-primary/20">
                            <Icon size={20} />
                        </div>
                        <h3 className="font-semibold text-gray-900">{title}</h3>
                    </div>
                    {action && <div>{action}</div>}
                </div>
            </CardHeader>
            <CardContent className="pt-4">
                {children}
            </CardContent>
        </Card>
    );
}
