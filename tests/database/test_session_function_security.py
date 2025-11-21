"""
Tests for Session Creation Function Security

This test suite verifies defense-in-depth validation on session creation functions.

Issue: Functions accept user_id parameter, allowing potential impersonation
Fix: Add auth.uid() validation - authenticated users must use their own ID
      Service role (auth.uid() = NULL) bypasses validation (for legacy backend)
Result: NON-BREAKING security upgrade with multi-layer protection

Functions:
- create_session_from_name(schedule_name, app_user_id)
- create_full_session(schedule_name, app_user_id)
- create_session_exercises(performed_session_id)
- create_my_session_from_name(schedule_name) - convenience function
- create_my_full_session(schedule_name) - convenience function
"""

import uuid

import pytest
from asyncpg import exceptions

from tests.conftest import create_test_user


@pytest.mark.unit
@pytest.mark.asyncio
async def test_authenticated_user_can_create_own_session(db_transaction):
    """Test that authenticated user can create session with their own user_id"""
    user_id = uuid.uuid4()
    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="Session User"
    )

    # Create test session schedule
    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ('Test Plan') RETURNING plan_id"
    )
    await db_transaction.execute(
        """
        INSERT INTO session_schedule (session_schedule_id, plan_id, name)
        VALUES ($1, $2, 'Test Session Schedule')
        """,
        uuid.uuid4(),
        plan_id,
    )

    # Set authenticated role
    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should be able to create session with own user_id
    session_id = await db_transaction.fetchval(
        "SELECT performed_session_id FROM create_session_from_name('Test Session Schedule', $1)",
        user_id,
    )
    assert session_id is not None, "User should be able to create session with their own user_id"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_authenticated_user_cannot_create_session_for_another_user(db_transaction):
    """Test that authenticated user CANNOT create session for another user_id"""
    user_id = uuid.uuid4()
    other_user_id = uuid.uuid4()

    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="User 1"
    )
    await create_test_user(
        db_transaction, other_user_id, f"{other_user_id}@example.com", name="User 2"
    )

    # Create test session schedule
    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ('Test Plan 2') RETURNING plan_id"
    )
    await db_transaction.execute(
        """
        INSERT INTO session_schedule (session_schedule_id, plan_id, name)
        VALUES ($1, $2, 'Test Schedule 2')
        """,
        uuid.uuid4(),
        plan_id,
    )

    # Set authenticated role as user_id
    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should be blocked by function validation (Layer 1: auth.uid() check)
    with pytest.raises(Exception) as exc_info:
        await db_transaction.fetchval(
            "SELECT performed_session_id FROM create_session_from_name('Test Schedule 2', $1)",
            other_user_id,
        )

    assert "Cannot create session for another user" in str(exc_info.value), \
        "Function should block creating session for another user"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_authenticated_user_cannot_create_full_session_for_another_user(db_transaction):
    """Test that authenticated user CANNOT create full session for another user_id"""
    user_id = uuid.uuid4()
    other_user_id = uuid.uuid4()

    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="User 1"
    )
    await create_test_user(
        db_transaction, other_user_id, f"{other_user_id}@example.com", name="User 2"
    )

    # Create test session schedule with exercises
    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ('Test Plan 3') RETURNING plan_id"
    )
    session_schedule_id = uuid.uuid4()
    await db_transaction.execute(
        """
        INSERT INTO session_schedule (session_schedule_id, plan_id, name)
        VALUES ($1, $2, 'Test Schedule 3')
        """,
        session_schedule_id,
        plan_id,
    )

    # Add an exercise to the schedule
    base_exercise_id = await db_transaction.fetchval(
        "SELECT base_exercise_id FROM base_exercise LIMIT 1"
    )
    if base_exercise_id:
        exercise_id = uuid.uuid4()
        await db_transaction.execute(
            """
            INSERT INTO exercise (exercise_id, base_exercise_id, name)
            VALUES ($1, $2, 'Test Exercise')
            """,
            exercise_id,
            base_exercise_id,
        )
        await db_transaction.execute(
            """
            INSERT INTO session_schedule_exercise (session_schedule_id, exercise_id, sort_order)
            VALUES ($1, $2, 1)
            """,
            session_schedule_id,
            exercise_id,
        )

    # Set authenticated role as user_id
    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should be blocked by function validation
    with pytest.raises(Exception) as exc_info:
        await db_transaction.fetch(
            "SELECT * FROM create_full_session('Test Schedule 3', $1)",
            other_user_id,
        )

    assert "Cannot create session for another user" in str(exc_info.value), \
        "Function should block creating full session for another user"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_service_role_can_create_session_for_any_user(db_transaction):
    """Test that service role (postgres) can create session for any user_id"""
    user_id = uuid.uuid4()
    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="Any User"
    )

    # Create test session schedule
    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ('Service Plan') RETURNING plan_id"
    )
    await db_transaction.execute(
        """
        INSERT INTO session_schedule (session_schedule_id, plan_id, name)
        VALUES ($1, $2, 'Service Schedule')
        """,
        uuid.uuid4(),
        plan_id,
    )

    # Service role (postgres) should bypass validation (auth.uid() = NULL)
    await db_transaction.execute("SET LOCAL ROLE postgres")

    session_id = await db_transaction.fetchval(
        "SELECT performed_session_id FROM create_session_from_name('Service Schedule', $1)",
        user_id,
    )
    assert session_id is not None, "Service role should be able to create session for any user"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_rls_also_blocks_direct_table_inserts(db_transaction):
    """Test that RLS (Layer 2) also blocks direct table inserts for other users"""
    user_id = uuid.uuid4()
    other_user_id = uuid.uuid4()

    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="User 1"
    )
    await create_test_user(
        db_transaction, other_user_id, f"{other_user_id}@example.com", name="User 2"
    )

    # Create test session schedule
    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ('RLS Plan') RETURNING plan_id"
    )
    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, 'RLS Schedule')
        RETURNING session_schedule_id
        """,
        plan_id,
    )

    # Set authenticated role as user_id
    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should be blocked by RLS policy (defense layer 2)
    with pytest.raises(exceptions.InsufficientPrivilegeError):
        await db_transaction.execute(
            """
            INSERT INTO performed_session (session_schedule_id, app_user_id)
            VALUES ($1, $2)
            """,
            session_schedule_id,
            other_user_id,
        )


@pytest.mark.unit
@pytest.mark.asyncio
async def test_functions_have_search_path_protection(db_transaction):
    """Test that session functions have search_path protection"""
    # Check create_session_from_name
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'create_session_from_name'
        """
    )
    assert has_search_path, "create_session_from_name should have search_path protection"

    # Check create_full_session
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'create_full_session'
        """
    )
    assert has_search_path, "create_full_session should have search_path protection"

    # Check create_session_exercises
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'create_session_exercises'
        """
    )
    assert has_search_path, "create_session_exercises should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_convenience_functions_exist(db_transaction):
    """Test that new convenience functions exist for migration path"""
    # Check create_my_session_from_name exists
    exists = await db_transaction.fetchval(
        """
        SELECT EXISTS(
            SELECT 1 FROM pg_proc
            WHERE proname = 'create_my_session_from_name'
        )
        """
    )
    assert exists, "create_my_session_from_name convenience function should exist"

    # Check create_my_full_session exists
    exists = await db_transaction.fetchval(
        """
        SELECT EXISTS(
            SELECT 1 FROM pg_proc
            WHERE proname = 'create_my_full_session'
        )
        """
    )
    assert exists, "create_my_full_session convenience function should exist"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_convenience_function_creates_session_for_authenticated_user(db_transaction):
    """Test that create_my_session_from_name works for authenticated user"""
    user_id = uuid.uuid4()
    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="Convenience User"
    )

    # Create test session schedule
    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ('Convenience Plan') RETURNING plan_id"
    )
    await db_transaction.execute(
        """
        INSERT INTO session_schedule (session_schedule_id, plan_id, name)
        VALUES ($1, $2, 'Convenience Schedule')
        """,
        uuid.uuid4(),
        plan_id,
    )

    # Set authenticated role
    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should automatically use auth.uid() - no user_id parameter needed
    session_id = await db_transaction.fetchval(
        "SELECT performed_session_id FROM create_my_session_from_name('Convenience Schedule')"
    )
    assert session_id is not None, "Convenience function should create session for authenticated user"

    # Verify session belongs to authenticated user
    session_owner = await db_transaction.fetchval(
        "SELECT app_user_id FROM performed_session WHERE performed_session_id = $1",
        session_id,
    )
    assert session_owner == user_id, "Created session should belong to authenticated user"
