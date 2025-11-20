export default function WorkoutDetailLoading() {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="mb-6">
          <div className="h-5 w-40 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
        </div>

        <div className="rounded-lg bg-white shadow dark:bg-gray-800">
          <div className="px-4 py-5 sm:p-6">
            <div className="mb-8">
              <div className="mb-4 h-8 w-64 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>

              <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="space-y-2">
                    <div className="h-4 w-16 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
                    <div className="h-5 w-32 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
                  </div>
                ))}
              </div>
            </div>

            <div className="space-y-6">
              <div className="h-6 w-32 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>

              <div className="space-y-4">
                {[1, 2, 3, 4].map((i) => (
                  <div key={i} className="space-y-3 rounded-lg border border-gray-200 p-4 dark:border-gray-700">
                    <div className="h-5 w-48 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
                    <div className="h-4 w-32 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
