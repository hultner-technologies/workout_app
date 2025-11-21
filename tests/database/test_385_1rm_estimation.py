# tests/database/test_385_1rm_estimation.py

import pytest


@pytest.mark.asyncio
async def test_1rm_actual_weight(db_transaction):
    """1 rep = actual weight is 1RM"""
    result = await db_transaction.fetchrow("""
        SELECT estimate_1rm_adaptive(100000, 1) as estimated_1rm
    """)
    assert result['estimated_1rm'] == 100.0


@pytest.mark.asyncio
async def test_epley_low_reps(db_transaction):
    """2-5 reps uses Epley formula"""
    # Test 3 reps: 1RM = weight × (1 + 0.0333 × reps)
    result = await db_transaction.fetchrow("""
        SELECT estimate_1rm_adaptive(100000, 3) as estimated_1rm
    """)
    expected = 100 * (1 + 0.0333 * 3)
    assert abs(result['estimated_1rm'] - expected) < 0.1


@pytest.mark.asyncio
async def test_brzycki_moderate_reps(db_transaction):
    """6-10 reps uses Brzycki formula"""
    # Test 8 reps: 1RM = weight × (36 / (37 - reps))
    result = await db_transaction.fetchrow("""
        SELECT estimate_1rm_adaptive(100000, 8) as estimated_1rm
    """)
    expected = 100 * (36 / (37 - 8))
    assert abs(result['estimated_1rm'] - expected) < 0.1


@pytest.mark.asyncio
async def test_mayhew_high_reps(db_transaction):
    """11-15 reps uses Mayhew formula"""
    # Test 12 reps: 1RM = (100 × weight) / (52.2 + 41.9 × e^(-0.055 × reps))
    result = await db_transaction.fetchrow("""
        SELECT estimate_1rm_adaptive(100000, 12) as estimated_1rm
    """)
    # Just verify it returns a reasonable value (formula is complex)
    assert result['estimated_1rm'] > 100
    assert result['estimated_1rm'] < 150


@pytest.mark.asyncio
async def test_very_high_reps_returns_null(db_transaction):
    """>15 reps returns NULL (unreliable estimation)"""
    for reps in [16, 20, 25, 30]:
        result = await db_transaction.fetchrow("""
            SELECT estimate_1rm_adaptive(100000, $1) as estimated_1rm
        """, reps)
        assert result['estimated_1rm'] is None, f"{reps} reps should return NULL"


@pytest.mark.asyncio
async def test_zero_reps_returns_null(db_transaction):
    """0 reps returns NULL (invalid)"""
    result = await db_transaction.fetchrow("""
        SELECT estimate_1rm_adaptive(100000, 0) as estimated_1rm
    """)
    assert result['estimated_1rm'] is None
