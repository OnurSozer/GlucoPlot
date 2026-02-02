/**
 * GlucoPlot brand icon component
 * A blood drop with a glucose trend line
 */

interface GlucoPlotIconProps {
    size?: number;
    className?: string;
}

export function GlucoPlotIcon({ size = 24, className = '' }: GlucoPlotIconProps) {
    return (
        <svg
            xmlns="http://www.w3.org/2000/svg"
            viewBox="0 0 64 64"
            width={size}
            height={size}
            className={className}
            fill="none"
        >
            {/* Blood drop shape */}
            <path
                d="M32 8 C32 8 16 26 16 38 C16 46.837 23.163 54 32 54 C40.837 54 48 46.837 48 38 C48 26 32 8 32 8Z"
                fill="currentColor"
                fillOpacity="0.15"
                stroke="currentColor"
                strokeWidth="2"
            />

            {/* Glucose trend line inside drop */}
            <path
                d="M22 42 L28 36 L32 40 L38 30 L44 34"
                stroke="currentColor"
                strokeWidth="3"
                strokeLinecap="round"
                strokeLinejoin="round"
                fill="none"
            />

            {/* Dot at end of trend */}
            <circle cx="44" cy="34" r="2.5" fill="currentColor" />
        </svg>
    );
}
