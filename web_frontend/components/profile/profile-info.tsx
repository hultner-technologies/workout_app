"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";

import { logout } from "@/app/profile/actions";
import { Button } from "@/components/ui/button";

interface ProfileInfoProps {
  user: {
    email?: string | null;
    email_confirmed_at?: string | null;
  };
  appUser: {
    name?: string | null;
    username?: string | null;
  } | null;
}

export function ProfileInfo({ user, appUser }: ProfileInfoProps) {
  const router = useRouter();
  const [loading, setLoading] = useState(false);

  async function handleLogout() {
    setLoading(true);
    await logout();
    router.push("/login");
    router.refresh();
  }

  return (
    <div className="space-y-6">
      <div>
        <h3 className="mb-4 text-lg font-medium text-gray-900">
          Account Information
        </h3>
        <dl className="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
          <div>
            <dt className="text-sm font-medium text-gray-500">Full Name</dt>
            <dd className="mt-1 text-sm text-gray-900">
              {appUser?.name || "Not set"}
            </dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Username</dt>
            <dd className="mt-1 text-sm text-gray-900">
              {appUser?.username || "Not set"}
            </dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Email</dt>
            <dd className="mt-1 text-sm text-gray-900">{user.email ?? "—"}</dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">
              Email Verified
            </dt>
            <dd className="mt-1 text-sm text-gray-900">
              {user.email_confirmed_at ? (
                <span className="text-green-600">Verified</span>
              ) : (
                <span className="text-red-600">Not verified</span>
              )}
            </dd>
          </div>
        </dl>
      </div>

      <div className="border-t border-gray-200 pt-5">
        <Button
          onClick={handleLogout}
          variant="destructive"
          disabled={loading}
        >
          {loading ? "Logging out..." : "Log out"}
        </Button>
      </div>
    </div>
  );
}
