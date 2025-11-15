# Phase 1: MCP MVP - Read-Only Analytics (Local STDIO)

**Status**: Planning
**Priority**: Medium
**Effort**: Medium (2-3 weeks)
**Labels**: `mcp`, `mvp`, `phase-1`
**Epic**: EPIC_mcp_integration.md
**Depends On**: None (standalone)

## Goal

Build a minimal viable MCP server that allows AI assistants to read and analyze existing workout data through local STDIO transport.

**Key Constraint**: Read-only operations only. No plan creation, no write operations.

## Success Criteria

User can:
1. Ask "How's my squat progress over the last 2 months?" → Get data-driven analysis
2. Ask "What weight should I use for bench press today?" → Get progression-based suggestion
3. Ask "Am I doing too much volume?" → Get volume landmark analysis
4. Run entirely locally (no deployment)

## Scope

### In Scope
- ✅ FastMCP server with STDIO transport
- ✅ Supabase REST API client (prepare for Cloudflare Workers compatibility)
- ✅ Simple authentication (API key via environment variable)
- ✅ Read-only resources (exercise catalog, performance history)
- ✅ Read-only tools (analyze progress, suggest weight, check volume)
- ✅ Local testing with Claude Desktop
- ✅ Documentation for local setup

### Out of Scope
- ❌ HTTP transport (Phase 2)
- ❌ OAuth 2.1 (Phase 2)
- ❌ Plan creation (Phase 3)
- ❌ Write operations (Phase 3)
- ❌ Deployment (Phase 2)
- ❌ Per-user rate limiting (Phase 2)

## Data Limits & Pagination

To prevent overwhelming the LLM context and ensure reasonable query performance:

### Hard Limits
- **History lookback**: Max 365 days per query
- **Sessions per analysis**: Max 200 sessions
- **Sessions per history query**: Max 100 sessions (default 50)
- **Exercise catalog**: Max 1000 exercises

### Pagination Support
All data-heavy endpoints support pagination:
- `limit`: Number of records to return (default varies by endpoint)
- `offset`: Number of records to skip (for fetching next page)

**Example**:
```python
# First page
history = await get_exercise_history("Squat", limit=50, offset=0)

# Second page
history = await get_exercise_history("Squat", limit=50, offset=50)

# Third page
history = await get_exercise_history("Squat", limit=50, offset=100)
```

### Why These Limits?
- **LLM Context**: Claude has token limits - returning 1000 sessions would exceed context window
- **Performance**: Smaller datasets = faster queries and responses
- **User Experience**: LLMs work better with focused, relevant data vs overwhelming dumps
- **Cost**: Fewer tokens = lower API costs for consuming LLM

### Future (Phase 2)
- Add per-user rate limiting (100 req/hour)
- Add query result caching
- Monitor actual usage patterns and adjust limits

## Architecture

### Project Structure

```
mcp_server/
├── pyproject.toml              # UV project config
├── .env.example                # Example environment variables
├── README.md                   # Setup instructions
├── src/
│   └── workout_mcp/
│       ├── __init__.py
│       ├── server.py           # Main MCP server
│       ├── database.py         # Supabase REST API client
│       ├── resources.py        # MCP resources
│       ├── tools.py            # MCP tools
│       ├── prompts.py          # MCP prompts
│       └── config.py           # Configuration
└── tests/
    ├── test_database.py
    ├── test_resources.py
    └── test_tools.py
```

### Technology Choices

| Component | Choice | Rationale |
|-----------|--------|-----------|
| Package Manager | UV | Project standard |
| Database Client | Supabase REST API | Prepares for Cloudflare Workers, works locally too |
| HTTP Client | httpx | Async support, well-maintained |
| MCP Framework | FastMCP 2.0+ | Official Python SDK |
| Testing | pytest + pytest-asyncio | Standard Python testing |
| Auth (MVP) | API key (env var) | Simple for local use |

### Environment Variables

```bash
# .env.example
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-role-key  # For testing only
```

**Security Note**: For MVP, we use Supabase anon key + RLS. User must provide their own JWT token (obtained via Supabase auth separately). In Phase 2, we'll implement full OAuth flow.

## Implementation

### 1. Database Client (`database.py`)

```python
"""Supabase REST API client for MCP server"""
import os
from typing import Any, Optional
import httpx
from datetime import datetime, timedelta

class SupabaseClient:
    """
    Async client for Supabase REST API (PostgREST).

    Uses REST API to ensure compatibility with Cloudflare Workers
    (Pyodide cannot use native PostgreSQL drivers).
    """

    def __init__(self, url: str, anon_key: str):
        self.url = url.rstrip('/') + '/rest/v1'
        self.anon_key = anon_key
        self.client = httpx.AsyncClient(
            headers={
                'apikey': anon_key,
                'Content-Type': 'application/json'
            },
            timeout=10.0
        )

    def with_user_auth(self, jwt_token: str) -> 'SupabaseClient':
        """Return new client with user JWT for RLS"""
        client = SupabaseClient(self.url.replace('/rest/v1', ''), self.anon_key)
        client.client.headers['Authorization'] = f'Bearer {jwt_token}'
        return client

    async def query(
        self,
        table: str,
        select: str = '*',
        filters: Optional[dict] = None,
        order: Optional[str] = None,
        limit: Optional[int] = None,
        offset: Optional[int] = None
    ) -> list[dict[str, Any]]:
        """
        Query a table using PostgREST syntax with pagination support.

        Example:
            results = await db.query(
                'exercise_stats',
                select='name,weight,volume_kg,completed_at',
                filters={'name': 'eq.Squat'},
                order='completed_at.desc',
                limit=10,
                offset=0  # For pagination
            )
        """
        params = {'select': select}

        if filters:
            for key, value in filters.items():
                params[key] = value

        if order:
            params['order'] = order

        if limit:
            params['limit'] = str(limit)

        if offset:
            params['offset'] = str(offset)

        response = await self.client.get(f'{self.url}/{table}', params=params)
        response.raise_for_status()
        return response.json()

    async def call_rpc(self, function: str, params: dict) -> Any:
        """Call a PostgreSQL function via RPC"""
        response = await self.client.post(
            f'{self.url}/rpc/{function}',
            json=params
        )
        response.raise_for_status()
        return response.json()

    async def close(self):
        await self.client.aclose()
```

### 2. Resources (`resources.py`)

```python
"""MCP resources - read-only data endpoints"""
from fastmcp import FastMCP
from .database import SupabaseClient
from .config import get_db_client

mcp = FastMCP("Workout Coach")

@mcp.resource("workout://exercises/catalog")
async def get_exercise_catalog() -> str:
    """
    Browse all available exercises with metadata.

    Returns exercises with:
    - Names and aliases
    - Muscle groups (primary and secondary)
    - Equipment requirements
    - Exercise category
    - Links to demonstrations
    """
    db = get_db_client()

    # Query base_exercise_full view
    exercises = await db.query(
        'base_exercise_full',
        select='name,description,muscle_groups,equipment,category,links',
        order='name.asc',
        limit=1000  # Prevent huge responses
    )

    # Format for LLM consumption
    result = "# Exercise Catalog\n\n"
    for ex in exercises:
        result += f"## {ex['name']}\n"
        result += f"- **Muscles**: {', '.join(ex.get('muscle_groups', []))}\n"
        result += f"- **Equipment**: {ex.get('equipment', 'None')}\n"
        result += f"- **Category**: {ex.get('category', 'Unknown')}\n"
        if ex.get('description'):
            result += f"- **Description**: {ex['description']}\n"
        result += "\n"

    return result


@mcp.resource("workout://performance/history/{exercise_name}")
async def get_exercise_history(
    exercise_name: str,
    user_token: str,
    days: int = 90,
    limit: int = 50,
    offset: int = 0
) -> str:
    """
    Get historical performance data for a specific exercise (paginated).

    Args:
        exercise_name: Name of the exercise (e.g., "Squat")
        user_token: User's JWT token (for RLS)
        days: How many days of history (default 90, max 365)
        limit: Number of records to return (default 50, max 100)
        offset: Number of records to skip for pagination (default 0)

    Returns:
        Performance history including:
        - Volume (kg)
        - Estimated 1RM (Brzycki formula)
        - Reps and sets
        - Weight progression
        - Date performed

    Example usage:
        - First page: offset=0, limit=50
        - Second page: offset=50, limit=50
        - For all history beyond 365 days, make multiple paginated requests
    """
    # Apply limits to prevent overwhelming LLM context
    if days > 365:
        days = 365
    if limit > 100:
        limit = 100
    if limit < 1:
        limit = 50

    db = get_db_client().with_user_auth(user_token)

    # Query exercise_stats view (has RLS) with pagination
    stats = await db.query(
        'exercise_stats',
        select='name,weight,volume_kg,brzycki_1_rm_max,reps,completed_at,note',
        filters={
            'name': f'ilike.%{exercise_name}%',
            'completed_at': f'gte.{(datetime.now() - timedelta(days=days)).isoformat()}'
        },
        order='completed_at.desc',
        limit=limit,
        offset=offset
    )

    if not stats:
        return f"No performance history found for '{exercise_name}' in the last {days} days."

    # Format for LLM with pagination info
    result = f"# Performance History: {exercise_name} ({days} days)\n\n"
    result += f"**Showing {len(stats)} workouts** (offset: {offset}, limit: {limit})\n"

    # Pagination hint
    if len(stats) == limit:
        result += f"_Note: More data may be available. Use offset={offset + limit} to fetch next page._\n"

    result += "\n"

    for session in stats:
        result += f"## {session['completed_at'][:10]}\n"
        result += f"- Weight: {session['weight'] / 1000:.1f} kg\n"
        result += f"- Reps: {session['reps']}\n"
        result += f"- Volume: {session['volume_kg']:.1f} kg\n"
        result += f"- Est. 1RM: {session.get('brzycki_1_rm_max', 'N/A')} kg\n"
        if session.get('note'):
            result += f"- Note: {session['note']}\n"
        result += "\n"

    return result
```

### 3. Tools (`tools.py`)

```python
"""MCP tools - executable actions (read-only for MVP)"""
from fastmcp import FastMCP
from .database import SupabaseClient
from .config import get_db_client
from datetime import datetime, timedelta
from typing import Optional

mcp = FastMCP("Workout Coach")

@mcp.tool()
async def analyze_progress(
    exercise_name: str,
    user_token: str,
    time_period_days: int = 30,
    max_sessions: int = 100
) -> dict:
    """
    Analyze progression trend for an exercise.

    Args:
        exercise_name: Exercise to analyze (e.g., "Bench Press")
        user_token: User's JWT token
        time_period_days: Analysis period in days (default 30, max 365)
        max_sessions: Maximum number of sessions to analyze (default 100, max 200)

    Returns:
        Dictionary containing:
        - volume_trend: Increasing, stable, or decreasing
        - avg_volume: Average volume per workout (kg)
        - one_rm_trend: 1RM progression trend
        - frequency: Workouts per week
        - last_workout: Date of last workout
        - sessions_analyzed: Number of sessions included in analysis
        - recommendation: Suggested action
    """
    # Apply limits to prevent overwhelming analysis
    if time_period_days > 365:
        time_period_days = 365
    if max_sessions > 200:
        max_sessions = 200

    db = get_db_client().with_user_auth(user_token)

    stats = await db.query(
        'exercise_stats',
        select='name,weight,volume_kg,brzycki_1_rm_max,completed_at',
        filters={
            'name': f'ilike.%{exercise_name}%',
            'completed_at': f'gte.{(datetime.now() - timedelta(days=time_period_days)).isoformat()}'
        },
        order='completed_at.desc',
        limit=max_sessions  # Limit sessions for analysis
    )

    if not stats:
        return {
            'error': f'No data found for {exercise_name} in last {time_period_days} days'
        }

    # Calculate metrics
    volumes = [s['volume_kg'] for s in stats]
    one_rms = [s.get('brzycki_1_rm_max', 0) for s in stats if s.get('brzycki_1_rm_max')]

    avg_volume = sum(volumes) / len(volumes)
    frequency = len(stats) / (time_period_days / 7)

    # Simple trend detection
    if len(volumes) >= 2:
        recent_avg = sum(volumes[:len(volumes)//2]) / (len(volumes)//2)
        older_avg = sum(volumes[len(volumes)//2:]) / (len(volumes) - len(volumes)//2)
        volume_trend = 'increasing' if recent_avg > older_avg * 1.1 else \
                      'decreasing' if recent_avg < older_avg * 0.9 else 'stable'
    else:
        volume_trend = 'insufficient_data'

    # 1RM trend
    if len(one_rms) >= 2:
        recent_1rm = sum(one_rms[:len(one_rms)//2]) / (len(one_rms)//2)
        older_1rm = sum(one_rms[len(one_rms)//2:]) / (len(one_rms) - len(one_rms)//2)
        one_rm_trend = 'increasing' if recent_1rm > older_1rm * 1.05 else \
                       'decreasing' if recent_1rm < older_1rm * 0.95 else 'stable'
    else:
        one_rm_trend = 'insufficient_data'

    return {
        'exercise': exercise_name,
        'time_period_days': time_period_days,
        'sessions_analyzed': len(stats),
        'max_sessions_limit': max_sessions,
        'frequency_per_week': round(frequency, 1),
        'avg_volume_kg': round(avg_volume, 1),
        'volume_trend': volume_trend,
        'one_rm_trend': one_rm_trend,
        'last_workout': stats[0]['completed_at'] if stats else None,
        'recommendation': _generate_recommendation(volume_trend, one_rm_trend, frequency)
    }


def _generate_recommendation(volume_trend: str, one_rm_trend: str, frequency: float) -> str:
    """Generate training recommendation based on trends"""
    if one_rm_trend == 'increasing':
        return "Great progress! Keep up current training approach."
    elif one_rm_trend == 'stable' and volume_trend == 'increasing':
        return "Volume increasing but strength plateaued. Consider deload or intensity work."
    elif one_rm_trend == 'decreasing':
        return "Strength declining. Check recovery, nutrition, or consider deload week."
    elif frequency < 1.0:
        return "Low training frequency. Consider increasing to at least 2x per week for optimal gains."
    else:
        return "Insufficient data for specific recommendation. Continue training consistently."


@mcp.tool()
async def suggest_next_weight(
    exercise_name: str,
    user_token: str,
    target_reps: int = 10
) -> dict:
    """
    Suggest next workout weight based on recent performance.

    Args:
        exercise_name: Exercise name
        user_token: User JWT token
        target_reps: Target rep range (default 10)

    Returns:
        Suggested weight and reasoning
    """
    db = get_db_client().with_user_auth(user_token)

    # Get recent performance + exercise config
    stats = await db.query(
        'exercise_stats',
        select='name,weight,reps,step_increment,completed_at',
        filters={'name': f'ilike.%{exercise_name}%'},
        order='completed_at.desc',
        limit=3
    )

    if not stats:
        return {'error': f'No previous data for {exercise_name}'}

    last = stats[0]
    current_weight_g = last['weight']
    last_reps = last['reps']
    step_increment = last.get('step_increment', 2500)  # Default 2.5kg

    # Simple progression logic
    if len(last_reps) >= 3 and all(r >= target_reps for r in last_reps[-3:]):
        # Hit target reps on last 3 sets -> increase weight
        suggested_weight_g = current_weight_g + step_increment
        reason = f"Hit {target_reps}+ reps on last 3 sets. Time to progress!"
    elif max(last_reps) < target_reps - 2:
        # Struggling -> decrease weight
        suggested_weight_g = current_weight_g - step_increment
        reason = "Struggling with current weight. Reduce to build back up."
    else:
        # Maintain current weight
        suggested_weight_g = current_weight_g
        reason = "Continue with current weight until consistent form."

    return {
        'exercise': exercise_name,
        'current_weight_kg': current_weight_g / 1000,
        'suggested_weight_kg': suggested_weight_g / 1000,
        'target_reps': target_reps,
        'last_performance': last_reps,
        'reason': reason
    }
```

### 4. Main Server (`server.py`)

```python
"""Main MCP server entry point"""
import os
from fastmcp import FastMCP
from .resources import mcp as resources_mcp
from .tools import mcp as tools_mcp
from .config import init_config

# Initialize configuration
init_config()

# Create main MCP server
mcp = FastMCP("Workout Coach")

# Register resources and tools from other modules
# (FastMCP will auto-discover decorators)

if __name__ == "__main__":
    # For local STDIO transport
    mcp.run(transport="stdio")
```

### 5. Configuration (`config.py`)

```python
"""Configuration management"""
import os
from typing import Optional
from .database import SupabaseClient

_db_client: Optional[SupabaseClient] = None

def init_config():
    """Initialize configuration from environment"""
    global _db_client

    supabase_url = os.getenv('SUPABASE_URL')
    supabase_key = os.getenv('SUPABASE_ANON_KEY')

    if not supabase_url or not supabase_key:
        raise ValueError(
            "Missing required environment variables: "
            "SUPABASE_URL and SUPABASE_ANON_KEY"
        )

    _db_client = SupabaseClient(supabase_url, supabase_key)

def get_db_client() -> SupabaseClient:
    """Get configured database client"""
    if _db_client is None:
        raise RuntimeError("Config not initialized. Call init_config() first.")
    return _db_client
```

### 6. Package Configuration (`pyproject.toml`)

```toml
[project]
name = "workout-mcp"
version = "0.1.0"
description = "MCP server for workout tracking and AI coaching"
requires-python = ">=3.10"
dependencies = [
    "fastmcp>=2.0.0",
    "httpx>=0.27.0",
    "python-dateutil>=2.8.2"
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "pytest-asyncio>=0.23.0",
    "pytest-mock>=3.12.0",
    "black>=24.0.0",
    "ruff>=0.1.0"
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[tool.pytest.ini_options]
asyncio_mode = "auto"
testpaths = ["tests"]

[tool.black]
line-length = 100
target-version = ["py310"]

[tool.ruff]
line-length = 100
select = ["E", "F", "I"]
```

## User Authentication Flow (MVP)

For MVP, we use a simplified auth flow:

1. User obtains JWT token from Supabase (via web app or CLI)
2. User configures Claude Desktop MCP settings:
   ```json
   {
     "mcpServers": {
       "workout": {
         "command": "uv",
         "args": ["run", "python", "-m", "workout_mcp.server"],
         "env": {
           "SUPABASE_URL": "https://your-project.supabase.co",
           "SUPABASE_ANON_KEY": "your-anon-key",
           "USER_JWT_TOKEN": "user-jwt-token-here"
         }
       }
     }
   }
   ```
3. MCP server uses `USER_JWT_TOKEN` for RLS-protected queries

**Note**: Phase 2 will replace this with proper OAuth flow.

## Testing Strategy

### Unit Tests

```python
# tests/test_tools.py
import pytest
from workout_mcp.tools import analyze_progress
from unittest.mock import AsyncMock, patch

@pytest.mark.asyncio
async def test_analyze_progress():
    mock_stats = [
        {'name': 'Squat', 'volume_kg': 1000, 'brzycki_1_rm_max': 150, 'completed_at': '2025-01-01'},
        {'name': 'Squat', 'volume_kg': 1100, 'brzycki_1_rm_max': 155, 'completed_at': '2025-01-08'},
    ]

    with patch('workout_mcp.tools.get_db_client') as mock_db:
        mock_db.return_value.with_user_auth.return_value.query = AsyncMock(return_value=mock_stats)

        result = await analyze_progress('Squat', 'fake-token', 30)

        assert result['total_workouts'] == 2
        assert result['one_rm_trend'] == 'increasing'
```

### Integration Tests (with real Supabase)

```python
# tests/integration/test_real_db.py
import pytest
import os
from workout_mcp.database import SupabaseClient

@pytest.mark.integration
@pytest.mark.asyncio
async def test_query_exercise_catalog():
    """Test against real Supabase instance"""
    client = SupabaseClient(
        os.getenv('SUPABASE_URL'),
        os.getenv('SUPABASE_ANON_KEY')
    )

    exercises = await client.query('base_exercise', limit=10)
    assert len(exercises) > 0
    assert 'name' in exercises[0]
```

### Manual Testing with Claude Desktop

1. Install Claude Desktop
2. Configure MCP server in settings
3. Test queries:
   - "Show me all exercises for chest"
   - "How's my bench press progress?"
   - "What weight should I use for squats?"

## Documentation

### README.md

Include:
- Installation instructions (UV setup)
- Environment variable configuration
- Claude Desktop integration steps
- Example queries
- Troubleshooting guide

### API Documentation

Generate from docstrings:
```bash
uv run python -m pydoc workout_mcp.tools
```

## Acceptance Criteria

- [ ] Project structure created with UV
- [ ] Supabase REST API client implemented
- [ ] All resources implemented (exercise catalog, history)
- [ ] All tools implemented (analyze, suggest weight)
- [ ] Unit tests pass (>80% coverage)
- [ ] Integration tests pass
- [ ] Manual testing with Claude Desktop successful
- [ ] Documentation complete
- [ ] Code formatted (black) and linted (ruff)
- [ ] Can answer all success criteria questions

## Deliverables

1. **Code**: Complete Phase 1 implementation
2. **Tests**: Unit + integration tests
3. **Documentation**: README with setup guide
4. **Demo**: Screen recording showing Claude Desktop integration
5. **Migration Notes**: Document any schema assumptions or requirements

## Future Work (Phase 2)

- HTTP transport for remote access
- OAuth 2.1 authentication
- Deployment to Railway/Fly.io
- Rate limiting
- Enhanced error handling

## References

- [FastMCP Documentation](https://gofastmcp.com/)
- [Supabase REST API](https://supabase.com/docs/guides/api)
- [Claude Desktop MCP](https://docs.claude.com/claude-code)
- Epic: `EPIC_mcp_integration.md`
