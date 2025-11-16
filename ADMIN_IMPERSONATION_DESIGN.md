# Admin Impersonation System Design

**Status:** Design Phase
**Created:** 2025-11-16
**Priority:** Phase 2 - High Priority
**Branch:** `claude/supabase-auth-research-01PkSeSy76eJxXtwayW79bKS`

## Overview

Design and implement session-based admin impersonation allowing authorized admins to "switch into" another user's session for debugging and support purposes. The admin experiences the application exactly as the target user would, with all RLS policies enforced as if they are that user.

## Goals

1. **Support & Debugging** - Allow admins to reproduce user-reported issues
2. **RLS Testing** - Verify Row Level Security policies work correctly for specific users
3. **User Experience** - Test feature access and permissions from user perspective
4. **Compliance** - Maintain audit trail of all impersonation activities
5. **Security** - Prevent abuse with strict access controls and session timeouts

## Non-Goals

- **Bypass RLS** - Admins should NOT bypass security policies (use service role for that)
- **Permanent Access** - Impersonation sessions should have time limits
- **Silent Impersonation** - All impersonation must be logged and auditable

---

## Architecture

### High-Level Flow

```
1. Admin authenticates normally → Has admin session
2. Admin selects user to impersonate → Validates admin permission
3. Backend generates magic link for target user → Using auth.admin.generateLink()
4. Store admin's original session → In separate JWT cookie
5. Switch to target user session → Using verifyOtp()
6. Admin operates as target user → All RLS policies enforced
7. Admin clicks "Exit Impersonation" → Reverse-impersonate back to admin
8. Restore admin session → Clear impersonation state
```

### Session Management

**Two-Cookie Approach:**

1. **Primary Session Cookie** (Supabase default)
   - Contains active user session (target user during impersonation)
   - Managed by Supabase Auth
   - Used for RLS `auth.uid()` resolution

2. **Impersonation Metadata Cookie** (custom)
   - Name: `sb-impersonation-meta`
   - Contains: `{admin_user_id, admin_email, started_at, expires_at}`
   - httpOnly, secure, sameSite
   - Only set during active impersonation
   - Deleted when exiting impersonation

---

## Database Schema

### Admin Roles Table

```sql
-- database/030_Admin_Roles.sql

-- Admin users table
CREATE TABLE admin_users (
  admin_user_id uuid REFERENCES app_user(app_user_id) ON DELETE CASCADE PRIMARY KEY,
  role text NOT NULL DEFAULT 'support',
  granted_by uuid REFERENCES admin_users(admin_user_id),
  granted_at timestamptz DEFAULT now(),
  revoked_at timestamptz,
  notes text,

  CONSTRAINT valid_admin_role CHECK (role IN ('support', 'admin', 'superadmin'))
);

-- RLS: Only admins can view admin_users
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view all admin users"
  ON admin_users
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM admin_users
      WHERE admin_user_id = (SELECT auth.uid())
        AND revoked_at IS NULL
    )
  );

-- Indexes
CREATE INDEX idx_admin_users_active ON admin_users(admin_user_id) WHERE revoked_at IS NULL;

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin(user_id uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT EXISTS (
    SELECT 1 FROM admin_users
    WHERE admin_user_id = user_id
      AND revoked_at IS NULL
  );
$$;

-- Helper function to get admin role
CREATE OR REPLACE FUNCTION get_admin_role(user_id uuid DEFAULT auth.uid())
RETURNS text
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT role FROM admin_users
  WHERE admin_user_id = user_id
    AND revoked_at IS NULL
  LIMIT 1;
$$;
```

### Impersonation Audit Log

```sql
-- database/031_Impersonation_Audit.sql

-- Audit log for all impersonation events
CREATE TABLE impersonation_audit (
  audit_id uuid PRIMARY KEY DEFAULT uuid_generate_v1mc(),
  admin_user_id uuid NOT NULL REFERENCES app_user(app_user_id) ON DELETE CASCADE,
  target_user_id uuid NOT NULL REFERENCES app_user(app_user_id) ON DELETE CASCADE,
  started_at timestamptz NOT NULL DEFAULT now(),
  ended_at timestamptz,
  ended_reason text,
  ip_address inet,
  user_agent text,
  notes text,

  CONSTRAINT valid_ended_reason CHECK (
    ended_reason IS NULL OR
    ended_reason IN ('manual', 'timeout', 'session_revoked', 'admin_logout')
  ),
  CONSTRAINT end_after_start CHECK (ended_at IS NULL OR ended_at >= started_at)
);

-- RLS: Only admins can view audit log
ALTER TABLE impersonation_audit ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can view all impersonation logs"
  ON impersonation_audit
  FOR SELECT
  TO authenticated
  USING (is_admin());

-- Indexes for common queries
CREATE INDEX idx_impersonation_audit_admin ON impersonation_audit(admin_user_id, started_at DESC);
CREATE INDEX idx_impersonation_audit_target ON impersonation_audit(target_user_id, started_at DESC);
CREATE INDEX idx_impersonation_audit_active ON impersonation_audit(started_at) WHERE ended_at IS NULL;

-- Function to log impersonation start
CREATE OR REPLACE FUNCTION log_impersonation_start(
  p_admin_user_id uuid,
  p_target_user_id uuid,
  p_ip_address inet DEFAULT NULL,
  p_user_agent text DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_audit_id uuid;
BEGIN
  -- Verify admin permission
  IF NOT is_admin(p_admin_user_id) THEN
    RAISE EXCEPTION 'User % is not an admin', p_admin_user_id;
  END IF;

  -- Insert audit record
  INSERT INTO impersonation_audit (
    admin_user_id,
    target_user_id,
    ip_address,
    user_agent
  ) VALUES (
    p_admin_user_id,
    p_target_user_id,
    p_ip_address,
    p_user_agent
  )
  RETURNING audit_id INTO v_audit_id;

  RETURN v_audit_id;
END;
$$;

-- Function to log impersonation end
CREATE OR REPLACE FUNCTION log_impersonation_end(
  p_audit_id uuid,
  p_ended_reason text DEFAULT 'manual'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE impersonation_audit
  SET ended_at = now(),
      ended_reason = p_ended_reason
  WHERE audit_id = p_audit_id
    AND ended_at IS NULL;
END;
$$;
```

---

## API Implementation

### Backend API Routes

These would be implemented in a separate backend service or Next.js API routes.

#### POST /api/admin/impersonate/start

**Purpose:** Initiate impersonation session

**Request:**
```typescript
{
  target_user_id: string  // UUID of user to impersonate
}
```

**Flow:**
1. Verify requester is admin (check `is_admin()`)
2. Verify target user exists
3. Generate magic link for target user via `auth.admin.generateLink()`
4. Create audit log entry
5. Generate impersonation metadata JWT
6. Return redirect URL with token hash

**Response:**
```typescript
{
  redirect_url: string,      // URL to redirect to for session switch
  audit_id: string,           // Audit log ID
  expires_at: string          // ISO timestamp
}
```

**Implementation:**
```typescript
// POST /api/admin/impersonate/start
export async function POST(request: Request) {
  const { target_user_id } = await request.json()

  // Get admin session
  const { data: { user: admin }, error: authError } =
    await supabaseAdmin.auth.getUser(request.headers.get('Authorization'))

  if (authError || !admin) {
    return Response.json({ error: 'Unauthorized' }, { status: 401 })
  }

  // Verify admin permission
  const { data: isAdmin } = await supabaseAdmin
    .rpc('is_admin', { user_id: admin.id })

  if (!isAdmin) {
    return Response.json({ error: 'Forbidden' }, { status: 403 })
  }

  // Get target user email
  const { data: targetUser } = await supabaseAdmin
    .from('app_user')
    .select('email')
    .eq('app_user_id', target_user_id)
    .single()

  if (!targetUser) {
    return Response.json({ error: 'User not found' }, { status: 404 })
  }

  // Generate magic link for target user
  const { data: linkData, error: linkError } =
    await supabaseAdmin.auth.admin.generateLink({
      type: 'magiclink',
      email: targetUser.email,
      options: {
        redirectTo: `${process.env.APP_URL}/admin/impersonation/verify`
      }
    })

  if (linkError || !linkData) {
    return Response.json({ error: 'Failed to generate link' }, { status: 500 })
  }

  // Create audit log
  const { data: auditId } = await supabaseAdmin
    .rpc('log_impersonation_start', {
      p_admin_user_id: admin.id,
      p_target_user_id: target_user_id,
      p_ip_address: request.headers.get('x-forwarded-for'),
      p_user_agent: request.headers.get('user-agent')
    })

  // Create impersonation metadata JWT
  const impersonationMeta = {
    admin_user_id: admin.id,
    admin_email: admin.email,
    target_user_id: target_user_id,
    audit_id: auditId,
    started_at: new Date().toISOString(),
    expires_at: new Date(Date.now() + 2 * 60 * 60 * 1000).toISOString() // 2 hours
  }

  const metaToken = await signJWT(impersonationMeta, process.env.IMPERSONATION_SECRET!)

  // Set impersonation metadata cookie
  const response = Response.json({
    redirect_url: linkData.properties.hashed_token
      ? `/admin/impersonation/verify?token_hash=${linkData.properties.hashed_token}`
      : linkData.properties.action_link,
    audit_id: auditId,
    expires_at: impersonationMeta.expires_at
  })

  response.headers.set('Set-Cookie',
    `sb-impersonation-meta=${metaToken}; HttpOnly; Secure; SameSite=Lax; Path=/; Max-Age=7200`
  )

  return response
}
```

#### POST /api/admin/impersonation/verify

**Purpose:** Verify magic link and establish impersonation session

**Request:**
```typescript
{
  token_hash: string  // From magic link URL
}
```

**Flow:**
1. Verify impersonation metadata cookie exists
2. Call `auth.verifyOtp()` with token hash
3. Session now switched to target user
4. Return success

**Response:**
```typescript
{
  success: true,
  impersonating: {
    user_id: string,
    username: string,
    email: string
  },
  admin: {
    user_id: string,
    email: string
  }
}
```

#### POST /api/admin/impersonation/end

**Purpose:** Exit impersonation and restore admin session

**Flow:**
1. Read impersonation metadata cookie
2. Generate magic link for admin's email
3. Update audit log (set ended_at)
4. Redirect to admin's magic link
5. Clear impersonation cookie
6. Session restored to admin

---

## Frontend Implementation

### Admin UI Components

#### ImpersonationBanner

**Location:** Top of all pages when impersonation active

**Design:**
```
╔═════════════════════════════════════════════════════════════════╗
║ ⚠️  IMPERSONATING: @SwoleRat (swolerat@example.com)            ║
║ Started: 5 minutes ago | Admin: @admin_user                     ║
║ [Exit Impersonation] ────────────────────────────────────────── ║
╚═════════════════════════════════════════════════════════════════╝
```

**Features:**
- Highly visible (yellow/orange background)
- Shows target username and email
- Shows admin's username
- Shows time elapsed
- One-click exit button
- Cannot be dismissed

#### User Switcher View

**Location:** `/admin/users` with impersonation controls

**Design:**
```
Users List
┌─────────────────────────────────────────────────────┐
│ Username      Email                    Actions       │
├─────────────────────────────────────────────────────┤
│ @SwoleRat     swolerat@example.com     [Impersonate]│
│ @IronLifter   iron@example.com         [Impersonate]│
│ @BuffBarbell  buff@example.com         [Impersonate]│
└─────────────────────────────────────────────────────┘
```

**Features:**
- Search/filter users
- Show user details
- "Impersonate" button with confirmation dialog
- Show recent impersonation history

#### Impersonation Audit Log

**Location:** `/admin/audit/impersonation`

**Columns:**
- Admin (username, email)
- Target User (username, email)
- Started At
- Duration
- Ended Reason
- IP Address

**Features:**
- Filter by admin, target user, date range
- Export to CSV
- Real-time updates for active sessions

---

## Security Considerations

### Access Control

1. **Admin Verification**
   - All impersonation endpoints verify `is_admin()` before proceeding
   - Admin role stored in database, not JWT (prevents tampering)
   - Supports role hierarchy: support < admin < superadmin

2. **Rate Limiting**
   - Max 10 impersonation starts per admin per hour
   - Implemented at API route level
   - Prevents abuse

3. **Session Timeouts**
   - Impersonation sessions expire after 2 hours
   - Configurable per admin role
   - Auto-logout on expiry

### Audit Trail

1. **Comprehensive Logging**
   - All impersonation starts/ends logged
   - IP address and user agent captured
   - Cannot be deleted (only admins can view)

2. **Monitoring**
   - Alert on multiple failed impersonation attempts
   - Alert on unusual impersonation patterns
   - Weekly summary reports

### Data Protection

1. **Cookie Security**
   - httpOnly prevents JavaScript access
   - Secure flag requires HTTPS
   - SameSite prevents CSRF
   - Signed JWT prevents tampering

2. **RLS Enforcement**
   - Impersonated sessions are real user sessions
   - All RLS policies apply normally
   - No security bypass

### Admin Restrictions

1. **Cannot Impersonate**
   - Other admins (prevents lateral movement)
   - Superadmins (unless requester is superadmin)
   - System accounts

2. **Revocation**
   - Admin privileges can be revoked instantly
   - Active impersonation sessions terminated
   - Audit log preserved

---

## Error Handling

### Common Scenarios

1. **Token Expired**
   - Show error message
   - Redirect to admin dashboard
   - Log failed attempt

2. **Session Timeout**
   - Auto-exit impersonation
   - Show notification
   - Restore admin session

3. **Target User Deleted**
   - End impersonation immediately
   - Show error
   - Update audit log

4. **Network Failure**
   - Retry with exponential backoff
   - Fallback to exit impersonation
   - Log error

---

## Testing Plan

### Unit Tests

- [ ] `is_admin()` function returns correct values
- [ ] `get_admin_role()` handles NULL/revoked admins
- [ ] `log_impersonation_start()` creates audit records
- [ ] `log_impersonation_end()` updates audit records
- [ ] JWT signing/verification for metadata cookie

### Integration Tests

- [ ] Admin can start impersonation
- [ ] Non-admin cannot start impersonation
- [ ] Magic link verification switches session
- [ ] RLS policies apply during impersonation
- [ ] Exit impersonation restores admin session
- [ ] Expired sessions auto-terminate
- [ ] Audit log captures all events

### E2E Tests

- [ ] Full impersonation flow in browser
- [ ] Banner displays correctly
- [ ] Navigation works during impersonation
- [ ] Data access matches target user
- [ ] Exit button restores admin session

---

## Implementation Phases

### Phase 2.2.1: Database Schema (Current)
- [x] Design admin_users table
- [x] Design impersonation_audit table
- [x] Create helper functions (is_admin, get_admin_role)
- [ ] Write SQL migrations
- [ ] Write unit tests for database functions

### Phase 2.2.2: Backend API
- [ ] Implement /api/admin/impersonate/start
- [ ] Implement /api/admin/impersonate/verify
- [ ] Implement /api/admin/impersonate/end
- [ ] Add rate limiting
- [ ] Write API integration tests

### Phase 2.2.3: Frontend UI
- [ ] Create ImpersonationBanner component
- [ ] Add impersonation controls to user list
- [ ] Create audit log viewer
- [ ] Add confirmation dialogs
- [ ] Write E2E tests

### Phase 2.2.4: Security Hardening
- [ ] Add monitoring/alerting
- [ ] Implement session timeouts
- [ ] Add admin restrictions
- [ ] Security audit
- [ ] Penetration testing

---

## Open Questions

1. **Frontend Architecture**
   - Is this a React Native app or web app or both?
   - Where do we implement the backend API? (Next.js API routes? Separate service?)
   - Mobile app impersonation UX considerations?

2. **Admin Provisioning**
   - How are initial admins created? (Manual SQL insert? Seed script?)
   - Self-service role requests? (Requires approval workflow)

3. **Notification**
   - Should target users be notified when impersonated?
   - Email notification to admin after impersonation session?

4. **Permissions**
   - Should some users be "unimpersonable"?
   - Role-based restrictions (support can impersonate regular users, admins can impersonate anyone)?

---

## References

- [Supabase Admin Impersonation (catjam.fi)](https://catjam.fi/articles/supabase-admin-impersonation)
- [Supabase User Impersonation Feature](https://supabase.com/features/user-impersonation)
- [Medium: Supabase Admin Login as User](https://medium.com/@razikus/supabase-admin-login-as-user-get-his-session-d35eedb50e75)
- SUPABASE_AUTH_INTEGRATION_PLAN.md section 2.2
