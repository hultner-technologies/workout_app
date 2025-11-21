# tests/database/test_330_schema_additions.py

import pytest


@pytest.mark.asyncio
async def test_estimated_rir_column_exists(db_transaction):
    """Verify estimated_rir column added to performed_exercise_set"""
    result = await db_transaction.fetchrow("""
        SELECT column_name, is_nullable, data_type
        FROM information_schema.columns
        WHERE table_name = 'performed_exercise_set'
          AND column_name = 'estimated_rir'
    """)
    assert result is not None
    assert result['is_nullable'] == 'YES'
    assert result['data_type'] == 'integer'


@pytest.mark.asyncio
async def test_rpe_column_exists(db_transaction):
    """Verify rpe column added"""
    result = await db_transaction.fetchrow("""
        SELECT column_name, is_nullable, data_type, numeric_precision, numeric_scale
        FROM information_schema.columns
        WHERE table_name = 'performed_exercise_set'
          AND column_name = 'rpe'
    """)
    assert result is not None
    assert result['is_nullable'] == 'YES'
    assert result['data_type'] == 'numeric'
    assert result['numeric_precision'] == 3
    assert result['numeric_scale'] == 1


@pytest.mark.asyncio
async def test_calculated_columns_exist(db_transaction):
    """Verify effective_volume_kg, estimated_1rm_kg, relative_intensity added"""
    for col in ['effective_volume_kg', 'estimated_1rm_kg', 'relative_intensity']:
        result = await db_transaction.fetchrow("""
            SELECT column_name, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'performed_exercise_set'
              AND column_name = $1
        """, col)
        assert result is not None, f"Column {col} not found"
        assert result['is_nullable'] == 'YES'


@pytest.mark.asyncio
async def test_existing_data_has_null_values(db_transaction):
    """Verify existing sets have NULL for new columns"""
    result = await db_transaction.fetchrow("""
        SELECT COUNT(*) as count
        FROM performed_exercise_set
        WHERE estimated_rir IS NOT NULL
           OR rpe IS NOT NULL
           OR effective_volume_kg IS NOT NULL
    """)
    assert result['count'] == 0, "New columns should be NULL for existing data"
