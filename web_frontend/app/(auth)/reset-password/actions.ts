"use server";

import { createClient } from "@/lib/supabase/server";

export async function requestPasswordReset(email: string) {
  const supabase = await createClient();

  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${
      process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"
    }/update-password`,
  });

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}
