"""
Tests for the exercise sets refactor migration.

This module tests the migration from legacy performed_exercise weight/reps fields
to the modern performed_exercise_set table.

Test coverage:
- Backfill migration creates correct performed_exercise_set records
- Updated views aggregate correctly from performed_exercise_set
- Updated functions use performed_exercise_set data
- Legacy and new data produce consistent results
"""

import uuid
from datetime import datetime, timedelta

import pytest

from tests.conftest import create_test_user


@pytest.mark.unit
@pytest.mark.asyncio
async def test_backfill_creates_sets_from_legacy_data(db_transaction):
    """
    Test that the backfill migration correctly creates performed_exercise_set
    records from legacy performed_exercise data.
    """
    # Arrange: Create test data
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    # Create plan, session schedule, and exercise
    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, $2)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Bench Press",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order
        )
        VALUES ($1, $2, 10, 5, interval '00:02:00', 1)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    # Create performed session
    performed_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(hours=1),
        datetime.now(),
    )

    # Create legacy performed exercise with weight and reps array
    # This simulates pre-2024 data
    performed_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            rest,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
        RETURNING performed_exercise_id
        """,
        performed_session_id,
        exercise_id,
        "Bench Press",
        [10, 10, 9, 8, 7],  # 5 sets with varying reps
        [
            timedelta(minutes=2),
            timedelta(minutes=2),
            timedelta(minutes=2),
            timedelta(minutes=2),
            timedelta(minutes=2),
        ],
        80000,  # 80kg in grams
        datetime.now() - timedelta(minutes=30),
        datetime.now() - timedelta(minutes=10),
    )

    # Act: Manually trigger backfill logic (simulating the migration)
    # In production, this is done by the 270_backfill_exercise_sets.sql migration
    await db_transaction.execute(
        """
        WITH pe_data AS (
            SELECT
                performed_exercise_id,
                weight,
                reps,
                rest,
                started_at,
                completed_at,
                sets,
                (completed_at - started_at) / sets AS set_duration
            FROM performed_exercise
            WHERE performed_exercise_id = $1
        )
        INSERT INTO performed_exercise_set (
            performed_exercise_id,
            exercise_set_type,
            weight,
            reps,
            rest,
            "order",
            started_at,
            completed_at
        )
        SELECT
            pe_data.performed_exercise_id,
            'regular',
            pe_data.weight,
            rep_value,
            COALESCE(pe_data.rest[set_index], interval '00:02:00'),
            set_index,
            pe_data.started_at + (pe_data.set_duration * (set_index - 1)),
            pe_data.started_at + (pe_data.set_duration * set_index)
        FROM pe_data,
             LATERAL unnest(pe_data.reps) WITH ORDINALITY AS u(rep_value, set_index)
        """,
        performed_exercise_id,
    )

    # Assert: Verify sets were created correctly
    sets = await db_transaction.fetch(
        """
        SELECT
            exercise_set_type,
            weight,
            reps,
            "order",
            started_at,
            completed_at
        FROM performed_exercise_set
        WHERE performed_exercise_id = $1
        ORDER BY "order"
        """,
        performed_exercise_id,
    )

    # Should have 5 sets
    assert len(sets) == 5

    # Verify each set
    expected_reps = [10, 10, 9, 8, 7]
    for i, set_record in enumerate(sets, start=1):
        assert set_record["exercise_set_type"] == "regular"
        assert set_record["weight"] == 80000
        assert set_record["reps"] == expected_reps[i - 1]
        assert set_record["order"] == i
        assert set_record["started_at"] is not None
        assert set_record["completed_at"] is not None
        assert set_record["completed_at"] > set_record["started_at"]


@pytest.mark.unit
@pytest.mark.asyncio
async def test_exercise_stats_view_aggregates_from_sets(db_transaction):
    """
    Test that the updated exercise_stats view correctly aggregates data
    from performed_exercise_set table.
    """
    # Arrange: Create test data with performed_exercise_set records
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, $2)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Squat",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order,
            step_increment
        )
        VALUES ($1, $2, 10, 5, interval '00:02:00', 1, 2500)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    performed_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(hours=1),
        datetime.now(),
    )

    # Create performed exercise (new style - will be populated via sets)
    performed_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        performed_session_id,
        exercise_id,
        "Squat",
        [10, 10, 10, 9, 8],  # Legacy field (deprecated)
        100000,  # Legacy field (deprecated)
        datetime.now() - timedelta(minutes=30),
        datetime.now() - timedelta(minutes=10),
    )

    # Create performed_exercise_set records (modern approach)
    set_data = [
        (1, 100000, 10),  # Set 1: 100kg, 10 reps
        (2, 100000, 10),  # Set 2: 100kg, 10 reps
        (3, 100000, 10),  # Set 3: 100kg, 10 reps
        (4, 102500, 9),  # Set 4: 102.5kg, 9 reps (drop set)
        (5, 105000, 8),  # Set 5: 105kg, 8 reps (final set with higher weight)
    ]

    for order, weight, reps in set_data:
        await db_transaction.execute(
            """
            INSERT INTO performed_exercise_set (
                performed_exercise_id,
                exercise_set_type,
                weight,
                reps,
                rest,
                "order",
                started_at,
                completed_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """,
            performed_exercise_id,
            "regular",
            weight,
            reps,
            timedelta(minutes=2),
            order,
            datetime.now() - timedelta(minutes=30 - (order * 4)),
            datetime.now() - timedelta(minutes=26 - (order * 4)),
        )

    # Act: Query the exercise_stats view
    stats = await db_transaction.fetchrow(
        """
        SELECT
            name,
            weight,
            reps,
            brzycki_1_rm_max,
            volume_kg
        FROM exercise_stats
        WHERE performed_exercise_id = $1
        """,
        performed_exercise_id,
    )

    # Assert: Verify aggregations are correct
    assert stats is not None
    assert stats["name"] == "Squat"

    # Weight should be MAX from sets
    assert stats["weight"] == 105000

    # Reps should be array from sets (ordered)
    assert stats["reps"] == [10, 10, 10, 9, 8]

    # Volume should be sum of (weight * reps) / 1000
    # (100000*10 + 100000*10 + 100000*10 + 102500*9 + 105000*8) / 1000
    # = (1000000 + 1000000 + 1000000 + 922500 + 840000) / 1000
    # = 4762500 / 1000 = 4762.5 kg
    expected_volume = 4762.5
    assert abs(stats["volume_kg"] - expected_volume) < 0.01

    # 1RM should be calculated from max reps (10)
    # Brzycki formula: weight * (36 / (37 - reps))
    # Using max reps of 10: 105000 * (36 / (37 - 10)) = 105000 * (36/27) = 140000
    expected_1rm = round(105000 * (36.0 / (37.0 - 10)))
    assert stats["brzycki_1_rm_max"] == expected_1rm


@pytest.mark.unit
@pytest.mark.asyncio
async def test_draft_session_exercises_uses_sets_for_progression(db_transaction):
    """
    Test that draft_session_exercises function uses performed_exercise_set
    data to determine progression and recommend weights.
    """
    # Arrange: Create user and plan structure
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name, progression_limit)
        VALUES ($1, $2, 0.9)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Deadlift",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order,
            step_increment
        )
        VALUES ($1, $2, 10, 3, interval '00:03:00', 1, 5000)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    # Create previous performed session with successful progression
    previous_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(days=2, hours=1),
        datetime.now() - timedelta(days=2),
    )

    previous_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        previous_session_id,
        exercise_id,
        "Deadlift",
        [10, 10, 10],
        120000,
        datetime.now() - timedelta(days=2, minutes=30),
        datetime.now() - timedelta(days=2, minutes=10),
    )

    # Create sets showing successful progression (all reps >= 9, which is 0.9 * 10)
    for order, reps in [(1, 10), (2, 10), (3, 10)]:
        await db_transaction.execute(
            """
            INSERT INTO performed_exercise_set (
                performed_exercise_id,
                exercise_set_type,
                weight,
                reps,
                rest,
                "order"
            )
            VALUES ($1, 'regular', $2, $3, interval '00:03:00', $4)
            """,
            previous_exercise_id,
            120000,  # 120kg
            reps,
            order,
        )

    # Create new draft session
    new_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at
        )
        VALUES ($1, $2, $3)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now(),
    )

    # Act: Call draft_session_exercises to get recommendations
    recommendations = await db_transaction.fetch(
        """
        SELECT
            name,
            weight,
            reps
        FROM draft_session_exercises($1)
        """,
        new_session_id,
    )

    # Assert: Should recommend increased weight due to successful progression
    assert len(recommendations) == 1
    rec = recommendations[0]
    assert rec["name"] == "Deadlift"
    # Should be previous weight (120000) + step_increment (5000) = 125000
    assert rec["weight"] == 125000
    assert rec["reps"] == [10, 10, 10]  # 3 sets of 10


@pytest.mark.unit
@pytest.mark.asyncio
async def test_draft_session_exercises_no_progression_when_reps_insufficient(db_transaction):
    """
    Test that draft_session_exercises doesn't increase weight when
    the user didn't hit the progression limit in their previous session.
    """
    # Arrange: Similar setup but with insufficient reps
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name, progression_limit)
        VALUES ($1, $2, 0.9)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Overhead Press",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order,
            step_increment
        )
        VALUES ($1, $2, 10, 3, interval '00:02:00', 1, 2500)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    previous_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(days=2, hours=1),
        datetime.now() - timedelta(days=2),
    )

    previous_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        previous_session_id,
        exercise_id,
        "Overhead Press",
        [10, 8, 7],  # Failed to maintain reps
        50000,
        datetime.now() - timedelta(days=2, minutes=30),
        datetime.now() - timedelta(days=2, minutes=10),
    )

    # Create sets showing failed progression (min reps = 7, which is < 0.9 * 10 = 9)
    for order, reps in [(1, 10), (2, 8), (3, 7)]:
        await db_transaction.execute(
            """
            INSERT INTO performed_exercise_set (
                performed_exercise_id,
                exercise_set_type,
                weight,
                reps,
                rest,
                "order"
            )
            VALUES ($1, 'regular', $2, $3, interval '00:02:00', $4)
            """,
            previous_exercise_id,
            50000,
            reps,
            order,
        )

    new_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at
        )
        VALUES ($1, $2, $3)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now(),
    )

    # Act: Call draft_session_exercises
    recommendations = await db_transaction.fetch(
        """
        SELECT
            name,
            weight,
            reps
        FROM draft_session_exercises($1)
        """,
        new_session_id,
    )

    # Assert: Should NOT increase weight (progression failed)
    assert len(recommendations) == 1
    rec = recommendations[0]
    assert rec["name"] == "Overhead Press"
    # Should be same weight as previous (no step_increment added)
    assert rec["weight"] == 50000


@pytest.mark.unit
@pytest.mark.asyncio
async def test_legacy_and_new_data_produce_consistent_stats(db_transaction):
    """
    Test that exercises with only legacy data (backfilled) and exercises
    with native performed_exercise_set data produce consistent stats.
    """
    # Arrange: Create two identical exercises, one with legacy data, one with new
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, $2)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Bicep Curl",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order
        )
        VALUES ($1, $2, 12, 3, interval '00:01:00', 1)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    # Session 1: Legacy data (backfilled)
    session1_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(days=1, hours=1),
        datetime.now() - timedelta(days=1),
    )

    exercise1_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        session1_id,
        exercise_id,
        "Bicep Curl",
        [12, 12, 10],
        25000,  # 25kg
        datetime.now() - timedelta(days=1, minutes=30),
        datetime.now() - timedelta(days=1, minutes=20),
    )

    # Backfill legacy data to sets
    await db_transaction.execute(
        """
        WITH pe_data AS (
            SELECT
                performed_exercise_id,
                weight,
                reps,
                rest,
                started_at,
                completed_at,
                sets,
                (completed_at - started_at) / sets AS set_duration
            FROM performed_exercise
            WHERE performed_exercise_id = $1
        )
        INSERT INTO performed_exercise_set (
            performed_exercise_id,
            exercise_set_type,
            weight,
            reps,
            rest,
            "order",
            started_at,
            completed_at
        )
        SELECT
            pe_data.performed_exercise_id,
            'regular',
            pe_data.weight,
            rep_value,
            COALESCE(pe_data.rest[set_index], interval '00:01:00'),
            set_index,
            pe_data.started_at + (pe_data.set_duration * (set_index - 1)),
            pe_data.started_at + (pe_data.set_duration * set_index)
        FROM pe_data,
             LATERAL unnest(pe_data.reps) WITH ORDINALITY AS u(rep_value, set_index)
        """,
        exercise1_id,
    )

    # Session 2: New data (native sets)
    session2_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(hours=1),
        datetime.now(),
    )

    exercise2_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        session2_id,
        exercise_id,
        "Bicep Curl",
        [12, 12, 10],  # Same as legacy
        25000,  # Same as legacy
        datetime.now() - timedelta(minutes=30),
        datetime.now() - timedelta(minutes=20),
    )

    # Create native sets
    for order, reps in [(1, 12), (2, 12), (3, 10)]:
        await db_transaction.execute(
            """
            INSERT INTO performed_exercise_set (
                performed_exercise_id,
                exercise_set_type,
                weight,
                reps,
                rest,
                "order"
            )
            VALUES ($1, 'regular', $2, $3, interval '00:01:00', $4)
            """,
            exercise2_id,
            25000,
            reps,
            order,
        )

    # Act: Get stats for both exercises
    stats1 = await db_transaction.fetchrow(
        "SELECT weight, reps, volume_kg, brzycki_1_rm_max FROM exercise_stats WHERE performed_exercise_id = $1",
        exercise1_id,
    )

    stats2 = await db_transaction.fetchrow(
        "SELECT weight, reps, volume_kg, brzycki_1_rm_max FROM exercise_stats WHERE performed_exercise_id = $1",
        exercise2_id,
    )

    # Assert: Stats should be identical
    assert stats1 is not None and stats2 is not None
    assert stats1["weight"] == stats2["weight"]
    assert stats1["reps"] == stats2["reps"]
    assert abs(stats1["volume_kg"] - stats2["volume_kg"]) < 0.01
    assert stats1["brzycki_1_rm_max"] == stats2["brzycki_1_rm_max"]


@pytest.mark.unit
@pytest.mark.asyncio
async def test_no_duplicate_backfill_for_existing_sets(db_transaction):
    """
    Test that the backfill migration doesn't create duplicate sets
    for exercises that already have performed_exercise_set records.
    """
    # Arrange: Create exercise with sets already present
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, $2)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Test Exercise",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order
        )
        VALUES ($1, $2, 10, 3, interval '00:02:00', 1)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    performed_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(hours=1),
        datetime.now(),
    )

    performed_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        performed_session_id,
        exercise_id,
        "Test Exercise",
        [10, 10, 10],
        50000,
        datetime.now() - timedelta(minutes=30),
        datetime.now() - timedelta(minutes=10),
    )

    # Create sets (simulating post-2024 data)
    for order in range(1, 4):
        await db_transaction.execute(
            """
            INSERT INTO performed_exercise_set (
                performed_exercise_id,
                exercise_set_type,
                weight,
                reps,
                rest,
                "order"
            )
            VALUES ($1, 'regular', $2, $3, interval '00:02:00', $4)
            """,
            performed_exercise_id,
            50000,
            10,
            order,
        )

    initial_count = await db_transaction.fetchval(
        "SELECT COUNT(*) FROM performed_exercise_set WHERE performed_exercise_id = $1",
        performed_exercise_id,
    )

    # Act: Try to run backfill (should skip this exercise)
    # This simulates the WHERE NOT EXISTS clause in the migration
    backfilled_count = await db_transaction.fetchval(
        """
        WITH pe_data AS (
            SELECT
                performed_exercise_id,
                weight,
                reps,
                rest,
                started_at,
                completed_at,
                sets,
                (completed_at - started_at) / sets AS set_duration
            FROM performed_exercise
            WHERE performed_exercise_id = $1
              AND NOT EXISTS (
                  SELECT 1
                  FROM performed_exercise_set pes
                  WHERE pes.performed_exercise_id = performed_exercise.performed_exercise_id
              )
        )
        INSERT INTO performed_exercise_set (
            performed_exercise_id,
            exercise_set_type,
            weight,
            reps,
            rest,
            "order",
            started_at,
            completed_at
        )
        SELECT
            pe_data.performed_exercise_id,
            'regular',
            pe_data.weight,
            rep_value,
            COALESCE(pe_data.rest[set_index], interval '00:02:00'),
            set_index,
            pe_data.started_at + (pe_data.set_duration * (set_index - 1)),
            pe_data.started_at + (pe_data.set_duration * set_index)
        FROM pe_data,
             LATERAL unnest(pe_data.reps) WITH ORDINALITY AS u(rep_value, set_index)
        RETURNING *
        """,
        performed_exercise_id,
    )

    final_count = await db_transaction.fetchval(
        "SELECT COUNT(*) FROM performed_exercise_set WHERE performed_exercise_id = $1",
        performed_exercise_id,
    )

    # Assert: No additional sets should be created
    assert initial_count == 3
    assert final_count == 3
    assert backfilled_count is None  # No rows inserted

## CRITICAL TESTS FOR FINALIZED MIGRATION RULES ##

@pytest.mark.unit
@pytest.mark.asyncio
async def test_backfill_body_weight_exercises_null_weight(db_transaction):
    """
    Test that exercises with NULL weight (body weight exercises like push-ups, pull-ups)
    are backfilled correctly with weight set to 0.
    
    Rule: Allow NULL weight for body weight exercises
    """
    # Arrange: Create body weight exercise (NULL weight)
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, $2)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Push-ups",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order
        )
        VALUES ($1, $2, 15, 3, interval '00:01:30', 1)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    # Create COMPLETED session (critical!)
    performed_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(hours=1),
        datetime.now(),  # Session is completed!
    )

    # Create performed exercise with NULL weight (body weight)
    performed_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        performed_session_id,
        exercise_id,
        "Push-ups",
        [15, 12, 10],  # 3 sets
        None,  # NULL weight = body weight exercise!
        datetime.now() - timedelta(minutes=20),
        datetime.now() - timedelta(minutes=10),
    )

    # Act: Trigger backfill
    await db_transaction.execute(
        """
        WITH pe_data AS (
            SELECT
                pe.performed_exercise_id,
                pe.weight,
                pe.reps,
                pe.rest,
                pe.started_at,
                pe.completed_at,
                pe.sets,
                (pe.completed_at - pe.started_at) / pe.sets AS set_duration
            FROM performed_exercise pe
            JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
            WHERE pe.performed_exercise_id = $1
              AND ps.completed_at IS NOT NULL  -- Session must be completed
              -- Conservative session-level exclusion
              AND NOT EXISTS (
                  SELECT 1
                  FROM performed_exercise_set pes
                  JOIN performed_exercise pe2 ON pes.performed_exercise_id = pe2.performed_exercise_id
                  WHERE pe2.performed_session_id = pe.performed_session_id
              )
        )
        INSERT INTO performed_exercise_set (
            performed_exercise_id,
            exercise_set_type,
            weight,
            reps,
            rest,
            "order",
            started_at,
            completed_at
        )
        SELECT
            pe_data.performed_exercise_id,
            'regular',
            COALESCE(pe_data.weight, 0),  -- NULL → 0 for body weight
            rep_value,
            COALESCE(pe_data.rest[set_index], interval '00:02:00'),
            set_index,
            pe_data.started_at + (pe_data.set_duration * (set_index - 1)),
            pe_data.started_at + (pe_data.set_duration * set_index)
        FROM pe_data,
             LATERAL unnest(pe_data.reps) WITH ORDINALITY AS u(rep_value, set_index)
        """,
        performed_exercise_id,
    )

    # Assert: Sets created with weight = 0
    sets = await db_transaction.fetch(
        """
        SELECT weight, reps, "order"
        FROM performed_exercise_set
        WHERE performed_exercise_id = $1
        ORDER BY "order"
        """,
        performed_exercise_id,
    )

    assert len(sets) == 3
    assert all(s["weight"] == 0 for s in sets)  # All weights should be 0
    assert [s["reps"] for s in sets] == [15, 12, 10]


@pytest.mark.unit
@pytest.mark.asyncio
async def test_backfill_skips_entire_session_if_any_exercise_has_sets(db_transaction):
    """
    Test conservative session-level exclusion: If ANY exercise in a session
    has sets, skip the ENTIRE session from backfill.
    
    Rule: Conservative session-level exclusion to prevent mixing data
    """
    # Arrange: Create session with 3 exercises
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, $2)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    # Create 3 exercises
    exercise_ids = []
    for i in range(3):
        base_exercise_id = await db_transaction.fetchval(
            """
            INSERT INTO base_exercise (name)
            VALUES ($1)
            RETURNING base_exercise_id
            """,
            f"Exercise {i+1}",
        )

        exercise_id = await db_transaction.fetchval(
            """
            INSERT INTO exercise (
                base_exercise_id,
                session_schedule_id,
                reps,
                sets,
                rest,
                sort_order
            )
            VALUES ($1, $2, 10, 3, interval '00:02:00', $3)
            RETURNING exercise_id
            """,
            base_exercise_id,
            session_schedule_id,
            i + 1,
        )
        exercise_ids.append(exercise_id)

    # Create completed session
    performed_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(hours=1),
        datetime.now(),
    )

    # Create 3 performed exercises in this session
    performed_exercise_ids = []
    for i, exercise_id in enumerate(exercise_ids):
        performed_exercise_id = await db_transaction.fetchval(
            """
            INSERT INTO performed_exercise (
                performed_session_id,
                exercise_id,
                name,
                reps,
                weight,
                started_at,
                completed_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7)
            RETURNING performed_exercise_id
            """,
            performed_session_id,
            exercise_id,
            f"Exercise {i+1}",
            [10, 10, 10],
            50000,
            datetime.now() - timedelta(minutes=60 - (i * 15)),
            datetime.now() - timedelta(minutes=50 - (i * 15)),
        )
        performed_exercise_ids.append(performed_exercise_id)

    # Add sets ONLY for the first exercise (simulating post-migration)
    for order in range(1, 4):
        await db_transaction.execute(
            """
            INSERT INTO performed_exercise_set (
                performed_exercise_id,
                exercise_set_type,
                weight,
                reps,
                rest,
                "order"
            )
            VALUES ($1, 'regular', 50000, 10, interval '00:02:00', $2)
            """,
            performed_exercise_ids[0],
            order,
        )

    # Act: Try to backfill second and third exercises
    # This should be BLOCKED by conservative session-level exclusion
    backfilled_count = await db_transaction.fetchval(
        """
        WITH pe_data AS (
            SELECT
                pe.performed_exercise_id,
                pe.weight,
                pe.reps,
                pe.rest,
                pe.started_at,
                pe.completed_at,
                pe.sets,
                (pe.completed_at - pe.started_at) / pe.sets AS set_duration
            FROM performed_exercise pe
            JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
            WHERE pe.performed_exercise_id = ANY($1::uuid[])
              AND ps.completed_at IS NOT NULL
              -- Conservative session-level exclusion: Skip if ANY exercise has sets
              AND NOT EXISTS (
                  SELECT 1
                  FROM performed_exercise_set pes
                  JOIN performed_exercise pe2 ON pes.performed_exercise_id = pe2.performed_exercise_id
                  WHERE pe2.performed_session_id = pe.performed_session_id
              )
        )
        INSERT INTO performed_exercise_set (
            performed_exercise_id,
            exercise_set_type,
            weight,
            reps,
            rest,
            "order",
            started_at,
            completed_at
        )
        SELECT
            pe_data.performed_exercise_id,
            'regular',
            COALESCE(pe_data.weight, 0),
            rep_value,
            COALESCE(pe_data.rest[set_index], interval '00:02:00'),
            set_index,
            pe_data.started_at + (pe_data.set_duration * (set_index - 1)),
            pe_data.started_at + (pe_data.set_duration * set_index)
        FROM pe_data,
             LATERAL unnest(pe_data.reps) WITH ORDINALITY AS u(rep_value, set_index)
        RETURNING performed_exercise_id
        """,
        [performed_exercise_ids[1], performed_exercise_ids[2]],
    )

    # Assert: No backfill should occur (session has sets already)
    assert backfilled_count is None

    # Verify only first exercise has sets
    for i, pe_id in enumerate(performed_exercise_ids):
        count = await db_transaction.fetchval(
            "SELECT COUNT(*) FROM performed_exercise_set WHERE performed_exercise_id = $1",
            pe_id,
        )
        if i == 0:
            assert count == 3  # First exercise: has sets (post-migration)
        else:
            assert count == 0  # Others: no sets (blocked by conservative exclusion)


@pytest.mark.unit
@pytest.mark.asyncio
async def test_backfill_skips_in_progress_sessions(db_transaction):
    """
    Test that in-progress sessions (performed_session.completed_at = NULL)
    are skipped from backfill even if exercises look complete.
    
    Rule: Only backfill exercises in completed sessions
    """
    # Arrange: Create in-progress session
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, $2)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Squat",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order
        )
        VALUES ($1, $2, 10, 5, interval '00:03:00', 1)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    # Create IN-PROGRESS session (completed_at = NULL)
    performed_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(minutes=30),
        None,  # Session NOT completed!
    )

    # Create performed exercise that looks "complete" (has completed_at)
    performed_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        performed_session_id,
        exercise_id,
        "Squat",
        [10, 10, 10, 10, 10],
        100000,
        datetime.now() - timedelta(minutes=25),
        datetime.now() - timedelta(minutes=10),  # Exercise looks complete
    )

    # Act: Try to backfill (should be blocked because session is in-progress)
    backfilled_count = await db_transaction.fetchval(
        """
        WITH pe_data AS (
            SELECT
                pe.performed_exercise_id,
                pe.weight,
                pe.reps,
                pe.rest,
                pe.started_at,
                pe.completed_at,
                pe.sets,
                (pe.completed_at - pe.started_at) / pe.sets AS set_duration
            FROM performed_exercise pe
            JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
            WHERE pe.performed_exercise_id = $1
              AND ps.completed_at IS NOT NULL  -- CRITICAL CHECK!
              AND NOT EXISTS (
                  SELECT 1
                  FROM performed_exercise_set pes
                  JOIN performed_exercise pe2 ON pes.performed_exercise_id = pe2.performed_exercise_id
                  WHERE pe2.performed_session_id = pe.performed_session_id
              )
        )
        INSERT INTO performed_exercise_set (
            performed_exercise_id,
            exercise_set_type,
            weight,
            reps,
            rest,
            "order",
            started_at,
            completed_at
        )
        SELECT
            pe_data.performed_exercise_id,
            'regular',
            COALESCE(pe_data.weight, 0),
            rep_value,
            COALESCE(pe_data.rest[set_index], interval '00:02:00'),
            set_index,
            pe_data.started_at + (pe_data.set_duration * (set_index - 1)),
            pe_data.started_at + (pe_data.set_duration * set_index)
        FROM pe_data,
             LATERAL unnest(pe_data.reps) WITH ORDINALITY AS u(rep_value, set_index)
        RETURNING performed_exercise_id
        """,
        performed_exercise_id,
    )

    # Assert: No backfill (session not completed)
    assert backfilled_count is None

    # Verify no sets were created
    count = await db_transaction.fetchval(
        "SELECT COUNT(*) FROM performed_exercise_set WHERE performed_exercise_id = $1",
        performed_exercise_id,
    )
    assert count == 0


@pytest.mark.unit
@pytest.mark.asyncio
async def test_backfill_includes_incomplete_exercises_in_completed_session(db_transaction):
    """
    Test that exercises with NULL completed_at are STILL backfilled
    if they're part of a completed session.
    
    Rule: Check performed_session.completed_at, not individual exercise completed_at
    """
    # Arrange: Create completed session with incomplete exercise
    app_user_id = uuid.uuid4()
    await create_test_user(
        db_transaction,
        app_user_id,
        f"user-{uuid.uuid4()}@example.com",
        name="Test User",
    )

    plan_id = await db_transaction.fetchval(
        "INSERT INTO plan (name) VALUES ($1) RETURNING plan_id",
        "Test Plan",
    )

    session_schedule_id = await db_transaction.fetchval(
        """
        INSERT INTO session_schedule (plan_id, name)
        VALUES ($1, $2)
        RETURNING session_schedule_id
        """,
        plan_id,
        "Test Session",
    )

    base_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO base_exercise (name)
        VALUES ($1)
        RETURNING base_exercise_id
        """,
        "Deadlift",
    )

    exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO exercise (
            base_exercise_id,
            session_schedule_id,
            reps,
            sets,
            rest,
            sort_order
        )
        VALUES ($1, $2, 5, 3, interval '00:03:00', 1)
        RETURNING exercise_id
        """,
        base_exercise_id,
        session_schedule_id,
    )

    # Create COMPLETED session
    performed_session_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_session (
            session_schedule_id,
            app_user_id,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4)
        RETURNING performed_session_id
        """,
        session_schedule_id,
        app_user_id,
        datetime.now() - timedelta(hours=1),
        datetime.now(),  # Session IS completed
    )

    # Create performed exercise WITHOUT completed_at (skipped/incomplete)
    performed_exercise_id = await db_transaction.fetchval(
        """
        INSERT INTO performed_exercise (
            performed_session_id,
            exercise_id,
            name,
            reps,
            weight,
            started_at,
            completed_at
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7)
        RETURNING performed_exercise_id
        """,
        performed_session_id,
        exercise_id,
        "Deadlift",
        [5, 5, 5],
        150000,
        datetime.now() - timedelta(minutes=30),
        None,  # Exercise NOT completed (maybe skipped last set?)
    )

    # Act: Backfill (should include this exercise because session is completed)
    await db_transaction.execute(
        """
        WITH pe_data AS (
            SELECT
                pe.performed_exercise_id,
                pe.weight,
                pe.reps,
                pe.rest,
                pe.started_at,
                COALESCE(pe.completed_at, ps.completed_at) as completed_at,  -- Use session time if exercise incomplete
                pe.sets,
                (COALESCE(pe.completed_at, ps.completed_at) - pe.started_at) / pe.sets AS set_duration
            FROM performed_exercise pe
            JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
            WHERE pe.performed_exercise_id = $1
              AND ps.completed_at IS NOT NULL  -- Session must be completed
              AND NOT EXISTS (
                  SELECT 1
                  FROM performed_exercise_set pes
                  JOIN performed_exercise pe2 ON pes.performed_exercise_id = pe2.performed_exercise_id
                  WHERE pe2.performed_session_id = pe.performed_session_id
              )
        )
        INSERT INTO performed_exercise_set (
            performed_exercise_id,
            exercise_set_type,
            weight,
            reps,
            rest,
            "order",
            started_at,
            completed_at
        )
        SELECT
            pe_data.performed_exercise_id,
            'regular',
            COALESCE(pe_data.weight, 0),
            rep_value,
            COALESCE(pe_data.rest[set_index], interval '00:02:00'),
            set_index,
            pe_data.started_at + (pe_data.set_duration * (set_index - 1)),
            pe_data.started_at + (pe_data.set_duration * set_index)
        FROM pe_data,
             LATERAL unnest(pe_data.reps) WITH ORDINALITY AS u(rep_value, set_index)
        """,
        performed_exercise_id,
    )

    # Assert: Sets WERE created (session is completed)
    count = await db_transaction.fetchval(
        "SELECT COUNT(*) FROM performed_exercise_set WHERE performed_exercise_id = $1",
        performed_exercise_id,
    )
    assert count == 3  # Sets created despite exercise.completed_at = NULL

    # Verify data
    sets = await db_transaction.fetch(
        """
        SELECT weight, reps, "order"
        FROM performed_exercise_set
        WHERE performed_exercise_id = $1
        ORDER BY "order"
        """,
        performed_exercise_id,
    )
    assert [s["reps"] for s in sets] == [5, 5, 5]
    assert all(s["weight"] == 150000 for s in sets)
