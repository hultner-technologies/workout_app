"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import Link from "next/link";

import { logout, updateName } from "@/app/profile/actions";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";

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
  const [editingName, setEditingName] = useState(false);
  const [name, setName] = useState(appUser?.name || "");
  const [nameError, setNameError] = useState<string | null>(null);
  const [nameSaving, setNameSaving] = useState(false);

  async function handleLogout() {
    setLoading(true);
    await logout();
    router.push("/login");
    router.refresh();
  }

  async function handleSaveName() {
    if (!name.trim()) {
      setNameError("Name cannot be empty");
      return;
    }

    setNameSaving(true);
    setNameError(null);

    const result = await updateName(name.trim());

    if (result.error) {
      setNameError(result.error);
      setNameSaving(false);
    } else {
      setEditingName(false);
      setNameSaving(false);
      router.refresh();
    }
  }

  function handleCancelEdit() {
    setName(appUser?.name || "");
    setEditingName(false);
    setNameError(null);
  }

  return (
    <div className="space-y-6">
      <div>
        <h3 className="mb-4 text-lg font-medium text-gray-900">
          Account Information
        </h3>
        <dl className="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
          <div className="sm:col-span-2">
            <dt className="text-sm font-medium text-gray-500">Full Name</dt>
            {editingName ? (
              <div className="mt-2 space-y-2">
                <Input
                  type="text"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="Enter your name"
                  disabled={nameSaving}
                />
                {nameError && (
                  <p className="text-sm text-red-600">{nameError}</p>
                )}
                <div className="flex gap-2">
                  <Button
                    size="sm"
                    onClick={handleSaveName}
                    disabled={nameSaving}
                  >
                    {nameSaving ? "Saving..." : "Save"}
                  </Button>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={handleCancelEdit}
                    disabled={nameSaving}
                  >
                    Cancel
                  </Button>
                </div>
              </div>
            ) : (
              <div className="mt-1 flex items-center gap-2">
                <dd className="text-sm text-gray-900">
                  {appUser?.name || "Not set"}
                </dd>
                <Button
                  size="sm"
                  variant="ghost"
                  onClick={() => setEditingName(true)}
                  className="text-blue-600 hover:text-blue-700"
                >
                  Edit
                </Button>
              </div>
            )}
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
        <h3 className="mb-4 text-lg font-medium text-gray-900">
          Quick Navigation
        </h3>
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Button asChild variant="outline">
            <Link href="/workouts">View Workout History</Link>
          </Button>
          <Button asChild variant="outline">
            <Link href="/stats">View Statistics</Link>
          </Button>
        </div>
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
