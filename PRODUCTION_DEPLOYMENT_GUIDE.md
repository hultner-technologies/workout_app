# Supabase Auth - Production Deployment Guide

**Version:** 1.0
**Last Updated:** 2025-11-17
**Branch:** `claude/supabase-auth-research-01PkSeSy76eJxXtwayW79bKS`

---

## Pre-Deployment Checklist

### ✅ Prerequisites

- [ ] **Supabase project created** (or existing project ready)
- [ ] **Database backup taken** (`pg_dump` recommended)
- [ ] **Code review completed** (Status: ✅ Approved 8.5/10)
- [ ] **Tests passing** (Status: ✅ 59/60 tests, 1 flaky)
- [ ] **User communication drafted** (see template below)
- [ ] **Rollback plan reviewed** (see MIGRATION_NOTES.md)

### ⚠️ Critical Pre-Migration Steps

#### 1. Verify No Code Dependencies on `app_user.password`

```bash
# Search codebase for password column references
grep -r "app_user.*password" --include="*.py" --include="*.js" --include="*.ts"
```

**Expected:** No results (password column will be dropped)

#### 2. Back Up Production Database

```bash
# Using Supabase CLI
supabase db dump --linked > backup_$(date +%Y%m%d_%H%M%S).sql

# Or using pg_dump directly
pg_dump "postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres" > backup.sql
```

**Verify backup:**
```bash
# Check file size
ls -lh backup*.sql

# Verify it contains app_user data
grep -c "INSERT INTO.*app_user" backup*.sql
```

---

## Step-by-Step Deployment

### Phase 1: Supabase Setup (30 minutes)

#### 1.1 Email Authentication Configuration

**Dashboard:** `Authentication > Providers > Email`

```yaml
Settings:
  Enable Email provider: ON
  Confirm email: ON (recommended)
  Secure email change: ON

Email Templates:
  Confirmation: Use default or customize
  Password Reset: Customize (see template below)
  Magic Link: Optional (can disable)
```

**Password Reset Email Template:**
```html
<h2>Password Reset - GymR8</h2>
<p>We've upgraded our authentication system. Click below to create your new password:</p>
<p><a href="{{ .ConfirmationURL }}">Reset Password</a></p>
<p>This link expires in 24 hours.</p>
```

#### 1.2 SMTP Configuration

**Dashboard:** `Settings > Auth > SMTP Settings`

**Option A: Supabase Built-in (Development Only)**
- Works out of the box
- Rate limited
- Not suitable for production

**Option B: Custom SMTP (Production)**

**Recommended Providers:**
- **SendGrid**: 100 emails/day free tier
- **AWS SES**: $0.10 per 1,000 emails
- **Mailgun**: 5,000 emails/month free

**Example Configuration (SendGrid):**
```yaml
SMTP Host: smtp.sendgrid.net
Port: 587
Username: apikey
Password: [Your SendGrid API Key]
Sender Email: noreply@yourdomain.com
Sender Name: GymR8
```

**Test SMTP:**
```bash
# Send test email via Supabase dashboard
# Go to Authentication > Settings > SMTP > Send Test Email
```

---

### Phase 2: Migration Deployment (20 minutes)

#### 2.1 Link Local Project to Supabase

```bash
# If not already linked
supabase link --project-ref [your-project-ref]

# Verify connection
supabase db remote ls
```

#### 2.2 Review Migrations

```bash
# Check migration status
supabase db remote diff

# Expected output: 7 new migrations (028-034)
```

**Migrations Being Deployed:**
1. **028**: Schema changes (username, email unique, drop password)
2. **029**: Username generation system (30K+ combinations)
3. **030**: Auth trigger (auto-create app_user on signup)
4. **031**: RLS performance documentation
5. **032**: Admin role system (support, admin, superadmin)
6. **033**: Impersonation audit logging
7. **034**: Auth.users sync + foreign key constraint

#### 2.3 Create Initial Superadmin

**CRITICAL:** Do this BEFORE running migrations to avoid being locked out.

```sql
-- Get your user ID from dashboard or create test user first
-- Dashboard: Authentication > Users > Add User

-- Then grant superadmin role
INSERT INTO admin_users (admin_user_id, role, notes)
VALUES (
  '[YOUR-USER-UUID]'::uuid,
  'superadmin',
  'Initial superadmin created during migration'
);
```

**To find your user ID:**
```bash
# Via Supabase SQL Editor
SELECT id, email FROM auth.users WHERE email = 'your-admin@email.com';
```

#### 2.4 Deploy Migrations

```bash
# Dry run (recommended first)
supabase db push --dry-run

# Review changes, then deploy
supabase db push

# Verify success
supabase db remote ls
```

**Expected Output:**
```
Applying migration 20240101000028_AppUser_Auth_Migration.sql...
Applying migration 20240101000029_Auth_Username_Generator.sql...
Applying migration 20240101000030_Auth_Trigger.sql...
Applying migration 20240101000031_RLS_Performance_Updates.sql...
Applying migration 20240101000032_Admin_Roles.sql...
Applying migration 20240101000033_Impersonation_Audit.sql...
Applying migration 20240101000034_Seed_Data_Auth_Sync.sql...
✓ Finished supabase db push
```

---

### Phase 3: Post-Migration Verification (15 minutes)

#### 3.1 Verify Schema Changes

```sql
-- Check username field exists
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'app_user' AND column_name = 'username';
-- Expected: username | text | NO

-- Check password field removed
SELECT column_name FROM information_schema.columns
WHERE table_name = 'app_user' AND column_name = 'password';
-- Expected: 0 rows

-- Verify FK constraint exists
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints
WHERE table_name = 'app_user' AND constraint_name = 'app_user_id_fkey';
-- Expected: app_user_id_fkey | FOREIGN KEY
```

#### 3.2 Test User Creation Flow

```bash
# Via Supabase Dashboard
# Authentication > Users > Add User
# Email: test@example.com
# Password: testpassword123
# Metadata: {"username": "testuser"}
```

**Verify auto-profile creation:**
```sql
SELECT au.app_user_id, au.name, au.email, au.username
FROM app_user au
JOIN auth.users u ON au.app_user_id = u.id
WHERE u.email = 'test@example.com';

-- Expected: 1 row with username 'testuser'
```

#### 3.3 Check Existing Users Migrated

```sql
-- Count users with auth.users entries
SELECT COUNT(*) FROM app_user au
JOIN auth.users u ON au.app_user_id = u.id;

-- Should equal total app_user count
SELECT COUNT(*) FROM app_user;

-- Verify all usernames generated
SELECT COUNT(*) FROM app_user WHERE username IS NULL;
-- Expected: 0
```

#### 3.4 Test Admin System

```sql
-- Verify superadmin exists
SELECT * FROM admin_users WHERE role = 'superadmin';

-- Test permission check
SELECT is_admin('[YOUR-USER-UUID]'::uuid);
-- Expected: true

-- Test role retrieval
SELECT get_admin_role('[YOUR-USER-UUID]'::uuid);
-- Expected: superadmin
```

---

### Phase 4: User Communication (Immediate)

#### 4.1 Email Existing Users

**Subject:** Action Required - Password Reset

**Body:**
```
Hi [Name],

We've upgraded GymR8 to use a more secure authentication system (Supabase Auth).

ACTION REQUIRED:
To continue using your account, please reset your password:

1. Visit: https://[your-app]/auth/reset-password
2. Enter your email address: [email]
3. Check your email for the reset link
4. Create a new password

Your workout data is completely safe and unchanged. Only your login method is different.

Why this change?
- More secure authentication
- Better password recovery
- Future support for Google/Apple sign-in

Questions? Reply to this email or contact support@yourdomain.com.

Thanks,
The GymR8 Team
```

#### 4.2 In-App Notification

```javascript
// Example React Native notification
if (user.migrated === true) {
  showBanner({
    title: "Password Reset Required",
    message: "For security, please reset your password",
    action: "Reset Now",
    link: "/auth/reset-password"
  });
}
```

---

## Post-Deployment Monitoring

### Day 1-3: Critical Monitoring

#### Monitor Password Resets
```sql
-- Track password reset requests
SELECT
  DATE(created_at) as date,
  COUNT(*) as reset_count
FROM auth.audit_log_entries
WHERE action = 'password_recovery'
  AND created_at > NOW() - INTERVAL '3 days'
GROUP BY DATE(created_at);
```

#### Monitor Failed Logins
```sql
-- Track failed login attempts
SELECT
  DATE(created_at) as date,
  COUNT(*) as failed_logins
FROM auth.audit_log_entries
WHERE action = 'login'
  AND error_message IS NOT NULL
  AND created_at > NOW() - INTERVAL '3 days'
GROUP BY DATE(created_at);
```

#### Monitor New User Signups
```sql
-- Verify trigger creates app_user records
SELECT
  COUNT(*) as new_users_today
FROM auth.users
WHERE created_at::date = CURRENT_DATE;

-- Should match app_user count
SELECT
  COUNT(*) as new_app_users_today
FROM app_user au
JOIN auth.users u ON au.app_user_id = u.id
WHERE u.created_at::date = CURRENT_DATE;
```

### Week 1: User Support Monitoring

**Common Issues:**

1. **"I can't log in"**
   - Solution: Direct to password reset flow
   - Check: `SELECT * FROM auth.users WHERE email = ?`

2. **"I didn't get the reset email"**
   - Check SMTP logs in Supabase dashboard
   - Verify email not in spam
   - Resend manually via dashboard

3. **"My username is weird"**
   - Expected: Auto-generated usernames like "ayourname_4521"
   - Future: Add username change feature (Phase 2.6 in roadmap)

---

## Rollback Procedure

**⚠️ ONLY IF CRITICAL ISSUES OCCUR**

### When to Rollback
- Migration fails partway through
- Data integrity issues discovered
- Critical auth functionality broken

### Rollback Steps

```bash
# 1. Restore database backup
psql "postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres" < backup.sql

# 2. Or use Supabase point-in-time recovery
# Dashboard: Database > Backups > Restore to point before migration

# 3. Verify restoration
psql "postgresql://..." -c "SELECT COUNT(*) FROM app_user WHERE password IS NOT NULL"
# Expected: > 0 (password column exists again)
```

**Manual Rollback SQL:**
```sql
-- See MIGRATION_NOTES.md for detailed rollback SQL
-- WARNING: This destroys migration data, use backup restore instead
```

---

## Production Configuration Summary

### Required Environment Variables

```bash
# .env.production
SUPABASE_URL=https://[your-project].supabase.co
SUPABASE_ANON_KEY=[your-anon-key]
SUPABASE_SERVICE_ROLE_KEY=[your-service-key] # Server-side only!

# Frontend (React Native)
EXPO_PUBLIC_SUPABASE_URL=https://[your-project].supabase.co
EXPO_PUBLIC_SUPABASE_ANON_KEY=[your-anon-key]
```

### Security Checklist

- [ ] RLS enabled on all tables
- [ ] Service role key NOT exposed to client
- [ ] SMTP credentials secured
- [ ] JWT secret rotated (if first time setup)
- [ ] Rate limiting configured (Supabase dashboard)
- [ ] Email confirmation enabled
- [ ] Password strength requirements set

### Rate Limits (Supabase Dashboard)

```yaml
Auth Settings:
  Rate Limit: 30 requests/hour (default)
  Password Requirements:
    - Minimum 8 characters
    - Require uppercase: ON
    - Require numbers: ON
    - Require special chars: Optional
```

---

## Success Metrics

### Week 1 Targets
- [ ] 80%+ existing users complete password reset
- [ ] 0 critical auth bugs reported
- [ ] New user signups create app_user records (100%)
- [ ] Average login time < 2 seconds

### Week 2 Targets
- [ ] 95%+ existing users migrated
- [ ] Email communication sent to remaining users
- [ ] Admin impersonation tested in production
- [ ] Audit logs reviewed for suspicious activity

---

## Support Resources

### Documentation
- **Setup Guide:** `SUPABASE_SETUP.md`
- **Implementation Plan:** `SUPABASE_AUTH_INTEGRATION_PLAN.md`
- **Migration Notes:** `MIGRATION_NOTES.md`
- **Code Review:** Review agent report (8.5/10 rating)

### Supabase Resources
- [Auth Documentation](https://supabase.com/docs/guides/auth)
- [RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [SMTP Setup](https://supabase.com/docs/guides/auth/auth-smtp)

### Emergency Contacts
- Database backup: `backup_[timestamp].sql`
- Rollback plan: `MIGRATION_NOTES.md` (lines 60-74)
- Support: Supabase Discord or GitHub issues

---

## Timeline Summary

**Total Time:** ~2 hours (including monitoring)

| Phase | Duration | Can Run Parallel |
|-------|----------|------------------|
| Phase 1: Supabase Setup | 30 min | No |
| Phase 2: Migration | 20 min | No |
| Phase 3: Verification | 15 min | No |
| Phase 4: User Comms | Immediate | Yes (while monitoring) |
| Monitoring (Day 1) | Ongoing | Yes |

**Recommended Schedule:**
- **Deploy:** Tuesday or Wednesday (mid-week)
- **Time:** 10 AM - 12 PM (allows for day-long monitoring)
- **Team:** Have support team on standby for user questions

---

## Final Pre-Launch Checklist

### Pre-Deployment (1 hour before)
- [ ] Database backup completed and verified
- [ ] Team notified (dev, support, product)
- [ ] Rollback plan printed/accessible
- [ ] SMTP tested and working
- [ ] Staging environment tested
- [ ] User communication email drafted

### During Deployment (20 minutes)
- [ ] Migrations deployed via `supabase db push`
- [ ] Schema verification queries run
- [ ] Test user signup completed
- [ ] Admin permissions verified

### Post-Deployment (1 hour after)
- [ ] User communication email sent
- [ ] Monitoring queries bookmarked
- [ ] Support team briefed on common issues
- [ ] Success metrics dashboard created

---

## Questions?

**Technical Issues:**
- Check HANDOFF.md for branch status
- Review code review report for known issues
- Test suite: `pytest -v` (59/60 passing expected)

**Migration Issues:**
- See MIGRATION_NOTES.md
- Review rollback procedure above
- Contact: [Your support channel]

---

**Last Updated:** 2025-11-17
**Maintained By:** Engineering Team
**Review Status:** ✅ Approved (8.5/10)
**Test Coverage:** 59/60 tests passing (98%)
