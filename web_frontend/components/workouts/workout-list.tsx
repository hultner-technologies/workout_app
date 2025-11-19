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
  } | {
    session_schedule_id: string
    name: string
  }[]
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
    const schedule = Array.isArray(session.session_schedule)
      ? session.session_schedule[0]
      : session.session_schedule
    const sessionName = schedule?.name?.toLowerCase() || ''
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
                    {(Array.isArray(session.session_schedule)
                      ? session.session_schedule[0]?.name
                      : session.session_schedule?.name) || 'Unknown Workout'}
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
