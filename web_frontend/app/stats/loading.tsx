export default function StatsLoading() {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="mb-8 flex items-center justify-between">
          <div className="h-8 w-32 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
          <div className="flex gap-2">
            {[1, 2, 3, 4, 5].map((i) => (
              <div
                key={i}
                className="h-10 w-20 animate-pulse rounded bg-gray-200 dark:bg-gray-700"
              ></div>
            ))}
          </div>
        </div>

        {/* Overview Stats Skeleton */}
        <div className="mb-8 grid grid-cols-1 gap-6 md:grid-cols-3">
          {[1, 2, 3].map((i) => (
            <div
              key={i}
              className="rounded-lg bg-white p-6 dark:bg-gray-800"
            >
              <div className="mb-2 h-4 w-32 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
              <div className="h-10 w-24 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
            </div>
          ))}
        </div>

        {/* Charts Skeleton */}
        {[1, 2, 3].map((i) => (
          <div
            key={i}
            className="mb-8 rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800"
          >
            <div className="mb-4 h-6 w-48 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
            <div className="h-80 animate-pulse rounded bg-gray-100 dark:bg-gray-900"></div>
          </div>
        ))}
      </div>
    </div>
  )
}
