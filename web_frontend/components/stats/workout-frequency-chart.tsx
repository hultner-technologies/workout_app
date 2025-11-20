'use client'

import { useMemo } from 'react'
import { format, eachWeekOfInterval, eachMonthOfInterval, sub } from 'date-fns'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts'
import { TIME_RANGES } from './time-range-selector'

/**
 * Session data structure from performed_session table
 */
interface Session {
  performed_session_id: string
  started_at: string
  completed_at: string
}

/**
 * Props for WorkoutFrequencyChart component
 */
interface WorkoutFrequencyChartProps {
  /** Array of workout sessions to analyze */
  sessions: Session[]
  /** Selected time range for filtering (from TIME_RANGES constants) */
  timeRange: string
}

/**
 * WorkoutFrequencyChart - Bar chart showing workout frequency over time
 *
 * Displays the number of workouts performed per time period (week or month).
 * Automatically switches between weekly and monthly buckets based on the
 * selected time range:
 * - Weekly buckets: 1Y, YTD time ranges
 * - Monthly buckets: 3Y, 5Y, All Time ranges
 *
 * Uses useMemo for performance optimization to avoid recalculating chart
 * data on every render.
 *
 * @param {WorkoutFrequencyChartProps} props - Component props
 * @returns {JSX.Element} Bar chart visualization of workout frequency
 *
 * @example
 * ```tsx
 * <WorkoutFrequencyChart
 *   sessions={userSessions}
 *   timeRange={TIME_RANGES.ONE_YEAR}
 * />
 * ```
 */
export function WorkoutFrequencyChart({ sessions, timeRange }: WorkoutFrequencyChartProps) {
  const chartData = useMemo(() => {
    if (sessions.length === 0) return []

    const now = new Date()

    // Determine if we should use monthly or weekly buckets
    const useMonthlyBuckets =
      timeRange === TIME_RANGES.ALL ||
      timeRange === TIME_RANGES.FIVE_YEARS ||
      timeRange === TIME_RANGES.THREE_YEARS

    if (useMonthlyBuckets) {
      // Use monthly buckets for longer time ranges
      const startDate = sessions.length > 0
        ? new Date(Math.min(...sessions.map((s) => new Date(s.started_at).getTime())))
        : sub(now, { years: 1 })

      const months = eachMonthOfInterval({
        start: startDate,
        end: now,
      })

      const monthCounts = months.map((monthStart) => {
        const monthEnd = new Date(monthStart)
        monthEnd.setMonth(monthEnd.getMonth() + 1)

        const count = sessions.filter((session) => {
          const sessionDate = new Date(session.started_at)
          return sessionDate >= monthStart && sessionDate < monthEnd
        }).length

        return {
          period: format(monthStart, 'MMM yyyy'),
          workouts: count,
        }
      })

      return monthCounts
    } else {
      // Use weekly buckets for shorter time ranges
      const startDate = sessions.length > 0
        ? new Date(Math.min(...sessions.map((s) => new Date(s.started_at).getTime())))
        : sub(now, { months: 3 })

      const weeks = eachWeekOfInterval({
        start: startDate,
        end: now,
      })

      const weekCounts = weeks.map((weekStart) => {
        const weekEnd = new Date(weekStart)
        weekEnd.setDate(weekEnd.getDate() + 7)

        const count = sessions.filter((session) => {
          const sessionDate = new Date(session.started_at)
          return sessionDate >= weekStart && sessionDate < weekEnd
        }).length

        return {
          period: format(weekStart, 'MMM d'),
          workouts: count,
        }
      })

      return weekCounts
    }
  }, [sessions, timeRange])

  const bucketLabel = timeRange === TIME_RANGES.ALL ||
    timeRange === TIME_RANGES.FIVE_YEARS ||
    timeRange === TIME_RANGES.THREE_YEARS
    ? 'Month'
    : 'Week'

  return (
    <div>
      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
        Workout Frequency
      </h3>
      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <BarChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis
              dataKey="period"
              angle={-45}
              textAnchor="end"
              height={80}
              className="text-xs"
            />
            <YAxis label={{ value: 'Workouts', angle: -90, position: 'insideLeft' }} />
            <Tooltip
              contentStyle={{
                backgroundColor: 'rgba(255, 255, 255, 0.9)',
                border: '1px solid #ccc',
                borderRadius: '4px',
              }}
              labelFormatter={(label) => `${bucketLabel}: ${label}`}
            />
            <Bar dataKey="workouts" fill="#3b82f6" name="Workouts" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}
