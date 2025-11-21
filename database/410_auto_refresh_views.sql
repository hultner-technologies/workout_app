-- database/410_auto_refresh_views.sql

CREATE OR REPLACE FUNCTION refresh_weekly_views()
RETURNS TRIGGER AS $$
BEGIN
  -- Only refresh when a session is marked as completed
  IF NEW.completed_at IS NOT NULL AND (OLD.completed_at IS NULL OR OLD.completed_at != NEW.completed_at) THEN
    -- Refresh materialized views in dependency order
    REFRESH MATERIALIZED VIEW CONCURRENTLY weekly_exercise_volume;
    REFRESH MATERIALIZED VIEW CONCURRENTLY weekly_muscle_volume;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER refresh_weekly_views_trigger
  AFTER UPDATE OF completed_at ON performed_session
  FOR EACH ROW
  WHEN (NEW.completed_at IS NOT NULL)
  EXECUTE FUNCTION refresh_weekly_views();

COMMENT ON FUNCTION refresh_weekly_views IS
  'Auto-refresh weekly materialized views when sessions are completed.
   Uses CONCURRENTLY to avoid blocking reads during refresh.';
