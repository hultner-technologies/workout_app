# V3 Analytics Implementation Plan

**Date:** 2025-11-21
**Status:** Planning
**Spec:** [exercise-stats-v3-spec.md](../specs/exercise-stats-v3-spec.md)

---

## Goal

Implement V3 analytics views and schema changes to enable:
- Evidence-based volume landmarks (MEV/MAV/MRV)
- Plateau detection with 3-week threshold
- Muscle balance tracking (push/pull ratios, injury warnings)
- Advanced set type support (drop-sets, myo-reps, supersets)
- Future ML/prediction features

---

## Approach

**Phased implementation** with backward compatibility maintained throughout:

1. **Phase 0:** Schema updates (non-breaking additions)
2. **Phase 1:** Core materialized views (weekly volume aggregates)
3. **Phase 2:** Advanced analytics views (plateau, balance, landmarks)
4. **Phase 3:** Helper functions and triggers
5. **Phase 4:** V2 backward-compatible views
6. **Phase 5:** Testing and production deployment

---

## Phase 0: Schema Updates (Week 1)

**Goal:** Add new columns to existing tables without breaking changes

### Tasks

#### 0.1: Add columns to performed_exercise_set (2-3 hours)

**Migration:** `database/330_add_set_tracking_columns.sql`

```sql
-- Add columns for future tracking
ALTER TABLE performed_exercise_set
  ADD COLUMN estimated_rir INTEGER,
  ADD COLUMN rpe NUMERIC(3,1),
  ADD COLUMN superset_group_id UUID,
  ADD COLUMN effective_volume_kg NUMERIC(10,2),
  ADD COLUMN estimated_1rm_kg NUMERIC(10,2),
  ADD COLUMN relative_intensity NUMERIC(5,2);

-- Add comprehensive comments
COMMENT ON COLUMN performed_exercise_set.estimated_rir IS
  'Reps in reserve (0 = failure, 1-3 = optimal hypertrophy).
   NULLABLE - historical data will not have this field.';

COMMENT ON COLUMN performed_exercise_set.rpe IS
  'Rate of perceived exertion (1-10 scale). NULLABLE.';

COMMENT ON COLUMN performed_exercise_set.superset_group_id IS
  'Links sets performed as supersets. NULL for regular sets.';

COMMENT ON COLUMN performed_exercise_set.effective_volume_kg IS
  'Auto-calculated: volume adjusted for set type and RIR.';

COMMENT ON COLUMN performed_exercise_set.estimated_1rm_kg IS
  'Auto-calculated: 1RM estimate using adaptive formula.';

COMMENT ON COLUMN performed_exercise_set.relative_intensity IS
  'Auto-calculated: % of estimated 1RM.';
```

**Success criteria:**
- [ ] Migration runs successfully on dev database
- [ ] No existing queries broken
- [ ] Columns are NULL for all existing data
- [ ] Comments visible in database schema

**Tests:**
```sql
-- Test that columns exist and are nullable
SELECT
  column_name,
  is_nullable,
  data_type
FROM information_schema.columns
WHERE table_name = 'performed_exercise_set'
  AND column_name IN ('estimated_rir', 'rpe', 'effective_volume_kg');
```

#### 0.2: Add training_preferences to app_user (1-2 hours)

**Migration:** `database/335_add_user_preferences.sql`

```sql
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
  'User preferences for analytics, plateau detection, and MCP data sharing';
```

**Success criteria:**
- [ ] All existing users get default preferences
- [ ] JSONB structure validated
- [ ] Can query preferences with JSON operators

**Tests:**
```sql
-- Verify default preferences applied
SELECT COUNT(*) FROM app_user
WHERE training_preferences->'volume_landmarks'->>'enabled' = 'true';
```

### Phase 0 Deliverables

- ✅ Two migrations (330, 335)
- ✅ Schema changes deployed to dev
- ✅ All tests passing
- ✅ Zero downtime

**Total effort:** 3-5 hours
**Dependencies:** None
**Risk:** Low (additive changes only)

---

## Phase 1: Core Materialized Views (Week 2-3)

**Goal:** Build foundation views for all analytics

### Tasks

#### 1.1: weekly_exercise_volume materialized view (6-8 hours)

**Migration:** `database/340_weekly_exercise_volume.sql`

**Purpose:** Primary aggregation of volume per exercise per week

Key features:
- Exclude warm-up sets from working volume
- Calculate total_volume_kg, effective_volume_kg
- Aggregate set type distribution
- RIR statistics (when available)

**Success criteria:**
- [ ] View created successfully
- [ ] Data matches manual calculations (spot check 10 users)
- [ ] Query performance < 500ms for single user
- [ ] Handles NULL RIR gracefully

**Tests:**
```python
# tests/database/test_weekly_exercise_volume.py

def test_excludes_warm_up_sets(db):
    """Verify warm-up sets excluded from working_sets count"""
    # Setup: Create session with warm-up and regular sets
    # Assert: working_sets count excludes warm-ups

def test_aggregates_volume_correctly(db):
    """Verify volume calculations match manual calculation"""
    # Setup: Known sets with specific weight/reps
    # Assert: total_volume_kg matches expected

def test_handles_null_rir(db):
    """Verify view works when RIR is NULL"""
    # Setup: Sets without RIR data
    # Assert: View still returns results, avg_rir is NULL
```

#### 1.2: weekly_muscle_volume materialized view (6-8 hours)

**Migration:** `database/345_weekly_muscle_volume.sql`

**Purpose:** Aggregate volume per muscle group using primary/secondary attribution

Key features:
- Primary muscles: 100% volume attribution
- Secondary muscles: 50% volume attribution
- Exercise selection quality metrics
- Force type distribution (push/pull/static)

**Success criteria:**
- [ ] Correctly attributes volume to primary/secondary muscles
- [ ] Joins with exercise metadata working
- [ ] Performance < 1s for single user
- [ ] Matches research methodology (Menno Henselmans)

**Tests:**
```python
def test_primary_muscle_attribution(db):
    """Primary muscles get 100% volume credit"""
    # Setup: Bench press (chest primary)
    # Assert: Chest gets 100% of volume

def test_secondary_muscle_attribution(db):
    """Secondary muscles get 50% volume credit"""
    # Setup: Bench press (triceps secondary)
    # Assert: Triceps gets 50% of volume

def test_force_type_distribution(db):
    """Correctly categorizes push/pull/static"""
    # Setup: Mix of push/pull exercises
    # Assert: Correct distribution calculated
```

#### 1.3: Refresh strategy (2-3 hours)

**Migration:** `database/350_materialized_view_refresh.sql`

```sql
-- Refresh weekly views after session completion
CREATE OR REPLACE FUNCTION refresh_weekly_analytics()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.completed_at IS NOT NULL AND OLD.completed_at IS NULL THEN
    -- Session just completed
    REFRESH MATERIALIZED VIEW CONCURRENTLY weekly_exercise_volume;
    REFRESH MATERIALIZED VIEW CONCURRENTLY weekly_muscle_volume;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_refresh_weekly_analytics
  AFTER UPDATE OF completed_at ON performed_session
  FOR EACH ROW
  EXECUTE FUNCTION refresh_weekly_analytics();
```

**Success criteria:**
- [ ] Views refresh automatically on session completion
- [ ] CONCURRENTLY flag prevents blocking
- [ ] Refresh completes in < 10s for typical user

**Tests:**
```python
def test_auto_refresh_on_completion(db):
    """Views refresh when session marked complete"""
    # Setup: Create incomplete session
    # Complete the session
    # Assert: Views contain new data
```

### Phase 1 Deliverables

- ✅ weekly_exercise_volume materialized view
- ✅ weekly_muscle_volume materialized view
- ✅ Auto-refresh trigger
- ✅ Comprehensive test suite (6+ tests)
- ✅ Performance benchmarks documented

**Total effort:** 14-19 hours
**Dependencies:** Phase 0 complete
**Risk:** Medium (complex queries, performance concerns)

---

## Phase 2: Advanced Analytics Views (Week 4-5)

**Goal:** Implement plateau detection, volume landmarks, muscle balance

### Tasks

#### 2.1: volume_landmarks_status view (4-6 hours)

**Migration:** `database/360_volume_landmarks_status.sql`

**Purpose:** Classify current volume as MEV/MAV/MRV with recommendations

Key features:
- Default volume landmarks per muscle (Mike Israetel research)
- User-specific overrides from training_preferences
- Progress toward next landmark
- Actionable recommendations

**Success criteria:**
- [ ] Correctly classifies volume status
- [ ] Recommendations make sense
- [ ] Handles user overrides
- [ ] Performance < 200ms

**Tests:**
```python
def test_below_mev_classification(db):
    """User with <MEV sets gets correct status"""
    # Setup: User with 4 sets chest (MEV = 6)
    # Assert: status = 'below_mev'

def test_optimal_classification(db):
    """User in MAV range gets optimal status"""
    # Setup: User with 14 sets chest (MAV = 10-22)
    # Assert: status = 'optimal'

def test_custom_landmarks(db):
    """User custom MEV/MAV/MRV respected"""
    # Setup: User sets custom MEV = 8
    # Assert: Classification uses custom value
```

#### 2.2: plateau_detection view (6-8 hours)

**Migration:** `database/365_plateau_detection.sql`

**Purpose:** Detect training plateaus using statistical methods

Key features:
- 4-week moving averages
- Linear regression (6-week window)
- Week-over-week change detection
- Plateau score (0-1)
- Status: confirmed_plateau, potential_plateau, progressing

**Success criteria:**
- [ ] Detects plateaus accurately (manual validation)
- [ ] 3-week stagnation threshold implemented
- [ ] Recommendations appropriate
- [ ] Performance < 300ms

**Tests:**
```python
def test_detects_3week_plateau(db):
    """Confirms plateau after 3 weeks <2% change"""
    # Setup: 3 weeks with 0.5% volume change
    # Assert: status = 'confirmed_plateau'

def test_progressing_status(db):
    """User making progress gets correct status"""
    # Setup: Consistent 3% weekly increase
    # Assert: status = 'progressing'

def test_plateau_score_calculation(db):
    """Plateau score calculated correctly"""
    # Setup: Known stagnation pattern
    # Assert: score matches expected formula
```

#### 2.3: muscle_balance_ratios view (4-6 hours)

**Migration:** `database/370_muscle_balance_ratios.sql`

**Purpose:** Track push/pull, quad/hamstring ratios with injury warnings

Key features:
- Push/pull ratio (target: 0.8-1.2)
- Quad/hamstring ratio (target: 0.6-1.0, <0.6 = ACL risk)
- Chest/back ratio
- Balance score (0-100)
- Injury risk warnings

**Success criteria:**
- [ ] Ratios calculated correctly
- [ ] Warnings trigger at correct thresholds
- [ ] Recommendations actionable
- [ ] Performance < 200ms

**Tests:**
```python
def test_balanced_push_pull(db):
    """Balanced training gets good status"""
    # Setup: 12 push sets, 11 pull sets
    # Assert: status = 'balanced'

def test_quad_dominant_warning(db):
    """High Q/H ratio triggers warning"""
    # Setup: 20 quad sets, 8 hamstring sets
    # Assert: status = 'quad_dominant', warning shown

def test_acl_risk_detection(db):
    """Very high Q/H ratio flags ACL risk"""
    # Setup: Q/H ratio > 2.0
    # Assert: severity = 'high_injury_risk'
```

### Phase 2 Deliverables

- ✅ volume_landmarks_status view
- ✅ plateau_detection view
- ✅ muscle_balance_ratios view
- ✅ Test suite (9+ tests)
- ✅ Documentation for each view

**Total effort:** 14-20 hours
**Dependencies:** Phase 1 complete
**Risk:** Medium (statistical methods, accuracy validation)

---

## Phase 3: Helper Functions & Triggers (Week 6)

**Goal:** Auto-calculate derived metrics

### Tasks

#### 3.1: calculate_effective_volume function (3-4 hours)

**Migration:** `database/380_calculate_effective_volume.sql`

Key features:
- Handles all set types
- RIR adjustment when available
- Warm-ups return 0
- NULL-safe for historical data

**Success criteria:**
- [ ] All set types handled correctly
- [ ] RIR multipliers match research
- [ ] Performance < 1ms per call

**Tests:**
```python
def test_regular_set_volume(db):
    """Regular set: simple weight × reps"""
    result = calculate_effective_volume('regular', 100000, 10, None)
    assert result == 1000.0  # 100kg × 10 reps

def test_rir_adjustment(db):
    """RIR adjusts volume correctly"""
    # 0-3 RIR: 1.0x
    # 4 RIR: 0.9x
    # 5 RIR: 0.8x
    result = calculate_effective_volume('regular', 100000, 10, 4)
    assert result == 900.0  # 1000kg × 0.9

def test_warmup_excluded(db):
    """Warm-up sets return 0"""
    result = calculate_effective_volume('warm-up', 50000, 5, None)
    assert result == 0
```

#### 3.2: estimate_1rm_adaptive function (3-4 hours)

**Migration:** `database/385_estimate_1rm_adaptive.sql`

Key features:
- Adaptive formula selection by rep range
- Epley (1-5 reps), Brzycki (6-10), Mayhew (11-15)
- Returns NULL for >15 reps (unreliable)

**Success criteria:**
- [ ] Correct formula for each rep range
- [ ] Matches research accuracy benchmarks
- [ ] Performance < 1ms per call

**Tests:**
```python
def test_epley_low_reps(db):
    """1-5 reps uses Epley formula"""
    result = estimate_1rm_adaptive(100000, 3)
    expected = 100 * (1 + 0.0333 * 3)
    assert abs(result - expected) < 0.1

def test_brzycki_moderate_reps(db):
    """6-10 reps uses Brzycki formula"""
    result = estimate_1rm_adaptive(100000, 8)
    expected = 100 * (36 / (37 - 8))
    assert abs(result - expected) < 0.1

def test_high_reps_returns_null(db):
    """>15 reps returns NULL (unreliable)"""
    result = estimate_1rm_adaptive(100000, 20)
    assert result is None
```

#### 3.3: Auto-update trigger (2-3 hours)

**Migration:** `database/390_auto_update_set_calculations.sql`

**Purpose:** Auto-calculate effective_volume_kg, estimated_1rm_kg, relative_intensity

**Success criteria:**
- [ ] Trigger fires on INSERT/UPDATE
- [ ] All calculated fields updated
- [ ] NULL-safe for historical data
- [ ] No performance impact on inserts

**Tests:**
```python
def test_auto_calculates_on_insert(db):
    """New set gets calculated fields"""
    # Insert set with weight=100kg, reps=10
    # Assert: effective_volume_kg = 1000.0
    # Assert: estimated_1rm_kg calculated
    # Assert: relative_intensity calculated

def test_handles_null_rir(db):
    """Historical data (NULL RIR) still calculated"""
    # Insert set without RIR
    # Assert: effective_volume_kg uses 1.0x multiplier
```

### Phase 3 Deliverables

- ✅ calculate_effective_volume function
- ✅ estimate_1rm_adaptive function
- ✅ Auto-update trigger
- ✅ Test suite (8+ tests)
- ✅ Performance benchmarks

**Total effort:** 8-11 hours
**Dependencies:** Phase 0 complete
**Risk:** Low (well-defined functions)

---

## Phase 4: V2 Backward-Compatible Views (Week 7)

**Goal:** Maintain API compatibility while using new data model

### Tasks

#### 4.1: exercise_stats_v2 view (4-6 hours)

**Migration:** `database/400_exercise_stats_v2.sql`

**Purpose:** Drop-in replacement for exercise_stats using sets table

Key differences from legacy:
- Uses performed_exercise_set table (not legacy weight/reps fields)
- Aggregates from sets table
- Same schema as original view

**Success criteria:**
- [ ] Same columns as exercise_stats
- [ ] API compatibility maintained
- [ ] Performance similar or better
- [ ] Deprecation warning added

**Tests:**
```python
def test_schema_compatibility(db):
    """v2 view has same columns as legacy"""
    legacy_columns = get_view_columns('exercise_stats')
    v2_columns = get_view_columns('exercise_stats_v2')
    assert legacy_columns == v2_columns

def test_data_equivalence(db):
    """v2 data matches legacy (post-migration)"""
    # For exercises with migrated data
    # Assert: v2 matches legacy values
```

#### 4.2: next_exercise_progression_v2 view (3-4 hours)

**Migration:** `database/405_next_exercise_progression_v2.sql`

**Purpose:** Updated progression logic using sets table

**Success criteria:**
- [ ] Progression logic uses MIN(reps) from sets
- [ ] API compatibility maintained
- [ ] Performance acceptable

**Tests:**
```python
def test_progression_logic(db):
    """Successful progression detected correctly"""
    # Setup: Exercise with increasing reps
    # Assert: successful = true when reps >= limit
```

### Phase 4 Deliverables

- ✅ exercise_stats_v2 view
- ✅ next_exercise_progression_v2 view
- ✅ Test suite (4+ tests)
- ✅ Migration guide for API consumers

**Total effort:** 7-10 hours
**Dependencies:** Phase 1 complete
**Risk:** Low (maintaining compatibility)

---

## Phase 5: Testing & Production Deployment (Week 8)

**Goal:** Validate everything before production

### Tasks

#### 5.1: Integration testing (8-10 hours)

**Areas to test:**
- [ ] End-to-end: Session creation → View updates → API responses
- [ ] Performance: 1000 users, 52 weeks data
- [ ] Edge cases: Empty data, single session, extreme values
- [ ] Concurrent access: Multiple users updating simultaneously

**Load testing:**
```python
# tests/load/test_view_performance.py

def test_weekly_volume_performance(db):
    """weekly_exercise_volume query under load"""
    # Setup: 1000 users, 52 weeks each
    # Run: SELECT * FROM weekly_exercise_volume WHERE user_id = ...
    # Assert: p95 latency < 500ms

def test_concurrent_refresh(db):
    """Multiple simultaneous view refreshes"""
    # Setup: 10 users completing sessions simultaneously
    # Assert: No deadlocks, all refreshes complete
```

#### 5.2: Migration testing (4-6 hours)

**Test migration path:**
1. Restore production backup to dev
2. Run all migrations (330-405)
3. Verify data integrity
4. Performance benchmarks

**Checklist:**
- [ ] All migrations run successfully
- [ ] No data loss
- [ ] Performance acceptable (< 2x slower max)
- [ ] Rollback plan tested

#### 5.3: Production deployment (2-4 hours)

**Deployment steps:**
1. [ ] Maintenance window scheduled
2. [ ] Database backup created
3. [ ] Migrations run (330-405)
4. [ ] Smoke tests passed
5. [ ] Monitoring confirms health
6. [ ] Rollback plan ready

**Monitoring:**
- View refresh times
- Query latencies (p50, p95, p99)
- Error rates
- User-facing API response times

### Phase 5 Deliverables

- ✅ Full integration test suite
- ✅ Load test results
- ✅ Production deployment checklist
- ✅ Monitoring dashboards
- ✅ Rollback plan documented

**Total effort:** 14-20 hours
**Dependencies:** Phases 0-4 complete
**Risk:** Medium (production deployment always has risk)

---

## Overall Timeline

### Summary

| Phase | Duration | Effort | Dependencies | Risk |
|-------|----------|--------|--------------|------|
| Phase 0: Schema | Week 1 | 3-5h | None | Low |
| Phase 1: Core Views | Week 2-3 | 14-19h | Phase 0 | Medium |
| Phase 2: Analytics | Week 4-5 | 14-20h | Phase 1 | Medium |
| Phase 3: Functions | Week 6 | 8-11h | Phase 0 | Low |
| Phase 4: V2 Views | Week 7 | 7-10h | Phase 1 | Low |
| Phase 5: Testing & Deploy | Week 8 | 14-20h | All | Medium |

**Total:** 8 weeks, 60-85 hours

### Milestones

**Week 1:** Schema updates deployed to dev
**Week 3:** Core materialized views working
**Week 5:** Advanced analytics complete
**Week 6:** Auto-calculations functional
**Week 7:** Backward compatibility maintained
**Week 8:** Production deployment ✅

---

## Success Criteria

### Technical

- [ ] All migrations (330-405) deployed successfully
- [ ] Zero data loss during migration
- [ ] API backward compatibility maintained
- [ ] Query performance targets met:
  - weekly_exercise_volume: < 500ms (p95)
  - weekly_muscle_volume: < 1s (p95)
  - Advanced analytics views: < 300ms (p95)
- [ ] Auto-refresh completes in < 10s

### Product

- [ ] Volume landmarks visible to users
- [ ] Plateau detection alerts working
- [ ] Muscle balance warnings showing
- [ ] V2 APIs functioning identically to legacy
- [ ] No user-reported bugs for 2 weeks

### Business

- [ ] Foundation for ML features complete
- [ ] Competitive advantage validated (first app with MEV/MAV/MRV)
- [ ] Documentation complete for engineering team
- [ ] Ready for frontend integration

---

## Risks & Mitigation

### Technical Risks

**Risk: View refresh too slow**
- **Impact:** Users see stale data
- **Mitigation:** Use CONCURRENTLY, optimize queries, consider partial refreshes
- **Fallback:** Refresh nightly instead of real-time

**Risk: Query performance degrades with scale**
- **Impact:** Slow API responses
- **Mitigation:** Load testing with realistic data, add indexes proactively
- **Fallback:** Implement caching layer

**Risk: Statistical methods produce false positives**
- **Impact:** Incorrect plateau/imbalance warnings
- **Mitigation:** Validate against manual analysis, tune thresholds with real users
- **Fallback:** Make warnings opt-in initially

### Product Risks

**Risk: Users don't understand analytics**
- **Impact:** Low engagement with features
- **Mitigation:** Clear explanations, tooltips, educational content
- **Fallback:** Simplify to essential metrics only

**Risk: Recommendations conflict with user goals**
- **Impact:** User frustration, feature disabled
- **Mitigation:** User preference controls, conservative thresholds
- **Fallback:** Make all recommendations opt-in

---

## Dependencies

### External

- [ ] V3 spec finalized (exercise-stats-v3-spec.md) ✅
- [ ] Research complete (Phase 2 docs) ✅
- [ ] Database access (dev, staging, prod)
- [ ] CI/CD pipeline for migrations

### Internal

- [ ] Phase 1 migration completed (sets table migration) ✅
- [ ] Test database with realistic data
- [ ] Team capacity for 60-85 hours over 8 weeks

---

## Open Questions

1. **Performance:** Should we use Redis caching for analytics queries? Or is PostgreSQL materialized views sufficient?

2. **Refresh frequency:** Real-time refresh on session completion vs nightly batch?

3. **User preferences:** Should volume landmarks be user-configurable from day 1, or add later?

4. **API versioning:** Launch V3 APIs alongside V2, or just V2 (which uses V3 under the hood)?

5. **Feature flags:** Should advanced analytics be behind feature flags initially?

---

## Next Steps

1. **Review this plan** with team
2. **Set up dev environment** (database, test data)
3. **Create project board** with tasks from this plan
4. **Start Phase 0** (schema updates)
5. **Schedule weekly check-ins** to track progress

---

**Plan Status:** Ready for Review
**Next Action:** Team planning session to finalize approach
