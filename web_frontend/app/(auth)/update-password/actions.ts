"use server";

import { createClient } from "@/lib/supabase/server";

export async function updatePassword(password: string) {
  const supabase = await createClient();

  // Check if user has an active session
  const { data: { user }, error: userError } = await supabase.auth.getUser();

  if (userError || !user) {
    return { error: `Auth session missing! ${userError?.message || 'No user found'}` };
  }

  const { error } = await supabase.auth.updateUser({
    password,
  });

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}
