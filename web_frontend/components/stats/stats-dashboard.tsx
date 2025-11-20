'use client'

import { useMemo, useState } from 'react'
import { startOfYear, subYears } from 'date-fns'
import { WorkoutFrequencyChart } from './workout-frequency-chart'
import { VolumeProgressChart } from './volume-progress-chart'
import { PersonalRecords } from './personal-records'
import { TimeRangeSelector, TIME_RANGES } from './time-range-selector'

interface Session {
  performed_session_id: string
  started_at: string
  completed_at: string
  session_schedule?: {
    name: string
  } | {
    name: string
  }[]
}

interface Exercise {
  performed_exercise_id: string
  name?: string
  reps: number[]
  sets: number
  weight?: number
  started_at: string
  performed_session?: {
    performed_session_id: string
    started_at: string
    app_user_id: string
  } | {
    performed_session_id: string
    started_at: string
    app_user_id: string
  }[]
  exercise?: {
    base_exercise?: {
      name: string
    } | {
      name: string
    }[]
  } | {
    base_exercise?: {
      name: string
    } | {
      name: string
    }[]
  }[]
}

interface StatsDashboardProps {
  /** Array of workout sessions for the user */
  sessions: Session[]
  /** Array of performed exercises for the user */
  exercises: Exercise[]
}

/**
 * StatsDashboard - Main container for workout statistics
 *
 * Displays comprehensive workout statistics including:
 * - Overview metrics (total workouts, exercises, volume)
 * - Workout frequency chart over time
 * - Volume progress chart over time
 * - Personal records table
 *
 * Features time-range filtering (YTD, 1Y, 3Y, 5Y, All Time) that
 * filters all data client-side for responsive UX.
 *
 * @param {StatsDashboardProps} props - Component props
 * @returns {JSX.Element} Complete stats dashboard with charts
 *
 * @example
 * ```tsx
 * <StatsDashboard
 *   sessions={userSessions}
 *   exercises={userExercises}
 * />
 * ```
 */
export function StatsDashboard({ sessions, exercises }: StatsDashboardProps) {
  const [timeRange, setTimeRange] = useState<string>(TIME_RANGES.ONE_YEAR)

  /**
   * Calculate start date based on selected time range
   * @param {string} range - Time range constant
   * @returns {Date | null} Start date for filtering, or null for "All Time"
   */
  const getStartDate = (range: string): Date | null => {
    const now = new Date()
    switch (range) {
      case TIME_RANGES.YTD:
        return startOfYear(now)
      case TIME_RANGES.ONE_YEAR:
        return subYears(now, 1)
      case TIME_RANGES.THREE_YEARS:
        return subYears(now, 3)
      case TIME_RANGES.FIVE_YEARS:
        return subYears(now, 5)
      case TIME_RANGES.ALL:
        return null // No filtering
      default:
        return subYears(now, 1)
    }
  }

  /**
   * Filter sessions and exercises based on selected time range
   * Uses useMemo for performance optimization to avoid recalculating
   * filtered data on every render.
   *
   * Handles Supabase's foreign key array pattern for performed_session.
   */
  const { filteredSessions, filteredExercises } = useMemo(() => {
    const startDate = getStartDate(timeRange)

    if (!startDate) {
      return { filteredSessions: sessions, filteredExercises: exercises }
    }

    const filteredSessions = sessions.filter(
      (session) => new Date(session.started_at) >= startDate
    )

    const filteredExercises = exercises.filter((exercise) => {
      const sessionDate = Array.isArray(exercise.performed_session)
        ? exercise.performed_session[0]?.started_at
        : exercise.performed_session?.started_at
      return sessionDate && new Date(sessionDate) >= startDate
    })

    return { filteredSessions, filteredExercises }
  }, [sessions, exercises, timeRange])

  // Calculate total workouts in selected time range
  const totalWorkouts = filteredSessions.length

  // Calculate total exercises performed in selected time range
  const totalExercises = filteredExercises.length

  /**
   * Calculate total volume (weight × reps) for all exercises in time range
   * Volume is measured in kilograms (converted from grams stored in database)
   * Uses useMemo to avoid expensive calculations on every render
   */
  const totalVolume = useMemo(() => {
    return filteredExercises.reduce((total, exercise) => {
      const weight = exercise.weight || 0
      const repsSum = exercise.reps.reduce((sum, reps) => sum + reps, 0)
      return total + (weight * repsSum) / 1000 // Convert grams to kg
    }, 0)
  }, [filteredExercises])

  return (
    <div className="space-y-8">
      {/* Time Range Selector */}
      <div className="flex justify-between items-center flex-wrap gap-4">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
          Your Stats
        </h2>
        <TimeRangeSelector value={timeRange} onChange={setTimeRange} />
      </div>

      {/* Overview Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-blue-50 p-6 rounded-lg dark:bg-blue-900/20">
          <dt className="text-sm font-medium text-blue-600 uppercase dark:text-blue-400">
            Total Workouts
          </dt>
          <dd className="mt-2 text-3xl font-bold text-blue-900 dark:text-blue-100">
            {totalWorkouts}
          </dd>
        </div>
        <div className="bg-green-50 p-6 rounded-lg dark:bg-green-900/20">
          <dt className="text-sm font-medium text-green-600 uppercase dark:text-green-400">
            Total Exercises
          </dt>
          <dd className="mt-2 text-3xl font-bold text-green-900 dark:text-green-100">
            {totalExercises}
          </dd>
        </div>
        <div className="bg-purple-50 p-6 rounded-lg dark:bg-purple-900/20">
          <dt className="text-sm font-medium text-purple-600 uppercase dark:text-purple-400">
            Total Volume
          </dt>
          <dd className="mt-2 text-3xl font-bold text-purple-900 dark:text-purple-100">
            {totalVolume.toFixed(0)} kg
          </dd>
        </div>
      </div>

      {/* Workout Frequency Chart */}
      <div className="border border-gray-200 rounded-lg p-6 dark:border-gray-700">
        <WorkoutFrequencyChart sessions={filteredSessions} timeRange={timeRange} />
      </div>

      {/* Volume Progress Chart */}
      <div className="border border-gray-200 rounded-lg p-6 dark:border-gray-700">
        <VolumeProgressChart exercises={filteredExercises} timeRange={timeRange} />
      </div>

      {/* Personal Records */}
      <div className="border border-gray-200 rounded-lg p-6 dark:border-gray-700">
        <PersonalRecords exercises={filteredExercises} />
      </div>
    </div>
  )
}
