import pytest


@pytest.mark.integration
def test_supabase_can_list_performed_sessions(supabase_client):
    response = (
        supabase_client.table("performed_session")
        .select("performed_session_id, session_schedule_id")
        .limit(1)
        .execute()
    )
    if not response.data:
        pytest.skip("no performed sessions available via Supabase API")

    row = response.data[0]
    assert "performed_session_id" in row
    assert "session_schedule_id" in row
