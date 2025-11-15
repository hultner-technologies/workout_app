# Security Model & Row Level Security (RLS)

## Overview

This workout app uses PostgreSQL Row Level Security (RLS) to ensure data isolation in a multi-tenant environment. The security model follows these principles:

1. **User Data Privacy**: Users can only access their own performed sessions and exercises
2. **Public Templates**: Workout plans, session schedules, and exercise definitions are publicly readable
3. **Defense in Depth**: RLS policies enforce security at the database level, independent of application code
4. **Supabase Compatible**: Uses `auth.uid()` for authentication in Supabase environment

## Security Architecture

### Data Classification

#### 🔒 **Private Data** (User-Specific)
- `performed_session` - User's workout sessions
- `performed_exercise` - User's exercise records
- `performed_exercise_set` - User's set records
- `app_user` - User profile data

**Access**: Only the owning user can read/write

#### 🌍 **Public Data** (Shared Templates)
- `plan` - Workout plan templates
- `session_schedule` - Workout session templates
- `exercise` - Exercise definitions in templates
- `base_exercise` - Exercise catalog
- `exercise_set_type` - Set type definitions

**Access**: All users can read, but cannot modify

### RLS Policy Summary

| Table | Authenticated Users | Anonymous Users | Notes |
|-------|---------------------|-----------------|-------|
| `performed_session` | Own data only | Read all* | *Can disable anon access |
| `performed_exercise` | Own data only | Read all* | *Can disable anon access |
| `performed_exercise_set` | Own data only | None | From 071_SpecialSet.sql |
| `app_user` | Own profile only | None | Cannot delete |
| `plan` | Read only | Read only | Admin-managed |
| `session_schedule` | Read only | Read only | Admin-managed |
| `exercise` | Read only | Read only | Admin-managed |
| `base_exercise` | Read only | Read only | Admin-managed |
| `exercise_set_type` | Read only | Read only | From 071_SpecialSet.sql |

### Anonymous Access

Currently, anonymous users can read `performed_session` and `performed_exercise` data. This allows for:
- Public workout log sharing
- Viewing workout statistics without login

**To disable anonymous access**, remove the "anon" policies from:
- `performed_session` (line 36-42 in 260_rls_policies.sql)
- `performed_exercise` (line 70-76 in 260_rls_policies.sql)

## Views and Functions Security

### Views with `security_invoker=on`

```sql
CREATE VIEW session_schedule_metadata
    WITH (security_invoker=on) AS ...
```

**Behavior:**
- Runs with the calling user's permissions
- Automatically respects RLS on underlying tables
- Safe for multi-tenant use
- No additional policies needed

**Views using this:**
- `session_schedule_metadata` (250_empty_workout_support.sql)
- `full_exercise` (110_views_full_exercise.sql)
- `next_exercise_progression` (120_views_next_exercise_progression.sql)
- `exercise_stats` (130_views_exercise_stats.sql)

### Functions with `SECURITY INVOKER`

```sql
CREATE FUNCTION draft_session_exercises_v2(...)
    SECURITY INVOKER
    SET search_path = 'public'
    AS $$ ... $$;
```

**Behavior:**
- Runs with the calling user's permissions
- RLS policies apply to all queries within the function
- Automatically filters data to user's own records

**Functions using this:**
- `draft_session_exercises_v2()` (250_empty_workout_support.sql)
- `performed_session_exists()` (250_empty_workout_support.sql)
- `draft_session_exercises()` (210_draft_session_exercises.sql)

### `SECURITY DEFINER` (Not Used)

We **do not** use `SECURITY DEFINER` for these functions because:
- It would bypass RLS and run as function owner (dangerous!)
- Could expose data from other users
- Violates principle of least privilege

## How RLS Works with Supabase

### Authentication Flow

1. User authenticates via Supabase Auth
2. Supabase sets `auth.uid()` to the user's UUID
3. PostgreSQL RLS policies check `auth.uid()`
4. Only matching rows are returned

### Example Policy

```sql
CREATE POLICY "Allow read access for own performed_session"
    ON performed_session
    FOR SELECT
    TO authenticated
    USING (app_user_id = (SELECT auth.uid()));
```

**Breakdown:**
- `FOR SELECT` - Applies to SELECT queries
- `TO authenticated` - Only for authenticated users
- `USING (...)` - Row filter condition
- `auth.uid()` - Current authenticated user's UUID

### Policy Types

| Operation | Policy Type | Purpose |
|-----------|-------------|---------|
| `SELECT` | `USING` | Which rows to return |
| `INSERT` | `WITH CHECK` | Can insert this row? |
| `UPDATE` | `USING` + `WITH CHECK` | Can see + can modify |
| `DELETE` | `USING` | Can delete this row? |

## Security Testing

### Automated Tests

Run the security test suite:

```bash
psql -d workout_app -f database/queries/test_rls_security.sql
```

This creates test users and verifies basic RLS behavior.

### Manual Testing in Supabase

1. **Create Test Users** in Supabase Auth with specific UUIDs:
   - Alice: `11111111-1111-1111-1111-111111111111`
   - Bob: `22222222-2222-2222-2222-222222222222`

2. **Set User Context** in SQL Editor:
   ```sql
   SET LOCAL role TO authenticated;
   SET LOCAL request.jwt.claim.sub TO '11111111-1111-1111-1111-111111111111';
   ```

3. **Test Data Isolation**:
   ```sql
   -- As Alice, should only see own sessions
   SELECT * FROM performed_session;

   -- As Alice, should NOT see Bob's session
   SELECT * FROM performed_session
   WHERE app_user_id = '22222222-2222-2222-2222-222222222222';
   ```

4. **Test Functions**:
   ```sql
   -- As Alice, should return Alice's exercises
   SELECT * FROM draft_session_exercises_v2('alice-session-uuid');

   -- As Alice, should return 0 rows (cannot see Bob's session)
   SELECT * FROM draft_session_exercises_v2('bob-session-uuid');
   ```

### Security Checklist

- [ ] RLS enabled on all user-data tables
- [ ] Policies prevent cross-user data access
- [ ] Views use `security_invoker=on`
- [ ] Functions use `SECURITY INVOKER` (default)
- [ ] No functions use `SECURITY DEFINER` for user data
- [ ] Anonymous access restricted (if needed)
- [ ] Tested with multiple users
- [ ] Verified data isolation

## Common Security Issues

### ❌ Problem: Function Exposes All Data

```sql
CREATE FUNCTION get_all_sessions()
    SECURITY DEFINER  -- ⚠️ BAD! Bypasses RLS
    AS $$
    SELECT * FROM performed_session;
    $$;
```

**Fix**: Use `SECURITY INVOKER` or add WHERE clause:

```sql
CREATE FUNCTION get_user_sessions()
    SECURITY INVOKER  -- ✅ GOOD! Respects RLS
    AS $$
    SELECT * FROM performed_session;
    $$;
```

### ❌ Problem: View Doesn't Respect RLS

```sql
CREATE VIEW all_sessions AS
SELECT * FROM performed_session;  -- ⚠️ May bypass RLS
```

**Fix**: Use `security_invoker=on`:

```sql
CREATE VIEW user_sessions
    WITH (security_invoker=on) AS  -- ✅ GOOD!
SELECT * FROM performed_session;
```

### ❌ Problem: Missing app_user_id in Query

```sql
-- User can specify any user_id!
SELECT * FROM performed_session
WHERE app_user_id = $1;  -- ⚠️ BAD without RLS
```

**Fix**: RLS enforces this automatically:

```sql
-- RLS automatically adds: AND app_user_id = auth.uid()
SELECT * FROM performed_session
WHERE session_schedule_id = $1;  -- ✅ GOOD with RLS
```

## Migration Guide

### Applying RLS to Existing Database

1. **Backup First**:
   ```bash
   pg_dump workout_app > backup.sql
   ```

2. **Apply RLS Migration**:
   ```bash
   psql -d workout_app -f database/260_rls_policies.sql
   ```

3. **Test with Existing Data**:
   - Verify users can access their own data
   - Verify users cannot see others' data
   - Test all API endpoints

4. **Monitor for Issues**:
   - Check application logs for access errors
   - Verify performance (RLS adds overhead)
   - Update application code if needed

### Performance Considerations

RLS policies add a WHERE clause to every query:

```sql
-- User query
SELECT * FROM performed_session WHERE completed_at > NOW() - INTERVAL '7 days';

-- Actual query with RLS
SELECT * FROM performed_session
WHERE completed_at > NOW() - INTERVAL '7 days'
  AND app_user_id = auth.uid();  -- ← Added by RLS
```

**Optimization:**
- Add index on `app_user_id`:
  ```sql
  CREATE INDEX idx_performed_session_user ON performed_session(app_user_id);
  ```
- Use composite indexes for common queries:
  ```sql
  CREATE INDEX idx_performed_session_user_date
    ON performed_session(app_user_id, completed_at);
  ```

## Additional Resources

- [PostgreSQL RLS Documentation](https://www.postgresql.org/docs/current/ddl-rowsecurity.html)
- [Supabase RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)
- [Security Best Practices](https://supabase.com/docs/guides/database/postgres/row-level-security)

## Support

For security issues:
1. Review test results from `test_rls_security.sql`
2. Check policy definitions in `260_rls_policies.sql`
3. Verify `auth.uid()` returns correct user ID
4. Test queries in SQL editor with user context set
