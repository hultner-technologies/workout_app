import { SignupForm } from "@/components/auth/signup-form";

export default function SignupPage() {
  return (
    <div>
      <div className="text-center">
        <h2 className="text-3xl font-bold tracking-tight">
          Create your account
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Already have an account?{" "}
          <a
            href="/login"
            className="font-medium text-blue-600 hover:text-blue-500"
          >
            Sign in
          </a>
        </p>
      </div>
      <SignupForm />
    </div>
  );
}
