"use server";

import { createClient } from "@/lib/supabase/server";

export async function logout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
}

export async function updateName(name: string) {
  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Not authenticated" };
  }

  const { error } = await supabase
    .from("app_user")
    .update({ name })
    .eq("app_user_id", user.id);

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}
