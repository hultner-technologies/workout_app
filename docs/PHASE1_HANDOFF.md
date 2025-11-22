# Password Reset Flow - Web App

## Current Status: MAGIC LINKS WORKING

The web app uses **magic link** password reset flow, which is working correctly.

### Multi-Platform Strategy
- **Web app (this repo):** Magic links via email
- **React Native app (separate repo):** OTP codes via email
- **Email template:** Contains both magic link AND OTP code to support both platforms

---

## Web App Flow (Magic Links)

### What Works ✅
1. Password reset request successfully generates recovery token
2. Email link has correct URL with `/auth/callback?type=recovery&next=/update-password`
3. User clicks link and is redirected to `/update-password` page
4. User enters new password and submits
5. Password is updated successfully

### Implementation Files
- `/app/(auth)/reset-password/page.tsx` - Email input form
- `/app/(auth)/reset-password/actions.ts` - Sends reset email
- `/app/auth/callback/route.ts` - Handles magic link callback
- `/app/(auth)/update-password/page.tsx` - New password form
- `/app/(auth)/update-password/actions.ts` - Updates password

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

---

## Notes for React Native App

The React Native app (separate repository) will use OTP codes instead of magic links. The Supabase email template should include **both**:
- Magic link URL (for web app)
- OTP code (for mobile app)

This allows both platforms to use the same password reset email endpoint while supporting their respective auth flows.
