'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Button } from '@/components/ui/button'

interface AuthNavProps {
  onSignOut?: () => void
}

/**
 * AuthNav - Navigation header for authenticated users
 *
 * Provides navigation between Profile, Workouts, and Stats pages
 * with visual indication of the current page and sign out functionality.
 *
 * @param {AuthNavProps} props - Component props
 * @returns {JSX.Element} Navigation header
 */
export function AuthNav({ onSignOut }: AuthNavProps) {
  const pathname = usePathname()

  const navItems = [
    { href: '/profile', label: 'Profile' },
    { href: '/workouts', label: 'Workouts' },
    { href: '/stats', label: 'Stats' },
  ]

  return (
    <nav className="border-b border-gray-200 bg-white dark:border-gray-700 dark:bg-gray-800">
      <div className="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div className="flex h-16 items-center justify-between">
          {/* Logo/Brand */}
          <div className="flex items-center">
            <Link href="/profile" className="text-xl font-bold text-gray-900 dark:text-white">
              GymR8
            </Link>
          </div>

          {/* Navigation Links */}
          <div className="flex items-center gap-1">
            {navItems.map((item) => {
              const isActive = pathname === item.href || pathname?.startsWith(item.href + '/')
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  className={`rounded-md px-3 py-2 text-sm font-medium transition-colors ${
                    isActive
                      ? 'bg-gray-100 text-gray-900 dark:bg-gray-700 dark:text-white'
                      : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900 dark:text-gray-300 dark:hover:bg-gray-700 dark:hover:text-white'
                  }`}
                  data-testid={`nav-${item.label.toLowerCase()}`}
                >
                  {item.label}
                </Link>
              )
            })}
          </div>

          {/* Sign Out Button */}
          {onSignOut && (
            <Button
              variant="ghost"
              onClick={onSignOut}
              className="text-sm"
              data-testid="nav-signout"
            >
              Sign Out
            </Button>
          )}
        </div>
      </div>
    </nav>
  )
}
