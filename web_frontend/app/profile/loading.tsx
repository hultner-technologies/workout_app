export default function ProfileLoading() {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="rounded-lg bg-white p-8 shadow dark:bg-gray-800">
          <div className="mb-8 h-8 w-32 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>

          <div className="space-y-6">
            <div className="h-4 w-24 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>

            <div className="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="space-y-2">
                  <div className="h-4 w-20 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
                  <div className="h-5 w-40 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
                </div>
              ))}
            </div>

            <div className="border-t border-gray-200 pt-6 dark:border-gray-700">
              <div className="h-10 w-24 animate-pulse rounded bg-gray-200 dark:bg-gray-700"></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}
