# Workout App

## Domain model draft

**Plan**
- id
- name
- description
- links
- data

**SessionSechedule** _Schedule for one session of a workout plan_
- id
- plan
- name
- description
- links
- data

**Exercise** _Specs for a specific Exrecise_
- id
- sessionSchedule 
- name
- reps
- sets
- rest
- description
- links
- data

**PerformedSession** _Instance of a session performed by a user_
- id
- user
- sessionSchedule
- startedAt
- completedAt
- note

**PerformedExercise** _Exercise performed by a user during a performed workout session_
- id
- user
- performedSession 
- reps
- sets
- rest
- weight
- startedAt
- completedAt
- note 

**User**
- id
- name


### Notes about types
_Unless otherwise specified_
- Strings such as name, note, description are text
- Weights are `numeric`, always in grams and converted in frontend/for end user
    - Constraint `CHECK(VALUE >= 0)`
- Sets, reps are positive `integers`
- id's are `UUID` unless otherwise necessary, in such cases `serial`
- links are arrays of text (or possibly IE max, varchar(2082)) `text[]`

#### Positive Integer
https://www.postgresql.org/docs/current/sql-createdomain.html
```psql
CREATE DOMAIN positive_int AS int
    CHECK(VALUE >= 0)
```

## Quick Start

### Local Development (Supabase)

```bash
# Install Supabase CLI (macOS)
brew install supabase/tap/supabase

# Start local Supabase environment
supabase start

# Sync and apply migrations
./database/sync_to_supabase.sh
supabase db reset

# Access Supabase Studio
open http://127.0.0.1:54323
```

See [database/README.md](database/README.md) for detailed setup and migration information.

### Testing

All Python tooling is managed via [uv](https://docs.astral.sh/uv/).

```bash
# Install dependencies (once)
uv sync

# Fast database tests (parallel safe)
uv run pytest -n auto tests/database

# Integration tests (requires TEST_SUPABASE_URL + keys in env)
uv run pytest -m integration tests/integration
```

The `tests/conftest.py` fixtures expect a local Postgres instance on
`127.0.0.1:54322` using the `postgres/postgres` credentials that Supabase CLI
provisions. Integration tests skip automatically until Supabase URL/API keys are
configured in the environment.

All overrides can be defined via standard environment variables or the local
`.env` file (parsed through `tests/settings.py`). Example:

```dotenv
TEST_PG_HOST=127.0.0.1
TEST_PG_PORT=54322
TEST_PG_USER=postgres
TEST_PG_PASSWORD=postgres
TEST_PG_DATABASE=postgres
TEST_SUPABASE_URL=http://127.0.0.1:54321
TEST_SUPABASE_ANON_KEY=...
TEST_SUPABASE_SERVICE_ROLE_KEY=...
```

### Tooling

```bash
# Format Python modules
uv run ruff format workout_app tests

# Lint / import sort
uv run ruff check .

# Type-check the async fixtures and settings helpers
uv run mypy tests/settings.py tests/conftest.py
```

## Tech Stack
### Backend
- **Database**: Supabase (PostgreSQL 17)
  - Database-first approach
  - Row Level Security (RLS) for multi-tenant isolation
  - Custom domains and constraints
  - Auto-generated REST API via PostgREST
- **Python Tools**: Analysis and statistics generation
  - Workout graphs and visualizations
  - May evolve into full backend layer (not currently prioritized)

### Frontend
- **Native App** (Priority): React Native (separate repository)
  - iOS first
  - Healthkit integration
  - Focus on gym workout experience
- **Web App** (Future): Desktop/mobile web interface
  - Analyzing previous workouts
  - Creating workout schedules
  - Statistics and progress tracking
  - Not currently prioritized
