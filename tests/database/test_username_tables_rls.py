"""
Tests for Username Tables RLS Fix

This test suite verifies that username generation tables have RLS enabled
and block direct API access while preserving function access.

Issue: username_adjectives and username_nouns lack RLS (exposed via PostgREST)
Fix: Enable RLS + blocking policies (internal-only tables)
Reference: https://supabase.com/docs/guides/database/database-linter?lint=0013_rls_disabled_in_public

Tables:
- username_adjectives (140 words for username generation)
- username_nouns (182 words for username generation)
"""

import uuid

import pytest
from asyncpg import exceptions

from tests.conftest import create_test_user


@pytest.mark.unit
@pytest.mark.asyncio
async def test_username_adjectives_rls_enabled(db_transaction):
    """Test that RLS is enabled on username_adjectives table"""
    # Query pg_class to check if RLS is enabled
    rls_enabled = await db_transaction.fetchval(
        """
        SELECT relrowsecurity
        FROM pg_class
        WHERE relname = 'username_adjectives'
        AND relnamespace = 'public'::regnamespace
        """
    )
    assert rls_enabled, "RLS should be enabled on username_adjectives"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_username_nouns_rls_enabled(db_transaction):
    """Test that RLS is enabled on username_nouns table"""
    rls_enabled = await db_transaction.fetchval(
        """
        SELECT relrowsecurity
        FROM pg_class
        WHERE relname = 'username_nouns'
        AND relnamespace = 'public'::regnamespace
        """
    )
    assert rls_enabled, "RLS should be enabled on username_nouns"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_authenticated_user_cannot_read_username_adjectives(db_transaction):
    """Test that authenticated users cannot read username_adjectives directly"""
    user_id = uuid.uuid4()
    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="Test User"
    )

    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should see zero rows due to RLS policy blocking access
    count = await db_transaction.fetchval("SELECT COUNT(*) FROM username_adjectives")
    assert count == 0, "Authenticated users should not see username_adjectives (RLS blocks)"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_authenticated_user_cannot_read_username_nouns(db_transaction):
    """Test that authenticated users cannot read username_nouns directly"""
    user_id = uuid.uuid4()
    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="Test User"
    )

    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should see zero rows due to RLS policy blocking access
    count = await db_transaction.fetchval("SELECT COUNT(*) FROM username_nouns")
    assert count == 0, "Authenticated users should not see username_nouns (RLS blocks)"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_authenticated_user_cannot_insert_username_adjectives(db_transaction):
    """Test that authenticated users cannot insert to username_adjectives"""
    user_id = uuid.uuid4()
    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="Test User"
    )

    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should be blocked by RLS policy
    with pytest.raises(exceptions.InsufficientPrivilegeError):
        await db_transaction.execute(
            """
            INSERT INTO username_adjectives (word, category)
            VALUES ('TestAdj', 'test')
            """
        )


@pytest.mark.unit
@pytest.mark.asyncio
async def test_authenticated_user_cannot_insert_username_nouns(db_transaction):
    """Test that authenticated users cannot insert to username_nouns"""
    user_id = uuid.uuid4()
    await create_test_user(
        db_transaction, user_id, f"{user_id}@example.com", name="Test User"
    )

    await db_transaction.execute("SET LOCAL ROLE authenticated")
    await db_transaction.execute(
        "SELECT set_config('request.jwt.claim.sub', $1, true)", str(user_id)
    )

    # Should be blocked by RLS policy
    with pytest.raises(exceptions.InsufficientPrivilegeError):
        await db_transaction.execute(
            """
            INSERT INTO username_nouns (word, category)
            VALUES ('TestNoun', 'test')
            """
        )


@pytest.mark.unit
@pytest.mark.asyncio
async def test_generate_unique_username_still_works(db_transaction):
    """Test that generate_unique_username() function still works despite RLS"""
    # Function uses SECURITY DEFINER to bypass RLS
    username = await db_transaction.fetchval("SELECT generate_unique_username()")

    assert username is not None, "generate_unique_username() should return a username"
    assert len(username) > 5, "Generated username should have reasonable length"
    assert username[0].isupper(), "Generated username should start with uppercase (AdjectiveNoun format)"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_generate_unique_username_creates_unique_usernames(db_transaction):
    """Test that generate_unique_username() creates unique usernames"""
    # Generate 10 usernames
    usernames = set()
    for _ in range(10):
        username = await db_transaction.fetchval("SELECT generate_unique_username()")
        usernames.add(username)

    # All should be unique (at least mostly - tiny chance of collision with numbers)
    assert len(usernames) >= 8, "Most generated usernames should be unique"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_service_role_can_read_username_tables(db_transaction):
    """Test that service role (postgres) can read username tables"""
    # Service role should bypass RLS
    await db_transaction.execute("SET LOCAL ROLE postgres")

    # Should be able to read both tables
    adj_count = await db_transaction.fetchval("SELECT COUNT(*) FROM username_adjectives")
    noun_count = await db_transaction.fetchval("SELECT COUNT(*) FROM username_nouns")

    assert adj_count > 0, "Service role should see username_adjectives"
    assert noun_count > 0, "Service role should see username_nouns"

    # Verify we have the expected counts from seed data
    assert adj_count >= 140, "Should have at least 140 adjectives from seed data"
    assert noun_count >= 180, "Should have at least 180 nouns from seed data"
