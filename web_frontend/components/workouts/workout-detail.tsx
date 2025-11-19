'use client'

import { format, formatDuration, intervalToDuration } from 'date-fns'

interface Exercise {
  performed_exercise_id: string
  name?: string
  reps: number[]
  sets: number
  weight?: number
  rest?: string[]
  started_at: string
  completed_at?: string
  note?: string
  exercise?: {
    exercise_id: string
    base_exercise?: {
      base_exercise_id: string
      name: string
      description?: string
    } | {
      base_exercise_id: string
      name: string
      description?: string
    }[]
  } | {
    exercise_id: string
    base_exercise?: {
      base_exercise_id: string
      name: string
      description?: string
    } | {
      base_exercise_id: string
      name: string
      description?: string
    }[]
  }[]
}

interface Session {
  performed_session_id: string
  started_at: string
  completed_at: string
  note?: string
  session_schedule?: {
    session_schedule_id: string
    name: string
  } | {
    session_schedule_id: string
    name: string
  }[]
}

interface WorkoutDetailProps {
  session: Session
  exercises: Exercise[]
}

export function WorkoutDetail({ session, exercises }: WorkoutDetailProps) {
  const duration = intervalToDuration({
    start: new Date(session.started_at),
    end: new Date(session.completed_at),
  })

  const formatWeight = (grams?: number) => {
    if (!grams) return 'Bodyweight'
    return `${(grams / 1000).toFixed(1)} kg`
  }

  const getScheduleName = () => {
    if (Array.isArray(session.session_schedule)) {
      return session.session_schedule[0]?.name || 'Workout Session'
    }
    return session.session_schedule?.name || 'Workout Session'
  }

  const getExerciseName = (exercise: Exercise) => {
    const ex = Array.isArray(exercise.exercise) ? exercise.exercise[0] : exercise.exercise
    if (!ex) return exercise.name || 'Unknown Exercise'

    const baseEx = Array.isArray(ex.base_exercise) ? ex.base_exercise[0] : ex.base_exercise
    return baseEx?.name || exercise.name || 'Unknown Exercise'
  }

  const getExerciseDescription = (exercise: Exercise) => {
    const ex = Array.isArray(exercise.exercise) ? exercise.exercise[0] : exercise.exercise
    if (!ex) return undefined

    const baseEx = Array.isArray(ex.base_exercise) ? ex.base_exercise[0] : ex.base_exercise
    return baseEx?.description
  }

  return (
    <div className="space-y-8">
      {/* Session Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">
          {getScheduleName()}
        </h1>
        <div className="mt-4 grid grid-cols-1 sm:grid-cols-3 gap-4">
          <div>
            <dt className="text-sm font-medium text-gray-500">Date</dt>
            <dd className="mt-1 text-sm text-gray-900">
              {format(new Date(session.started_at), 'PPP')}
            </dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Started</dt>
            <dd className="mt-1 text-sm text-gray-900">
              {format(new Date(session.started_at), 'p')}
            </dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Duration</dt>
            <dd className="mt-1 text-sm text-gray-900">
              {formatDuration(duration, { format: ['hours', 'minutes'] }) || 'Less than a minute'}
            </dd>
          </div>
        </div>
        {session.note && (
          <div className="mt-4 p-4 bg-blue-50 rounded-md">
            <p className="text-sm text-blue-900">{session.note}</p>
          </div>
        )}
      </div>

      {/* Exercises */}
      <div>
        <h2 className="text-2xl font-bold text-gray-900 mb-4">Exercises</h2>
        {exercises.length === 0 ? (
          <p className="text-gray-500">No exercises recorded for this session.</p>
        ) : (
          <div className="space-y-6">
            {exercises.map((exercise, index) => (
              <div
                key={exercise.performed_exercise_id}
                className="border border-gray-200 rounded-lg p-4"
              >
                <div className="flex justify-between items-start mb-4">
                  <div>
                    <h3 className="text-lg font-semibold text-gray-900">
                      {index + 1}. {getExerciseName(exercise)}
                    </h3>
                    {getExerciseDescription(exercise) && (
                      <p className="text-sm text-gray-600 mt-1">
                        {getExerciseDescription(exercise)}
                      </p>
                    )}
                  </div>
                  <div className="text-right">
                    <div className="text-sm font-medium text-gray-900">
                      {formatWeight(exercise.weight)}
                    </div>
                    <div className="text-xs text-gray-500">
                      {exercise.sets} sets
                    </div>
                  </div>
                </div>

                {/* Sets Table */}
                <div className="overflow-x-auto">
                  <table className="min-w-full divide-y divide-gray-200">
                    <thead>
                      <tr>
                        <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                          Set
                        </th>
                        <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                          Reps
                        </th>
                        <th className="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">
                          Weight
                        </th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-gray-200">
                      {exercise.reps.map((reps, setIndex) => (
                        <tr key={setIndex}>
                          <td className="px-3 py-2 text-sm text-gray-900">
                            {setIndex + 1}
                          </td>
                          <td className="px-3 py-2 text-sm text-gray-900">
                            {reps}
                          </td>
                          <td className="px-3 py-2 text-sm text-gray-900">
                            {formatWeight(exercise.weight)}
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>

                {exercise.note && (
                  <div className="mt-3 p-3 bg-gray-50 rounded-md">
                    <p className="text-sm text-gray-700">{exercise.note}</p>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}
