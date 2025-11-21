# tests/database/test_380_effective_volume.py

import pytest


@pytest.mark.asyncio
async def test_regular_set_volume(db_transaction):
    """Regular set: simple weight × reps / 1000"""
    result = await db_transaction.fetchrow("""
        SELECT calculate_effective_volume('regular', 100000, 10, NULL) as volume
    """)
    assert result['volume'] == 1000.0  # 100kg × 10 reps


@pytest.mark.asyncio
async def test_rir_0_3_no_adjustment(db_transaction):
    """RIR 0-3: No volume adjustment (1.0x multiplier)"""
    for rir in [0, 1, 2, 3]:
        result = await db_transaction.fetchrow("""
            SELECT calculate_effective_volume('regular', 100000, 10, $1) as volume
        """, rir)
        assert result['volume'] == 1000.0, f"RIR {rir} should be 1.0x"


@pytest.mark.asyncio
async def test_rir_4_adjustment(db_transaction):
    """RIR 4: 0.9x multiplier"""
    result = await db_transaction.fetchrow("""
        SELECT calculate_effective_volume('regular', 100000, 10, 4) as volume
    """)
    assert result['volume'] == 900.0  # 1000kg × 0.9


@pytest.mark.asyncio
async def test_rir_5_adjustment(db_transaction):
    """RIR 5: 0.8x multiplier"""
    result = await db_transaction.fetchrow("""
        SELECT calculate_effective_volume('regular', 100000, 10, 5) as volume
    """)
    assert result['volume'] == 800.0  # 1000kg × 0.8


@pytest.mark.asyncio
async def test_rir_6_plus_adjustment(db_transaction):
    """RIR 6+: 0.6x multiplier"""
    for rir in [6, 7, 8, 9, 10]:
        result = await db_transaction.fetchrow("""
            SELECT calculate_effective_volume('regular', 100000, 10, $1) as volume
        """, rir)
        assert result['volume'] == 600.0, f"RIR {rir} should be 0.6x"


@pytest.mark.asyncio
async def test_warmup_excluded(db_transaction):
    """Warm-up sets return 0"""
    result = await db_transaction.fetchrow("""
        SELECT calculate_effective_volume('warm-up', 50000, 5, NULL) as volume
    """)
    assert result['volume'] == 0


@pytest.mark.asyncio
async def test_null_rir_defaults_to_1x(db_transaction):
    """NULL RIR (historical data) uses 1.0x multiplier"""
    result = await db_transaction.fetchrow("""
        SELECT calculate_effective_volume('regular', 100000, 10, NULL) as volume
    """)
    assert result['volume'] == 1000.0


@pytest.mark.asyncio
async def test_all_set_types_handled(db_transaction):
    """All set types return expected volume"""
    set_types = ['regular', 'pyramid-set', 'super-set', 'amrap', 'drop-set', 'myo-rep']

    for set_type in set_types:
        result = await db_transaction.fetchrow("""
            SELECT calculate_effective_volume($1, 100000, 10, NULL) as volume
        """, set_type)
        assert result['volume'] == 1000.0, f"{set_type} should calculate volume"
