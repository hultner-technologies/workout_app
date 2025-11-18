# Password Reset Flow - Handoff Documentation

## Current Status: PARTIALLY WORKING

The password reset redirect URL issue is **FIXED**, but session persistence after callback is **STILL BROKEN**.

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

## Success Criteria
User completes full flow: reset request → email link → update password form → submit → login with new password
