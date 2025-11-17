# GymR8 Deployment Guide

Quick deployment guide with exact commands for deploying Phase 1 and Phase 2.2.1 to Supabase.

## Prerequisites

- Supabase project created at [supabase.com](https://supabase.com)
- Supabase CLI installed: `npm install -g supabase` OR use Supabase Dashboard SQL Editor

## Local Development with Supabase CLI

**Quick Start:**

```bash
# Start local Supabase (includes PostgreSQL, Auth, Storage, etc.)
supabase start

# Apply all migrations (from supabase/migrations/)
supabase db reset

# Run tests
pytest

# Stop Supabase
supabase stop
```

**Migrations are automatically applied** from `supabase/migrations/` directory when you run `supabase db reset`. The migrations are numbered sequentially:

- `20240101000028` - AppUser Auth Migration (Phase 1)
- `20240101000029` - Username Generator (Phase 1)
- `20240101000030` - Auth Trigger (Phase 1)
- `20240101000031` - RLS Performance Updates (Phase 1)
- `20240101000032` - Admin Roles (Phase 2.2.1)
- `20240101000033` - Impersonation Audit (Phase 2.2.1)

**Note:** CI automatically applies these migrations via GitHub Actions.

---

## Phase 1: Core Authentication

### Step 1: Deploy Migrations (Exact Order)

**Via Supabase Dashboard:**

1. Go to **SQL Editor** in your Supabase dashboard
2. Click **New Query**
3. Copy/paste each migration file below **in exact order**
4. Click **Run** for each one
5. Wait for "Success" message before proceeding to next

**Migration Order:**

```bash
# 1. AppUser auth migration
database/025_AppUser_Auth_Migration.sql

# 2. Username generation tables and function
database/026_Auth_Username_Generator.sql

# 3. Auto-profile creation trigger
database/027_Auth_Trigger.sql

# 4. RLS performance updates
database/265_RLS_Performance_Updates.sql
```

### Step 2: Configure Email Authentication

**Supabase Dashboard:**

1. Go to **Authentication** > **Providers** > **Email**
2. Enable **"Confirm email"** toggle (set to ON)
3. Click **Save**

### Step 3: Set Redirect URLs

**Supabase Dashboard:**

1. Go to **Authentication** > **URL Configuration**
2. Add these URLs (adjust for your domain):
   ```
   http://localhost:3000/auth/callback
   https://yourapp.com/auth/callback
   gymr8://auth/callback
   ```
3. Click **Save**

### Step 4: Verify Installation

**Test in SQL Editor:**

```sql
-- Check username word tables populated
SELECT COUNT(*) FROM username_adjectives;  -- Should be 140
SELECT COUNT(*) FROM username_nouns;       -- Should be 182

-- Check trigger exists
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';

-- Check RLS policies
SELECT * FROM debug_rls_performance('app_user');
```

### Step 5: Test Signup Flow

**Using Supabase Dashboard:**

1. Go to **Authentication** > **Users**
2. Click **Add User** > **Create new user**
3. Fill in:
   - Email: `test@example.com`
   - Password: `TestPassword123!`
   - Auto Confirm User: ON (for testing)
4. Click **Create User**
5. Go to **Table Editor** > `app_user` table
6. Verify new row created with:
   - Generated username (e.g., `SwoleRat`, `IronLifter`)
   - Matching email
   - app_user_id matches auth.users ID

---

## Phase 2.2.1: Admin Impersonation

### Step 1: Deploy Admin Migrations

**Via Supabase Dashboard:**

```bash
# 1. Admin roles table and functions
database/030_Admin_Roles.sql

# 2. Impersonation audit table and functions
database/031_Impersonation_Audit.sql
```

### Step 2: Create Initial Admin

**Manual via SQL Editor:**

```sql
-- Replace 'your-user-id-here' with actual user UUID from app_user table
INSERT INTO admin_users (admin_user_id, role, notes)
VALUES (
  'your-user-id-here',  -- Get this from app_user table
  'superadmin',
  'Initial superadmin - created manually'
);
```

**To find your user ID:**

```sql
SELECT app_user_id, username, email FROM app_user WHERE email = 'your@email.com';
```

### Step 3: Verify Admin Functions

**Test in SQL Editor:**

```sql
-- Check admin status
SELECT is_admin('your-user-id-here');  -- Should return true

-- Get admin role
SELECT get_admin_role('your-user-id-here');  -- Should return 'superadmin'

-- List impersonatable users (all non-admin users)
SELECT * FROM list_impersonatable_users();

-- Check active sessions (should be empty initially)
SELECT * FROM get_active_impersonation_sessions();
```

### Step 4: Test Impersonation Logging

**Via SQL Editor:**

```sql
-- Start impersonation (replace UUIDs with real IDs)
SELECT log_impersonation_start(
  'admin-user-id',
  'target-user-id',
  '127.0.0.1'::inet,
  'Testing from SQL Editor'
);

-- View active sessions
SELECT * FROM get_active_impersonation_sessions();

-- End impersonation (replace with actual audit_id from above)
SELECT log_impersonation_end('audit-id-here', 'manual');

-- View audit history
SELECT * FROM recent_impersonation_activity;
```

---

## Production Deployment

### Additional Steps for Production:

1. **Custom SMTP** (see SUPABASE_SETUP.md#3-configure-smtp-production)
   - Configure email provider (SendGrid, Mailgun, AWS SES)
   - Update in **Project Settings** > **Auth** > **SMTP Settings**

2. **Security Checklist:**
   ```sql
   -- Verify RLS enabled on all tables
   SELECT tablename, rowsecurity
   FROM pg_tables
   WHERE schemaname = 'public'
   AND rowsecurity = false;  -- Should return empty

   -- Check RLS performance
   SELECT * FROM debug_rls_performance('app_user');
   SELECT * FROM debug_rls_performance('admin_users');
   SELECT * FROM debug_rls_performance('impersonation_audit');
   ```

3. **Set up Session Timeout Cron** (optional):
   - Go to **Database** > **Extensions**
   - Enable **pg_cron** extension
   - Create cron job:
     ```sql
     SELECT cron.schedule(
       'timeout-impersonation-sessions',
       '*/15 * * * *',  -- Every 15 minutes
       $$ SELECT timeout_expired_impersonation_sessions(); $$
     );
     ```

---

## Rollback Procedures

### Rollback Phase 2.2.1:

```sql
-- Drop admin tables (CASCADE removes dependent objects)
DROP TABLE IF EXISTS impersonation_audit CASCADE;
DROP TABLE IF EXISTS admin_users CASCADE;

-- Drop functions
DROP FUNCTION IF EXISTS is_admin(uuid) CASCADE;
DROP FUNCTION IF EXISTS get_admin_role(uuid) CASCADE;
DROP FUNCTION IF EXISTS can_impersonate_user(uuid, uuid) CASCADE;
DROP FUNCTION IF EXISTS grant_admin_role(uuid, text, text) CASCADE;
DROP FUNCTION IF EXISTS revoke_admin_role(uuid, text) CASCADE;
DROP FUNCTION IF EXISTS log_impersonation_start(uuid, uuid, inet, text, text) CASCADE;
DROP FUNCTION IF EXISTS log_impersonation_end(uuid, text) CASCADE;
DROP FUNCTION IF EXISTS list_impersonatable_users() CASCADE;
DROP FUNCTION IF EXISTS get_active_impersonation_sessions() CASCADE;
DROP FUNCTION IF EXISTS timeout_expired_impersonation_sessions() CASCADE;
DROP FUNCTION IF EXISTS get_impersonation_history(uuid, int) CASCADE;
DROP VIEW IF EXISTS recent_impersonation_activity CASCADE;
```

### Rollback Phase 1:

```sql
-- Disable trigger
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Drop username generation
DROP FUNCTION IF EXISTS generate_unique_username() CASCADE;
DROP TABLE IF EXISTS username_nouns CASCADE;
DROP TABLE IF EXISTS username_adjectives CASCADE;

-- Remove app_user modifications (CAREFUL - this will delete data)
ALTER TABLE app_user DROP CONSTRAINT IF EXISTS app_user_id_fkey;
ALTER TABLE app_user DROP COLUMN IF EXISTS username;
```

---

## Troubleshooting

### Issue: Migration fails with "relation already exists"

**Solution:** Migration already applied or duplicate run. Check if tables exist:

```sql
\dt  -- List tables
```

### Issue: Trigger not firing on signup

**Solution:** Check trigger and function exist:

```sql
SELECT * FROM pg_trigger WHERE tgname = 'on_auth_user_created';
SELECT * FROM pg_proc WHERE proname = 'handle_new_user';
```

### Issue: Username not generated

**Solution:** Check word tables populated:

```sql
SELECT COUNT(*) FROM username_adjectives;  -- Should be 140
SELECT COUNT(*) FROM username_nouns;       -- Should be 182
```

### Issue: Cannot impersonate users

**Solution:** Verify admin status:

```sql
SELECT is_admin(auth.uid());  -- Should return true for admins
SELECT * FROM admin_users WHERE admin_user_id = auth.uid();
```

### Issue: RLS blocking queries

**Solution:** Check policies and current user:

```sql
SELECT auth.uid();  -- Current user ID
SELECT * FROM debug_rls_performance('table_name');
```

---

## Post-Deployment Verification

Run these checks after deployment:

```bash
# Phase 1 checks
✓ Username word tables populated (140 adj, 182 nouns)
✓ Trigger exists on auth.users
✓ Email confirmation enabled
✓ Redirect URLs configured
✓ Test signup creates app_user with generated username

# Phase 2.2.1 checks
✓ Admin tables created (admin_users, impersonation_audit)
✓ At least one superadmin exists
✓ is_admin() returns correct values
✓ list_impersonatable_users() excludes admins
✓ Audit logging functions work
```

---

## Quick Reference

**Key Files:**
- Phase 1 migrations: `database/025-027_*.sql`
- Phase 2.2.1 migrations: `database/030-031_*.sql`
- Setup guide: `SUPABASE_SETUP.md`
- Full auth plan: `SUPABASE_AUTH_INTEGRATION_PLAN.md`
- Admin design: `ADMIN_IMPERSONATION_DESIGN.md`

**Key Functions:**
- `generate_unique_username()` - Auto-generate usernames
- `is_admin(uuid)` - Check admin status
- `list_impersonatable_users()` - Get list for admin UI
- `log_impersonation_start()` - Start impersonation session
- `log_impersonation_end()` - End impersonation session
- `timeout_expired_impersonation_sessions()` - Cleanup (run via cron)

**Supabase Dashboard URLs:**
- Auth: `https://app.supabase.com/project/_/auth/users`
- SQL Editor: `https://app.supabase.com/project/_/sql`
- Table Editor: `https://app.supabase.com/project/_/editor`
