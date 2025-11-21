import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import Link from 'next/link'
import { WorkoutDetail } from '@/components/workouts/workout-detail'
import { AuthNavWrapper } from '@/components/nav/auth-nav-wrapper'

export default async function WorkoutDetailPage({
  params,
}: {
  params: { id: string }
}) {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  // Fetch performed session
  const { data: session, error: sessionError } = await supabase
    .from('performed_session')
    .select(`
      performed_session_id,
      started_at,
      completed_at,
      note,
      session_schedule:session_schedule_id (
        session_schedule_id,
        name
      )
    `)
    .eq('performed_session_id', params.id)
    .eq('app_user_id', user.id)
    .single()

  if (sessionError || !session) {
    notFound()
  }

  // Fetch performed exercises for this session
  const { data: exercises, error: exercisesError } = await supabase
    .from('performed_exercise')
    .select(`
      performed_exercise_id,
      name,
      reps,
      sets,
      weight,
      rest,
      started_at,
      completed_at,
      note,
      exercise:exercise_id (
        exercise_id,
        base_exercise:base_exercise_id (
          base_exercise_id,
          name,
          description
        )
      )
    `)
    .eq('performed_session_id', params.id)
    .order('started_at', { ascending: true })

  if (exercisesError) {
    console.error('Error fetching exercises:', exercisesError)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <AuthNavWrapper />
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="mb-6">
          <Link
            href="/workouts"
            className="text-sm font-medium text-blue-600 hover:text-blue-500"
          >
            ← Back to Workouts
          </Link>
        </div>
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <WorkoutDetail session={session} exercises={exercises || []} />
          </div>
        </div>
      </div>
    </div>
  )
}
