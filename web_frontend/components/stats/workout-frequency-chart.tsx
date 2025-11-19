'use client'

import { useMemo } from 'react'
import { format, startOfWeek, eachWeekOfInterval, subMonths } from 'date-fns'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
} from 'recharts'

interface Session {
  performed_session_id: string
  started_at: string
  completed_at: string
}

interface WorkoutFrequencyChartProps {
  sessions: Session[]
}

export function WorkoutFrequencyChart({ sessions }: WorkoutFrequencyChartProps) {
  const chartData = useMemo(() => {
    if (sessions.length === 0) return []

    const now = new Date()
    const threeMonthsAgo = subMonths(now, 3)

    // Get all weeks in the last 3 months
    const weeks = eachWeekOfInterval({
      start: threeMonthsAgo,
      end: now,
    })

    // Count workouts per week
    const weekCounts = weeks.map((weekStart) => {
      const weekEnd = new Date(weekStart)
      weekEnd.setDate(weekEnd.getDate() + 6)

      const count = sessions.filter((session) => {
        const sessionDate = new Date(session.started_at)
        return sessionDate >= weekStart && sessionDate <= weekEnd
      }).length

      return {
        week: format(weekStart, 'MMM d'),
        workouts: count,
      }
    })

    return weekCounts
  }, [sessions])

  if (sessions.length === 0) {
    return (
      <div className="text-center py-8 text-gray-500">
        No workout data available
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <h3 className="text-lg font-semibold text-gray-900">
        Workout Frequency (Last 3 Months)
      </h3>
      <ResponsiveContainer width="100%" height={300}>
        <BarChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis
            dataKey="week"
            tick={{ fontSize: 12 }}
            interval="preserveStartEnd"
          />
          <YAxis allowDecimals={false} />
          <Tooltip />
          <Bar dataKey="workouts" fill="#3b82f6" />
        </BarChart>
      </ResponsiveContainer>
    </div>
  )
}
