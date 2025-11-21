# Exercise Sets Migration - Testing & Analytics Enhancement Design

**Date:** 2025-11-21
**Status:** Design Phase - Brainstorming & Research Planning
**Context:** Exercise sets schema refactor from legacy to performed_exercise_set table

## Design Sessions

### Session 1: Testing Strategy & Edge Cases (2025-11-21)

**Participants:** User + Claude
**Skill Used:** superpowers:brainstorming

---

## Part 1: Migration Safety & Testing Strategy

### Critical Priorities (User Input)

**Top Priority: Data Loss Prevention (A)**
- Must ensure NO records are lost or incorrectly transformed
- Correct data > Complete migration (can always run additional passes)
- Conservative approach preferred

**Acceptable Trade-offs:**
- Partial migration is fine if all backfilled data is correct (D)
- Can write additional migrations to catch remaining records
- Rest interval data loss acceptable (secondary metadata)

### Backfill Strategy: Conservative Session-Level Exclusion

**Decision: Approach A - Conservative (Safest)**

```sql
-- Skip entire performed_session if ANY exercise in it has sets
WHERE NOT EXISTS (
    SELECT 1 FROM performed_exercise_set pes
    JOIN performed_exercise pe2 ON pes.performed_exercise_id = pe2.performed_exercise_id
    WHERE pe2.performed_session_id = pe.performed_session_id
)
```

**Rationale:**
- Prevents mixing pre-migration and post-migration data in same session
- Eliminates ambiguity about session state
- Safer for data integrity

**Edge Case Identified:**
- In-progress workouts: `performed_exercise` exists but `completed_at = NULL`
- Skipped exercises: Exercise record exists but wasn't actually performed
- Post-migration sessions: Any session with sets in new table should be excluded entirely

### Backfill Rules

#### Rule 1: completed_at Handling
```
IF performed_session.completed_at IS NOT NULL:
    → Backfill exercise (even if exercise.completed_at = NULL)
    → Rationale: Exercise is part of completed session
ELSE:
    → Skip (in-progress session)
```

#### Rule 2: NULL Weight Handling
```
weight = NULL:
    → Backfill with weight = 0 or NULL in sets
    → Rationale: Body weight exercises (push-ups, pull-ups, dips, etc.)
    → Data must be preserved, not discarded
```

#### Rule 3: Rest Array Mismatch
```
Source of truth: array_length(reps, 1) = number of sets

For each set index i:
    IF rest[i] exists:
        → Use rest[i]
    ELSE:
        → Use default interval '00:02:00'

Note: Rest field wasn't consistently used in legacy phase
    → Data quality is erratic
    → Data loss acceptable here (secondary metadata)
    → But preserve good data where available
```

### Test Coverage Requirements

**Priority 1: Data Loss Prevention**
- ✅ Standard completed exercises backfill correctly
- ✅ Varying reps preserved per-set
- ✅ NULL weight exercises backfilled (body weight)
- ✅ Empty/mismatched rest arrays handled gracefully
- ✅ Session-level exclusion when ANY sets exist
- ✅ Completed sessions with incomplete exercises handled
- ✅ In-progress sessions excluded from backfill

**Priority 2: Edge Cases**
- ✅ Skipped exercises (record exists, not performed)
- ✅ Mixed pre/post migration detection
- ✅ Partial session completions
- ✅ No duplicate backfill on re-run

**Priority 3: Data Consistency**
- ✅ Legacy vs new data produces identical stats
- ✅ View aggregations correct
- ✅ Function progression logic works

---

## Part 2: Analytics Enhancement Vision

### Three-Tier View Architecture

**Decision: Create three versions of exercise_stats view**

#### Legacy View (Deprecated)
- **Name:** `exercise_stats` (current)
- **Purpose:** Backward compatibility only
- **Data Model:** Original structure
- **Backing:** Still aggregates from performed_exercise_set (better data)
- **Status:** Deprecated, maintain until all consumers migrate

#### V2 View (Drop-in Replacement)
- **Name:** `exercise_stats_v2`
- **Purpose:** Same data model as legacy, better backing data
- **Data Model:** Identical to legacy (or add-only fields)
- **Migration:** Frontend can switch immediately without code changes
- **Features:**
  - More reliable data from sets table
  - Same column names/types as legacy
  - Optional: Add new fields (but keep old ones)

#### V3 View (Advanced Analytics)
- **Name:** `exercise_stats_v3` or `workout_analytics`
- **Purpose:** Best-in-class workout analytics
- **Data Model:** Completely redesigned
- **Features:** Advanced metrics (see below)
- **Migration:** Requires frontend updates, migrate over time
- **Vision:** Enable AI-powered insights via MCP integration

### Advanced Metrics for V3 (Research Required)

#### A. Granular Volume Tracking ✅ User Wants This

**Working Volume (Exclude Warm-ups)**
```sql
-- Example metric
working_volume_kg = SUM(weight * reps) / 1000
  FROM performed_exercise_set
  WHERE exercise_set_type != 'warm-up'
```

**Relative Intensity (% of 1RM)**
```sql
-- Example metric
relative_intensity = (set_weight / estimated_1rm) * 100
```

**Research Needed:**
- What's standard practice for calculating working volume?
- Should we exclude warm-ups only, or also cool-downs?
- How to handle super-sets in volume calculations?
- How to handle myo-reps in volume calculations?
- What about drop-sets - full volume or adjusted?

#### B. Progressive Overload Metrics ✅ User Wants This

**Week-over-Week Volume Delta**
```sql
-- Example metric
volume_delta_week = (this_week_volume - last_week_volume) / last_week_volume * 100
```

**Research Needed:**
- Standard time windows? (weekly, biweekly, monthly)
- How to handle deload weeks?
- How to handle missed sessions?
- How to normalize for different set/rep schemes?
- What about super-sets, myo-reps, warm-up sets in these calculations?
- Industry best practices for progressive overload tracking?

**Note:** User wants KG for universality (tonnage varies by country)

#### C. Set Type Awareness ✅ User Wants This

**Separate Stats by Set Type**
- Warm-up sets vs working sets
- Drop-set specific metrics
- Myo-rep metrics
- Super-set tracking

**Research Needed:**
- What metrics are specific to each set type?
- Drop-set volume calculations - special handling?
- Myo-rep effective reps calculations?
- Super-set pairing and sequencing analysis?

#### D. Time-Based Metrics (Mixed Interest)

**Rest Period Actuals vs Prescribed** ✅ User Interested
```sql
-- Example metric
rest_adherence = AVG(actual_rest / prescribed_rest) * 100
```

**Time Under Tension** ❓ User Skeptical
- User concern: Can this be calculated reliably?
- Research: What data would we need? Rep tempo tracking?

**Research Needed:**
- Can we calculate time under tension from available data?
- What's needed for accurate TUT tracking?
- Industry standards for rest period tracking?

#### E. Advanced Analytics (User's Ultimate Vision)

**Goal: "Best in class insights" - Most data-focused workout app**

**Desired Features:**
1. **Regression Analysis**
   - Trend lines for key metrics
   - Prediction of future performance
   - Statistical significance of progress

2. **Plateau Detection**
   - Automatic detection of training plateaus
   - Alerts when progress stalls
   - Deload recommendations?

3. **AI-Ready Data Model**
   - Structured for MCP integration (see .github/EPIC_mcp_integration.md)
   - Rich context for AI workout recommendations
   - Enable conversational workout insights

4. **Better Visualizations**
   - Enhanced graphs based on research
   - Industry-standard metrics
   - Actionable insights, not just numbers

**Research Needed:**
- Exercise science best practices for tracking progress
- Statistical methods for plateau detection
- What metrics do professional strength coaches track?
- What does research say about effective progress indicators?
- How do best-in-class apps handle this? (StrongLifts, Strong, etc.)

---

## Part 3: Additional Scope Identified

### Session Creation Functions Need Updates

**Issue:** `draft_session_exercises_v2` and related functions are "half done"

**Requirements:**
1. Update functions that CREATE sessions to use new sets table
2. Leverage RLS to supply `app_user_id` automatically
3. Ensure consistency with new data model

**Note:** This is separate from the migration but related work

---

## Next Steps: Research Phase

### Research Topics (Priority Order)

#### 1. Exercise Science - Progressive Overload Tracking
**Questions:**
- What metrics do strength coaches track?
- How is progressive overload measured scientifically?
- Time windows for progress assessment?
- Handling deload weeks and missed sessions?

**Sources to Consult:**
- Exercise science journals
- Professional strength coaching resources
- Existing workout tracking apps (best practices)
- Evidence-based training programs

#### 2. Volume Calculations - Set Type Considerations
**Questions:**
- How to calculate volume for super-sets?
- How to calculate volume for myo-reps?
- How to calculate volume for drop-sets?
- Should warm-ups be excluded from working volume?
- How to normalize different training styles?

**Sources to Consult:**
- Strength training research
- Bodybuilding/powerlifting standards
- Renaissance Periodization (Mike Israetel)
- Stronger by Science (Greg Nuckols)

#### 3. Plateau Detection - Statistical Methods
**Questions:**
- How to detect training plateaus algorithmically?
- Statistical tests for progress stagnation?
- False positive prevention?
- What's actionable once plateau detected?

**Sources to Consult:**
- Sports science research on training adaptation
- Time series analysis methods
- Existing app implementations

#### 4. Relative Intensity - 1RM Calculations
**Questions:**
- Best 1RM estimation formula? (Brzycki, Epley, others?)
- When is 1RM estimation unreliable?
- How to handle different rep ranges?
- %1RM zones for different training goals?

**Sources to Consult:**
- Strength training research
- Comparison of 1RM formulas
- Practical programming guidance

#### 5. Competitive Analysis
**Questions:**
- How do best-in-class apps handle analytics?
- What metrics do users find most valuable?
- What visualizations are most effective?
- What's missing in current solutions?

**Apps to Research:**
- Strong app
- StrongLifts 5x5
- Hevy
- JEFIT
- Fitbod

### Research Output Format

For each research topic, document:
1. **Findings:** What does research/best practice say?
2. **Recommendations:** What should we implement?
3. **Rationale:** Why this approach?
4. **Trade-offs:** What are we giving up?
5. **Implementation Notes:** Technical considerations

Save research to: `docs/research/2025-11-21-workout-analytics-research.md`

---

## Implementation Phases (Tentative)

### Phase 1: Migration Safety (Current Focus)
- ✅ Backfill migration with conservative session-level exclusion
- ✅ Updated views using sets table
- ✅ Updated functions using sets table
- 🔄 Comprehensive tests (in progress)
- ⏳ Update backfill logic based on finalized rules

### Phase 2: V2 Views (Backward Compatibility)
- Create `exercise_stats_v2` (drop-in replacement)
- Same data model, better backing data
- Deprecate legacy view
- Frontend can migrate without code changes

### Phase 3: Research & Design V3 Analytics
- Complete research phase
- Design V3 data model
- Spec out advanced metrics
- Plan AI/MCP integration points

### Phase 4: V3 Implementation
- Implement advanced analytics views
- Build supporting infrastructure
- Create new visualizations
- Frontend migration to V3

### Phase 5: Session Creation Updates
- Update session creation functions
- Leverage RLS properly
- Ensure consistency

---

## Design Questions Outstanding

### For User Review:

1. **Test Coverage:** Does the test priority list cover all critical scenarios?

2. **Backfill Rules:** Are the three rules (completed_at, weight, rest) complete and correct?

3. **Research Priorities:** Which research topics should I tackle first?

4. **Timeline:** Should all phases be in same PR or separate?

5. **V2 vs V3:** Should V2 be truly identical to legacy, or can we add optional fields?

---

## References

- Original migration files: `database/270-320_*.sql`
- MCP integration plans: `.github/EPIC_mcp_integration.md`
- Existing tests: `tests/database/test_sets_refactor_migration.py` (WIP)
- Superpowers skills: `/tmp/superpowers/skills/`

---

**Next Action:** Await user feedback on research priorities, then begin research phase using superpowers:brainstorming for each topic.
