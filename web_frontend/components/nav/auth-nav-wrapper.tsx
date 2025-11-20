'use client'

import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { AuthNav } from './auth-nav'

/**
 * AuthNavWrapper - Client component wrapper for AuthNav with sign out functionality
 *
 * Handles authentication actions that require client-side Supabase client.
 *
 * @returns {JSX.Element} Navigation with sign out handler
 */
export function AuthNavWrapper() {
  const router = useRouter()

  const handleSignOut = async () => {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/login')
    router.refresh()
  }

  return <AuthNav onSignOut={handleSignOut} />
}
