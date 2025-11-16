# Phase 3: User Plans + Write Operations + Volume Landmarks

**Status**: Planning
**Priority**: Medium (after Phase 2)
**Effort**: Large (3-4 weeks)
**Labels**: `mcp`, `user-plans`, `volume-landmarks`, `phase-3`
**Epic**: EPIC_mcp_integration.md
**Depends On**: Phase 2 #XXX, Pre-req: ISSUE_user_plan_schema #XXX

## Goal

Enable AI to create personalized workout plans for users and provide evidence-based coaching using volume landmarks (MEV/MAV/MRV).

## Success Criteria

User can:
1. Ask AI to "Create me a 4-day upper/lower split" → AI generates valid user_plan
2. Ask "Am I doing too much volume for chest?" → AI checks against volume landmarks
3. Modify existing plans via AI conversation
4. Share plans (simple: private/public only)
5. Get deload week suggestions based on volume analysis

## Scope

### In Scope
- ✅ User plan creation tools (via MCP)
- ✅ User plan modification tools
- ✅ Volume landmarks implementation (MEV/MAV/MRV per muscle group)
- ✅ Per-muscle volume calculation
- ✅ Deload detection and suggestions
- ✅ Plan templates (based on existing system plans)
- ✅ Simple sharing (private/public visibility)
- ✅ Write operation security (RLS validation)

### Out of Scope
- ❌ Complex sharing (specific users, following)
- ❌ Plan version history
- ❌ Plan comments/ratings
- ❌ Social features
- ❌ MCP registry publication (Phase 4)

## Prerequisites

From ISSUE_user_plan_schema.md:
- [x] `user_plan` table created with RLS policies
- [x] `session_schedule` extended to support `user_plan_id`
- [x] `all_plans` view combining system and user plans

## Implementation

### 1. Volume Landmarks Data

We already have exercise-to-muscle mapping in the app. Define volume landmarks per muscle group (based on Israetel's research):

```python
# volume_landmarks.py
"""
Volume landmarks for muscle hypertrophy training.

Based on Dr. Mike Israetel's research (Renaissance Periodization).
Values are sets per muscle group per week.
"""

VOLUME_LANDMARKS = {
    # Upper Body - Pushing
    "chest": {
        "MV": 8,    # Maintenance Volume
        "MEV": 10,  # Minimum Effective Volume
        "MAV": 18,  # Maximum Adaptive Volume (midpoint)
        "MRV": 22   # Maximum Recoverable Volume
    },
    "front_delts": {
        "MV": 0,    # Gets maintenance from chest work
        "MEV": 0,   # Direct work often not needed
        "MAV": 8,
        "MRV": 12
    },
    "side_delts": {
        "MV": 6,
        "MEV": 8,
        "MAV": 22,
        "MRV": 26
    },
    "rear_delts": {
        "MV": 6,
        "MEV": 8,
        "MAV": 20,
        "MRV": 26
    },
    "triceps": {
        "MV": 4,    # Gets work from pressing
        "MEV": 6,
        "MAV": 18,
        "MRV": 22
    },

    # Upper Body - Pulling
    "back_thickness": {  # Rows, pulldowns
        "MV": 8,
        "MEV": 10,
        "MAV": 20,
        "MRV": 25
    },
    "back_width": {  # Pull-ups, lat focus
        "MV": 8,
        "MEV": 10,
        "MAV": 20,
        "MRV": 25
    },
    "biceps": {
        "MV": 4,
        "MEV": 8,
        "MAV": 20,
        "MRV": 26
    },

    # Lower Body
    "quads": {
        "MV": 6,
        "MEV": 8,
        "MAV": 18,
        "MRV": 22
    },
    "hamstrings": {
        "MV": 4,
        "MEV": 6,
        "MAV": 16,
        "MRV": 20
    },
    "glutes": {
        "MV": 4,
        "MEV": 6,
        "MAV": 16,
        "MRV": 20
    },
    "calves": {
        "MV": 6,
        "MEV": 8,
        "MAV": 20,
        "MRV": 25
    },

    # Core
    "abs": {
        "MV": 0,    # Gets work from compounds
        "MEV": 0,
        "MAV": 20,
        "MRV": 25
    },
}

def get_volume_status(actual_sets: int, muscle: str) -> dict:
    """
    Check volume status against landmarks.

    Returns:
        dict with status, recommendation, and landmark values
    """
    landmarks = VOLUME_LANDMARKS.get(muscle.lower())
    if not landmarks:
        return {"error": f"Unknown muscle group: {muscle}"}

    if actual_sets < landmarks["MV"]:
        status = "below_maintenance"
        recommendation = "Volume below maintenance. Muscle loss likely. Increase volume."
    elif actual_sets < landmarks["MEV"]:
        status = "maintenance"
        recommendation = "Maintenance volume. Not growing, but maintaining. Increase for growth."
    elif actual_sets <= landmarks["MAV"]:
        status = "optimal"
        recommendation = "Optimal volume for growth. Continue current approach."
    elif actual_sets <= landmarks["MRV"]:
        status = "high"
        recommendation = "High volume, approaching max recoverable. Monitor fatigue."
    else:
        status = "excessive"
        recommendation = "Exceeds MRV. Deload recommended - reduce to 50-60% of current volume."

    return {
        "muscle": muscle,
        "actual_sets_per_week": actual_sets,
        "status": status,
        "recommendation": recommendation,
        "landmarks": landmarks
    }
```

### 2. Volume Calculation Tool

```python
# tools.py (add to existing)

@mcp.tool()
async def calculate_weekly_volume(
    user_token: str,
    weeks: int = 4
) -> dict:
    """
    Calculate weekly training volume per muscle group.

    Args:
        user_token: User's JWT token
        weeks: Number of recent weeks to analyze (default 4)

    Returns:
        Volume per muscle group with status vs landmarks
    """
    db = get_db_client().with_user_auth(user_token)

    # Get recent performed sessions
    cutoff_date = datetime.now() - timedelta(weeks=weeks*7)

    # Query performed exercises with muscle group data
    # Note: Requires join with exercise metadata
    exercises = await db.query(
        'performed_exercise',
        select='exercise_id,sets,performed_session_id',
        filters={
            'performed_session_id.in': f'(select performed_session_id from performed_session where completed_at >= {cutoff_date.isoformat()})'
        }
    )

    # Aggregate by muscle group (simplified - actual implementation needs muscle mapping)
    volume_by_muscle = {}  # muscle -> total_sets

    # For each muscle, check against landmarks
    results = {}
    for muscle, total_sets in volume_by_muscle.items():
        avg_weekly_sets = total_sets / weeks
        results[muscle] = get_volume_status(avg_weekly_sets, muscle)

    return {
        "analysis_period_weeks": weeks,
        "muscle_volumes": results,
        "overall_status": _get_overall_volume_status(results)
    }


@mcp.tool()
async def suggest_deload(
    user_token: str,
    weeks_analyzed: int = 4
) -> dict:
    """
    Analyze if user needs a deload week.

    Indicators:
    - Any muscle group exceeding MRV
    - Multiple muscle groups at high volume
    - Declining performance trends

    Returns:
        Deload recommendation with reduced volume targets
    """
    volume_analysis = await calculate_weekly_volume(user_token, weeks_analyzed)

    # Check for deload indicators
    needs_deload = False
    reasons = []

    for muscle, data in volume_analysis["muscle_volumes"].items():
        if data["status"] == "excessive":
            needs_deload = True
            reasons.append(f"{muscle}: Exceeds MRV ({data['actual_sets_per_week']} > {data['landmarks']['MRV']} sets)")

    if needs_deload:
        return {
            "recommendation": "deload",
            "reasons": reasons,
            "deload_protocol": {
                "duration_weeks": 1,
                "volume_reduction": "50-60%",
                "intensity_maintenance": "Keep weights same, reduce sets/reps",
                "example": "If doing 4 sets of 10, do 2 sets of 6-8 at same weight"
            }
        }
    else:
        return {
            "recommendation": "no_deload_needed",
            "status": "Volume within healthy ranges",
            "continue_training": True
        }
```

### 3. User Plan Creation Tool

```python
# tools.py (add to existing)

@mcp.tool()
async def create_workout_plan(
    user_token: str,
    name: str,
    description: str,
    sessions: list[dict],
    duration_weeks: int = 6,
    based_on_plan_id: Optional[str] = None
) -> dict:
    """
    Create a new user workout plan.

    Args:
        user_token: User's JWT token
        name: Plan name (e.g., "4-Day Upper/Lower Split")
        description: Plan description
        sessions: List of session definitions
        duration_weeks: Plan duration (default 6 weeks)
        based_on_plan_id: Optional system plan to base this on

    Session format:
        {
            "name": "Upper A",
            "description": "Chest, shoulders, triceps focus",
            "exercises": [
                {
                    "base_exercise_name": "Bench Press",
                    "sets": 4,
                    "reps": 8,
                    "rest_seconds": 120
                },
                ...
            ]
        }

    Returns:
        Created user_plan_id and status
    """
    # Validate JWT and extract user_id
    claims = validate_token(user_token)
    user_id = claims['sub']

    db = get_db_client().with_user_auth(user_token)

    # Validate volume before creating plan
    total_volume_by_muscle = _calculate_plan_volume(sessions)
    for muscle, sets in total_volume_by_muscle.items():
        status = get_volume_status(sets, muscle)
        if status["status"] == "excessive":
            return {
                "error": "volume_validation_failed",
                "message": f"{muscle} exceeds MRV ({sets} sets vs {status['landmarks']['MRV']} max)",
                "suggestion": f"Reduce {muscle} volume to {status['landmarks']['MAV']} sets for optimal growth"
            }

    # Calculate start and end dates
    starts_at = datetime.now()
    ends_at = starts_at + timedelta(weeks=duration_weeks)

    # Create user_plan
    plan_result = await db.query(
        'user_plan',
        method='POST',  # INSERT
        data={
            "app_user_id": user_id,
            "name": name,
            "description": description,
            "based_on_plan_id": based_on_plan_id,
            "visibility": "private",
            "created_by": "ai",
            "starts_at": starts_at.isoformat(),
            "ends_at": ends_at.isoformat(),
            "is_active": True  # Automatically activate new plan
        }
    )

    user_plan_id = plan_result[0]['user_plan_id']

    # Create session schedules
    for session in sessions:
        session_result = await db.query(
            'session_schedule',
            method='POST',
            data={
                "user_plan_id": user_plan_id,
                "name": session["name"],
                "description": session.get("description", "")
            }
        )
        session_schedule_id = session_result[0]['session_schedule_id']

        # Create exercises for this session
        for exercise in session["exercises"]:
            # Look up base_exercise_id from name
            base_exercise = await db.query(
                'base_exercise',
                select='base_exercise_id',
                filters={'name': f'ilike.{exercise["base_exercise_name"]}'},
                limit=1
            )

            if not base_exercise:
                continue  # Skip unknown exercises

            await db.query(
                'exercise',
                method='POST',
                data={
                    "session_schedule_id": session_schedule_id,
                    "base_exercise_id": base_exercise[0]['base_exercise_id'],
                    "sets": exercise.get("sets", 3),
                    "reps": exercise.get("reps", 10),
                    "rest": f'{exercise.get("rest_seconds", 90)} seconds'
                }
            )

    return {
        "success": True,
        "user_plan_id": user_plan_id,
        "name": name,
        "duration_weeks": duration_weeks,
        "sessions_created": len(sessions),
        "starts_at": starts_at.isoformat(),
        "ends_at": ends_at.isoformat(),
        "volume_validation": "passed"
    }
```

### 4. Plan Management Tools

```python
@mcp.tool()
async def modify_user_plan(
    user_token: str,
    user_plan_id: str,
    updates: dict
) -> dict:
    """
    Modify an existing user plan.

    Updates can include:
    - name, description
    - duration (extends end date)
    - visibility (private/public)
    - is_active (activate/deactivate)
    """
    db = get_db_client().with_user_auth(user_token)

    # RLS ensures only owner can modify
    result = await db.query(
        f'user_plan?user_plan_id=eq.{user_plan_id}',
        method='PATCH',
        data=updates
    )

    return {"success": True, "updated": result}


@mcp.tool()
async def get_user_plans(
    user_token: str,
    include_inactive: bool = False
) -> list[dict]:
    """
    Get all plans for the authenticated user.

    Returns system plans + user's own plans.
    """
    db = get_db_client().with_user_auth(user_token)

    filters = {}
    if not include_inactive:
        filters['is_active'] = 'eq.true'

    # Use all_plans view
    plans = await db.query(
        'all_plans',
        filters=filters
    )

    return plans
```

### 5. Plan Templates

Provide templates based on common splits:

```python
# plan_templates.py

PLAN_TEMPLATES = {
    "upper_lower_4day": {
        "name": "4-Day Upper/Lower Split",
        "description": "Classic 4-day split for balanced development",
        "duration_weeks": 6,
        "sessions": [
            {
                "name": "Upper A",
                "description": "Chest, shoulders, triceps emphasis",
                "exercises": [
                    {"name": "Bench Press", "sets": 4, "reps": 8},
                    {"name": "Overhead Press", "sets": 3, "reps": 10},
                    {"name": "Incline Dumbbell Press", "sets": 3, "reps": 12},
                    {"name": "Lateral Raise", "sets": 3, "reps": 15},
                    {"name": "Tricep Pushdown", "sets": 3, "reps": 12},
                ]
            },
            {
                "name": "Lower A",
                "description": "Quad emphasis",
                "exercises": [
                    {"name": "Squat", "sets": 4, "reps": 8},
                    {"name": "Romanian Deadlift", "sets": 3, "reps": 10},
                    {"name": "Leg Press", "sets": 3, "reps": 12},
                    {"name": "Leg Curl", "sets": 3, "reps": 12},
                    {"name": "Calf Raise", "sets": 4, "reps": 15},
                ]
            },
            # ... Upper B, Lower B
        ]
    },

    "push_pull_legs": {
        "name": "6-Day Push/Pull/Legs",
        "description": "High frequency PPL split",
        # ...
    }
}

@mcp.tool()
async def get_plan_templates() -> dict:
    """Return available plan templates"""
    return {
        "templates": list(PLAN_TEMPLATES.keys()),
        "details": PLAN_TEMPLATES
    }

@mcp.tool()
async def create_plan_from_template(
    user_token: str,
    template_name: str,
    customizations: Optional[dict] = None
) -> dict:
    """
    Create user plan from template with optional customizations.

    Customizations can include:
    - Swap exercises
    - Adjust sets/reps
    - Change rest periods
    """
    template = PLAN_TEMPLATES.get(template_name)
    if not template:
        return {"error": f"Template '{template_name}' not found"}

    # Apply customizations if provided
    sessions = template["sessions"]
    if customizations:
        sessions = _apply_customizations(sessions, customizations)

    # Create the plan
    return await create_workout_plan(
        user_token=user_token,
        name=template["name"],
        description=template["description"],
        sessions=sessions,
        duration_weeks=template["duration_weeks"]
    )
```

## Testing Strategy

### 1. Unit Tests

```python
# tests/test_volume_landmarks.py
def test_volume_landmarks():
    # Test optimal volume
    status = get_volume_status(18, "chest")
    assert status["status"] == "optimal"

    # Test excessive volume
    status = get_volume_status(25, "chest")
    assert status["status"] == "excessive"
    assert "deload" in status["recommendation"].lower()
```

### 2. Integration Tests

```python
# tests/integration/test_plan_creation.py
async def test_create_plan_via_mcp():
    # Test full plan creation
    result = await create_workout_plan(
        user_token=test_token,
        name="Test Plan",
        sessions=[...]
    )

    assert result["success"]
    assert result["user_plan_id"]

    # Verify plan exists in database
    plans = await get_user_plans(test_token)
    assert any(p["name"] == "Test Plan" for p in plans)
```

### 3. Claude Desktop Testing

Real-world testing with AI:
1. "Create me a 4-day upper/lower split"
2. "Am I doing too much chest volume?"
3. "Modify my plan to add more back work"
4. "Do I need a deload week?"

## Documentation

### Volume Landmarks Guide

Add `docs/volume_landmarks.md`:
- Explanation of MV/MEV/MAV/MRV
- Per-muscle recommendations
- How to interpret volume analysis
- When to deload

### Plan Creation Guide

Add `docs/creating_plans.md`:
- How to ask AI to create plans
- Template options
- Customization examples
- Volume validation

## Acceptance Criteria

- [ ] `user_plan` schema implemented (from pre-req)
- [ ] Volume landmarks data defined for all major muscle groups
- [ ] Volume calculation tool working accurately
- [ ] Plan creation tool creates valid plans
- [ ] Plan modification tools working
- [ ] Plan templates available
- [ ] Volume validation prevents excessive programming
- [ ] Deload detection working
- [ ] Simple sharing (private/public) working
- [ ] All RLS policies enforce ownership
- [ ] Integration tests passing
- [ ] Claude Desktop can create plans via conversation
- [ ] Documentation complete

## Cost Estimate

- **Development**: $0 (using existing Fly.io deployment)
- **Additional Storage**: Negligible (user plans are small)
- **Total**: $0/month (remains on free tier)

## Future Enhancements (Post-Phase 3)

- Complex sharing (specific users, following)
- Plan version history
- Plan forking (duplicate others' public plans)
- Auto-progression (AI adjusts plan based on performance)
- Exercise substitution recommendations
- Volume periodization (undulating, linear)

## References

- [RP Volume Landmarks](https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth)
- [Dr. Mike Israetel MV/MEV/MAV/MRV](https://drmikeisraetel.com/dr-mike-israetel-wikipedia/dr-mike-israetel-mv-mev-mav-mrv-explained/)
- Pre-req: ISSUE_user_plan_schema.md
- Phase 2: ISSUE_phase2_http_oauth.md
- Epic: EPIC_mcp_integration.md

## Related Issues

- Depends on: Phase 2 #XXX
- Depends on: ISSUE_user_plan_schema #XXX
- Blocks: Phase 4 #XXX
