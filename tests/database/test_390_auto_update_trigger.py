# tests/database/test_390_auto_update_trigger.py

import pytest


@pytest.mark.asyncio
async def test_trigger_exists(db_transaction):
    """Verify trigger created on performed_exercise_set"""
    result = await db_transaction.fetchrow("""
        SELECT trigger_name
        FROM information_schema.triggers
        WHERE event_object_table = 'performed_exercise_set'
          AND trigger_name = 'update_calculated_fields_trigger'
    """)
    assert result is not None


@pytest.mark.asyncio
async def test_effective_volume_auto_calculated(db_transaction):
    """Verify effective_volume_kg auto-calculated on insert"""
    # Get existing user and exercise
    user_result = await db_transaction.fetchrow("SELECT user_id FROM app_user LIMIT 1")
    user_id = user_result['user_id']

    session_result = await db_transaction.fetchrow(
        "SELECT session_id FROM performed_session WHERE user_id = $1 LIMIT 1",
        user_id
    )
    session_id = session_result['session_id']

    exercise_result = await db_transaction.fetchrow(
        "SELECT exercise_id FROM performed_exercise WHERE session_id = $1 LIMIT 1",
        session_id
    )
    exercise_id = exercise_result['exercise_id']

    # Insert new set
    result = await db_transaction.fetchrow("""
        INSERT INTO performed_exercise_set (exercise_id, weight_g, reps, set_type, estimated_rir)
        VALUES ($1, 100000, 10, 'regular', 2)
        RETURNING set_id, effective_volume_kg, estimated_1rm_kg
    """, exercise_id)

    assert result['effective_volume_kg'] == 1000.0  # 100kg × 10 reps, RIR 2 = 1.0x
    assert result['estimated_1rm_kg'] is not None
    assert result['estimated_1rm_kg'] > 100  # Should be > weight


@pytest.mark.asyncio
async def test_update_recalculates(db_transaction):
    """Verify updating weight/reps recalculates fields"""
    # Get an existing set
    original = await db_transaction.fetchrow(
        "SELECT set_id, effective_volume_kg FROM performed_exercise_set LIMIT 1"
    )
    set_id = original['set_id']

    # Update it
    updated = await db_transaction.fetchrow("""
        UPDATE performed_exercise_set
        SET weight_g = 120000, reps = 8, estimated_rir = 1
        WHERE set_id = $1
        RETURNING effective_volume_kg, estimated_1rm_kg
    """, set_id)

    assert updated['effective_volume_kg'] == 960.0  # 120kg × 8 reps
    assert updated['estimated_1rm_kg'] is not None
