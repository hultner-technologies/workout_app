# Web Authentication App - Design Document

**Created**: 2025-11-17
**Status**: Approved
**Phase**: Phase 1 - MVP Implementation

## Overview

A Next.js web application providing user authentication for the Workout App platform. This app handles login, signup, password reset, and email verification flows using Supabase Auth, with optional workout history and stats views.

## Tech Stack

### Core Framework
- **Next.js 14** with App Router (React Server Components)
- **TypeScript** for type safety
- **Supabase SSR** (@supabase/ssr) for server-side authentication

### UI/Styling
- **shadcn/ui** component library (Radix UI + Tailwind CSS)
- **Tailwind CSS** for styling
- **Responsive design** for mobile and desktop

### Deployment
- **Vercel** for hosting and edge deployment
- **Environment variables** for Supabase connection

## Project Structure

```
web_frontend/
├── app/
│   ├── (auth)/              # Public auth pages
│   │   ├── login/
│   │   │   └── page.tsx
│   │   ├── signup/
│   │   │   └── page.tsx
│   │   ├── reset-password/
│   │   │   └── page.tsx
│   │   └── verify-email/
│   │       └── page.tsx
│   ├── (protected)/         # Requires authentication
│   │   ├── profile/
│   │   │   └── page.tsx
│   │   ├── workouts/        # Phase 2
│   │   │   └── page.tsx
│   │   └── stats/           # Phase 3
│   │       └── page.tsx
│   ├── layout.tsx           # Root layout
│   ├── page.tsx             # Landing page
│   └── api/
│       └── auth/
│           └── callback/    # OAuth callback handler
│               └── route.ts
├── components/
│   ├── ui/                  # shadcn components
│   │   ├── button.tsx
│   │   ├── input.tsx
│   │   ├── form.tsx
│   │   └── ...
│   └── auth/                # Custom auth components
│       ├── login-form.tsx
│       ├── signup-form.tsx
│       └── reset-password-form.tsx
├── lib/
│   ├── supabase/
│   │   ├── client.ts        # Client-side Supabase client
│   │   ├── server.ts        # Server-side Supabase client
│   │   └── middleware.ts    # Middleware helper
│   └── utils.ts             # Utility functions
├── middleware.ts            # Auth middleware (route protection)
├── next.config.js
├── tailwind.config.ts
├── tsconfig.json
└── package.json
```

## Authentication Flows

### 1. Signup Flow
1. User visits `/signup`
2. Fills in form: email, password, username, name
3. Supabase creates auth.users entry
4. Trigger auto-creates app_user entry (via database trigger)
5. Sends verification email
6. User redirected to `/verify-email` with instructions
7. User clicks link in email → email confirmed
8. User can now log in

**Email Verification**: Required before login. Users must confirm email before accessing protected pages.

### 2. Login Flow
1. User visits `/login`
2. Enters email and password
3. Supabase validates credentials
4. Checks email_confirmed_at (must be verified)
5. Creates session, sets cookies
6. Redirects to `/profile` or intended page

**Session Management**: Server-side sessions using Supabase cookies, validated on each request.

### 3. Password Reset Flow
1. User clicks "Forgot Password?" on login page
2. Visits `/reset-password`
3. Enters email address
4. Supabase sends reset email
5. User clicks link → redirected to reset page with token
6. User enters new password
7. Password updated, redirected to `/login`

### 4. Protected Page Access
1. User attempts to visit protected page (e.g., `/profile`)
2. Middleware checks for valid session
3. If no session → redirect to `/login?redirect=/profile`
4. If session valid → allow access
5. Page loads with server-side user data

## Pages and Features

### Phase 1: MVP (Core Auth)

#### Landing Page (`/`)
- Hero section introducing the app
- Links to login and signup
- Public, no auth required

#### Login Page (`/login`)
- Email/password form
- "Forgot password?" link
- Link to signup page
- Error handling for invalid credentials
- Redirect parameter support

#### Signup Page (`/signup`)
- Email, password, username, name fields
- Password strength indicator
- Terms of service checkbox
- Error handling for existing users
- Success → redirect to verify-email

#### Verify Email Page (`/verify-email`)
- Instructions for checking email
- Resend verification email button
- Link back to login

#### Reset Password Page (`/reset-password`)
- Email input form (step 1)
- New password form (step 2, after email link clicked)
- Confirmation message
- Link back to login

#### Profile Page (`/profile`) - Protected
- Display user info (name, username, email)
- Edit profile form
- Change password option
- Logout button

### Phase 2: Enhancement (Workout History)

#### Workouts Page (`/workouts`) - Protected
- List of user's performed sessions
- Sortable by date
- Filter by exercise or plan
- View session details (sets, reps, weights)
- Link to stats page

### Phase 3: Polish (Stats & Analytics)

#### Stats Page (`/stats`) - Protected
- Dashboard with workout statistics
- Charts showing progress over time
- PR (personal record) tracking
- Volume calculations
- Exercise frequency analysis

## Authentication Middleware

**File**: `middleware.ts`

**Purpose**: Protect routes and manage auth state

**Logic**:
1. Check if route is protected (starts with `/(protected)/`)
2. Get session from Supabase using SSR
3. If no session and route protected → redirect to `/login?redirect=<current-path>`
4. If session valid → allow request
5. Refresh session if needed

**Protected Routes**: All routes under `/(protected)/` directory

**Public Routes**: `/(auth)/`, `/`, and static assets

## Database Integration

### Tables Used
- **auth.users**: Managed by Supabase Auth
- **app_user**: Auto-created via trigger when auth.users entry created
- **performed_session**: User's workout history (Phase 2)
- **exercise**: Exercise definitions (Phase 2)

### Trigger Integration
- `sync_app_user_from_auth()`: Auto-creates app_user when signup occurs
- Username from `raw_user_meta_data->>'username'`
- Name from `raw_user_meta_data->>'name'`

## Phased Implementation

### Phase 1: MVP (Week 1)
**Goal**: Core authentication working end-to-end

**Deliverables**:
- Project setup (Next.js, shadcn/ui, Supabase)
- Auth pages (login, signup, reset-password, verify-email)
- Profile page
- Middleware for route protection
- Deployment to Vercel

**Success Criteria**:
- User can sign up, verify email, and log in
- User can reset password
- Protected pages require authentication
- Session persists across page reloads

### Phase 2: Enhancement (Week 2)
**Goal**: Add workout history viewing

**Deliverables**:
- Workouts page with session list
- Session detail view
- Filtering and sorting
- Link to stats page

**Success Criteria**:
- User can view their workout history
- Sessions display correctly with sets/reps/weights
- Filtering by exercise works

### Phase 3: Polish (Week 3)
**Goal**: Add analytics and charts

**Deliverables**:
- Stats dashboard
- Progress charts (recharts or similar)
- PR tracking
- Volume calculations

**Success Criteria**:
- Charts display workout trends
- PRs calculated correctly
- Volume metrics accurate

## Environment Variables

**Required**:
```env
NEXT_PUBLIC_SUPABASE_URL=<your-supabase-url>
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
```

**Deployment**: Set in Vercel project settings

## Testing Strategy

### Unit Tests
- Form validation logic
- Utility functions
- Component rendering

### Integration Tests
- Auth flow end-to-end (signup → verify → login)
- Password reset flow
- Protected route access control

### Manual Testing
- Cross-browser compatibility (Chrome, Safari, Firefox)
- Mobile responsiveness
- Error state handling

## Security Considerations

1. **Email Verification Required**: Users must verify email before login
2. **Server-Side Session Validation**: All protected pages check session server-side
3. **HTTPS Only**: Enforced in production (Vercel default)
4. **Password Strength**: Supabase enforces minimum requirements
5. **Rate Limiting**: Consider adding for signup/login endpoints
6. **CSRF Protection**: Next.js built-in via SameSite cookies

## Open Questions

1. **Social Login**: Do we want OAuth providers (Google, GitHub)?
   - Decision: Not in MVP, revisit in Phase 2

2. **Username Validation**: Should usernames be case-sensitive?
   - Decision: Use existing database constraints (lowercase, alphanumeric + underscore)

3. **Profile Photos**: Do we need avatar upload?
   - Decision: Not in MVP, use initials or default icon

## Success Metrics

- **Phase 1**: User can complete full auth flow (signup → verify → login → access profile)
- **Phase 2**: User can view workout history with filtering
- **Phase 3**: User can see progress charts and PRs

## Future Enhancements (Post-MVP)

- Social login (OAuth)
- Two-factor authentication
- Profile photo upload
- Workout creation/editing (currently mobile-only)
- Sharing workouts with friends
- Public workout profiles
