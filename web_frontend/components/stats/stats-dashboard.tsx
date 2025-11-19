'use client'

import { useMemo } from 'react'
import { WorkoutFrequencyChart } from './workout-frequency-chart'
import { PersonalRecords } from './personal-records'

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
  sessions: Session[]
  exercises: Exercise[]
}

export function StatsDashboard({ sessions, exercises }: StatsDashboardProps) {
  // Calculate total workouts
  const totalWorkouts = sessions.length

  // Calculate total exercises performed
  const totalExercises = exercises.length

  // Calculate total volume (sum of weight * reps for all sets)
  const totalVolume = useMemo(() => {
    return exercises.reduce((total, exercise) => {
      const weight = exercise.weight || 0
      const repsSum = exercise.reps.reduce((sum, reps) => sum + reps, 0)
      return total + (weight * repsSum) / 1000 // Convert grams to kg
    }, 0)
  }, [exercises])

  return (
    <div className="space-y-8">
      {/* Overview Stats */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <div className="bg-blue-50 p-6 rounded-lg">
          <dt className="text-sm font-medium text-blue-600 uppercase">
            Total Workouts
          </dt>
          <dd className="mt-2 text-3xl font-bold text-blue-900">
            {totalWorkouts}
          </dd>
        </div>
        <div className="bg-green-50 p-6 rounded-lg">
          <dt className="text-sm font-medium text-green-600 uppercase">
            Total Exercises
          </dt>
          <dd className="mt-2 text-3xl font-bold text-green-900">
            {totalExercises}
          </dd>
        </div>
        <div className="bg-purple-50 p-6 rounded-lg">
          <dt className="text-sm font-medium text-purple-600 uppercase">
            Total Volume
          </dt>
          <dd className="mt-2 text-3xl font-bold text-purple-900">
            {totalVolume.toFixed(0)} kg
          </dd>
        </div>
      </div>

      {/* Workout Frequency Chart */}
      <div className="border border-gray-200 rounded-lg p-6">
        <WorkoutFrequencyChart sessions={sessions} />
      </div>

      {/* Personal Records */}
      <div className="border border-gray-200 rounded-lg p-6">
        <PersonalRecords exercises={exercises} />
      </div>
    </div>
  )
}
