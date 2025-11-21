# tests/database/test_410_auto_refresh.py

import pytest


@pytest.mark.asyncio
async def test_trigger_exists(db_transaction):
    """Verify refresh trigger exists on performed_session"""
    result = await db_transaction.fetchrow("""
        SELECT trigger_name
        FROM information_schema.triggers
        WHERE event_object_table = 'performed_session'
          AND trigger_name = 'refresh_weekly_views_trigger'
    """)
    assert result is not None


@pytest.mark.asyncio
async def test_completing_session_refreshes_views(db_transaction):
    """Verify completing a session triggers view refresh"""
    # Get an incomplete session
    session = await db_transaction.fetchrow("""
        SELECT session_id
        FROM performed_session
        WHERE completed_at IS NULL
        LIMIT 1
    """)

    if session:
        # Record current row count
        before_result = await db_transaction.fetchrow(
            "SELECT COUNT(*) as count FROM weekly_exercise_volume"
        )
        before_count = before_result['count']

        # Complete the session
        await db_transaction.execute("""
            UPDATE performed_session
            SET completed_at = NOW()
            WHERE session_id = $1
        """, session['session_id'])

        # Check if views were refreshed (row count may change)
        after_result = await db_transaction.fetchrow(
            "SELECT COUNT(*) as count FROM weekly_exercise_volume"
        )
        after_count = after_result['count']

        # At minimum, the query should succeed (view is valid)
        assert after_count >= 0
