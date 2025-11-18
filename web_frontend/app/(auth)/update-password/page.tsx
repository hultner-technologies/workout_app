import { UpdatePasswordForm } from "@/components/auth/update-password-form";

export default function UpdatePasswordPage() {
  return (
    <div>
      <div className="text-center">
        <h2 className="text-3xl font-bold tracking-tight">
          Update your password
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Enter a new password to finish resetting your account.
        </p>
      </div>
      <UpdatePasswordForm />
    </div>
  );
}
