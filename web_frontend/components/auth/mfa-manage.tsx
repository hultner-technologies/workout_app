'use client'

import { useState, useEffect } from 'react'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { MFASetup } from './mfa-setup'

/**
 * MFAManage - Component for managing MFA settings
 *
 * Shows current MFA status and allows users to:
 * - Enable MFA if not already enabled
 * - Disable MFA if enabled
 * - View when MFA was last configured
 */
export function MFAManage() {
  const [mfaEnabled, setMfaEnabled] = useState(false)
  const [loading, setLoading] = useState(true)
  const [showSetup, setShowSetup] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    checkMFAStatus()
  }, [])

  const checkMFAStatus = async () => {
    try {
      const supabase = createClient()
      const { data, error } = await supabase.auth.mfa.listFactors()

      if (error) throw error

      // Check if user has any verified TOTP factors
      const hasVerifiedFactor = data?.totp?.some(f => f.status === 'verified')
      setMfaEnabled(!!hasVerifiedFactor)
    } catch (err) {
      console.error('Error checking MFA status:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleDisableMFA = async () => {
    if (!confirm('Are you sure you want to disable two-factor authentication? This will make your account less secure.')) {
      return
    }

    setLoading(true)
    setError(null)

    try {
      const supabase = createClient()
      const { data: factors } = await supabase.auth.mfa.listFactors()
      const verifiedFactor = factors?.totp?.find(f => f.status === 'verified')

      if (!verifiedFactor) {
        throw new Error('No MFA factor found')
      }

      const { error } = await supabase.auth.mfa.unenroll({
        factorId: verifiedFactor.id,
      })

      if (error) throw error

      setMfaEnabled(false)
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to disable MFA')
    } finally {
      setLoading(false)
    }
  }

  const handleSetupComplete = () => {
    setShowSetup(false)
    setMfaEnabled(true)
    checkMFAStatus()
  }

  if (loading) {
    return (
      <div className="rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800">
        <p className="text-sm text-gray-500 dark:text-gray-400">Loading MFA settings...</p>
      </div>
    )
  }

  if (showSetup) {
    return (
      <div className="rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800">
        <MFASetup
          onSuccess={handleSetupComplete}
          onCancel={() => setShowSetup(false)}
        />
      </div>
    )
  }

  return (
    <div className="rounded-lg border border-gray-200 bg-white p-6 dark:border-gray-700 dark:bg-gray-800" data-testid="mfa-settings">
      <div className="flex items-start justify-between">
        <div className="flex-1">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
            Two-Factor Authentication
          </h3>
          <p className="mt-1 text-sm text-gray-600 dark:text-gray-400">
            {mfaEnabled
              ? 'Your account is protected with two-factor authentication.'
              : 'Add an extra layer of security by requiring a code from your phone when you sign in.'}
          </p>

          {mfaEnabled && (
            <div className="mt-3 inline-flex items-center rounded-full bg-green-100 px-3 py-1 text-sm font-medium text-green-800 dark:bg-green-900/20 dark:text-green-400" data-testid="mfa-enabled-badge">
              <svg className="mr-1.5 h-4 w-4" fill="currentColor" viewBox="0 0 20 20">
                <path fillRule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clipRule="evenodd" />
              </svg>
              Enabled
            </div>
          )}
        </div>

        <div>
          {mfaEnabled ? (
            <Button
              variant="outline"
              onClick={handleDisableMFA}
              disabled={loading}
              data-testid="mfa-disable-button"
            >
              {loading ? 'Disabling...' : 'Disable'}
            </Button>
          ) : (
            <Button
              onClick={() => setShowSetup(true)}
              disabled={loading}
              data-testid="mfa-enable-button"
            >
              Enable MFA
            </Button>
          )}
        </div>
      </div>

      {error && (
        <div className="mt-4 rounded-md bg-red-50 p-3 text-sm text-red-600 dark:bg-red-900/20 dark:text-red-400" data-testid="mfa-error">
          {error}
        </div>
      )}
    </div>
  )
}
