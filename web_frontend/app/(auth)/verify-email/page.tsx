export default function VerifyEmailPage() {
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
        We sent a verification link to your email address. Click the link to
        verify your account.
      </p>
      <div className="mt-8 rounded-md bg-blue-50 p-4">
        <p className="text-sm text-blue-800">
          <strong>Note:</strong> The link expires in 24 hours. You will not be
          able to log in until your email is verified.
        </p>
      </div>
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
