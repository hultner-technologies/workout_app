"use server";

import { z } from "zod";
import { createClient } from "@/lib/supabase/server";

export async function logout() {
  const supabase = await createClient();
  await supabase.auth.signOut();
}

const nameSchema = z
  .string()
  .trim()
  .min(1, "Name cannot be empty")
  .max(100, "Name must be less than 100 characters");

export async function updateName(name: string) {
  // Validate input
  const validationResult = nameSchema.safeParse(name);

  if (!validationResult.success) {
    return { error: validationResult.error.issues[0].message };
  }

  const supabase = await createClient();

  const { data: { user } } = await supabase.auth.getUser();

  if (!user) {
    return { error: "Not authenticated" };
  }

  const { error } = await supabase
    .from("app_user")
    .update({ name: validationResult.data })
    .eq("app_user_id", user.id);

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}
