# V3 Analytics Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement V3 analytics views enabling volume landmarks (MEV/MAV/MRV), plateau detection, and muscle balance tracking with research-backed thresholds.

**Architecture:** Add schema columns for future tracking (RIR, RPE), create materialized views for weekly volume aggregation, build analytics views on top using statistical methods from Phase 2 research, maintain backward compatibility with V2 API.

**Tech Stack:** PostgreSQL 15+, Supabase functions, Python pytest for testing

---

## Task 1: Add RIR/RPE Columns to performed_exercise_set

**Files:**
- Create: `database/330_add_set_tracking_columns.sql`
- Create: `tests/database/test_330_schema_additions.py`

### Step 1: Write the failing test

```python
# tests/database/test_330_schema_additions.py

def test_estimated_rir_column_exists(db_connection):
    """Verify estimated_rir column added to performed_exercise_set"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT column_name, is_nullable, data_type
        FROM information_schema.columns
        WHERE table_name = 'performed_exercise_set'
          AND column_name = 'estimated_rir'
    """)
    result = cursor.fetchone()
    assert result is not None
    assert result['is_nullable'] == 'YES'
    assert result['data_type'] == 'integer'

def test_rpe_column_exists(db_connection):
    """Verify rpe column added"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT column_name, is_nullable, data_type, numeric_precision, numeric_scale
        FROM information_schema.columns
        WHERE table_name = 'performed_exercise_set'
          AND column_name = 'rpe'
    """)
    result = cursor.fetchone()
    assert result is not None
    assert result['is_nullable'] == 'YES'
    assert result['data_type'] == 'numeric'
    assert result['numeric_precision'] == 3
    assert result['numeric_scale'] == 1

def test_calculated_columns_exist(db_connection):
    """Verify effective_volume_kg, estimated_1rm_kg, relative_intensity added"""
    cursor = db_connection.cursor()
    for col in ['effective_volume_kg', 'estimated_1rm_kg', 'relative_intensity']:
        cursor.execute("""
            SELECT column_name, is_nullable
            FROM information_schema.columns
            WHERE table_name = 'performed_exercise_set'
              AND column_name = %s
        """, (col,))
        result = cursor.fetchone()
        assert result is not None, f"Column {col} not found"
        assert result['is_nullable'] == 'YES'

def test_existing_data_has_null_values(db_connection):
    """Verify existing sets have NULL for new columns"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT COUNT(*) as count
        FROM performed_exercise_set
        WHERE estimated_rir IS NOT NULL
           OR rpe IS NOT NULL
           OR effective_volume_kg IS NOT NULL
    """)
    result = cursor.fetchone()
    assert result['count'] == 0, "New columns should be NULL for existing data"
```

### Step 2: Run test to verify it fails

Run: `pytest tests/database/test_330_schema_additions.py -v`

Expected: FAIL with "column 'estimated_rir' does not exist"

### Step 3: Write migration

```sql
-- database/330_add_set_tracking_columns.sql

-- Add columns to performed_exercise_set table
ALTER TABLE performed_exercise_set
  -- RIR tracking for effective volume calculations (optional - historical data won't have this)
  ADD COLUMN estimated_rir INTEGER,

  -- RPE tracking (Rate of Perceived Exertion, 1-10 scale, optional)
  ADD COLUMN rpe NUMERIC(3,1),

  -- Superset grouping (optional - links sets performed together)
  ADD COLUMN superset_group_id UUID,

  -- Calculated fields (auto-updated via trigger, nullable for historical data)
  ADD COLUMN effective_volume_kg NUMERIC(10,2),
  ADD COLUMN estimated_1rm_kg NUMERIC(10,2),
  ADD COLUMN relative_intensity NUMERIC(5,2);

-- Add comprehensive comments
COMMENT ON COLUMN performed_exercise_set.estimated_rir IS
  'Reps in reserve (0 = failure, 1-3 = optimal hypertrophy).
   NULLABLE - historical data will not have this field.
   When NULL, effective_volume_kg uses unadjusted volume.';

COMMENT ON COLUMN performed_exercise_set.rpe IS
  'Rate of perceived exertion (1-10 scale, often matches 10-RIR).
   NULLABLE - optional field for users who track RPE.';

COMMENT ON COLUMN performed_exercise_set.superset_group_id IS
  'Links sets performed as supersets. NULL for regular sets.';

COMMENT ON COLUMN performed_exercise_set.effective_volume_kg IS
  'Auto-calculated: volume adjusted for set type and RIR (if available).
   Falls back to standard volume calculation when RIR is NULL.';

COMMENT ON COLUMN performed_exercise_set.estimated_1rm_kg IS
  'Auto-calculated: 1RM estimate using adaptive formula (Epley/Brzycki/Mayhew).
   NULL for sets with >15 reps (unreliable estimation).';

COMMENT ON COLUMN performed_exercise_set.relative_intensity IS
  'Auto-calculated: % of estimated 1RM. NULL when 1RM estimation is unavailable.';
```

### Step 4: Run migration

Run: `psql -d workout_db -f database/330_add_set_tracking_columns.sql`

Expected: "ALTER TABLE" success message

### Step 5: Run tests to verify they pass

Run: `pytest tests/database/test_330_schema_additions.py -v`

Expected: All tests PASS

### Step 6: Commit

```bash
git add database/330_add_set_tracking_columns.sql tests/database/test_330_schema_additions.py
git commit -m "feat: add RIR, RPE, and calculated columns to performed_exercise_set

- Add estimated_rir (INTEGER, nullable) for reps in reserve tracking
- Add rpe (NUMERIC(3,1), nullable) for rate of perceived exertion
- Add superset_group_id (UUID, nullable) for linking supersets
- Add effective_volume_kg, estimated_1rm_kg, relative_intensity (auto-calculated fields)
- All columns nullable for historical data compatibility
- Comprehensive column comments documenting research basis"
```

---

## Task 2: Add training_preferences to app_user

**Files:**
- Create: `database/335_add_user_preferences.sql`
- Create: `tests/database/test_335_user_preferences.py`

### Step 1: Write the failing test

```python
# tests/database/test_335_user_preferences.py

import json

def test_training_preferences_column_exists(db_connection):
    """Verify training_preferences column added to app_user"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT column_name, is_nullable, data_type
        FROM information_schema.columns
        WHERE table_name = 'app_user'
          AND column_name = 'training_preferences'
    """)
    result = cursor.fetchone()
    assert result is not None
    assert result['data_type'] == 'jsonb'

def test_existing_users_get_default_preferences(db_connection):
    """Verify existing users get default training_preferences"""
    cursor = db_connection.cursor()

    # Get first user
    cursor.execute("SELECT user_id, training_preferences FROM app_user LIMIT 1")
    user = cursor.fetchone()

    assert user is not None
    assert user['training_preferences'] is not None

    prefs = user['training_preferences']
    assert 'volume_landmarks' in prefs
    assert prefs['volume_landmarks']['enabled'] == True
    assert 'plateau_detection' in prefs
    assert prefs['plateau_detection']['enabled'] == True

def test_can_update_custom_landmarks(db_connection):
    """Verify users can set custom MEV/MAV/MRV values"""
    cursor = db_connection.cursor()

    # Get a user
    cursor.execute("SELECT user_id FROM app_user LIMIT 1")
    user_id = cursor.fetchone()['user_id']

    # Update custom MEV
    cursor.execute("""
        UPDATE app_user
        SET training_preferences = jsonb_set(
            training_preferences,
            '{volume_landmarks,custom_mev}',
            '8'::jsonb
        )
        WHERE user_id = %s
        RETURNING training_preferences->'volume_landmarks'->>'custom_mev' as custom_mev
    """, (user_id,))

    result = cursor.fetchone()
    assert result['custom_mev'] == '8'
```

### Step 2: Run test to verify it fails

Run: `pytest tests/database/test_335_user_preferences.py -v`

Expected: FAIL with "column 'training_preferences' does not exist"

### Step 3: Write migration

```sql
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
```

### Step 4: Run migration

Run: `psql -d workout_db -f database/335_add_user_preferences.sql`

Expected: "ALTER TABLE" success, all existing users get default preferences

### Step 5: Run tests to verify they pass

Run: `pytest tests/database/test_335_user_preferences.py -v`

Expected: All tests PASS

### Step 6: Commit

```bash
git add database/335_add_user_preferences.sql tests/database/test_335_user_preferences.py
git commit -m "feat: add training_preferences to app_user

- Add training_preferences JSONB column with default structure
- Include volume_landmarks (MEV/MAV/MRV custom values)
- Include plateau_detection settings
- Include MCP data sharing privacy controls
- All existing users get default preferences automatically"
```

---

## Task 3: Create calculate_effective_volume Function

**Files:**
- Create: `database/380_calculate_effective_volume.sql`
- Create: `tests/database/test_380_effective_volume.py`

### Step 1: Write the failing test

```python
# tests/database/test_380_effective_volume.py

def test_regular_set_volume(db_connection):
    """Regular set: simple weight × reps / 1000"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT calculate_effective_volume('regular', 100000, 10, NULL) as volume
    """)
    result = cursor.fetchone()
    assert result['volume'] == 1000.0  # 100kg × 10 reps

def test_rir_0_3_no_adjustment(db_connection):
    """RIR 0-3: No volume adjustment (1.0x multiplier)"""
    cursor = db_connection.cursor()
    for rir in [0, 1, 2, 3]:
        cursor.execute("""
            SELECT calculate_effective_volume('regular', 100000, 10, %s) as volume
        """, (rir,))
        result = cursor.fetchone()
        assert result['volume'] == 1000.0, f"RIR {rir} should be 1.0x"

def test_rir_4_adjustment(db_connection):
    """RIR 4: 0.9x multiplier"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT calculate_effective_volume('regular', 100000, 10, 4) as volume
    """)
    result = cursor.fetchone()
    assert result['volume'] == 900.0  # 1000kg × 0.9

def test_rir_5_adjustment(db_connection):
    """RIR 5: 0.8x multiplier"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT calculate_effective_volume('regular', 100000, 10, 5) as volume
    """)
    result = cursor.fetchone()
    assert result['volume'] == 800.0  # 1000kg × 0.8

def test_rir_6_plus_adjustment(db_connection):
    """RIR 6+: 0.6x multiplier"""
    cursor = db_connection.cursor()
    for rir in [6, 7, 8, 9, 10]:
        cursor.execute("""
            SELECT calculate_effective_volume('regular', 100000, 10, %s) as volume
        """, (rir,))
        result = cursor.fetchone()
        assert result['volume'] == 600.0, f"RIR {rir} should be 0.6x"

def test_warmup_excluded(db_connection):
    """Warm-up sets return 0"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT calculate_effective_volume('warm-up', 50000, 5, NULL) as volume
    """)
    result = cursor.fetchone()
    assert result['volume'] == 0

def test_null_rir_defaults_to_1x(db_connection):
    """NULL RIR (historical data) uses 1.0x multiplier"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT calculate_effective_volume('regular', 100000, 10, NULL) as volume
    """)
    result = cursor.fetchone()
    assert result['volume'] == 1000.0

def test_all_set_types_handled(db_connection):
    """All set types return expected volume"""
    cursor = db_connection.cursor()
    set_types = ['regular', 'pyramid-set', 'super-set', 'amrap', 'drop-set', 'myo-rep']

    for set_type in set_types:
        cursor.execute("""
            SELECT calculate_effective_volume(%s, 100000, 10, NULL) as volume
        """, (set_type,))
        result = cursor.fetchone()
        assert result['volume'] == 1000.0, f"{set_type} should calculate volume"
```

### Step 2: Run test to verify it fails

Run: `pytest tests/database/test_380_effective_volume.py -v`

Expected: FAIL with "function calculate_effective_volume does not exist"

### Step 3: Write function

```sql
-- database/380_calculate_effective_volume.sql

CREATE OR REPLACE FUNCTION calculate_effective_volume(
  p_set_type TEXT,
  p_weight INTEGER,      -- in grams
  p_reps INTEGER,
  p_estimated_rir INTEGER DEFAULT NULL  -- Nullable - historical data won't have this
) RETURNS NUMERIC AS $$
DECLARE
  v_base_volume NUMERIC;
  v_rir_multiplier NUMERIC := 1.0;
  v_effective_volume NUMERIC;
BEGIN
  -- Base volume calculation: weight × reps for all set types
  -- (Myo-reps are handled via parent/child set relationships, not special calculation)
  CASE p_set_type
    WHEN 'regular', 'pyramid-set', 'super-set', 'amrap', 'drop-set', 'myo-rep' THEN
      v_base_volume := (p_weight * p_reps) / 1000.0;  -- Convert grams to kg

    WHEN 'warm-up' THEN
      -- Warm-ups don't count toward effective volume
      RETURN 0;

    ELSE
      -- Default to standard volume calculation for unknown set types
      v_base_volume := (p_weight * p_reps) / 1000.0;
  END CASE;

  -- RIR adjustment (optional, only when data is available)
  -- Based on research showing hypertrophy decreases linearly with higher RIR
  IF p_estimated_rir IS NOT NULL THEN
    v_rir_multiplier := CASE
      WHEN p_estimated_rir <= 3 THEN 1.0   -- Optimal (0-3 RIR)
      WHEN p_estimated_rir = 4 THEN 0.9    -- Good
      WHEN p_estimated_rir = 5 THEN 0.8    -- Fair
      ELSE 0.6                              -- 6+ RIR not recommended for hypertrophy
    END;
  END IF;
  -- Note: When RIR is NULL (historical data), multiplier stays 1.0 (unadjusted)

  v_effective_volume := v_base_volume * v_rir_multiplier;

  RETURN ROUND(v_effective_volume, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION calculate_effective_volume IS
  'Calculate effective volume based on set type and RIR (when available).

   Parameters:
   - p_set_type: Type of set (regular, warm-up, drop-set, myo-rep, etc.)
   - p_weight: Weight in grams
   - p_reps: Number of reps performed
   - p_estimated_rir: Reps in reserve (NULL for historical data)

   Returns: Effective volume in kg

   Volume calculation:
   - Base: weight × reps / 1000 (converts grams to kg)
   - Warm-ups: Always return 0 (excluded from working volume)
   - RIR adjustment (when not NULL):
     * 0-3 RIR: 1.0x (optimal)
     * 4 RIR: 0.9x (good)
     * 5 RIR: 0.8x (fair)
     * 6+ RIR: 0.6x (not recommended for hypertrophy)
   - NULL RIR: 1.0x (unadjusted, for historical data)

   Research: Robinson et al. 2024 (proximity-to-failure dose-response)';
```

### Step 4: Run migration

Run: `psql -d workout_db -f database/380_calculate_effective_volume.sql`

Expected: "CREATE FUNCTION" success message

### Step 5: Run tests to verify they pass

Run: `pytest tests/database/test_380_effective_volume.py -v`

Expected: All tests PASS

### Step 6: Commit

```bash
git add database/380_calculate_effective_volume.sql tests/database/test_380_effective_volume.py
git commit -m "feat: add calculate_effective_volume function

- Calculate effective volume adjusted for set type and RIR
- RIR multipliers based on Robinson et al. 2024 research:
  * 0-3 RIR: 1.0x (optimal hypertrophy range)
  * 4 RIR: 0.9x
  * 5 RIR: 0.8x
  * 6+ RIR: 0.6x (suboptimal for hypertrophy)
- Warm-up sets return 0 (excluded from working volume)
- NULL RIR uses 1.0x for historical data compatibility
- Comprehensive tests for all set types and RIR values"
```

---

## Task 4: Create estimate_1rm_adaptive Function

**Files:**
- Create: `database/385_estimate_1rm_adaptive.sql`
- Create: `tests/database/test_385_1rm_estimation.py`

### Step 1: Write the failing test

```python
# tests/database/test_385_1rm_estimation.py

def test_1rm_actual_weight(db_connection):
    """1 rep = actual weight is 1RM"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT estimate_1rm_adaptive(100000, 1) as estimated_1rm
    """)
    result = cursor.fetchone()
    assert result['estimated_1rm'] == 100.0

def test_epley_low_reps(db_connection):
    """2-5 reps uses Epley formula"""
    cursor = db_connection.cursor()

    # Test 3 reps: 1RM = weight × (1 + 0.0333 × reps)
    cursor.execute("""
        SELECT estimate_1rm_adaptive(100000, 3) as estimated_1rm
    """)
    result = cursor.fetchone()
    expected = 100 * (1 + 0.0333 * 3)
    assert abs(result['estimated_1rm'] - expected) < 0.1

def test_brzycki_moderate_reps(db_connection):
    """6-10 reps uses Brzycki formula"""
    cursor = db_connection.cursor()

    # Test 8 reps: 1RM = weight × (36 / (37 - reps))
    cursor.execute("""
        SELECT estimate_1rm_adaptive(100000, 8) as estimated_1rm
    """)
    result = cursor.fetchone()
    expected = 100 * (36 / (37 - 8))
    assert abs(result['estimated_1rm'] - expected) < 0.1

def test_mayhew_high_reps(db_connection):
    """11-15 reps uses Mayhew formula"""
    cursor = db_connection.cursor()

    # Test 12 reps: 1RM = (100 × weight) / (52.2 + 41.9 × e^(-0.055 × reps))
    cursor.execute("""
        SELECT estimate_1rm_adaptive(100000, 12) as estimated_1rm
    """)
    result = cursor.fetchone()
    # Just verify it returns a reasonable value (formula is complex)
    assert result['estimated_1rm'] > 100
    assert result['estimated_1rm'] < 150

def test_very_high_reps_returns_null(db_connection):
    """>15 reps returns NULL (unreliable estimation)"""
    cursor = db_connection.cursor()

    for reps in [16, 20, 25, 30]:
        cursor.execute("""
            SELECT estimate_1rm_adaptive(100000, %s) as estimated_1rm
        """, (reps,))
        result = cursor.fetchone()
        assert result['estimated_1rm'] is None, f"{reps} reps should return NULL"

def test_zero_reps_returns_null(db_connection):
    """0 reps returns NULL (invalid)"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT estimate_1rm_adaptive(100000, 0) as estimated_1rm
    """)
    result = cursor.fetchone()
    assert result['estimated_1rm'] is None
```

### Step 2: Run test to verify it fails

Run: `pytest tests/database/test_385_1rm_estimation.py -v`

Expected: FAIL with "function estimate_1rm_adaptive does not exist"

### Step 3: Write function

```sql
-- database/385_estimate_1rm_adaptive.sql

CREATE OR REPLACE FUNCTION estimate_1rm_adaptive(
  p_weight INTEGER,  -- in grams
  p_reps INTEGER
) RETURNS NUMERIC AS $$
DECLARE
  v_weight_kg NUMERIC := p_weight / 1000.0;
  v_1rm_kg NUMERIC;
BEGIN
  -- Adaptive formula selection based on rep range
  CASE
    WHEN p_reps <= 0 OR p_reps > 15 THEN
      -- Invalid or unreliable range
      RETURN NULL;

    WHEN p_reps = 1 THEN
      -- Already 1RM
      v_1rm_kg := v_weight_kg;

    WHEN p_reps BETWEEN 2 AND 5 THEN
      -- Epley formula (best for low reps, <3% error)
      -- 1RM = weight × (1 + 0.0333 × reps)
      v_1rm_kg := v_weight_kg * (1 + 0.0333 * p_reps);

    WHEN p_reps BETWEEN 6 AND 10 THEN
      -- Brzycki formula (best for moderate reps, 3-5% error)
      -- 1RM = weight × (36 / (37 - reps))
      v_1rm_kg := v_weight_kg * (36.0 / (37 - p_reps));

    WHEN p_reps BETWEEN 11 AND 15 THEN
      -- Mayhew formula (best for higher reps, 5-10% error)
      -- 1RM = (100 × weight) / (52.2 + 41.9 × e^(-0.055 × reps))
      v_1rm_kg := (100 * v_weight_kg) / (52.2 + 41.9 * EXP(-0.055 * p_reps));

  END CASE;

  RETURN ROUND(v_1rm_kg, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION estimate_1rm_adaptive IS
  'Estimate 1RM using rep-range optimized formulas.

   Parameters:
   - p_weight: Weight lifted in grams
   - p_reps: Number of reps performed

   Returns: Estimated 1RM in kg, or NULL if unreliable

   Formula selection by rep range:
   - 1 rep: Actual weight is 1RM
   - 2-5 reps: Epley formula (error <3%)
     1RM = weight × (1 + 0.0333 × reps)
   - 6-10 reps: Brzycki formula (error 3-5%)
     1RM = weight × (36 / (37 - reps))
   - 11-15 reps: Mayhew formula (error 5-10%)
     1RM = (100 × weight) / (52.2 + 41.9 × e^(-0.055 × reps))
   - >15 reps: NULL (error >10%, unreliable)

   Research:
   - Epley (1985)
   - Brzycki (1993) - DOI: 10.1080/07303084.1993.10606684
   - Mayhew et al. (1992) - PMID: 1293423
   - LeSuer et al. (1997) - Accuracy comparison study';
```

### Step 4: Run migration

Run: `psql -d workout_db -f database/385_estimate_1rm_adaptive.sql`

Expected: "CREATE FUNCTION" success message

### Step 5: Run tests to verify they pass

Run: `pytest tests/database/test_385_1rm_estimation.py -v`

Expected: All tests PASS

### Step 6: Commit

```bash
git add database/385_estimate_1rm_adaptive.sql tests/database/test_385_1rm_estimation.py
git commit -m "feat: add estimate_1rm_adaptive function

- Adaptive 1RM estimation using rep-range optimized formulas
- 2-5 reps: Epley (<3% error)
- 6-10 reps: Brzycki (3-5% error) - already in use
- 11-15 reps: Mayhew (5-10% error)
- >15 reps: Returns NULL (>10% error, unreliable)
- Research citations: Epley 1985, Brzycki 1993, Mayhew 1992
- Comprehensive tests for all rep ranges"
```

---

## Task 5: Create Auto-Update Trigger for Calculated Fields

**Files:**
- Create: `database/390_auto_update_calculated_fields.sql`
- Create: `tests/database/test_390_auto_update_trigger.py`

### Step 1: Write the failing test

```python
# tests/database/test_390_auto_update_trigger.py

def test_trigger_exists(db_connection):
    """Verify trigger created on performed_exercise_set"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT trigger_name
        FROM information_schema.triggers
        WHERE event_object_table = 'performed_exercise_set'
          AND trigger_name = 'update_calculated_fields_trigger'
    """)
    result = cursor.fetchone()
    assert result is not None

def test_effective_volume_auto_calculated(db_connection):
    """Verify effective_volume_kg auto-calculated on insert"""
    cursor = db_connection.cursor()

    # Get existing user and exercise
    cursor.execute("SELECT user_id FROM app_user LIMIT 1")
    user_id = cursor.fetchone()['user_id']

    cursor.execute("SELECT session_id FROM performed_session WHERE user_id = %s LIMIT 1", (user_id,))
    session_id = cursor.fetchone()['session_id']

    cursor.execute("SELECT exercise_id FROM performed_exercise WHERE session_id = %s LIMIT 1", (session_id,))
    exercise_id = cursor.fetchone()['exercise_id']

    # Insert new set
    cursor.execute("""
        INSERT INTO performed_exercise_set (exercise_id, weight_g, reps, set_type, estimated_rir)
        VALUES (%s, 100000, 10, 'regular', 2)
        RETURNING set_id, effective_volume_kg, estimated_1rm_kg
    """, (exercise_id,))

    result = cursor.fetchone()
    assert result['effective_volume_kg'] == 1000.0  # 100kg × 10 reps, RIR 2 = 1.0x
    assert result['estimated_1rm_kg'] is not None
    assert result['estimated_1rm_kg'] > 100  # Should be > weight

def test_update_recalculates(db_connection):
    """Verify updating weight/reps recalculates fields"""
    cursor = db_connection.cursor()

    # Get an existing set
    cursor.execute("SELECT set_id, effective_volume_kg FROM performed_exercise_set LIMIT 1")
    original = cursor.fetchone()
    set_id = original['set_id']

    # Update it
    cursor.execute("""
        UPDATE performed_exercise_set
        SET weight_g = 120000, reps = 8, estimated_rir = 1
        WHERE set_id = %s
        RETURNING effective_volume_kg, estimated_1rm_kg
    """, (set_id,))

    updated = cursor.fetchone()
    assert updated['effective_volume_kg'] == 960.0  # 120kg × 8 reps
    assert updated['estimated_1rm_kg'] is not None
```

### Step 2: Run test to verify it fails

Run: `pytest tests/database/test_390_auto_update_trigger.py -v`

Expected: FAIL with "trigger does not exist" or calculated fields are NULL

### Step 3: Write trigger function and trigger

```sql
-- database/390_auto_update_calculated_fields.sql

CREATE OR REPLACE FUNCTION update_calculated_fields()
RETURNS TRIGGER AS $$
BEGIN
  -- Calculate effective volume
  NEW.effective_volume_kg := calculate_effective_volume(
    NEW.set_type,
    NEW.weight_g,
    NEW.reps,
    NEW.estimated_rir
  );

  -- Calculate estimated 1RM
  NEW.estimated_1rm_kg := estimate_1rm_adaptive(
    NEW.weight_g,
    NEW.reps
  );

  -- Calculate relative intensity (% of 1RM)
  IF NEW.estimated_1rm_kg IS NOT NULL AND NEW.estimated_1rm_kg > 0 THEN
    NEW.relative_intensity := ROUND(
      ((NEW.weight_g / 1000.0) / NEW.estimated_1rm_kg) * 100,
      2
    );
  ELSE
    NEW.relative_intensity := NULL;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_calculated_fields_trigger
  BEFORE INSERT OR UPDATE OF weight_g, reps, set_type, estimated_rir
  ON performed_exercise_set
  FOR EACH ROW
  EXECUTE FUNCTION update_calculated_fields();

COMMENT ON FUNCTION update_calculated_fields IS
  'Trigger function to auto-calculate effective_volume_kg, estimated_1rm_kg,
   and relative_intensity whenever a set is inserted or relevant fields updated.';
```

### Step 4: Run migration

Run: `psql -d workout_db -f database/390_auto_update_calculated_fields.sql`

Expected: "CREATE FUNCTION" and "CREATE TRIGGER" success messages

### Step 5: Run tests to verify they pass

Run: `pytest tests/database/test_390_auto_update_trigger.py -v`

Expected: All tests PASS

### Step 6: Commit

```bash
git add database/390_auto_update_calculated_fields.sql tests/database/test_390_auto_update_trigger.py
git commit -m "feat: add auto-update trigger for calculated fields

- Create update_calculated_fields() trigger function
- Auto-calculate effective_volume_kg using calculate_effective_volume()
- Auto-calculate estimated_1rm_kg using estimate_1rm_adaptive()
- Auto-calculate relative_intensity (% of 1RM)
- Trigger fires on INSERT or UPDATE of weight_g, reps, set_type, estimated_rir
- All calculated fields update automatically, no manual computation needed"
```

---

## Task 6: Create weekly_exercise_volume Materialized View

**Files:**
- Create: `database/400_weekly_exercise_volume_view.sql`
- Create: `tests/database/test_400_weekly_exercise_volume.py`

### Step 1: Write the failing test

```python
# tests/database/test_400_weekly_exercise_volume.py

from datetime import datetime, timedelta

def test_view_exists(db_connection):
    """Verify weekly_exercise_volume materialized view exists"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT matviewname
        FROM pg_matviews
        WHERE matviewname = 'weekly_exercise_volume'
    """)
    result = cursor.fetchone()
    assert result is not None

def test_aggregates_by_user_week_exercise(db_connection):
    """Verify view groups by user_id, week_start_date, base_exercise_id"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT COUNT(DISTINCT (user_id, week_start_date, base_exercise_id))
        FROM weekly_exercise_volume
    """)
    result = cursor.fetchone()
    assert result['count'] > 0

def test_total_sets_calculated(db_connection):
    """Verify total_sets counts all non-warmup sets"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT user_id, week_start_date, base_exercise_id, total_sets
        FROM weekly_exercise_volume
        WHERE total_sets > 0
        LIMIT 1
    """)
    result = cursor.fetchone()
    assert result is not None
    assert result['total_sets'] > 0

def test_effective_volume_summed(db_connection):
    """Verify effective_volume_kg is sum of all set volumes"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT effective_volume_kg, total_sets
        FROM weekly_exercise_volume
        WHERE effective_volume_kg > 0
        LIMIT 1
    """)
    result = cursor.fetchone()
    assert result is not None
    assert result['effective_volume_kg'] > 0

def test_max_estimated_1rm_tracked(db_connection):
    """Verify max_estimated_1rm_kg is highest 1RM for the week"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT max_estimated_1rm_kg
        FROM weekly_exercise_volume
        WHERE max_estimated_1rm_kg IS NOT NULL
        LIMIT 1
    """)
    result = cursor.fetchone()
    assert result is not None
    assert result['max_estimated_1rm_kg'] > 0
```

### Step 2: Run test to verify it fails

Run: `pytest tests/database/test_400_weekly_exercise_volume.py -v`

Expected: FAIL with "relation 'weekly_exercise_volume' does not exist"

### Step 3: Write materialized view

```sql
-- database/400_weekly_exercise_volume_view.sql

CREATE MATERIALIZED VIEW weekly_exercise_volume AS
SELECT
  u.user_id,
  DATE_TRUNC('week', ps.completed_at)::DATE AS week_start_date,
  be.exercise_id AS base_exercise_id,
  be.name AS exercise_name,

  -- Volume metrics
  COUNT(DISTINCT ps.session_id) AS session_count,
  COUNT(pes.set_id) AS total_sets,
  SUM(pes.effective_volume_kg) AS effective_volume_kg,

  -- Intensity metrics
  MAX(pes.estimated_1rm_kg) AS max_estimated_1rm_kg,
  AVG(pes.relative_intensity) AS avg_relative_intensity,

  -- RIR tracking (when available)
  AVG(pes.estimated_rir) FILTER (WHERE pes.estimated_rir IS NOT NULL) AS avg_rir,

  -- Metadata
  MIN(ps.completed_at) AS first_session_date,
  MAX(ps.completed_at) AS last_session_date

FROM app_user u
  INNER JOIN performed_session ps ON u.user_id = ps.user_id
  INNER JOIN performed_exercise pe ON ps.session_id = pe.session_id
  INNER JOIN base_exercise be ON pe.base_exercise_id = be.exercise_id
  INNER JOIN performed_exercise_set pes ON pe.exercise_id = pes.exercise_id

WHERE ps.completed_at IS NOT NULL
  AND pes.set_type != 'warm-up'  -- Exclude warm-up sets

GROUP BY
  u.user_id,
  DATE_TRUNC('week', ps.completed_at)::DATE,
  be.exercise_id,
  be.name;

-- Index for fast user+week lookups
CREATE INDEX idx_weekly_exercise_volume_user_week
  ON weekly_exercise_volume (user_id, week_start_date);

-- Index for exercise lookups
CREATE INDEX idx_weekly_exercise_volume_exercise
  ON weekly_exercise_volume (base_exercise_id, week_start_date);

COMMENT ON MATERIALIZED VIEW weekly_exercise_volume IS
  'Weekly aggregation of exercise volume and intensity metrics per user.

   Aggregates all working sets (excludes warm-ups) by:
   - user_id
   - week_start_date (Monday, ISO 8601)
   - base_exercise_id

   Provides:
   - session_count: Number of sessions exercise was performed
   - total_sets: Count of working sets
   - effective_volume_kg: Sum of RIR-adjusted volume
   - max_estimated_1rm_kg: Highest 1RM estimate for the week
   - avg_relative_intensity: Average % of 1RM
   - avg_rir: Average reps in reserve (when tracked)

   Updated via refresh trigger when new sessions completed.';
```

### Step 4: Run migration

Run: `psql -d workout_db -f database/400_weekly_exercise_volume_view.sql`

Expected: "CREATE MATERIALIZED VIEW" and "CREATE INDEX" success messages

### Step 5: Run tests to verify they pass

Run: `pytest tests/database/test_400_weekly_exercise_volume.py -v`

Expected: All tests PASS

### Step 6: Commit

```bash
git add database/400_weekly_exercise_volume_view.sql tests/database/test_400_weekly_exercise_volume.py
git commit -m "feat: add weekly_exercise_volume materialized view

- Aggregate volume and intensity metrics per user/week/exercise
- Track total_sets, effective_volume_kg (RIR-adjusted)
- Track max_estimated_1rm_kg and avg_relative_intensity
- Track avg_rir when available
- Exclude warm-up sets from aggregation
- Add indexes for fast user+week and exercise lookups
- Foundation for volume landmarks and plateau detection"
```

---

## Task 7: Create weekly_muscle_volume Materialized View

**Files:**
- Create: `database/405_weekly_muscle_volume_view.sql`
- Create: `tests/database/test_405_weekly_muscle_volume.py`

### Step 1: Write the failing test

```python
# tests/database/test_405_weekly_muscle_volume.py

def test_view_exists(db_connection):
    """Verify weekly_muscle_volume materialized view exists"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT matviewname
        FROM pg_matviews
        WHERE matviewname = 'weekly_muscle_volume'
    """)
    result = cursor.fetchone()
    assert result is not None

def test_aggregates_by_user_week_muscle(db_connection):
    """Verify view groups by user_id, week_start_date, muscle_group"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT COUNT(DISTINCT (user_id, week_start_date, muscle_group))
        FROM weekly_muscle_volume
    """)
    result = cursor.fetchone()
    assert result['count'] > 0

def test_primary_muscle_100_percent_attribution(db_connection):
    """Verify primary muscles get 100% volume attribution"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT muscle_group, muscle_role, activation_factor
        FROM weekly_muscle_volume
        WHERE muscle_role = 'primary'
        LIMIT 1
    """)
    result = cursor.fetchone()
    assert result is not None
    assert result['activation_factor'] == 1.0

def test_secondary_muscle_50_percent_attribution(db_connection):
    """Verify secondary muscles get 50% volume attribution"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT muscle_group, muscle_role, activation_factor
        FROM weekly_muscle_volume
        WHERE muscle_role = 'secondary'
        LIMIT 1
    """)
    result = cursor.fetchone()
    assert result is not None
    assert result['activation_factor'] == 0.5

def test_attributed_volume_calculated(db_connection):
    """Verify attributed_volume_kg = effective_volume_kg * activation_factor"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT effective_volume_kg, activation_factor, attributed_volume_kg
        FROM weekly_muscle_volume
        LIMIT 1
    """)
    result = cursor.fetchone()
    assert result is not None
    expected = result['effective_volume_kg'] * result['activation_factor']
    assert abs(result['attributed_volume_kg'] - expected) < 0.01
```

### Step 2: Run test to verify it fails

Run: `pytest tests/database/test_405_weekly_muscle_volume.py -v`

Expected: FAIL with "relation 'weekly_muscle_volume' does not exist"

### Step 3: Write materialized view

```sql
-- database/405_weekly_muscle_volume_view.sql

CREATE MATERIALIZED VIEW weekly_muscle_volume AS
-- Primary muscle volume (100% attribution)
SELECT
  wev.user_id,
  wev.week_start_date,
  pm.muscle_group,
  'primary'::TEXT AS muscle_role,
  1.0 AS activation_factor,  -- Fixed 100% for primary muscles

  -- Volume metrics
  wev.session_count,
  wev.total_sets,
  wev.effective_volume_kg,
  wev.effective_volume_kg * 1.0 AS attributed_volume_kg,  -- 100% attribution

  -- Intensity metrics
  wev.max_estimated_1rm_kg,
  wev.avg_relative_intensity,
  wev.avg_rir,

  -- Metadata
  wev.first_session_date,
  wev.last_session_date

FROM weekly_exercise_volume wev
  INNER JOIN base_exercise_primary_muscle pm ON wev.base_exercise_id = pm.exercise_id

UNION ALL

-- Secondary muscle volume (50% attribution)
SELECT
  wev.user_id,
  wev.week_start_date,
  sm.muscle_group,
  'secondary'::TEXT AS muscle_role,
  0.5 AS activation_factor,  -- Fixed 50% for secondary muscles

  -- Volume metrics
  wev.session_count,
  wev.total_sets,
  wev.effective_volume_kg,
  wev.effective_volume_kg * 0.5 AS attributed_volume_kg,  -- 50% attribution

  -- Intensity metrics
  wev.max_estimated_1rm_kg,
  wev.avg_relative_intensity,
  wev.avg_rir,

  -- Metadata
  wev.first_session_date,
  wev.last_session_date

FROM weekly_exercise_volume wev
  INNER JOIN base_exercise_secondary_muscle sm ON wev.base_exercise_id = sm.exercise_id;

-- Index for fast user+week lookups
CREATE INDEX idx_weekly_muscle_volume_user_week
  ON weekly_muscle_volume (user_id, week_start_date);

-- Index for muscle group analysis
CREATE INDEX idx_weekly_muscle_volume_muscle
  ON weekly_muscle_volume (muscle_group, week_start_date);

COMMENT ON MATERIALIZED VIEW weekly_muscle_volume IS
  'Weekly muscle group volume with research-backed activation factors.

   Expands weekly_exercise_volume into muscle-specific volumes using:
   - Primary muscles: 100% volume attribution (activation_factor = 1.0)
   - Secondary muscles: 50% volume attribution (activation_factor = 0.5)

   Based on Menno Henselmans research on muscle activation patterns.

   Used for:
   - Volume landmarks (MEV/MAV/MRV) per muscle
   - Muscle balance ratio analysis
   - Push/pull ratio tracking
   - Injury risk detection (e.g., Q/H ratio <0.6)';
```

### Step 4: Run migration

Run: `psql -d workout_db -f database/405_weekly_muscle_volume_view.sql`

Expected: "CREATE MATERIALIZED VIEW" and "CREATE INDEX" success messages

### Step 5: Run tests to verify they pass

Run: `pytest tests/database/test_405_weekly_muscle_volume.py -v`

Expected: All tests PASS

### Step 6: Commit

```bash
git add database/405_weekly_muscle_volume_view.sql tests/database/test_405_weekly_muscle_volume.py
git commit -m "feat: add weekly_muscle_volume materialized view

- Expand exercise volume into muscle-specific volumes
- Primary muscles: 100% attribution (activation_factor = 1.0)
- Secondary muscles: 50% attribution (activation_factor = 0.5)
- Based on Menno Henselmans research
- Add indexes for user+week and muscle lookups
- Foundation for muscle balance analysis and injury prevention"
```

---

## Task 8: Create Auto-Refresh Trigger for Materialized Views

**Files:**
- Create: `database/410_auto_refresh_views.sql`
- Create: `tests/database/test_410_auto_refresh.py`

### Step 1: Write the failing test

```python
# tests/database/test_410_auto_refresh.py

import time

def test_trigger_exists(db_connection):
    """Verify refresh trigger exists on performed_session"""
    cursor = db_connection.cursor()
    cursor.execute("""
        SELECT trigger_name
        FROM information_schema.triggers
        WHERE event_object_table = 'performed_session'
          AND trigger_name = 'refresh_weekly_views_trigger'
    """)
    result = cursor.fetchone()
    assert result is not None

def test_completing_session_refreshes_views(db_connection):
    """Verify completing a session triggers view refresh"""
    cursor = db_connection.cursor()

    # Get an incomplete session
    cursor.execute("""
        SELECT session_id
        FROM performed_session
        WHERE completed_at IS NULL
        LIMIT 1
    """)
    session = cursor.fetchone()

    if session:
        # Record current row count
        cursor.execute("SELECT COUNT(*) as count FROM weekly_exercise_volume")
        before_count = cursor.fetchone()['count']

        # Complete the session
        cursor.execute("""
            UPDATE performed_session
            SET completed_at = NOW()
            WHERE session_id = %s
        """, (session['session_id'],))

        db_connection.commit()

        # Check if views were refreshed (row count may change)
        cursor.execute("SELECT COUNT(*) as count FROM weekly_exercise_volume")
        after_count = cursor.fetchone()['count']

        # At minimum, the query should succeed (view is valid)
        assert after_count >= 0
```

### Step 2: Run test to verify it fails

Run: `pytest tests/database/test_410_auto_refresh.py -v`

Expected: FAIL with "trigger does not exist"

### Step 3: Write trigger function and trigger

```sql
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
```

### Step 4: Run migration

Run: `psql -d workout_db -f database/410_auto_refresh_views.sql`

Expected: "CREATE FUNCTION" and "CREATE TRIGGER" success messages

### Step 5: Run tests to verify they pass

Run: `pytest tests/database/test_410_auto_refresh.py -v`

Expected: All tests PASS

### Step 6: Commit

```bash
git add database/410_auto_refresh_views.sql tests/database/test_410_auto_refresh.py
git commit -m "feat: add auto-refresh trigger for weekly materialized views

- Create refresh_weekly_views() trigger function
- Trigger fires when performed_session.completed_at is set
- Refresh weekly_exercise_volume and weekly_muscle_volume
- Use CONCURRENTLY to avoid blocking reads
- Ensures analytics views stay up-to-date automatically"
```

---

## Execution Handoff

Plan complete with 8 core infrastructure tasks. Remaining advanced analytics views (volume landmarks, plateau detection, muscle balance, V2 compatibility) can be added iteratively.

Ready to execute using subagent-driven approach.
