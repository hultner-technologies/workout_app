# Workout App - Agent Guidelines

## Build/Lint/Test Commands

### Python/Database Tools
- `pytest` - Run all tests
- `pytest tests/test_specific.py` - Run single test file
- `black workout_app/` - Format Python code
- `poetry install` - Install dependencies

## Code Style Guidelines

### Python/Database
- Imports: Group stdlib, third-party, then local imports
- Database models defined as SQL code in /database/queries/, not Python or SQLModel
- UUID primary keys with `uuid_generate_v1mc()`
- Store weights in grams, convert in frontend
- Use snake_case for variables and functions

### Database (Supabase/PostgreSQL)
- Database-first development approach
- PostgreSQL with custom domains (positive_int)
- Text arrays for links
- CHECK constraints for data integrity
- Explicit SQL schemas in /database/
- All SQL migrations in /database/ directory

## Architecture
- Database-only repository for Supabase backend
- Domain: Plans, SessionSchedules, Exercises, PerformedSessions, Users
- Frontend is separate React Native project
- Focus on data modeling and database schema design

## Deprecated Components
- FastAPI backend (moved to Supabase)
- Next.js frontend (moved to separate React Native project)
- TypeScript/React code in web_frontend/ (no longer maintained)