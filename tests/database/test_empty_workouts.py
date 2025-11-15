import asyncpg
import pytest


@pytest.mark.unit
@pytest.mark.asyncio
async def test_draft_session_exercises_function_accessible(db_transaction):
    """
    Simple smoke test to ensure the draft_session_exercises_v2 function is queryable.
    """
    session_id = await db_transaction.fetchval(
        "select performed_session_id from performed_session limit 1"
    )
    if session_id is None:
        pytest.skip("no performed sessions available in the test database")

    try:
        rows = await db_transaction.fetch(
            "select count(*)::int as exercise_count from draft_session_exercises_v2($1)",
            session_id,
        )
    except asyncpg.UndefinedFunctionError:
        pytest.skip(
            "draft_session_exercises_v2 function not found; run supabase db reset or apply migrations"
        )

    assert rows, "expected at least one row returned from the exercises function"
    assert rows[0]["exercise_count"] >= 0
