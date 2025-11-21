# tests/database/test_405_weekly_muscle_volume.py

import pytest


@pytest.mark.asyncio
async def test_view_exists(db_transaction):
    """Verify weekly_muscle_volume materialized view exists"""
    result = await db_transaction.fetchrow("""
        SELECT matviewname
        FROM pg_matviews
        WHERE matviewname = 'weekly_muscle_volume'
    """)
    assert result is not None


@pytest.mark.asyncio
async def test_aggregates_by_user_week_muscle(db_transaction):
    """Verify view groups by user_id, week_start_date, muscle_group"""
    result = await db_transaction.fetchrow("""
        SELECT COUNT(DISTINCT (user_id, week_start_date, muscle_group))
        FROM weekly_muscle_volume
    """)
    assert result['count'] > 0


@pytest.mark.asyncio
async def test_primary_muscle_100_percent_attribution(db_transaction):
    """Verify primary muscles get 100% volume attribution"""
    result = await db_transaction.fetchrow("""
        SELECT muscle_group, muscle_role, activation_factor
        FROM weekly_muscle_volume
        WHERE muscle_role = 'primary'
        LIMIT 1
    """)
    assert result is not None
    assert result['activation_factor'] == 1.0


@pytest.mark.asyncio
async def test_secondary_muscle_50_percent_attribution(db_transaction):
    """Verify secondary muscles get 50% volume attribution"""
    result = await db_transaction.fetchrow("""
        SELECT muscle_group, muscle_role, activation_factor
        FROM weekly_muscle_volume
        WHERE muscle_role = 'secondary'
        LIMIT 1
    """)
    assert result is not None
    assert result['activation_factor'] == 0.5


@pytest.mark.asyncio
async def test_attributed_volume_calculated(db_transaction):
    """Verify attributed_volume_kg = effective_volume_kg * activation_factor"""
    result = await db_transaction.fetchrow("""
        SELECT effective_volume_kg, activation_factor, attributed_volume_kg
        FROM weekly_muscle_volume
        LIMIT 1
    """)
    assert result is not None
    expected = result['effective_volume_kg'] * result['activation_factor']
    assert abs(result['attributed_volume_kg'] - expected) < 0.01
