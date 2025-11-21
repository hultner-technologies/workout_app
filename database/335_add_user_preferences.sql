-- database/335_add_user_preferences.sql

ALTER TABLE app_user
  ADD COLUMN training_preferences JSONB DEFAULT '{
    "volume_landmarks": {
      "enabled": true,
      "custom_mev": null,
      "custom_mav": null,
      "custom_mrv": null
    },
    "plateau_detection": {
      "enabled": true,
      "sensitivity": "medium",
      "notification_threshold": 3
    },
    "estimated_training_age": "intermediate",
    "deload_frequency_weeks": 6,
    "mcp_data_sharing": {
      "performance_history": true,
      "body_metrics": false,
      "notes": false
    }
  }'::jsonb;

COMMENT ON COLUMN app_user.training_preferences IS
  'User preferences for analytics, plateau detection, and MCP data sharing.

   Structure:
   - volume_landmarks: MEV/MAV/MRV customization
   - plateau_detection: sensitivity and notification settings
   - estimated_training_age: beginner/intermediate/advanced
   - deload_frequency_weeks: user preference for deload timing
   - mcp_data_sharing: privacy controls for AI features';
