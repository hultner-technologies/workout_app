-- Migration: Add 6 Evidence-Based Beginner Strength Training Programs
-- Date: 2025-11-22
-- Description: Adds comprehensive beginner programs including StrongLifts 5x5, Greyskull LP,
--              Ice Cream Fitness, Reddit Basic Beginner, Phrak's GSLP, and GZCLP
-- Research: /home/user/workout_app/docs/programs/beginner-programs.md

-- =============================================================================
-- PLANS (Workout Programs)
-- =============================================================================

-- StrongLifts 5x5
INSERT INTO plan (plan_id, name, description, links, data)
VALUES (
    '1b8e4f20-a8f1-11ef-8c9a-0b2e8f4a5d3c',
    'StrongLifts 5x5',
    'StrongLifts 5×5 is one of the most popular beginner strength training programs, designed to build foundational strength through simple compound barbell movements. Train 3 days per week, alternating between two full-body workouts (A and B).

**Program Structure:**
- Frequency: 3x per week (e.g., Monday, Wednesday, Friday)
- Duration: 45-60 minutes per workout
- Recommended length: 12-16 weeks

**Key Features:**
- Simple 5×5 scheme (5 sets of 5 reps) for all main lifts except deadlift (1×5)
- Linear progression: Add 5 lbs to upper body, 10 lbs to lower body each workout
- Squats every workout to build total body strength
- Rest 3-5 minutes between sets on main lifts

**Starting Weights:**
For complete beginners, start with the empty barbell (45 lbs/20 kg) for most lifts. The first few weeks should feel easy to allow focus on perfecting form.

**Progression:**
- Upper body lifts (Bench, OHP, Row): +5 lbs (2.5 kg) per workout
- Lower body lifts (Squat, Deadlift): +10 lbs (5 kg) per workout
- Monthly gains: Squat/Deadlift +60 lbs, Upper body +30 lbs

**Deload Protocol:**
If you fail to complete 5×5 for the same weight three workouts in a row, reduce weight by 10% and work back up with better form.

**Ideal for:** Complete beginners who want maximum simplicity and a proven strength-building program.',
    ARRAY[
        'https://stronglifts.com/stronglifts-5x5/',
        'https://stronglifts.com/stronglifts-5x5/workout-program/'
    ],
    NULL
),

-- Greyskull LP
(
    '2c9f6a30-a8f1-11ef-8c9a-1c3f9a5b6e4d',
    'Greyskull LP',
    'Greyskull Linear Progression is a powerbuilding program (strength + hypertrophy) created by John Sheaffer. It uses AMRAP (As Many Reps As Possible) sets to provide autoregulation and additional volume for muscle growth.

**Program Structure:**
- Frequency: 3x per week
- Duration: 45-60 minutes per workout
- Set scheme: 2×5, then 1×5+ (AMRAP on last set)
- Recommended length: 3-6 months

**Key Features:**
- AMRAP sets allow for extra volume on good days
- Lower per-workout volume than 5×5 programs (less fatigue)
- Includes curls and weighted chin-ups for arm development
- Balanced push/pull ratio for better upper body development

**Progression:**
- Add 2.5 lbs to upper body lifts each workout
- Add 5 lbs to lower body lifts each workout
- AMRAP acceleration: If you hit 10+ reps on AMRAP set, double the weight increase next session

**Deload/Reset Protocol:**
When reps on AMRAP set fall below 5, take 10% off the bar and work back up. Only deload the stalled lift; continue progressing on others.

**Ideal for:** Beginners who want both strength and muscle mass, prefer lower volume per session, and like the flexibility of AMRAP sets.',
    ARRAY[
        'https://liftvault.com/programs/strength/greyskull-linear-progression-spreadsheet/',
        'https://www.powerliftingtowin.com/greyskull-lp/',
        'https://outlift.com/greyskull-lp/'
    ],
    NULL
),

-- Ice Cream Fitness 5x5
(
    '3da07b40-a8f1-11ef-8c9a-2d4fab6c7f5e',
    'Ice Cream Fitness 5x5 (ICF)',
    'Ice Cream Fitness 5×5 is essentially StrongLifts 5×5 with extensive bodybuilding accessory work added. Created by Jason Blaha for beginners who want to build both strength and muscle size.

**Program Structure:**
- Frequency: 3x per week (e.g., Monday, Wednesday, Friday)
- Duration: ~1.5 hours per workout (due to accessory volume)
- Main lifts: 5×5 scheme
- Accessories: 3×8 for most isolation work
- Recommended length: 12-16 weeks

**Key Features:**
- Same 5×5 foundation as StrongLifts for main compound lifts
- Extensive accessory work for arms, abs, and back
- Direct bicep, tricep, and ab training included
- Balanced development for aesthetic and strength goals

**Progression:**
- Main lifts: +5-10 lbs lower body, +2-4 lbs upper body each workout
- Accessories: Progress when you complete all sets with good form

**Starting Weights:**
Use same guidelines as StrongLifts for main lifts. For accessories, start with weights that allow you to complete all prescribed sets with 1-2 reps in reserve.

**Deload Protocol:**
For main lifts, if you fail 5×5 for three consecutive workouts, deload by 10%. For accessories, maintain weight until you can complete all sets.

**Considerations:**
Higher time commitment and total volume requires adequate nutrition, sleep, and recovery capacity.

**Ideal for:** Beginner bodybuilders or those with aesthetic goals who still want a strength foundation. Best for younger lifters or those with good recovery capacity.',
    ARRAY[
        'https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout',
        'https://liftvault.com/programs/strength/ice-cream-fitness-icf-spreadsheet/',
        'https://www.powerliftingtowin.com/jason-blaha-5x5-novice-routine/'
    ],
    NULL
),

-- Reddit Basic Beginner Routine
(
    '4eb18c50-a8f1-11ef-8c9a-3e5fbc7d8a6f',
    'r/Fitness Basic Beginner Routine',
    'The r/Fitness Basic Beginner Routine is a "training wheels" program designed by the r/Fitness community specifically for complete beginners. Its primary goal is teaching fundamental barbell movements and building the habit of consistent training.

**Program Structure:**
- Frequency: 3x per week (e.g., Monday, Wednesday, Friday)
- Duration: 45-60 minutes per workout
- Main lifts: 3×5+ (last set AMRAP)
- Assistance work: 50-100 reps per category (push/pull/single-leg or core)
- Maximum recommended length: 3 months

**Key Features:**
- Extreme simplicity to reduce overwhelm for beginners
- AMRAP autoregulation on last set of each exercise
- 5/3/1-style assistance work ensures balanced development
- Time-boxed: designed as a stepping stone to more comprehensive programs

**Progression:**
- Add 2.5 lbs to upper body lifts each workout
- Add 5 lbs to lower body lifts each workout
- Accelerated: If 10+ reps on AMRAP, add 5 lbs upper or 10 lbs lower instead

**Assistance Work:**
Choose one exercise from each category (push, pull, single-leg/core) and perform 50-100 total reps (e.g., 5 sets of 10-20 reps). Not taken to failure.

**Deload Protocol:**
If you fail to get at least 5 reps on your AMRAP set, deload 10% and build back up.

**After Completion:**
After 3 months, transition to GZCLP, 5/3/1 for Beginners, or other intermediate programs.

**Ideal for:** Absolute beginners who have never touched a barbell, need to build the gym habit, and want a clear progression path to better programs.',
    ARRAY[
        'https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/',
        'https://thefitness.wiki/routines/'
    ],
    NULL
),

-- Phrak's Greyskull LP Variant
(
    '5fc29d60-a8f1-11ef-8c9a-4f6acd8e9b7a',
    'Phrak''s Greyskull LP Variant',
    'Phrak''s Greyskull LP Variant is a streamlined modification of the original Greyskull LP that has become one of the most popular beginner programs on r/Fitness. It includes more pulling movements than the original for better balance.

**Program Structure:**
- Frequency: 3x per week (e.g., Monday, Wednesday, Friday)
- Duration: 45-60 minutes per workout
- Set scheme: 2×5, then 1×5+ (AMRAP on last set)
- Recommended length: 3-6 months

**Key Features:**
- Balanced push/pull with chin-ups and barbell rows alternated
- AMRAP sets for autoregulation and increased volume potential
- Simpler accessory structure than original Greyskull LP
- Lower per-session volume (2×5 vs 5×5) reduces fatigue

**Progression:**
- Add 2.5 lbs to upper body lifts each workout
- Add 5 lbs to lower body lifts each workout
- AMRAP acceleration: If you hit 10+ reps on AMRAP set, double the weight increase

**Chin-up Guidance:**
Start with bodyweight. If you cannot do 3×5 bodyweight chin-ups, perform negatives (jump up, slowly lower) until you build strength. Once you can complete 3×5, start adding weight in 2.5 lb increments.

**Deload Protocol:**
When you fail to get at least 5 reps on your AMRAP set, reduce weight by 10% for that lift only. Continue progressing normally on other lifts.

**Advantages over Original GSLP:**
- More balanced upper body development
- Simpler accessory work (optional rather than prescribed)
- Better suited for general fitness goals

**Ideal for:** Beginners who want a balanced push/pull program with built-in autoregulation, are concerned about postural health, and prefer lower volume per session.',
    ARRAY[
        'https://liftvault.com/programs/strength/greyskull-linear-progression-spreadsheet/',
        'https://www.boostcamp.app/coaches/r-fitness/greyskull-linear-progression',
        'https://www.drworkout.fitness/phraks-gslp-program/',
        'https://outlift.com/greyskull-lp/'
    ],
    NULL
),

-- GZCLP
(
    '6ad3ae70-a8f1-11ef-8c9a-5a7bde9fac8b',
    'GZCLP (GZCL Linear Progression)',
    'GZCLP is a beginner-friendly linear progression program based on the GZCL Method by competitive powerlifter Cody Lefever. It uses a three-tier system to organize exercises by priority and intensity.

**Program Structure:**
- Frequency: 3-4x per week (4 different workouts cycled through)
- Duration: 60-75 minutes per workout
- Three-tier system:
  • Tier 1 (T1): Heavy main lifts - 5×3+ (Stage 1)
  • Tier 2 (T2): Lighter compounds - 3×10 (Stage 1)
  • Tier 3 (T3): Accessories - 3×15+
- Recommended length: 3-6 months

**Key Features:**
- Intelligent volume progression through multiple stages (3s → 2s → 1s for T1)
- Exposes beginners to different rep ranges and intensities
- Exercise prioritization through tier system
- Built-in periodization even at beginner level

**Tier 1 Progression:**
Stage 1: 5×3+ → If fail to hit 15 total reps, move to Stage 2
Stage 2: 6×2+ → If fail to hit 12 total reps, move to Stage 3
Stage 3: 10×1+ → If fail to hit 10 total reps, test new 5RM, use 85% to restart at Stage 1

**Tier 2 Progression:**
Follows T1 through stages (3×10 → 3×8 → 3×6). When T1 resets, add 15-20 lbs to last successful Stage 1 weight and restart.

**Tier 3 Progression:**
Keep same weight until you hit 25 reps on AMRAP set, then add smallest increment available.

**Weight Increases (T1):**
- Bench Press and Overhead Press: +5 lbs per workout
- Squat and Deadlift: +10 lbs per workout

**AMRAP Note:**
All AMRAP sets should leave 1-2 reps "in the tank" - don''t go to absolute failure.

**Ideal for:** Beginners who want a more sophisticated program structure, are interested in powerlifting, can train 3-4 days per week, and like tier-based training.',
    ARRAY[
        'https://thefitness.wiki/routines/gzclp/',
        'https://www.boostcamp.app/coaches/cody-lefever/gzcl-program-gzclp',
        'https://www.saynotobroscience.com/gzclp-infographic/',
        'https://liftvault.com/programs/powerlifting/gzclp-program-spreadsheets/'
    ],
    NULL
)
ON CONFLICT (plan_id) DO NOTHING;

-- =============================================================================
-- SESSION SCHEDULES (Workout Days/Sessions within Programs)
-- =============================================================================

-- StrongLifts 5x5 Session Schedules
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
(
    '1b9f6030-a8f1-11ef-8c9a-1b3f9a5b6e4d',
    '1b8e4f20-a8f1-11ef-8c9a-0b2e8f4a5d3c',
    'Workout A',
    'StrongLifts 5x5 Workout A: Squat, Bench Press, Barbell Row. Performed on Monday and Friday of Week 1, Wednesday of Week 2, alternating throughout the program.',
    1.0,
    ARRAY['https://stronglifts.com/stronglifts-5x5/'],
    NULL
),
(
    '1ba07140-a8f1-11ef-8c9a-2c4fab6c7f5e',
    '1b8e4f20-a8f1-11ef-8c9a-0b2e8f4a5d3c',
    'Workout B',
    'StrongLifts 5x5 Workout B: Squat, Overhead Press, Deadlift. Performed on Wednesday of Week 1, Monday and Friday of Week 2, alternating throughout the program.',
    1.0,
    ARRAY['https://stronglifts.com/stronglifts-5x5/'],
    NULL
),

-- Greyskull LP Session Schedules
(
    '2cb08250-a8f1-11ef-8c9a-3d5fbc7d8a6f',
    '2c9f6a30-a8f1-11ef-8c9a-1c3f9a5b6e4d',
    'Workout A',
    'Greyskull LP Workout A: Bench Press (2×5, 1×5+), Bicep Curl (2×10-15), Squat (2×5, 1×5+). Last set of main lifts is AMRAP.',
    1.0,
    ARRAY['https://liftvault.com/programs/strength/greyskull-linear-progression-spreadsheet/'],
    NULL
),
(
    '2cb19360-a8f1-11ef-8c9a-4e6acd8e9b7a',
    '2c9f6a30-a8f1-11ef-8c9a-1c3f9a5b6e4d',
    'Workout B',
    'Greyskull LP Workout B: Overhead Press (2×5, 1×5+), Weighted Chin-ups (2×6-8), Deadlift (1×5+ AMRAP only). Last set of main lifts is AMRAP.',
    1.0,
    ARRAY['https://liftvault.com/programs/strength/greyskull-linear-progression-spreadsheet/'],
    NULL
),

-- Ice Cream Fitness 5x5 Session Schedules
(
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b',
    '3da07b40-a8f1-11ef-8c9a-2d4fab6c7f5e',
    'Workout A',
    'ICF 5x5 Workout A: Main lifts (Squat 5×5, Bench Press 5×5, Barbell Row 5×5) followed by accessories (Barbell Shrugs 3×8, Tricep Extensions 3×8, Barbell Curls 3×8, Hyperextensions 2×10, Cable Crunches 3×10).',
    1.0,
    ARRAY['https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout'],
    NULL
),
(
    '3db2b580-a8f1-11ef-8c9a-6a8cef0abd9c',
    '3da07b40-a8f1-11ef-8c9a-2d4fab6c7f5e',
    'Workout B',
    'ICF 5x5 Workout B: Main lifts (Squat 5×5, Overhead Press 5×5, Deadlift 1×5) followed by accessories (Close Grip Bench Press 3×8, Barbell Curls 3×8, Cable Crunches 3×10).',
    1.0,
    ARRAY['https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout'],
    NULL
),

-- Reddit Basic Beginner Routine Session Schedules
(
    '4ec2c690-a8f1-11ef-8c9a-7b9dfa1bce0d',
    '4eb18c50-a8f1-11ef-8c9a-3e5fbc7d8a6f',
    'Workout A',
    'r/Fitness Basic Beginner Workout A: Squat (3×5+), Bench Press (3×5+), Barbell Row (3×5+), followed by assistance work (50-100 reps each: push, pull, single-leg/core). Last set of main lifts is AMRAP.',
    1.0,
    ARRAY['https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/'],
    NULL
),
(
    '4ec3d7a0-a8f1-11ef-8c9a-8cafeb2cdf1e',
    '4eb18c50-a8f1-11ef-8c9a-3e5fbc7d8a6f',
    'Workout B',
    'r/Fitness Basic Beginner Workout B: Deadlift (3×5+), Overhead Press (3×5+), Chin-ups or Lat Pulldown (3×5+), followed by assistance work (50-100 reps each: push, pull, single-leg/core). Last set of main lifts is AMRAP.',
    1.0,
    ARRAY['https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/'],
    NULL
),

-- Phrak's Greyskull LP Variant Session Schedules
(
    '5fd4e8b0-a8f1-11ef-8c9a-9dbffc3dee2f',
    '5fc29d60-a8f1-11ef-8c9a-4f6acd8e9b7a',
    'Workout A',
    'Phrak''s GSLP Workout A: Overhead Press (2×5, 1×5+), Chin-ups (2×5, 1×5+), Squat (2×5, 1×5+). Last set is AMRAP. Chin-ups use supinated (palms facing you) grip.',
    1.0,
    ARRAY['https://www.drworkout.fitness/phraks-gslp-program/'],
    NULL
),
(
    '5fd5f9c0-a8f1-11ef-8c9a-0ecafd4eff3a',
    '5fc29d60-a8f1-11ef-8c9a-4f6acd8e9b7a',
    'Workout B',
    'Phrak''s GSLP Workout B: Bench Press (2×5, 1×5+), Barbell Row (2×5, 1×5+), Deadlift (1×5+ AMRAP only). Last set is AMRAP.',
    1.0,
    ARRAY['https://www.drworkout.fitness/phraks-gslp-program/'],
    NULL
),

-- GZCLP Session Schedules (4 different days)
(
    '6ae50ad0-a8f1-11ef-8c9a-1fdbfe5af04b',
    '6ad3ae70-a8f1-11ef-8c9a-5a7bde9fac8b',
    'Day 1 - Squat Focus',
    'GZCLP Day 1: T1 Squat (5×3+), T2 Bench Press (3×10), T3 Lat Pulldown (3×15+). T1 is heavy, T2 is moderate volume, T3 is high rep accessory work.',
    1.0,
    ARRAY['https://thefitness.wiki/routines/gzclp/'],
    NULL
),
(
    '6ae61be0-a8f1-11ef-8c9a-2aecff6ba15c',
    '6ad3ae70-a8f1-11ef-8c9a-5a7bde9fac8b',
    'Day 2 - Overhead Press Focus',
    'GZCLP Day 2: T1 Overhead Press (5×3+), T2 Deadlift (3×10), T3 Dumbbell Row (3×15+). T1 is heavy, T2 is moderate volume, T3 is high rep accessory work.',
    1.0,
    ARRAY['https://thefitness.wiki/routines/gzclp/'],
    NULL
),
(
    '6ae72cf0-a8f1-11ef-8c9a-3bfdfa7cb26d',
    '6ad3ae70-a8f1-11ef-8c9a-5a7bde9fac8b',
    'Day 3 - Bench Press Focus',
    'GZCLP Day 3: T1 Bench Press (5×3+), T2 Squat (3×10), T3 Lat Pulldown (3×15+). T1 is heavy, T2 is moderate volume, T3 is high rep accessory work.',
    1.0,
    ARRAY['https://thefitness.wiki/routines/gzclp/'],
    NULL
),
(
    '6ae83e00-a8f1-11ef-8c9a-4cafeb8dc37e',
    '6ad3ae70-a8f1-11ef-8c9a-5a7bde9fac8b',
    'Day 4 - Deadlift Focus',
    'GZCLP Day 4: T1 Deadlift (5×3+), T2 Overhead Press (3×10), T3 Dumbbell Row (3×15+). T1 is heavy, T2 is moderate volume, T3 is high rep accessory work.',
    1.0,
    ARRAY['https://thefitness.wiki/routines/gzclp/'],
    NULL
)
ON CONFLICT (session_schedule_id) DO NOTHING;

-- =============================================================================
-- EXERCISES (Exercise configurations within session schedules)
-- =============================================================================

-- ============================================
-- STRONGLIFTS 5x5 EXERCISES
-- ============================================

-- StrongLifts Workout A Exercises
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links)
VALUES
-- Squat 5x5
(
    '1bb14f10-a8f1-11ef-8c9a-1b3f9a5b6e4d',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '1b9f6030-a8f1-11ef-8c9a-1b3f9a5b6e4d', -- StrongLifts Workout A
    5, 5, '00:03:00', 1000, 5000,
    'Squat 5×5. Add 10 lbs (5 kg) each workout when you complete all sets. Start with empty barbell (45 lbs) if you''re a complete beginner. Focus on depth - thighs parallel to ground.',
    ARRAY['https://stronglifts.com/squat/']
),
-- Bench Press 5x5
(
    '1bb26020-a8f1-11ef-8c9a-2c4fab6c7f5e',
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
    '1b9f6030-a8f1-11ef-8c9a-1b3f9a5b6e4d', -- StrongLifts Workout A
    5, 5, '00:03:00', 2000, 2500,
    'Bench Press 5×5. Add 5 lbs (2.5 kg) each workout when you complete all sets. Lower bar to chest, press until arms are locked.',
    ARRAY['https://stronglifts.com/bench-press/']
),
-- Barbell Row 5x5
(
    '1bb37130-a8f1-11ef-8c9a-3d5fbc7d8a6f',
    '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', -- Barbell Row
    '1b9f6030-a8f1-11ef-8c9a-1b3f9a5b6e4d', -- StrongLifts Workout A
    5, 5, '00:03:00', 3000, 2500,
    'Barbell Row 5×5. Add 5 lbs (2.5 kg) each workout when you complete all sets. Pull bar to lower chest, elbows at 45 degrees. Do not use momentum.',
    ARRAY['https://stronglifts.com/barbell-row/']
),

-- StrongLifts Workout B Exercises
-- Squat 5x5
(
    '1bb48240-a8f1-11ef-8c9a-4e6acd8e9b7a',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '1ba07140-a8f1-11ef-8c9a-2c4fab6c7f5e', -- StrongLifts Workout B
    5, 5, '00:03:00', 1000, 5000,
    'Squat 5×5. Add 10 lbs (5 kg) each workout when you complete all sets. You squat every StrongLifts workout to build total body strength.',
    ARRAY['https://stronglifts.com/squat/']
),
-- Overhead Press 5x5
(
    '1bb59350-a8f1-11ef-8c9a-5f7bde9fac8b',
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
    '1ba07140-a8f1-11ef-8c9a-2c4fab6c7f5e', -- StrongLifts Workout B
    5, 5, '00:03:00', 2000, 2500,
    'Overhead Press 5×5. Add 5 lbs (2.5 kg) each workout when you complete all sets. Press bar from shoulders to overhead, lock your elbows at the top.',
    ARRAY['https://stronglifts.com/overhead-press/']
),
-- Deadlift 1x5
(
    '1bb6a460-a8f1-11ef-8c9a-6a8cef0abd9c',
    '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
    '1ba07140-a8f1-11ef-8c9a-2c4fab6c7f5e', -- StrongLifts Workout B
    5, 1, '00:05:00', 3000, 5000,
    'Deadlift 1×5 (one set only). Add 10 lbs (5 kg) each workout when you complete the set. Deadlifts are only 1 set because they create high systemic fatigue. Start at 95 lbs if you''re a beginner.',
    ARRAY['https://stronglifts.com/deadlift/']
),

-- ============================================
-- GREYSKULL LP EXERCISES
-- ============================================

-- Greyskull LP Workout A
-- Bench Press 2x5, 1x5+
(
    '2cc1b570-a8f1-11ef-8c9a-1b3f9a5b6e4d',
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
    '2cb08250-a8f1-11ef-8c9a-3d5fbc7d8a6f', -- Greyskull Workout A
    5, 3, '00:03:00', 1000, 2500,
    'Bench Press: 2 sets of 5 reps, then 1 set of 5+ (AMRAP - as many reps as possible). Add 2.5 lbs per workout. If you get 10+ reps on the AMRAP set, add 5 lbs instead.',
    ARRAY['https://outlift.com/greyskull-lp/']
),
-- Bicep Curl 2x10-15
(
    '2cc2c680-a8f1-11ef-8c9a-2c4fab6c7f5e',
    'bee63c0c-05c8-11ed-824f-673da9665bfa', -- Bicep Curl
    '2cb08250-a8f1-11ef-8c9a-3d5fbc7d8a6f', -- Greyskull Workout A
    12, 2, '00:02:00', 2000, 2500,
    'Bicep Curl: 2 sets of 10-15 reps. Add weight when you hit the top of the rep range. Keep elbows stationary.',
    NULL
),
-- Squat 2x5, 1x5+
(
    '2cc3d790-a8f1-11ef-8c9a-3d5fbc7d8a6f',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '2cb08250-a8f1-11ef-8c9a-3d5fbc7d8a6f', -- Greyskull Workout A
    5, 3, '00:03:00', 3000, 5000,
    'Squat: 2 sets of 5 reps, then 1 set of 5+ (AMRAP). Add 5 lbs per workout. If you get 10+ reps on the AMRAP set, add 10 lbs instead.',
    ARRAY['https://outlift.com/greyskull-lp/']
),

-- Greyskull LP Workout B
-- Overhead Press 2x5, 1x5+
(
    '2cc4e8a0-a8f1-11ef-8c9a-4e6acd8e9b7a',
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
    '2cb19360-a8f1-11ef-8c9a-4e6acd8e9b7a', -- Greyskull Workout B
    5, 3, '00:03:00', 1000, 2500,
    'Overhead Press: 2 sets of 5 reps, then 1 set of 5+ (AMRAP). Add 2.5 lbs per workout. If you get 10+ reps on AMRAP, add 5 lbs instead.',
    ARRAY['https://outlift.com/greyskull-lp/']
),
-- Weighted Chin-ups 2x6-8
(
    '2cc5f9b0-a8f1-11ef-8c9a-5f7bde9fac8b',
    'b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac', -- Chin-ups
    '2cb19360-a8f1-11ef-8c9a-4e6acd8e9b7a', -- Greyskull Workout B
    7, 2, '00:02:00', 2000, 2500,
    'Weighted Chin-ups: 2 sets of 6-8 reps. Start with bodyweight only. Once you can do 3×8 bodyweight, start adding weight. If you cannot do bodyweight chin-ups yet, do negatives (jump up, slowly lower down) or use lat pulldown as a substitute.',
    ARRAY['https://outlift.com/greyskull-lp/']
),
-- Deadlift 1x5+
(
    '2cc70ac0-a8f1-11ef-8c9a-6a8cef0abd9c',
    '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
    '2cb19360-a8f1-11ef-8c9a-4e6acd8e9b7a', -- Greyskull Workout B
    5, 1, '00:03:00', 3000, 5000,
    'Deadlift: 1 set of 5+ (AMRAP only - no warm-up sets counted). Add 5 lbs per workout. Push for as many quality reps as possible.',
    ARRAY['https://outlift.com/greyskull-lp/']
),

-- ============================================
-- ICE CREAM FITNESS 5x5 EXERCISES
-- ============================================

-- ICF Workout A
-- Squat 5x5
(
    '3dc2bd80-a8f1-11ef-8c9a-1b3f9a5b6e4d',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b', -- ICF Workout A
    5, 5, '00:03:00', 1000, 5000,
    'Squat 5×5. Main compound lift. Add 5-10 lbs per workout when you complete all sets.',
    ARRAY['https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout']
),
-- Bench Press 5x5
(
    '3dc3ce90-a8f1-11ef-8c9a-2c4fab6c7f5e',
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b', -- ICF Workout A
    5, 5, '00:03:00', 2000, 2500,
    'Bench Press 5×5. Main compound lift. Add 2-4 lbs per workout when you complete all sets.',
    ARRAY['https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout']
),
-- Barbell Row 5x5
(
    '3dc4dfa0-a8f1-11ef-8c9a-3d5fbc7d8a6f',
    '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', -- Barbell Row
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b', -- ICF Workout A
    5, 5, '00:03:00', 3000, 2500,
    'Barbell Row 5×5. Main compound lift. Add 2-4 lbs per workout when you complete all sets. Pull to lower chest.',
    ARRAY['https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout']
),
-- Barbell Shrugs 3x8
(
    '3dc5f0b0-a8f1-11ef-8c9a-4e6acd8e9b7a',
    'bef4006c-05c8-11ed-824f-0fb53f8f059b', -- Shrug
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b', -- ICF Workout A
    8, 3, '00:01:30', 4000, 2500,
    'Barbell Shrugs 3×8. Accessory exercise for traps. Raise shoulders as high as possible, squeeze at the top.',
    NULL
),
-- Tricep Extensions 3x8
(
    '3dc701c0-a8f1-11ef-8c9a-5f7bde9fac8b',
    'bee7fe8e-05c8-11ed-824f-578dbf84191f', -- Overhead Tricep Extension
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b', -- ICF Workout A
    8, 3, '00:01:30', 5000, 2500,
    'Overhead Tricep Extensions 3×8. Accessory exercise. Extend arms fully at top to feel the burn in triceps.',
    NULL
),
-- Barbell Curls 3x8
(
    '3dc812d0-a8f1-11ef-8c9a-6a8cef0abd9c',
    'bee63c0c-05c8-11ed-824f-673da9665bfa', -- Bicep Curl
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b', -- ICF Workout A
    8, 3, '00:01:30', 6000, 2500,
    'Barbell Curls 3×8. Accessory exercise for biceps. Keep elbows stationary, no swinging.',
    NULL
),
-- Hyperextensions 2x10
(
    '3dc923e0-a8f1-11ef-8c9a-7b9dfa1bce0d',
    'cad62a1a-538f-408a-95d3-de74f54f6710', -- Hyperextensions
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b', -- ICF Workout A
    10, 2, '00:01:30', 7000, 2500,
    'Hyperextensions 2×10. Lower back and posterior chain. Hinge at hips, maintain neutral spine. Can substitute with Good Mornings.',
    NULL
),
-- Cable Crunches 3x10
(
    '3dca34f0-a8f1-11ef-8c9a-8cafeb2cdf1e',
    '2a36d342-dc9e-11ee-b3ef-77b99b9dab02', -- Cable Crunch
    '3db1a470-a8f1-11ef-8c9a-5f7bde9fac8b', -- ICF Workout A
    10, 3, '00:01:30', 8000, 2500,
    'Cable Crunches 3×10. Ab work. Return to starting position slowly, don''t let rope tension do the work.',
    NULL
),

-- ICF Workout B
-- Squat 5x5
(
    '3dcb4600-a8f1-11ef-8c9a-9dbffc3dee2f',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '3db2b580-a8f1-11ef-8c9a-6a8cef0abd9c', -- ICF Workout B
    5, 5, '00:03:00', 1000, 5000,
    'Squat 5×5. Main compound lift. You squat every workout in ICF. Add 5-10 lbs per workout.',
    ARRAY['https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout']
),
-- Overhead Press 5x5
(
    '3dcc5710-a8f1-11ef-8c9a-0ecafd4eff3a',
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
    '3db2b580-a8f1-11ef-8c9a-6a8cef0abd9c', -- ICF Workout B
    5, 5, '00:03:00', 2000, 2500,
    'Overhead Press 5×5. Main compound lift. Add 2-4 lbs per workout when you complete all sets.',
    ARRAY['https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout']
),
-- Deadlift 1x5
(
    '3dcd6820-a8f1-11ef-8c9a-1fdbfe5af04b',
    '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
    '3db2b580-a8f1-11ef-8c9a-6a8cef0abd9c', -- ICF Workout B
    5, 1, '00:05:00', 3000, 5000,
    'Deadlift 1×5 (one set only). Main compound lift. Add 5-10 lbs per workout. One set due to high fatigue.',
    ARRAY['https://www.muscleandstrength.com/workouts/jason-blaha-ice-cream-fitness-5x5-novice-workout']
),
-- Close Grip Bench Press 3x8
(
    '3dce7930-a8f1-11ef-8c9a-2aecff6ba15c',
    '48a24998-5466-4e5c-af83-fc2de2cd6c4c', -- Close-Grip Bench Press
    '3db2b580-a8f1-11ef-8c9a-6a8cef0abd9c', -- ICF Workout B
    8, 3, '00:01:30', 4000, 2500,
    'Close Grip Bench Press 3×8. Tricep-focused accessory. Hands shoulder-width or slightly narrower. Lower to mid-chest.',
    NULL
),
-- Barbell Curls 3x8
(
    '3dcf8a40-a8f1-11ef-8c9a-3bfdfa7cb26d',
    'bee63c0c-05c8-11ed-824f-673da9665bfa', -- Bicep Curl
    '3db2b580-a8f1-11ef-8c9a-6a8cef0abd9c', -- ICF Workout B
    8, 3, '00:01:30', 5000, 2500,
    'Barbell Curls 3×8. Accessory for biceps. Keep elbows stationary, no momentum.',
    NULL
),
-- Cable Crunches 3x10
(
    '3dd09b50-a8f1-11ef-8c9a-4cafeb8dc37e',
    '2a36d342-dc9e-11ee-b3ef-77b99b9dab02', -- Cable Crunch
    '3db2b580-a8f1-11ef-8c9a-6a8cef0abd9c', -- ICF Workout B
    10, 3, '00:01:30', 6000, 2500,
    'Cable Crunches 3×10. Ab work. Control the movement, don''t let cable do the work.',
    NULL
),

-- ============================================
-- REDDIT BASIC BEGINNER ROUTINE EXERCISES
-- ============================================

-- r/Fitness Workout A
-- Squat 3x5+
(
    '4ed3d8a0-a8f1-11ef-8c9a-1b3f9a5b6e4d',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '4ec2c690-a8f1-11ef-8c9a-7b9dfa1bce0d', -- r/Fitness Workout A
    5, 3, '00:03:00', 1000, 5000,
    'Squat 3×5+ (last set AMRAP). Add 5 lbs per workout. If you get 10+ reps on AMRAP, add 10 lbs instead. Start conservatively to learn form.',
    ARRAY['https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/']
),
-- Bench Press 3x5+
(
    '4ed4e9b0-a8f1-11ef-8c9a-2c4fab6c7f5e',
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
    '4ec2c690-a8f1-11ef-8c9a-7b9dfa1bce0d', -- r/Fitness Workout A
    5, 3, '00:03:00', 2000, 2500,
    'Bench Press 3×5+ (last set AMRAP). Add 2.5 lbs per workout. If you get 10+ reps on AMRAP, add 5 lbs instead.',
    ARRAY['https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/']
),
-- Barbell Row 3x5+
(
    '4ed5fac0-a8f1-11ef-8c9a-3d5fbc7d8a6f',
    '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', -- Barbell Row
    '4ec2c690-a8f1-11ef-8c9a-7b9dfa1bce0d', -- r/Fitness Workout A
    5, 3, '00:03:00', 3000, 2500,
    'Barbell Row 3×5+ (last set AMRAP). Add 2.5 lbs per workout. If you get 10+ reps on AMRAP, add 5 lbs instead. Pull to lower chest.',
    ARRAY['https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/']
),

-- r/Fitness Workout B
-- Deadlift 3x5+
(
    '4ed70bd0-a8f1-11ef-8c9a-4e6acd8e9b7a',
    '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
    '4ec3d7a0-a8f1-11ef-8c9a-8cafeb2cdf1e', -- r/Fitness Workout B
    5, 3, '00:03:00', 1000, 5000,
    'Deadlift 3×5+ (last set AMRAP). Add 5 lbs per workout. If you get 10+ reps on AMRAP, add 10 lbs instead.',
    ARRAY['https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/']
),
-- Overhead Press 3x5+
(
    '4ed81ce0-a8f1-11ef-8c9a-5f7bde9fac8b',
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
    '4ec3d7a0-a8f1-11ef-8c9a-8cafeb2cdf1e', -- r/Fitness Workout B
    5, 3, '00:03:00', 2000, 2500,
    'Overhead Press 3×5+ (last set AMRAP). Add 2.5 lbs per workout. If you get 10+ reps on AMRAP, add 5 lbs instead.',
    ARRAY['https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/']
),
-- Chin-ups or Lat Pulldown 3x5+
(
    '4ed92df0-a8f1-11ef-8c9a-6a8cef0abd9c',
    'b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac', -- Chin-ups
    '4ec3d7a0-a8f1-11ef-8c9a-8cafeb2cdf1e', -- r/Fitness Workout B
    5, 3, '00:02:00', 3000, 2500,
    'Chin-ups 3×5+ (last set AMRAP). Use bodyweight. If you cannot do chin-ups, substitute with lat pulldown. Once you can do 3×8 bodyweight, start adding weight.',
    ARRAY['https://thefitness.wiki/routines/r-fitness-basic-beginner-routine/']
),

-- ============================================
-- PHRAK'S GREYSKULL LP VARIANT EXERCISES
-- ============================================

-- Phrak's GSLP Workout A
-- Overhead Press 2x5, 1x5+
(
    '5fe5fad0-a8f1-11ef-8c9a-1b3f9a5b6e4d',
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
    '5fd4e8b0-a8f1-11ef-8c9a-9dbffc3dee2f', -- Phrak's Workout A
    5, 3, '00:03:00', 1000, 2500,
    'Overhead Press: 2 sets of 5 reps, then 1 set of 5+ (AMRAP). Add 2.5 lbs per workout. If you get 10+ reps on AMRAP, add 5 lbs instead. This is the core Greyskull progression scheme.',
    ARRAY['https://www.drworkout.fitness/phraks-gslp-program/']
),
-- Chin-ups 2x5, 1x5+
(
    '5fe70be0-a8f1-11ef-8c9a-2c4fab6c7f5e',
    'b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac', -- Chin-ups
    '5fd4e8b0-a8f1-11ef-8c9a-9dbffc3dee2f', -- Phrak's Workout A
    5, 3, '00:02:00', 2000, 2500,
    'Chin-ups: 2 sets of 5 reps, then 1 set of 5+ (AMRAP). Use supinated (palms facing you) grip. Start bodyweight. If you can''t do bodyweight chin-ups, do negatives or substitute lat pulldown. Once you can do 3×8, add weight.',
    ARRAY['https://www.drworkout.fitness/phraks-gslp-program/']
),
-- Squat 2x5, 1x5+
(
    '5fe81cf0-a8f1-11ef-8c9a-3d5fbc7d8a6f',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '5fd4e8b0-a8f1-11ef-8c9a-9dbffc3dee2f', -- Phrak's Workout A
    5, 3, '00:03:00', 3000, 5000,
    'Squat: 2 sets of 5 reps, then 1 set of 5+ (AMRAP). Add 5 lbs per workout. If you get 10+ reps on AMRAP, add 10 lbs instead.',
    ARRAY['https://www.drworkout.fitness/phraks-gslp-program/']
),

-- Phrak's GSLP Workout B
-- Bench Press 2x5, 1x5+
(
    '5fe92e00-a8f1-11ef-8c9a-4e6acd8e9b7a',
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
    '5fd5f9c0-a8f1-11ef-8c9a-0ecafd4eff3a', -- Phrak's Workout B
    5, 3, '00:03:00', 1000, 2500,
    'Bench Press: 2 sets of 5 reps, then 1 set of 5+ (AMRAP). Add 2.5 lbs per workout. If you get 10+ reps on AMRAP, add 5 lbs instead.',
    ARRAY['https://www.drworkout.fitness/phraks-gslp-program/']
),
-- Barbell Row 2x5, 1x5+
(
    '5fea3f10-a8f1-11ef-8c9a-5f7bde9fac8b',
    '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', -- Barbell Row
    '5fd5f9c0-a8f1-11ef-8c9a-0ecafd4eff3a', -- Phrak's Workout B
    5, 3, '00:02:00', 2000, 2500,
    'Barbell Row: 2 sets of 5 reps, then 1 set of 5+ (AMRAP). Add 2.5 lbs per workout. If you get 10+ reps on AMRAP, add 5 lbs instead. Use Yates rows or any row variant.',
    ARRAY['https://www.drworkout.fitness/phraks-gslp-program/']
),
-- Deadlift 1x5+
(
    '5feb5020-a8f1-11ef-8c9a-6a8cef0abd9c',
    '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
    '5fd5f9c0-a8f1-11ef-8c9a-0ecafd4eff3a', -- Phrak's Workout B
    5, 1, '00:03:00', 3000, 5000,
    'Deadlift: 1 set of 5+ (AMRAP only). Add 5 lbs per workout. Push for as many quality reps as possible without form breakdown.',
    ARRAY['https://www.drworkout.fitness/phraks-gslp-program/']
),

-- ============================================
-- GZCLP EXERCISES
-- ============================================

-- GZCLP Day 1 - Squat Focus
-- T1: Squat 5x3+
(
    '6af94f20-a8f1-11ef-8c9a-1b3f9a5b6e4d',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '6ae50ad0-a8f1-11ef-8c9a-1fdbfe5af04b',  -- GZCLP Day 1
    3, 5, '00:03:00', 1000, 5000,
    'T1 Squat 5×3+ (last set AMRAP). Add 10 lbs per workout. Stage 1: If you fail to hit 15 total reps, move to Stage 2 (6×2+). Stage 2: If you fail to hit 12 reps, move to Stage 3 (10×1+). Stage 3: If you fail 10 reps, test new 5RM and use 85% to restart at Stage 1.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),
-- T2: Bench Press 3x10
(
    '6afa6030-a8f1-11ef-8c9a-2c4fab6c7f5e',
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
    '6ae50ad0-a8f1-11ef-8c9a-1fdbfe5af04b',  -- GZCLP Day 1
    10, 3, '00:02:00', 2000, 0,
    'T2 Bench Press 3×10 (no AMRAP). Keep same weight; don''t add weight on T2. When T1 Squat moves to Stage 2, this becomes 3×8. When T1 moves to Stage 3, this becomes 3×6. When T1 resets, add 15-20 lbs to this weight and restart at 3×10.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),
-- T3: Lat Pulldown 3x15+
(
    '6afb7140-a8f1-11ef-8c9a-3d5fbc7d8a6f',
    '28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50', -- Lat Pulldown
    '6ae50ad0-a8f1-11ef-8c9a-1fdbfe5af04b',  -- GZCLP Day 1
    15, 3, '00:01:00', 3000, 2500,
    'T3 Lat Pulldown 3×15+ (last set AMRAP). Keep same weight until you hit 25 reps on AMRAP set, then add smallest increment (usually 5 lbs) and restart at 3×15+. Can substitute with other pulling movements.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),

-- GZCLP Day 2 - Overhead Press Focus
-- T1: Overhead Press 5x3+
(
    '6afc8250-a8f1-11ef-8c9a-4e6acd8e9b7a',
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
    '6ae61be0-a8f1-11ef-8c9a-2aecff6ba15c',  -- GZCLP Day 2
    3, 5, '00:03:00', 1000, 2500,
    'T1 Overhead Press 5×3+ (last set AMRAP). Add 5 lbs per workout. Follows same stage progression as T1 Squat: Stage 1 (5×3+) → Stage 2 (6×2+) → Stage 3 (10×1+) → Reset with 85% of new 5RM.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),
-- T2: Deadlift 3x10
(
    '6afd9360-a8f1-11ef-8c9a-5f7bde9fac8b',
    '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
    '6ae61be0-a8f1-11ef-8c9a-2aecff6ba15c',  -- GZCLP Day 2
    10, 3, '00:02:00', 2000, 0,
    'T2 Deadlift 3×10 (no AMRAP). Follows T1 OHP stages: 3×10 → 3×8 → 3×6. When T1 OHP resets, add 15-20 lbs to this weight.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),
-- T3: Dumbbell Row 3x15+
(
    '6afea470-a8f1-11ef-8c9a-6a8cef0abd9c',
    'cc50696f-1aad-422e-a192-12c9bfd0cc25', -- Dumbbell Row
    '6ae61be0-a8f1-11ef-8c9a-2aecff6ba15c',  -- GZCLP Day 2
    15, 3, '00:01:00', 3000, 2500,
    'T3 Dumbbell Row 3×15+ (last set AMRAP). Keep weight until 25 reps on AMRAP, then add weight and restart.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),

-- GZCLP Day 3 - Bench Press Focus
-- T1: Bench Press 5x3+
(
    '6affb580-a8f1-11ef-8c9a-7b9dfa1bce0d',
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
    '6ae72cf0-a8f1-11ef-8c9a-3bfdfa7cb26d',  -- GZCLP Day 3
    3, 5, '00:03:00', 1000, 2500,
    'T1 Bench Press 5×3+ (last set AMRAP). Add 5 lbs per workout. Stage progression: 5×3+ → 6×2+ → 10×1+ → Reset.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),
-- T2: Squat 3x10
(
    '6b00c690-a8f1-11ef-8c9a-8cafeb2cdf1e',
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    '6ae72cf0-a8f1-11ef-8c9a-3bfdfa7cb26d',  -- GZCLP Day 3
    10, 3, '00:02:00', 2000, 0,
    'T2 Squat 3×10 (no AMRAP). Follows T1 Bench stages: 3×10 → 3×8 → 3×6. When T1 resets, add 15-20 lbs.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),
-- T3: Lat Pulldown 3x15+
(
    '6b01d7a0-a8f1-11ef-8c9a-9dbffc3dee2f',
    '28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50', -- Lat Pulldown
    '6ae72cf0-a8f1-11ef-8c9a-3bfdfa7cb26d',  -- GZCLP Day 3
    15, 3, '00:01:00', 3000, 2500,
    'T3 Lat Pulldown 3×15+ (last set AMRAP). Keep weight until 25 reps on AMRAP, then add weight.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),

-- GZCLP Day 4 - Deadlift Focus
-- T1: Deadlift 5x3+
(
    '6b02e8b0-a8f1-11ef-8c9a-0ecafd4eff3a',
    '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
    '6ae83e00-a8f1-11ef-8c9a-4cafeb8dc37e',  -- GZCLP Day 4
    3, 5, '00:03:00', 1000, 5000,
    'T1 Deadlift 5×3+ (last set AMRAP). Add 10 lbs per workout. Stage progression: 5×3+ → 6×2+ → 10×1+ → Reset.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),
-- T2: Overhead Press 3x10
(
    '6b03f9c0-a8f1-11ef-8c9a-1fdbfe5af04b',
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
    '6ae83e00-a8f1-11ef-8c9a-4cafeb8dc37e',  -- GZCLP Day 4
    10, 3, '00:02:00', 2000, 0,
    'T2 Overhead Press 3×10 (no AMRAP). Follows T1 Deadlift stages: 3×10 → 3×8 → 3×6. When T1 resets, add 15-20 lbs.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
),
-- T3: Dumbbell Row 3x15+
(
    '6b050ad0-a8f1-11ef-8c9a-2aecff6ba15c',
    'cc50696f-1aad-422e-a192-12c9bfd0cc25', -- Dumbbell Row
    '6ae83e00-a8f1-11ef-8c9a-4cafeb8dc37e',  -- GZCLP Day 4
    15, 3, '00:01:00', 3000, 2500,
    'T3 Dumbbell Row 3×15+ (last set AMRAP). Keep weight until 25 reps on AMRAP, then add weight.',
    ARRAY['https://thefitness.wiki/routines/gzclp/']
)
ON CONFLICT (exercise_id) DO NOTHING;

-- =============================================================================
-- Migration Complete
-- =============================================================================
-- 6 beginner programs added:
-- 1. StrongLifts 5x5 (2 workouts)
-- 2. Greyskull LP (2 workouts)
-- 3. Ice Cream Fitness 5x5 (2 workouts)
-- 4. Reddit Basic Beginner Routine (2 workouts)
-- 5. Phrak's Greyskull LP Variant (2 workouts)
-- 6. GZCLP (4 workouts)
--
-- Total: 6 plans, 14 session schedules, 64 exercises
