# Quick Research Findings - Exercise Analytics Basics

**Date:** 2025-11-21
**Purpose:** Quick targeted research for Phase 1 migration decisions
**Scope:** Basic principles only - comprehensive research in Phase 2

---

## 1. Working Volume - Warm-up Set Handling

### Key Finding: Warm-ups Should Be Excluded

**Consensus:** Only working sets count toward training volume

**Rationale:**
- Warm-up sets have very low relative volume
- They don't create sufficient stimulus for growth/strength gains
- Purpose is preparation, not training adaptation

### What Qualifies as a "Working Set"?

**Criteria:**
1. Within ~3 reps of failure, OR
2. Above 85-90% of working weight

**Warm-up Definition (2024 Research):**
- 1-2 sets with submaximal load
- 30-50% of one repetition maximum
- Purpose: prepare body, not create training stimulus

### Implementation Decision for Views

```sql
-- V2/V3 views should calculate:
working_volume_kg = SUM(weight * reps) / 1000
  FROM performed_exercise_set
  WHERE exercise_set_type != 'warm-up'  -- Exclude warm-ups

total_volume_kg = SUM(weight * reps) / 1000
  FROM performed_exercise_set
  -- All sets (for completeness)
```

**For V2 (backward compatible):**
- Keep existing `volume_kg` (all sets for compatibility)
- Add optional `working_volume_kg` field

**For V3 (advanced):**
- Default to `working_volume_kg`
- Provide both for comparison/analysis

---

## 2. Progressive Overload Tracking

### Key Metrics to Track

**Essential:**
1. Volume load: `sets × reps × weight`
2. Week-over-week volume change
3. Per-exercise progression

**Optional but useful:**
- RPE (Rate of Perceived Exertion) for main lifts
- Proximity to failure

### Volume Load Calculation

```
Training Volume = sets × reps × weight
Example: 3 sets × 10 reps × 100kg = 3,000kg volume
```

### Safe Progression Guidelines

**Week-over-week increases:**
- Conservative: 2-5% per week
- Maximum: 10% per week
- Exceeding 10%: Risk of overtraining

**Implementation:**
```sql
volume_delta_week =
  (this_week_volume - last_week_volume) / last_week_volume * 100

-- Flag if > 10%: potential overtraining risk
-- Flag if < 0% for 3+ weeks: potential plateau
```

### Why Track Volume vs Individual Components?

**Volume encompasses:**
- Intensity (weight)
- Frequency (sessions)
- Sets
- Reps

**Easier and more beneficial** to track aggregate volume than individual factors.

**Note:** Also called "tonnage" but KG is more universal (user preference)

### Tracking Importance

**Critical finding:** Without tracking, progressive overload is difficult
- Need record of previous metrics to increase intensity
- Can't identify plateaus without historical data
- Essential for evidence-based training decisions

---

## 3. Set Type Volume Calculations

### Drop Sets

**Research findings:**
- Produce similar hypertrophy to traditional training
- Take 50-66% less time (time efficiency)
- May compromise strength gains slightly
- Study: Drop sets → 2x triceps growth vs normal sets (6 weeks)

**Volume equivalence:**
- Drop sets ≈ 3 normal sets in terms of stress/stimulus

**Implementation consideration:**
```sql
-- For V3 analytics, may want to weight drop-sets differently
effective_volume = CASE
  WHEN exercise_set_type = 'drop-set' THEN volume * 1.5
  ELSE volume
END
```

### Myo-Reps

**Protocol:**
- Activation set: 10-20 reps (0-3 reps from failure)
- Mini-sets: 5 reps with 20 sec rest
- Continue until only 3 reps possible
- Total: ~3-5 myo-rep sets

**Characteristics:**
- High time efficiency
- Increases metabolic stress
- Better for strength-endurance than max strength
- Substantial volume in short period

**Volume equivalence:**
- Myo-reps ≈ 3 normal sets in terms of stress

**Implementation note:**
- Parent-child relationship in our schema supports this
- Can aggregate myo-rep mini-sets for analysis

### Rest-Pause Sets

**Finding:** Rest-pause and drop-set training elicit similar strength and hypertrophy adaptations compared with traditional sets

### General Principle

**Intensity techniques (drop-sets, myo-reps, rest-pause):**
- ~3× normal set equivalent stress
- Time-efficient alternatives
- May increase fatigue
- Trade-off: efficiency vs max strength development

---

## Immediate Implementation Decisions

### For Phase 1 (Current Migration)

**V2 Views (Backward Compatible):**
```sql
CREATE OR REPLACE VIEW exercise_stats_v2 AS
SELECT
  -- Existing fields (compatible)
  weight,
  reps,
  brzycki_1_rm_max,
  volume_kg,  -- Keep for compatibility (all sets)

  -- NEW: Add working volume (excludes warm-ups)
  working_volume_kg,  -- Only working sets

  -- Everything else same as legacy
  ...
FROM ...
```

**Backfill Migration:**
- Mark all legacy sets as 'regular' (no warm-up distinction in old data)
- Volume calculations will include all sets initially
- Future workouts can differentiate warm-ups

### For Phase 2 (Deep Research & V3)

**Research further:**
- Optimal plateau detection algorithms
- Statistical significance of volume changes
- Best practices for deload week handling
- How to handle missed sessions in trends
- Advanced relative intensity calculations
- Competitive analysis of Strong/Hevy/JEFIT
- AI/MCP integration patterns

**V3 Advanced Features:**
- Working volume as default
- Progressive overload indicators
- Plateau detection alerts
- Set-type specific analytics
- Trend analysis and predictions

---

## Sources

**Working Volume:**
- Simple Solutions Fitness: Training Volume
- Juggernaut Training Systems: Understanding Volume
- Hevy App: Warm Up Sets
- 2024 ScienceDirect study on warm-up protocols

**Progressive Overload:**
- Hevy: Progressive Overload Guide
- NCBI PMC: Progression of volume load and muscular adaptation
- Biolayne: Three Important Metrics for Progressive Overload
- JEFIT: Science Behind Progressive Overload

**Set Types:**
- NCBI PMC: Drop Sets Meta-analysis (2023)
- Barbell Medicine: Myo-Reps
- Stronger by Science: New Approach to Training Volume
- ResearchGate: Rest-pause and drop-set comparative study

---

## Next Steps

1. ✅ Quick research complete
2. ⏳ Update backfill migration with conservative rules
3. ⏳ Write comprehensive tests (TDD)
4. ⏳ Implement V2 views (drop-in replacement)
5. ⏳ Verify CI/CD
6. ⏳ Merge Phase 1
7. ⏳ Phase 2: Deep research (4-6 hours)
8. ⏳ Phase 2: Design & implement V3 analytics

---

**Research Time:** 30 minutes
**Next:** Implementation Phase 1
