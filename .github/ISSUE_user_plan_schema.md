# Pre-Requisite: Design and Implement User Plan Schema

**Status**: Planning
**Priority**: High (blocks Phase 3)
**Effort**: Medium
**Labels**: `database`, `schema`, `prerequisite`, `mcp`
**Epic**: EPIC_mcp_integration.md
**Blocks**: Phase 3 - User Plans

## Problem

Currently, the `plan` table has no user relationship. All plans are global/shared system plans.

For MCP integration, we need user-specific plans that:
1. Can be created by AI (via MCP)
2. Are owned by specific users
3. Have privacy settings (private, shared, public)
4. Can be based on system plan templates
5. Maintain backwards compatibility with existing plans

## Requirements

### Functional
- [x] Users can create their own workout plans
- [x] Plans can be private (only owner), shared (specific users), or public (everyone)
- [x] Plans can be based on system plan templates (optional)
- [x] Track whether plan was created by user or AI
- [x] Support plan activation (one active plan at a time)
- [x] Support time-bounded plans (start/end dates)
- [x] Backwards compatible with existing `plan` table
- [x] Row Level Security (RLS) enforces ownership

### Non-Functional
- [x] Query performance: <100ms for user's plans
- [x] Storage efficient (reuse sessions from base plans where possible)
- [x] Clear separation between system and user content

## Proposed Schema

### Option 1: Extend `plan` Table (Rejected)

```sql
-- NOT RECOMMENDED
ALTER TABLE plan
    ADD COLUMN created_by_user_id uuid REFERENCES app_user(app_user_id),
    ADD COLUMN visibility text CHECK (visibility IN ('public', 'private', 'shared')),
    ADD COLUMN is_system boolean DEFAULT false;
```

**Pros**: Single table, simpler joins
**Cons**: Mixing system/user data, harder RLS, unclear ownership model

### Option 2: Separate `user_plan` Table (Recommended)

```sql
-- Mark existing system plans
ALTER TABLE plan
    ADD COLUMN IF NOT EXISTS is_system boolean DEFAULT false,
    ADD COLUMN IF NOT EXISTS visibility text DEFAULT 'public'
        CHECK (visibility IN ('public', 'unlisted'));

COMMENT ON COLUMN plan.is_system IS 'True for first-party/official plans provided by the app';
COMMENT ON COLUMN plan.visibility IS 'Public plans appear in browse, unlisted are accessible via link';

-- Create new table for user-created plans
CREATE TABLE user_plan (
    user_plan_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY,

    -- Ownership
    app_user_id uuid REFERENCES app_user(app_user_id) ON DELETE CASCADE NOT NULL,

    -- Plan details
    name text NOT NULL CHECK (length(name) >= 1 AND length(name) <= 200),
    description text,

    -- Template relationship (optional)
    based_on_plan_id uuid REFERENCES plan(plan_id) ON DELETE SET NULL,

    -- Privacy & sharing
    visibility text DEFAULT 'private' NOT NULL
        CHECK (visibility IN ('private', 'shared', 'public')),

    -- Creation metadata
    created_by text DEFAULT 'user' NOT NULL
        CHECK (created_by IN ('user', 'ai')),
    created_at timestamp DEFAULT now() NOT NULL,
    updated_at timestamp DEFAULT now() NOT NULL,

    -- Scheduling
    starts_at timestamp,
    ends_at timestamp,
    is_active boolean DEFAULT false,

    -- Extensibility
    data jsonb DEFAULT '{}'::jsonb,

    -- Constraints
    CHECK (starts_at IS NULL OR ends_at IS NULL OR starts_at < ends_at),
    CHECK (is_active = false OR (starts_at IS NOT NULL AND ends_at IS NOT NULL))
);

-- Indexes for common queries
CREATE INDEX idx_user_plan_user ON user_plan(app_user_id);
CREATE INDEX idx_user_plan_active ON user_plan(app_user_id, is_active) WHERE is_active = true;
CREATE INDEX idx_user_plan_visibility ON user_plan(visibility) WHERE visibility = 'public';
CREATE INDEX idx_user_plan_based_on ON user_plan(based_on_plan_id) WHERE based_on_plan_id IS NOT NULL;

-- Comments
COMMENT ON TABLE user_plan IS 'User-created workout plans, can be based on system plan templates';
COMMENT ON COLUMN user_plan.based_on_plan_id IS 'If set, this user plan is based on a system plan template';
COMMENT ON COLUMN user_plan.visibility IS 'private: only owner, shared: owner + specific users, public: everyone';
COMMENT ON COLUMN user_plan.created_by IS 'Track whether user created manually or AI created via MCP';
COMMENT ON COLUMN user_plan.data IS 'JSON storage for sharing config, AI metadata, customizations';
COMMENT ON COLUMN user_plan.is_active IS 'Only one plan can be active per user at a time';

-- Trigger to update updated_at
CREATE OR REPLACE FUNCTION update_user_plan_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_plan_updated_at
    BEFORE UPDATE ON user_plan
    FOR EACH ROW
    EXECUTE FUNCTION update_user_plan_updated_at();

-- Trigger to ensure only one active plan per user
CREATE OR REPLACE FUNCTION ensure_single_active_plan()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_active = true THEN
        UPDATE user_plan
        SET is_active = false
        WHERE app_user_id = NEW.app_user_id
          AND user_plan_id != NEW.user_plan_id
          AND is_active = true;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_single_active_plan
    BEFORE INSERT OR UPDATE ON user_plan
    FOR EACH ROW
    WHEN (NEW.is_active = true)
    EXECUTE FUNCTION ensure_single_active_plan();
```

### Row Level Security

```sql
-- Enable RLS
ALTER TABLE user_plan ENABLE ROW LEVEL SECURITY;

-- Users can read their own plans
CREATE POLICY "Users can read own plans" ON user_plan
    FOR SELECT
    TO authenticated
    USING (app_user_id = auth.uid());

-- Users can read public plans
CREATE POLICY "Anyone can read public plans" ON user_plan
    FOR SELECT
    TO authenticated, anon
    USING (visibility = 'public');

-- TODO: Shared plans (requires sharing table)
-- CREATE POLICY "Users can read shared plans" ON user_plan
--     FOR SELECT
--     TO authenticated
--     USING (
--         visibility = 'shared' AND
--         user_plan_id IN (
--             SELECT user_plan_id FROM user_plan_shares
--             WHERE shared_with_user_id = auth.uid()
--         )
--     );

-- Users can create their own plans
CREATE POLICY "Users can create own plans" ON user_plan
    FOR INSERT
    TO authenticated
    WITH CHECK (app_user_id = auth.uid());

-- Users can update their own plans
CREATE POLICY "Users can update own plans" ON user_plan
    FOR UPDATE
    TO authenticated
    USING (app_user_id = auth.uid())
    WITH CHECK (app_user_id = auth.uid());

-- Users can delete their own plans
CREATE POLICY "Users can delete own plans" ON user_plan
    FOR DELETE
    TO authenticated
    USING (app_user_id = auth.uid());

-- Grant permissions
GRANT SELECT ON user_plan TO authenticated, anon;
GRANT INSERT, UPDATE, DELETE ON user_plan TO authenticated;
```

### Combining System and User Plans (View)

```sql
CREATE OR REPLACE VIEW all_plans
    WITH (security_invoker=on)
AS
SELECT
    plan_id::text as id,
    NULL::uuid as user_plan_id,
    plan_id,
    name,
    description,
    'system' as source,
    NULL::uuid as owner_id,
    NULL::text as owner_name,
    visibility,
    is_system as first_party,
    NULL::timestamp as created_at,
    NULL::timestamp as starts_at,
    NULL::timestamp as ends_at,
    false as is_active,
    NULL::text as created_by
FROM plan

UNION ALL

SELECT
    user_plan_id::text as id,
    user_plan_id,
    based_on_plan_id as plan_id,
    up.name,
    up.description,
    'user' as source,
    up.app_user_id as owner_id,
    au.name as owner_name,
    up.visibility,
    false as first_party,
    up.created_at,
    up.starts_at,
    up.ends_at,
    up.is_active,
    up.created_by
FROM user_plan up
LEFT JOIN app_user au ON up.app_user_id = au.app_user_id;

-- Grant permissions
GRANT SELECT ON all_plans TO authenticated, anon;

COMMENT ON VIEW all_plans IS 'Unified view of system plans and user plans for easy querying';
```

## Session Schedule Relationship

User plans need their own session schedules. Two approaches:

### Approach A: Extend `session_schedule` Table (Recommended)

```sql
-- Allow session_schedule to belong to either plan or user_plan
ALTER TABLE session_schedule
    ADD COLUMN user_plan_id uuid REFERENCES user_plan(user_plan_id) ON DELETE CASCADE,
    ADD CONSTRAINT session_schedule_plan_xor
        CHECK (
            (plan_id IS NOT NULL AND user_plan_id IS NULL) OR
            (plan_id IS NULL AND user_plan_id IS NOT NULL)
        );

-- Index for user plan sessions
CREATE INDEX idx_session_schedule_user_plan ON session_schedule(user_plan_id)
    WHERE user_plan_id IS NOT NULL;

-- RLS for session_schedule (if not already exists)
ALTER TABLE session_schedule ENABLE ROW LEVEL SECURITY;

-- Anyone can read system plan sessions
CREATE POLICY "Anyone can read system plan sessions" ON session_schedule
    FOR SELECT
    TO authenticated, anon
    USING (plan_id IS NOT NULL);

-- Users can read their own user plan sessions
CREATE POLICY "Users can read own user plan sessions" ON session_schedule
    FOR SELECT
    TO authenticated
    USING (
        user_plan_id IS NOT NULL AND
        user_plan_id IN (
            SELECT user_plan_id FROM user_plan
            WHERE app_user_id = auth.uid()
        )
    );

-- Users can create/update/delete their own user plan sessions
CREATE POLICY "Users can manage own user plan sessions" ON session_schedule
    FOR ALL
    TO authenticated
    USING (
        user_plan_id IS NOT NULL AND
        user_plan_id IN (
            SELECT user_plan_id FROM user_plan
            WHERE app_user_id = auth.uid()
        )
    )
    WITH CHECK (
        user_plan_id IS NOT NULL AND
        user_plan_id IN (
            SELECT user_plan_id FROM user_plan
            WHERE app_user_id = auth.uid()
        )
    );

GRANT SELECT ON session_schedule TO authenticated, anon;
GRANT INSERT, UPDATE, DELETE ON session_schedule TO authenticated;

COMMENT ON COLUMN session_schedule.user_plan_id IS 'If set, this session belongs to a user plan (mutually exclusive with plan_id)';
```

### Approach B: Separate `user_session_schedule` Table

Not recommended - creates duplication and complex queries.

## Data Storage in `user_plan.data` (JSONB)

```jsonb
{
  "sharing": {
    "shared_with_users": ["uuid1", "uuid2"],
    "allow_fork": true,
    "allow_comments": false
  },
  "ai_metadata": {
    "mcp_session_id": "session_123",
    "generation_prompt": "Create a 4-day upper/lower split",
    "model": "claude-3-5-sonnet-20241022",
    "created_via": "mcp_create_workout_plan"
  },
  "customizations": {
    "custom_rest_periods": true,
    "progression_scheme": "linear",
    "deload_frequency": 6
  },
  "template_overrides": {
    "session_1": {
      "name": "Custom Upper Day A"
    }
  }
}
```

## Migration Plan

### Step 1: Add Columns to `plan` Table

```sql
-- Migration: 250_add_plan_metadata.sql
ALTER TABLE plan
    ADD COLUMN IF NOT EXISTS is_system boolean DEFAULT false,
    ADD COLUMN IF NOT EXISTS visibility text DEFAULT 'public'
        CHECK (visibility IN ('public', 'unlisted'));

-- Mark all existing plans as system plans
UPDATE plan SET is_system = true WHERE is_system IS NULL OR is_system = false;

COMMENT ON COLUMN plan.is_system IS 'True for first-party/official plans';
COMMENT ON COLUMN plan.visibility IS 'Public (browse) or unlisted (link only)';
```

### Step 2: Create `user_plan` Table

```sql
-- Migration: 260_create_user_plan.sql
-- (Include full user_plan creation from above)
```

### Step 3: Extend `session_schedule`

```sql
-- Migration: 270_extend_session_schedule_for_user_plans.sql
-- (Include session_schedule alterations from above)
```

### Step 4: Create View

```sql
-- Migration: 280_create_all_plans_view.sql
-- (Include all_plans view from above)
```

## Testing

### Unit Tests

```sql
-- Test: User can create plan
INSERT INTO user_plan (app_user_id, name, visibility)
VALUES ('test-user-uuid', 'My Custom Plan', 'private')
RETURNING user_plan_id;

-- Test: Only one active plan per user
INSERT INTO user_plan (app_user_id, name, is_active, starts_at, ends_at)
VALUES
    ('test-user-uuid', 'Plan A', true, now(), now() + interval '6 weeks'),
    ('test-user-uuid', 'Plan B', true, now(), now() + interval '6 weeks');

SELECT count(*) FROM user_plan WHERE app_user_id = 'test-user-uuid' AND is_active = true;
-- Expected: 1 (last inserted becomes active, first gets deactivated)

-- Test: RLS prevents reading other user's private plans
SET ROLE authenticated;
SET request.jwt.claims.sub = 'user-1-uuid';

SELECT * FROM user_plan WHERE app_user_id = 'user-2-uuid' AND visibility = 'private';
-- Expected: 0 rows

-- Test: All users can read public plans
SELECT * FROM user_plan WHERE visibility = 'public';
-- Expected: All public plans

-- Test: Unified view
SELECT * FROM all_plans;
-- Expected: Both system plans and accessible user plans
```

### Integration Tests (Python)

```python
# tests/test_user_plan.py
import pytest
from supabase import create_client

def test_create_user_plan(supabase_client, authenticated_user):
    result = supabase_client.table('user_plan').insert({
        'app_user_id': authenticated_user.id,
        'name': 'My Plan',
        'visibility': 'private',
        'created_by': 'ai'
    }).execute()

    assert result.data
    assert result.data[0]['name'] == 'My Plan'

def test_single_active_plan(supabase_client, authenticated_user):
    # Create two plans, both active
    plan1 = create_plan(name='Plan 1', is_active=True)
    plan2 = create_plan(name='Plan 2', is_active=True)

    # Check only plan2 is active
    active_plans = supabase_client.table('user_plan').select('*').eq(
        'is_active', True
    ).eq('app_user_id', authenticated_user.id).execute()

    assert len(active_plans.data) == 1
    assert active_plans.data[0]['name'] == 'Plan 2'

def test_rls_prevents_access(supabase_client, user1, user2):
    # User 1 creates private plan
    plan = create_plan(user=user1, visibility='private')

    # User 2 cannot read it
    client2 = authenticate_as(user2)
    result = client2.table('user_plan').select('*').eq(
        'user_plan_id', plan['user_plan_id']
    ).execute()

    assert len(result.data) == 0
```

## Acceptance Criteria

- [ ] `user_plan` table created with all fields
- [ ] RLS policies enforce ownership and visibility
- [ ] Triggers ensure only one active plan per user
- [ ] `session_schedule` can reference either `plan` or `user_plan`
- [ ] `all_plans` view combines system and user plans
- [ ] Migrations run successfully on clean database
- [ ] All unit tests pass
- [ ] Integration tests pass
- [ ] Documentation updated
- [ ] No breaking changes to existing `plan` queries

## Future Enhancements (Out of Scope)

- [ ] Sharing table (`user_plan_shares`) for granular sharing
- [ ] Following system (`user_follows`) to see followed users' public plans
- [ ] Plan forking (duplicate someone's plan as template)
- [ ] Plan version history
- [ ] Plan comments/ratings

## References

- Database schema: `/database/*.sql`
- Existing RLS examples: `/database/067_ExerciseMetadata_RLS.sql`
- Epic: `EPIC_mcp_integration.md`

## Related Issues

- Blocks: Phase 3 #XXX - User plans + write operations
- Related: EPIC #XXX - MCP Integration
