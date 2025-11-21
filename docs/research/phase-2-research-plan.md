# Phase 2: Deep Research Plan Summary

**Purpose:** Design world-class workout analytics backed by exercise science research
**Timeline:** 4-6 hours of focused research
**Output:** Evidence-based V3 analytics specification

---

## Research Areas

### 1. Exercise Science Fundamentals (90 minutes)

**Progressive Overload Principles:**
- Scientific definition and measurement
- Time windows for assessment (weekly, monthly, mesocycle)
- Deload week handling and periodization
- Missed session compensation strategies
- Plateau detection thresholds

**Volume Metrics:**
- Working volume calculations (exclude warm-ups confirmed ✓)
- Hard set vs junk volume distinction
- Stimulus-to-fatigue ratio concepts
- Effective reps theory (Mike Israetel)
- Minimum effective volume (MEV)
- Maximum recoverable volume (MRV)

**Sources:**
- Renaissance Periodization (Mike Israetel)
- Stronger by Science (Greg Nuckols)
- Exercise science journals (PubMed)
- Evidence-based training programs

---

### 2. Set Type Volume Calculations (60 minutes)

**Advanced Set Types:**
- Super-sets: Volume counting, rest period handling
- Myo-reps: Effective volume equivalence
- Drop-sets: Fatigue-adjusted volume (research found ≈3 normal sets)
- Pyramid sets: Progressive overload implications
- Warm-up sets: Exclusion confirmed ✓, but threshold definitions

**Muscle Group Considerations:**
- Primary vs secondary muscle activation
- Volume distribution across muscle groups
- Push/pull/legs split analytics
- Compound vs isolation exercise ratios
- Muscle imbalance detection algorithms

**Data Model Integration:**
- How to leverage `base_exercise_primary_muscle` junction table
- How to leverage `base_exercise_secondary_muscle` junction table
- Aggregate volume per muscle group
- Force type analytics (push/pull/static)
- Equipment-specific volume tracking

---

### 3. Relative Intensity & 1RM Calculations (45 minutes)

**1RM Estimation Formulas:**
- Brzycki (currently used - verify if optimal)
- Epley
- Lombardi
- O'Conner
- Wathan
- Comparison and accuracy by rep range

**Intensity Zones:**
- % 1RM zones for different training goals
- Hypertrophy range (typically 60-85% 1RM)
- Strength range (typically 85-95% 1RM)
- Power range considerations
- Reliability thresholds (when is estimation unreliable?)

**Application:**
- Per-set relative intensity tracking
- Training distribution across zones
- Optimal intensity for different muscle groups

---

### 4. Plateau Detection & Progress Tracking (60 minutes)

**Statistical Methods:**
- Time series analysis for workout data
- Moving averages and trend detection
- Regression analysis for progress prediction
- Statistical significance testing
- False positive prevention strategies

**Plateau Criteria:**
- Volume stagnation thresholds
- Weight stagnation thresholds
- Combined metrics approach
- Time window considerations
- Contextual factors (deloads, injuries, life stress)

**Actionable Recommendations:**
- When to deload
- When to change program
- When to adjust volume
- When to modify exercise selection

**Advanced Metrics:**
- Week-over-week volume delta (confirmed target ✓)
- Rate of progress (velocity of improvement)
- Training age consideration
- Diminishing returns detection

---

### 5. Muscle-Specific Analytics (45 minutes)

**Leveraging Rich Metadata:**
- Volume per muscle group calculations
- Primary vs secondary muscle volume distinction
- Muscle balance ratio calculations
- Weak point identification algorithms
- Push/pull ratio tracking

**Training Split Analysis:**
- Push/pull/legs volume distribution
- Upper/lower split analytics
- Full body workout metrics
- Frequency per muscle group

**Exercise Selection Insights:**
- Compound vs isolation ratios
- Equipment utilization patterns
- Exercise variety metrics
- Movement pattern distribution

---

### 6. Competitive Analysis (90 minutes)

**Apps to Analyze:**
1. **Strong** - Market leader features
2. **Hevy** - Social features and analytics
3. **JEFIT** - Exercise database and tracking
4. **StrongLifts 5x5** - Progressive overload focus
5. **Fitbod** - AI-powered recommendations

**Analysis Focus:**
- What metrics do they track?
- What visualizations do they provide?
- What's missing/can be improved?
- What do user reviews praise/complain about?
- How do they handle plateau detection?
- How do they present progressive overload?

**Unique Value Propositions:**
- What can we do better with our rich metadata?
- What insights are competitors missing?
- How can MCP integration add unique value?
- What makes "most data-focused app" different?

---

### 7. AI/MCP Integration Patterns (45 minutes)

**Context from Codebase:**
- Review `.github/EPIC_mcp_integration.md`
- Understand MCP server architecture plans
- Identify data access patterns needed

**AI-Ready Analytics:**
- What context does AI need for workout recommendations?
- What format for conversational insights?
- How to structure data for LLM consumption?
- Real-time vs historical data balance

**Use Cases:**
- "Why am I plateauing on bench press?"
- "Design a program for my weak points"
- "How's my push/pull balance?"
- "Am I recovering adequately?"
- "Suggest deload timing"

---

## Research Output Format

For each topic, document:

### Findings
- Key research discoveries
- Scientific consensus
- Relevant formulas/algorithms
- Industry best practices

### Recommendations
- What metrics to implement
- How to calculate them
- Thresholds and parameters
- Display/visualization approach

### Rationale
- Why this approach?
- What evidence supports it?
- What alternatives were considered?
- What trade-offs were made?

### Implementation Notes
- Data model considerations
- View structure implications
- Performance considerations
- Frontend impact

---

## Deliverables

1. **Research Document** (`docs/research/2025-11-21-workout-analytics-research.md`)
   - All findings organized by topic
   - Citations and sources
   - Recommendations with rationale

2. **V3 Analytics Specification** (`docs/specs/exercise-stats-v3-spec.md`)
   - Complete view schema
   - All metrics with formulas
   - Sample queries
   - Integration points

3. **Updated Design Doc** (append to `docs/plans/2025-11-21-sets-migration-analytics-design.md`)
   - Finalized V3 features
   - Implementation roadmap
   - Testing strategy

---

## Execution Strategy

**Use Subagent for Research:**
- Dispatch to fresh subagent with this research plan
- Parallel web searches across topics
- Consolidated findings document
- Saves main session context

**Subagent Instructions:**
```
Task: Conduct comprehensive workout analytics research

Context: We're building best-in-class analytics for a workout tracking app.
We have rich exercise metadata (muscles, equipment, force types, etc.).
Goal is evidence-based metrics backed by exercise science.

Research Plan: [paste this document]

Deliverable: Comprehensive research document with findings, recommendations,
rationale, and implementation notes for each topic.

Format: Markdown document suitable for engineering team reference.
```

---

## Success Criteria

- [ ] All 7 research areas covered comprehensively
- [ ] Competitive analysis identifies unique differentiators
- [ ] Recommendations backed by scientific evidence
- [ ] Implementation notes address technical feasibility
- [ ] V3 specification ready for engineering review
- [ ] MCP integration patterns identified
- [ ] Timeline and effort estimates included

---

**Estimated Total Time:** 6.5 hours
**Best Approach:** Dispatch to dedicated research subagent
**Context Savings:** ~50,000 tokens for main session

**Next Action:** User approval, then dispatch subagent with this plan
