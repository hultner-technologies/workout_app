'use client'

import { useState } from 'react'
import Image from 'next/image'
import { createClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import QRCode from 'qrcode'

interface MFASetupProps {
  onSuccess: () => void
  onCancel: () => void
}

/**
 * MFASetup - Component for enrolling in MFA
 *
 * Guides user through MFA setup:
 * 1. Generates QR code for authenticator app
 * 2. User scans QR code
 * 3. User enters verification code to confirm setup
 */
export function MFASetup({ onSuccess, onCancel }: MFASetupProps) {
  const [qrCode, setQrCode] = useState<string>('')
  const [secret, setSecret] = useState<string>('')
  const [verificationCode, setVerificationCode] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [step, setStep] = useState<'generate' | 'verify'>('generate')

  const generateQRCode = async () => {
    setLoading(true)
    setError(null)

    try {
      const supabase = createClient()
      const { data, error } = await supabase.auth.mfa.enroll({
        factorType: 'totp',
      })

      if (error) throw error

      // Generate QR code from the URI
      const qrCodeDataUrl = await QRCode.toDataURL(data.totp.qr_code)
      setQrCode(qrCodeDataUrl)
      setSecret(data.totp.secret)
      setStep('verify')
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to generate QR code')
    } finally {
      setLoading(false)
    }
  }

  const verifyAndEnable = async () => {
    if (!verificationCode || verificationCode.length !== 6) {
      setError('Please enter a 6-digit code')
      return
    }

    setLoading(true)
    setError(null)

    try {
      const supabase = createClient()

      // Get the factor ID from the enrolled factors
      const { data: factors } = await supabase.auth.mfa.listFactors()
      const totpFactor = factors?.totp?.find(f => f.status !== 'verified')

      if (!totpFactor) {
        throw new Error('No pending MFA enrollment found')
      }

      // Verify the code
      const { error } = await supabase.auth.mfa.challengeAndVerify({
        factorId: totpFactor.id,
        code: verificationCode,
      })

      if (error) throw error

      onSuccess()
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Verification failed')
    } finally {
      setLoading(false)
    }
  }

  if (step === 'generate') {
    return (
      <div className="space-y-4">
        <div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
            Enable Two-Factor Authentication
          </h3>
          <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
            Add an extra layer of security to your account by requiring a code from your authenticator app when you sign in.
          </p>
        </div>

        {error && (
          <div className="rounded-md bg-red-50 p-3 text-sm text-red-600 dark:bg-red-900/20 dark:text-red-400" data-testid="mfa-error">
            {error}
          </div>
        )}

        <div className="flex gap-3">
          <Button onClick={generateQRCode} disabled={loading} data-testid="mfa-generate-button">
            {loading ? 'Generating...' : 'Set Up Authenticator'}
          </Button>
          <Button variant="outline" onClick={onCancel} disabled={loading}>
            Cancel
          </Button>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div>
        <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
          Scan QR Code
        </h3>
        <p className="mt-2 text-sm text-gray-600 dark:text-gray-400">
          Scan this QR code with your authenticator app (Google Authenticator, Authy, 1Password, etc.)
        </p>
      </div>

      <div className="flex justify-center bg-white p-4 rounded-lg dark:bg-gray-800" data-testid="mfa-qr-code">
        {qrCode && <Image src={qrCode} alt="MFA QR Code" width={256} height={256} className="max-w-xs" />}
      </div>

      <div className="rounded-lg bg-gray-50 p-4 dark:bg-gray-800">
        <p className="text-xs font-medium text-gray-700 dark:text-gray-300 mb-2">
          Or enter this code manually:
        </p>
        <code className="text-sm font-mono text-gray-900 dark:text-white break-all">
          {secret}
        </code>
      </div>

      <div>
        <label htmlFor="verification-code" className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
          Enter the 6-digit code from your authenticator app
        </label>
        <Input
          id="verification-code"
          type="text"
          inputMode="numeric"
          pattern="[0-9]*"
          maxLength={6}
          value={verificationCode}
          onChange={(e) => setVerificationCode(e.target.value.replace(/\D/g, ''))}
          placeholder="000000"
          className="text-center text-2xl tracking-widest"
          data-testid="mfa-verification-input"
        />
      </div>

      {error && (
        <div className="rounded-md bg-red-50 p-3 text-sm text-red-600 dark:bg-red-900/20 dark:text-red-400" data-testid="mfa-error">
          {error}
        </div>
      )}

      <div className="flex gap-3">
        <Button onClick={verifyAndEnable} disabled={loading || verificationCode.length !== 6} data-testid="mfa-verify-button">
          {loading ? 'Verifying...' : 'Verify and Enable'}
        </Button>
        <Button variant="outline" onClick={onCancel} disabled={loading}>
          Cancel
        </Button>
      </div>
    </div>
  )
}
