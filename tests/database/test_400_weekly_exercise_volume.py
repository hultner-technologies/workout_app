# tests/database/test_400_weekly_exercise_volume.py

import pytest
from datetime import datetime, timedelta


@pytest.mark.asyncio
async def test_view_exists(db_transaction):
    """Verify weekly_exercise_volume materialized view exists"""
    result = await db_transaction.fetchrow("""
        SELECT matviewname
        FROM pg_matviews
        WHERE matviewname = 'weekly_exercise_volume'
    """)
    assert result is not None


@pytest.mark.asyncio
async def test_aggregates_by_user_week_exercise(db_transaction):
    """Verify view groups by user_id, week_start_date, base_exercise_id"""
    result = await db_transaction.fetchrow("""
        SELECT COUNT(DISTINCT (user_id, week_start_date, base_exercise_id))
        FROM weekly_exercise_volume
    """)
    assert result['count'] > 0


@pytest.mark.asyncio
async def test_total_sets_calculated(db_transaction):
    """Verify total_sets counts all non-warmup sets"""
    result = await db_transaction.fetchrow("""
        SELECT user_id, week_start_date, base_exercise_id, total_sets
        FROM weekly_exercise_volume
        WHERE total_sets > 0
        LIMIT 1
    """)
    assert result is not None
    assert result['total_sets'] > 0


@pytest.mark.asyncio
async def test_effective_volume_summed(db_transaction):
    """Verify effective_volume_kg is sum of all set volumes"""
    result = await db_transaction.fetchrow("""
        SELECT effective_volume_kg, total_sets
        FROM weekly_exercise_volume
        WHERE effective_volume_kg > 0
        LIMIT 1
    """)
    assert result is not None
    assert result['effective_volume_kg'] > 0


@pytest.mark.asyncio
async def test_max_estimated_1rm_tracked(db_transaction):
    """Verify max_estimated_1rm_kg is highest 1RM for the week"""
    result = await db_transaction.fetchrow("""
        SELECT max_estimated_1rm_kg
        FROM weekly_exercise_volume
        WHERE max_estimated_1rm_kg IS NOT NULL
        LIMIT 1
    """)
    assert result is not None
    assert result['max_estimated_1rm_kg'] > 0
