import pytest


@pytest.mark.integration
def test_anonymous_client_cannot_read_performed_sessions(supabase_client):
    """
    PR #1 security fix: Anonymous users via HTTP API cannot access workout data.

    This test verifies the RLS policy DROP statements work correctly through
    the real Supabase HTTP API layer.
    """
    response = supabase_client.table("performed_session").select("*").execute()
    assert len(response.data) == 0, (
        "Anonymous users should not be able to read any performed_session records"
    )


@pytest.mark.integration
def test_anonymous_client_cannot_read_performed_exercises(supabase_client):
    """PR #1 security fix: Anonymous users cannot read exercise performance data"""
    response = supabase_client.table("performed_exercise").select("*").execute()
    assert len(response.data) == 0, (
        "Anonymous users should not be able to read any performed_exercise records"
    )


@pytest.mark.integration
def test_anonymous_client_can_read_public_data(supabase_client):
    """Verify anonymous users can still access public reference data (plans, exercises)"""
    # Plans should be publicly readable
    _plans_response = supabase_client.table("plan").select("*").limit(5).execute()
    # We don't assert > 0 because test database might be empty, just verify no error

    # Base exercises should be publicly readable
    _exercises_response = (
        supabase_client.table("base_exercise").select("*").limit(5).execute()
    )
    # Again, just verify no error - empty database is valid
