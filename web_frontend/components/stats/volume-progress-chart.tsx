'use client'

import { useMemo } from 'react'
import { format, startOfWeek, eachWeekOfInterval, subMonths } from 'date-fns'
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
}

export function VolumeProgressChart({ exercises }: VolumeProgressChartProps) {
  const chartData = useMemo(() => {
    if (exercises.length === 0) return []

    const now = new Date()
    const threeMonthsAgo = subMonths(now, 3)

    // Get all weeks in the last 3 months
    const weeks = eachWeekOfInterval({
      start: threeMonthsAgo,
      end: now,
    })

    // Calculate volume per week
    const weeklyVolume = weeks.map((weekStart) => {
      const weekEnd = new Date(weekStart)
      weekEnd.setDate(weekEnd.getDate() + 6)

      const volume = exercises
        .filter((exercise) => {
          const session = Array.isArray(exercise.performed_session)
            ? exercise.performed_session[0]
            : exercise.performed_session

          const exerciseDate = session
            ? new Date(session.started_at)
            : new Date(exercise.started_at)

          return exerciseDate >= weekStart && exerciseDate <= weekEnd
        })
        .reduce((total, exercise) => {
          const weight = exercise.weight || 0
          const repsSum = exercise.reps.reduce((sum, reps) => sum + reps, 0)
          return total + (weight * repsSum) / 1000 // Convert grams to kg
        }, 0)

      return {
        week: format(weekStart, 'MMM d'),
        volume: Math.round(volume),
      }
    })

    return weeklyVolume
  }, [exercises])

  if (exercises.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        No exercise data available
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <h3 className="text-lg font-semibold text-gray-900">
        Volume Progress (Last 3 Months)
      </h3>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis
            dataKey="week"
            tick={{ fontSize: 12 }}
            interval="preserveStartEnd"
          />
          <YAxis label={{ value: 'Volume (kg)', angle: -90, position: 'insideLeft' }} />
          <Tooltip formatter={(value) => [`${value} kg`, 'Volume']} />
          <Legend />
          <Line
            type="monotone"
            dataKey="volume"
            stroke="#8b5cf6"
            strokeWidth={2}
            dot={{ fill: '#8b5cf6' }}
            name="Weekly Volume"
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
