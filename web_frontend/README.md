# GymR8 - Web Frontend

Next.js 14 web application that powers the GymR8 authentication and analytics experience.

## Features

**Phase 1: Core Authentication**
- User signup with Supabase email verification
- Email/password login with session management
- Password reset with magic links
- Protected routes with middleware
- Profile page with user information
- Dark mode support for all auth pages

**Phase 2: Workout History**
- View all workout sessions with filtering and sorting
- Search workouts by name or notes
- Detailed workout view with exercise breakdown
- Sets, reps, and weights display
- Weight conversion (grams to kg)
- Duration calculations

**Phase 3: Stats & Analytics**
- Workout frequency chart (last 3 months)
- Volume progress tracking over time
- Personal records (PR) for each exercise
- Total workouts, exercises, and volume metrics
- Interactive charts using Recharts
- Server-side data aggregation

## Tech Stack

- **Framework:** Next.js 14 (App Router)
- **Language:** TypeScript
- **Styling:** Tailwind CSS with shadcn/ui components
- **Authentication:** Supabase Auth + @supabase/ssr
- **Charts:** Recharts for data visualization
- **Date Handling:** date-fns for formatting and calculations
- **Forms:** React Hook Form + Zod validation
- **Deployment:** Vercel

## Getting Started

### Prerequisites

- Node.js 18+
- npm (comes with Node)
- Supabase project (local or hosted)

### Installation

1. Install dependencies:

   ```bash
   npm install
   ```

2. Copy `.env.example` to `.env.local` and update with your Supabase details:

   ```env
   NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
   NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
   NEXT_PUBLIC_SITE_URL=http://localhost:3000
   ```

3. Start the dev server:

   ```bash
   npm run dev
   ```

   Visit http://localhost:3000 to view the app.

### Build for Production

```bash
npm run build
npm run start
```

## Project Structure

```
web_frontend/
├── app/
│   ├── (auth)/           # Public auth pages (login, signup, etc.)
│   ├── auth/callback/    # OAuth/email callbacks
│   ├── profile/          # Protected profile page
│   ├── workouts/         # Workout history pages
│   │   ├── [id]/         # Individual workout detail
│   │   └── page.tsx      # Workout list
│   ├── stats/            # Statistics dashboard
│   ├── layout.tsx        # Root layout
│   └── page.tsx          # Landing page
├── components/
│   ├── auth/             # Auth form components
│   ├── profile/          # Profile UI
│   ├── workouts/         # Workout components
│   │   ├── workout-list.tsx
│   │   └── workout-detail.tsx
│   ├── stats/            # Stats components
│   │   ├── stats-dashboard.tsx
│   │   ├── workout-frequency-chart.tsx
│   │   ├── volume-progress-chart.tsx
│   │   └── personal-records.tsx
│   └── ui/               # shadcn/ui primitives
├── lib/
│   ├── supabase/         # Supabase client helpers
│   └── utils.ts          # Utility functions
├── middleware.ts         # Session refresh + route protection
└── tailwind.config.ts
```

## Authentication Flow

### Signup

1. User completes signup form (email, username, name, password).
2. Supabase creates `auth.users` entry and sends verification email.
3. Database trigger `sync_app_user_from_auth()` creates `app_user` row.
4. User verifies email and gains access to protected routes.

### Login

1. User enters email/password.
2. Supabase validates credentials and sets auth cookies.
3. Middleware refreshes sessions and redirects to `/profile`.

### Password Reset

1. User submits reset request.
2. Supabase emails a reset link pointing to `/update-password`.
3. User sets a new password and is redirected to login.

## Environment Variables

- `NEXT_PUBLIC_SUPABASE_URL` – Supabase project URL.
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` – Supabase anon key.
- `NEXT_PUBLIC_SITE_URL` – Base site URL for Supabase email redirects.

## Deployment

### Vercel

1. Push the branch to GitHub.
2. Import the repo in Vercel and select this project root.
3. Set the environment variables above.
4. Deploy – Vercel auto-detects Next.js.

## Production Checklist

Before deploying:

- [ ] Update `NEXT_PUBLIC_SUPABASE_URL` to production Supabase URL
- [ ] Update `NEXT_PUBLIC_SUPABASE_ANON_KEY` to production anon key
- [ ] Set `NEXT_PUBLIC_SITE_URL` to production domain (e.g., `https://app.example.com`)
- [ ] Configure Supabase email templates (verification, password reset)
- [ ] Test signup + verification end-to-end with real email
- [ ] Test password reset flow
- [ ] Test workout history with sample data
- [ ] Test stats dashboard with varied data
- [ ] Verify all charts render correctly
- [ ] Ensure Supabase RLS policies are enabled
- [ ] Set up proper error monitoring (e.g., Sentry)
- [ ] Configure security headers (CSP, X-Frame-Options, etc.)
- [ ] Test dark mode across all pages
- [ ] Verify mobile responsiveness

## License

MIT
