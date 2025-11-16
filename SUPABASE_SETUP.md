# Supabase Setup Guide

Quick setup guide for deploying the GymR8 authentication system.

## Prerequisites

- Supabase project created at [supabase.com](https://supabase.com)
- Database migrations ready in `/database/` directory

## 1. Deploy Database Migrations

Run migrations in order:

```bash
# Connect to your Supabase project
# Dashboard > Project Settings > Database > Connection string

# Run migrations in SQL Editor or via CLI
025_AppUser_Auth_Migration.sql
026_Auth_Username_Generator.sql
027_Auth_Trigger.sql
265_RLS_Performance_Updates.sql
```

**Via Supabase Dashboard:**
1. Go to SQL Editor
2. Create new query
3. Copy/paste each migration file
4. Run in order

**Via Supabase CLI:**
```bash
supabase db push
```

## 2. Configure Email Authentication

### Enable Email Confirmation

**Dashboard Steps:**
1. Go to **Authentication** > **Providers** > **Email**
2. Enable "Confirm email"
3. Set "Confirm email" to **ON**

[📖 Email Auth Docs](https://supabase.com/docs/guides/auth/auth-email)

### Customize Email Templates (Optional)

**Dashboard Steps:**
1. Go to **Authentication** > **Email Templates**
2. Edit templates:
   - **Confirm signup** - Welcome email with confirmation link
   - **Magic Link** - Passwordless login
   - **Change Email Address** - Email change confirmation
   - **Reset Password** - Password reset link

Available templates use Go templating:
- `{{ .ConfirmationURL }}` - Email confirmation link
- `{{ .Token }}` - OTP code
- `{{ .SiteURL }}` - Your app URL

[📖 Email Templates Docs](https://supabase.com/docs/guides/auth/auth-email-templates)

### Set Redirect URLs

**Dashboard Steps:**
1. Go to **Authentication** > **URL Configuration**
2. Add redirect URLs for your app:
   - Development: `http://localhost:3000/auth/callback`
   - Production: `https://yourapp.com/auth/callback`
   - Mobile: `gymr8://auth/callback` (deep link)

[📖 Redirect URLs Docs](https://supabase.com/docs/guides/auth/redirect-urls)

## 3. Configure SMTP (Production)

**Free Tier Limits:**
- 3-4 emails per hour per user
- Sufficient for testing only

**Production Setup:**
1. Go to **Project Settings** > **Auth** > **SMTP Settings**
2. Enable custom SMTP
3. Configure your email provider:
   - **SendGrid** (100 emails/day free)
   - **Mailgun** (5,000 emails/month free)
   - **AWS SES** (62,000 emails/month free)
   - **Postmark** (100 emails/month free)

[📖 Custom SMTP Docs](https://supabase.com/docs/guides/auth/auth-smtp)

## 4. Test Authentication Flow

### Test Signup

```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/auth/v1/signup' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "secure-password",
    "data": {
      "name": "Test User",
      "username": "testuser"
    }
  }'
```

### Verify Database

Check that `app_user` was created:

```sql
SELECT app_user_id, username, email, name
FROM app_user
WHERE email = 'test@example.com';
```

### Test Username Generation

Signup without username to test auto-generation:

```bash
curl -X POST 'https://YOUR_PROJECT.supabase.co/auth/v1/signup' \
  -H "apikey: YOUR_ANON_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "autouser@example.com",
    "password": "secure-password"
  }'
```

Check for GymR8-style username:

```sql
SELECT username FROM app_user WHERE email = 'autouser@example.com';
-- Should return something like: SwoleRat, IronLifter, BuffBarbell
```

## 5. Security Checklist

- [ ] Enable RLS on all tables (already done in migrations)
- [ ] Verify service role key is never exposed to client
- [ ] Test that users can only access their own data
- [ ] Enable email confirmation in production
- [ ] Configure custom SMTP for production
- [ ] Set up proper redirect URLs
- [ ] Test password reset flow
- [ ] Review RLS policies with `debug_rls_performance()`

```sql
-- Verify RLS performance optimization
SELECT * FROM debug_rls_performance('app_user');
SELECT * FROM debug_rls_performance('performed_session');
```

## 6. Frontend Integration

See `SUPABASE_AUTH_INTEGRATION_PLAN.md` section 1.5 for React Native code examples.

Quick example:

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://YOUR_PROJECT.supabase.co',
  'YOUR_ANON_KEY'
)

// Signup
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    data: {
      name: 'John Doe',
      username: 'johndoe'  // Optional - auto-generated if omitted
    }
  }
})
```

## Useful Links

- [Supabase Dashboard](https://app.supabase.com)
- [Auth Docs](https://supabase.com/docs/guides/auth)
- [RLS Docs](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Email Auth](https://supabase.com/docs/guides/auth/auth-email)
- [Custom SMTP](https://supabase.com/docs/guides/auth/auth-smtp)
- [Redirect URLs](https://supabase.com/docs/guides/auth/redirect-urls)
- [JS Client Docs](https://supabase.com/docs/reference/javascript/introduction)

## Troubleshooting

### Email not sending
- Check SMTP settings (free tier has strict rate limits)
- Verify email templates are configured
- Check spam folder
- Review logs in Dashboard > Logs

### Trigger not creating app_user
```sql
-- Check if trigger exists
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- Check if function exists
SELECT * FROM pg_proc WHERE proname = 'handle_new_user';

-- Test trigger manually
SELECT handle_new_user();
```

### Username collisions
```sql
-- Check for duplicate usernames
SELECT username, COUNT(*)
FROM app_user
GROUP BY username
HAVING COUNT(*) > 1;

-- Check word list counts
SELECT COUNT(*) FROM username_adjectives;  -- Should be 140
SELECT COUNT(*) FROM username_nouns;       -- Should be 182
```

### RLS blocking legitimate access
```sql
-- Check current user
SELECT auth.uid();

-- Test RLS policy
SELECT * FROM app_user WHERE app_user_id = auth.uid();
```
