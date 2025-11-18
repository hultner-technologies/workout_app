# Web Frontend - Phase 2 & 3 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Extend the Next.js web authentication app with workout history viewing (Phase 2) and statistics/analytics dashboard (Phase 3).

**Architecture:** Server-side rendered pages using Supabase client to fetch workout data from `performed_session`, `performed_exercise`, `exercise`, and `base_exercise` tables. Data visualization using recharts library.

**Tech Stack:** Next.js 14 (App Router), TypeScript, Supabase SSR, shadcn/ui, Tailwind CSS, Recharts (for charts)

**Prerequisites:** Phase 1 (Core Authentication) must be complete with working login/signup/profile pages.

---

## Phase 2: Workout History

### Task 1: Install Chart Dependencies

**Files:**
- Modify: `web_frontend/package.json`

**Step 1: Install recharts and date utilities**

```bash
cd web_frontend
npm install recharts date-fns
```

Expected: Dependencies installed successfully

**Step 2: Verify installation**

Run: `npm run build`

Expected: Build succeeds

**Step 3: Commit**

```bash
git add package.json package-lock.json
git commit -m "chore: add recharts and date-fns for data visualization"
```

---

### Task 2: Create Workouts List Page

**Files:**
- Create: `web_frontend/app/workouts/page.tsx`
- Create: `web_frontend/app/workouts/actions.ts`
- Create: `web_frontend/components/workouts/workout-list.tsx`

**Step 1: Write workouts page (server component)**

Create file: `web_frontend/app/workouts/page.tsx`

```typescript
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { WorkoutList } from '@/components/workouts/workout-list'

export default async function WorkoutsPage({
  searchParams,
}: {
  searchParams: { filter?: string; sort?: string }
}) {
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
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <div className="flex justify-between items-center mb-8">
              <h1 className="text-3xl font-bold text-gray-900">
                Workout History
              </h1>
              <a
                href="/stats"
                className="text-sm font-medium text-blue-600 hover:text-blue-500"
              >
                View Stats →
              </a>
            </div>
            <WorkoutList sessions={sessions || []} />
          </div>
        </div>
      </div>
    </div>
  )
}
```

**Step 2: Write workout list component**

Create file: `web_frontend/components/workouts/workout-list.tsx`

```typescript
'use client'

import { useState } from 'react'
import { format } from 'date-fns'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

interface Session {
  performed_session_id: string
  started_at: string
  completed_at: string
  note?: string
  session_schedule?: {
    session_schedule_id: string
    name: string
  }
}

interface WorkoutListProps {
  sessions: Session[]
}

export function WorkoutList({ sessions }: WorkoutListProps) {
  const [filter, setFilter] = useState('')
  const [sortOrder, setSortOrder] = useState<'asc' | 'desc'>('desc')

  // Filter sessions by session name or note
  const filteredSessions = sessions.filter((session) => {
    if (!filter) return true
    const searchLower = filter.toLowerCase()
    const sessionName = session.session_schedule?.name?.toLowerCase() || ''
    const note = session.note?.toLowerCase() || ''
    return sessionName.includes(searchLower) || note.includes(searchLower)
  })

  // Sort sessions
  const sortedSessions = [...filteredSessions].sort((a, b) => {
    const dateA = new Date(a.started_at).getTime()
    const dateB = new Date(b.started_at).getTime()
    return sortOrder === 'desc' ? dateB - dateA : dateA - dateB
  })

  return (
    <div className="space-y-6">
      {/* Filters */}
      <div className="flex gap-4 items-center">
        <Input
          type="text"
          placeholder="Search workouts..."
          value={filter}
          onChange={(e) => setFilter(e.target.value)}
          className="max-w-sm"
        />
        <Button
          variant="outline"
          onClick={() => setSortOrder(sortOrder === 'desc' ? 'asc' : 'desc')}
        >
          Sort: {sortOrder === 'desc' ? 'Newest First' : 'Oldest First'}
        </Button>
      </div>

      {/* Session List */}
      {sortedSessions.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-gray-500">
            {filter ? 'No workouts found matching your search.' : 'No workouts recorded yet.'}
          </p>
        </div>
      ) : (
        <div className="space-y-4">
          {sortedSessions.map((session) => (
            <div
              key={session.performed_session_id}
              className="border border-gray-200 rounded-lg p-4 hover:border-blue-300 transition-colors"
            >
              <div className="flex justify-between items-start">
                <div className="flex-1">
                  <h3 className="text-lg font-semibold text-gray-900">
                    {session.session_schedule?.name || 'Unknown Workout'}
                  </h3>
                  <p className="text-sm text-gray-500 mt-1">
                    {format(new Date(session.started_at), 'PPP')} at{' '}
                    {format(new Date(session.started_at), 'p')}
                  </p>
                  {session.note && (
                    <p className="text-sm text-gray-600 mt-2">{session.note}</p>
                  )}
                </div>
                <a
                  href={`/workouts/${session.performed_session_id}`}
                  className="text-sm font-medium text-blue-600 hover:text-blue-500"
                >
                  View Details →
                </a>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  )
}
```

**Step 3: Test workouts page**

Run: `npm run dev`

Visit: http://localhost:3000/workouts

Expected: Page loads, shows empty state or workout list if data exists

Stop server

**Step 4: Commit**

```bash
git add app/workouts/ components/workouts/
git commit -m "feat: add workout history list page with filtering and sorting"
```

---

### Task 3: Create Workout Detail Page

**Files:**
- Create: `web_frontend/app/workouts/[id]/page.tsx`
- Create: `web_frontend/components/workouts/workout-detail.tsx`

**Step 1: Write workout detail page (server component)**

Create file: `web_frontend/app/workouts/[id]/page.tsx`

```typescript
import { createClient } from '@/lib/supabase/server'
import { redirect, notFound } from 'next/navigation'
import { WorkoutDetail } from '@/components/workouts/workout-detail'

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
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="mb-6">
          <a
            href="/workouts"
            className="text-sm font-medium text-blue-600 hover:text-blue-500"
          >
            ← Back to Workouts
          </a>
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
```

**Step 2: Write workout detail component**

Create file: `web_frontend/components/workouts/workout-detail.tsx`

```typescript
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
    }
  }
}

interface Session {
  performed_session_id: string
  started_at: string
  completed_at: string
  note?: string
  session_schedule?: {
    session_schedule_id: string
    name: string
  }
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

  return (
    <div className="space-y-8">
      {/* Session Header */}
      <div>
        <h1 className="text-3xl font-bold text-gray-900">
          {session.session_schedule?.name || 'Workout Session'}
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
                      {index + 1}.{' '}
                      {exercise.exercise?.base_exercise?.name ||
                        exercise.name ||
                        'Unknown Exercise'}
                    </h3>
                    {exercise.exercise?.base_exercise?.description && (
                      <p className="text-sm text-gray-600 mt-1">
                        {exercise.exercise.base_exercise.description}
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
```

**Step 3: Test workout detail page**

Run: `npm run dev`

Visit: http://localhost:3000/workouts (click on a workout if data exists)

Expected: Detail page loads with exercise breakdown

Stop server

**Step 4: Commit**

```bash
git add app/workouts/ components/workouts/
git commit -m "feat: add workout detail page with exercise breakdown"
```

---

## Phase 3: Stats & Analytics

### Task 4: Create Stats Dashboard Page Structure

**Files:**
- Create: `web_frontend/app/stats/page.tsx`
- Create: `web_frontend/components/stats/stats-dashboard.tsx`

**Step 1: Write stats page (server component)**

Create file: `web_frontend/app/stats/page.tsx`

```typescript
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { StatsDashboard } from '@/components/stats/stats-dashboard'

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
    .eq('performed_session.app_user_id', user.id)
    .order('started_at', { ascending: true })

  if (error || exercisesError) {
    console.error('Error fetching stats data:', error || exercisesError)
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="mb-6">
          <a
            href="/workouts"
            className="text-sm font-medium text-blue-600 hover:text-blue-500"
          >
            ← Back to Workouts
          </a>
        </div>
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h1 className="text-3xl font-bold text-gray-900 mb-8">
              Workout Statistics
            </h1>
            <StatsDashboard
              sessions={sessions || []}
              exercises={exercises || []}
            />
          </div>
        </div>
      </div>
    </div>
  )
}
```

**Step 2: Write stats dashboard component skeleton**

Create file: `web_frontend/components/stats/stats-dashboard.tsx`

```typescript
'use client'

import { useMemo } from 'react'

interface Session {
  performed_session_id: string
  started_at: string
  completed_at: string
  session_schedule?: {
    name: string
  }
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
  }
  exercise?: {
    base_exercise?: {
      name: string
    }
  }
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

      {/* Placeholder for charts - will add in next tasks */}
      <div className="border-2 border-dashed border-gray-300 rounded-lg p-8 text-center">
        <p className="text-gray-500">
          Charts will be added in the next tasks
        </p>
      </div>
    </div>
  )
}
```

**Step 3: Test stats page**

Run: `npm run dev`

Visit: http://localhost:3000/stats

Expected: Page loads with overview stats cards

Stop server

**Step 4: Commit**

```bash
git add app/stats/ components/stats/
git commit -m "feat: add stats dashboard page with overview metrics"
```

---

### Task 5: Add Workout Frequency Chart

**Files:**
- Modify: `web_frontend/components/stats/stats-dashboard.tsx`
- Create: `web_frontend/components/stats/workout-frequency-chart.tsx`

**Step 1: Create workout frequency chart component**

Create file: `web_frontend/components/stats/workout-frequency-chart.tsx`

```typescript
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
```

**Step 2: Update stats dashboard to include frequency chart**

Modify: `web_frontend/components/stats/stats-dashboard.tsx`

Replace the placeholder section with:

```typescript
import { WorkoutFrequencyChart } from './workout-frequency-chart'

// ... in the return statement, replace the placeholder div with:

      {/* Workout Frequency Chart */}
      <div className="border border-gray-200 rounded-lg p-6">
        <WorkoutFrequencyChart sessions={sessions} />
      </div>
```

**Step 3: Test frequency chart**

Run: `npm run dev`

Visit: http://localhost:3000/stats

Expected: Chart displays workout frequency over last 3 months

Stop server

**Step 4: Commit**

```bash
git add components/stats/
git commit -m "feat: add workout frequency chart to stats dashboard"
```

---

### Task 6: Add Personal Records (PR) Tracking

**Files:**
- Create: `web_frontend/components/stats/personal-records.tsx`
- Modify: `web_frontend/components/stats/stats-dashboard.tsx`

**Step 1: Create personal records component**

Create file: `web_frontend/components/stats/personal-records.tsx`

```typescript
'use client'

import { useMemo } from 'react'

interface Exercise {
  performed_exercise_id: string
  name?: string
  reps: number[]
  sets: number
  weight?: number
  started_at: string
  exercise?: {
    base_exercise?: {
      name: string
    }
  }
}

interface PersonalRecordsProps {
  exercises: Exercise[]
}

interface PR {
  exerciseName: string
  maxWeight: number
  reps: number
  date: string
}

export function PersonalRecords({ exercises }: PersonalRecordsProps) {
  const personalRecords = useMemo(() => {
    // Group exercises by name
    const exercisesByName = exercises.reduce((acc, exercise) => {
      const name =
        exercise.exercise?.base_exercise?.name ||
        exercise.name ||
        'Unknown Exercise'

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
```

**Step 2: Update stats dashboard to include PR tracking**

Modify: `web_frontend/components/stats/stats-dashboard.tsx`

Add import:
```typescript
import { PersonalRecords } from './personal-records'
```

Add after the frequency chart:
```typescript
      {/* Personal Records */}
      <div className="border border-gray-200 rounded-lg p-6">
        <PersonalRecords exercises={exercises} />
      </div>
```

**Step 3: Test PR tracking**

Run: `npm run dev`

Visit: http://localhost:3000/stats

Expected: Personal records table displays top 10 exercises by max weight

Stop server

**Step 4: Commit**

```bash
git add components/stats/
git commit -m "feat: add personal records tracking to stats dashboard"
```

---

### Task 7: Add Volume Progress Chart

**Files:**
- Create: `web_frontend/components/stats/volume-progress-chart.tsx`
- Modify: `web_frontend/components/stats/stats-dashboard.tsx`

**Step 1: Create volume progress chart component**

Create file: `web_frontend/components/stats/volume-progress-chart.tsx`

```typescript
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
  }
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
    const weekVolumes = weeks.map((weekStart) => {
      const weekEnd = new Date(weekStart)
      weekEnd.setDate(weekEnd.getDate() + 6)

      const weekExercises = exercises.filter((exercise) => {
        const exerciseDate = new Date(
          exercise.performed_session?.started_at || exercise.started_at
        )
        return exerciseDate >= weekStart && exerciseDate <= weekEnd
      })

      const totalVolume = weekExercises.reduce((total, exercise) => {
        const weight = exercise.weight || 0
        const repsSum = exercise.reps.reduce((sum, reps) => sum + reps, 0)
        return total + (weight * repsSum) / 1000 // Convert grams to kg
      }, 0)

      return {
        week: format(weekStart, 'MMM d'),
        volume: Math.round(totalVolume),
      }
    })

    return weekVolumes
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
          <Tooltip />
          <Legend />
          <Line
            type="monotone"
            dataKey="volume"
            stroke="#8b5cf6"
            strokeWidth={2}
            dot={{ r: 4 }}
            activeDot={{ r: 6 }}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
```

**Step 2: Update stats dashboard to include volume chart**

Modify: `web_frontend/components/stats/stats-dashboard.tsx`

Add import:
```typescript
import { VolumeProgressChart } from './volume-progress-chart'
```

Add after the frequency chart:
```typescript
      {/* Volume Progress Chart */}
      <div className="border border-gray-200 rounded-lg p-6">
        <VolumeProgressChart exercises={exercises} />
      </div>
```

**Step 3: Test volume progress chart**

Run: `npm run dev`

Visit: http://localhost:3000/stats

Expected: Line chart displays volume progression over last 3 months

Stop server

**Step 4: Commit**

```bash
git add components/stats/
git commit -m "feat: add volume progress chart to stats dashboard"
```

---

### Task 8: Add Navigation Links

**Files:**
- Modify: `web_frontend/app/profile/page.tsx`
- Modify: `web_frontend/components/profile/profile-info.tsx`

**Step 1: Update profile page to include navigation to workouts**

Modify: `web_frontend/components/profile/profile-info.tsx`

Add after the account information section, before logout button:

```typescript
      {/* Quick Links */}
      <div className="pt-5 border-t border-gray-200">
        <h3 className="text-lg font-medium text-gray-900 mb-4">
          Quick Links
        </h3>
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <a
            href="/workouts"
            className="flex items-center justify-center px-4 py-3 border border-blue-300 rounded-md shadow-sm text-sm font-medium text-blue-700 bg-blue-50 hover:bg-blue-100"
          >
            View Workout History
          </a>
          <a
            href="/stats"
            className="flex items-center justify-center px-4 py-3 border border-purple-300 rounded-md shadow-sm text-sm font-medium text-purple-700 bg-purple-50 hover:bg-purple-100"
          >
            View Statistics
          </a>
        </div>
      </div>
```

**Step 2: Test navigation**

Run: `npm run dev`

Visit: http://localhost:3000/profile

Test:
1. Click "View Workout History" → should navigate to /workouts
2. Click "View Statistics" → should navigate to /stats

Expected: All links work correctly

Stop server

**Step 3: Commit**

```bash
git add components/profile/
git commit -m "feat: add navigation links to workouts and stats from profile"
```

---

## Testing & Verification

### Task 9: Manual End-to-End Testing

**No files created - this is a testing task**

**Step 1: Start development server**

Run: `npm run dev`

**Step 2: Test workout history flow**

1. Visit http://localhost:3000/workouts
2. Verify: List displays (empty state or workouts if data exists)
3. Test: Search filter works
4. Test: Sort order toggle works
5. If workouts exist: Click "View Details" on a workout
6. Verify: Detail page shows exercises with sets/reps/weight

**Step 3: Test stats dashboard**

1. Visit http://localhost:3000/stats
2. Verify: Overview stats cards display correctly
3. Verify: Workout frequency chart renders
4. Verify: Volume progress chart renders
5. Verify: Personal records table displays top exercises

**Step 4: Test navigation between pages**

1. Start at /profile
2. Click "View Workout History" → verify /workouts loads
3. Click "View Stats" → verify /stats loads
4. Click "Back to Workouts" → verify /workouts loads
5. Navigate to /profile using browser back

**Step 5: Check for errors**

Check browser console and terminal for any errors

Expected: No errors

**Step 6: Stop server**

Stop development server with Ctrl+C

---

### Task 10: Update Documentation

**Files:**
- Modify: `web_frontend/README.md`

**Step 1: Add Phase 2 & 3 features to README**

Update the Features section in `web_frontend/README.md`:

```markdown
## Features

**Phase 1: Core Authentication**
- User signup with email verification
- User login with session management
- Password reset flow
- Protected routes (profile, workouts, stats)
- Server-side rendering with Supabase Auth

**Phase 2: Workout History**
- View all workout sessions
- Filter workouts by name or notes
- Sort by date (newest/oldest first)
- Detailed workout view with exercises, sets, reps, and weights
- Exercise breakdown with rest times

**Phase 3: Stats & Analytics**
- Workout frequency chart (last 3 months)
- Volume progress tracking over time
- Personal records (PR) for each exercise
- Total workouts, exercises, and volume metrics
- Interactive charts using Recharts
```

Add to Project Structure section:

```markdown
├── app/
│   ├── workouts/          # Workout history pages
│   │   ├── [id]/         # Individual workout detail
│   │   └── page.tsx      # Workout list
│   └── stats/             # Statistics dashboard
│       └── page.tsx
├── components/
│   ├── workouts/          # Workout components
│   │   ├── workout-list.tsx
│   │   └── workout-detail.tsx
│   └── stats/             # Stats components
│       ├── stats-dashboard.tsx
│       ├── workout-frequency-chart.tsx
│       ├── volume-progress-chart.tsx
│       └── personal-records.tsx
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README with Phase 2 & 3 features"
```

---

## Completion & Next Steps

### Task 11: Final Verification

**No files created - this is a verification task**

**Step 1: Run final build**

Run: `npm run build`

Expected: Build succeeds with no errors

**Step 2: Check git status**

Run: `git status`

Expected: Working directory clean

**Step 3: View commit log**

Run: `git log --oneline -15`

Expected: See all Phase 2 & 3 commits

**Step 4: Push branch**

Run: `git push`

Expected: Changes pushed to remote

**Step 5: Document completion**

Phase 2 & 3 Complete:

✅ Workout history list page with filtering and sorting
✅ Workout detail page with exercise breakdown
✅ Stats dashboard with overview metrics
✅ Workout frequency chart (3 months)
✅ Volume progress chart
✅ Personal records tracking
✅ Navigation links between all pages
✅ Documentation updated

**Next Steps:**

**Option 1: Create Pull Request**
- Open PR to merge Phase 2 & 3 work
- Add description of new features
- Request review

**Option 2: Deploy to Production**
- Deploy to Vercel
- Test with production Supabase data
- Verify all charts and stats work correctly

**Option 3: Future Enhancements**
- Add exercise-specific progress charts
- Add workout streak tracking
- Add goal setting and tracking
- Add workout templates/favorites
- Add social sharing features

---

## Summary

This plan provides step-by-step implementation of Phase 2 (Workout History) and Phase 3 (Stats & Analytics) for the Next.js web authentication app.

**Total Tasks:** 11
**Estimated Time:** 4-6 hours
**Phase:** Phase 2 & 3 - Workout History and Analytics

The implementation follows best practices:
- Server-side data fetching for performance
- Type-safe with TypeScript
- Responsive charts with Recharts
- Clean component separation
- Efficient data calculations with useMemo
- Proper date formatting with date-fns
- Consistent UI with Tailwind CSS and shadcn/ui
