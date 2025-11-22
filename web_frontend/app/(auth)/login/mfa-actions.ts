"use server";

import { createClient } from "@/lib/supabase/server";

export async function verifyMFA(code: string) {
  const supabase = await createClient();

  try {
    // Get the list of MFA factors
    const { data: factors, error: listError } = await supabase.auth.mfa.listFactors();

    if (listError) {
      return { error: listError.message };
    }

    // Find the TOTP factor
    const totpFactor = factors?.totp?.find(f => f.status === 'verified');

    if (!totpFactor) {
      return { error: 'No MFA factor found' };
    }

    // Create a challenge and verify
    const { data: challengeData, error: challengeError } = await supabase.auth.mfa.challenge({
      factorId: totpFactor.id,
    });

    if (challengeError) {
      return { error: challengeError.message };
    }

    // Verify the code
    const { error: verifyError } = await supabase.auth.mfa.verify({
      factorId: totpFactor.id,
      challengeId: challengeData.id,
      code,
    });

    if (verifyError) {
      return { error: 'Invalid code. Please try again.' };
    }

    return { success: true };
  } catch {
    return { error: 'Verification failed. Please try again.' };
  }
}
