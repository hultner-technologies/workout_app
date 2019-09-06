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

## Tech stack
### Backend
- Database
    - Database first approach
    - PostgresSQL
    - Driver
        - asyncpg 
          https://github.com/MagicStack/asyncpg
        - aiopg (backup)
          https://github.com/aio-libs/aiopg
        - psycopg2 (worst case fallback)
- Application layer 
    - Python
    - FastAPI
    - PyDantic
        - Maybe write own object mapper/model generator with aiopg
    - REST w. OpenAPI specs
      and/or GraphQL w. apollo?
    - Async IO

### Frontend
- Native App
    - ReactNative
    - iOS first
    - Focus on experience in the gym, at your workout
    - Healthkit integration
    - Suggestion, create a mobile web-app using React Native for web for
      platforms we don't officially support with goal to share most code.
        - Also faster & easier to deploy 
- Web cloud app
    - Online app, desktop/mobile
    - Focus on 
        - Analyzing previous workouts
        - Create new workout schedules
        - See statistics and progress
        - Social? (Not initial version)

