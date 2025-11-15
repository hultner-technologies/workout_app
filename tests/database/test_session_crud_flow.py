import uuid

import pytest


@pytest.mark.unit
@pytest.mark.asyncio
async def test_full_session_crud_flow(db_transaction):
    plan_id = await db_transaction.fetchval(
        "insert into plan (name) values ($1) returning plan_id",
        f"Test Plan {uuid.uuid4()}",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        insert into session_schedule (plan_id, name)
        values ($1, $2)
        returning session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        insert into base_exercise (name)
        values ($1)
        returning base_exercise_id
        """,
        "Test Exercise",
    )

    exercise_id = await db_transaction.fetchval(
        """
        insert into exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order
        )
        values ($1, $2, 10, 3, interval '00:01:00', 1)
        returning exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    app_user_id = await db_transaction.fetchval(
        "insert into app_user (name, email) values ($1, $2) returning app_user_id",
        "Test User",
        f"user-{uuid.uuid4()}@example.com",
    )

    performed_session_id = await db_transaction.fetchval(
        """
        insert into performed_session (session_schedule_id, app_user_id, started_at)
        values ($1, $2, now())
        returning performed_session_id
        """,
        session_schedule_id,
        app_user_id,
    )

    performed_exercise_id = await db_transaction.fetchval(
        """
        insert into performed_exercise (
            performed_session_id,
            name,
            reps,
            exercise_id
        )
        values ($1, $2, ARRAY[10, 10, 10], $3)
        returning performed_exercise_id
        """,
        performed_session_id,
        "Test Exercise Set",
        exercise_id,
    )

    await db_transaction.execute(
        """
        update performed_exercise
        set note = 'Great set', weight = 1000
        where performed_exercise_id = $1
        """,
        performed_exercise_id,
    )

    row = await db_transaction.fetchrow(
        """
        select note, weight
        from performed_exercise
        where performed_exercise_id = $1
        """,
        performed_exercise_id,
    )
    assert row["note"] == "Great set"
    assert row["weight"] == 1000

    await db_transaction.execute(
        "delete from performed_exercise where performed_exercise_id = $1",
        performed_exercise_id,
    )
    count = await db_transaction.fetchval(
        "select count(*) from performed_exercise where performed_session_id = $1",
        performed_session_id,
    )
    assert count == 0
