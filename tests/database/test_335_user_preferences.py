# tests/database/test_335_user_preferences.py

import json
import pytest


@pytest.mark.asyncio
async def test_training_preferences_column_exists(db_transaction):
    """Verify training_preferences column added to app_user"""
    result = await db_transaction.fetchrow("""
        SELECT column_name, is_nullable, data_type
        FROM information_schema.columns
        WHERE table_name = 'app_user'
          AND column_name = 'training_preferences'
    """)
    assert result is not None
    assert result['data_type'] == 'jsonb'


@pytest.mark.asyncio
async def test_existing_users_get_default_preferences(db_transaction):
    """Verify existing users get default training_preferences"""
    # Get first user
    user = await db_transaction.fetchrow(
        "SELECT user_id, training_preferences FROM app_user LIMIT 1"
    )

    assert user is not None
    assert user['training_preferences'] is not None

    prefs = user['training_preferences']
    assert 'volume_landmarks' in prefs
    assert prefs['volume_landmarks']['enabled'] == True
    assert 'plateau_detection' in prefs
    assert prefs['plateau_detection']['enabled'] == True


@pytest.mark.asyncio
async def test_can_update_custom_landmarks(db_transaction):
    """Verify users can set custom MEV/MAV/MRV values"""
    # Get a user
    user = await db_transaction.fetchrow("SELECT user_id FROM app_user LIMIT 1")
    user_id = user['user_id']

    # Update custom MEV
    result = await db_transaction.fetchrow("""
        UPDATE app_user
        SET training_preferences = jsonb_set(
            training_preferences,
            '{volume_landmarks,custom_mev}',
            '8'::jsonb
        )
        WHERE user_id = $1
        RETURNING training_preferences->'volume_landmarks'->>'custom_mev' as custom_mev
    """, user_id)

    assert result['custom_mev'] == '8'
