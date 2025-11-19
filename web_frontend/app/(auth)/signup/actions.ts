"use server";

import { createClient } from "@/lib/supabase/server";

interface SignupInput {
  email: string;
  password: string;
  username: string;
  name: string;
}

export async function signup(data: SignupInput) {
  const supabase = await createClient();

  const { error } = await supabase.auth.signUp({
    email: data.email,
    password: data.password,
    options: {
      data: {
        username: data.username,
        name: data.name,
      },
      emailRedirectTo: `${
        process.env.NEXT_PUBLIC_SITE_URL ?? "http://localhost:3000"
      }/auth/callback`,
    },
  });

  if (error) {
    return { error: error.message };
  }

  return { success: true };
}
