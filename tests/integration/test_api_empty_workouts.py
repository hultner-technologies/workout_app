import pytest


@pytest.mark.integration
def test_empty_workouts_rpc_placeholder(supabase_service_client):
    """
    Placeholder integration that will call the Supabase RPC once the client is configured.
    """
    session_resp = (
        supabase_service_client.table("performed_session")
        .select("performed_session_id")
        .limit(1)
        .execute()
    )
    if not session_resp.data:
        pytest.skip("no performed sessions available via Supabase API")

    session_id = session_resp.data[0]["performed_session_id"]
    response = supabase_service_client.rpc(
        "draft_session_exercises_v2", {"performed_session_id_": session_id}
    ).execute()
    assert response.data is not None
