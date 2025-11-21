"""
Tests for Function Search Path Protection

This test suite verifies that all functions have SET search_path = public
to protect against search_path hijacking attacks.

Issue: Functions without search_path protection vulnerable to hijacking
Fix: Add SET search_path = public to all functions
Reference: Supabase database linter - function_search_path_mutable

Functions tested:
- get_exercise_metadata_stats
- set_exercise_muscles
- add_primary_muscle
- add_secondary_muscle
- find_exercises_by_muscle
- debug_rls_performance
- backfill_username_on_insert
- generate_unique_username (already fixed in Priority 2)
"""

import pytest


@pytest.mark.unit
@pytest.mark.asyncio
async def test_get_exercise_metadata_stats_has_search_path(db_transaction):
    """Test that get_exercise_metadata_stats has search_path protection"""
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'get_exercise_metadata_stats'
        """
    )
    assert has_search_path, "get_exercise_metadata_stats should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_set_exercise_muscles_has_search_path(db_transaction):
    """Test that set_exercise_muscles has search_path protection"""
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'set_exercise_muscles'
        """
    )
    assert has_search_path, "set_exercise_muscles should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_add_primary_muscle_has_search_path(db_transaction):
    """Test that add_primary_muscle has search_path protection"""
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'add_primary_muscle'
        """
    )
    assert has_search_path, "add_primary_muscle should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_add_secondary_muscle_has_search_path(db_transaction):
    """Test that add_secondary_muscle has search_path protection"""
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'add_secondary_muscle'
        """
    )
    assert has_search_path, "add_secondary_muscle should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_find_exercises_by_muscle_has_search_path(db_transaction):
    """Test that find_exercises_by_muscle has search_path protection"""
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'find_exercises_by_muscle'
        """
    )
    assert has_search_path, "find_exercises_by_muscle should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_debug_rls_performance_has_search_path(db_transaction):
    """Test that debug_rls_performance has search_path protection"""
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'debug_rls_performance'
        """
    )
    assert has_search_path, "debug_rls_performance should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_backfill_username_on_insert_has_search_path(db_transaction):
    """Test that backfill_username_on_insert has search_path protection"""
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'backfill_username_on_insert'
        """
    )
    assert has_search_path, "backfill_username_on_insert should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_generate_unique_username_has_search_path(db_transaction):
    """Test that generate_unique_username has search_path protection (from Priority 2)"""
    has_search_path = await db_transaction.fetchval(
        """
        SELECT proconfig::text LIKE '%search_path=public%'
        FROM pg_proc
        WHERE proname = 'generate_unique_username'
        """
    )
    assert has_search_path, "generate_unique_username should have search_path protection"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_functions_still_work_after_search_path_added(db_transaction):
    """Test that functions still work correctly after adding search_path"""
    # Test generate_unique_username
    username = await db_transaction.fetchval("SELECT generate_unique_username()")
    assert username is not None, "generate_unique_username should still work"

    # Test get_exercise_metadata_stats
    stats = await db_transaction.fetchrow("SELECT * FROM get_exercise_metadata_stats()")
    assert stats is not None, "get_exercise_metadata_stats should still work"

    # Note: Other functions require specific test data setup, tested individually
