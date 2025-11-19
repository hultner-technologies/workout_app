# Password Reset Flow - Handoff Documentation

## Current Status: WILL BE REPLACED WITH OTP APPROACH

The magic link password reset flow has session persistence issues. **Decision: Implement OTP-based password reset instead.**

### Why OTP Instead of Magic Links?
- Web app is in a separate repository from mobile app
- Magic link session persistence bugs are complex to debug
- OTP provides better UX for web-only flow
- User confirmed: "for all intents and purposes of this app and repo we only support otp"

---

## Previous Magic Link Issues (For Reference)

## What Works ✅
1. Password reset request successfully generates recovery token
2. Email link now has correct URL with `/auth/callback?type=recovery&next=/update-password`
3. User is redirected to `/update-password` page after clicking link
4. `/update-password` page loads and displays form

## What's Broken ❌
**Session cookies from `exchangeCodeForSession` are not persisting after redirect**

Error: `Auth session missing! Auth session missing!`

## Root Cause
Session created in `/app/auth/callback/route.ts` is not available in Server Action at `/app/(auth)/update-password/actions.ts`. Cookies are being set on response but not persisting.

## Key Files Modified

1. **`/supabase/migrations/20251118000036_Fix_Auth_Null_Tokens.sql`** - Migration to fix NULL tokens (needs production deployment)
2. **`.env.local`** - Changed NEXT_PUBLIC_SITE_URL to `http://127.0.0.1:3000`
3. **`/app/(auth)/reset-password/actions.ts`** - Fixed redirectTo URL (WORKING ✅)
4. **`/app/auth/callback/route.ts`** - Session cookie handling (BROKEN ❌)
5. **`/middleware.ts`** - Allow `/update-password` for authenticated users (WORKING ✅)
6. **`/supabase/config.toml`** - Added callback URLs to whitelist

## Next Steps

**Primary Task:** Fix session cookie persistence in callback route

**Debugging Commands:**
```bash
# Run E2E test
npx playwright test --grep "should complete password reset flow" --reporter=line

# Check session in database after callback
docker exec supabase_db_workout_app psql -U postgres -c "SELECT * FROM auth.sessions ORDER BY created_at DESC LIMIT 1"

# Manual test
# 1. http://127.0.0.1:3000/reset-password
# 2. Email: ahultner@gmail.com
# 3. Check Inbucket: http://127.0.0.1:54324
# 4. Click link (within 60s!)
```

**References:**
- Supabase SSR: https://supabase.com/docs/guides/auth/server-side/nextjs
- Related issue: https://github.com/supabase/auth-helpers/issues/712

## Environment
- App: http://127.0.0.1:3000
- Supabase: http://127.0.0.1:54321  
- Inbucket: http://127.0.0.1:54324
- Working dir: `.worktrees/web-auth-app/web_frontend`

## Success Criteria (Magic Link - DEPRECATED)
User completes full flow: reset request → email link → update password form → submit → login with new password

---

## OTP Implementation Plan (NEW APPROACH)

### What Needs to Be Built

1. **Request Password Reset Page** (`/reset-password`)
   - [x] Email input form (already exists)
   - [ ] Update to use Supabase OTP API instead of magic link

2. **OTP Entry Page** (`/verify-otp`)
   - [ ] Create new page for OTP code entry
   - [ ] 6-digit code input field
   - [ ] Timer showing code expiration (60 seconds)
   - [ ] Resend code button
   - [ ] Verify OTP and update password in single flow

3. **Supabase Configuration**
   - [ ] Configure email template for OTP codes
   - [ ] Set OTP expiration time (60 seconds recommended)
   - [ ] Update email redirects (if needed)

### User Flow (OTP)
1. User visits `/reset-password`
2. User enters email and submits
3. Backend calls `supabase.auth.resetPasswordForEmail({ email, options: { channel: 'email', shouldCreateUser: false } })`
4. User receives email with 6-digit OTP code
5. User is redirected to `/verify-otp?email=<email>`
6. User enters OTP code
7. On valid OTP: show new password form on same page
8. User enters new password and submits
9. Backend calls `supabase.auth.verifyOtp({ email, token, type: 'recovery' })` then `supabase.auth.updateUser({ password })`
10. User is logged in and redirected to `/profile`

### Technical Notes
- Supabase OTP API: https://supabase.com/docs/reference/javascript/auth-verifyotp
- OTP codes are 6 digits, expire in 60 seconds by default
- No session persistence issues (verification happens in same request)
- Better UX for web-only applications

### Files to Create/Modify
- `/app/(auth)/verify-otp/page.tsx` - New OTP entry page
- `/app/(auth)/verify-otp/actions.ts` - Server action for OTP verification
- `/app/(auth)/reset-password/actions.ts` - Update to use OTP API
- `/components/auth/verify-otp-form.tsx` - OTP input form component

### Success Criteria (OTP)
User completes full flow: email entry → OTP code → new password → logged in
