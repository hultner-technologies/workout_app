import pytest


@pytest.mark.unit
@pytest.mark.asyncio
async def test_performed_session_details_returns_metadata(db_transaction):
    session_id = await db_transaction.fetchval(
        "select performed_session_id from performed_session limit 1"
    )
    if session_id is None:
        pytest.skip("no performed sessions available in the test database")

    row = await db_transaction.fetchrow(
        "select * from performed_session_details($1)", session_id
    )
    assert row is not None
    assert row["performed_session_id"] == session_id
    assert row["session_schedule_id"] is not None
    assert row["app_user_id"] is not None
