# Database Documentation

This project uses **Supabase** (PostgreSQL 17) with a database-first development approach.

## Quick Start

```bash
# Install Supabase CLI (macOS)
brew install supabase/tap/supabase

# Start local Supabase
supabase start

# Sync migrations and reset database
./database/sync_to_supabase.sh
supabase db reset
```

Access Supabase Studio at http://127.0.0.1:54323

## Project Structure

```
database/
├── *.sql                      # Migration files (numbered)
├── sync_to_supabase.sh        # Sync script to Supabase migrations
├── queries/                   # Test queries and utilities
└── README.md                  # This file

supabase/
├── config.toml                # Supabase configuration
└── migrations/                # Auto-synced Supabase migrations
```

## Working with Migrations

### Development Workflow

1. **Create new migration** in `database/` with numbered prefix:
   ```bash
   # Example: database/270_add_user_preferences.sql
   vim database/270_add_user_preferences.sql
   ```

2. **Sync to Supabase**:
   ```bash
   ./database/sync_to_supabase.sh
   ```

3. **Apply migrations**:
   ```bash
   supabase db reset  # Resets and applies all migrations
   ```

4. **Test your changes** in Supabase Studio or via SQL:
   ```bash
   docker exec supabase_db_workout_app psql -U postgres -d postgres -c "SELECT ..."
   ```

### Migration Naming Convention

Files in `database/` follow this pattern: `<number>_<description>.sql`

Example:
- `010_setup.sql` - Initial setup
- `250_empty_workout_support.sql` - Empty workout templates
- `260_rls_policies.sql` - Row Level Security

The sync script automatically converts these to Supabase format:
- `20240101000000_setup.sql`
- `20240101000025_empty_workout_support.sql`

### Sync Script Behavior

`sync_to_supabase.sh` does the following:
- Copies all `.sql` files from `database/` to `supabase/migrations/`
- Adds timestamps in format `YYYYMMDDHHMMSS`
- Skips test files (`test_*`, `restore_*`, `seed_*`)
- Preserves migration order based on file numbering

## Supabase Commands

```bash
# Start/stop services
supabase start
supabase stop

# Check status
supabase status

# Reset database (reapply all migrations)
supabase db reset

# View container logs
docker logs supabase_db_workout_app

# Execute SQL
docker exec supabase_db_workout_app psql -U postgres -d postgres -c "SELECT * FROM plan;"
```

## Seeding Development Database

The `supabase/seed.sql` file runs automatically after migrations during `supabase db reset`.

### Two Seeding Options

**Option 1: Minimal Development Data (Default)**

Quick setup with minimal test data:

```bash
# Use minimal dev seed (default)
./database/use_dev_seed.sh
supabase db reset
```

This creates:
- One test user (`dev@example.com`)
- Sample "Starter Plan" with 3 sessions
- Unknown plan (auto-populated with all base exercises)

**Option 2: Full Production Replica**

Get an exact copy of your production database:

```bash
# Set your production database URL
export PRODUCTION_DATABASE_URL='postgresql://postgres:[password]@[host]:5432/postgres'
# (Get this from Supabase Dashboard → Project Settings → Database)

# Dump all production data
./database/dump_production_full.sh

# Apply to local database
supabase db reset
```

This dumps **everything**:
- All user accounts and profiles
- Complete workout history and performance data
- All notes and preferences
- Plans and exercise templates

### Switching Between Modes

Just run the script for the mode you want, then reset:

```bash
# Switch to dev data
./database/use_dev_seed.sh && supabase db reset

# Switch to production replica
./database/dump_production_full.sh && supabase db reset
```

### Notes

- **File**: `supabase/seed.sql` is overwritten by these scripts
- **Auto-runs**: After all migrations during `supabase db reset`
- **Gitignore**: Add `supabase/seed.sql` to `.gitignore` if using real data

## Access Points

When Supabase is running:

- **Database**: `postgresql://postgres:postgres@127.0.0.1:54322/postgres`
- **API**: http://127.0.0.1:54321
- **Studio**: http://127.0.0.1:54323
- **GraphQL**: http://127.0.0.1:54321/graphql/v1

Keys available via `supabase status`

## Database Schema

### Core Tables

- **plan** - Workout plans
- **session_schedule** - Individual sessions within a plan
- **exercise** - Exercise templates for sessions
- **base_exercise** - Exercise metadata library
- **performed_session** - User workout sessions
- **performed_exercise** - Actual exercises performed
- **app_user** - User accounts

### Key Features

**Row Level Security (RLS)**
- User data isolated per `app_user_id`
- Templates (plans, schedules) are public read-only
- See `260_rls_policies.sql` for details

**Custom Types**
- `positive_int` domain for non-negative integers
- UUID primary keys using `uuid_generate_v1mc()`
- Weights stored in grams (converted in frontend)

**Empty Workout Support**
- Functions return JSON with empty arrays for sessions without exercises
- See PR #1 / `250_empty_workout_support.sql` for implementation

## Testing

### Run PR #1 Tests (Empty Workout Support)

```bash
cd database/queries
./run_tests_docker.sh
```

This tests:
- Empty workout handling
- JSON response structure
- RLS security
- Function behavior

### Manual Testing

```bash
# Start Supabase
supabase start

# Apply migrations
./database/sync_to_supabase.sh
supabase db reset

# Test queries
docker exec supabase_db_workout_app psql -U postgres -d postgres << 'SQL'
  -- Create test data
  INSERT INTO app_user (email, display_name) VALUES ('test@example.com', 'Test User');

  -- Verify functions
  SELECT * FROM session_schedule_with_exercises LIMIT 1;
SQL
```

## Common Issues

### Migrations Fail to Apply

```bash
# Check which migration failed
supabase db reset --debug

# Fix the SQL file in database/
# Re-sync and try again
./database/sync_to_supabase.sh
supabase db reset
```

### Database Won't Start

```bash
# Stop all containers
supabase stop

# Remove volumes and restart
docker volume prune
supabase start
```

### Function Returns Wrong Data

Check RLS policies - they affect what data functions can access:

```sql
-- Disable RLS temporarily for testing (NOT for production)
ALTER TABLE performed_session DISABLE ROW LEVEL SECURITY;
```

## Production Deployment

Migrations in `database/` are the source of truth. To deploy:

1. Review changes in `database/*.sql`
2. Test locally with `supabase db reset`
3. Apply to production Supabase via:
   - Supabase Dashboard (manual SQL)
   - `supabase db push` (if using Supabase hosting)
   - Or your deployment pipeline

## References

- [Supabase CLI Docs](https://supabase.com/docs/guides/cli)
- [PostgreSQL Domains](https://www.postgresql.org/docs/current/sql-createdomain.html)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- PR #1: Empty workout templates and RLS policies
