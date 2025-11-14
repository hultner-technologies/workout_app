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

