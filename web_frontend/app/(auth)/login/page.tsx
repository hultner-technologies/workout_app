import { LoginForm } from "@/components/auth/login-form";

interface LoginPageProps {
  searchParams: {
    redirect?: string;
    error?: string;
    success?: string;
  };
}

export default function LoginPage({ searchParams }: LoginPageProps) {
  return (
    <div>
      <div className="text-center">
        <h2 className="text-3xl font-bold tracking-tight">
          Sign in to your account
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Or{" "}
          <a
            href="/signup"
            className="font-medium text-blue-600 hover:text-blue-500"
          >
            Sign up
          </a>
        </p>
      </div>
      {searchParams.error && (
        <div className="mt-4 rounded-md bg-red-50 p-3 text-sm text-red-600">
          {searchParams.error}
        </div>
      )}
      {searchParams.success && (
        <div className="mt-4 rounded-md bg-green-50 p-3 text-sm text-green-700">
          {searchParams.success}
        </div>
      )}
      <LoginForm redirect={searchParams.redirect} />
    </div>
  );
}
