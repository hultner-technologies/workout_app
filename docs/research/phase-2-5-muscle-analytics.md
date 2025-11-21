# Phase 2.5: Muscle-Specific Analytics Research

**Date:** 2025-11-21
**Research Duration:** 45 minutes
**Purpose:** Design muscle group analytics using rich exercise metadata
**Status:** Research Complete

---

## Executive Summary

This document provides evidence-based formulas, ratios, and algorithms for leveraging our rich exercise metadata (muscle groups, mechanic, force, equipment) to deliver advanced muscle-specific analytics. Key findings include:

- **Volume Attribution**: Primary muscles = 100%, secondary muscles = 30-50% (simplified approach)
- **Push/Pull Ratio**: 1:1 for upper body (some recommend 1:2), 1:2-3 for lower body
- **Muscle Balance**: Hamstrings should be 60-100% as strong as quads
- **Exercise Variety**: 2-4 exercises per muscle group optimal, 4-12 per week ideal
- **Volume Ranges**: 10-25 sets per muscle per week (MEV-MRV framework)

---

## 1. Volume Per Muscle Group

### 1.1 Primary vs Secondary Muscle Attribution

**Challenge:** How to count volume when exercises work multiple muscle groups?

#### Method 1: Simplified Fractional Approach (RECOMMENDED)

**Formula:**
```
Primary muscle volume = 1.0 × (weight × reps)
Secondary muscle volume = 0.5 × (weight × reps)
```

**Rationale:**
- Simple to implement and understand
- Widely used by practitioners
- Example: Bench press counts as 1 set for chest, 0.5 sets for triceps/shoulders
- Conservative approach prevents double-counting volume

**Sources:**
- Menno Henselmans: "Count sets where target muscle is prime mover"
- Common practice in evidence-based training programs

#### Method 2: Stimulus-Weighted Approach (ADVANCED)

**Formula:**
```
Muscle volume = activation_percentage × (weight × reps)

Where activation_percentage is assigned per exercise-muscle pair:
- Primary muscles: 80-100% (based on exercise specificity)
- Secondary muscles: 30-50% (based on EMG research)
- Tertiary involvement: 0% (below 40% threshold, negligible for growth)
```

**Research Support:**
- EMG studies show ~2× greater pectoralis activation vs triceps in bench press
- Minimum effective tension: ~40-60% of maximum voluntary isometric contraction
- Muscles below 40% stimulus can be rounded to 0%

**Implementation Note:**
```sql
-- Store activation percentages in junction table
ALTER TABLE base_exercise_primary_muscle
    ADD COLUMN activation_percentage decimal DEFAULT 1.0;

ALTER TABLE base_exercise_secondary_muscle
    ADD COLUMN activation_percentage decimal DEFAULT 0.5;
```

### 1.2 Volume Landmarks (Renaissance Periodization)

**Framework by Dr. Mike Israetel:**

| Landmark | Definition | Typical Range |
|----------|------------|---------------|
| **MV** (Maintenance Volume) | Minimum to preserve muscle | ~6 sets/week |
| **MEV** (Minimum Effective Volume) | Lowest amount that grows muscle | Varies by muscle |
| **MAV** (Maximum Adaptive Volume) | Optimal growth zone (not fixed) | 10-25 sets/week |
| **MRV** (Maximum Recoverable Volume) | Most you can recover from | Varies by muscle |

**Muscle-Specific Volume Ranges (sets per week):**

| Muscle Group | MEV | Typical Range | Notes |
|--------------|-----|---------------|-------|
| Chest | 6-8 | 6-16 sets | 4-6 minimum for growth |
| Back | 8-10 | 10-20 sets | High work capacity |
| Shoulders | 8-10 | 8-16 sets | Consider push/pull balance |
| Biceps | 8 | 8-20 sets | 6-10 for beginners |
| Triceps | 6-8 | 8-20 sets | Gets work from pressing |
| Quadriceps | 8-10 | 8-20 sets | High volume tolerance |
| Hamstrings | 6-8 | 6-16 sets | Often undertrained |
| Glutes | 6-8 | 6-16 sets | Priority for many |
| Calves | 8-10 | 8-16 sets | Stubborn muscle group |
| Abs | 0-6 | 0-20 sets | Gets work from compounds |

**Key Insight:** Ideal range is 10-25 working sets per muscle per week at minimum RPE 6-7.

### 1.3 Progressive Volume Algorithm

**Mesocycle Approach:**
```
Week 1: Start at MEV + 2 sets
Week 2: Add 1-2 sets per muscle
Week 3: Add 1-2 sets per muscle
Week 4: Add 1-2 sets per muscle
Week 5: Monitor for MRV indicators
Deload: Reduce volume by 50-70%
Next Mesocycle: Start 1-2 sets higher than previous MEV
```

**MRV Detection:**
- Rep strength drops below baseline
- Recovery time increases
- Sleep quality decreases
- Persistent soreness

---

## 2. Training Split Analysis

### 2.1 Push/Pull/Legs Split

**Optimal Frequency:** 2× per week per muscle group (6-day split)

**Volume Distribution Principles:**
- Each muscle group trained twice weekly = superior hypertrophy vs once weekly
- 48-72 hours recovery between training same muscle
- Volume distributed to prevent single workout from being too long

**2025 Research Insights:**
- Train within 1-2 reps of failure for optimal hypertrophy
- Change exercise selection every 4-6 weeks for novel stimulus
- Hybrid 5-day split scored highest (9.0) in hypertrophy effectiveness
- PPL 6-day allows maximum volume due to training frequency

**Muscle Group Assignments:**

```
PUSH:
- Chest (primary)
- Shoulders (primary)
- Triceps (primary)
- Upper chest (emphasis)

PULL:
- Back: lats, middle back, lower back (primary)
- Rear delts (primary)
- Biceps (primary)
- Traps (primary)
- Forearms (accessory)

LEGS:
- Quadriceps (primary)
- Hamstrings (primary)
- Glutes (primary)
- Calves (primary)
- Abs/Core (accessory)
```

### 2.2 Upper/Lower Split

**Frequency:** 4-day split (each muscle 2× per week)

**Volume Distribution:**
```
UPPER:
- Push muscles: chest, shoulders, triceps
- Pull muscles: back, biceps
- Ratio: 3 horizontal (1 push + 2 pull) + 2 vertical (1 push + 1 pull)

LOWER:
- Quad dominant: 1 exercise
- Hip dominant: 1-2 exercises
- Accessory: calves, abs
```

### 2.3 Full Body Split

**Frequency:** 3-day split

**Characteristics:**
- 1-2 exercises per major muscle group per session
- Lower volume per session, higher frequency
- Good for beginners and strength focus
- Less suitable for high-volume hypertrophy

---

## 3. Balance & Weak Points

### 3.1 Push/Pull Ratio Targets

#### Upper Body (Chest:Back)

**Recommendations:**

| Source | Ratio | Reasoning |
|--------|-------|-----------|
| **Conservative** | 1:2 (push:pull) | Prevent rounded shoulders, shoulder impingement |
| **Balanced** | 1:1 | Equal development |
| **Common Scheme** | 6-movement: 2 push + 2 pull | 1 horizontal push + 1 vertical push + 1 horizontal pull + 1 vertical pull |

**Research Evidence:**
- Overtraining chest while neglecting back → rounded shoulder posture
- Subacromial impingement syndrome risk
- Most experts recommend equal or pull-dominant approach

**Implementation:**
```sql
-- Calculate push/pull ratio for upper body
WITH upper_body_volume AS (
    SELECT
        app_user_id,
        date_trunc('week', date) as week,
        SUM(CASE WHEN force = 'push'
            AND muscle IN ('chest', 'shoulders', 'triceps')
            THEN volume_kg ELSE 0 END) as push_volume,
        SUM(CASE WHEN force = 'pull'
            AND muscle IN ('lats', 'middle back', 'biceps', 'traps')
            THEN volume_kg ELSE 0 END) as pull_volume
    FROM muscle_volume_stats
    GROUP BY app_user_id, week
)
SELECT
    *,
    push_volume / NULLIF(pull_volume, 0) as push_pull_ratio,
    CASE
        WHEN push_volume / NULLIF(pull_volume, 0) > 1.2 THEN 'Push-dominant (consider more pull work)'
        WHEN push_volume / NULLIF(pull_volume, 0) < 0.8 THEN 'Pull-dominant (consider more push work)'
        ELSE 'Balanced'
    END as balance_assessment
FROM upper_body_volume;
```

**Healthy Range:** 0.8 - 1.2 (80-120% ratio)

#### Lower Body (Quad:Hamstring)

**Recommendations:**

| Source | Ratio | Notes |
|--------|-------|-------|
| **Injury Prevention** | 2:1 to 3:1 (posterior:quad) | Emphasize hamstrings, glutes, lower back |
| **Strength Testing** | 0.6-0.8 (ham:quad) | H/Q ratio of 60-80% acceptable |
| **Optimal** | 1:1 (ham:quad) | 100% ratio reduces hamstring strain risk |

**Research Evidence:**
- Conventional H/Q ratio normative value: 0.6 (hamstrings 60% as strong as quads)
- Desirable: >60%, optimal: approaching 100%
- Lower body training often emphasizes posterior chain (hamstrings, glutes) 2-3× more than quads

### 3.2 Muscle Imbalance Thresholds

**Definitions:**

| Imbalance Type | Detection Method | Threshold | Action |
|----------------|------------------|-----------|--------|
| **Bilateral** | Left vs Right strength | >15% difference | Unilateral training priority |
| **Antagonist** | Push vs Pull volume | >20% difference | Increase lagging side |
| **Regional** | Quad vs Hamstring | <60% H/Q ratio | Prioritize hamstrings |
| **Aesthetic** | Visual proportion | Subjective | Priority principle |

**Time to Correct:**
- Minor imbalances: 8-12 weeks
- Pronounced problems: 6-12 months
- Requires consistent progressive effort

### 3.3 Weak Point Detection Algorithm

**Step 1: Volume Analysis**
```sql
-- Identify undertrained muscles (below MEV)
WITH muscle_weekly_volume AS (
    SELECT
        app_user_id,
        muscle_group,
        date_trunc('week', date) as week,
        SUM(working_sets) as weekly_sets
    FROM muscle_volume_stats
    WHERE exercise_set_type != 'warm-up'
    GROUP BY app_user_id, muscle_group, week
),
mev_thresholds AS (
    VALUES
        ('chest', 6), ('back', 8), ('shoulders', 8),
        ('biceps', 8), ('triceps', 6), ('quadriceps', 8),
        ('hamstrings', 6), ('glutes', 6), ('calves', 8)
)
SELECT
    v.app_user_id,
    v.muscle_group,
    AVG(v.weekly_sets) as avg_weekly_sets,
    m.mev,
    CASE
        WHEN AVG(v.weekly_sets) < m.mev THEN 'Below MEV - Weak Point'
        WHEN AVG(v.weekly_sets) < m.mev * 1.5 THEN 'Low Volume - Monitor'
        ELSE 'Adequate Volume'
    END as status
FROM muscle_weekly_volume v
JOIN mev_thresholds m ON v.muscle_group = m.muscle
GROUP BY v.app_user_id, v.muscle_group, m.mev
HAVING AVG(v.weekly_sets) < m.mev * 1.5;
```

**Step 2: Progress Stagnation**
```sql
-- Detect muscles with no progress over 4+ weeks
WITH muscle_progression AS (
    SELECT
        app_user_id,
        muscle_group,
        date_trunc('week', date) as week,
        SUM(volume_kg) as weekly_volume,
        LAG(SUM(volume_kg), 4) OVER (
            PARTITION BY app_user_id, muscle_group
            ORDER BY date_trunc('week', date)
        ) as volume_4weeks_ago
    FROM muscle_volume_stats
    GROUP BY app_user_id, muscle_group, week
)
SELECT
    app_user_id,
    muscle_group,
    weekly_volume,
    volume_4weeks_ago,
    (weekly_volume - volume_4weeks_ago) / NULLIF(volume_4weeks_ago, 0) * 100 as pct_change,
    CASE
        WHEN ABS((weekly_volume - volume_4weeks_ago) / NULLIF(volume_4weeks_ago, 0)) < 0.05
        THEN 'Stagnant - Potential Plateau'
        ELSE 'Progressing'
    END as progress_status
FROM muscle_progression
WHERE volume_4weeks_ago IS NOT NULL;
```

**Step 3: Balance Ratio Analysis**
```sql
-- Detect muscle imbalances (push/pull, quad/ham)
WITH muscle_ratios AS (
    SELECT
        app_user_id,
        date_trunc('week', date) as week,
        SUM(CASE WHEN muscle_group = 'chest' THEN volume_kg ELSE 0 END) as chest_volume,
        SUM(CASE WHEN muscle_group IN ('lats', 'middle back') THEN volume_kg ELSE 0 END) as back_volume,
        SUM(CASE WHEN muscle_group = 'quadriceps' THEN volume_kg ELSE 0 END) as quad_volume,
        SUM(CASE WHEN muscle_group = 'hamstrings' THEN volume_kg ELSE 0 END) as ham_volume
    FROM muscle_volume_stats
    GROUP BY app_user_id, week
)
SELECT
    app_user_id,
    chest_volume / NULLIF(back_volume, 0) as chest_back_ratio,
    ham_volume / NULLIF(quad_volume, 0) as ham_quad_ratio,
    CASE
        WHEN chest_volume / NULLIF(back_volume, 0) > 1.3 THEN 'Chest overdeveloped'
        WHEN chest_volume / NULLIF(back_volume, 0) < 0.7 THEN 'Back overdeveloped'
        ELSE 'Upper body balanced'
    END as upper_balance,
    CASE
        WHEN ham_volume / NULLIF(quad_volume, 0) < 0.6 THEN 'Hamstrings weak - injury risk'
        WHEN ham_volume / NULLIF(quad_volume, 0) < 0.8 THEN 'Hamstrings underdeveloped'
        ELSE 'Lower body balanced'
    END as lower_balance
FROM muscle_ratios;
```

**Step 4: Consolidated Weak Point Report**
```sql
-- Generate comprehensive weak point analysis
CREATE OR REPLACE VIEW weak_point_analysis AS
WITH current_volume AS (
    -- Last 4 weeks average
    SELECT
        app_user_id,
        muscle_group,
        AVG(weekly_sets) as avg_sets,
        AVG(volume_kg) as avg_volume
    FROM muscle_weekly_volume
    WHERE week >= CURRENT_DATE - INTERVAL '4 weeks'
    GROUP BY app_user_id, muscle_group
),
volume_assessment AS (
    SELECT
        cv.*,
        CASE
            WHEN cv.muscle_group = 'chest' AND cv.avg_sets < 6 THEN 'Low'
            WHEN cv.muscle_group = 'back' AND cv.avg_sets < 8 THEN 'Low'
            WHEN cv.muscle_group = 'shoulders' AND cv.avg_sets < 8 THEN 'Low'
            WHEN cv.muscle_group = 'biceps' AND cv.avg_sets < 8 THEN 'Low'
            WHEN cv.muscle_group = 'triceps' AND cv.avg_sets < 6 THEN 'Low'
            WHEN cv.muscle_group = 'quadriceps' AND cv.avg_sets < 8 THEN 'Low'
            WHEN cv.muscle_group = 'hamstrings' AND cv.avg_sets < 6 THEN 'Low'
            WHEN cv.muscle_group = 'glutes' AND cv.avg_sets < 6 THEN 'Low'
            WHEN cv.muscle_group = 'calves' AND cv.avg_sets < 8 THEN 'Low'
            ELSE 'Adequate'
        END as volume_status
    FROM current_volume cv
)
SELECT
    app_user_id,
    muscle_group,
    avg_sets,
    avg_volume,
    volume_status,
    -- Add recommendations
    CASE
        WHEN volume_status = 'Low' THEN 'Increase volume by 2-4 sets per week'
        ELSE 'Maintain current volume'
    END as recommendation
FROM volume_assessment
WHERE volume_status = 'Low'
ORDER BY app_user_id, avg_sets ASC;
```

### 3.4 Training Strategies for Weak Points

**Priority Principle:**
1. Train weak muscles first in workout (when fresh)
2. Research: muscles trained early respond better
3. Mental and physical energy highest at start

**Unilateral Training:**
1. Perform weak side first
2. Match strong side to weak side reps (don't exceed)
3. Continue until equalized

**Volume Adjustment:**
1. Increase weak muscle volume by 20-50%
2. Maintain strong muscle at maintenance volume (MV)
3. Monitor for overcorrection

**Technique Emphasis:**
1. 10-12 reps with challenging weight
2. Slow negatives (3-4 seconds) for time under tension
3. RPE 8-9 (close to failure)

---

## 4. Exercise Selection Insights

### 4.1 Compound vs Isolation Ratio

**General Consensus:** No specific numerical ratio, but clear hierarchy

**Program Structure:**

```
Priority Order:
1. Compound exercises FIRST (when energy is high)
2. Isolation exercises SECOND (accessory work)
3. Weak point exercises LAST (if needed)
```

**Experience-Based Guidelines:**

| Experience Level | Compound Focus | Isolation Focus | Notes |
|------------------|----------------|-----------------|-------|
| **Beginner** | 80-90% | 10-20% | Build foundation with compounds |
| **Intermediate** | 70-80% | 20-30% | Add isolation for weak points |
| **Advanced** | 60-70% | 30-40% | More isolation for detail work |

**Research Finding:**
- Multi-joint (MJ) exercises more efficient for strength and VO2max than single-joint (SJ)
- No differences in body composition when total work volume equated
- Compound exercises train entire body evenly (80% of imbalance prevention)

**Implementation:**
```sql
-- Calculate compound vs isolation ratio
WITH exercise_classification AS (
    SELECT
        app_user_id,
        date_trunc('week', date) as week,
        COUNT(*) FILTER (WHERE mechanic = 'compound') as compound_exercises,
        COUNT(*) FILTER (WHERE mechanic = 'isolation') as isolation_exercises,
        SUM(working_sets) FILTER (WHERE mechanic = 'compound') as compound_sets,
        SUM(working_sets) FILTER (WHERE mechanic = 'isolation') as isolation_sets
    FROM exercise_performance_with_metadata
    WHERE exercise_set_type != 'warm-up'
    GROUP BY app_user_id, week
)
SELECT
    *,
    compound_sets::decimal / NULLIF(isolation_sets, 0) as compound_isolation_ratio,
    CASE
        WHEN compound_sets::decimal / NULLIF(isolation_sets, 0) < 2.0 THEN 'Too much isolation'
        WHEN compound_sets::decimal / NULLIF(isolation_sets, 0) > 9.0 THEN 'Add more isolation'
        ELSE 'Good balance'
    END as assessment
FROM exercise_classification;
```

**Healthy Range:** 2:1 to 9:1 (compound:isolation) depending on experience level

### 4.2 Exercise Variety Recommendations

**General Guidelines:**

| Metric | Recommendation | Research Support |
|--------|----------------|------------------|
| **Per Session** | 2-4 exercises per muscle group | Optimal for variety without excessive fatigue |
| **Per Week** | 4-12 exercises per muscle group | Study: varied group had better overall muscle growth |
| **Minimum for Growth** | 3 exercises per muscle per week | Baseline for hypertrophy focus |

**Research Evidence:**
- Study compared 1 exercise 3× per week vs different exercise each workout
- Same total volume and intensity
- After 9 weeks: varied group had better overall muscle growth
- Variety matters: different angles and force vectors

**Experience-Based:**

| Experience Level | Exercises Per Muscle | Notes |
|------------------|----------------------|-------|
| **Beginner** | 2-3 different exercises | Great results with basics |
| **Intermediate** | 3-4 exercises | Add variety for continued progress |
| **Advanced** | 4-5 exercises | More variety for detail work |

**Implementation:**
```sql
-- Track exercise variety per muscle group
WITH exercise_variety AS (
    SELECT
        app_user_id,
        date_trunc('week', date) as week,
        muscle_group,
        COUNT(DISTINCT base_exercise_id) as unique_exercises,
        COUNT(DISTINCT CASE WHEN mechanic = 'compound' THEN base_exercise_id END) as unique_compounds,
        COUNT(DISTINCT CASE WHEN mechanic = 'isolation' THEN base_exercise_id END) as unique_isolations
    FROM exercise_performance_with_muscles
    WHERE muscle_is_primary = true  -- Only count primary muscles
    GROUP BY app_user_id, week, muscle_group
)
SELECT
    *,
    CASE
        WHEN unique_exercises < 2 THEN 'Low variety - add more exercises'
        WHEN unique_exercises > 6 THEN 'High variety - may be excessive'
        ELSE 'Good variety'
    END as variety_assessment,
    CASE
        WHEN unique_compounds = 0 THEN 'Missing compound movements'
        ELSE 'Has compound base'
    END as compound_check
FROM exercise_variety;
```

**Optimal Variety per Muscle per Week:** 3-5 unique exercises

### 4.3 Equipment Utilization Patterns

**Balanced Program Should Include:**

```
Free Weights (Barbell/Dumbbell): 50-70%
- Build stabilizer strength
- More functional
- Greater ROM potential

Machines/Cable: 20-30%
- Isolation focus
- Fatigue management
- Injury rehabilitation

Bodyweight: 10-20%
- Always accessible
- Skill development
- Core integration
```

**Implementation:**
```sql
-- Analyze equipment utilization
WITH equipment_usage AS (
    SELECT
        app_user_id,
        date_trunc('month', date) as month,
        equipment_type,
        COUNT(*) as exercise_count,
        SUM(working_sets) as total_sets,
        SUM(volume_kg) as total_volume
    FROM exercise_performance_with_metadata
    WHERE exercise_set_type != 'warm-up'
    GROUP BY app_user_id, month, equipment_type
),
equipment_percentages AS (
    SELECT
        *,
        total_sets::decimal / SUM(total_sets) OVER (PARTITION BY app_user_id, month) * 100 as pct_of_sets
    FROM equipment_usage
)
SELECT
    app_user_id,
    month,
    equipment_type,
    total_sets,
    ROUND(pct_of_sets, 1) as pct_of_sets,
    CASE equipment_type
        WHEN 'body only' THEN
            CASE WHEN pct_of_sets > 30 THEN 'Too much bodyweight - add resistance'
                 WHEN pct_of_sets < 5 THEN 'Add bodyweight exercises'
                 ELSE 'Good' END
        WHEN 'barbell' THEN
            CASE WHEN pct_of_sets < 20 THEN 'Add more barbell work'
                 ELSE 'Good' END
        WHEN 'machine' THEN
            CASE WHEN pct_of_sets > 40 THEN 'Too machine-dependent'
                 ELSE 'Good' END
        ELSE 'Good'
    END as recommendation
FROM equipment_percentages
ORDER BY app_user_id, month, pct_of_sets DESC;
```

### 4.4 Movement Pattern Distribution

**Balanced Program Should Include:**

```
HORIZONTAL PUSH: 15-20% (bench press, push-ups)
VERTICAL PUSH: 15-20% (overhead press, dips)
HORIZONTAL PULL: 15-20% (rows, face pulls)
VERTICAL PULL: 15-20% (pull-ups, lat pulldowns)
KNEE DOMINANT: 10-15% (squats, leg press)
HIP DOMINANT: 10-15% (deadlifts, hip thrusts)
CARRY/CORE: 5-10% (planks, carries)
```

**Common 6-Movement Scheme:**
1. Horizontal push (bench press)
2. Horizontal pull (row)
3. Vertical push (overhead press)
4. Vertical pull (pull-up)
5. Knee dominant (squat)
6. Hip dominant (deadlift)

---

## 5. SQL Queries for Muscle-Specific Analytics

### 5.1 Foundation View: Muscle Volume Stats

```sql
-- Base view: Exercise performance with muscle attribution
CREATE OR REPLACE VIEW exercise_performance_with_muscles AS
WITH exercise_set_volume AS (
    SELECT
        pes.performed_exercise_set_id,
        pes.performed_exercise_id,
        pe.app_user_id,
        pe.base_exercise_id,
        pes.weight_grams / 1000.0 as weight_kg,
        pes.reps,
        pes.exercise_set_type,
        pes.completed_at,
        (pes.weight_grams / 1000.0) * pes.reps as set_volume_kg,
        CASE WHEN pes.exercise_set_type != 'warm-up' THEN 1 ELSE 0 END as is_working_set
    FROM performed_exercise_set pes
    JOIN performed_exercise pe ON pes.performed_exercise_id = pe.performed_exercise_id
    WHERE pes.completed_at IS NOT NULL
),
exercise_metadata AS (
    SELECT
        be.base_exercise_id,
        be.name as exercise_name,
        be.level,
        be.mechanic,
        be.force,
        et.name as equipment_type
    FROM base_exercise be
    LEFT JOIN equipment_type et ON be.equipment_type_id = et.equipment_type_id
)
SELECT
    esv.*,
    em.exercise_name,
    em.level,
    em.mechanic,
    em.force,
    em.equipment_type,

    -- Primary muscles
    mg_primary.name as muscle_group,
    mg_primary.display_name as muscle_display_name,
    true as muscle_is_primary,
    COALESCE(bepm.activation_percentage, 1.0) as activation_percentage,
    esv.set_volume_kg * COALESCE(bepm.activation_percentage, 1.0) as attributed_volume_kg

FROM exercise_set_volume esv
JOIN exercise_metadata em ON esv.base_exercise_id = em.base_exercise_id
JOIN base_exercise_primary_muscle bepm ON esv.base_exercise_id = bepm.base_exercise_id
JOIN muscle_group mg_primary ON bepm.muscle_group_id = mg_primary.muscle_group_id

UNION ALL

SELECT
    esv.*,
    em.exercise_name,
    em.level,
    em.mechanic,
    em.force,
    em.equipment_type,

    -- Secondary muscles
    mg_secondary.name as muscle_group,
    mg_secondary.display_name as muscle_display_name,
    false as muscle_is_primary,
    COALESCE(besm.activation_percentage, 0.5) as activation_percentage,
    esv.set_volume_kg * COALESCE(besm.activation_percentage, 0.5) as attributed_volume_kg

FROM exercise_set_volume esv
JOIN exercise_metadata em ON esv.base_exercise_id = em.base_exercise_id
JOIN base_exercise_secondary_muscle besm ON esv.base_exercise_id = besm.base_exercise_id
JOIN muscle_group mg_secondary ON besm.muscle_group_id = mg_secondary.muscle_group_id;

COMMENT ON VIEW exercise_performance_with_muscles IS
    'Exercise performance data with muscle attribution (primary and secondary).
     Each set appears multiple times - once per muscle involved.
     Use attributed_volume_kg for muscle-specific volume calculations.';
```

### 5.2 Aggregated Muscle Volume

```sql
-- Muscle volume aggregated by week
CREATE OR REPLACE VIEW muscle_volume_weekly AS
SELECT
    app_user_id,
    muscle_group,
    muscle_display_name,
    date_trunc('week', completed_at) as week,

    -- Working sets only (exclude warm-ups)
    COUNT(*) FILTER (WHERE is_working_set = 1) as working_sets,
    SUM(attributed_volume_kg) FILTER (WHERE is_working_set = 1) as working_volume_kg,

    -- All sets (for comparison)
    COUNT(*) as total_sets,
    SUM(attributed_volume_kg) as total_volume_kg,

    -- Primary vs secondary
    COUNT(*) FILTER (WHERE muscle_is_primary) as primary_sets,
    SUM(attributed_volume_kg) FILTER (WHERE muscle_is_primary) as primary_volume_kg,
    COUNT(*) FILTER (WHERE NOT muscle_is_primary) as secondary_sets,
    SUM(attributed_volume_kg) FILTER (WHERE NOT muscle_is_primary) as secondary_volume_kg,

    -- Exercise variety
    COUNT(DISTINCT base_exercise_id) as unique_exercises,
    COUNT(DISTINCT base_exercise_id) FILTER (WHERE mechanic = 'compound') as unique_compounds,
    COUNT(DISTINCT base_exercise_id) FILTER (WHERE mechanic = 'isolation') as unique_isolations,

    -- Average intensity
    AVG(weight_kg) as avg_weight_kg,
    AVG(reps) as avg_reps

FROM exercise_performance_with_muscles
GROUP BY app_user_id, muscle_group, muscle_display_name, date_trunc('week', completed_at);

COMMENT ON VIEW muscle_volume_weekly IS
    'Weekly aggregated volume per muscle group with working sets, variety metrics, and intensity.';
```

### 5.3 Push/Pull Balance Analysis

```sql
-- Push/Pull balance tracker
CREATE OR REPLACE VIEW push_pull_balance AS
WITH weekly_force_volume AS (
    SELECT
        app_user_id,
        date_trunc('week', completed_at) as week,
        force,

        -- Upper body only (filter by muscle group)
        SUM(attributed_volume_kg) FILTER (
            WHERE muscle_group IN ('chest', 'shoulders', 'triceps', 'lats', 'middle back', 'biceps', 'traps')
            AND is_working_set = 1
        ) as upper_body_volume_kg,

        COUNT(*) FILTER (
            WHERE muscle_group IN ('chest', 'shoulders', 'triceps', 'lats', 'middle back', 'biceps', 'traps')
            AND is_working_set = 1
        ) as upper_body_sets,

        -- Lower body
        SUM(attributed_volume_kg) FILTER (
            WHERE muscle_group IN ('quadriceps', 'hamstrings', 'glutes', 'calves')
            AND is_working_set = 1
        ) as lower_body_volume_kg,

        COUNT(*) FILTER (
            WHERE muscle_group IN ('quadriceps', 'hamstrings', 'glutes', 'calves')
            AND is_working_set = 1
        ) as lower_body_sets

    FROM exercise_performance_with_muscles
    WHERE force IS NOT NULL
    GROUP BY app_user_id, week, force
)
SELECT
    app_user_id,
    week,

    -- Upper body
    MAX(upper_body_volume_kg) FILTER (WHERE force = 'push') as upper_push_volume,
    MAX(upper_body_volume_kg) FILTER (WHERE force = 'pull') as upper_pull_volume,
    MAX(upper_body_sets) FILTER (WHERE force = 'push') as upper_push_sets,
    MAX(upper_body_sets) FILTER (WHERE force = 'pull') as upper_pull_sets,

    -- Ratios
    MAX(upper_body_volume_kg) FILTER (WHERE force = 'push') /
        NULLIF(MAX(upper_body_volume_kg) FILTER (WHERE force = 'pull'), 0) as upper_push_pull_ratio,

    -- Assessment
    CASE
        WHEN MAX(upper_body_volume_kg) FILTER (WHERE force = 'push') /
             NULLIF(MAX(upper_body_volume_kg) FILTER (WHERE force = 'pull'), 0) > 1.2
        THEN 'Push-dominant: Add more pull work'
        WHEN MAX(upper_body_volume_kg) FILTER (WHERE force = 'push') /
             NULLIF(MAX(upper_body_volume_kg) FILTER (WHERE force = 'pull'), 0) < 0.8
        THEN 'Pull-dominant: Add more push work'
        ELSE 'Balanced'
    END as upper_balance_status,

    -- Lower body
    MAX(lower_body_volume_kg) FILTER (WHERE force = 'push') as lower_push_volume,
    MAX(lower_body_volume_kg) FILTER (WHERE force = 'pull') as lower_pull_volume,
    MAX(lower_body_sets) FILTER (WHERE force = 'push') as lower_push_sets,
    MAX(lower_body_sets) FILTER (WHERE force = 'pull') as lower_pull_sets,

    MAX(lower_body_volume_kg) FILTER (WHERE force = 'pull') /
        NULLIF(MAX(lower_body_volume_kg) FILTER (WHERE force = 'push'), 0) as lower_pull_push_ratio,

    CASE
        WHEN MAX(lower_body_volume_kg) FILTER (WHERE force = 'pull') /
             NULLIF(MAX(lower_body_volume_kg) FILTER (WHERE force = 'push'), 0) < 1.5
        THEN 'Insufficient posterior chain work'
        WHEN MAX(lower_body_volume_kg) FILTER (WHERE force = 'pull') /
             NULLIF(MAX(lower_body_volume_kg) FILTER (WHERE force = 'push'), 0) > 3.5
        THEN 'Excessive posterior emphasis'
        ELSE 'Good posterior chain focus'
    END as lower_balance_status

FROM weekly_force_volume
GROUP BY app_user_id, week;

COMMENT ON VIEW push_pull_balance IS
    'Analyzes push/pull balance for upper and lower body with recommendations.
     Upper target: 0.8-1.2 ratio (balanced to pull-dominant)
     Lower target: 1.5-3.0 pull:push ratio (posterior chain emphasis)';
```

### 5.4 Muscle Imbalance Detection

```sql
-- Quad:Hamstring and Chest:Back balance
CREATE OR REPLACE VIEW muscle_balance_ratios AS
WITH muscle_volume AS (
    SELECT
        app_user_id,
        date_trunc('week', completed_at) as week,
        muscle_group,
        SUM(attributed_volume_kg) FILTER (WHERE is_working_set = 1) as working_volume_kg,
        COUNT(*) FILTER (WHERE is_working_set = 1) as working_sets
    FROM exercise_performance_with_muscles
    WHERE muscle_is_primary = true  -- Only primary muscles for balance assessment
    GROUP BY app_user_id, week, muscle_group
)
SELECT
    app_user_id,
    week,

    -- Upper body: Chest vs Back
    MAX(working_volume_kg) FILTER (WHERE muscle_group = 'chest') as chest_volume,
    MAX(working_volume_kg) FILTER (WHERE muscle_group IN ('lats', 'middle back')) as back_volume,
    MAX(working_sets) FILTER (WHERE muscle_group = 'chest') as chest_sets,
    MAX(working_sets) FILTER (WHERE muscle_group IN ('lats', 'middle back')) as back_sets,

    MAX(working_volume_kg) FILTER (WHERE muscle_group = 'chest') /
        NULLIF(MAX(working_volume_kg) FILTER (WHERE muscle_group IN ('lats', 'middle back')), 0)
        as chest_back_ratio,

    CASE
        WHEN MAX(working_volume_kg) FILTER (WHERE muscle_group = 'chest') /
             NULLIF(MAX(working_volume_kg) FILTER (WHERE muscle_group IN ('lats', 'middle back')), 0) > 1.3
        THEN 'Chest overdeveloped - increase back work'
        WHEN MAX(working_volume_kg) FILTER (WHERE muscle_group = 'chest') /
             NULLIF(MAX(working_volume_kg) FILTER (WHERE muscle_group IN ('lats', 'middle back')), 0) < 0.7
        THEN 'Back overdeveloped - increase chest work'
        ELSE 'Upper body balanced'
    END as upper_balance,

    -- Lower body: Quad vs Hamstring
    MAX(working_volume_kg) FILTER (WHERE muscle_group = 'quadriceps') as quad_volume,
    MAX(working_volume_kg) FILTER (WHERE muscle_group = 'hamstrings') as hamstring_volume,
    MAX(working_sets) FILTER (WHERE muscle_group = 'quadriceps') as quad_sets,
    MAX(working_sets) FILTER (WHERE muscle_group = 'hamstrings') as hamstring_sets,

    MAX(working_volume_kg) FILTER (WHERE muscle_group = 'hamstrings') /
        NULLIF(MAX(working_volume_kg) FILTER (WHERE muscle_group = 'quadriceps'), 0)
        as hamstring_quad_ratio,

    CASE
        WHEN MAX(working_volume_kg) FILTER (WHERE muscle_group = 'hamstrings') /
             NULLIF(MAX(working_volume_kg) FILTER (WHERE muscle_group = 'quadriceps'), 0) < 0.6
        THEN 'Critical: Hamstrings weak - injury risk'
        WHEN MAX(working_volume_kg) FILTER (WHERE muscle_group = 'hamstrings') /
             NULLIF(MAX(working_volume_kg) FILTER (WHERE muscle_group = 'quadriceps'), 0) < 0.8
        THEN 'Warning: Hamstrings underdeveloped'
        WHEN MAX(working_volume_kg) FILTER (WHERE muscle_group = 'hamstrings') /
             NULLIF(MAX(working_volume_kg) FILTER (WHERE muscle_group = 'quadriceps'), 0) > 1.2
        THEN 'Good: Strong posterior chain'
        ELSE 'Lower body balanced'
    END as lower_balance

FROM muscle_volume
GROUP BY app_user_id, week;

COMMENT ON VIEW muscle_balance_ratios IS
    'Tracks critical muscle balance ratios to prevent injury and imbalances.
     Chest:Back target: 0.7-1.3
     Hamstring:Quad target: >0.6 (acceptable), >0.8 (good), approaching 1.0 (optimal)';
```

### 5.5 Exercise Selection Quality

```sql
-- Compound vs Isolation and Exercise Variety
CREATE OR REPLACE VIEW exercise_selection_quality AS
WITH weekly_stats AS (
    SELECT
        app_user_id,
        date_trunc('week', completed_at) as week,
        muscle_group,

        -- Sets by mechanic
        COUNT(*) FILTER (WHERE mechanic = 'compound' AND is_working_set = 1) as compound_sets,
        COUNT(*) FILTER (WHERE mechanic = 'isolation' AND is_working_set = 1) as isolation_sets,

        -- Exercise variety
        COUNT(DISTINCT base_exercise_id) as unique_exercises,
        COUNT(DISTINCT base_exercise_id) FILTER (WHERE mechanic = 'compound') as unique_compounds,
        COUNT(DISTINCT base_exercise_id) FILTER (WHERE mechanic = 'isolation') as unique_isolations,

        -- Equipment diversity
        COUNT(DISTINCT equipment_type) as equipment_types_used

    FROM exercise_performance_with_muscles
    WHERE muscle_is_primary = true
    GROUP BY app_user_id, week, muscle_group
)
SELECT
    app_user_id,
    week,
    muscle_group,
    compound_sets,
    isolation_sets,
    compound_sets::decimal / NULLIF(isolation_sets, 0) as compound_isolation_ratio,
    unique_exercises,
    unique_compounds,
    unique_isolations,
    equipment_types_used,

    -- Compound/Isolation assessment
    CASE
        WHEN compound_sets = 0 THEN 'Critical: Missing compound exercises'
        WHEN compound_sets::decimal / NULLIF(isolation_sets, 0) < 1.5
        THEN 'Warning: Too much isolation work'
        WHEN isolation_sets = 0 AND unique_exercises < 3
        THEN 'Tip: Add isolation for weak point development'
        ELSE 'Good compound/isolation balance'
    END as balance_assessment,

    -- Variety assessment
    CASE
        WHEN unique_exercises < 2 THEN 'Low variety - add 1-2 more exercises'
        WHEN unique_exercises > 6 THEN 'High variety - may be excessive'
        WHEN unique_exercises BETWEEN 3 AND 5 THEN 'Optimal variety'
        ELSE 'Good variety'
    END as variety_assessment,

    -- Equipment diversity
    CASE
        WHEN equipment_types_used = 1 THEN 'Limited equipment - consider adding variety'
        WHEN equipment_types_used >= 3 THEN 'Good equipment diversity'
        ELSE 'Adequate equipment variety'
    END as equipment_assessment

FROM weekly_stats;

COMMENT ON VIEW exercise_selection_quality IS
    'Evaluates exercise selection quality: compound/isolation balance, variety, equipment diversity.
     Target compound:isolation ratio: 1.5-9.0
     Target unique exercises: 3-5 per muscle per week
     Target equipment types: 2-3 different types';
```

### 5.6 Comprehensive Muscle Analytics Dashboard

```sql
-- Complete muscle analytics summary
CREATE OR REPLACE VIEW muscle_analytics_dashboard AS
WITH latest_4weeks AS (
    SELECT app_user_id, muscle_group, muscle_display_name,
           AVG(working_sets) as avg_weekly_sets,
           AVG(working_volume_kg) as avg_weekly_volume,
           AVG(unique_exercises) as avg_unique_exercises
    FROM muscle_volume_weekly
    WHERE week >= CURRENT_DATE - INTERVAL '4 weeks'
    GROUP BY app_user_id, muscle_group, muscle_display_name
),
mev_reference AS (
    SELECT * FROM (VALUES
        ('chest', 6, 16), ('lats', 8, 20), ('middle back', 8, 20),
        ('shoulders', 8, 16), ('biceps', 8, 20), ('triceps', 6, 20),
        ('quadriceps', 8, 20), ('hamstrings', 6, 16), ('glutes', 6, 16),
        ('calves', 8, 16), ('abdominals', 0, 20)
    ) AS t(muscle_group, mev, typical_max)
),
muscle_status AS (
    SELECT
        l.*,
        m.mev,
        m.typical_max,
        CASE
            WHEN l.avg_weekly_sets < m.mev THEN 'Below MEV - Not growing'
            WHEN l.avg_weekly_sets < m.mev * 1.5 THEN 'Low volume - Weak point candidate'
            WHEN l.avg_weekly_sets > m.typical_max THEN 'Very high volume - Risk of overtraining'
            ELSE 'Adequate volume'
        END as volume_status,
        CASE
            WHEN l.avg_unique_exercises < 2 THEN 'Low variety'
            WHEN l.avg_unique_exercises > 6 THEN 'High variety'
            ELSE 'Good variety'
        END as variety_status
    FROM latest_4weeks l
    LEFT JOIN mev_reference m ON l.muscle_group = m.muscle_group
)
SELECT
    ms.*,

    -- Recommendations
    CASE
        WHEN ms.volume_status = 'Below MEV - Not growing'
        THEN 'Increase volume by ' || (ms.mev - ms.avg_weekly_sets + 2)::int || ' sets per week'
        WHEN ms.volume_status = 'Low volume - Weak point candidate'
        THEN 'Add 2-4 sets per week to promote growth'
        WHEN ms.volume_status = 'Very high volume - Risk of overtraining'
        THEN 'Reduce volume by ' || (ms.avg_weekly_sets - ms.typical_max)::int || ' sets or deload'
        ELSE 'Maintain current volume'
    END as volume_recommendation,

    CASE
        WHEN ms.variety_status = 'Low variety'
        THEN 'Add 1-2 more exercises for this muscle'
        WHEN ms.variety_status = 'High variety'
        THEN 'Focus on 3-5 key exercises for consistency'
        ELSE 'Exercise variety is optimal'
    END as variety_recommendation

FROM muscle_status ms
ORDER BY
    CASE ms.volume_status
        WHEN 'Below MEV - Not growing' THEN 1
        WHEN 'Low volume - Weak point candidate' THEN 2
        WHEN 'Very high volume - Risk of overtraining' THEN 3
        ELSE 4
    END,
    ms.muscle_group;

COMMENT ON VIEW muscle_analytics_dashboard IS
    'Comprehensive muscle-by-muscle analytics dashboard with volume status, variety, and actionable recommendations.
     Use this as the primary view for muscle-specific insights.';
```

---

## 6. Implementation Formulas Summary

### 6.1 Volume Attribution

```
Primary muscle: volume_kg × 1.0
Secondary muscle: volume_kg × 0.5

Or with custom activation percentages:
Muscle volume = exercise_volume × activation_percentage
```

### 6.2 Balance Ratios

```
Upper Body:
- Push:Pull ratio = 0.8 to 1.2 (balanced to pull-dominant)
- Chest:Back ratio = 0.7 to 1.3

Lower Body:
- Hamstring:Quad ratio = >0.6 (minimum), >0.8 (good), →1.0 (optimal)
- Posterior:Anterior ratio = 1.5 to 3.0
```

### 6.3 Volume Landmarks

```
Per muscle per week:
- MV (Maintenance): ~6 sets
- MEV (Minimum Effective): 6-10 sets (muscle-specific)
- MAV (Maximum Adaptive): 10-25 sets (progression zone)
- MRV (Maximum Recoverable): Varies, watch for performance drop
```

### 6.4 Exercise Selection

```
Compound:Isolation ratio: 2:1 to 9:1 (depends on experience)
Exercise variety: 3-5 unique exercises per muscle per week
Equipment diversity: 2-3 different types per muscle
```

### 6.5 Weak Point Detection

```
Weak point if:
1. Volume < MEV for 2+ weeks
2. Progress stagnation: <5% change over 4 weeks
3. Balance ratio outside healthy range
4. Hamstring:Quad < 0.6 (injury risk)
```

---

## 7. Implementation Recommendations

### 7.1 Phase 1: Foundation (V2 Views)

**Add to existing views:**
```sql
-- In exercise_stats_v2, add:
working_volume_kg  -- Exclude warm-ups
muscle_group       -- From junction tables
force              -- push/pull/static
mechanic           -- compound/isolation
```

### 7.2 Phase 2: Muscle Analytics (V3)

**New views to create:**
1. `exercise_performance_with_muscles` - Base view with muscle attribution
2. `muscle_volume_weekly` - Aggregated muscle volume by week
3. `push_pull_balance` - Push/pull ratio tracking
4. `muscle_balance_ratios` - Chest:back, quad:hamstring
5. `exercise_selection_quality` - Compound/isolation, variety
6. `muscle_analytics_dashboard` - Complete summary with recommendations

### 7.3 Phase 3: AI/MCP Integration

**Context for AI queries:**
- "Why am I plateauing on chest?"
  → Check volume status, balance ratios, exercise variety
- "What are my weak points?"
  → Query muscle_analytics_dashboard for below-MEV muscles
- "Is my push/pull balanced?"
  → Query push_pull_balance view
- "Design a program for my weak hamstrings"
  → Increase hamstring volume by 50%, prioritize in workout

### 7.4 Frontend Visualization

**Dashboards:**
1. **Muscle Volume Heatmap**: Color-coded by MEV/MAV/MRV status
2. **Balance Radar Chart**: Push vs pull, upper vs lower
3. **Progress Timeline**: Volume trends per muscle over time
4. **Weak Point Alert**: Flagged muscles with recommendations
5. **Exercise Variety Matrix**: Compound/isolation, equipment types

---

## 8. Key Ratios Quick Reference

| Metric | Target | Threshold |
|--------|--------|-----------|
| **Push:Pull (Upper)** | 0.8-1.2 | Outside = imbalance |
| **Pull:Push (Lower)** | 1.5-3.0 | <1.5 = insufficient posterior |
| **Hamstring:Quad** | >0.6 | <0.6 = injury risk |
| **Hamstring:Quad (Optimal)** | →1.0 | Approaching 100% ideal |
| **Chest:Back** | 0.7-1.3 | Outside = imbalance |
| **Compound:Isolation** | 2:1 to 9:1 | <2 = too much isolation |
| **Exercise Variety** | 3-5/week | <2 = low, >6 = high |
| **Weekly Sets** | 10-25 | <MEV = not growing, >MRV = overtraining |

---

## 9. Research Sources

### Exercise Science & Training Volume
- Renaissance Periodization (Mike Israetel): Volume landmarks, MEV/MRV framework
- Menno Henselmans: Volume counting methodology, compound vs isolation
- PMC/NCBI: EMG studies, muscle activation research
- Frontiers in Sports: Volume quantification in competitive athletes

### Training Splits & Balance
- Built with Science: 2025 training split analysis
- Gravitus, StrengthLog, ATHLEAN-X: PPL programming
- Bret Contreras: Push/pull ratios
- Sports Performance Bulletin: Hamstring/quad ratios

### Exercise Selection
- PMC: Multi-joint vs single-joint exercise effectiveness
- Men's Health, Fitbod, StrengthLog: Exercise variety research
- Various sources: Compound vs isolation hierarchies

### Weak Point Training
- Legion Athletics, EliteFTS, Mirafit: Muscle imbalance detection
- Bodybuilding.com: Weak point training techniques
- Hevy Coach: Muscular imbalance definitions

---

## Document Location

**File:** `/home/user/workout_app/docs/research/phase-2-5-muscle-analytics.md`

**Related Documents:**
- `/home/user/workout_app/docs/research/phase-2-research-plan.md`
- `/home/user/workout_app/docs/plans/2025-11-21-sets-migration-analytics-design.md`
- `/home/user/workout_app/docs/research/2025-11-21-quick-research-findings.md`

---

**Research Complete:** 2025-11-21
**Next Steps:** Implement V3 muscle analytics views and integrate with MCP for AI-powered insights
