"""
Tests for admin impersonation system.

Tests the admin_users table, impersonation_audit table, and helper functions
for the admin impersonation feature (Phase 2.2).
"""

import pytest
from uuid import uuid4


# =============================================================================
# SCHEMA TESTS
# =============================================================================


@pytest.mark.unit
@pytest.mark.asyncio
async def test_admin_users_table_exists(db_transaction):
    """Test that admin_users table exists with correct columns."""
    result = await db_transaction.fetchrow(
        """
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = 'admin_users'
        ORDER BY ordinal_position
        """
    )
    assert result is not None, "admin_users table should exist"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_admin_users_required_columns(db_transaction):
    """Test that admin_users has all required columns."""
    columns = await db_transaction.fetch(
        """
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = 'admin_users'
        """
    )
    column_names = {col["column_name"] for col in columns}

    required_columns = {
        "admin_user_id",
        "role",
        "granted_by",
        "granted_at",
        "revoked_at",
        "notes",
    }
    assert required_columns.issubset(
        column_names
    ), f"Missing columns: {required_columns - column_names}"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_admin_users_role_constraint(db_transaction):
    """Test that admin role is constrained to valid values."""
    # Check constraint exists
    constraint = await db_transaction.fetchrow(
        """
        SELECT conname, pg_get_constraintdef(oid) as definition
        FROM pg_constraint
        WHERE conrelid = 'admin_users'::regclass
          AND conname LIKE '%role%'
        """
    )
    assert constraint is not None, "Role constraint should exist"
    assert (
        "support" in constraint["definition"]
    ), "Should allow 'support' role"
    assert "admin" in constraint["definition"], "Should allow 'admin' role"
    assert (
        "superadmin" in constraint["definition"]
    ), "Should allow 'superadmin' role"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_admin_users_foreign_key_to_app_user(db_transaction):
    """Test that admin_user_id references app_user."""
    fk = await db_transaction.fetchrow(
        """
        SELECT
            tc.constraint_name,
            kcu.column_name,
            ccu.table_name AS foreign_table_name,
            ccu.column_name AS foreign_column_name
        FROM information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
          ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage AS ccu
          ON ccu.constraint_name = tc.constraint_name
        WHERE tc.table_name = 'admin_users'
          AND tc.constraint_type = 'FOREIGN KEY'
          AND kcu.column_name = 'admin_user_id'
        """
    )
    assert fk is not None, "Foreign key should exist for admin_user_id"
    assert (
        fk["foreign_table_name"] == "app_user"
    ), "Should reference app_user table"
    assert (
        fk["foreign_column_name"] == "app_user_id"
    ), "Should reference app_user_id column"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_admin_users_rls_enabled(db_transaction):
    """Test that RLS is enabled on admin_users table."""
    rls_enabled = await db_transaction.fetchval(
        """
        SELECT relrowsecurity
        FROM pg_class
        WHERE relname = 'admin_users'
        """
    )
    assert rls_enabled, "RLS should be enabled on admin_users"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_impersonation_audit_table_exists(db_transaction):
    """Test that impersonation_audit table exists."""
    result = await db_transaction.fetchrow(
        """
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = 'impersonation_audit'
        LIMIT 1
        """
    )
    assert result is not None, "impersonation_audit table should exist"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_impersonation_audit_required_columns(db_transaction):
    """Test that impersonation_audit has all required columns."""
    columns = await db_transaction.fetch(
        """
        SELECT column_name, data_type
        FROM information_schema.columns
        WHERE table_name = 'impersonation_audit'
        """
    )
    column_names = {col["column_name"] for col in columns}

    required_columns = {
        "audit_id",
        "admin_user_id",
        "target_user_id",
        "started_at",
        "ended_at",
        "ended_reason",
        "ip_address",
        "user_agent",
        "notes",
    }
    assert required_columns.issubset(
        column_names
    ), f"Missing columns: {required_columns - column_names}"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_impersonation_audit_foreign_keys(db_transaction):
    """Test that impersonation_audit has foreign keys to app_user."""
    fks = await db_transaction.fetch(
        """
        SELECT
            kcu.column_name,
            ccu.table_name AS foreign_table_name,
            ccu.column_name AS foreign_column_name
        FROM information_schema.table_constraints AS tc
        JOIN information_schema.key_column_usage AS kcu
          ON tc.constraint_name = kcu.constraint_name
        JOIN information_schema.constraint_column_usage AS ccu
          ON ccu.constraint_name = tc.constraint_name
        WHERE tc.table_name = 'impersonation_audit'
          AND tc.constraint_type = 'FOREIGN KEY'
        """
    )

    fk_columns = {fk["column_name"] for fk in fks}
    assert "admin_user_id" in fk_columns, "Should have FK for admin_user_id"
    assert (
        "target_user_id" in fk_columns
    ), "Should have FK for target_user_id"

    for fk in fks:
        assert (
            fk["foreign_table_name"] == "app_user"
        ), "All FKs should reference app_user"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_impersonation_audit_rls_enabled(db_transaction):
    """Test that RLS is enabled on impersonation_audit table."""
    rls_enabled = await db_transaction.fetchval(
        """
        SELECT relrowsecurity
        FROM pg_class
        WHERE relname = 'impersonation_audit'
        """
    )
    assert rls_enabled, "RLS should be enabled on impersonation_audit"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_impersonation_audit_ended_reason_constraint(db_transaction):
    """Test that ended_reason is constrained to valid values."""
    constraint = await db_transaction.fetchrow(
        """
        SELECT conname, pg_get_constraintdef(oid) as definition
        FROM pg_constraint
        WHERE conrelid = 'impersonation_audit'::regclass
          AND conname LIKE '%ended_reason%'
        """
    )
    assert constraint is not None, "ended_reason constraint should exist"
    definition = constraint["definition"]
    assert "manual" in definition, "Should allow 'manual'"
    assert "timeout" in definition, "Should allow 'timeout'"
    assert (
        "session_revoked" in definition
    ), "Should allow 'session_revoked'"
    assert "admin_logout" in definition, "Should allow 'admin_logout'"


# =============================================================================
# HELPER FUNCTION TESTS
# =============================================================================


@pytest.mark.unit
@pytest.mark.asyncio
async def test_is_admin_function_exists(db_transaction):
    """Test that is_admin() function exists."""
    func_exists = await db_transaction.fetchval(
        """
        SELECT EXISTS (
            SELECT 1 FROM pg_proc WHERE proname = 'is_admin'
        )
        """
    )
    assert func_exists, "is_admin() function should exist"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_is_admin_function_signature(db_transaction):
    """Test that is_admin() has correct signature."""
    func = await db_transaction.fetchrow(
        """
        SELECT
            pg_get_function_result(oid) as return_type,
            pg_get_function_arguments(oid) as arguments
        FROM pg_proc
        WHERE proname = 'is_admin'
        """
    )
    assert func is not None, "is_admin() function should exist"
    assert (
        "boolean" in func["return_type"].lower()
    ), "Should return boolean"
    # Should accept optional uuid parameter with default auth.uid()
    assert (
        "uuid" in func["arguments"].lower()
        or func["arguments"].strip() == ""
    ), "Should accept uuid parameter"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_get_admin_role_function_exists(db_transaction):
    """Test that get_admin_role() function exists."""
    func_exists = await db_transaction.fetchval(
        """
        SELECT EXISTS (
            SELECT 1 FROM pg_proc WHERE proname = 'get_admin_role'
        )
        """
    )
    assert func_exists, "get_admin_role() function should exist"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_get_admin_role_function_signature(db_transaction):
    """Test that get_admin_role() has correct signature."""
    func = await db_transaction.fetchrow(
        """
        SELECT
            pg_get_function_result(oid) as return_type,
            pg_get_function_arguments(oid) as arguments
        FROM pg_proc
        WHERE proname = 'get_admin_role'
        """
    )
    assert func is not None, "get_admin_role() function should exist"
    assert "text" in func["return_type"].lower(), "Should return text"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_log_impersonation_start_function_exists(db_transaction):
    """Test that log_impersonation_start() function exists."""
    func_exists = await db_transaction.fetchval(
        """
        SELECT EXISTS (
            SELECT 1 FROM pg_proc WHERE proname = 'log_impersonation_start'
        )
        """
    )
    assert func_exists, "log_impersonation_start() function should exist"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_log_impersonation_end_function_exists(db_transaction):
    """Test that log_impersonation_end() function exists."""
    func_exists = await db_transaction.fetchval(
        """
        SELECT EXISTS (
            SELECT 1 FROM pg_proc WHERE proname = 'log_impersonation_end'
        )
        """
    )
    assert func_exists, "log_impersonation_end() function should exist"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_can_impersonate_user_function_exists(db_transaction):
    """Test that can_impersonate_user() function exists."""
    func_exists = await db_transaction.fetchval(
        """
        SELECT EXISTS (
            SELECT 1 FROM pg_proc WHERE proname = 'can_impersonate_user'
        )
        """
    )
    assert (
        func_exists
    ), "can_impersonate_user() function should exist for permission checks"


# =============================================================================
# INDEX TESTS
# =============================================================================


@pytest.mark.unit
@pytest.mark.asyncio
async def test_admin_users_has_indexes(db_transaction):
    """Test that admin_users has appropriate indexes."""
    indexes = await db_transaction.fetch(
        """
        SELECT indexname, indexdef
        FROM pg_indexes
        WHERE tablename = 'admin_users'
        """
    )
    index_names = {idx["indexname"] for idx in indexes}

    # Should have index for active admins
    assert any(
        "active" in name.lower() or "revoked" in idx["indexdef"].lower()
        for name, idx in zip(index_names, indexes)
    ), "Should have index for active (non-revoked) admins"


@pytest.mark.unit
@pytest.mark.asyncio
async def test_impersonation_audit_has_indexes(db_transaction):
    """Test that impersonation_audit has appropriate indexes."""
    indexes = await db_transaction.fetch(
        """
        SELECT indexname, indexdef
        FROM pg_indexes
        WHERE tablename = 'impersonation_audit'
        """
    )

    index_defs = " ".join(idx["indexdef"] for idx in indexes)

    # Check for expected indexes
    assert (
        "admin_user_id" in index_defs
    ), "Should have index on admin_user_id"
    assert (
        "target_user_id" in index_defs
    ), "Should have index on target_user_id"
    assert (
        "started_at" in index_defs
    ), "Should have index on started_at for sorting"


# =============================================================================
# INTEGRATION TESTS (require database connection)
# =============================================================================


@pytest.mark.integration
@pytest.mark.asyncio
async def test_is_admin_returns_false_for_non_admin(db_transaction):
    """Test that is_admin() returns false for non-admin users."""
    # Create a regular user
    user_id = uuid4()
    await db_transaction.execute(
        """
        INSERT INTO app_user (app_user_id, name, email, username, data)
        VALUES ($1, 'Test User', 'test@example.com', 'testuser', '{}')
        """,
        user_id,
    )

    # Check is_admin returns false
    is_admin = await db_transaction.fetchval(
        "SELECT is_admin($1)", user_id
    )
    assert not is_admin, "Regular user should not be admin"


@pytest.mark.integration
@pytest.mark.asyncio
async def test_is_admin_returns_true_for_admin(db_transaction):
    """Test that is_admin() returns true for admin users."""
    # Create a user
    user_id = uuid4()
    await db_transaction.execute(
        """
        INSERT INTO app_user (app_user_id, name, email, username, data)
        VALUES ($1, 'Admin User', 'admin@example.com', 'adminuser', '{}')
        """,
        user_id,
    )

    # Grant admin role
    await db_transaction.execute(
        """
        INSERT INTO admin_users (admin_user_id, role)
        VALUES ($1, 'admin')
        """,
        user_id,
    )

    # Check is_admin returns true
    is_admin = await db_transaction.fetchval(
        "SELECT is_admin($1)", user_id
    )
    assert is_admin, "Admin user should be identified as admin"


@pytest.mark.integration
@pytest.mark.asyncio
async def test_is_admin_returns_false_for_revoked_admin(db_transaction):
    """Test that is_admin() returns false for revoked admins."""
    # Create a user
    user_id = uuid4()
    await db_transaction.execute(
        """
        INSERT INTO app_user (app_user_id, name, email, username, data)
        VALUES ($1, 'Revoked Admin', 'revoked@example.com', 'revokedadmin', '{}')
        """,
        user_id,
    )

    # Grant and then revoke admin role
    await db_transaction.execute(
        """
        INSERT INTO admin_users (admin_user_id, role, revoked_at)
        VALUES ($1, 'admin', now())
        """,
        user_id,
    )

    # Check is_admin returns false
    is_admin = await db_transaction.fetchval(
        "SELECT is_admin($1)", user_id
    )
    assert not is_admin, "Revoked admin should not be identified as admin"


@pytest.mark.integration
@pytest.mark.asyncio
async def test_get_admin_role_returns_correct_role(db_transaction):
    """Test that get_admin_role() returns correct role."""
    # Create a support user
    user_id = uuid4()
    await db_transaction.execute(
        """
        INSERT INTO app_user (app_user_id, name, email, username, data)
        VALUES ($1, 'Support User', 'support@example.com', 'supportuser', '{}')
        """,
        user_id,
    )

    # Grant support role
    await db_transaction.execute(
        """
        INSERT INTO admin_users (admin_user_id, role)
        VALUES ($1, 'support')
        """,
        user_id,
    )

    # Check role
    role = await db_transaction.fetchval(
        "SELECT get_admin_role($1)", user_id
    )
    assert role == "support", "Should return 'support' role"


@pytest.mark.integration
@pytest.mark.asyncio
async def test_log_impersonation_start_creates_audit_record(
    db_transaction,
):
    """Test that log_impersonation_start() creates audit record."""
    # Create admin and target users
    admin_id = uuid4()
    target_id = uuid4()

    await db_transaction.execute(
        """
        INSERT INTO app_user (app_user_id, name, email, username, data)
        VALUES
            ($1, 'Admin', 'admin@example.com', 'admin', '{}'),
            ($2, 'Target', 'target@example.com', 'target', '{}')
        """,
        admin_id,
        target_id,
    )

    # Grant admin role
    await db_transaction.execute(
        """
        INSERT INTO admin_users (admin_user_id, role)
        VALUES ($1, 'admin')
        """,
        admin_id,
    )

    # Log impersonation start
    audit_id = await db_transaction.fetchval(
        """
        SELECT log_impersonation_start($1, $2, '127.0.0.1'::inet, 'Test Agent')
        """,
        admin_id,
        target_id,
    )

    assert audit_id is not None, "Should return audit_id"

    # Verify audit record
    audit = await db_transaction.fetchrow(
        """
        SELECT admin_user_id, target_user_id, started_at, ended_at, ip_address, user_agent
        FROM impersonation_audit
        WHERE audit_id = $1
        """,
        audit_id,
    )

    assert audit is not None, "Audit record should exist"
    assert audit["admin_user_id"] == admin_id
    assert audit["target_user_id"] == target_id
    assert audit["ended_at"] is None, "Should not be ended yet"
    assert str(audit["ip_address"]) == "127.0.0.1"
    assert audit["user_agent"] == "Test Agent"


@pytest.mark.integration
@pytest.mark.asyncio
async def test_log_impersonation_end_updates_audit_record(db_transaction):
    """Test that log_impersonation_end() updates audit record."""
    # Create admin and target users
    admin_id = uuid4()
    target_id = uuid4()

    await db_transaction.execute(
        """
        INSERT INTO app_user (app_user_id, name, email, username, data)
        VALUES
            ($1, 'Admin', 'admin@example.com', 'admin', '{}'),
            ($2, 'Target', 'target@example.com', 'target', '{}')
        """,
        admin_id,
        target_id,
    )

    # Grant admin role
    await db_transaction.execute(
        """
        INSERT INTO admin_users (admin_user_id, role)
        VALUES ($1, 'admin')
        """,
        admin_id,
    )

    # Start impersonation
    audit_id = await db_transaction.fetchval(
        """
        SELECT log_impersonation_start($1, $2)
        """,
        admin_id,
        target_id,
    )

    # End impersonation
    await db_transaction.execute(
        """
        SELECT log_impersonation_end($1, 'manual')
        """,
        audit_id,
    )

    # Verify audit record updated
    audit = await db_transaction.fetchrow(
        """
        SELECT ended_at, ended_reason
        FROM impersonation_audit
        WHERE audit_id = $1
        """,
        audit_id,
    )

    assert audit["ended_at"] is not None, "Should have ended_at timestamp"
    assert audit["ended_reason"] == "manual", "Should have ended_reason"


@pytest.mark.integration
@pytest.mark.asyncio
async def test_can_impersonate_user_prevents_admin_impersonation(
    db_transaction,
):
    """Test that admins cannot impersonate other admins."""
    # Create two admin users
    admin1_id = uuid4()
    admin2_id = uuid4()

    await db_transaction.execute(
        """
        INSERT INTO app_user (app_user_id, name, email, username, data)
        VALUES
            ($1, 'Admin 1', 'admin1@example.com', 'admin1', '{}'),
            ($2, 'Admin 2', 'admin2@example.com', 'admin2', '{}')
        """,
        admin1_id,
        admin2_id,
    )

    # Grant admin roles
    await db_transaction.execute(
        """
        INSERT INTO admin_users (admin_user_id, role)
        VALUES
            ($1, 'admin'),
            ($2, 'admin')
        """,
        admin1_id,
        admin2_id,
    )

    # Check if admin1 can impersonate admin2
    can_impersonate = await db_transaction.fetchval(
        """
        SELECT can_impersonate_user($1, $2)
        """,
        admin1_id,
        admin2_id,
    )

    assert (
        not can_impersonate
    ), "Admins should not be able to impersonate other admins"


@pytest.mark.integration
@pytest.mark.asyncio
async def test_can_impersonate_user_allows_regular_user_impersonation(
    db_transaction,
):
    """Test that admins can impersonate regular users."""
    # Create admin and regular user
    admin_id = uuid4()
    user_id = uuid4()

    await db_transaction.execute(
        """
        INSERT INTO app_user (app_user_id, name, email, username, data)
        VALUES
            ($1, 'Admin', 'admin@example.com', 'admin', '{}'),
            ($2, 'User', 'user@example.com', 'user', '{}')
        """,
        admin_id,
        user_id,
    )

    # Grant admin role to admin only
    await db_transaction.execute(
        """
        INSERT INTO admin_users (admin_user_id, role)
        VALUES ($1, 'admin')
        """,
        admin_id,
    )

    # Check if admin can impersonate regular user
    can_impersonate = await db_transaction.fetchval(
        """
        SELECT can_impersonate_user($1, $2)
        """,
        admin_id,
        user_id,
    )

    assert (
        can_impersonate
    ), "Admins should be able to impersonate regular users"
