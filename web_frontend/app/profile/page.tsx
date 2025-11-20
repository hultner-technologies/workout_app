import { redirect } from "next/navigation";
import { Metadata } from "next";

import { ProfileInfo } from "@/components/profile/profile-info";
import { AuthNavWrapper } from "@/components/nav/auth-nav-wrapper";
import { createClient } from "@/lib/supabase/server";

export const metadata: Metadata = {
  title: "Profile | GymR8",
  description: "Manage your GymR8 profile, view account information, and access your fitness journey dashboard.",
}

export default async function ProfilePage() {
  const supabase = await createClient();

  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect("/login");
  }

  const { data: appUser } = await supabase
    .from("app_user")
    .select("*")
    .eq("app_user_id", user.id)
    .maybeSingle();

  return (
    <div className="min-h-screen bg-gray-50">
      <AuthNavWrapper />
      <div className="mx-auto max-w-7xl px-4 py-12 sm:px-6 lg:px-8">
        <div className="rounded-lg bg-white shadow">
          <div className="px-4 py-5 sm:p-6">
            <h1 className="mb-8 text-3xl font-bold text-gray-900">Profile</h1>
            <ProfileInfo user={user} appUser={appUser} />
          </div>
        </div>
      </div>
    </div>
  );
}
