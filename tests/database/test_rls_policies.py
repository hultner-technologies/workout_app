import uuid

import pytest


@pytest.mark.unit
@pytest.mark.asyncio
async def test_performed_session_rls_filters_by_auth_uid(db_transaction):
    user_id = uuid.uuid4()
    other_user_id = uuid.uuid4()

    await db_transaction.execute(
        """
        insert into app_user (app_user_id, name, email)
        values ($1, 'RLS User', $2)
        """,
        user_id,
        f"{user_id}@example.com",
    )

    await db_transaction.execute(
        """
        insert into app_user (app_user_id, name, email)
        values ($1, 'RLS Other', $2)
        """,
        other_user_id,
        f"{other_user_id}@example.com",
    )

    session_schedule_id = await db_transaction.fetchval(
        "insert into plan (name) values ('RLS Plan') returning plan_id"
    )
    session_schedule_id = await db_transaction.fetchval(
        """
        insert into session_schedule (plan_id, name)
        values ($1, 'RLS Session')
        returning session_schedule_id
        """,
        session_schedule_id,
    )

    await db_transaction.execute(
        """
        insert into performed_session (session_schedule_id, app_user_id)
        values ($1, $2), ($1, $3)
        """,
        session_schedule_id,
        user_id,
        other_user_id,
    )

    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "select set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )
    visible_for_user = await db_transaction.fetchval(
        "select count(*) from performed_session"
    )
    assert visible_for_user == 1

    await db_transaction.execute(
        "select set_config('request.jwt.claim.sub', $1, true)", str(other_user_id)
    )
    visible_for_other = await db_transaction.fetchval(
        "select count(*) from performed_session"
    )
    assert visible_for_other == 1

    await db_transaction.execute(
        "select set_config('request.jwt.claim.sub', $1, true)", str(uuid.uuid4())
    )
    visible_for_unknown = await db_transaction.fetchval(
        "select count(*) from performed_session"
    )
    assert visible_for_unknown == 0
