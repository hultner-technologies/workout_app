'use client'

import { useMemo } from 'react'
import { format, eachWeekOfInterval, eachMonthOfInterval, sub } from 'date-fns'
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  Legend,
} from 'recharts'
import { TIME_RANGES } from './time-range-selector'

interface Exercise {
  performed_exercise_id: string
  reps: number[]
  weight?: number
  started_at: string
  performed_session?: {
    started_at: string
  } | {
    started_at: string
  }[]
}

interface VolumeProgressChartProps {
  exercises: Exercise[]
  timeRange: string
}

export function VolumeProgressChart({ exercises, timeRange }: VolumeProgressChartProps) {
  const chartData = useMemo(() => {
    if (exercises.length === 0) return []

    const now = new Date()

    // Determine if we should use monthly or weekly buckets
    const useMonthlyBuckets =
      timeRange === TIME_RANGES.ALL ||
      timeRange === TIME_RANGES.FIVE_YEARS ||
      timeRange === TIME_RANGES.THREE_YEARS

    if (useMonthlyBuckets) {
      // Use monthly buckets for longer time ranges
      const startDate = exercises.length > 0
        ? new Date(Math.min(...exercises.map((e) => {
            const date = Array.isArray(e.performed_session)
              ? e.performed_session[0]?.started_at
              : e.performed_session?.started_at
            return date ? new Date(date).getTime() : Date.now()
          })))
        : sub(now, { years: 1 })

      const months = eachMonthOfInterval({
        start: startDate,
        end: now,
      })

      const monthlyVolume = months.map((monthStart) => {
        const monthEnd = new Date(monthStart)
        monthEnd.setMonth(monthEnd.getMonth() + 1)

        const volume = exercises
          .filter((exercise) => {
            const exerciseDate = Array.isArray(exercise.performed_session)
              ? exercise.performed_session[0]?.started_at
              : exercise.performed_session?.started_at

            if (!exerciseDate) return false

            const date = new Date(exerciseDate)
            return date >= monthStart && date < monthEnd
          })
          .reduce((total, exercise) => {
            const weight = exercise.weight || 0
            const repsSum = exercise.reps.reduce((sum, reps) => sum + reps, 0)
            return total + (weight * repsSum) / 1000 // Convert grams to kg
          }, 0)

        return {
          period: format(monthStart, 'MMM yyyy'),
          volume: Math.round(volume),
        }
      })

      return monthlyVolume
    } else {
      // Use weekly buckets for shorter time ranges
      const startDate = exercises.length > 0
        ? new Date(Math.min(...exercises.map((e) => {
            const date = Array.isArray(e.performed_session)
              ? e.performed_session[0]?.started_at
              : e.performed_session?.started_at
            return date ? new Date(date).getTime() : Date.now()
          })))
        : sub(now, { months: 3 })

      const weeks = eachWeekOfInterval({
        start: startDate,
        end: now,
      })

      const weeklyVolume = weeks.map((weekStart) => {
        const weekEnd = new Date(weekStart)
        weekEnd.setDate(weekEnd.getDate() + 7)

        const volume = exercises
          .filter((exercise) => {
            const exerciseDate = Array.isArray(exercise.performed_session)
              ? exercise.performed_session[0]?.started_at
              : exercise.performed_session?.started_at

            if (!exerciseDate) return false

            const date = new Date(exerciseDate)
            return date >= weekStart && date < weekEnd
          })
          .reduce((total, exercise) => {
            const weight = exercise.weight || 0
            const repsSum = exercise.reps.reduce((sum, reps) => sum + reps, 0)
            return total + (weight * repsSum) / 1000 // Convert grams to kg
          }, 0)

        return {
          period: format(weekStart, 'MMM d'),
          volume: Math.round(volume),
        }
      })

      return weeklyVolume
    }
  }, [exercises, timeRange])

  const bucketLabel = timeRange === TIME_RANGES.ALL ||
    timeRange === TIME_RANGES.FIVE_YEARS ||
    timeRange === TIME_RANGES.THREE_YEARS
    ? 'Month'
    : 'Week'

  return (
    <div>
      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">
        Volume Progress
      </h3>
      <div className="h-80">
        <ResponsiveContainer width="100%" height="100%">
          <LineChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis
              dataKey="period"
              angle={-45}
              textAnchor="end"
              height={80}
              className="text-xs"
            />
            <YAxis label={{ value: 'Volume (kg)', angle: -90, position: 'insideLeft' }} />
            <Tooltip
              contentStyle={{
                backgroundColor: 'rgba(255, 255, 255, 0.9)',
                border: '1px solid #ccc',
                borderRadius: '4px',
              }}
              labelFormatter={(label) => `${bucketLabel}: ${label}`}
              formatter={(value: number) => [`${value} kg`, 'Volume']}
            />
            <Legend />
            <Line
              type="monotone"
              dataKey="volume"
              stroke="#9333ea"
              strokeWidth={2}
              dot={{ fill: '#9333ea' }}
              name="Total Volume"
            />
          </LineChart>
        </ResponsiveContainer>
      </div>
    </div>
  )
}
