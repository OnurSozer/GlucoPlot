/**
 * Scale Selector Component
 * A 1-10 scale selector with optional labels
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
  const numbers = Array.from({ length: max - min + 1 }, (_, i) => min + i);

  return (
    <div className="space-y-3">
      {label && (
        <label className="block text-sm font-medium text-gray-700">
          {label}
        </label>
      )}

      <div className="flex items-center gap-2">
        {leftLabel && (
          <span className="text-xs text-gray-500 w-24 text-right flex-shrink-0">
            {leftLabel}
          </span>
        )}

        <div className="flex items-center gap-1 flex-1 justify-center">
          {numbers.map((num) => (
            <button
              key={num}
              type="button"
              onClick={() => !disabled && onChange(num)}
              disabled={disabled}
              className={`
                w-8 h-8 rounded-full text-sm font-medium
                transition-all duration-200
                ${value === num
                  ? 'bg-primary text-white shadow-sm scale-110'
                  : 'bg-gray-100 text-gray-600 hover:bg-gray-200'
                }
                ${disabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer'}
              `}
            >
              {num}
            </button>
          ))}
        </div>

        {rightLabel && (
          <span className="text-xs text-gray-500 w-24 flex-shrink-0">
            {rightLabel}
          </span>
        )}
      </div>

      {/* Visual indicator bar */}
      <div className="relative h-1 bg-gray-200 rounded-full mx-24">
        {value && (
          <div
            className="absolute h-1 bg-primary rounded-full transition-all duration-200"
            style={{ width: `${((value - min) / (max - min)) * 100}%` }}
          />
        )}
      </div>
    </div>
  );
}
