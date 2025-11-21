# Phase 2-7: AI/MCP Integration Research

**Date:** 2025-11-21
**Research Duration:** 45 minutes
**Status:** Complete
**Related Epic:** `.github/EPIC_mcp_integration.md`

## Executive Summary

This research explores AI/MCP (Model Context Protocol) integration patterns for conversational workout analytics. The goal is to enable users to ask natural language questions like "Why am I plateauing?" or "Design a program for my weak points" and receive data-driven, personalized coaching insights.

**Key Finding:** MCP should serve as a **data & tool provider**, not an AI coach itself. The consuming LLM (Claude, GPT-4, etc.) provides coaching intelligence, while the MCP server exposes workout data and executable actions through standardized primitives.

**Recommended Architecture:** Three-layer approach with Resources (read-only data), Tools (executable actions), and Prompts (conversation templates), combined with intelligent caching and privacy-first data filtering.

---

## 1. MCP Architecture Recommendations

### 1.1 Core MCP Primitives for Workout Data

Based on MCP specification 2025-03-26 and best practices research, workout data should be exposed through three standardized primitives:

#### **Resources** (Read-Only Context)
Resources are passive, side-effect-free data access points that provide context for LLM reasoning.

**Recommended Resources:**

```python
@mcp.resource("workout://exercises/catalog")
async def get_exercise_catalog():
    """
    Complete exercise database with rich metadata.
    Returns: Array of exercises with muscles, equipment, force type, etc.
    Format: JSON array optimized for LLM consumption
    """

@mcp.resource("workout://performance/history/{exercise_name}")
async def get_exercise_history(exercise_name: str, days: int = 90):
    """
    Historical performance data for specific exercise.
    Returns: Time series of sets, reps, weight, volume, 1RM estimates
    Format: Structured JSON with temporal metadata
    """

@mcp.resource("workout://analytics/volume/{muscle_group}")
async def get_muscle_volume(muscle_group: str, weeks: int = 4):
    """
    Volume analytics for specific muscle group.
    Returns: Weekly volume, primary vs secondary activation, trends
    Format: Aggregated time series with volume landmarks context
    """

@mcp.resource("workout://session/recent")
async def get_recent_sessions(weeks: int = 4):
    """
    Recent workout sessions with exercise details.
    Returns: Session timestamps, exercises performed, volume, notes
    Format: Chronologically ordered with rich context
    """

@mcp.resource("workout://analytics/plateau-indicators")
async def get_plateau_indicators():
    """
    Pre-computed plateau detection signals.
    Returns: Stagnation metrics, progression rates, trend analysis
    Format: Statistical summary with confidence scores
    """
```

**Design Rationale:**
- **Granular access**: Each resource serves specific query pattern
- **LLM-optimized format**: Structured JSON with contextual metadata
- **Temporal awareness**: Default time windows balance recency vs history
- **Pre-aggregation**: Complex calculations done server-side to reduce LLM processing

#### **Tools** (Executable Actions)
Tools have side effects or perform complex computations that return structured data.

**Recommended Tools:**

```python
@mcp.tool()
async def analyze_progress(
    exercise_name: str,
    time_period_days: int = 30,
    include_volume_landmarks: bool = True
) -> dict:
    """
    Comprehensive progression analysis for an exercise.

    Returns:
    - volume_trend: "increasing" | "plateauing" | "decreasing"
    - one_rm_progression_rate: float (kg/week)
    - training_frequency: float (sessions/week)
    - plateau_score: float (0-100, higher = more likely plateauing)
    - recommendations: list[str] (deload, increase volume, etc.)
    - volume_landmark_status: dict (MEV/MAV/MRV comparison if applicable)
    """

@mcp.tool()
async def detect_weak_points() -> dict:
    """
    Identify under-trained muscle groups using volume analytics.

    Algorithm:
    1. Calculate weekly volume per muscle group (primary + secondary)
    2. Compare to user's average volume across all muscles
    3. Flag muscles below 70% of average volume
    4. Consider push/pull/legs balance

    Returns:
    - weak_muscles: list[dict] (muscle, weekly_volume, deficit_percentage)
    - push_pull_ratio: float (should be ~1.0 for balance)
    - recommendations: list[str] (exercises to add)
    """

@mcp.tool()
async def suggest_next_weight(
    exercise_name: str,
    target_reps: int = 10,
    target_rpe: float | None = None  # Rate of Perceived Exertion (1-10)
) -> dict:
    """
    Suggest weight for next workout based on progression rules.

    Algorithm:
    1. Get last 3 sessions of this exercise
    2. Calculate average 1RM using Brzycki formula
    3. Apply exercise.step_increment (e.g., 2.5kg for bench press)
    4. Check against exercise.progression_limit (max increase per session)
    5. Adjust for target reps using %1RM tables

    Returns:
    - suggested_weight_grams: int
    - suggested_weight_display: str (e.g., "60kg" or "132.5lbs")
    - rationale: str (explanation of calculation)
    - confidence: float (0-1, based on data recency and consistency)
    """

@mcp.tool()
async def check_recovery_needs() -> dict:
    """
    Analyze if user needs deload week based on training intensity.

    Algorithm:
    1. Calculate last 4 weeks volume per muscle group
    2. Check for sustained high volume (approaching MRV)
    3. Detect consecutive high-intensity sessions (>85% 1RM)
    4. Check session frequency (>5 sessions/week for 4+ weeks)

    Returns:
    - needs_deload: bool
    - deload_confidence: float (0-1)
    - indicators: list[str] (reasons: volume, intensity, frequency)
    - suggested_deload_approach: str ("reduce volume 40-50%" | "active recovery" | etc)
    """

@mcp.tool()
async def design_program(
    goals: list[str],  # ["hypertrophy", "strength", "weak_point_focus"]
    sessions_per_week: int,
    weak_muscles: list[str] | None = None,
    equipment_available: list[str] | None = None,
    duration_weeks: int = 8
) -> dict:
    """
    Generate personalized workout plan (WRITE operation).

    Algorithm:
    1. Select exercises targeting specified goals and weak points
    2. Balance push/pull/legs distribution
    3. Apply volume landmarks (MEV to MAV range)
    4. Set progressive overload schedule
    5. Create user_plan record in database

    Returns:
    - user_plan_id: uuid
    - plan_name: str
    - sessions: list[dict] (session name, exercises, sets/reps)
    - rationale: str (why these exercises were chosen)
    - expected_outcomes: list[str]
    """
```

**Design Rationale:**
- **Clear boundaries**: Each tool has single responsibility
- **Rich returns**: Includes data + reasoning + confidence scores
- **Evidence-based**: Algorithms based on exercise science (volume landmarks, %1RM)
- **Actionable**: Tools provide recommendations, not just raw data

#### **Prompts** (Conversation Templates)
Prompts standardize common conversational scenarios and bundle context.

**Recommended Prompts:**

```python
@mcp.prompt()
async def analyze_plateau(exercise_name: str):
    """Template for plateau analysis conversation."""
    return {
        "messages": [{
            "role": "user",
            "content": f"I feel like I'm plateauing on {exercise_name}. Why might this be happening?"
        }],
        "context": {
            "exercise_history": await get_exercise_history(exercise_name, days=90),
            "recent_sessions": await get_recent_sessions(weeks=6),
            "volume_trend": await analyze_progress(exercise_name, time_period_days=60)
        },
        "instructions": """
        Analyze the provided workout data and identify potential causes for plateau:
        1. Check if volume has stagnated or decreased
        2. Look for inadequate progressive overload
        3. Check training frequency (too high or too low)
        4. Consider recovery needs (high volume over extended period)
        5. Provide specific, actionable recommendations
        """
    }

@mcp.prompt()
async def design_weak_point_program():
    """Template for weak point program design."""
    return {
        "messages": [{
            "role": "user",
            "content": "Design a program to bring up my weak points"
        }],
        "context": {
            "weak_points": await detect_weak_points(),
            "recent_volume": await get_muscle_volume_all(weeks=4),
            "exercise_catalog": await get_exercise_catalog()
        },
        "instructions": """
        Design a periodized program addressing identified weak points:
        1. Prioritize under-trained muscle groups
        2. Balance with existing training (avoid overtraining)
        3. Suggest exercise selection from catalog
        4. Apply volume landmarks (start at MEV, progress to MAV)
        5. Include progression scheme over 8-12 weeks
        """
    }

@mcp.prompt()
async def suggest_deload():
    """Template for deload recommendation."""
    return {
        "messages": [{
            "role": "user",
            "content": "Should I take a deload week?"
        }],
        "context": {
            "recovery_analysis": await check_recovery_needs(),
            "recent_sessions": await get_recent_sessions(weeks=4),
            "plateau_indicators": await get_plateau_indicators()
        },
        "instructions": """
        Evaluate need for deload based on:
        1. Training volume over last 4 weeks
        2. Session frequency and intensity
        3. Signs of stagnation or regression
        4. If deload recommended, suggest specific approach (volume reduction, intensity reduction, or active recovery)
        """
    }
```

**Design Rationale:**
- **Contextual bundling**: Prompts pre-fetch relevant data
- **Guided reasoning**: Instructions help LLM provide consistent, evidence-based answers
- **Conversation starters**: Make common questions one-click accessible

---

### 1.2 Data Format for LLM Consumption

Research shows **structured formats optimize LLM context windows**. Key findings:

**Format Choice: YAML > JSON for Analytics**
- **YAML is 66% more token-efficient than JSON** (2025 research)
- More readable for LLMs, clearer delineation of data types
- Use for complex nested structures (exercise history, program design)

**JSON for Simple Resources**
- Use JSON for simple key-value resources (exercise catalog, single session)
- Faster parsing, wider compatibility

**Metadata Enrichment**
Every data structure should include contextual metadata:

```yaml
exercise_history:
  exercise: "Bench Press"
  period: "2025-08-21 to 2025-11-21 (90 days)"
  user_context:
    training_age: "3 years"
    current_goal: "hypertrophy"
  data:
    - date: "2025-11-21"
      sets: 4
      avg_reps: 9.5
      avg_weight_kg: 80
      total_volume_kg: 3040
      estimated_1rm_kg: 106.4
      relative_intensity: "75% 1RM"
    # ... more sessions
  aggregates:
    avg_weekly_volume_kg: 10120
    volume_trend: "increasing +8% over last 4 weeks"
    avg_1rm_progression_kg_per_week: 0.8
    training_frequency_per_week: 2.3
  volume_landmarks:  # Context for LLM
    current_weekly_sets: 12
    mev_sets: 10
    mav_sets: 16
    mrv_sets: 22
    status: "Within optimal range (MEV to MAV)"
```

**Benefits:**
- **Self-documenting**: LLM understands units, time windows, context
- **Aggregates included**: Reduce LLM computation
- **Evidence-based context**: Volume landmarks, %1RM provide scientific framing

---

### 1.3 Real-Time vs Historical Data Balance

**Research Finding:** Conversational AI demands speed - **MCP servers must respond within 2 seconds** (p95 latency) for acceptable UX.

**Recommended Strategy:**

#### **Tier 1: Real-Time Resources** (< 500ms)
- Recent sessions (last 7 days)
- Current active plan
- Latest performance metrics per exercise

**Implementation:**
- Direct PostgreSQL queries via native driver (Fly.io hosting)
- Indexed queries on `performed_session.completed_at`, `performed_exercise.completed_at`
- Pre-aggregated views: `exercise_stats_v3` (computed on write)

#### **Tier 2: Short History** (< 1s)
- Last 90 days of exercise history
- 4-week volume trends
- Progression analysis

**Implementation:**
- Aggregation queries with time window filters
- Leverage `performed_exercise_set` table with indexes
- Use materialized views refreshed hourly for expensive aggregations

#### **Tier 3: Long History / Complex Analytics** (< 2s)
- Full training history (years)
- Advanced plateau detection
- Cross-exercise comparisons
- Weak point analysis (all muscle groups)

**Implementation:**
- Pre-computed analytics stored in `app_user.data` JSONB field
- Background jobs update analytics daily
- Cached at MCP server layer (see caching section)

**Pagination for Large Datasets:**
```python
@mcp.resource("workout://performance/history/{exercise_name}")
async def get_exercise_history(
    exercise_name: str,
    days: int = 90,
    offset: int = 0,
    limit: int = 100
):
    """
    Paginated history to prevent overwhelming LLM context.
    Default: last 90 days, max 100 sessions per call.
    For older data, use offset parameter.
    """
```

---

## 2. Conversational Use Cases - Implementation Patterns

This section details how the MCP server should respond to specific conversational queries, with data structures and reasoning patterns.

### 2.1 "Why am I plateauing on bench press?"

**MCP Server Response Pattern:**

1. **Fetch Recent History** (90 days):
   - Call `get_exercise_history("Bench Press", days=90)`
   - Returns time series: dates, volume, 1RM estimates, frequency

2. **Run Plateau Detection**:
   - Call `analyze_progress("Bench Press", time_period_days=60)`
   - Detects: volume stagnation, 1RM stall, frequency changes

3. **Check Recovery Indicators**:
   - Call `check_recovery_needs()`
   - Checks: total volume across all muscle groups, session frequency

4. **Return Structured Context to LLM**:
```yaml
plateau_analysis:
  exercise: "Bench Press"
  time_period: "Last 60 days"

  findings:
    volume_trend: "stagnant"  # No increase in last 4 weeks
    volume_change_percentage: "+2%"  # Minimal change
    one_rm_trend: "plateauing"
    one_rm_progression_kg_per_week: 0.1  # Below minimum effective (0.5kg/week)
    training_frequency_per_week: 2.0  # Reasonable

  potential_causes:
    - id: "insufficient_progressive_overload"
      description: "1RM progression is 0.1kg/week, below minimum effective (0.5kg/week)"
      confidence: 0.9
    - id: "volume_stagnation"
      description: "Weekly volume unchanged for 4 weeks"
      confidence: 0.85
    - id: "possible_overtraining"
      description: "Total weekly volume across all exercises is 280 sets (approaching MRV)"
      confidence: 0.4

  recommendations:
    - "Increase weight by one step increment (2.5kg) and reduce reps to maintain form"
    - "Add one additional set per session (increase volume by ~25%)"
    - "Consider deload week if fatigue is high (reduce volume by 50% for one week)"
    - "Vary rep ranges: try 3x5 heavy + 2x12 light in same week"
```

**LLM's Role:**
- Translate technical metrics into conversational explanation
- Prioritize recommendations based on user's training history
- Ask clarifying questions ("Are you feeling fatigued?")
- Provide scientific context (progressive overload principles)

**Expected Conversation:**
> **User:** "Why am I plateauing on bench press?"
>
> **Claude (via MCP):** "Looking at your last 60 days of bench press training, I can see a couple of factors:
>
> Your 1RM has only increased by 0.5kg over the past month, which is below the typical progression rate of 0.5-1kg per week for an intermediate lifter. Additionally, your weekly volume has stayed constant at around 3,040kg for 4 weeks straight.
>
> The good news is you're training consistently (2x per week), and you're not showing signs of overtraining.
>
> **Here's what I recommend:**
> 1. Add 2.5kg to your working weight next session and aim for 8-10 reps
> 2. If that feels too heavy, add one extra set instead to increase volume by about 25%
> 3. Consider a deload week after 2-3 more weeks of increased intensity
>
> Does this align with how you've been feeling during your bench sessions?"

---

### 2.2 "Design a program for my weak points"

**MCP Server Response Pattern:**

1. **Detect Weak Points**:
   - Call `detect_weak_points()`
   - Algorithm:
     ```sql
     -- Calculate volume per muscle group over last 4 weeks
     WITH muscle_volume AS (
       SELECT
         mg.name as muscle_group,
         SUM(pes.weight * pes.reps) / 1000.0 as total_volume_kg,
         COUNT(DISTINCT ps.performed_session_id) as sessions
       FROM performed_exercise_set pes
       JOIN performed_exercise pe ON pes.performed_exercise_id = pe.performed_exercise_id
       JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
       JOIN exercise e ON pe.exercise_id = e.exercise_id
       JOIN base_exercise be ON e.base_exercise_id = be.base_exercise_id
       JOIN base_exercise_primary_muscle bepm ON be.base_exercise_id = bepm.base_exercise_id
       JOIN muscle_group mg ON bepm.muscle_group_id = mg.muscle_group_id
       WHERE ps.completed_at >= NOW() - INTERVAL '4 weeks'
         AND pes.exercise_set_type != 'warm-up'
         AND ps.app_user_id = auth.uid()
       GROUP BY mg.name
     )
     SELECT
       muscle_group,
       total_volume_kg,
       total_volume_kg / (SELECT AVG(total_volume_kg) FROM muscle_volume) as volume_ratio
     FROM muscle_volume
     WHERE volume_ratio < 0.7  -- Flag muscles below 70% of average
     ORDER BY volume_ratio ASC;
     ```

2. **Get Current Volume Distribution**:
   - Call `get_muscle_volume_all(weeks=4)`
   - Returns: volume per muscle, push/pull/legs breakdown

3. **Fetch Exercise Recommendations**:
   - Query exercise catalog filtered by weak muscles
   - Prioritize: compound movements, available equipment, user's level

4. **Return Program Design Context**:
```yaml
weak_point_analysis:
  period: "Last 4 weeks"

  under_trained_muscles:
    - muscle: "hamstrings"
      weekly_volume_kg: 1200
      avg_weekly_volume_kg: 3500  # User's avg across all muscles
      deficit_percentage: -66%
      priority: "high"

    - muscle: "rear_delts"
      weekly_volume_kg: 1800
      avg_weekly_volume_kg: 3500
      deficit_percentage: -49%
      priority: "high"

    - muscle: "biceps"
      weekly_volume_kg: 2300
      avg_weekly_volume_kg: 3500
      deficit_percentage: -34%
      priority: "medium"

  push_pull_ratio: 1.4  # Imbalanced (should be ~1.0)
  push_weekly_sets: 28
  pull_weekly_sets: 20  # Underdeveloped

  recommended_exercises:
    hamstrings:
      - name: "Romanian Deadlift"
        type: "compound"
        equipment: "barbell"
        primary_muscles: ["hamstrings", "glutes"]
        suggested_volume: "3 sets x 8-12 reps, 2x per week"
      - name: "Lying Leg Curl"
        type: "isolation"
        equipment: "machine"
        primary_muscles: ["hamstrings"]
        suggested_volume: "3 sets x 10-15 reps, 2x per week"

    rear_delts:
      - name: "Face Pull"
        type: "isolation"
        equipment: "cable"
        primary_muscles: ["rear_delts"]
        suggested_volume: "4 sets x 15-20 reps, 2x per week"
      - name: "Reverse Fly"
        type: "isolation"
        equipment: "dumbbells"
        primary_muscles: ["rear_delts"]
        suggested_volume: "3 sets x 12-15 reps, 2x per week"

  program_recommendations:
    duration_weeks: 8
    phases:
      - phase: "Weeks 1-4: MEV to MAV (Volume Accumulation)"
        hamstrings_sets_per_week: 12  # Start at MEV (10), progress to 12
        rear_delts_sets_per_week: 16
        progression: "Add 1 set per week OR increase weight by 2.5kg"

      - phase: "Weeks 5-7: MAV (Peak Volume)"
        hamstrings_sets_per_week: 16
        rear_delts_sets_per_week: 20
        progression: "Maintain volume, focus on weight progression"

      - phase: "Week 8: Deload"
        volume_reduction: "50% of Week 7 volume"
        intensity_maintenance: "Keep weights, reduce sets"
```

**LLM's Role:**
- Create conversational program explanation
- Ask about equipment availability
- Suggest specific split (e.g., "Add hamstrings to your pull day")
- Explain why these exercises were chosen
- Offer to create the plan in database via `design_program()` tool

**Expected Conversation:**
> **User:** "Design a program for my weak points"
>
> **Claude (via MCP):** "I've analyzed your last 4 weeks of training, and I've identified some imbalances:
>
> **Primary Weak Points:**
> 1. **Hamstrings** - You're doing 66% less volume than your other muscle groups
> 2. **Rear Delts** - 49% below average
> 3. **Biceps** - 34% below average
>
> Also, your push/pull ratio is 1.4:1, which means you're doing 40% more pushing than pulling. This can lead to shoulder imbalances.
>
> **My Recommendation: 8-Week Weak Point Program**
>
> **Add these exercises:**
> - **Romanian Deadlifts** (hamstrings): 3x8-12, twice per week
> - **Face Pulls** (rear delts): 4x15-20, twice per week
> - **Hammer Curls** (biceps): 3x10-12, twice per week
>
> Start at minimum effective volume (MEV) and gradually increase over 8 weeks, then deload.
>
> Would you like me to create this full program in your app? I can integrate it with your current training schedule."

---

### 2.3 "How's my push/pull balance?"

**MCP Server Response Pattern:**

1. **Calculate Push/Pull Volume**:
   - Query: Aggregate volume by `base_exercise.force` ('push', 'pull', 'static')
   - Time window: Last 4 weeks

2. **Return Balance Analysis**:
```yaml
push_pull_analysis:
  period: "Last 4 weeks"

  volume_breakdown:
    push:
      total_volume_kg: 24500
      weekly_sets: 32
      exercises: ["Bench Press", "Overhead Press", "Dips", "Lateral Raise"]

    pull:
      total_volume_kg: 17800
      weekly_sets: 24
      exercises: ["Pull-ups", "Bent Over Row", "Face Pull"]

    static:  # Legs, core
      total_volume_kg: 18900
      weekly_sets: 28
      exercises: ["Squat", "Romanian Deadlift", "Plank"]

  balance_metrics:
    push_pull_ratio: 1.38  # Imbalanced (target: 0.9-1.1)
    push_percentage: 40%
    pull_percentage: 29%
    static_percentage: 31%

  status: "imbalanced_push_dominant"

  recommendations:
    - "Increase pulling volume by 8 sets per week (25% increase)"
    - "Add exercise: Barbell Row (3x8-10, 2x per week)"
    - "Add exercise: Face Pull (4x15-20, 2x per week)"
    - "Consider reducing pushing volume slightly if total volume is high"

  injury_risk:
    assessment: "moderate"
    description: "Push-dominant training can lead to internal shoulder rotation and poor posture"
    prevention: "Prioritize horizontal pulling (rows) and rear delt work"
```

**Expected Conversation:**
> **User:** "How's my push/pull balance?"
>
> **Claude (via MCP):** "Your push/pull ratio is 1.38:1, which means you're doing 38% more pushing than pulling. Ideally, this should be closer to 1:1 (or slightly pull-dominant for shoulder health).
>
> **Current Volume:**
> - Push: 32 sets/week (40%)
> - Pull: 24 sets/week (29%)
> - Legs/Core: 28 sets/week (31%)
>
> **Why this matters:** Push-dominant training can lead to internal shoulder rotation, rounded shoulders, and increased injury risk.
>
> **Quick Fix:** Add 8 sets of pulling per week:
> - Barbell Rows: 3x8-10, twice per week
> - Face Pulls: 4x15-20, twice per week
>
> This will bring you to 1.13:1, which is much healthier. Want me to add these to your current program?"

---

### 2.4 "Am I recovering adequately?"

**MCP Server Response Pattern:**

1. **Analyze Training Load**:
   - Total weekly volume (last 4 weeks)
   - Session frequency
   - Intensity distribution (% of sets >85% 1RM)

2. **Check Volume Landmarks**:
   - Compare current volume to MRV (Maximum Recoverable Volume)
   - Per-muscle and total

3. **Detect Regression Signals**:
   - Performance decreases despite maintained/increased volume
   - Unusual fatigue patterns

4. **Return Recovery Analysis**:
```yaml
recovery_assessment:
  period: "Last 4 weeks"

  training_load:
    avg_weekly_volume_kg: 62000
    avg_sessions_per_week: 4.8
    avg_sets_per_week: 88

  intensity_distribution:
    high_intensity_sets: 24  # >85% 1RM
    moderate_intensity_sets: 52  # 70-85% 1RM
    low_intensity_sets: 12  # <70% 1RM
    high_intensity_percentage: 27%  # Good (target: 20-30%)

  volume_landmark_comparison:
    chest:
      current_weekly_sets: 20
      mav_sets: 18  # Maximum Adaptive Volume
      mrv_sets: 22  # Maximum Recoverable Volume
      status: "approaching_mrv"  # Warning

    back:
      current_weekly_sets: 24
      mav_sets: 20
      mrv_sets: 26
      status: "within_mav"  # Good

    legs:
      current_weekly_sets: 28
      mav_sets: 22
      mrv_sets: 30
      status: "high_but_recoverable"

  regression_signals:
    detected: true
    exercises:
      - name: "Bench Press"
        last_4_weeks_1rm_change_kg: -1.5
        volume_change: "+8%"
        interpretation: "Performance decreased despite increased volume (potential overtraining)"

  recovery_score: 6.5  # Out of 10 (10 = perfect recovery)

  recommendations:
    immediate:
      - "Reduce chest volume to 16 sets/week (below MAV) for 1-2 weeks"
      - "Consider deload week if fatigue persists"

    ongoing:
      - "Monitor chest exercises for continued regression"
      - "Ensure 7-8 hours sleep per night"
      - "Consider tracking subjective fatigue (RPE) per session"
```

**Expected Conversation:**
> **User:** "Am I recovering adequately?"
>
> **Claude (via MCP):** "Looking at your last 4 weeks, I see some concerning signals:
>
> **Recovery Score: 6.5/10**
>
> **Good news:**
> - Your overall training volume (88 sets/week) is manageable
> - Intensity distribution is healthy (27% high-intensity)
> - Most muscle groups are within optimal ranges
>
> **Concerns:**
> - Your chest volume (20 sets/week) is approaching your Maximum Recoverable Volume (MRV: 22 sets)
> - More concerning: Your bench press 1RM has *decreased* by 1.5kg despite an 8% increase in volume over this period. This is a classic overtraining signal.
>
> **What to do:**
> 1. **Immediate:** Reduce chest volume to 16 sets/week for the next 1-2 weeks
> 2. **Watch closely:** If performance doesn't improve, take a full deload week (50% volume reduction)
> 3. **Long-term:** Your body may have a lower MRV for chest than average. Consider 16-18 sets as your sustainable max.
>
> How have you been feeling during chest workouts? Any unusual fatigue or joint discomfort?"

---

### 2.5 "Suggest deload timing"

**MCP Server Response Pattern:**

1. **Check Deload Indicators**:
   - Sustained high volume (4+ weeks at or near MRV)
   - Performance stagnation despite progression attempts
   - High session frequency with no rest days
   - Accumulated fatigue (subjective if tracked)

2. **Calculate Time Since Last Deload**:
   - Query sessions for low-volume weeks (<50% of average)
   - Identify last deload (if any)

3. **Return Deload Recommendation**:
```yaml
deload_recommendation:
  period_analyzed: "Last 8 weeks"

  deload_indicators:
    - indicator: "sustained_high_volume"
      status: true
      details: "6 consecutive weeks at 85+ sets/week"
      weight: 0.8

    - indicator: "performance_stagnation"
      status: true
      details: "3 main lifts show <1% improvement in last 4 weeks"
      weight: 0.9

    - indicator: "high_frequency_no_rest"
      status: false
      details: "Average 4.5 sessions/week with 2 rest days"
      weight: 0.3

    - indicator: "accumulated_fatigue"
      status: "unknown"
      details: "No subjective fatigue data tracked"
      weight: 0.0

  last_deload:
    date: "2025-09-15"  # 10 weeks ago
    weeks_since: 10
    typical_deload_frequency: "Every 4-8 weeks"

  recommendation:
    needs_deload: true
    confidence: 0.85
    timing: "This week or next week"
    urgency: "high"

  deload_protocol:
    type: "volume_reduction"  # Alternative: "intensity_reduction", "active_recovery"
    duration: "1 week"
    approach:
      - "Reduce total sets by 50% (from 88 to 44 sets)"
      - "Keep weight the same (maintain intensity)"
      - "Focus on perfect form and mind-muscle connection"
      - "Maintain training frequency (same session split)"
    expected_outcome: "Return to training refreshed with improved performance"

  rationale: |
    You've been training at high volume for 6 weeks without a break, and performance
    has plateaued on major lifts. Additionally, it's been 10 weeks since your last
    deload, which is beyond the typical 4-8 week cycle. A deload will allow your body
    to dissipate accumulated fatigue while maintaining adaptations.
```

**Expected Conversation:**
> **User:** "Suggest deload timing"
>
> **Claude (via MCP):** "**You should deload this week or next week.** Here's why:
>
> **Deload Indicators:**
> - You've trained at 85+ sets/week for 6 consecutive weeks (high volume)
> - Your main lifts (squat, bench, deadlift) have improved less than 1% in the last 4 weeks
> - It's been **10 weeks** since your last deload (typical frequency is every 4-8 weeks)
>
> **Recommended Deload Protocol:**
> - **Duration:** 1 week
> - **Approach:** Volume reduction (keep intensity)
> - **How:** Cut your sets in half (from 88 to 44 sets)
> - **Keep:** Same weights, same exercises, same split
> - **Focus:** Perfect form, recovery, mind-muscle connection
>
> **Why this works:** Your body has accumulated fatigue from 6 weeks of high-volume training. Deloading allows you to dissipate fatigue while maintaining your strength adaptations. You'll likely come back stronger!
>
> **After deload:** Return to training at 70-75% of your pre-deload volume for week 1, then build back up.
>
> Want me to create a deload plan for your current program?"

---

### 2.6 "Compare my progress to typical lifters"

**Note:** This is a **future feature** requiring external data (population benchmarks). Currently out of scope, but MCP architecture should support it.

**Future Implementation:**
- Add resource: `workout://benchmarks/population-data`
- Compare user's 1RM to strength standards (beginner/intermediate/advanced)
- Requires careful framing to avoid discouragement
- Privacy consideration: Only compare anonymized aggregates

---

## 3. Data Structure Optimization for LLM Context

### 3.1 Context Window Management

**Research Finding:** Modern LLMs have large context windows (Claude 3.5 Sonnet: 200K tokens), but **performance degrades with excessive context**.

**Best Practices:**

#### **Principle 1: Progressive Disclosure**
Start with summaries, provide details on request.

```yaml
# Initial context (compact)
exercise_summary:
  exercise: "Bench Press"
  last_session: "2025-11-21"
  recent_trend: "plateauing"
  avg_weekly_volume_kg: 3040
  one_rm_estimate_kg: 105

# Detailed context (on request)
exercise_history_detailed:
  # Full 90-day time series
  sessions: [...]  # 30+ sessions
```

#### **Principle 2: Aggregate First, Detail Second**
Pre-compute aggregates server-side.

```yaml
# Good: Aggregates provided
volume_analysis:
  total_volume_kg: 124000
  avg_weekly_volume_kg: 31000
  weekly_trend: "+5%"
  sessions: 16

# Bad: Raw data only (forces LLM to compute)
raw_sessions:
  - date: "2025-11-21"
    sets: [...]
  - date: "2025-11-20"
    sets: [...]
  # ... 100+ sessions
```

#### **Principle 3: Semantic Chunking**
Chunk data by logical units (per exercise, per muscle, per week).

```python
# Good: Chunked by muscle group
@mcp.resource("workout://analytics/muscle/{muscle_name}")
async def get_muscle_analytics(muscle_name: str):
    """Single muscle group analytics"""

# Bad: All muscles in one giant blob
@mcp.resource("workout://analytics/all-muscles")
async def get_all_muscle_analytics():
    """Returns 20+ muscle groups, overwhelming"""
```

---

### 3.2 Temporal Data Structuring

**Research Finding:** Time series data benefits from **hybrid representation** (raw + aggregated).

**Recommended Structure:**

```yaml
exercise_history:
  metadata:
    exercise: "Bench Press"
    period: "2025-08-21 to 2025-11-21"
    total_sessions: 26

  aggregates:  # Summary statistics
    by_week:
      - week_start: "2025-11-14"
        sessions: 2
        total_volume_kg: 3180
        avg_1rm_kg: 106
        volume_change_from_previous_week: "+4%"
      - week_start: "2025-11-07"
        sessions: 2
        total_volume_kg: 3060
        avg_1rm_kg: 105
        volume_change_from_previous_week: "+2%"
      # ... more weeks

    by_month:
      - month: "2025-11"
        sessions: 8
        total_volume_kg: 12200
        avg_1rm_kg: 105.5
        progression_kg: +1.8
      # ... more months

  raw_sessions:  # Optional, for detailed analysis
    - date: "2025-11-21"
      sets:
        - weight_kg: 80
          reps: 10
          set_type: "regular"
        - weight_kg: 80
          reps: 9
          set_type: "regular"
        # ... more sets
      total_volume_kg: 3200
      estimated_1rm_kg: 106.4
    # ... more sessions (paginated if >50)
```

**Benefits:**
- **Fast scanning**: LLM can reason about trends from aggregates
- **Drill-down**: Raw data available for specific questions
- **Token-efficient**: Aggregates are compact

---

### 3.3 Scientific Context Embedding

**Research Finding:** LLMs benefit from **embedded domain knowledge** in data structures.

**Example: Volume Landmarks Context**

```yaml
volume_analysis:
  current_volume:
    chest_weekly_sets: 18

  volume_landmarks:  # Educational context for LLM
    definition: "Volume landmarks are evidence-based training volume ranges by Dr. Mike Israetel"
    source: "Renaissance Periodization"

    ranges:
      mv_maintenance_volume:
        sets: 6
        description: "Minimum to maintain muscle mass"
      mev_minimum_effective_volume:
        sets: 10
        description: "Minimum to grow"
      mav_maximum_adaptive_volume:
        sets: 12-18
        description: "Optimal growth range"
      mrv_maximum_recoverable_volume:
        sets: 22
        description: "Upper limit before overtraining"

  interpretation:
    status: "within_mav"
    recommendation: "You're in the optimal growth range. Can increase by 1-2 sets if recovered."
```

**Benefits:**
- **Self-documenting**: LLM understands scientific basis
- **Consistent reasoning**: LLM applies same framework across users
- **Educational**: User learns principles through conversation

---

## 4. Privacy and Data Filtering

### 4.1 Privacy-First Data Access

**Research Finding:** 80% of fitness apps transfer user data to third parties. **MCP server must be privacy-first by default.**

**Principles:**

#### **Principle 1: User-Configurable Data Sharing**
Store preferences in `app_user.data` JSONB field:

```sql
-- Example: User privacy preferences
UPDATE app_user SET data = jsonb_set(
  COALESCE(data, '{}'::jsonb),
  '{mcp_settings}',
  '{
    "include_notes": true,
    "include_session_times": false,
    "share_exercise_names": true,
    "share_performance_data": true,
    "max_history_days": 90,
    "allow_comparative_analytics": false
  }'::jsonb
);
```

**MCP Implementation:**
```python
@mcp.resource("workout://performance/history/{exercise_name}")
async def get_exercise_history(exercise_name: str, days: int = 90):
    """Respects user privacy settings."""
    user_settings = await get_user_mcp_settings()

    # Filter based on preferences
    max_days = min(days, user_settings.get("max_history_days", 365))

    history = await db.query(
        """
        SELECT
          date,
          CASE
            WHEN $1 THEN note ELSE NULL
          END as note,
          volume_kg,
          one_rm_estimate
        FROM exercise_stats_v3
        WHERE exercise_name = $2
          AND date >= NOW() - INTERVAL '%s days'
        """,
        user_settings.get("include_notes", True),
        exercise_name,
        max_days
    )

    return history
```

#### **Principle 2: No Third-Party Data Sharing**
- MCP server does NOT send data to external services
- All AI reasoning happens in user's chosen LLM (Claude, ChatGPT, etc.)
- User controls which LLM has access via MCP authorization

#### **Principle 3: Anonymization for Comparative Analytics**
If implementing population benchmarks (future):
- Aggregate anonymized data (no PII)
- Opt-in only (`allow_comparative_analytics: true`)
- Clear disclosure of what's shared

---

### 4.2 Data Filtering Strategies

**Sensitive Data Categories:**

| Data Type | Sensitivity | Default Access | Configurable |
|-----------|-------------|----------------|--------------|
| Exercise names | Low | ✅ Allowed | ❌ No |
| Sets/reps/weight | Low | ✅ Allowed | ❌ No |
| Volume/1RM | Low | ✅ Allowed | ❌ No |
| Session notes | **High** | ✅ Allowed | ✅ Yes (`include_notes`) |
| Session times | Medium | ✅ Allowed | ✅ Yes (`include_session_times`) |
| Body weight | **High** | ❌ Excluded | ✅ Yes (`include_body_metrics`) |
| Photos/videos | **High** | ❌ Excluded | ✅ Yes (future) |

**Rationale:**
- **Exercise performance data**: Essential for coaching, low privacy risk
- **Session notes**: May contain personal info (injuries, mood, life events) - user configurable
- **Body weight**: Sensitive, only include if user explicitly opts in
- **Photos/videos**: High privacy risk, requires explicit consent per item

---

### 4.3 MCP Authorization & Row-Level Security

**Integration with Supabase RLS:**

MCP server leverages existing RLS policies:

```python
# MCP server authenticates user via OAuth 2.1
# Gets Supabase JWT token
# All database queries automatically filtered by RLS

async def get_exercise_history(exercise_name: str):
    # Supabase RLS ensures only user's own data is returned
    # No manual filtering needed - database enforces security
    return await supabase.from_("exercise_stats_v3") \
        .select("*") \
        .eq("exercise_name", exercise_name) \
        .execute()  # RLS filters to auth.uid() automatically
```

**Benefits:**
- **No security bypass**: Impossible to leak other users' data
- **Consistent with app**: Same RLS policies as mobile app
- **Audit trail**: All access logged via Supabase audit tables

---

## 5. Caching Strategies

### 5.1 Multi-Tier Caching Architecture

**Research Finding:** MCP caching can reduce latency by **50-70%** while maintaining data consistency.

**Recommended Tiers:**

#### **Tier 1: In-Memory Cache (Redis or in-process)**
- **What:** Frequently accessed, read-only resources
- **TTL:** 5-60 minutes depending on data staleness tolerance
- **Examples:**
  - Exercise catalog (TTL: 60 minutes, rarely changes)
  - User's current active plan (TTL: 5 minutes)
  - Recent session summary (TTL: 5 minutes)

**Implementation:**
```python
from functools import lru_cache
import asyncio

# In-memory cache for exercise catalog
@lru_cache(maxsize=1)
@ttl_cache(seconds=3600)  # 1 hour TTL
async def get_exercise_catalog_cached():
    return await db.query("SELECT * FROM base_exercise_with_muscles")

@mcp.resource("workout://exercises/catalog")
async def get_exercise_catalog():
    return await get_exercise_catalog_cached()
```

#### **Tier 2: Distributed Cache (Redis/Valkey)**
- **What:** User-specific analytics (expensive to compute)
- **TTL:** 1-24 hours depending on update frequency
- **Examples:**
  - Plateau indicators (TTL: 24 hours, updated daily)
  - Weak point analysis (TTL: 6 hours)
  - Volume landmarks status (TTL: 1 hour)

**Implementation:**
```python
import redis.asyncio as redis

cache = redis.Redis(host='localhost', port=6379)

async def get_plateau_indicators(user_id: str):
    # Check cache first
    cached = await cache.get(f"plateau_indicators:{user_id}")
    if cached:
        return json.loads(cached)

    # Compute if not cached
    result = await compute_plateau_indicators(user_id)

    # Cache for 24 hours
    await cache.setex(
        f"plateau_indicators:{user_id}",
        86400,  # 24 hours
        json.dumps(result)
    )

    return result
```

#### **Tier 3: Materialized Views (PostgreSQL)**
- **What:** Complex aggregations used across multiple MCP resources
- **Refresh:** Hourly or on-demand after new session
- **Examples:**
  - `exercise_stats_v3` (aggregates from `performed_exercise_set`)
  - `muscle_volume_weekly` (volume per muscle per week)
  - `user_progression_summary` (overall progress metrics)

**Implementation:**
```sql
-- Create materialized view
CREATE MATERIALIZED VIEW exercise_stats_v3 AS
SELECT
  pe.name as exercise_name,
  date_trunc('day', pes.completed_at) as date,
  SUM(pes.weight * pes.reps) / 1000.0 as volume_kg,
  MAX(round(pes.weight * (36.0 / (37.0 - pes.reps)))) as brzycki_1rm_kg,
  COUNT(*) FILTER (WHERE pes.exercise_set_type != 'warm-up') as working_sets,
  ps.app_user_id
FROM performed_exercise_set pes
JOIN performed_exercise pe ON pes.performed_exercise_id = pe.performed_exercise_id
JOIN performed_session ps ON pe.performed_session_id = ps.performed_session_id
WHERE pes.completed_at IS NOT NULL
GROUP BY pe.name, date, ps.app_user_id;

-- Refresh hourly via cron job
CREATE EXTENSION IF NOT EXISTS pg_cron;
SELECT cron.schedule('refresh-exercise-stats', '0 * * * *',
  'REFRESH MATERIALIZED VIEW CONCURRENTLY exercise_stats_v3');
```

---

### 5.2 Cache Invalidation Strategies

**Research Finding:** "Common mistakes include over-relying on TTL without active invalidation."

**Recommended Strategies:**

#### **Strategy 1: Event-Driven Invalidation**
Invalidate cache when user creates/updates data:

```python
async def create_performed_session(session_data):
    # Write to database
    session = await db.insert("performed_session", session_data)

    # Invalidate affected caches
    user_id = session_data["app_user_id"]
    await cache.delete(f"recent_sessions:{user_id}")
    await cache.delete(f"plateau_indicators:{user_id}")
    await cache.delete(f"weak_points:{user_id}")

    # Trigger materialized view refresh (async)
    asyncio.create_task(refresh_materialized_view("exercise_stats_v3"))

    return session
```

#### **Strategy 2: Versioned Caching**
Include version/timestamp in cache key:

```python
async def get_exercise_history_cached(user_id, exercise_name):
    # Get user's last session timestamp
    last_session = await db.query(
        "SELECT MAX(completed_at) FROM performed_session WHERE app_user_id = $1",
        user_id
    )

    # Cache key includes last_session timestamp (auto-invalidates when new session)
    cache_key = f"history:{user_id}:{exercise_name}:{last_session.isoformat()}"

    cached = await cache.get(cache_key)
    if cached:
        return json.loads(cached)

    # Compute and cache
    result = await compute_exercise_history(user_id, exercise_name)
    await cache.setex(cache_key, 3600, json.dumps(result))

    return result
```

#### **Strategy 3: Lazy Invalidation**
Combine TTL with version checking:

```python
async def get_cached_with_version(cache_key, compute_fn, ttl=3600):
    cached_data = await cache.get(cache_key)

    if cached_data:
        cached = json.loads(cached_data)

        # Check if data is stale (version mismatch)
        current_version = await get_data_version()
        if cached.get("version") == current_version:
            return cached["data"]

    # Compute fresh data
    result = await compute_fn()

    await cache.setex(cache_key, ttl, json.dumps({
        "version": await get_data_version(),
        "data": result
    }))

    return result
```

---

### 5.3 Predictive Cache Warming

**Research Finding:** "Advanced systems use ML to predict data access patterns and preemptively load cache."

**Practical Implementation (Non-ML):**

```python
# After user completes session, warm caches for likely next queries
async def on_session_completed(user_id, session_id):
    # Likely queries after workout:
    # 1. "How did I do today?"
    # 2. "What should I do next session?"
    # 3. "Am I making progress?"

    # Pre-warm these caches:
    asyncio.create_task(get_recent_sessions_cached(user_id))
    asyncio.create_task(get_plateau_indicators_cached(user_id))
    asyncio.create_task(get_next_session_recommendations_cached(user_id))

    # User will get instant responses when they ask!
```

---

## 6. Implementation Roadmap

### Phase 1: MVP - Read-Only Analytics (2-3 weeks)
**Goal:** Enable conversational workout analysis with existing data

**Scope:**
- MCP server with STDIO transport (local development)
- Resources: exercise catalog, performance history, recent sessions
- Tools: `analyze_progress`, `check_recovery_needs`, `detect_weak_points`
- No write operations (no plan creation)
- Basic caching (in-memory only)

**Deliverables:**
- FastMCP server (`workout-mcp-server`)
- Supabase REST API client (Pyodide-compatible)
- 5-10 resources and tools
- Local testing with Claude Desktop
- Documentation for local setup

**Success Criteria:**
- User can ask "Why am I plateauing on bench press?" and get data-driven answer
- Response time < 2 seconds (p95)
- All data filtered by user (RLS working)

---

### Phase 2: Advanced Analytics & Caching (1-2 weeks)
**Goal:** Production-ready performance and complex analytics

**Scope:**
- Redis caching layer (Tier 1 & 2)
- Materialized views for expensive aggregations
- Advanced tools: volume landmarks, push/pull balance, deload recommendations
- Prompts: Pre-packaged conversation templates
- Rate limiting (100 req/hour/user)

**Deliverables:**
- Redis integration
- 3-5 materialized views
- 10+ resources and tools
- 5+ conversation prompts
- Performance monitoring

**Success Criteria:**
- 50-70% cache hit rate
- Response time < 1 second for cached queries
- Complex analytics (weak point detection) < 2 seconds

---

### Phase 3: HTTP Transport & OAuth 2.1 (2-3 weeks)
**Goal:** Remote access with secure authentication

**Scope:**
- HTTP + SSE transport
- Supabase OAuth 2.1 integration
- JWT token validation
- Deploy to Fly.io (native PostgreSQL drivers for performance)
- Privacy settings UI (future frontend work)

**Deliverables:**
- HTTP server with OAuth flow
- Authorization middleware
- Deployment configuration
- Security audit

**Success Criteria:**
- User can authorize MCP server from Claude Desktop via OAuth
- Zero authentication bypasses (security tested)
- Production deployment stable

---

### Phase 4: Write Operations - Plan Creation (2-3 weeks)
**Goal:** AI can create personalized workout plans

**Scope:**
- Implement `user_plan` table (if not already done)
- Tool: `design_program` (creates plans in database)
- Tool: `modify_plan` (updates existing plans)
- Validation logic (prevent invalid plans)
- Template system (base plans as starting points)

**Deliverables:**
- Plan creation tools
- Plan validation functions
- Template library
- User plan management

**Success Criteria:**
- User can say "Create a 4-day upper/lower split" and AI generates valid plan
- Plans respect volume landmarks and exercise science principles
- Plans saved to database and visible in mobile app

---

### Phase 5: MCP Registry Publication (1 week)
**Goal:** Make server discoverable in MCP ecosystem

**Scope:**
- Package for PyPI (using UV)
- Create `server.json` metadata
- Publish to MCP.io registry
- Documentation and examples
- Demo video

**Deliverables:**
- PyPI package: `workout-mcp-server`
- MCP registry listing
- Setup documentation
- Demo video

**Success Criteria:**
- Server appears in MCP registry
- Installable via `mcp install workout-mcp-server`
- 10+ users connect MCP server within first month

---

## 7. Key Integration Patterns Summary

### 7.1 Data Flow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                       User (Claude Desktop)                  │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ Natural Language Query
                            │ "Why am I plateauing?"
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    LLM (Claude/GPT-4)                        │
│  • Interprets user intent                                    │
│  • Decides which MCP tools/resources to call                 │
│  • Synthesizes conversational response                       │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ MCP Protocol (JSON-RPC 2.0)
                            │ Call: analyze_progress("Bench Press")
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                  MCP Server (FastMCP)                        │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Resources      Tools           Prompts               │   │
│  │ • Catalog     • analyze()      • plateau_template    │   │
│  │ • History     • detect_weak()  • deload_template     │   │
│  │ • Sessions    • suggest()      • balance_template    │   │
│  └──────────────────────────────────────────────────────┘   │
│                            │                                 │
│                            │ Auth: Supabase JWT              │
│                            ▼                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │           Caching Layer (Redis)                      │   │
│  │  • Exercise catalog (1hr TTL)                        │   │
│  │  • Plateau indicators (24hr TTL)                     │   │
│  │  • User analytics (6hr TTL)                          │   │
│  └──────────────────────────────────────────────────────┘   │
└───────────────────────────┬─────────────────────────────────┘
                            │
                            │ SQL Queries (RLS enforced)
                            ▼
┌─────────────────────────────────────────────────────────────┐
│              Supabase PostgreSQL Database                    │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Tables:                                              │   │
│  │ • performed_exercise_set (raw sets data)            │   │
│  │ • performed_exercise                                 │   │
│  │ • performed_session                                  │   │
│  │ • base_exercise (with rich metadata)                │   │
│  │ • muscle_group, equipment_type                       │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌──────────────────────────────────────────────────────┐   │
│  │ Views (Materialized):                                │   │
│  │ • exercise_stats_v3 (aggregated performance)        │   │
│  │ • muscle_volume_weekly (volume per muscle)          │   │
│  │ • base_exercise_with_muscles (exercise catalog)     │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  RLS: WHERE app_user_id = auth.uid()                        │
└─────────────────────────────────────────────────────────────┘
```

---

### 7.2 Key Design Decisions Summary

| Decision | Choice | Rationale |
|----------|--------|-----------|
| **MCP Role** | Data provider only | LLM provides coaching intelligence, not server |
| **Caching Strategy** | Multi-tier (in-memory + Redis + materialized views) | 50-70% latency reduction |
| **Data Format** | YAML for complex, JSON for simple | 66% token efficiency gain |
| **Context Structure** | Aggregates + raw data (hybrid) | Fast reasoning + drill-down capability |
| **Privacy** | User-configurable, no third-party sharing | 80% of fitness apps leak data - we won't |
| **Authentication** | Supabase OAuth 2.1 + JWT | Reuse existing auth, industry standard |
| **Hosting** | Fly.io (native PostgreSQL) | 5-20ms queries vs 50-150ms REST API |
| **Transport** | STDIO (dev) + HTTP (prod) | Local testing + remote access |
| **Volume Landmarks** | Embedded in responses | LLM learns exercise science principles |
| **Rate Limiting** | 100 req/hour/user in server code | Better than platform limits (429 errors) |
| **Time Windows** | 90 days default, paginated for more | Balance recency vs history |
| **Plateau Detection** | Pre-computed daily, cached 24hr | Expensive calculation, infrequent changes |

---

### 7.3 Example Conversational Flows

#### **Flow 1: Plateau Investigation**
```
User: "Why am I stuck on bench press?"
  ↓
LLM: [Calls analyze_progress("Bench Press", 60 days)]
  ↓
MCP: [Returns: volume_trend: "stagnant", 1rm_change: -0.5kg, frequency: 2x/week]
  ↓
LLM: "Your bench press has stagnated because [analysis]. Try [recommendations]."
  ↓
User: "Should I deload?"
  ↓
LLM: [Calls check_recovery_needs()]
  ↓
MCP: [Returns: needs_deload: false, reason: "volume moderate, recent deload 3 weeks ago"]
  ↓
LLM: "No, you don't need a deload yet. Instead, try increasing volume by 2 sets."
```

#### **Flow 2: Program Design**
```
User: "Design a program for my weak points"
  ↓
LLM: [Calls detect_weak_points()]
  ↓
MCP: [Returns: weak_muscles: [hamstrings, rear_delts], push_pull_ratio: 1.4]
  ↓
LLM: "Your weak points are [list]. Here's an 8-week program: [outline]"
  ↓
User: "Create it for me"
  ↓
LLM: [Calls design_program(goals=["weak_points"], weak_muscles=[...], sessions=4)]
  ↓
MCP: [WRITES to database, returns user_plan_id]
  ↓
LLM: "Done! Your new plan 'Weak Point Focus' is now active in your app."
```

---

## 8. References & Further Reading

### 8.1 MCP Specification & Best Practices
- [MCP Specification 2025-03-26](https://modelcontextprotocol.io/specification/2025-03-26)
- [FastMCP Documentation](https://gofastmcp.com/)
- [MCP Best Practices (MikesBlog)](https://oshea00.github.io/posts/mcp-practices/)
- [Advanced MCP Caching Strategies (Medium)](https://medium.com/@parichay2406/advanced-caching-strategies-for-mcp-servers)

### 8.2 Exercise Science & Volume Landmarks
- [Volume Landmarks - Dr. Mike Israetel (Renaissance Periodization)](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth)
- Stronger by Science (Greg Nuckols) - Progressive Overload Research
- [AI in Fitness Industry 2025 Trends (Orangesoft)](https://orangesoft.co/blog/ai-in-fitness-industry)

### 8.3 LLM Context Optimization
- [Context Engineering: 2025's #1 Skill in AI](https://www.decodingai.com/p/context-engineering-2025s-1-skill)
- [LLM Context Window Performance Research (Epoch AI)](https://epoch.ai/data-insights/context-windows)
- [YAML 66% Token Efficiency Study](https://www.analyticsvidhya.com/blog/2025/11/guide-to-context-engineering/)

### 8.4 Fitness App Data Privacy
- [Fitness Apps Data Privacy Concerns (CyberGuy)](https://cyberguy.com/privacy/trade-off-between-using-fitness-apps-and-data-privacy-concerns/)
- GDPR & HIPAA Compliance for Health Data

### 8.5 RAG & Time Series Analytics
- [TS-RAG: Time Series Foundation Models (arXiv 2503.07649)](https://arxiv.org/abs/2503.07649)
- [Retrieval-Augmented Generation 2025 Guide (Chitika)](https://www.chitika.com/retrieval-augmented-generation-rag-the-definitive-guide-2025/)

### 8.6 Related Project Documents
- `.github/EPIC_mcp_integration.md` - Full MCP integration epic
- `docs/plans/2025-11-21-sets-migration-analytics-design.md` - V3 analytics design
- `docs/research/phase-2-research-plan.md` - Phase 2 research roadmap
- `database/065_ExerciseMetadata_Normalized.sql` - Exercise metadata schema
- `database/071_SpecialSet.sql` - Performed exercise set schema

---

## 9. Next Steps

1. **User Review:** Validate research findings and recommendations
2. **Prioritization:** Confirm Phase 1 scope and timeline
3. **Technical Spike:** Test FastMCP + Supabase REST API integration (Pyodide compatibility)
4. **Database Prep:** Ensure `exercise_stats_v3` view exists (or create as part of Phase 1)
5. **MCP Server Setup:** Initialize FastMCP project structure
6. **Documentation:** Create developer guide for MCP server development

---

**Document Version:** 1.0
**Last Updated:** 2025-11-21
**Status:** Ready for Review
**Next Review:** After Phase 1 MVP completion
