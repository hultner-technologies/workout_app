import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import Link from 'next/link'
import { Metadata } from 'next'
import { WorkoutList } from '@/components/workouts/workout-list'
import { AuthNavWrapper } from '@/components/nav/auth-nav-wrapper'

export const metadata: Metadata = {
  title: "Workout History | GymR8",
  description: "View and manage your complete workout history. Track all your training sessions, exercises, and progress over time.",
}

export default async function WorkoutsPage() {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  // Fetch performed sessions with related data
  const { data: sessions, error } = await supabase
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
    .eq('app_user_id', user.id)
    .order('started_at', { ascending: false })

  if (error) {
    console.error('Error fetching sessions:', error)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <AuthNavWrapper />
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex justify-between items-center mb-8">
              <h1 className="text-3xl font-bold text-gray-900">
                Workout History
              </h1>
              <Link
                href="/stats"
                className="text-sm font-medium text-blue-600 hover:text-blue-500"
                data-testid="view-stats-link"
              >
                View Stats →
              </Link>
            </div>
            <WorkoutList sessions={sessions || []} />
          </div>
        </div>
      </div>
    </div>
  )
}
