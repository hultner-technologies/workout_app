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

-- Add username field (required, unique, min 4 chars, alphanumeric + common chars)
ALTER TABLE app_user
  ADD COLUMN username text NOT NULL UNIQUE
  CONSTRAINT username_length CHECK (char_length(username) >= 4)
  CONSTRAINT username_format CHECK (username ~ '^[a-zA-Z0-9._-]{4,}$');

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

**Two Implementation Approaches:**

#### Option A: Table-Based (Recommended)

More maintainable, easier to expand, follows database best practices.

**Implementation:**

```sql
-- Create word tables for username generation
CREATE TABLE username_adjectives (
  word text PRIMARY KEY,
  category text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE username_nouns (
  word text PRIMARY KEY,
  category text,
  created_at timestamptz DEFAULT now()
);

-- Seed with expanded word lists (120 adjectives × 150 nouns = 18,000 combinations)
INSERT INTO username_adjectives (word, category) VALUES
  -- Positive traits
  ('Happy', 'emotion'), ('Jolly', 'emotion'), ('Cheerful', 'emotion'), ('Bright', 'quality'),
  ('Sunny', 'nature'), ('Friendly', 'personality'), ('Kind', 'personality'), ('Gentle', 'personality'),
  ('Calm', 'personality'), ('Peaceful', 'quality'), ('Serene', 'quality'), ('Tranquil', 'quality'),
  -- Speed & movement
  ('Quick', 'movement'), ('Swift', 'movement'), ('Rapid', 'movement'), ('Fast', 'movement'),
  ('Agile', 'quality'), ('Nimble', 'quality'), ('Fleet', 'movement'), ('Speedy', 'movement'),
  -- Intelligence & wisdom
  ('Wise', 'mental'), ('Clever', 'mental'), ('Smart', 'mental'), ('Bright', 'mental'),
  ('Sharp', 'mental'), ('Keen', 'mental'), ('Astute', 'mental'), ('Savvy', 'mental'),
  -- Strength & power
  ('Strong', 'physical'), ('Mighty', 'physical'), ('Powerful', 'physical'), ('Robust', 'physical'),
  ('Sturdy', 'physical'), ('Solid', 'physical'), ('Tough', 'physical'), ('Hardy', 'physical'),
  -- Bravery & courage
  ('Brave', 'personality'), ('Bold', 'personality'), ('Daring', 'personality'), ('Fearless', 'personality'),
  ('Valiant', 'personality'), ('Heroic', 'personality'), ('Gallant', 'personality'), ('Noble', 'personality'),
  -- Freedom & independence
  ('Free', 'concept'), ('Wild', 'concept'), ('Rogue', 'concept'), ('Rebel', 'concept'),
  ('Maverick', 'concept'), ('Wandering', 'concept'), ('Roaming', 'concept'), ('Drifting', 'concept'),
  -- Purity & truth
  ('Pure', 'quality'), ('True', 'quality'), ('Honest', 'quality'), ('Clear', 'quality'),
  ('Genuine', 'quality'), ('Real', 'quality'), ('Authentic', 'quality'), ('Sincere', 'quality'),
  -- Royalty & grandeur
  ('Royal', 'status'), ('Grand', 'status'), ('Majestic', 'status'), ('Regal', 'status'),
  ('Imperial', 'status'), ('Sovereign', 'status'), ('Supreme', 'status'), ('Noble', 'status'),
  -- Magic & fantasy
  ('Magic', 'fantasy'), ('Mystic', 'fantasy'), ('Arcane', 'fantasy'), ('Ethereal', 'fantasy'),
  ('Enchanted', 'fantasy'), ('Fabled', 'fantasy'), ('Mythic', 'fantasy'), ('Legendary', 'fantasy'),
  -- Metals & gems
  ('Golden', 'material'), ('Silver', 'material'), ('Crystal', 'material'), ('Amber', 'material'),
  ('Ruby', 'material'), ('Jade', 'material'), ('Emerald', 'material'), ('Sapphire', 'material'),
  ('Diamond', 'material'), ('Bronze', 'material'), ('Platinum', 'material'), ('Pearl', 'material'),
  -- Space & cosmic
  ('Cosmic', 'space'), ('Stellar', 'space'), ('Lunar', 'space'), ('Solar', 'space'),
  ('Astral', 'space'), ('Galactic', 'space'), ('Nebular', 'space'), ('Celestial', 'space'),
  -- Time & era
  ('Ancient', 'time'), ('Modern', 'time'), ('Future', 'time'), ('Eternal', 'time'),
  ('Timeless', 'time'), ('Primal', 'time'), ('Classic', 'time'), ('Vintage', 'time'),
  -- Greek alphabet & special
  ('Alpha', 'greek'), ('Beta', 'greek'), ('Gamma', 'greek'), ('Delta', 'greek'),
  ('Omega', 'greek'), ('Prime', 'concept'), ('Mega', 'concept'), ('Ultra', 'concept'),
  ('Super', 'concept'), ('Hyper', 'concept'), ('Neo', 'concept'), ('Quantum', 'concept'),
  -- Technology
  ('Cyber', 'tech'), ('Digital', 'tech'), ('Pixel', 'tech'), ('Binary', 'tech'),
  ('Vector', 'tech'), ('Matrix', 'tech'), ('Circuit', 'tech'), ('Silicon', 'tech'),
  -- Style & cool
  ('Cool', 'style'), ('Epic', 'style'), ('Awesome', 'style'), ('Rad', 'style'),
  ('Stellar', 'style'), ('Prime', 'style'), ('Elite', 'style'), ('Supreme', 'style'),
  -- Nature qualities
  ('Verdant', 'nature'), ('Lush', 'nature'), ('Vibrant', 'nature'), ('Radiant', 'nature'),
  ('Glowing', 'nature'), ('Shining', 'nature'), ('Gleaming', 'nature'), ('Sparkling', 'nature');

INSERT INTO username_nouns (word, category) VALUES
  -- Large mammals
  ('Panda', 'mammal'), ('Tiger', 'mammal'), ('Lion', 'mammal'), ('Bear', 'mammal'),
  ('Wolf', 'mammal'), ('Fox', 'mammal'), ('Deer', 'mammal'), ('Otter', 'mammal'),
  ('Leopard', 'mammal'), ('Jaguar', 'mammal'), ('Panther', 'mammal'), ('Cheetah', 'mammal'),
  ('Lynx', 'mammal'), ('Cougar', 'mammal'), ('Bison', 'mammal'), ('Buffalo', 'mammal'),
  ('Moose', 'mammal'), ('Elk', 'mammal'), ('Rhino', 'mammal'), ('Hippo', 'mammal'),
  -- Birds
  ('Eagle', 'bird'), ('Falcon', 'bird'), ('Hawk', 'bird'), ('Owl', 'bird'),
  ('Raven', 'bird'), ('Sparrow', 'bird'), ('Phoenix', 'bird'), ('Condor', 'bird'),
  ('Crane', 'bird'), ('Heron', 'bird'), ('Swan', 'bird'), ('Dove', 'bird'),
  ('Finch', 'bird'), ('Robin', 'bird'), ('Cardinal', 'bird'), ('Bluejay', 'bird'),
  -- Sea creatures
  ('Dolphin', 'sea'), ('Shark', 'sea'), ('Whale', 'sea'), ('Seal', 'sea'),
  ('Penguin', 'sea'), ('Turtle', 'sea'), ('Orca', 'sea'), ('Manta', 'sea'),
  ('Nautilus', 'sea'), ('Kraken', 'sea'), ('Barracuda', 'sea'), ('Marlin', 'sea'),
  -- Mythical creatures
  ('Dragon', 'mythical'), ('Griffin', 'mythical'), ('Unicorn', 'mythical'), ('Pegasus', 'mythical'),
  ('Chimera', 'mythical'), ('Hydra', 'mythical'), ('Basilisk', 'mythical'), ('Sphinx', 'mythical'),
  -- Geography & landscapes
  ('River', 'geography'), ('Mountain', 'geography'), ('Ocean', 'geography'), ('Forest', 'geography'),
  ('Desert', 'geography'), ('Valley', 'geography'), ('Canyon', 'geography'), ('Meadow', 'geography'),
  ('Peak', 'geography'), ('Ridge', 'geography'), ('Summit', 'geography'), ('Glacier', 'geography'),
  ('Volcano', 'geography'), ('Island', 'geography'), ('Peninsula', 'geography'), ('Plateau', 'geography'),
  -- Weather & sky
  ('Storm', 'weather'), ('Thunder', 'weather'), ('Lightning', 'weather'), ('Rain', 'weather'),
  ('Snow', 'weather'), ('Wind', 'weather'), ('Cloud', 'weather'), ('Mist', 'weather'),
  ('Frost', 'weather'), ('Blizzard', 'weather'), ('Tempest', 'weather'), ('Gale', 'weather'),
  -- Celestial
  ('Star', 'celestial'), ('Moon', 'celestial'), ('Sun', 'celestial'), ('Comet', 'celestial'),
  ('Galaxy', 'celestial'), ('Nebula', 'celestial'), ('Cosmos', 'celestial'), ('Planet', 'celestial'),
  ('Meteor', 'celestial'), ('Aurora', 'celestial'), ('Pulsar', 'celestial'), ('Quasar', 'celestial'),
  -- Fantasy roles
  ('Knight', 'fantasy'), ('Wizard', 'fantasy'), ('Ninja', 'fantasy'), ('Samurai', 'fantasy'),
  ('Ranger', 'fantasy'), ('Hunter', 'fantasy'), ('Warrior', 'fantasy'), ('Guardian', 'fantasy'),
  ('Sage', 'fantasy'), ('Oracle', 'fantasy'), ('Prophet', 'fantasy'), ('Scholar', 'fantasy'),
  ('Paladin', 'fantasy'), ('Druid', 'fantasy'), ('Monk', 'fantasy'), ('Rogue', 'fantasy'),
  ('Archer', 'fantasy'), ('Mage', 'fantasy'), ('Cleric', 'fantasy'), ('Shaman', 'fantasy'),
  -- Arts & creativity
  ('Artist', 'arts'), ('Poet', 'arts'), ('Bard', 'arts'), ('Scribe', 'arts'),
  ('Painter', 'arts'), ('Dancer', 'arts'), ('Singer', 'arts'), ('Player', 'arts'),
  -- Trees & plants
  ('Oak', 'plant'), ('Pine', 'plant'), ('Willow', 'plant'), ('Maple', 'plant'),
  ('Cedar', 'plant'), ('Birch', 'plant'), ('Aspen', 'plant'), ('Redwood', 'plant'),
  ('Bamboo', 'plant'), ('Lotus', 'plant'), ('Rose', 'plant'), ('Iris', 'plant'),
  -- Gemstones & minerals
  ('Opal', 'mineral'), ('Topaz', 'mineral'), ('Onyx', 'mineral'), ('Quartz', 'mineral'),
  ('Obsidian', 'mineral'), ('Flint', 'mineral'), ('Marble', 'mineral'), ('Granite', 'mineral'),
  -- Concepts & abstract
  ('Spirit', 'concept'), ('Shadow', 'concept'), ('Light', 'concept'), ('Echo', 'concept'),
  ('Dream', 'concept'), ('Vision', 'concept'), ('Phantom', 'concept'), ('Spectre', 'concept'),
  ('Ember', 'concept'), ('Flame', 'concept'), ('Blaze', 'concept'), ('Spark', 'concept');

-- Add index for random selection performance
CREATE INDEX idx_username_adjectives_random ON username_adjectives USING btree (random());
CREATE INDEX idx_username_nouns_random ON username_nouns USING btree (random());

-- Username generation function using tables
CREATE OR REPLACE FUNCTION generate_unique_username()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  selected_adjective text;
  selected_noun text;
  new_username text;
  username_exists boolean;
  attempt_count integer := 0;
  max_attempts integer := 5;
BEGIN
  LOOP
    -- Select random adjective and noun from tables
    SELECT word INTO selected_adjective
    FROM username_adjectives
    ORDER BY random()
    LIMIT 1;

    SELECT word INTO selected_noun
    FROM username_nouns
    ORDER BY random()
    LIMIT 1;

    -- Generate AdjectiveNoun combination
    new_username := selected_adjective || selected_noun;

    -- Add random 2-4 digit number if we've had collisions
    IF attempt_count > 0 THEN
      new_username := new_username || (10 + floor(random() * 9990))::text;
    END IF;

    -- Check if username already exists
    SELECT EXISTS(SELECT 1 FROM app_user WHERE username = new_username)
    INTO username_exists;

    -- Exit loop if username is unique
    EXIT WHEN NOT username_exists;

    attempt_count := attempt_count + 1;

    -- Safety check: prevent infinite loop
    IF attempt_count >= max_attempts THEN
      -- Fallback: guarantee uniqueness with timestamp
      new_username := new_username || extract(epoch from now())::bigint::text;
      EXIT;
    END IF;
  END LOOP;

  RETURN new_username;
END;
$$;
```

**Considerations (Table-Based):**
- **Highly Scalable**: 120 adjectives × 150 nouns = **18,000 base combinations**
- **With Numbers**: ~18,000 × 9,980 = **~180 million combinations**
- **Easy Expansion**: Add words with simple INSERT statements
- **Categorization**: Words organized by category for future features
- **Analytics-Ready**: Can query most popular words, usage statistics
- **Admin-Friendly**: Future admin UI can manage word lists
- **Performance**: Minimal overhead, optimized with proper indexing
- **Maintainable**: Follows database normalization best practices

#### Option B: Array-Based (Simpler, Static)

Simpler implementation, good for getting started quickly. Less flexible but adequate for most use cases.

**Implementation:** See expanded array-based version in appendix (maintains original approach with 3x more words)

**Considerations (Array-Based):**
- **Simpler**: No additional tables to manage
- **Adequate Namespace**: Can expand to ~10,000-15,000 combinations
- **Static**: Requires code changes to add/remove words
- **Good for MVP**: Faster to implement initially
- **Migration Path**: Can migrate to table-based later if needed

**Recommendation:** Start with **Option A (Table-Based)** for long-term maintainability, or use Option B if you want to ship faster and migrate later.

**Status:** ⏳ Pending (Decision needed: Table-based or Array-based?)

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
  user_name text;
BEGIN
  -- Get username from metadata or generate one
  user_username := COALESCE(
    NEW.raw_user_meta_data->>'username',
    generate_unique_username()
  );

  -- Get name from metadata, or use username as fallback
  user_name := COALESCE(
    NEW.raw_user_meta_data->>'name',
    user_username
  );

  -- Insert into app_user
  INSERT INTO app_user (app_user_id, name, email, username, data)
  VALUES (
    NEW.id,
    user_name,
    NEW.email,
    user_username,
    '{}'::jsonb
  );

  RETURN NEW;
EXCEPTION
  WHEN unique_violation THEN
    -- If username collision (race condition), generate new one
    user_username := generate_unique_username();
    user_name := COALESCE(NEW.raw_user_meta_data->>'name', user_username);

    INSERT INTO app_user (app_user_id, name, email, username, data)
    VALUES (
      NEW.id,
      user_name,
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
- Pulls name from `raw_user_meta_data->>'name'`, defaults to username if not provided
- Pulls username from `raw_user_meta_data->>'username'`, generates Reddit-style if not provided
- Generated usernames: `HappyPanda`, `QuietZebra`, `SwiftEagle42` (alphanumeric only)
- User-provided usernames: Can include `-`, `_`, `.` (e.g., `john.doe`, `user_123`)
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
- [ ] **1.5** Configure email confirmation in Supabase Dashboard
- [ ] **1.6** Test migrations on local/dev database
- [ ] **1.7** Document frontend integration examples
- [ ] **1.8** Create migration guide for existing users
- [ ] **1.9** Write tests for new functionality
- [ ] **1.10** Update README with auth setup instructions
- [ ] **1.11** Deploy to production

### Phase 2 Tasks (Future)

- [ ] **2.1** Configure OAuth providers (Apple, Google, GitHub)
- [ ] **2.2** Design admin impersonation system
- [ ] **2.3** Implement impersonation backend
- [ ] **2.4** Implement impersonation frontend
- [ ] **2.5** Add audit logging for impersonation
- [ ] **2.6** Implement username change functionality (self-service with rate limiting)
- [ ] **2.7** Configure custom SMTP for production email sending

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
- ✅ **Username validation**: Allow common characters (`-`, `_`, `.`) in addition to alphanumeric
- ✅ **Username changes**: Enabled but discouraged (link breakage). Manual process initially acceptable
- ✅ **Email confirmation**: Enabled from start (Supabase free tier includes email, no frontend hosting needed)
- ✅ **Default name**: Use username if name not provided during signup

### Implementation Notes

**Username Validation Pattern:**
```sql
-- Allow alphanumeric, hyphens, underscores, and periods
-- Minimum 4 characters
ALTER TABLE app_user
  ADD CONSTRAINT username_format
  CHECK (username ~ '^[a-zA-Z0-9._-]{4,}$');
```

**Email Confirmation Setup:**
- Supabase free tier: 2-4 emails/hour (sufficient for early development)
- Configuration: Supabase Dashboard > Authentication > Email Templates
- Redirect URL: Use deep linking for React Native app (e.g., `yourapp://auth/confirm`)
- For testing: Can disable confirmation in Supabase Dashboard > Email Provider settings
- Production: Configure custom SMTP for higher rate limits (30 emails/hour minimum)

**Username Changes:**
- Add `username_updated_at` timestamp column to track changes
- Implement rate limiting (e.g., once per 30 days)
- Consider username history table for link preservation
- Phase 1: Manual changes via admin/support
- Phase 2: Self-service with rate limiting

---

## References

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Supabase RLS Documentation](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Managing User Data in Supabase](https://supabase.com/docs/guides/auth/managing-user-data)
- [User Impersonation Feature](https://supabase.com/features/user-impersonation)

---

## Changelog

### 2025-11-16

**Initial Plan:**
- Initial plan created
- Phase 1 scope defined: core auth integration
- Phase 2 scope defined: OAuth + admin impersonation
- Username generation strategy designed
- Migration approach documented

**Update 1 - Reddit-Style Usernames:**
- Username generation changed to Reddit-style readable format (AdjectiveNoun pattern)
- Changed from random character strings to memorable combinations
- Examples: `HappyPanda`, `QuietZebra`, `SwiftEagle42`
- 56 adjectives × 64 nouns = 3,584 base combinations

**Update 2 - Finalized Requirements:**
- Resolved all open questions:
  - ✅ Username validation: Allow alphanumeric + common chars (`-`, `_`, `.`)
  - ✅ Username changes: Enabled but discouraged, manual process initially
  - ✅ Email confirmation: Enabled from start (free tier sufficient for development)
  - ✅ Default name: Use username if not provided during signup
- Added username format constraint: `^[a-zA-Z0-9._-]{4,}$`
- Updated trigger to use username as default name fallback
- Moved email confirmation from Phase 2 to Phase 1
- Added implementation notes for email setup and username changes

**Update 3 - Improved Username Generation:**
- Analyzed current namespace: 3,584 combinations (adequate but limited)
- Added two implementation approaches:
  - **Option A (Recommended)**: Table-based with 18,000+ combinations
    - 120 adjectives × 150 nouns = 18,000 base combinations
    - ~180 million combinations with numbers
    - Organized by category (emotion, nature, fantasy, etc.)
    - Easy to expand via SQL INSERT
    - Analytics-ready for usage statistics
    - Future admin UI capability
  - **Option B**: Array-based (simpler, can expand to 10,000-15,000 combinations)
- Table-based approach follows PostgreSQL best practices for maintainability
- Added word categories: mammals, birds, mythical creatures, geography, celestial, fantasy roles, etc.
- Decision needed: Choose table-based or array-based implementation
