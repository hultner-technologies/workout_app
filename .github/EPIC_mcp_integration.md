# Epic: MCP (Model Context Protocol) Integration for AI-Powered Workout Assistance

**Status**: Planning
**Priority**: Medium
**Effort**: Large (multi-phase)
**Labels**: `epic`, `mcp`, `ai-integration`, `oauth`, `enhancement`

## Executive Summary

Add a Model Context Protocol (MCP) server to enable AI assistants (like Claude) to interact with workout data through natural language. This allows users to ask questions about their progress, get workout suggestions, and create personalized plans through AI conversation.

**Important**: The MCP server provides data and tools to consuming LLMs (like Claude). The server itself does NOT contain AI/LLM logic - all coaching intelligence comes from the consuming AI.

## What is MCP?

Model Context Protocol is a standardized way to connect AI assistants to external data sources and tools. Think of it as "REST API for AI assistants" - it provides:

- **Resources**: Read-only data (exercise history, performance metrics)
- **Tools**: Actions the AI can execute (create plans, analyze trends)
- **Prompts**: Templates for common scenarios (suggest deload week)

## Current State

The workout app has:
- Rich performance analytics (volume tracking, Brzycki 1RM, progression views)
- Comprehensive exercise database with metadata (muscles, equipment, categories)
- Detailed session tracking with temporal data
- Supabase backend with Row Level Security (RLS)
- Existing authentication system

**Missing**: User-specific plans (currently all plans are global/shared)

## Proposed Architecture

### Technology Stack

| Component | Choice | Rationale |
|-----------|--------|-----------|
| **MCP Framework** | FastMCP (Python) | Official Python SDK, type-hint based, supports HTTP transport |
| **Hosting** | TBD - See ADR | Pyodide limitations require careful evaluation |
| **Database Access** | Supabase REST API | Pyodide can't use native PostgreSQL drivers |
| **Authentication** | Supabase Auth + OAuth 2.1 | Reuse existing auth, MCP spec requires OAuth 2.1 |
| **Package Manager** | UV | Project standard (see branch/PR for migration) |
| **Transport** | STDIO + HTTP | Both supported in same implementation |

### Critical Finding: Pyodide Limitations

**Research shows**: Cloudflare Workers use Pyodide (Python via WebAssembly) which **cannot** use native PostgreSQL drivers (psycopg2, asyncpg).

**Workaround**: Use Supabase REST API (PostgREST) via HTTP calls. This works but adds latency.

**Implication**: We need a clear path to migrate away from Cloudflare Workers if REST API proves too slow. See Architecture Decision Record below.

### Transport Support: STDIO + HTTP

The same MCP server can support both:

**STDIO (Local Development)**
- No network authentication needed
- Client launches server as subprocess
- Credentials via environment variables
- Perfect for local testing
- Zero cost

**HTTP (Production)**
- Requires OAuth 2.1 authentication
- Remote access via URL
- Network security (HTTPS, CORS, Origin validation)
- Deployed on cloud hosting
- Usage-based costs

**Security**: STDIO relies on OS process permissions, HTTP requires full OAuth flow.

## Core Capabilities

### Resources (Read-Only Data)

```python
@mcp.resource("workout://exercises/catalog")
async def get_exercise_catalog():
    """Browse all exercises with metadata (muscles, equipment, categories)"""

@mcp.resource("workout://performance/history/{exercise_name}")
async def get_exercise_history(exercise_name: str, days: int = 90):
    """Historical performance data for specific exercise"""

@mcp.resource("workout://plans/available")
async def get_available_plans():
    """List public/system plans + user's own plans"""
```

### Tools (Executable Actions)

```python
@mcp.tool()
async def analyze_progress(
    exercise_name: str,
    time_period_days: int = 30
) -> dict:
    """
    Analyze progression trend for an exercise.
    Returns volume trends, 1RM progression rate, training frequency.
    """

@mcp.tool()
async def suggest_next_weight(
    exercise_name: str,
    target_reps: int = 10
) -> dict:
    """
    Suggest next workout weight based on recent performance.
    Uses exercise step_increment and progression_limit.
    """

@mcp.tool()
async def create_workout_plan(
    name: str,
    sessions: list[dict],
    duration_weeks: int,
    visibility: str = "private"
) -> str:
    """
    Create a new workout plan for the user.
    Returns user_plan_id.
    """

@mcp.tool()
async def check_volume_landmarks(
    muscle_group: str
) -> dict:
    """
    Check if user is within healthy volume ranges (MEV-MRV).
    Based on Israetel's volume landmarks research.
    """
```

### Prompts (Templates)

```python
@mcp.prompt()
async def suggest_deload():
    """Template for AI to suggest deload week"""
    return {
        "messages": [{
            "role": "user",
            "content": "Analyze my recent training and suggest if I need a deload week."
        }],
        "context": await get_recent_sessions(weeks=4)
    }
```

## Volume Landmarks

Volume landmarks (by Dr. Mike Israetel, Renaissance Periodization) are evidence-based training volume ranges:

- **MV (Maintenance Volume)**: ~6 sets/muscle/week - minimum to maintain muscle mass
- **MEV (Minimum Effective Volume)**: Minimum to grow (varies by trainee)
- **MAV (Maximum Adaptive Volume)**: Optimal growth range (between MEV and MRV)
- **MRV (Maximum Recoverable Volume)**: Upper limit before overtraining

The MCP server can check if user's volume falls within healthy ranges and warn about potential overtraining.

## Database Changes

### Problem: No User-Specific Plans

Current `plan` table has no user relationship. All plans are global/shared.

### Solution: Dual-Table Design

**Option A**: Extend `plan` table (rejected - mixing concerns, harder RLS)

**Option B**: Separate tables ✅

```sql
-- Keep existing table for system/public plans
-- (No changes - backwards compatible)
CREATE TABLE plan (
    plan_id uuid PRIMARY KEY,
    name text NOT NULL,
    description text,
    is_system boolean DEFAULT false,  -- NEW: mark first-party plans
    visibility text DEFAULT 'public' CHECK (visibility IN ('public', 'unlisted')),
    ...
);

-- New table for user-created plans
CREATE TABLE user_plan (
    user_plan_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY,
    app_user_id uuid REFERENCES app_user(app_user_id) NOT NULL,
    based_on_plan_id uuid REFERENCES plan(plan_id),  -- NULL if fully custom
    name text NOT NULL,
    description text,
    visibility text DEFAULT 'private' CHECK (visibility IN ('private', 'shared', 'public')),
    created_by text DEFAULT 'user' CHECK (created_by IN ('user', 'ai')),
    created_at timestamp DEFAULT now(),
    starts_at timestamp,
    ends_at timestamp,
    is_active boolean DEFAULT false,
    data jsonb  -- AI metadata, customizations, sharing settings
);

-- RLS Policy
ALTER TABLE user_plan ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own plans" ON user_plan
    USING (app_user_id = auth.uid())
    WITH CHECK (app_user_id = auth.uid());

-- View combining both for easy querying
CREATE VIEW all_plans AS
SELECT
    plan_id as id,
    name,
    description,
    'system' as source,
    NULL::uuid as owner_id,
    visibility,
    is_system as first_party
FROM plan
UNION ALL
SELECT
    user_plan_id as id,
    name,
    description,
    'user' as source,
    app_user_id as owner_id,
    visibility,
    false as first_party
FROM user_plan;
```

**Future**: Add sharing/following features:
- `user_plan.data` could store `shared_with_users: [uuid]`
- Could add `user_follows` table for following other users
- Privacy settings: private (only me), shared (specific users), public (anyone)

## Rate Limiting & Cost Control

### Problem
Unrestricted MCP access could cause:
- Supabase quota overruns (RLS queries are expensive)
- High hosting costs
- Database overload from AI making too many queries

### Solution: Multi-Layer Rate Limiting

```python
# 1. Per-User Rate Limiting (in MCP server)
from datetime import datetime, timedelta
from collections import defaultdict

user_request_counts = defaultdict(list)

def check_rate_limit(user_id: str) -> bool:
    """Allow 100 requests per hour per user"""
    now = datetime.now()
    hour_ago = now - timedelta(hours=1)

    # Clean old requests
    user_request_counts[user_id] = [
        ts for ts in user_request_counts[user_id]
        if ts > hour_ago
    ]

    if len(user_request_counts[user_id]) >= 100:
        raise RateLimitError("Rate limit exceeded: 100 requests/hour")

    user_request_counts[user_id].append(now)
    return True

# 2. Query Result Limits
async def get_exercise_history(exercise_name: str, days: int = 90):
    """Limit historical data to prevent huge queries"""
    if days > 365:
        days = 365  # Hard cap at 1 year
    # Query database with LIMIT clause

# 3. Resource-Specific Limits
LIMITS = {
    "exercises": 1000,  # Max exercises to return
    "sessions": 100,    # Max sessions in one query
    "history_days": 365  # Max lookback period
}

# 4. User-Configurable Preferences
# Store in app_user.data:
{
    "mcp_settings": {
        "max_history_days": 90,  # User preference: 30, 90, 180, 365
        "include_notes": true,    # User configurable
        "rate_limit_notify": true  # Warn when approaching limit
    }
}
```

### Hosting Platform Limits

Each platform has built-in rate limiting (see hosting comparison below).

**Best Practice**: Implement rate limiting in MCP server code, not relying on platform limits (which would return 429 errors without context).

## Use Cases

### 1. Progress Analysis
**User**: "How's my bench press progress over the last 2 months?"
**AI** (via MCP): Calls `get_exercise_history("Bench Press", days=60)` → Analyzes volume trends, 1RM progression, frequency → Returns insights

### 2. Weight Suggestion
**User**: "What weight should I use for squats today?"
**AI**: Calls `suggest_next_weight("Squat")` → Returns suggested weight based on recent performance and step_increment

### 3. Plateau Detection
**User**: "I feel stuck on overhead press"
**AI**: Calls `analyze_progress("Overhead Press", days=56)` → Detects stalled 1RM → Suggests deload or exercise variation

### 4. Plan Creation
**User**: "Create me a 4-day upper/lower split"
**AI**: Calls `create_workout_plan(name="4-Day Upper/Lower", sessions=[...])` → Creates user_plan → Returns plan_id

### 5. Volume Check
**User**: "Am I doing too much volume for chest?"
**AI**: Calls `check_volume_landmarks("chest")` → Compares current volume to MEV/MAV/MRV ranges → Warns if approaching MRV

### 6. Recovery Guidance
**User**: "I'm feeling burned out"
**AI**: Uses `suggest_deload` prompt → Analyzes recent sessions → Recommends 50-60% volume reduction for 1 week

## Implementation Phases

### Pre-Requisites (Separate Issues)
- [ ] Issue #XXX: Design and implement `user_plan` table schema
- [ ] Issue #XXX: Set up Supabase OAuth 2.1 configuration
- [ ] Issue #XXX: Create `all_plans` view combining system and user plans

### Phase 1: MVP - Read-Only Analytics (Issue #XXX)
**Goal**: AI can read and analyze existing workout data

**Scope**:
- STDIO transport only (local development)
- Simple API key auth (env var)
- Read-only resources and tools
- No plan creation yet

**Deliverables**:
- FastMCP server with Supabase REST API client
- Resources: exercise catalog, performance history
- Tools: `analyze_progress`, `suggest_next_weight`
- Local testing with Claude Desktop
- Documentation for local setup

**Success**: User can ask "How's my squat progress?" and get data-driven answer

### Phase 2: HTTP Transport + OAuth 2.1 (Issue #XXX)
**Goal**: Secure production deployment with proper authentication

**Scope**:
- Add HTTP transport (streamable-http)
- Implement OAuth 2.1 flow
- Deploy to hosting platform (see ADR)
- Add rate limiting

**Deliverables**:
- OAuth 2.1 authorization endpoints
- JWT token validation
- HTTP server deployment
- Rate limiting middleware
- Production documentation

**Success**: User can authorize MCP server via Supabase OAuth from Claude Desktop

### Phase 3: User Plans - Write Operations (Issue #XXX)
**Goal**: AI can create personalized workout plans

**Scope**:
- Implement `user_plan` table (from pre-req)
- Add write tools: `create_workout_plan`, `modify_plan`
- Plan management resources
- Template system (based on existing plans)

**Deliverables**:
- Plan creation tools
- Plan validation logic
- Templates from existing system plans
- User plan management

**Success**: User can say "Create a 3-day push/pull/legs" and AI generates valid plan

### Phase 4: Registry Publication (Issue #XXX)
**Goal**: Make server discoverable in MCP ecosystem

**Scope**:
- Package for PyPI (using UV)
- Create `server.json` metadata
- Publish to MCP.io registry
- Documentation and examples

**Deliverables**:
- PyPI package
- MCP registry listing
- Setup documentation
- Demo video

**Success**: Server appears in MCP registry, installable via `mcp install`

## Non-Goals (Out of Scope)

- ❌ AI coaching logic in server (LLM does this)
- ❌ Real-time workout tracking (still in app)
- ❌ Exercise video analysis
- ❌ Social features
- ❌ Nutrition tracking
- ❌ Wearable device integration
- ❌ Mobile app changes

## Open Questions & Decisions

### 1. Coaching Intelligence Location
**Decision**: Option B - Server returns data, consuming LLM analyzes
**Rationale**: Simpler, no LLM costs in server, leverages Claude's knowledge
**Status**: ✅ Decided

### 2. Plan Table Design
**Decision**: Dual-table design (system plans + user plans)
**Rationale**: Clean separation, backwards compatible, clearer security
**Status**: ✅ Decided - needs detailed schema design (pre-req issue)

### 3. Exercise Recommendations
**Question**: How to balance AI creativity vs evidence-based programming?
**Approach**: Provide volume landmarks context to consuming LLM, let it make informed decisions
**Status**: ⏳ To be validated in Phase 1

### 4. Data Privacy - Notes Access
**Decision**: User-configurable via `app_user.data.mcp_settings.include_notes`
**Default**: Include notes (useful for form feedback)
**Status**: ✅ Decided

### 5. Rate Limiting Strategy
**Question**: Where to implement rate limiting?
**Decision**: In MCP server code (100 req/hour/user)
**Rationale**: Consistent across hosting platforms, better error messages
**Status**: ✅ Decided

### 6. Python Library Limitations (Pyodide)
**Question**: Will Cloudflare Workers work with our stack?
**Research**: Pyodide cannot use native PostgreSQL drivers
**Decision**: Use Supabase REST API + maintain migration path
**Status**: ✅ Decided - see Architecture Decision Record

### 7. Auth Gateway Hosting
**Question**: Does OAuth gateway need separate hosting?
**Answer**: No, can be part of same MCP server package
**Implementation**: FastMCP server includes OAuth endpoints
**Status**: ✅ Decided

### 8. Local STDIO + Remote HTTP
**Question**: Can same server support both transports?
**Answer**: Yes, FastMCP supports both in same implementation
**Security**: STDIO skips OAuth (local trust), HTTP requires full OAuth
**Status**: ✅ Decided

## Success Metrics

### Technical
- [ ] Server responds to MCP discovery requests
- [ ] OAuth flow completes end-to-end
- [ ] All tools execute within 2 seconds (p95)
- [ ] Zero authentication bypasses
- [ ] Rate limiting prevents abuse
- [ ] Published in MCP registry

### User Experience
- [ ] Users can analyze progress via AI
- [ ] AI creates valid workout plans
- [ ] Zero data leaks between users (RLS validation)
- [ ] User feedback is positive

### Adoption
- [ ] 10+ users connect MCP server
- [ ] 100+ AI interactions
- [ ] 5+ user-created plans via AI

## Related Issues

- [ ] Pre-req #XXX: Design `user_plan` table schema
- [ ] Pre-req #XXX: Set up Supabase OAuth 2.1
- [ ] Pre-req #XXX: Create `all_plans` view
- [ ] Phase 1 #XXX: MVP - Read-only analytics
- [ ] Phase 2 #XXX: HTTP transport + OAuth
- [ ] Phase 3 #XXX: User plans + write operations
- [ ] Phase 4 #XXX: MCP registry publication
- [ ] ADR #XXX: Hosting platform decision

## References

- [MCP Specification](https://modelcontextprotocol.io/)
- [FastMCP Documentation](https://gofastmcp.com/)
- [Supabase Auth OAuth](https://supabase.com/docs/guides/getting-started/mcp)
- [Volume Landmarks Research](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth)
- [MCP Registry](https://github.com/modelcontextprotocol/registry)
- [OAuth 2.1 for MCP](https://modelcontextprotocol.io/specification/draft/basic/authorization)
