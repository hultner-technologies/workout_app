import pytest


@pytest.mark.unit
@pytest.mark.asyncio
async def test_positive_int_array_roundtrip(db_transaction):
    """
    Ensure positive-int domains and arrays can be written/read through asyncpg.
    """
    await db_transaction.execute('CREATE EXTENSION IF NOT EXISTS "uuid-ossp"')
    await db_transaction.execute("DROP DOMAIN IF EXISTS test_positive_int CASCADE")
    await db_transaction.execute("CREATE DOMAIN test_positive_int AS int CHECK (VALUE >= 0)")
    await db_transaction.execute(
        """
        CREATE TABLE test_performed_exercise (
            performed_exercise_id uuid DEFAULT uuid_generate_v1mc() PRIMARY KEY,
            reps test_positive_int[] NOT NULL
        )
        """
    )

    data = [10, 1, 10, 1]
    inserted_id = await db_transaction.fetchval(
        "INSERT INTO test_performed_exercise (reps) VALUES ($1) RETURNING performed_exercise_id",
        data,
    )

    row = await db_transaction.fetchrow(
        "SELECT reps FROM test_performed_exercise WHERE performed_exercise_id = $1",
        inserted_id,
    )
    assert row is not None
    assert row["reps"] == data
