"use server";

import { createClient } from "@/lib/supabase/server";

interface LoginInput {
  email: string;
  password: string;
}

export async function login(data: LoginInput) {
  const supabase = await createClient();

  const { error: signInError } = await supabase.auth.signInWithPassword({
    email: data.email,
    password: data.password,
  });

  if (signInError) {
    if (signInError.message.includes("Email not confirmed")) {
      return {
        error: "Please verify your email address before signing in.",
      };
    }

    return { error: signInError.message };
  }

  // Check if user has MFA enabled
  const { data: factors } = await supabase.auth.mfa.listFactors();
  const hasMFAEnabled = factors?.totp?.some(f => f.status === 'verified');

  // If user has MFA enabled, they need to complete the second factor
  if (hasMFAEnabled) {
    return { success: true, mfaRequired: true };
  }

  return { success: true, mfaRequired: false };
}
