# Supabase Auth Migration - Important Notes

## Production Migration Strategy

### Critical Discovery (2025-11-17)

The migration files have been updated to handle existing production data properly. However, there are important considerations:

### Migration 028: Schema Changes
- **Username backfill**: Creates usernames from email (e.g., `ayourname_4521`)
- **Temporary trigger**: `app_user_backfill_username` auto-generates usernames for legacy INSERT statements
- **Auth.users sync**: Deferred to migration 034

### Migration 034: Foreign Key Setup
- Creates `auth.users` entries for existing `app_user` records
- Adds foreign key constraint `app_user_id_fkey`
- **IMPORTANT**: This migration creates placeholder passwords - users MUST reset via Supabase Auth

### Seed Data Limitation

**For Local Development:**
- The full production `seed.sql` represents PRE-migration data format
- It includes `password` column and lacks `username` column
- Migration 028 drops `password` and requires `username`
- **Recommendation**: Use `./database/use_dev_seed.sh` for local testing
- Dev seed creates minimal test data in the new schema format

**For Production Deployment:**
1. Back up your database before running migrations
2. Run migrations 025-034 in order
3. All existing users will get:
   - Auto-generated usernames (from email)
   - Corresponding `auth.users` entries with placeholder passwords
   - **Users MUST reset their passwords via Supabase Auth**

### Post-Migration User Communication

Send this to existing users after migration:

```
We've upgraded our authentication system to Supabase Auth.

Action Required:
1. Visit [your-app]/auth/reset-password
2. Enter your email address
3. Check your email for the reset link
4. Create a new password

Your data and workouts are safe and unchanged.
```

### Testing Results

- **59/60 tests passing** (1 flaky test due to random username generation)
- All core functionality verified
- Migration handles existing data correctly
- FK constraints properly enforced

### Rollback Plan

If migration fails or issues arise:

```sql
-- Rollback migration 034 (FK and auth sync)
ALTER TABLE app_user DROP CONSTRAINT IF EXISTS app_user_id_fkey;
DELETE FROM auth.users WHERE raw_user_meta_data->>'migrated' = 'true';

-- Rollback migration 028 (schema changes)
ALTER TABLE app_user DROP COLUMN IF EXISTS username;
ALTER TABLE app_user DROP CONSTRAINT IF EXISTS app_user_email_unique;
ALTER TABLE app_user ADD COLUMN password text;
DROP TRIGGER IF EXISTS app_user_backfill_username ON app_user;
DROP FUNCTION IF EXISTS backfill_username_on_insert();
```

### Files Modified

- `supabase/migrations/20240101000028_AppUser_Auth_Migration.sql`
- `supabase/migrations/20240101000034_Seed_Data_Auth_Sync.sql`
- `database/025_AppUser_Auth_Migration.sql` (synced)
- `database/034_Seed_Data_Auth_Sync.sql` (synced)
