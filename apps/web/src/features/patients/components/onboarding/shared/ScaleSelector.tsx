/**
 * Scale Selector Component
 * A 1-10 range slider with optional labels
 */

interface ScaleSelectorProps {
  value?: number;
  onChange: (value: number) => void;
  min?: number;
  max?: number;
  label?: string;
  leftLabel?: string;
  rightLabel?: string;
  disabled?: boolean;
}

export function ScaleSelector({
  value,
  onChange,
  min = 1,
  max = 10,
  label,
  leftLabel,
  rightLabel,
  disabled = false,
}: ScaleSelectorProps) {
  const currentValue = value ?? min;
  const percentage = ((currentValue - min) / (max - min)) * 100;
  // Offset the bubble so it stays centered on the thumb (10px = half thumb width)
  const thumbOffset = 10 - (percentage / 100) * 20;

  return (
    <div className="space-y-2">
      {label && (
        <label className="block text-sm font-medium text-gray-700">
          {label}
        </label>
      )}

      <div className="flex items-center gap-3">
        {leftLabel && (
          <span className="text-xs text-gray-500 w-20 text-right flex-shrink-0">
            {leftLabel}
          </span>
        )}

        <div className="flex-1 relative">
          <input
            type="range"
            min={min}
            max={max}
            step={1}
            value={currentValue}
            onChange={(e) => !disabled && onChange(Number(e.target.value))}
            disabled={disabled}
            className="scale-slider w-full"
            style={{ '--slider-percent': `${percentage}%` } as React.CSSProperties}
          />
          {value != null && (
            <div
              className="absolute top-5 pointer-events-none"
              style={{ left: `calc(${percentage}% + ${thumbOffset}px)`, transform: 'translateX(-50%)' }}
            >
              <span className="text-xs font-semibold text-primary">{value}</span>
            </div>
          )}
        </div>

        {rightLabel && (
          <span className="text-xs text-gray-500 w-20 flex-shrink-0">
            {rightLabel}
          </span>
        )}
      </div>

      <style>{`
        .scale-slider {
          -webkit-appearance: none;
          appearance: none;
          height: 6px;
          border-radius: 3px;
          background: linear-gradient(
            to right,
            #E8A87C 0%,
            #E8A87C var(--slider-percent, 0%),
            #e5e7eb var(--slider-percent, 0%),
            #e5e7eb 100%
          );
          outline: none;
          cursor: pointer;
        }
        .scale-slider:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }
        .scale-slider::-webkit-slider-thumb {
          -webkit-appearance: none;
          appearance: none;
          width: 20px;
          height: 20px;
          border-radius: 50%;
          background: #E8A87C;
          border: 2px solid white;
          box-shadow: 0 1px 3px rgba(0,0,0,0.2);
          cursor: pointer;
        }
        .scale-slider::-moz-range-thumb {
          width: 20px;
          height: 20px;
          border-radius: 50%;
          background: #E8A87C;
          border: 2px solid white;
          box-shadow: 0 1px 3px rgba(0,0,0,0.2);
          cursor: pointer;
        }
        .scale-slider:focus::-webkit-slider-thumb {
          box-shadow: 0 0 0 3px rgba(232, 168, 124, 0.3);
        }
      `}</style>
    </div>
  );
}
