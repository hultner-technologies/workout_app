'use client'

import { useEffect } from 'react'
import Link from 'next/link'
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
        <div
          className="rounded-lg border border-red-200 bg-white p-8 text-center dark:border-red-800 dark:bg-gray-800"
          role="alert"
          aria-live="assertive"
        >
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-red-100 dark:bg-red-900/20">
            <svg
              className="h-6 w-6 text-red-600 dark:text-red-400"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
              aria-hidden="true"
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
            Unable to Load Statistics
          </h2>
          <p className="mb-4 text-gray-600 dark:text-gray-300">
            We encountered an error while analyzing your workout data. This might be due to a temporary issue with data processing or network connectivity.
          </p>

          <div className="mb-6 rounded-lg bg-gray-50 p-4 text-left dark:bg-gray-900/50">
            <h3 className="mb-2 text-sm font-semibold text-gray-900 dark:text-white">
              Troubleshooting steps:
            </h3>
            <ul className="space-y-1 text-sm text-gray-600 dark:text-gray-300">
              <li>• Click &quot;Try Again&quot; to recalculate your statistics</li>
              <li>• Ensure you have an active internet connection</li>
              <li>• Try viewing your workout history instead</li>
              <li>• If the issue continues, please contact support with the error reference below</li>
            </ul>
          </div>

          {error.digest && (
            <p className="mb-6 text-xs text-gray-500 dark:text-gray-400">
              Error Reference: <code className="rounded bg-gray-100 px-2 py-1 dark:bg-gray-800">{error.digest}</code>
            </p>
          )}

          <div className="flex justify-center gap-4">
            <Button
              onClick={reset}
              variant="default"
              aria-label="Try loading statistics again"
            >
              Try Again
            </Button>
            <Button asChild variant="outline">
              <Link href="/workouts">View Workouts</Link>
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}
