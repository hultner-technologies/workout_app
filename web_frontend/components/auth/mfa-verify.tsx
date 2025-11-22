'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'

interface MFAVerifyProps {
  onVerify: (code: string) => Promise<void>
  onCancel: () => void
  loading?: boolean
  error?: string | null
}

/**
 * MFAVerify - Component for verifying MFA code during login
 *
 * Shown after successful email/password login when user has MFA enabled.
 * Requires 6-digit code from authenticator app.
 */
export function MFAVerify({ onVerify, onCancel, loading = false, error }: MFAVerifyProps) {
  const [code, setCode] = useState('')

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (code.length === 6) {
      await onVerify(code)
    }
  }

  return (
    <div className="space-y-4">
      <div className="text-center">
        <h2 className="text-2xl font-bold text-gray-900 dark:text-white">
          Two-Factor Authentication
        </h2>
        <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
          Enter the 6-digit code from your authenticator app
        </p>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        <div>
          <Input
            type="text"
            inputMode="numeric"
            pattern="[0-9]*"
            maxLength={6}
            value={code}
            onChange={(e) => setCode(e.target.value.replace(/\D/g, ''))}
            placeholder="000000"
            className="text-center text-2xl tracking-widest"
            autoFocus
            data-testid="mfa-code-input"
          />
        </div>

        {error && (
          <div className="rounded-md bg-red-50 p-3 text-sm text-red-600 dark:bg-red-900/20 dark:text-red-400" data-testid="mfa-verify-error">
            {error}
          </div>
        )}

        <div className="flex gap-3">
          <Button
            type="submit"
            className="flex-1"
            disabled={loading || code.length !== 6}
            data-testid="mfa-verify-submit"
          >
            {loading ? 'Verifying...' : 'Verify'}
          </Button>
          <Button
            type="button"
            variant="outline"
            onClick={onCancel}
            disabled={loading}
          >
            Cancel
          </Button>
        </div>
      </form>

      <div className="text-center text-sm text-gray-600 dark:text-gray-400">
        <p>Lost access to your authenticator?</p>
        <button
          type="button"
          className="text-blue-600 hover:text-blue-500 dark:text-blue-400"
          onClick={onCancel}
        >
          Contact support
        </button>
      </div>
    </div>
  )
}
