import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Link from 'next/link'
import { Metadata } from 'next'
import { StatsDashboard } from '@/components/stats/stats-dashboard'

export const metadata: Metadata = {
  title: "Workout Statistics | GymR8",
  description: "Analyze your workout performance with comprehensive charts and statistics. Track volume, frequency, and personal records over time.",
}

export default async function StatsPage() {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  // Fetch all performed sessions with exercises for stats calculation
  const { data: sessions, error } = await supabase
    .from('performed_session')
    .select(`
      performed_session_id,
      started_at,
      completed_at,
      session_schedule:session_schedule_id (
        name
      )
    `)
    .eq('app_user_id', user.id)
    .order('started_at', { ascending: true })

  // Fetch all performed exercises for detailed stats
  const { data: exercises, error: exercisesError } = await supabase
    .from('performed_exercise')
    .select(`
      performed_exercise_id,
      name,
      reps,
      sets,
      weight,
      started_at,
      performed_session:performed_session_id (
        performed_session_id,
        started_at,
        app_user_id
      ),
      exercise:exercise_id (
        base_exercise:base_exercise_id (
          name
        )
      )
    `)
    .order('started_at', { ascending: true })

  if (error || exercisesError) {
    console.error('Error fetching stats data:', error || exercisesError)
  }

  // Filter exercises to only include those from this user's sessions
  const userExercises = exercises?.filter((ex) => {
    const session = Array.isArray(ex.performed_session)
      ? ex.performed_session[0]
      : ex.performed_session
    return session?.app_user_id === user.id
  }) || []

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="mb-6">
          <Link
            href="/workouts"
            className="text-sm font-medium text-blue-600 hover:text-blue-500"
            data-testid="back-to-workouts-link"
          >
            ← Back to Workouts
          </Link>
        </div>
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h1 className="text-3xl font-bold text-gray-900 mb-8">
              Workout Statistics
            </h1>
            <StatsDashboard
              sessions={sessions || []}
              exercises={userExercises}
            />
          </div>
        </div>
      </div>
    </div>
  )
}
