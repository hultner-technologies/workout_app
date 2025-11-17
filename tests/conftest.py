import json
from collections.abc import AsyncIterator
from typing import Iterator
from uuid import UUID

import asyncpg
import pytest
import pytest_asyncio

from supabase import Client, create_client
from tests.settings import get_db_settings, get_supabase_settings


@pytest_asyncio.fixture
async def asyncpg_pool() -> AsyncIterator[asyncpg.Pool]:
    """Shared connection pool for the Postgres test database."""
    db_settings = get_db_settings()
    pool = await asyncpg.create_pool(**db_settings.model_dump())
    try:
        yield pool
    finally:
        await pool.close()


@pytest_asyncio.fixture
async def db_transaction(asyncpg_pool: asyncpg.Pool) -> AsyncIterator[asyncpg.Connection]:
    """
    Wrap each test in a transaction that is rolled back to keep the database clean.
    """
    async with asyncpg_pool.acquire() as connection:
        transaction = connection.transaction()
        await transaction.start()
        try:
            yield connection
        finally:
            await transaction.rollback()


def _build_supabase_client(key: str | None, fixture_name: str) -> Client:
    supabase_settings = get_supabase_settings()
    url = supabase_settings.url
    if not url or not key:
        pytest.skip(
            f"{fixture_name} requires TEST_SUPABASE_URL and the appropriate key to be set "
            "in environment variables or the .env file."
        )
    return create_client(str(url), key)


@pytest.fixture(scope="session")
def supabase_client() -> Iterator[Client]:
    """
    Placeholder client using the anon key – tests skip until env variables are supplied.
    """
    settings = get_supabase_settings()
    yield _build_supabase_client(settings.anon_key, "supabase_client")


@pytest.fixture(scope="session")
def supabase_service_client() -> Iterator[Client]:
    """
    Placeholder client using the service role key for privileged RPC calls.
    """
    settings = get_supabase_settings()
    yield _build_supabase_client(settings.service_role_key, "supabase_service_client")


async def create_test_user(
    conn: asyncpg.Connection,
    user_id: UUID,
    email: str,
    username: str | None = None,
    name: str | None = None,
) -> None:
    """
    Helper function to create a test user in auth.users.

    This function creates a user in auth.users, which triggers the
    handle_new_user() function that automatically creates an app_user record.

    Args:
        conn: Database connection
        user_id: UUID for the user
        email: Email address
        username: Optional username (auto-generated if not provided)
        name: Optional name (defaults to username if not provided)
    """
    # Build metadata JSON for username and name
    metadata = {}
    if username:
        metadata["username"] = username
    if name:
        metadata["name"] = name

    # Insert into auth.users - this will trigger handle_new_user()
    # Note: raw_user_meta_data expects a JSON string, not a Python dict
    await conn.execute(
        """
        INSERT INTO auth.users (
            id,
            instance_id,
            email,
            encrypted_password,
            email_confirmed_at,
            raw_user_meta_data,
            aud,
            role
        )
        VALUES (
            $1,
            '00000000-0000-0000-0000-000000000000',
            $2,
            crypt('password', gen_salt('bf')),
            now(),
            $3,
            'authenticated',
            'authenticated'
        )
        """,
        user_id,
        email,
        json.dumps(metadata) if metadata else "{}",
    )
