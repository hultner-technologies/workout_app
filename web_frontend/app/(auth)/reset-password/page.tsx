import { ResetPasswordForm } from "@/components/auth/reset-password-form";

interface ResetPasswordPageProps {
  searchParams: {
    success?: string;
  };
}

export default function ResetPasswordPage({
  searchParams,
}: ResetPasswordPageProps) {
  if (searchParams.success) {
    return (
      <div className="text-center">
        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-full bg-green-100">
          <svg
            className="h-6 w-6 text-green-600"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
            />
          </svg>
        </div>
        <h2 className="mt-6 text-3xl font-bold tracking-tight">
          Check your email
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          We sent a password reset link to your email address.
        </p>
        <div className="mt-6">
          <a
            href="/login"
            className="text-sm font-medium text-blue-600 hover:text-blue-500"
          >
            Back to login
          </a>
        </div>
      </div>
    );
  }

  return (
    <div>
      <div className="text-center">
        <h2 className="text-3xl font-bold tracking-tight">
          Reset your password
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Enter your email address and we&apos;ll send you a reset link.
        </p>
      </div>
      <ResetPasswordForm />
    </div>
  );
}
