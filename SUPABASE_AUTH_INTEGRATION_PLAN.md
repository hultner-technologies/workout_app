# Supabase Auth Integration Plan

**Status:** Planning
**Created:** 2025-11-16
**Branch:** `claude/supabase-auth-research-01PkSeSy76eJxXtwayW79bKS`

## Overview

Integrate Supabase authentication system with the existing `app_user` table, enabling secure user authentication with email/password (Phase 1) and OAuth providers (Phase 2).

## Current State

### What We Have
- ✅ `app_user` table with UUID primary key
- ✅ RLS policies using `auth.uid()` throughout the codebase
- ✅ Proper security model for multi-tenant data isolation
- ✅ RLS policies preventing direct user creation
- ✅ Performance-optimized indexes for user-based queries

### What's Missing
- ❌ Foreign key relationship between `app_user` and `auth.users`
- ❌ Database trigger to auto-create `app_user` records on signup
- ❌ Required username field with uniqueness constraint
- ❌ Automatic username generation for users who don't provide one
- ❌ Migration path for existing app_user records

## Phase 1: Core Authentication Setup

### 1.1 Modify `app_user` Table Schema

**File:** `database/025_AppUser_Auth_Migration.sql`

**Changes:**
```sql
-- Add foreign key constraint to auth.users
ALTER TABLE app_user
  ADD CONSTRAINT app_user_id_fkey
  FOREIGN KEY (app_user_id)
  REFERENCES auth.users(id)
  ON DELETE CASCADE;

-- Add username field (required, unique, min 4 chars)
ALTER TABLE app_user
  ADD COLUMN username text NOT NULL UNIQUE
  CONSTRAINT username_length CHECK (char_length(username) >= 4);

-- Add unique constraint on email
ALTER TABLE app_user
  ADD CONSTRAINT app_user_email_unique UNIQUE (email);

-- Remove password field (Supabase manages authentication)
ALTER TABLE app_user DROP COLUMN IF EXISTS password;

-- Keep existing fields: name, email, data (jsonb)
```

**Status:** ⏳ Pending

---

### 1.2 Create Username Generation Function

**File:** `database/026_Auth_Username_Generator.sql`

**Implementation:**
```sql
-- Function to generate unique random username
-- Pattern: user_<8-char-random-string>
-- Handles uniqueness by checking existing usernames
CREATE OR REPLACE FUNCTION generate_unique_username()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  new_username text;
  username_exists boolean;
BEGIN
  LOOP
    -- Generate random 8-character alphanumeric string
    new_username := 'user_' || lower(substring(md5(random()::text || clock_timestamp()::text) from 1 for 8));

    -- Check if username already exists
    SELECT EXISTS(SELECT 1 FROM app_user WHERE username = new_username) INTO username_exists;

    -- Exit loop if username is unique
    EXIT WHEN NOT username_exists;
  END LOOP;

  RETURN new_username;
END;
$$;
```

**Considerations:**
- Uses MD5 hash of random value + timestamp for uniqueness
- Loop ensures no collisions (retries if username exists)
- Generates usernames like: `user_a3f7c8d2`, `user_9e2b4f1a`
- Unique constraint on `app_user.username` provides database-level guarantee

**Status:** ⏳ Pending

---

### 1.3 Create Database Trigger for Auto-Profile Creation

**File:** `database/027_Auth_Trigger.sql`

**Implementation:**
```sql
-- Trigger function to create app_user when auth.users record created
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_username text;
BEGIN
  -- Get username from metadata or generate one
  user_username := COALESCE(
    NEW.raw_user_meta_data->>'username',
    generate_unique_username()
  );

  -- Insert into app_user
  INSERT INTO app_user (app_user_id, name, email, username, data)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', ''),
    NEW.email,
    user_username,
    '{}'::jsonb
  );

  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- If username collision (race condition), generate new one
    user_username := generate_unique_username();

    INSERT INTO app_user (app_user_id, name, email, username, data)
    VALUES (
      NEW.id,
      COALESCE(NEW.raw_user_meta_data->>'name', ''),
      NEW.email,
      user_username,
      '{}'::jsonb
    );

    RETURN NEW;
END;
$$;

-- Create trigger on auth.users insert
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();
```

**Features:**
- Pulls email from `NEW.email`
- Pulls name from `raw_user_meta_data->>'name'` (if provided during signup)
- Pulls username from `raw_user_meta_data->>'username'` or generates one
- Handles race conditions with exception handling
- Uses `SECURITY DEFINER` to bypass RLS during trigger execution

**Status:** ⏳ Pending

---

### 1.4 Update RLS Policies

**File:** `database/265_RLS_Performance_Updates.sql`

**Changes:**

#### Performance Optimization
Replace direct `auth.uid()` calls with `(SELECT auth.uid())` for caching:

```sql
-- Example: Update performed_session policies
DROP POLICY IF EXISTS "Allow read access for own performed_session" ON public.performed_session;
CREATE POLICY "Allow read access for own performed_session"
  ON public.performed_session
  FOR SELECT
  TO authenticated
  USING (app_user_id = (SELECT auth.uid()));
```

**Apply to all RLS policies in:**
- performed_session (SELECT, INSERT, UPDATE, DELETE)
- performed_exercise (SELECT, INSERT, UPDATE, DELETE)
- app_user (SELECT, UPDATE)

#### Allow Trigger-Based Inserts to app_user

Currently, the INSERT policy blocks all inserts. We need to allow the trigger function to insert while blocking client inserts:

```sql
-- Drop the blanket prevention policy
DROP POLICY IF EXISTS "Prevent insert access app_user" ON public.app_user;

-- New policy: Allow only if called from trigger context
-- Client inserts will fail because they run as 'authenticated' role
-- Trigger runs as SECURITY DEFINER with elevated privileges
CREATE POLICY "Allow insert from auth trigger only"
  ON public.app_user
  FOR INSERT
  TO authenticated
  WITH CHECK (false);  -- Blocks direct client inserts

-- The trigger function bypasses RLS due to SECURITY DEFINER
```

**Status:** ⏳ Pending

---

### 1.5 Frontend Integration Guide

**For React Native App:**

```typescript
// Signup with username
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    data: {
      name: 'John Doe',
      username: 'johndoe123'  // Optional, will be auto-generated if not provided
    }
  }
})

// Login
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'secure-password'
})

// Get user profile
const { data: profile } = await supabase
  .from('app_user')
  .select('*')
  .eq('app_user_id', user.id)
  .single()
```

**Status:** ⏳ Pending

---

### 1.6 Migration Guide for Existing Users

**Manual Migration Process:**

1. Create backup of existing `app_user` table
2. For each existing user:
   - Sign up through Supabase Auth
   - Note the new `auth.users.id`
   - Update foreign key references from old `app_user_id` to new one
   - Delete old `app_user` record

**Helper Query:**
```sql
-- List existing app_users to migrate
SELECT app_user_id, name, email,
       COALESCE(name, 'user_' || substring(app_user_id::text from 1 for 8)) as suggested_username
FROM app_user
ORDER BY email;
```

**Status:** ⏳ Pending

---

## Phase 2: Advanced Features (Future)

### 2.1 OAuth Providers

**Providers to Support:**
- ✅ Apple (required for iOS App Store)
- ✅ Google
- ⚠️ GitHub (nice-to-have)

**Implementation:**
- Configure OAuth apps in provider dashboards
- Add OAuth configurations to Supabase project settings
- Update trigger to handle OAuth user metadata
- Test username generation with OAuth signups

**Status:** 📅 Future

---

### 2.2 Admin User Impersonation

**Goal:** Allow admin users to "switch into" another user's session for debugging/support.

**Approach:**
Use Supabase's session-based impersonation with `set_config` for JWT claims:

```sql
-- Admin table
CREATE TABLE admins (
  user_id uuid REFERENCES app_user(app_user_id) PRIMARY KEY,
  created_at timestamptz DEFAULT now()
);

-- Session context for impersonation
-- Set acting_as_user_id in session config
SELECT set_config('app.acting_as_user_id', '<target-user-id>', true);

-- Modified RLS policies check either:
-- 1. User is the owner, OR
-- 2. User is acting as the owner (impersonation)
CREATE OR REPLACE FUNCTION get_effective_user_id()
RETURNS uuid
LANGUAGE sql
STABLE
AS $$
  SELECT COALESCE(
    current_setting('app.acting_as_user_id', true)::uuid,
    auth.uid()
  );
$$;

-- Update RLS policies to use effective_user_id
USING (app_user_id = (SELECT get_effective_user_id()))
```

**Security Considerations:**
- Audit log for all impersonation events
- Restrict impersonation to specific admin roles
- Session timeout for impersonated sessions
- UI indicator showing impersonation mode
- Ability to "switch back" to admin's own session

**Frontend Flow:**
1. Admin navigates to user switcher view
2. Admin selects user to impersonate
3. Backend validates admin permissions
4. Backend sets session config with target user ID
5. All subsequent queries run as target user
6. Admin can switch back to their own session

**Status:** 📅 Future (Phase 2)

---

### 2.3 Email Confirmation

**Configuration:**
- Enable email confirmation in Supabase Auth settings
- Customize confirmation email template
- Handle unconfirmed user states in app

**Status:** 📅 Future

---

## Testing Plan

### Unit Tests
- [ ] Test username generation produces valid format
- [ ] Test username generation handles collisions
- [ ] Test trigger creates app_user on auth.users insert
- [ ] Test trigger handles missing metadata gracefully
- [ ] Test RLS policies block unauthorized access
- [ ] Test RLS policies allow authorized access

### Integration Tests
- [ ] Test full signup flow (email/password)
- [ ] Test login flow
- [ ] Test profile retrieval
- [ ] Test profile updates
- [ ] Test user deletion cascades properly

### Performance Tests
- [ ] Verify RLS query performance with indexes
- [ ] Test concurrent signups don't cause username collisions

**Status:** ⏳ Pending

---

## Security Considerations

### Completed
- ✅ RLS policies restrict data access to owner
- ✅ Foreign key cascade prevents orphaned records
- ✅ Unique constraints prevent duplicate usernames/emails
- ✅ Password storage handled by Supabase (not in app_user)

### To Verify
- [ ] Trigger function uses `SECURITY DEFINER` safely
- [ ] Trigger function has minimal privileges
- [ ] No sensitive data in `raw_user_meta_data`
- [ ] Service role keys kept server-side only

---

## Rollback Plan

If issues arise:

1. **Before migration:**
   - Disable trigger: `DROP TRIGGER on_auth_user_created ON auth.users;`
   - Remove foreign key: `ALTER TABLE app_user DROP CONSTRAINT app_user_id_fkey;`

2. **After migration:**
   - Restore from backup
   - Document issues encountered
   - Adjust plan and re-attempt

---

## Progress Tracking

### Phase 1 Tasks

- [ ] **1.1** Create `025_AppUser_Auth_Migration.sql`
- [ ] **1.2** Create `026_Auth_Username_Generator.sql`
- [ ] **1.3** Create `027_Auth_Trigger.sql`
- [ ] **1.4** Create `265_RLS_Performance_Updates.sql`
- [ ] **1.5** Test migrations on local/dev database
- [ ] **1.6** Document frontend integration examples
- [ ] **1.7** Create migration guide for existing users
- [ ] **1.8** Write tests for new functionality
- [ ] **1.9** Update README with auth setup instructions
- [ ] **1.10** Deploy to production

### Phase 2 Tasks (Future)

- [ ] **2.1** Configure OAuth providers (Apple, Google, GitHub)
- [ ] **2.2** Design admin impersonation system
- [ ] **2.3** Implement impersonation backend
- [ ] **2.4** Implement impersonation frontend
- [ ] **2.5** Add audit logging for impersonation
- [ ] **2.6** Enable email confirmation

---

## Questions & Decisions

### Resolved ✅
- ✅ Use Pattern 1 (database trigger) for user creation
- ✅ Username required (min 4 chars)
- ✅ Auto-generate usernames if not provided
- ✅ Manual migration acceptable for existing users
- ✅ Email/password auth is priority 1
- ✅ OAuth is Phase 2
- ✅ Admin impersonation is Phase 2

### Open Questions ❓
- ❓ Should we validate username format (alphanumeric only, no special chars)?
- ❓ Should users be able to change their username after signup?
- ❓ Do we want email confirmation enabled from the start?
- ❓ What should the default value for `name` be if not provided?

---

## References

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Supabase RLS Documentation](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Managing User Data in Supabase](https://supabase.com/docs/guides/auth/managing-user-data)
- [User Impersonation Feature](https://supabase.com/features/user-impersonation)

---

## Changelog

### 2025-11-16
- Initial plan created
- Phase 1 scope defined: core auth integration
- Phase 2 scope defined: OAuth + admin impersonation
- Username generation strategy designed
- Migration approach documented
