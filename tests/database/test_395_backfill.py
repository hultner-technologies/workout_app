"""Test backfill of calculated fields for historical data."""

import pytest


@pytest.mark.asyncio
async def test_all_sets_have_effective_volume(db_transaction):
    """Verify all non-warmup sets have effective_volume_kg calculated."""
    result = await db_transaction.fetchrow("""
        SELECT COUNT(*) as total_sets,
               COUNT(effective_volume_kg) as sets_with_volume
        FROM performed_exercise_set
        WHERE set_type != 'warm-up'
    """)

    assert result["total_sets"] > 0, "Should have test data"
    assert result["sets_with_volume"] == result["total_sets"], (
        "All non-warmup sets should have effective_volume_kg calculated"
    )


@pytest.mark.asyncio
async def test_all_valid_sets_have_1rm_estimate(db_transaction):
    """Verify all sets with valid rep ranges have 1RM estimates."""
    result = await db_transaction.fetchrow("""
        SELECT COUNT(*) as total_sets,
               COUNT(estimated_1rm_kg) as sets_with_1rm
        FROM performed_exercise_set
        WHERE reps BETWEEN 1 AND 15  -- Valid range for 1RM estimation
    """)

    if result["total_sets"] > 0:
        assert result["sets_with_1rm"] == result["total_sets"], (
            "All sets with 1-15 reps should have 1RM estimates"
        )


@pytest.mark.asyncio
async def test_high_rep_sets_have_null_1rm(db_transaction):
    """Verify sets with >15 reps have NULL 1RM (unreliable range)."""
    result = await db_transaction.fetchrow("""
        SELECT COUNT(*) as total_sets,
               COUNT(estimated_1rm_kg) as sets_with_1rm
        FROM performed_exercise_set
        WHERE reps > 15
    """)

    if result["total_sets"] > 0:
        assert result["sets_with_1rm"] == 0, (
            "Sets with >15 reps should have NULL 1RM (unreliable estimation)"
        )


@pytest.mark.asyncio
async def test_relative_intensity_calculated_when_1rm_exists(db_transaction):
    """Verify relative_intensity is calculated when 1RM is available."""
    result = await db_transaction.fetchrow("""
        SELECT COUNT(*) as sets_with_1rm,
               COUNT(relative_intensity) as sets_with_intensity
        FROM performed_exercise_set
        WHERE estimated_1rm_kg IS NOT NULL
    """)

    if result["sets_with_1rm"] > 0:
        assert result["sets_with_intensity"] == result["sets_with_1rm"], (
            "All sets with 1RM should have relative_intensity calculated"
        )


@pytest.mark.asyncio
async def test_warmup_sets_have_zero_volume(db_transaction):
    """Verify warm-up sets have 0 effective volume."""
    result = await db_transaction.fetchrow("""
        SELECT COUNT(*) as total_warmups,
               COUNT(*) FILTER (WHERE effective_volume_kg = 0) as zero_volume_warmups
        FROM performed_exercise_set
        WHERE set_type = 'warm-up'
    """)

    if result["total_warmups"] > 0:
        assert result["zero_volume_warmups"] == result["total_warmups"], (
            "All warm-up sets should have effective_volume_kg = 0"
        )


@pytest.mark.asyncio
async def test_backfill_respects_null_rir(db_transaction):
    """Verify backfill uses 1.0x multiplier when RIR is NULL (historical data)."""
    result = await db_transaction.fetchrow("""
        SELECT weight_g, reps, effective_volume_kg
        FROM performed_exercise_set
        WHERE estimated_rir IS NULL
          AND set_type = 'regular'
          AND weight_g IS NOT NULL
          AND reps IS NOT NULL
        LIMIT 1
    """)

    if result:
        expected_volume = (result["weight_g"] * result["reps"]) / 1000.0
        assert result["effective_volume_kg"] == expected_volume, (
            f"NULL RIR should use 1.0x multiplier: "
            f"expected {expected_volume}, got {result['effective_volume_kg']}"
        )
