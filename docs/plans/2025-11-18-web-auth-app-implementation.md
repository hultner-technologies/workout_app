# Web Authentication App Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Next.js 14 web application providing user authentication (signup, login, password reset, email verification) integrated with Supabase Auth.

**Architecture:** App Router with server-side rendering, Supabase SSR for authentication, shadcn/ui components for UI. Auth middleware protects routes, database trigger auto-creates app_user records on signup. Email verification required before login.

**Tech Stack:** Next.js 14 (App Router), TypeScript, Supabase SSR (@supabase/ssr), shadcn/ui, Tailwind CSS, Vercel (deployment)

---

## Phase 1: Project Setup & Configuration

### Task 1: Initialize Next.js Project

**Files:**
- Create: `.worktrees/web-auth-app/web_frontend/` (directory)
- Create: `.worktrees/web-auth-app/web_frontend/package.json`
- Create: `.worktrees/web-auth-app/web_frontend/tsconfig.json`
- Create: `.worktrees/web-auth-app/web_frontend/next.config.js`
- Create: `.worktrees/web-auth-app/web_frontend/tailwind.config.ts`

**Step 1: Navigate to worktree**

```bash
cd .worktrees/web-auth-app
```

**Step 2: Create Next.js app**

Run: `npx create-next-app@latest web_frontend --typescript --tailwind --app --src-dir --import-alias "@/*"`

When prompted:
- TypeScript: Yes
- ESLint: Yes
- Tailwind CSS: Yes
- `src/` directory: No (we'll use app/ directly)
- App Router: Yes
- Import alias: `@/*`

Expected: Next.js project created in web_frontend/

**Step 3: Navigate to project**

```bash
cd web_frontend
```

**Step 4: Install Supabase dependencies**

Run: `npm install @supabase/supabase-js @supabase/ssr`

Expected: Dependencies installed

**Step 5: Verify project runs**

Run: `npm run dev`

Expected: Dev server starts on http://localhost:3000

Stop server with Ctrl+C

**Step 6: Commit**

```bash
git add web_frontend/
git commit -m "chore: initialize Next.js project with TypeScript and Tailwind"
```

---

### Task 2: Install and Configure shadcn/ui

**Files:**
- Create: `web_frontend/components.json`
- Create: `web_frontend/lib/utils.ts`
- Create: `web_frontend/components/ui/` (directory)

**Step 1: Initialize shadcn/ui**

Run: `npx shadcn@latest init`

When prompted:
- TypeScript: Yes
- Style: Default
- Base color: Slate
- CSS variables: Yes
- Tailwind config: tailwind.config.ts
- Components path: `@/components`
- Utils path: `@/lib/utils`
- React Server Components: Yes
- Component style: New York

Expected: shadcn/ui configured

**Step 2: Install base components**

Run: `npx shadcn@latest add button input label card form`

Expected: Components installed in components/ui/

**Step 3: Verify installation**

Check files exist:
- `components/ui/button.tsx`
- `components/ui/input.tsx`
- `components/ui/label.tsx`
- `components/ui/card.tsx`
- `components/ui/form.tsx`

**Step 4: Commit**

```bash
git add .
git commit -m "chore: configure shadcn/ui and install base components"
```

---

### Task 3: Configure Environment Variables

**Files:**
- Create: `web_frontend/.env.local`
- Create: `web_frontend/.env.example`

**Step 1: Create .env.local**

Create file: `web_frontend/.env.local`

```env
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

**Step 2: Create .env.example**

Create file: `web_frontend/.env.example`

```env
# Supabase Configuration
# Get these from your Supabase project settings
NEXT_PUBLIC_SUPABASE_URL=your-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

**Step 3: Verify .gitignore**

Check that `.env.local` is in `.gitignore` (should be there by default from create-next-app)

**Step 4: Commit**

```bash
git add .env.example
git commit -m "chore: add environment variable configuration"
```

---

## Phase 2: Supabase Client Setup

### Task 4: Create Supabase Client Utilities

**Files:**
- Create: `web_frontend/lib/supabase/client.ts`
- Create: `web_frontend/lib/supabase/server.ts`
- Create: `web_frontend/lib/supabase/middleware.ts`

**Step 1: Write client-side Supabase client**

Create file: `web_frontend/lib/supabase/client.ts`

```typescript
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

**Step 2: Write server-side Supabase client**

Create file: `web_frontend/lib/supabase/server.ts`

```typescript
import { createServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export async function createClient() {
  const cookieStore = await cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) => {
              cookieStore.set(name, value, options)
            })
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing
            // user sessions.
          }
        },
      },
    }
  )
}
```

**Step 3: Write middleware helper**

Create file: `web_frontend/lib/supabase/middleware.ts`

```typescript
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function updateSession(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            request.cookies.set(name, value)
          )
          response = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Refresh session if expired
  await supabase.auth.getUser()

  return response
}
```

**Step 4: Commit**

```bash
git add lib/supabase/
git commit -m "feat: add Supabase client utilities for browser and server"
```

---

### Task 5: Create Auth Middleware

**Files:**
- Create: `web_frontend/middleware.ts`

**Step 1: Write middleware**

Create file: `web_frontend/middleware.ts`

```typescript
import { updateSession } from '@/lib/supabase/middleware'
import { type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  return await updateSession(request)
}

export const config = {
  matcher: [
    /*
     * Match all request paths except:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public files (images, etc.)
     */
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

**Step 2: Verify TypeScript compiles**

Run: `npm run build`

Expected: Build succeeds (may have warnings about unused routes)

**Step 3: Commit**

```bash
git add middleware.ts
git commit -m "feat: add auth middleware for session management"
```

---

## Phase 3: Authentication Pages - Signup

### Task 6: Create Signup Page Layout

**Files:**
- Create: `web_frontend/app/(auth)/layout.tsx`
- Create: `web_frontend/app/(auth)/signup/page.tsx`

**Step 1: Create auth route group layout**

Create file: `web_frontend/app/(auth)/layout.tsx`

```typescript
export default function AuthLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-md w-full space-y-8">
        {children}
      </div>
    </div>
  )
}
```

**Step 2: Create signup page**

Create file: `web_frontend/app/(auth)/signup/page.tsx`

```typescript
import { SignupForm } from '@/components/auth/signup-form'

export default function SignupPage() {
  return (
    <div>
      <div className="text-center">
        <h2 className="text-3xl font-bold tracking-tight">
          Create your account
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Already have an account?{' '}
          <a href="/login" className="font-medium text-blue-600 hover:text-blue-500">
            Sign in
          </a>
        </p>
      </div>
      <SignupForm />
    </div>
  )
}
```

**Step 3: Verify routes**

Run: `npm run dev`

Visit: http://localhost:3000/signup

Expected: Page loads but SignupForm component is missing (will create next)

Stop server

**Step 4: Commit**

```bash
git add app/\(auth\)/
git commit -m "feat: add signup page layout and structure"
```

---

### Task 7: Create Signup Form Component

**Files:**
- Create: `web_frontend/components/auth/signup-form.tsx`
- Create: `web_frontend/app/(auth)/signup/actions.ts`

**Step 1: Install react-hook-form and zod**

Run: `npm install react-hook-form @hookform/resolvers zod`

Expected: Dependencies installed

**Step 2: Write signup form component**

Create file: `web_frontend/components/auth/signup-form.tsx`

```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
import * as z from 'zod'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { signup } from '@/app/(auth)/signup/actions'

const signupSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(8, 'Password must be at least 8 characters'),
  username: z.string()
    .min(3, 'Username must be at least 3 characters')
    .max(20, 'Username must be at most 20 characters')
    .regex(/^[a-z0-9_]+$/, 'Username must be lowercase letters, numbers, and underscores only'),
  name: z.string().min(2, 'Name must be at least 2 characters'),
})

type SignupFormValues = z.infer<typeof signupSchema>

export function SignupForm() {
  const router = useRouter()
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const form = useForm<SignupFormValues>({
    resolver: zodResolver(signupSchema),
    defaultValues: {
      email: '',
      password: '',
      username: '',
      name: '',
    },
  })

  async function onSubmit(values: SignupFormValues) {
    setLoading(true)
    setError(null)

    const result = await signup(values)

    if (result.error) {
      setError(result.error)
      setLoading(false)
    } else {
      router.push('/verify-email')
    }
  }

  return (
    <div className="mt-8">
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl>
                  <Input
                    type="email"
                    placeholder="you@example.com"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="username"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Username</FormLabel>
                <FormControl>
                  <Input
                    type="text"
                    placeholder="johndoe_123"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="name"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Full Name</FormLabel>
                <FormControl>
                  <Input
                    type="text"
                    placeholder="John Doe"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Password</FormLabel>
                <FormControl>
                  <Input
                    type="password"
                    placeholder="••••••••"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {error && (
            <div className="text-sm text-red-600 bg-red-50 p-3 rounded-md">
              {error}
            </div>
          )}

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? 'Creating account...' : 'Create account'}
          </Button>
        </form>
      </Form>
    </div>
  )
}
```

**Step 3: Write signup server action**

Create file: `web_frontend/app/(auth)/signup/actions.ts`

```typescript
'use server'

import { createClient } from '@/lib/supabase/server'

export async function signup(data: {
  email: string
  password: string
  username: string
  name: string
}) {
  const supabase = await createClient()

  const { error } = await supabase.auth.signUp({
    email: data.email,
    password: data.password,
    options: {
      data: {
        username: data.username,
        name: data.name,
      },
      emailRedirectTo: `${process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'}/auth/callback`,
    },
  })

  if (error) {
    return { error: error.message }
  }

  return { success: true }
}
```

**Step 4: Test signup form**

Run: `npm run dev`

Visit: http://localhost:3000/signup

Test:
1. Try submitting empty form → should show validation errors
2. Try invalid email → should show email error
3. Try short password → should show password error
4. Try invalid username (uppercase) → should show username error

Expected: All validations work

Stop server

**Step 5: Commit**

```bash
git add components/auth/signup-form.tsx app/\(auth\)/signup/actions.ts package.json package-lock.json
git commit -m "feat: add signup form with validation"
```

---

### Task 8: Create Email Verification Page

**Files:**
- Create: `web_frontend/app/(auth)/verify-email/page.tsx`

**Step 1: Write verify-email page**

Create file: `web_frontend/app/(auth)/verify-email/page.tsx`

```typescript
export default function VerifyEmailPage() {
  return (
    <div className="text-center">
      <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-green-100">
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
        We sent a verification link to your email address.
        Click the link to verify your account.
      </p>
      <div className="mt-8 bg-blue-50 p-4 rounded-md">
        <p className="text-sm text-blue-800">
          <strong>Note:</strong> The link will expire in 24 hours.
          You won't be able to log in until you verify your email.
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
  )
}
```

**Step 2: Test verify-email page**

Run: `npm run dev`

Visit: http://localhost:3000/verify-email

Expected: Page displays email verification instructions

Stop server

**Step 3: Commit**

```bash
git add app/\(auth\)/verify-email/
git commit -m "feat: add email verification page"
```

---

### Task 9: Create Auth Callback Handler

**Files:**
- Create: `web_frontend/app/auth/callback/route.ts`

**Step 1: Write callback route handler**

Create file: `web_frontend/app/auth/callback/route.ts`

```typescript
import { createClient } from '@/lib/supabase/server'
import { NextResponse } from 'next/server'

export async function GET(request: Request) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/profile'

  if (code) {
    const supabase = await createClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    if (!error) {
      return NextResponse.redirect(`${origin}${next}`)
    }
  }

  // Return to login if something went wrong
  return NextResponse.redirect(`${origin}/login?error=Unable to verify email`)
}
```

**Step 2: Verify TypeScript compiles**

Run: `npm run build`

Expected: Build succeeds

**Step 3: Commit**

```bash
git add app/auth/
git commit -m "feat: add OAuth callback handler for email verification"
```

---

## Phase 4: Authentication Pages - Login

### Task 10: Create Login Page

**Files:**
- Create: `web_frontend/app/(auth)/login/page.tsx`
- Create: `web_frontend/app/(auth)/login/actions.ts`
- Create: `web_frontend/components/auth/login-form.tsx`

**Step 1: Write login page**

Create file: `web_frontend/app/(auth)/login/page.tsx`

```typescript
import { LoginForm } from '@/components/auth/login-form'

export default function LoginPage({
  searchParams,
}: {
  searchParams: { error?: string; redirect?: string }
}) {
  return (
    <div>
      <div className="text-center">
        <h2 className="text-3xl font-bold tracking-tight">
          Sign in to your account
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Don't have an account?{' '}
          <a href="/signup" className="font-medium text-blue-600 hover:text-blue-500">
            Sign up
          </a>
        </p>
      </div>
      {searchParams.error && (
        <div className="mt-4 text-sm text-red-600 bg-red-50 p-3 rounded-md">
          {searchParams.error}
        </div>
      )}
      <LoginForm redirect={searchParams.redirect} />
    </div>
  )
}
```

**Step 2: Write login form component**

Create file: `web_frontend/components/auth/login-form.tsx`

```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
import * as z from 'zod'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { login } from '@/app/(auth)/login/actions'

const loginSchema = z.object({
  email: z.string().email('Invalid email address'),
  password: z.string().min(1, 'Password is required'),
})

type LoginFormValues = z.infer<typeof loginSchema>

export function LoginForm({ redirect }: { redirect?: string }) {
  const router = useRouter()
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: '',
      password: '',
    },
  })

  async function onSubmit(values: LoginFormValues) {
    setLoading(true)
    setError(null)

    const result = await login(values)

    if (result.error) {
      setError(result.error)
      setLoading(false)
    } else {
      router.push(redirect || '/profile')
      router.refresh()
    }
  }

  return (
    <div className="mt-8">
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl>
                  <Input
                    type="email"
                    placeholder="you@example.com"
                    autoComplete="email"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Password</FormLabel>
                <FormControl>
                  <Input
                    type="password"
                    placeholder="••••••••"
                    autoComplete="current-password"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <div className="flex items-center justify-end">
            <a
              href="/reset-password"
              className="text-sm font-medium text-blue-600 hover:text-blue-500"
            >
              Forgot your password?
            </a>
          </div>

          {error && (
            <div className="text-sm text-red-600 bg-red-50 p-3 rounded-md">
              {error}
            </div>
          )}

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? 'Signing in...' : 'Sign in'}
          </Button>
        </form>
      </Form>
    </div>
  )
}
```

**Step 3: Write login server action**

Create file: `web_frontend/app/(auth)/login/actions.ts`

```typescript
'use server'

import { createClient } from '@/lib/supabase/server'

export async function login(data: {
  email: string
  password: string
}) {
  const supabase = await createClient()

  const { error } = await supabase.auth.signInWithPassword({
    email: data.email,
    password: data.password,
  })

  if (error) {
    // Customize error message for better UX
    if (error.message.includes('Email not confirmed')) {
      return { error: 'Please verify your email address before signing in.' }
    }
    return { error: error.message }
  }

  return { success: true }
}
```

**Step 4: Test login page**

Run: `npm run dev`

Visit: http://localhost:3000/login

Test:
1. Try submitting empty form → should show validation errors
2. Try invalid email → should show email error

Expected: All validations work

Stop server

**Step 5: Commit**

```bash
git add app/\(auth\)/login/ components/auth/login-form.tsx
git commit -m "feat: add login page and form"
```

---

## Phase 5: Authentication Pages - Password Reset

### Task 11: Create Password Reset Request Page

**Files:**
- Create: `web_frontend/app/(auth)/reset-password/page.tsx`
- Create: `web_frontend/app/(auth)/reset-password/actions.ts`
- Create: `web_frontend/components/auth/reset-password-form.tsx`

**Step 1: Write reset password page**

Create file: `web_frontend/app/(auth)/reset-password/page.tsx`

```typescript
import { ResetPasswordForm } from '@/components/auth/reset-password-form'

export default function ResetPasswordPage({
  searchParams,
}: {
  searchParams: { success?: string }
}) {
  if (searchParams.success) {
    return (
      <div className="text-center">
        <div className="mx-auto flex items-center justify-center h-12 w-12 rounded-full bg-green-100">
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
    )
  }

  return (
    <div>
      <div className="text-center">
        <h2 className="text-3xl font-bold tracking-tight">
          Reset your password
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Enter your email address and we'll send you a reset link.
        </p>
      </div>
      <ResetPasswordForm />
    </div>
  )
}
```

**Step 2: Write reset password form**

Create file: `web_frontend/components/auth/reset-password-form.tsx`

```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
import * as z from 'zod'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { requestPasswordReset } from '@/app/(auth)/reset-password/actions'

const resetSchema = z.object({
  email: z.string().email('Invalid email address'),
})

type ResetFormValues = z.infer<typeof resetSchema>

export function ResetPasswordForm() {
  const router = useRouter()
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const form = useForm<ResetFormValues>({
    resolver: zodResolver(resetSchema),
    defaultValues: {
      email: '',
    },
  })

  async function onSubmit(values: ResetFormValues) {
    setLoading(true)
    setError(null)

    const result = await requestPasswordReset(values.email)

    if (result.error) {
      setError(result.error)
      setLoading(false)
    } else {
      router.push('/reset-password?success=true')
    }
  }

  return (
    <div className="mt-8">
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          <FormField
            control={form.control}
            name="email"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Email</FormLabel>
                <FormControl>
                  <Input
                    type="email"
                    placeholder="you@example.com"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {error && (
            <div className="text-sm text-red-600 bg-red-50 p-3 rounded-md">
              {error}
            </div>
          )}

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? 'Sending reset link...' : 'Send reset link'}
          </Button>

          <div className="text-center">
            <a
              href="/login"
              className="text-sm font-medium text-blue-600 hover:text-blue-500"
            >
              Back to login
            </a>
          </div>
        </form>
      </Form>
    </div>
  )
}
```

**Step 3: Write password reset action**

Create file: `web_frontend/app/(auth)/reset-password/actions.ts`

```typescript
'use server'

import { createClient } from '@/lib/supabase/server'

export async function requestPasswordReset(email: string) {
  const supabase = await createClient()

  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${process.env.NEXT_PUBLIC_SITE_URL || 'http://localhost:3000'}/update-password`,
  })

  if (error) {
    return { error: error.message }
  }

  return { success: true }
}
```

**Step 4: Test reset password request**

Run: `npm run dev`

Visit: http://localhost:3000/reset-password

Test:
1. Try submitting empty form → should show validation error
2. Try invalid email → should show email error

Expected: All validations work

Stop server

**Step 5: Commit**

```bash
git add app/\(auth\)/reset-password/ components/auth/reset-password-form.tsx
git commit -m "feat: add password reset request page"
```

---

### Task 12: Create Update Password Page

**Files:**
- Create: `web_frontend/app/(auth)/update-password/page.tsx`
- Create: `web_frontend/app/(auth)/update-password/actions.ts`
- Create: `web_frontend/components/auth/update-password-form.tsx`

**Step 1: Write update password page**

Create file: `web_frontend/app/(auth)/update-password/page.tsx`

```typescript
import { UpdatePasswordForm } from '@/components/auth/update-password-form'

export default function UpdatePasswordPage() {
  return (
    <div>
      <div className="text-center">
        <h2 className="text-3xl font-bold tracking-tight">
          Update your password
        </h2>
        <p className="mt-2 text-sm text-gray-600">
          Enter your new password below.
        </p>
      </div>
      <UpdatePasswordForm />
    </div>
  )
}
```

**Step 2: Write update password form**

Create file: `web_frontend/components/auth/update-password-form.tsx`

```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { zodResolver } from '@hookform/resolvers/zod'
import { useForm } from 'react-hook-form'
import * as z from 'zod'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'
import { updatePassword } from '@/app/(auth)/update-password/actions'

const updatePasswordSchema = z.object({
  password: z.string().min(8, 'Password must be at least 8 characters'),
  confirmPassword: z.string(),
}).refine((data) => data.password === data.confirmPassword, {
  message: "Passwords don't match",
  path: ['confirmPassword'],
})

type UpdatePasswordFormValues = z.infer<typeof updatePasswordSchema>

export function UpdatePasswordForm() {
  const router = useRouter()
  const [error, setError] = useState<string | null>(null)
  const [loading, setLoading] = useState(false)

  const form = useForm<UpdatePasswordFormValues>({
    resolver: zodResolver(updatePasswordSchema),
    defaultValues: {
      password: '',
      confirmPassword: '',
    },
  })

  async function onSubmit(values: UpdatePasswordFormValues) {
    setLoading(true)
    setError(null)

    const result = await updatePassword(values.password)

    if (result.error) {
      setError(result.error)
      setLoading(false)
    } else {
      router.push('/login?success=Password updated successfully')
    }
  }

  return (
    <div className="mt-8">
      <Form {...form}>
        <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-6">
          <FormField
            control={form.control}
            name="password"
            render={({ field }) => (
              <FormItem>
                <FormLabel>New Password</FormLabel>
                <FormControl>
                  <Input
                    type="password"
                    placeholder="••••••••"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          <FormField
            control={form.control}
            name="confirmPassword"
            render={({ field }) => (
              <FormItem>
                <FormLabel>Confirm Password</FormLabel>
                <FormControl>
                  <Input
                    type="password"
                    placeholder="••••••••"
                    {...field}
                  />
                </FormControl>
                <FormMessage />
              </FormItem>
            )}
          />

          {error && (
            <div className="text-sm text-red-600 bg-red-50 p-3 rounded-md">
              {error}
            </div>
          )}

          <Button type="submit" className="w-full" disabled={loading}>
            {loading ? 'Updating password...' : 'Update password'}
          </Button>
        </form>
      </Form>
    </div>
  )
}
```

**Step 3: Write update password action**

Create file: `web_frontend/app/(auth)/update-password/actions.ts`

```typescript
'use server'

import { createClient } from '@/lib/supabase/server'

export async function updatePassword(password: string) {
  const supabase = await createClient()

  const { error } = await supabase.auth.updateUser({
    password: password,
  })

  if (error) {
    return { error: error.message }
  }

  return { success: true }
}
```

**Step 4: Test update password page**

Run: `npm run dev`

Visit: http://localhost:3000/update-password

Test:
1. Try submitting empty form → should show validation errors
2. Try password less than 8 chars → should show error
3. Try mismatched passwords → should show error

Expected: All validations work

Stop server

**Step 5: Commit**

```bash
git add app/\(auth\)/update-password/ components/auth/update-password-form.tsx
git commit -m "feat: add update password page"
```

---

## Phase 6: Protected Pages

### Task 13: Create Protected Route Middleware

**Files:**
- Modify: `web_frontend/middleware.ts`

**Step 1: Update middleware to protect routes**

Replace content in: `web_frontend/middleware.ts`

```typescript
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let response = NextResponse.next({
    request: {
      headers: request.headers,
    },
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) =>
            request.cookies.set(name, value)
          )
          response = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            response.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Refresh session if expired
  const { data: { user } } = await supabase.auth.getUser()

  // Check if accessing protected route
  const isProtectedRoute = request.nextUrl.pathname.startsWith('/profile') ||
                          request.nextUrl.pathname.startsWith('/workouts') ||
                          request.nextUrl.pathname.startsWith('/stats')

  // Redirect to login if not authenticated and trying to access protected route
  if (isProtectedRoute && !user) {
    const redirectUrl = new URL('/login', request.url)
    redirectUrl.searchParams.set('redirect', request.nextUrl.pathname)
    return NextResponse.redirect(redirectUrl)
  }

  // Redirect to profile if authenticated and trying to access auth pages
  const isAuthRoute = request.nextUrl.pathname.startsWith('/login') ||
                     request.nextUrl.pathname.startsWith('/signup')

  if (isAuthRoute && user) {
    return NextResponse.redirect(new URL('/profile', request.url))
  }

  return response
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
```

**Step 2: Verify TypeScript compiles**

Run: `npm run build`

Expected: Build succeeds

**Step 3: Commit**

```bash
git add middleware.ts
git commit -m "feat: add route protection middleware"
```

---

### Task 14: Create Profile Page

**Files:**
- Create: `web_frontend/app/profile/page.tsx`
- Create: `web_frontend/app/profile/actions.ts`
- Create: `web_frontend/components/profile/profile-info.tsx`

**Step 1: Write profile page**

Create file: `web_frontend/app/profile/page.tsx`

```typescript
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { ProfileInfo } from '@/components/profile/profile-info'

export default async function ProfilePage() {
  const supabase = await createClient()

  const { data: { user } } = await supabase.auth.getUser()

  if (!user) {
    redirect('/login')
  }

  // Fetch app_user data
  const { data: appUser } = await supabase
    .from('app_user')
    .select('*')
    .eq('app_user_id', user.id)
    .single()

  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-7xl mx-auto py-12 px-4 sm:px-6 lg:px-8">
        <div className="bg-white shadow rounded-lg">
          <div className="px-4 py-5 sm:p-6">
            <h1 className="text-3xl font-bold text-gray-900 mb-8">
              Profile
            </h1>
            <ProfileInfo user={user} appUser={appUser} />
          </div>
        </div>
      </div>
    </div>
  )
}
```

**Step 2: Write profile info component**

Create file: `web_frontend/components/profile/profile-info.tsx`

```typescript
'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { logout } from '@/app/profile/actions'

interface ProfileInfoProps {
  user: any
  appUser: any
}

export function ProfileInfo({ user, appUser }: ProfileInfoProps) {
  const router = useRouter()
  const [loading, setLoading] = useState(false)

  async function handleLogout() {
    setLoading(true)
    await logout()
    router.push('/login')
  }

  return (
    <div className="space-y-6">
      <div>
        <h3 className="text-lg font-medium text-gray-900 mb-4">
          Account Information
        </h3>
        <dl className="grid grid-cols-1 gap-x-4 gap-y-6 sm:grid-cols-2">
          <div>
            <dt className="text-sm font-medium text-gray-500">Full Name</dt>
            <dd className="mt-1 text-sm text-gray-900">{appUser?.name || 'Not set'}</dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Username</dt>
            <dd className="mt-1 text-sm text-gray-900">{appUser?.username || 'Not set'}</dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Email</dt>
            <dd className="mt-1 text-sm text-gray-900">{user.email}</dd>
          </div>
          <div>
            <dt className="text-sm font-medium text-gray-500">Email Verified</dt>
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

      <div className="pt-5 border-t border-gray-200">
        <Button
          onClick={handleLogout}
          variant="destructive"
          disabled={loading}
        >
          {loading ? 'Logging out...' : 'Log out'}
        </Button>
      </div>
    </div>
  )
}
```

**Step 3: Write logout action**

Create file: `web_frontend/app/profile/actions.ts`

```typescript
'use server'

import { createClient } from '@/lib/supabase/server'

export async function logout() {
  const supabase = await createClient()
  await supabase.auth.signOut()
}
```

**Step 4: Test profile page**

Run: `npm run dev`

Test:
1. Visit http://localhost:3000/profile → should redirect to login
2. Expected: Redirected to /login?redirect=/profile

Stop server

**Step 5: Commit**

```bash
git add app/profile/ components/profile/
git commit -m "feat: add profile page with user information display"
```

---

### Task 15: Create Landing Page

**Files:**
- Modify: `web_frontend/app/page.tsx`
- Modify: `web_frontend/app/layout.tsx`

**Step 1: Update root layout**

Replace content in: `web_frontend/app/layout.tsx`

```typescript
import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'Workout App - Track Your Fitness',
  description: 'Track your workouts and monitor your progress',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}
```

**Step 2: Update landing page**

Replace content in: `web_frontend/app/page.tsx`

```typescript
import { createClient } from '@/lib/supabase/server'
import { redirect } from 'next/navigation'
import { Button } from '@/components/ui/button'

export default async function Home() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()

  // Redirect to profile if already logged in
  if (user) {
    redirect('/profile')
  }

  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="py-20 text-center">
          <h1 className="text-5xl font-bold text-gray-900 mb-6">
            Welcome to Workout App
          </h1>
          <p className="text-xl text-gray-600 mb-12 max-w-2xl mx-auto">
            Track your workouts, monitor your progress, and achieve your fitness goals.
          </p>
          <div className="flex gap-4 justify-center">
            <Button asChild size="lg">
              <a href="/signup">Get Started</a>
            </Button>
            <Button asChild variant="outline" size="lg">
              <a href="/login">Sign In</a>
            </Button>
          </div>
        </div>

        <div className="py-20 grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="text-center">
            <div className="bg-blue-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
              </svg>
            </div>
            <h3 className="text-xl font-semibold mb-2">Track Workouts</h3>
            <p className="text-gray-600">
              Log your exercises, sets, and reps with ease.
            </p>
          </div>

          <div className="text-center">
            <div className="bg-blue-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
              </svg>
            </div>
            <h3 className="text-xl font-semibold mb-2">View Progress</h3>
            <p className="text-gray-600">
              See your strength gains and workout trends over time.
            </p>
          </div>

          <div className="text-center">
            <div className="bg-blue-100 rounded-full w-16 h-16 flex items-center justify-center mx-auto mb-4">
              <svg className="w-8 h-8 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
              </svg>
            </div>
            <h3 className="text-xl font-semibold mb-2">Stay Motivated</h3>
            <p className="text-gray-600">
              Achieve your fitness goals with data-driven insights.
            </p>
          </div>
        </div>
      </div>
    </div>
  )
}
```

**Step 3: Test landing page**

Run: `npm run dev`

Visit: http://localhost:3000

Expected: Landing page displays with signup/login buttons

Stop server

**Step 4: Commit**

```bash
git add app/page.tsx app/layout.tsx
git commit -m "feat: add landing page with feature highlights"
```

---

## Phase 7: Testing & Verification

### Task 16: Manual End-to-End Testing

**No files created - this is a testing task**

**Step 1: Start development server**

Run: `npm run dev`

**Step 2: Test signup flow**

1. Visit http://localhost:3000
2. Click "Get Started"
3. Fill in signup form with test data:
   - Email: test@example.com
   - Username: testuser
   - Name: Test User
   - Password: testpassword123
4. Submit form
5. Expected: Redirected to /verify-email page

**Step 3: Check Supabase for user**

Visit Supabase Dashboard → Authentication → Users

Expected: New user exists with email test@example.com, email_confirmed_at is NULL

**Step 4: Manually verify email in Supabase**

In Supabase Dashboard → Authentication → Users:
1. Click on test@example.com user
2. Set email_confirmed_at to current timestamp
3. Save

**Step 5: Test login flow**

1. Visit http://localhost:3000/login
2. Enter credentials:
   - Email: test@example.com
   - Password: testpassword123
3. Submit form
4. Expected: Redirected to /profile page with user info displayed

**Step 6: Test protected route access**

1. Log out
2. Try visiting http://localhost:3000/profile directly
3. Expected: Redirected to /login?redirect=/profile

**Step 7: Test password reset flow**

1. Visit http://localhost:3000/reset-password
2. Enter email: test@example.com
3. Submit form
4. Expected: Redirected to success page

**Step 8: Check for errors**

Check browser console and terminal for any errors

Expected: No errors

**Step 9: Stop server**

Stop development server with Ctrl+C

**Step 10: Document test results**

Create note of any issues found during testing

---

### Task 17: Add README Documentation

**Files:**
- Create: `web_frontend/README.md`

**Step 1: Write README**

Create file: `web_frontend/README.md`

```markdown
# Workout App - Web Frontend

Next.js 14 web application for user authentication and workout tracking.

## Features

- User signup with email verification
- User login with session management
- Password reset flow
- Protected routes (profile, workouts, stats)
- Server-side rendering with Supabase Auth

## Tech Stack

- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS
- **UI Components:** shadcn/ui
- **Authentication:** Supabase Auth with SSR
- **Deployment:** Vercel

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- Supabase project (local or hosted)

### Installation

1. Install dependencies:

```bash
npm install
```

2. Configure environment variables:

Create `.env.local` file:

```env
NEXT_PUBLIC_SUPABASE_URL=your-supabase-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
```

3. Run development server:

```bash
npm run dev
```

Visit http://localhost:3000

### Build for Production

```bash
npm run build
npm run start
```

## Project Structure

```
web_frontend/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Auth pages (login, signup, etc.)
│   ├── auth/              # Auth callback handler
│   ├── profile/           # Protected profile page
│   └── layout.tsx         # Root layout
├── components/
│   ├── ui/                # shadcn/ui components
│   ├── auth/              # Auth form components
│   └── profile/           # Profile components
├── lib/
│   └── supabase/          # Supabase client utilities
└── middleware.ts          # Auth middleware
```

## Authentication Flow

### Signup

1. User fills signup form (email, username, name, password)
2. Supabase creates auth.users entry
3. Database trigger auto-creates app_user entry
4. Verification email sent
5. User clicks link → email verified
6. User can now log in

### Login

1. User enters email and password
2. Supabase validates credentials
3. Checks email is verified
4. Creates session
5. User redirected to profile

### Password Reset

1. User requests password reset
2. Email sent with reset link
3. User clicks link → redirected to update password page
4. User enters new password
5. Password updated

## Environment Variables

- `NEXT_PUBLIC_SUPABASE_URL` - Your Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Your Supabase anonymous key
- `NEXT_PUBLIC_SITE_URL` (optional) - Your site URL for email redirects (defaults to localhost:3000)

## Deployment

### Vercel

1. Push code to GitHub
2. Import repository in Vercel
3. Configure environment variables
4. Deploy

Vercel will automatically detect Next.js and configure build settings.

## Database Integration

This app integrates with the existing Supabase database:

- **auth.users** - Managed by Supabase Auth
- **app_user** - Auto-created via trigger when user signs up

The database trigger `sync_app_user_from_auth()` automatically creates app_user records when auth.users entries are created, using username and name from `raw_user_meta_data`.

## License

MIT
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README with setup and deployment instructions"
```

---

## Phase 8: Deployment Preparation

### Task 18: Configure for Production

**Files:**
- Modify: `web_frontend/.env.example`
- Create: `web_frontend/vercel.json`

**Step 1: Update .env.example for production**

Replace content in: `web_frontend/.env.example`

```env
# Supabase Configuration
# Get these from your Supabase project settings (Settings > API)
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key

# Site URL for email redirects (set to your production domain)
NEXT_PUBLIC_SITE_URL=https://your-app.vercel.app
```

**Step 2: Create Vercel configuration**

Create file: `web_frontend/vercel.json`

```json
{
  "buildCommand": "npm run build",
  "devCommand": "npm run dev",
  "installCommand": "npm install",
  "framework": "nextjs",
  "regions": ["iad1"]
}
```

**Step 3: Add deployment notes to README**

Add section to `web_frontend/README.md` before License section:

```markdown
## Production Checklist

Before deploying to production:

- [ ] Update `NEXT_PUBLIC_SUPABASE_URL` to production Supabase URL
- [ ] Update `NEXT_PUBLIC_SUPABASE_ANON_KEY` to production anon key
- [ ] Set `NEXT_PUBLIC_SITE_URL` to production domain
- [ ] Configure email templates in Supabase Dashboard
- [ ] Test signup flow with real email
- [ ] Test password reset flow
- [ ] Verify email verification works
- [ ] Enable Supabase RLS policies
```

**Step 4: Commit**

```bash
git add .env.example vercel.json README.md
git commit -m "chore: add production configuration and deployment checklist"
```

---

## Completion & Next Steps

### Task 19: Final Verification and Branch Cleanup

**No files created - this is a verification task**

**Step 1: Run final build**

Run: `npm run build`

Expected: Build succeeds with no errors

**Step 2: Check git status**

Run: `git status`

Expected: Working directory clean

**Step 3: View commit log**

Run: `git log --oneline -10`

Expected: See all commits from this implementation

**Step 4: Push branch**

Run: `git push -u origin feature/web-auth-app`

Expected: Branch pushed to remote

**Step 5: Document what was built**

Phase 1 (MVP) Complete:

✅ Next.js 14 project setup with TypeScript and Tailwind
✅ shadcn/ui component library configured
✅ Supabase client utilities (browser, server, middleware)
✅ Auth middleware for route protection
✅ Signup page with email verification
✅ Login page with session management
✅ Password reset flow (request + update)
✅ Email verification page
✅ Profile page (protected)
✅ Landing page
✅ OAuth callback handler
✅ Production deployment configuration

**Next Steps:**

**Option 1: Create Pull Request**
- Open PR from feature/web-auth-app → master
- Add description of changes
- Request review

**Option 2: Continue with Phase 2 (Workout History)**
- Add workouts list page
- Add session detail view
- Add filtering and sorting

**Option 3: Continue with Phase 3 (Stats & Analytics)**
- Add stats dashboard
- Add progress charts
- Add PR tracking

---

## Summary

This plan provides step-by-step implementation of a Next.js 14 web authentication app integrated with Supabase Auth. Each task is broken down into small, verifiable steps following TDD principles where applicable.

**Total Tasks:** 19
**Estimated Time:** 6-8 hours
**Phase:** Phase 1 (MVP) - Core Authentication

The implementation follows best practices:
- Server-side rendering for SEO and performance
- Type-safe with TypeScript
- Form validation with zod and react-hook-form
- Secure authentication with Supabase SSR
- Protected routes with middleware
- Email verification required
- Responsive design with Tailwind CSS
- Component library with shadcn/ui
