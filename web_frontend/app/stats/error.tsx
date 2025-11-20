'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'

export default function StatsError({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error('Stats page error:', error)
  }, [error])

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="rounded-lg border border-red-200 bg-white p-8 text-center dark:border-red-800 dark:bg-gray-800">
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-red-100 dark:bg-red-900/20">
            <svg
              className="h-6 w-6 text-red-600 dark:text-red-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
              />
            </svg>
          </div>

          <h2 className="mb-2 text-2xl font-bold text-gray-900 dark:text-white">
            Failed to Load Statistics
          </h2>
          <p className="mb-6 text-gray-600 dark:text-gray-300">
            We encountered an error while calculating your fitness statistics.
            {error.digest && (
              <span className="mt-2 block text-sm text-gray-500">
                Error ID: {error.digest}
              </span>
            )}
          </p>

          <div className="flex justify-center gap-4">
            <Button onClick={reset} variant="default">
              Try Again
            </Button>
            <Button asChild variant="outline">
              <a href="/profile">Back to Profile</a>
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
