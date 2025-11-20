export default function WorkoutsLoading() {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="rounded-lg bg-white shadow dark:bg-gray-800">
          <div className="px-4 py-5 sm:p-6">
            <div className="mb-8 flex items-center justify-between">
              <div className="h-10 w-48 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
              <div className="h-6 w-24 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
            </div>

            <div className="space-y-4">
              {[1, 2, 3, 4, 5].map((i) => (
                <div
                  key={i}
                  className="rounded-lg border border-gray-200 bg-gray-50 p-6 dark:border-gray-700 dark:bg-gray-700"
                >
                  <div className="flex items-center justify-between">
                    <div className="flex-1 space-y-3">
                      <div className="h-6 w-48 animate-pulse rounded bg-gray-200 dark:bg-gray-600"></div>
                      <div className="h-4 w-32 animate-pulse rounded bg-gray-200 dark:bg-gray-600"></div>
                    </div>
                    <div className="h-6 w-24 animate-pulse rounded bg-gray-200 dark:bg-gray-600"></div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
