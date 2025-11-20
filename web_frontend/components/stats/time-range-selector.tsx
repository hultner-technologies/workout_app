'use client'

/**
 * Time range constants for filtering statistics data
 * @constant
 */
export const TIME_RANGES = {
  ALL: 'all',
  FIVE_YEARS: '5y',
  THREE_YEARS: '3y',
  ONE_YEAR: '1y',
  YTD: 'ytd',
} as const

/**
 * Human-readable labels for each time range
 * @constant
 */
export const TIME_RANGE_LABELS: Record<string, string> = {
  [TIME_RANGES.ALL]: 'All Time',
  [TIME_RANGES.FIVE_YEARS]: '5 Years',
  [TIME_RANGES.THREE_YEARS]: '3 Years',
  [TIME_RANGES.ONE_YEAR]: '1 Year',
  [TIME_RANGES.YTD]: 'YTD',
}

interface TimeRangeSelectorProps {
  /** Currently selected time range */
  value: string
  /** Callback when time range changes */
  onChange: (value: string) => void
}

/**
 * TimeRangeSelector - Button group for selecting stats time range
 *
 * Allows users to filter statistics by different time periods:
 * - YTD (Year to Date)
 * - 1 Year, 3 Years, 5 Years
 * - All Time
 *
 * @param {TimeRangeSelectorProps} props - Component props
 * @returns {JSX.Element} Rendered button group
 *
 * @example
 * ```tsx
 * <TimeRangeSelector
 *   value={timeRange}
 *   onChange={setTimeRange}
 * />
 * ```
 */
export function TimeRangeSelector({ value, onChange }: TimeRangeSelectorProps) {
  return (
    <div className="flex gap-2 flex-wrap" data-testid="time-range-selector">
      {Object.entries(TIME_RANGE_LABELS).map(([rangeValue, label]) => (
        <button
          key={rangeValue}
          onClick={() => onChange(rangeValue)}
          className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
            value === rangeValue
              ? 'bg-blue-600 text-white'
              : 'bg-gray-100 text-gray-700 hover:bg-gray-200 dark:bg-gray-700 dark:text-gray-300 dark:hover:bg-gray-600'
          }`}
          data-testid={`time-range-${rangeValue}`}
        >
          {label}
        </button>
      ))}
    </div>
  )
}
