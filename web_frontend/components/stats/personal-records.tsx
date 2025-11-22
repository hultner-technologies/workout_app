'use client'

import { useMemo } from 'react'

/**
 * Exercise data structure from performed_exercise table
 */
interface Exercise {
  performed_exercise_id: string
  name?: string
  /** Array of reps performed for each set */
  reps: number[]
  sets: number
  /** Weight used in grams (stored in database) */
  weight?: number
  started_at: string
  /** Foreign key reference to exercise and base_exercise */
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

/**
 * Props for PersonalRecords component
 */
interface PersonalRecordsProps {
  /** Array of exercises to find PRs from */
  exercises: Exercise[]
}

/**
 * Personal record data structure
 */
interface PR {
  /** Name of the exercise */
  exerciseName: string
  /** Maximum weight lifted in kg */
  maxWeight: number
  /** Number of reps performed at max weight */
  reps: number
  /** Date the PR was achieved (ISO format) */
  date: string
}

/**
 * PersonalRecords - Table displaying personal records for each exercise
 *
 * Analyzes all exercises and finds the maximum weight (1-rep max) achieved
 * for each unique exercise. Groups exercises by name and displays the top
 * 10 PRs sorted by weight in descending order.
 *
 * Weight conversion: Database stores weight in grams, table displays in kg.
 *
 * Uses useMemo for performance optimization to avoid recalculating PRs
 * on every render.
 *
 * @param {PersonalRecordsProps} props - Component props
 * @returns {JSX.Element} Table of personal records with exercise names, weights, reps, and dates
 *
 * @example
 * ```tsx
 * <PersonalRecords exercises={userExercises} />
 * ```
 */
export function PersonalRecords({ exercises }: PersonalRecordsProps) {
  const personalRecords = useMemo(() => {
    // Helper function to get exercise name
    const getExerciseName = (exercise: Exercise): string => {
      const ex = Array.isArray(exercise.exercise) ? exercise.exercise[0] : exercise.exercise
      if (!ex) return exercise.name || 'Unknown Exercise'

      const baseEx = Array.isArray(ex.base_exercise) ? ex.base_exercise[0] : ex.base_exercise
      return baseEx?.name || exercise.name || 'Unknown Exercise'
    }

    // Group exercises by name
    const exercisesByName = exercises.reduce((acc, exercise) => {
      const name = getExerciseName(exercise)

      if (!acc[name]) {
        acc[name] = []
      }
      acc[name].push(exercise)
      return acc
    }, {} as Record<string, Exercise[]>)

    // Find max weight for each exercise
    const prs: PR[] = Object.entries(exercisesByName).map(([name, exs]) => {
      let maxWeight = 0
      let maxReps = 0
      let maxDate = ''

      exs.forEach((exercise) => {
        const weight = exercise.weight || 0
        if (weight > maxWeight) {
          maxWeight = weight
          maxReps = Math.max(...exercise.reps)
          maxDate = exercise.started_at
        }
      })

      return {
        exerciseName: name,
        maxWeight,
        reps: maxReps,
        date: maxDate,
      }
    })

    // Sort by weight descending
    return prs.sort((a, b) => b.maxWeight - a.maxWeight).slice(0, 10)
  }, [exercises])

  const formatWeight = (grams: number) => {
    if (grams === 0) return 'Bodyweight'
    return `${(grams / 1000).toFixed(1)} kg`
  }

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
        Personal Records (Top 10)
      </h3>
      <div className="overflow-x-auto">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Exercise
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Max Weight
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Reps
              </th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                Date
              </th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {personalRecords.map((pr, index) => (
              <tr key={index}>
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                  {pr.exerciseName}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {formatWeight(pr.maxWeight)}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {pr.reps}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {new Date(pr.date).toLocaleDateString()}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}
