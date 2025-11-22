import { redirect } from "next/navigation";
import Link from "next/link";

import { Button } from "@/components/ui/button";
import { createClient } from "@/lib/supabase/server";

export default async function Home() {
  const supabase = await createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (user) {
    redirect("/profile");
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 via-white to-purple-50 dark:from-gray-900 dark:via-gray-800 dark:to-gray-900">
      {/* Hero Section */}
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="py-20 text-center">
          <div className="mb-6 inline-block rounded-full bg-blue-100 px-4 py-2 dark:bg-blue-900">
            <span className="text-sm font-semibold text-blue-600 dark:text-blue-300">
              Your Personal Workout Companion
            </span>
          </div>

          <h1 className="mb-6 text-6xl font-bold text-gray-900 dark:text-white">
            Welcome to <span className="bg-gradient-to-r from-blue-600 to-purple-600 bg-clip-text text-transparent">GymR8</span>
          </h1>

          <p className="mx-auto mb-12 max-w-2xl text-xl text-gray-600 dark:text-gray-300">
            The intelligent fitness platform that helps you track every rep,
            visualize your progress, and crush your personal records.
          </p>

          <div className="flex justify-center gap-4">
            <Button asChild size="lg" className="text-lg px-8 py-6">
              <Link href="/signup">Start Free Today</Link>
            </Button>
            <Button asChild variant="outline" size="lg" className="text-lg px-8 py-6">
              <Link href="/login">Sign In</Link>
            </Button>
          </div>

          <p className="mt-4 text-sm text-gray-500 dark:text-gray-400">
            No credit card required • Free forever
          </p>
        </div>

        {/* Features Grid */}
        <div className="grid gap-8 py-20 md:grid-cols-3">
          <div className="rounded-lg border border-gray-200 bg-white p-8 text-center shadow-sm transition-shadow hover:shadow-md dark:border-gray-700 dark:bg-gray-800">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-blue-100 dark:bg-blue-900">
              <svg
                className="h-8 w-8 text-blue-600 dark:text-blue-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"
                />
              </svg>
            </div>
            <h3 className="mb-3 text-xl font-semibold text-gray-900 dark:text-white">
              Smart Workout Logging
            </h3>
            <p className="text-gray-600 dark:text-gray-300">
              Quickly log exercises, sets, reps, and weight. Our intelligent
              system remembers your patterns and suggests your next lift.
            </p>
          </div>

          <div className="rounded-lg border border-gray-200 bg-white p-8 text-center shadow-sm transition-shadow hover:shadow-md dark:border-gray-700 dark:bg-gray-800">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-purple-100 dark:bg-purple-900">
              <svg
                className="h-8 w-8 text-purple-600 dark:text-purple-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
                />
              </svg>
            </div>
            <h3 className="mb-3 text-xl font-semibold text-gray-900 dark:text-white">
              Visual Progress Tracking
            </h3>
            <p className="text-gray-600 dark:text-gray-300">
              Beautiful charts show your strength gains, workout frequency,
              and volume over time. Watch your progress come to life.
            </p>
          </div>

          <div className="rounded-lg border border-gray-200 bg-white p-8 text-center shadow-sm transition-shadow hover:shadow-md dark:border-gray-700 dark:bg-gray-800">
            <div className="mx-auto mb-4 flex h-16 w-16 items-center justify-center rounded-full bg-green-100 dark:bg-green-900">
              <svg
                className="h-8 w-8 text-green-600 dark:text-green-400"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M13 10V3L4 14h7v7l9-11h-7z"
                />
              </svg>
            </div>
            <h3 className="mb-3 text-xl font-semibold text-gray-900 dark:text-white">
              Personal Records
            </h3>
            <p className="text-gray-600 dark:text-gray-300">
              Automatically track your PRs for every exercise. Get notified
              when you hit a new personal best and celebrate your victories.
            </p>
          </div>
        </div>

        {/* CTA Section */}
        <div className="py-16 text-center">
          <h2 className="mb-4 text-3xl font-bold text-gray-900 dark:text-white">
            Ready to Level Up Your Training?
          </h2>
          <p className="mx-auto mb-8 max-w-2xl text-lg text-gray-600 dark:text-gray-300">
            Start tracking your workouts today and see the difference data-driven
            training can make. It&apos;s completely free to get started.
          </p>
          <Button asChild size="lg" className="text-lg px-8 py-6">
            <Link href="/signup">Create Your Free Account</Link>
          </Button>
        </div>
      </div>
    </div>
  );
}
