# GymR8 Workout App

**GymR8** (Swedish: "Gym Råtta" = Gym Rat) - A database-first workout tracking application built with Supabase and PostgreSQL.

## Overview

GymR8 is a workout tracking system focused on data modeling and database schema design. The backend uses Supabase for authentication, database, and real-time features, with a separate React Native mobile app for the frontend.

## Features

- **Supabase Authentication** - Email/password auth with auto-generated usernames
- **GymR8 Usernames** - Reddit-style readable usernames (e.g., `SwoleRat`, `IronLifter`, `BuffBarbell`)
- **Row Level Security** - Multi-tenant data isolation at the database level
- **Workout Plans** - Create and manage workout programs
- **Session Tracking** - Log performed workouts with exercises and sets
- **Exercise Library** - Comprehensive exercise database

## Tech Stack

- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth
- **Backend**: Database-only (no application server)
- **Frontend**: React Native (separate repository)
- **Testing**: pytest with asyncpg

## Quick Start

### Prerequisites

- Python 3.11+
- [uv](https://github.com/astral-sh/uv) (Python package manager)
- Supabase account

### Installation

```bash
# Install dependencies
uv sync

# Run tests
pytest
```

## Authentication Setup

GymR8 uses Supabase Auth with automatic user profile creation and username generation.

### Setup Steps

1. **Deploy Database Migrations**
   - See [SUPABASE_SETUP.md](SUPABASE_SETUP.md) for detailed instructions
   - Migrations located in `/database/` directory

2. **Configure Supabase Auth**
   - Enable email authentication in Supabase Dashboard
   - Configure email confirmation (required)
   - Set up redirect URLs for your app
   - See [SUPABASE_SETUP.md](SUPABASE_SETUP.md#2-configure-email-authentication)

3. **Production SMTP** (optional for development)
   - Free tier: 3-4 emails/hour (testing only)
   - Production: Configure custom SMTP provider
   - See [SUPABASE_SETUP.md](SUPABASE_SETUP.md#3-configure-smtp-production)

### Username Generation

GymR8 automatically generates memorable, gym-themed usernames if users don't provide one:

- **Pattern**: AdjectiveNoun (e.g., `SwoleRat`, `IronLifter`)
- **Combinations**: 25,480 base combinations (254M with numbers)
- **GymR8 Words**: Rat, Barbell, Dumbbell, Swole, Buff, Ripped, etc.
- **Fallback**: Users can provide custom usernames (min 4 chars, alphanumeric + `-_.`)

Examples: `SwoleRat`, `BuffBarbell`, `RippedGymRat`, `IronLifter`, `HardcoreGains`

### Integration Example

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

// Signup with auto-generated username
await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password'
})

// Signup with custom username
await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'secure-password',
  options: {
    data: {
      name: 'John Doe',
      username: 'johndoe'
    }
  }
})
```

See [SUPABASE_AUTH_INTEGRATION_PLAN.md](SUPABASE_AUTH_INTEGRATION_PLAN.md) for full implementation details.

## Database Schema

### Core Tables

- **app_user** - User profiles (linked to auth.users)
- **plan** - Workout plans
- **session_schedule** - Scheduled workout sessions
- **exercise** - Exercise library
- **performed_session** - Logged workouts
- **performed_exercise** - Individual exercise records

### Custom PostgreSQL Features

- **Domains**: `positive_int` for weight/rep validation
- **UUID Keys**: Using `uuid_generate_v1mc()` for performance
- **Text Arrays**: For exercise links and media
- **CHECK Constraints**: Data integrity at database level
- **RLS Policies**: Row-level security on all user data

## Development

### Running Tests

```bash
# All tests
pytest

# Specific test file
pytest tests/database/test_supabase_auth_integration.py

# With coverage
pytest --cov=database
```

### Code Style

```bash
# Format Python code
uv run ruff format .

# Lint
uv run ruff check .
```

### Database Migrations

SQL migrations are located in `/database/` and should be run in numerical order:

```
database/
  020_AppUser.sql
  025_AppUser_Auth_Migration.sql
  026_Auth_Username_Generator.sql
  027_Auth_Trigger.sql
  ...
```

## Architecture

GymR8 follows a **database-first** approach:

- No application server (Supabase handles API layer)
- All business logic in PostgreSQL (triggers, functions, constraints)
- RLS policies enforce security at the database level
- Frontend communicates directly with Supabase client library

### Why Database-First?

- **Security**: RLS policies prevent unauthorized access at the database level
- **Performance**: Direct database queries via Supabase (no API server overhead)
- **Simplicity**: No backend code to maintain
- **Real-time**: Built-in real-time subscriptions via Supabase
- **Type Safety**: Database schema is source of truth

## Documentation

- [SUPABASE_SETUP.md](SUPABASE_SETUP.md) - Deployment and configuration guide
- [SUPABASE_AUTH_INTEGRATION_PLAN.md](SUPABASE_AUTH_INTEGRATION_PLAN.md) - Auth implementation details
- [CLAUDE.md](CLAUDE.md) - AI assistant instructions
- [AGENTS.md](AGENTS.md) - Development guidelines

## Project Status

### Phase 1: Core Authentication ✅

- [x] Database schema with RLS
- [x] Supabase Auth integration
- [x] Automatic username generation
- [x] Email/password authentication
- [x] Comprehensive test suite
- [ ] Deployment to production

### Phase 2: Advanced Features 📅

- [ ] OAuth providers (Apple, Google, GitHub)
- [ ] Admin user impersonation
- [ ] Username change functionality
- [ ] Custom SMTP for production emails

## Contributing

This is a personal project, but feedback and suggestions are welcome via GitHub issues.

## License

Proprietary - All rights reserved
