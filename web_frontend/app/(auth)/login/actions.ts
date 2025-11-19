"use server";

import { createClient } from "@/lib/supabase/server";

interface LoginInput {
  email: string;
  password: string;
}

export async function login(data: LoginInput) {
  const supabase = await createClient();

  const { error } = await supabase.auth.signInWithPassword({
    email: data.email,
    password: data.password,
  });

  if (error) {
    if (error.message.includes("Email not confirmed")) {
      return {
        error: "Please verify your email address before signing in.",
      };
    }

    return { error: error.message };
  }

  return { success: true };
}
