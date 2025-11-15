# Testing Infrastructure Plan

**Date:** 2025-11-14
**Goal:** Set up pytest-based testing for database functions and Supabase API
**Target:** Python 3.13, local Supabase instance

## Overview

Create a comprehensive test suite with two testing approaches:
1. **Fast unit tests** - Direct PostgreSQL via asyncpg (transaction-based, parallel)
2. **Integration tests** - Supabase HTTP API via supabase-py (realistic, sequential)

## Architecture

```
workout_app/
├── tests/
│   ├── conftest.py                    # Shared fixtures and setup
│   ├── database/                      # Fast unit tests (direct DB)
│   │   ├── __init__.py
│   │   ├── test_empty_workouts.py    # PR #1: Empty workout support
│   │   ├── test_rls_policies.py      # PR #1: RLS security
│   │   └── test_views.py             # View functionality
│   └── integration/                   # Integration tests (HTTP API)
│       ├── __init__.py
│       ├── test_api_empty_workouts.py # Via Supabase client
│       └── test_api_rls_security.py   # Real RLS via HTTP
├── tests/settings.py                 # Pydantic settings layer (.env aware)
├── pyproject.toml                     # uv-managed dependencies
├── uv.lock                            # Locked dependency graph
└── pytest.ini                         # Pytest configuration
```

## Dependencies

**Core:**
- Python 3.13
- pytest >= 9.0 (parallel-friendly)
- pytest-asyncio >= 1.3
- pytest-xdist (parallel execution)

**Database:**
- asyncpg >= 0.30 (direct PostgreSQL)
- supabase >= 2.24 (HTTP API client aligned with Pydantic v2)

**Development:**
- pytest-cov (coverage reporting)
- pytest-timeout (prevent hanging tests)
- pydantic-settings + python-dotenv for configuration management

## Configuration

`tests/settings.py` centralizes configuration through `pydantic-settings.BaseSettings`. It loads
values from environment variables (first) and `.env` (fallback) via `python-dotenv`. Defaults match
the Supabase CLI stack, but everything can be overridden:

```dotenv
# tests/settings.py picks these up automatically
TEST_PG_HOST=127.0.0.1
TEST_PG_PORT=54322
TEST_PG_USER=postgres
TEST_PG_PASSWORD=postgres
TEST_PG_DATABASE=postgres

TEST_SUPABASE_URL=http://127.0.0.1:54321
TEST_SUPABASE_ANON_KEY=...
TEST_SUPABASE_SERVICE_ROLE_KEY=...
```

## Test Strategy

### Unit Tests (tests/database/)

**Characteristics:**
- Direct PostgreSQL connection via asyncpg
- Each test wrapped in transaction (automatic rollback)
- Run in parallel with `pytest -n auto`
- Target: ~100ms per test

**Example:**
```python
@pytest.mark.asyncio
async def test_empty_workout_returns_one_row(db_transaction):
    """PR #1: Empty workouts should return 1 row with exercises=[]"""
    # Setup
    session_id = await db_transaction.fetchval("""
        INSERT INTO performed_session (app_user_id, session_schedule_id, started_at)
        SELECT app_user_id, session_schedule_id, now()
        FROM app_user, session_schedule
        WHERE app_user.email = 'dev@example.com'
        AND session_schedule.name = 'Day A - Push'
        LIMIT 1
        RETURNING performed_session_id
    """)

    # Test
    result = await db_transaction.fetchrow(
        "SELECT * FROM draft_session_exercises_v2($1)",
        session_id
    )

    # Assert
    assert result['has_exercises'] is False
    assert result['exercise_count'] == 0
    assert result['exercises'] == []
```

**Scope:**
- All database functions (draft_session_exercises_v2, performed_session_details, etc.)
- Views (session_schedule_with_exercises)
- Data integrity constraints
- Function error handling

### Integration Tests (tests/integration/)

**Characteristics:**
- Supabase HTTP client (supabase-py)
- Tests full API stack (PostgREST + RLS)
- One `supabase db reset` before test session
- Run sequentially (not parallel)
- Target: ~5-10s total

**Example:**
```python
@pytest.mark.integration
@pytest.mark.asyncio
async def test_rls_blocks_other_users_data(supabase_alice, supabase_bob):
    """Verify RLS prevents cross-user data access"""
    # Alice creates a session
    alice_response = await supabase_alice.rpc(
        'draft_session_exercises_v2',
        {'performed_session_id_': alice_session_id}
    ).execute()

    assert alice_response.data is not None

    # Bob tries to access Alice's session
    bob_response = await supabase_bob.rpc(
        'draft_session_exercises_v2',
        {'performed_session_id_': alice_session_id}
    ).execute()

    # RLS should block Bob from seeing Alice's data
    assert bob_response.data is None or len(bob_response.data) == 0
```

**Scope:**
- API endpoint availability
- RLS policy enforcement via HTTP
- Authentication/authorization flows
- Error responses from PostgREST
- Real-world usage patterns

## Fixtures (conftest.py)

### Database Connection Fixtures

```python
@pytest.fixture(scope="session")
async def db_pool():
    """PostgreSQL connection pool (session-scoped)"""
    pool = await asyncpg.create_pool(
        host='127.0.0.1',
        port=54322,
        user='postgres',
        password='postgres',
        database='postgres'
    )
    yield pool
    await pool.close()

@pytest.fixture
async def db_transaction(db_pool):
    """Transaction-wrapped connection (test-scoped, auto-rollback)"""
    async with db_pool.acquire() as conn:
        async with conn.transaction():
            yield conn
            # Transaction automatically rolls back after test
```

### Supabase Client Fixtures

```python
@pytest.fixture(scope="session")
def supabase_url():
    """Local Supabase URL"""
    return "http://127.0.0.1:54321"

@pytest.fixture(scope="session")
def supabase_anon_key():
    """Anon key from supabase status"""
    # Read from environment or config
    return os.getenv("TEST_SUPABASE_ANON_KEY")

@pytest.fixture
async def supabase_client(supabase_url, supabase_anon_key):
    """Authenticated Supabase client"""
    client = create_client(supabase_url, supabase_anon_key)
    # Authenticate as test user
    await client.auth.sign_in_with_password({
        "email": "dev@example.com",
        "password": "test_password"
    })
    yield client
    await client.auth.sign_out()
```

## Configuration

### pytest.ini

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_classes = Test*
python_functions = test_*
asyncio_mode = auto
markers =
    integration: integration tests (via HTTP API)
    slow: slow-running tests
    unit: fast unit tests (direct DB)
addopts =
    -v
    --strict-markers
    --tb=short
    --cov=database
    --cov-report=term-missing
```

### pyproject.toml (uv)

```toml
[project]
name = "workout_app"
version = "0.1.0"
requires-python = ">=3.10,<4.0"
dependencies = [
    "asyncpg>=0.30.0,<0.31.0",
    "fastapi>=0.111.0,<0.112.0",
    "pydantic[email]>=2.12.4,<3.0.0",
    "pydantic-settings>=2.4.0,<3.0.0",
    "sqlalchemy>=2.0.29,<2.1.0",
    "sqlmodel>=0.0.27,<0.0.28",
]

[dependency-groups]
dev = [
    "pytest>=9.0.1,<10.0.0",
    "pytest-asyncio>=1.3.0,<2.0.0",
    "pytest-xdist>=3.8.0,<4.0.0",
    "pytest-cov>=7.0.0,<8.0.0",
    "pytest-timeout>=2.4.0,<3.0.0",
    "supabase>=2.24.0,<3.0.0",
    "websockets>=13.1,<14.0",
]

[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"
```

## Test Commands

```bash
# Install/refresh the environment
uv sync

# Run all tests (parallel unit tests, sequential integration)
uv run pytest

# Run only fast unit tests (parallel)
uv run pytest tests/database/ -n auto

# Run only integration tests
uv run pytest tests/integration/ -m integration

# Run with coverage
uv run pytest --cov=database --cov-report=html

# Run a specific test
uv run pytest tests/database/test_empty_workouts.py::test_empty_workout_returns_one_row

# Code style / quality
uv run ruff check .
uv run ruff format workout_app tests
uv run mypy tests/settings.py tests/conftest.py
```

## GitHub Actions Workflow

```yaml
name: Tests

on:
  push:
    branches: [master, main]
  pull_request:
    branches: [master, main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: supabase/postgres:latest
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 54322:5432

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python 3.13
        uses: actions/setup-python@v5
        with:
          python-version: "3.13"

      - name: Install uv
        run: pipx install uv

      - name: Sync dependencies
        run: uv sync --python 3.13

      - name: Start Supabase
        run: |
          brew install supabase/tap/supabase
          supabase start

      - name: Sync migrations
        run: ./database/sync_to_supabase.sh

      - name: Apply migrations
        run: supabase db reset

      - name: Run tests
        run: uv run pytest --cov --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./coverage.xml
```

## Implementation Steps

### Step 1: Project Setup
1. Initialize uv project with Python 3.13 (`uv python pin 3.13 && uv init` if starting fresh)
2. Declare dependencies (pytest stack, asyncpg, supabase-py) in `pyproject.toml`
3. Create directory structure
4. Configure pytest.ini

### Step 2: Basic Fixtures
1. Create `tests/settings.py` (BaseSettings + dotenv loader)
2. Create `conftest.py`
3. Implement database connection fixtures
4. Implement Supabase client fixtures (using settings helpers)
5. Test fixtures work with local Supabase

### Step 3: Unit Tests (PR #1 Focus)
1. `test_empty_workouts.py` - Empty workout support
   - Test `draft_session_exercises_v2()` returns 1 row
   - Test empty exercises array
   - Test `has_exercises=false` flag
   - Test `performed_session_details()` metadata
2. `test_rls_policies.py` - RLS at SQL level
   - Test RLS is enabled on tables
   - Test policy existence
   - Test role-based access (via SET ROLE)

### Step 4: Integration Tests (PR #1 Focus)
1. `test_api_empty_workouts.py` - Via HTTP
   - Test RPC calls work
   - Test JSON response structure
   - Test error handling
2. `test_api_rls_security.py` - Real RLS
   - Test multi-user isolation
   - Test authenticated vs anonymous access
   - Test cross-user data blocking

### Step 5: CI/CD Integration
1. Create GitHub Actions workflow
2. Test on pull requests
3. Add coverage reporting
4. Configure branch protection

## Success Criteria

✅ **Fast Feedback**
- Unit tests run in < 30 seconds total
- Integration tests run in < 10 seconds
- `pytest -n auto` enables parallel execution

✅ **Comprehensive Coverage**
- All PR #1 functions tested
- RLS policies verified
- Both direct DB and HTTP API covered
- Edge cases handled (empty data, missing records, etc.)

✅ **Easy to Extend**
- Clear fixture pattern
- Simple test structure
- Good documentation
- Easy to add new tests

✅ **CI/CD Ready**
- GitHub Actions workflow
- Runs on every PR
- Coverage reporting
- Clear pass/fail status

## Future Enhancements

**Phase 2:**
- Test all database views
- Test migration rollbacks
- Performance benchmarks
- Load testing with production data volume

**Phase 3:**
- Mutation testing (verify tests catch bugs)
- Property-based testing (hypothesis)
- Database snapshot testing
- API contract testing

## Notes

- Tests assume local Supabase is running (`supabase start`)
- Seed data is loaded via `supabase/seed.sql`
- Transaction-based tests don't persist data
- Integration tests may leave test data (consider cleanup fixture)
- RLS testing requires actual user authentication (not just SQL SET ROLE)

## References

- [pytest documentation](https://docs.pytest.org/)
- [pytest-asyncio](https://github.com/pytest-dev/pytest-asyncio)
- [asyncpg documentation](https://magicstack.github.io/asyncpg/)
- [supabase-py client](https://github.com/supabase/supabase-py)
- [Supabase local development](https://supabase.com/docs/guides/cli/local-development)
