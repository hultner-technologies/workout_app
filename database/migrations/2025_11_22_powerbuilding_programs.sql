-- ============================================================================
-- Powerbuilding Programs Migration
-- Created: 2025-11-22
-- ============================================================================
-- This migration adds 5 comprehensive powerbuilding programs to the database:
-- 1. GZCL Method (GZCLP) - 4 day version
-- 2. nSuns 531 LP - 4 day version
-- 3. PHUL (Power Hypertrophy Upper Lower)
-- 4. PHAT (Power Hypertrophy Adaptive Training)
-- 5. Juggernaut Method
--
-- All programs include:
-- - Detailed plan descriptions with markdown formatting
-- - Source links for reference
-- - Session schedules for each workout day
-- - Complete exercise configurations with sets, reps, rest periods
-- - Proper progression parameters (step_increment, progression_limit)
-- ============================================================================

-- ============================================================================
-- PLANS (Workout Programs)
-- ============================================================================

INSERT INTO plan (plan_id, name, description, links, data)
VALUES
    -- GZCL Method (GZCLP)
    (
        uuid_generate_v1mc(),
        'GZCL Method (GZCLP)',
        '# GZCL Method - General Gainz Cody Lefever Linear Progression

The GZCL Method is a tier-based powerbuilding program created by powerlifter Cody Lefever. It combines strength and hypertrophy training through an intelligent three-tier system.

## Program Overview

**Training Frequency:** 4 days per week (A1, B1, A2, B2 repeating)

**Philosophy:** The program uses a tier-based approach that balances intensity and volume:
- **Tier 1 (T1):** Main compound lifts - highest intensity, lowest volume (3-5 reps)
- **Tier 2 (T2):** Secondary compounds - moderate intensity, moderate volume (6-10 reps)
- **Tier 3 (T3):** Accessory exercises - lowest intensity, highest volume (15+ reps)

## Key Features

- **Autoregulation:** AMRAP sets on the final set of each exercise allow you to regulate progression based on performance
- **Linear Progression:** Add weight every workout - 5 lbs for upper body, 10 lbs for lower body
- **Built-in Progression Scheme:** When you fail to hit volume targets, the program automatically adjusts set/rep schemes
- **Flexibility:** T3 exercises can be customized based on individual needs and equipment

## Progression System

**T1 Progression:**
1. Start: 5 sets x 3 reps (volume = 15)
2. When volume fails: Drop to 6 sets x 2 reps
3. When volume fails again: Drop to 10 sets x 1 rep
4. Reset with new 5RM and restart cycle

**T2 Progression:**
1. Start: 3 sets x 10 reps (volume = 30)
2. Progress to 3x8, then 3x6 as needed
3. Reset with new 10RM when needed

**T3 Progression:**
- Add weight when AMRAP set reaches 25+ reps
- Simple and sustainable

## Intensity Guidelines

- **T1:** ~85-100% of 2-3 rep max (very heavy)
- **T2:** ~65-75% of 1RM (moderate)
- **T3:** Light enough for 15+ reps (pump work)

## Rest Periods

- **T1:** 3-5 minutes between sets
- **T2:** 2-3 minutes between sets
- **T3:** 1-2 minutes between sets

## Best For

- Beginner to early intermediate lifters
- Those who want a simple, flexible framework
- Athletes seeking both strength and size
- 3-4 day per week training commitment

## Program Duration

Can run indefinitely with linear progression. Deload every 6-8 weeks or as needed. Typical beginner run: 3-6 months before transitioning to more advanced GZCL variations.

## Evidence Base

Created by competitive powerlifter Cody Lefever through analysis of his own training logs. Strong community support with thousands of documented success stories. Aligns with research on tier-based training and autoregulation.',
        ARRAY[
            'https://swoleateveryheight.blogspot.com/2014/07/the-gzcl-method-simplified_13.html',
            'https://www.boostcamp.app/coaches/cody-lefever/gzcl-program-gzclp',
            'https://thefitness.wiki/routines/gzclp/',
            'https://liftvault.com/programs/powerlifting/gzclp-program-spreadsheets/',
            'https://gzcl.substack.com/p/p-zero'
        ],
        NULL
    ),

    -- nSuns 531 LP
    (
        uuid_generate_v1mc(),
        'nSuns 5/3/1 Linear Progression',
        '# nSuns 5/3/1 Linear Progression

A high-volume linear progression powerlifting program inspired by Jim Wendler''s legendary 5/3/1. Created by Reddit user u/nSuns, this program advances weekly instead of monthly, making it ideal for late-stage novice and early intermediate lifters.

## Program Overview

**Training Frequency:** 4 days per week (Bench/OHP, Squat/Sumo DL, OHP/Incline, Deadlift/Front Squat)

**Philosophy:** Very high volume approach with 17 sets per workout before accessories (9 sets main lift + 8 sets variant). Uses AMRAP sets for autoregulation and rapid weekly progression.

## Key Features

- **Extremely High Volume:** 17 compound sets per workout develops work capacity and technical proficiency
- **Weekly Progression:** Add weight every week based on AMRAP performance (much faster than standard 5/3/1)
- **Training Max System:** All percentages based on 90% of true 1RM for sustainable progression
- **AMRAP Autoregulation:** 1+ sets determine next week''s weight increases

## Volume Characteristics

Each workout follows this structure:
- **Main Lift:** 9 sets with varying rep ranges (1x5, 1x3, 1x1+, 1x3, 1x3, 1x5, 1x3, 1x5, 1x3)
- **Variant Lift:** 8 sets (1x6, 1x5, 1x3, 1x5, 1x7, 1x4, 1x6, 1x8)
- **Accessories:** 3-5 exercises at 8-12 reps (user-selected)

## Progression System

**Training Max (TM) = 90% of your true 1RM**

Based on AMRAP set performance:
- **2-3 reps:** +5 lbs upper / +10 lbs lower
- **4-5 reps:** +5-10 lbs upper / +10-15 lbs lower
- **6+ reps:** +10-15 lbs upper / +15-20 lbs lower

## Percentages

Main lifts use: 75%, 85%, 95%+, 90%, 85%, 80%, 75%, 70%, 65% of Training Max

Variant lifts vary by day but typically 40-70% of the main lift''s TM.

## Rest Periods

- Main lifts: 2-3 minutes
- Accessories: 1-2 minutes

## Best For

- Late novice to early intermediate lifters
- Those who can handle high volume
- Athletes wanting rapid strength gains
- 4-6 days per week commitment
- 1-2 hour training sessions

## Program Duration

Typical run: 3-6 months before linear progression stalls. Deload every 6-7 weeks. After stalling, transition to slower progression programs.

## Evidence Base

Built on Jim Wendler''s proven 5/3/1 methodology. Massive community validation with thousands of documented results on Reddit and fitness forums. High volume aligns with hypertrophy research (10-20 sets per muscle per week).',
        ARRAY[
            'https://liftvault.com/programs/powerlifting/n-suns-lifting-spreadsheets/',
            'https://www.boostcamp.app/nsuns-531-powerlifting-program',
            'https://fitnessvolt.com/nsuns-program/',
            'https://www.drworkout.fitness/nsuns-programs-with-spreadsheet/',
            'https://muscleevo.net/nsuns-program/'
        ],
        NULL
    ),

    -- PHUL
    (
        uuid_generate_v1mc(),
        'PHUL - Power Hypertrophy Upper Lower',
        '# PHUL - Power Hypertrophy Upper Lower

A 4-day training program that combines powerlifting-style training with bodybuilding hypertrophy work in an upper/lower split. Created by Brandon Campbell in 2013, PHUL has become one of the most widely used powerbuilding programs.

## Program Overview

**Training Frequency:** 4 days per week
- Day 1: Upper Power
- Day 2: Lower Power
- Day 3: Rest
- Day 4: Upper Hypertrophy
- Day 5: Lower Hypertrophy
- Days 6-7: Rest

**Philosophy:** Each major muscle group is trained twice per week - once with heavy weights and low reps (power), and once with moderate weights and higher reps (hypertrophy). This dual stimulus maximizes both strength and muscle growth.

## Key Features

- **Dual Frequency:** Hit each muscle 2x per week for optimal growth
- **Clear Power/Hypertrophy Split:** Power days (3-5 reps) build strength, Hypertrophy days (8-12 reps) build size
- **RPE 9 Target:** Train with 1 rep left in reserve - avoid failure for better recovery
- **Progressive Overload:** Simple progression system based on achieving target reps

## Power vs Hypertrophy Days

**Power Days (Days 1-2):**
- Heavy compound movements
- 3-5 reps per set
- 3-5 min rest periods
- RPE 9 intensity
- Focus: Maximal strength

**Hypertrophy Days (Days 4-5):**
- Moderate weights
- 8-15 reps per set
- 1-2 min rest periods
- Focus: Muscle contraction quality
- Goal: Muscle growth and volume

## Progression System

**Power Days:**
- When you complete all sets at top of range (e.g., 4x5), add weight
- Upper body: +5 lbs
- Lower body: +10 lbs

**Hypertrophy Days:**
- When you complete all sets for 12 reps, add weight
- Upper body: +2.5-5 lbs
- Lower body: +5-10 lbs

## Rest Periods

- Power exercises: 3-5 minutes
- Hypertrophy exercises: 1-2 minutes

## Best For

- Intermediate lifters (1+ year experience)
- Those seeking balanced strength and aesthetics
- 4 days per week commitment
- Athletes who value proven, simple methods

## Program Duration

Minimum: 12 weeks
Typical cycle: 12-16 weeks
Long-term: Can run 6-12 months with periodic deloads

Deload every 6-8 weeks or when feeling excessively fatigued.

## Evidence Base

- Frequency optimization: 2x per week per muscle aligns with hypertrophy research
- Dual stimulus: Heavy + volume work proven effective
- Sustainable volume: 15-20 sets per muscle per week in optimal range
- Recovery-friendly: Rest day between power and hypertrophy allows adequate recovery
- Proven track record: Thousands of successful transformations documented',
        ARRAY[
            'https://www.muscleandstrength.com/workouts/phul-workout',
            'https://www.hevyapp.com/phul-power-hypertrophy-upper-lower/',
            'https://liftvault.com/programs/strength/phul-spreadsheet/',
            'https://www.strengthlog.com/phul-workout-routine/',
            'https://www.boostcamp.app/coaches/brandon-campbell/phul-4-day-split'
        ],
        NULL
    ),

    -- PHAT
    (
        uuid_generate_v1mc(),
        'PHAT - Power Hypertrophy Adaptive Training',
        '# PHAT - Power Hypertrophy Adaptive Training

A 5-day training program developed by Dr. Layne Norton, combining powerlifting and bodybuilding methodologies to maximize both strength and muscle growth. PHAT trains each muscle group twice per week with different stimuli.

## Program Overview

**Training Frequency:** 5 days per week
- Day 1: Upper Body Power
- Day 2: Lower Body Power
- Day 3: Rest
- Day 4: Back and Shoulders Hypertrophy
- Day 5: Lower Body Hypertrophy
- Day 6: Chest and Arms Hypertrophy
- Day 7: Rest

**Philosophy:** Dual-stimulus approach hitting each muscle twice weekly. First with heavy "power" training for strength, then with higher-volume "hypertrophy" training for growth. Includes unique "speed work" on hypertrophy days.

## Key Features

- **Speed Work:** Explosive sets at 65-70% of power day weight for 6-8 sets x 3 reps on hypertrophy days
- **Dual Stimulus:** Power days build maximal strength, hypertrophy days build size and work capacity
- **High Volume:** 50-75% more volume on hypertrophy days compared to power days
- **Scientific Foundation:** Created by PhD scientist with extensive research background

## Power vs Hypertrophy Balance

**Power Days (Days 1-2):**
- Heavy weights: 3-5 reps
- Intensity: 70-80% of 1RM
- Rest: 3-5 minutes
- Focus: Maximal strength development

**Hypertrophy Days (Days 4-6):**
- Speed work: 6-8 sets x 3 reps at 65-70%, 60-90 sec rest
- Volume work: 8-20 reps, 1-2 min rest
- Focus: Muscle size, explosiveness, work capacity

## Progression System

**Power Days:**
- Add weight when completing all sets at top of rep range
- Upper body: +5 lbs
- Lower body: +10 lbs

**Speed Work:**
- Keep at 65-70% of power day weight
- Adjust when power day weight increases
- Focus on bar speed, not weight

**Hypertrophy Volume Work:**
- Upper body: +2.5-5 lbs
- Lower body: +5-10 lbs
- Volume should be 50-75% higher than power days

## Rest Periods

- Power exercises: 3-5 minutes
- Speed work: 60-90 seconds
- Hypertrophy work: 1-2 minutes

## Best For

- Intermediate to advanced lifters
- Those wanting maximum size and strength
- 5 days per week commitment
- Athletes who enjoy high-volume training
- 60-90 minute training sessions

## Program Duration

Recommended cycle: 8-12 weeks before deload or program change
Long-term: Can run 6-12 months with periodic deloads and exercise variations
Deload: Every 6-8 weeks

## Evidence Base

- Created by Dr. Layne Norton (PhD in Nutritional Sciences)
- Proven in competition: Norton succeeded in both powerlifting and natural bodybuilding
- Frequency optimization: 2x per week aligns with research
- Speed work: Explosive training develops power and muscle fiber recruitment
- Volume periodization: Alternates between strength and hypertrophy volumes
- Research-backed: Based on muscle protein synthesis and fatigue management research',
        ARRAY[
            'https://biolayne.com/articles/training/phat-power-hypertrophy-adaptive-training/',
            'https://biolayne.com/phat/',
            'https://liftvault.com/programs/bodybuilding/phat-spreadsheet/',
            'https://barbend.com/phat-training/',
            'https://www.boostcamp.app/coaches/layne-norton/phat',
            'https://www.simplyshredded.com/mega-feature-layne-norton-training-series-full-powerhypertrophy-routine-updated-2011.html'
        ],
        NULL
    ),

    -- Juggernaut Method
    (
        uuid_generate_v1mc(),
        'The Juggernaut Method',
        '# The Juggernaut Method 2.0

A 16-week periodized strength training program created by Chad Wesley Smith, one of the strongest powerlifters in the world. The program uses wave periodization to systematically build strength through four distinct phases.

## Program Overview

**Training Frequency:** 4 days per week (Squat, Bench, Deadlift, OHP focus days)

**Duration:** 16 weeks (4 waves x 4 weeks each)

**Philosophy:** Systematic progression through wave periodization - starting with hypertrophy-focused high reps and progressing to peak strength with low reps. Emphasizes submaximal training to manage CNS fatigue while building work capacity.

## Wave Periodization Structure

**Wave 1 (Weeks 1-4): 10s Phase**
- Focus: Hypertrophy and muscular base
- Rep range: 10+ reps on AMRAP sets
- Intensity: Lower (60-75% TM)

**Wave 2 (Weeks 5-8): 8s Phase**
- Focus: Bridge between hypertrophy and strength
- Rep range: 8+ reps on AMRAP sets
- Intensity: Moderate (62.5-77.5% TM)

**Wave 3 (Weeks 9-12): 5s Phase**
- Focus: Strength development
- Rep range: 5+ reps on AMRAP sets
- Intensity: High (65-85% TM)

**Wave 4 (Weeks 13-16): 3s Phase**
- Focus: Peak strength
- Rep range: 3+ reps on AMRAP sets
- Intensity: Very high (70-90% TM)

## Weekly Structure Within Each Wave

Each wave follows the same weekly pattern:

**Week 1 - Accumulation:** High volume, build fatigue and work capacity
**Week 2 - Intensification:** Increase intensity, reduce volume by 50%+
**Week 3 - Realization:** Peak week, test strength adaptation
**Week 4 - Deload:** Reduce volume/intensity, prepare for next wave

## Key Features

- **AMRAP Autoregulation:** Final set is "as many reps as possible" to individualize progression
- **Training Max System:** All percentages based on 90% of true 1RM (or 105% of proven 5RM)
- **Submaximal Training:** Avoids excessive CNS fatigue while building strength systematically
- **Flexible Assistance Work:** 2-4 exercises per day targeting individual weaknesses

## Progression System

After each wave''s Week 1 AMRAP set, adjust Training Max based on reps achieved:

**Example for 10s Wave:**
- 10-12 reps: +5 lbs upper / +10 lbs lower
- 13-15 reps: +10 lbs upper / +15 lbs lower
- 16+ reps: +15 lbs upper / +20 lbs lower

Similar tables exist for 8s, 5s, and 3s waves with adjusted benchmarks.

## Rest Periods

- Main lifts: 2-3 minutes
- Assistance work: 1-2 minutes
- AMRAP sets: Take as much rest as needed before the final set

## Best For

- Intermediate to advanced lifters
- Those wanting periodized, systematic progression
- Athletes who prefer structured 16-week cycles
- Lifters seeking submaximal training and longevity
- 4 days per week commitment

## Program Duration

Fixed 16-week cycle. After completion:
- Option 1: Test new 1RMs and start fresh cycle
- Option 2: Take 1-2 week deload and begin another cycle
- Can run back-to-back cycles for 6-12 months

## Evidence Base

- Created by elite powerlifter Chad Wesley Smith
- Wave periodization backed by sports science research
- Submaximal training shown to build strength while managing fatigue
- AMRAP autoregulation individualizes progression
- Systematic progression from hypertrophy to peak strength
- Used successfully by powerlifters, weightlifters, and strength athletes worldwide',
        ARRAY[
            'https://liftvault.com/programs/strength/juggernaut-method-base-template-spreadsheet/',
            'https://www.amazon.com/Juggernaut-Method-2-0-Strength-Athlete-ebook/dp/B00DRIYWBU',
            'https://www.jtsstrength.com/',
            'https://steelsupplements.com/blogs/steel-blog/juggernaut-training-method-overview-program-spreadsheet',
            'https://www.powerliftingtowin.com/the-juggernaut-method/',
            'https://physiqz.com/workout-routines/powerlifting-programs/juggernaut-method-strength-training/'
        ],
        NULL
    )
ON CONFLICT (plan_id) DO NOTHING;

-- ============================================================================
-- SESSION SCHEDULES (Workout Days/Sessions within Programs)
-- ============================================================================

-- Get plan IDs for reference
DO $$
DECLARE
    gzcl_plan_id uuid;
    nsuns_plan_id uuid;
    phul_plan_id uuid;
    phat_plan_id uuid;
    jugg_plan_id uuid;
BEGIN
    -- Get the plan IDs we just created
    SELECT plan_id INTO gzcl_plan_id FROM plan WHERE name = 'GZCL Method (GZCLP)';
    SELECT plan_id INTO nsuns_plan_id FROM plan WHERE name = 'nSuns 5/3/1 Linear Progression';
    SELECT plan_id INTO phul_plan_id FROM plan WHERE name = 'PHUL - Power Hypertrophy Upper Lower';
    SELECT plan_id INTO phat_plan_id FROM plan WHERE name = 'PHAT - Power Hypertrophy Adaptive Training';
    SELECT plan_id INTO jugg_plan_id FROM plan WHERE name = 'The Juggernaut Method';

    -- GZCL Session Schedules (4-day version)
    INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
    VALUES
        (uuid_generate_v1mc(), gzcl_plan_id, 'Day A1 - Squat Focus', 'T1 Squat, T2 Bench Press, T3 Back accessories', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), gzcl_plan_id, 'Day B1 - OHP Focus', 'T1 Overhead Press, T2 Deadlift, T3 Arms', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), gzcl_plan_id, 'Day A2 - Bench Focus', 'T1 Bench Press, T2 Squat, T3 Back accessories', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), gzcl_plan_id, 'Day B2 - Deadlift Focus', 'T1 Deadlift, T2 Overhead Press, T3 Arms', 1.0, NULL, NULL)
    ON CONFLICT (session_schedule_id) DO NOTHING;

    -- nSuns Session Schedules (4-day version)
    INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
    VALUES
        (uuid_generate_v1mc(), nsuns_plan_id, 'Day 1: Bench Press / OHP', '9 sets bench press, 8 sets OHP, accessories', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), nsuns_plan_id, 'Day 2: Squat / Sumo Deadlift', '9 sets squat, 8 sets sumo deadlift, accessories', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), nsuns_plan_id, 'Day 3: OHP / Incline Bench', '9 sets OHP, 8 sets incline bench, accessories', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), nsuns_plan_id, 'Day 4: Deadlift / Front Squat', '9 sets deadlift, 8 sets front squat, accessories', 1.0, NULL, NULL)
    ON CONFLICT (session_schedule_id) DO NOTHING;

    -- PHUL Session Schedules
    INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
    VALUES
        (uuid_generate_v1mc(), phul_plan_id, 'Day 1: Upper Power', 'Heavy compound upper body movements, 3-5 reps', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), phul_plan_id, 'Day 2: Lower Power', 'Heavy compound lower body movements, 3-5 reps', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), phul_plan_id, 'Day 4: Upper Hypertrophy', 'Moderate weight upper body, 8-12 reps', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), phul_plan_id, 'Day 5: Lower Hypertrophy', 'Moderate weight lower body, 8-12 reps', 1.0, NULL, NULL)
    ON CONFLICT (session_schedule_id) DO NOTHING;

    -- PHAT Session Schedules
    INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
    VALUES
        (uuid_generate_v1mc(), phat_plan_id, 'Day 1: Upper Body Power', 'Heavy upper body power work, 3-10 reps', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), phat_plan_id, 'Day 2: Lower Body Power', 'Heavy lower body power work, 3-10 reps', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), phat_plan_id, 'Day 4: Back and Shoulders Hypertrophy', 'Speed work + volume work, 3-20 reps', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), phat_plan_id, 'Day 5: Lower Body Hypertrophy', 'Speed work + volume work, 3-20 reps', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), phat_plan_id, 'Day 6: Chest and Arms Hypertrophy', 'Speed work + volume work, 3-20 reps', 1.0, NULL, NULL)
    ON CONFLICT (session_schedule_id) DO NOTHING;

    -- Juggernaut Method Session Schedules
    INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
    VALUES
        (uuid_generate_v1mc(), jugg_plan_id, 'Day 1: Squat Focus', 'Main squat work + assistance exercises', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), jugg_plan_id, 'Day 2: Bench Press Focus', 'Main bench work + assistance exercises', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), jugg_plan_id, 'Day 3: Deadlift Focus', 'Main deadlift work + assistance exercises', 1.0, NULL, NULL),
        (uuid_generate_v1mc(), jugg_plan_id, 'Day 4: Overhead Press Focus', 'Main OHP work + assistance exercises', 1.0, NULL, NULL)
    ON CONFLICT (session_schedule_id) DO NOTHING;

END $$;

-- ============================================================================
-- EXERCISES (Exercise configurations within session schedules)
-- ============================================================================
-- Note: This section creates the exercise entries for each program
-- We'll reference base exercises that already exist in the database
-- ============================================================================

-- Get session schedule IDs and create exercises
DO $$
DECLARE
    -- GZCL sessions
    gzcl_a1_id uuid;
    gzcl_b1_id uuid;
    gzcl_a2_id uuid;
    gzcl_b2_id uuid;

    -- nSuns sessions
    nsuns_day1_id uuid;
    nsuns_day2_id uuid;
    nsuns_day3_id uuid;
    nsuns_day4_id uuid;

    -- PHUL sessions
    phul_upper_power_id uuid;
    phul_lower_power_id uuid;
    phul_upper_hyp_id uuid;
    phul_lower_hyp_id uuid;

    -- PHAT sessions
    phat_upper_power_id uuid;
    phat_lower_power_id uuid;
    phat_back_shoulders_id uuid;
    phat_lower_hyp_id uuid;
    phat_chest_arms_id uuid;

    -- Juggernaut sessions
    jugg_squat_id uuid;
    jugg_bench_id uuid;
    jugg_deadlift_id uuid;
    jugg_ohp_id uuid;

    -- Base exercise IDs (from existing database)
    ex_squat uuid;
    ex_bench uuid;
    ex_deadlift uuid;
    ex_ohp uuid;
    ex_lat_pulldown uuid;
    ex_dumbbell_row uuid;
    ex_bicep_curl uuid;
    ex_tricep_ext uuid;
    ex_front_squat uuid;
    ex_incline_press uuid;
    ex_romanian_dl uuid;
    ex_leg_press uuid;
    ex_leg_curl uuid;
    ex_leg_ext uuid;
    ex_calf_raise uuid;
    ex_barbell_row uuid;
    ex_lateral_raise uuid;
    ex_pullups uuid;
    ex_dips uuid;
    ex_sumo_deadlift uuid;
    ex_close_grip_bench uuid;
    ex_face_pulls uuid;
    ex_preacher_curl uuid;
    ex_hammer_curl uuid;
    ex_lying_tricep_ext uuid;
    ex_cable_row uuid;
    ex_dumbbell_flyes uuid;
    ex_upright_row uuid;
    ex_walking_lunge uuid;
    ex_seated_calf uuid;
    ex_incline_db_press uuid;
    ex_cable_crossover uuid;
    ex_spider_curl uuid;
    ex_cable_pressdown uuid;
    ex_incline_db_curl uuid;
    ex_shrug uuid;
    ex_glute_ham_raise uuid;
    ex_push_press uuid;
    ex_pause_squat uuid;
    ex_good_morning uuid;

BEGIN
    -- Get session schedule IDs
    SELECT session_schedule_id INTO gzcl_a1_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'GZCL Method (GZCLP)' AND ss.name = 'Day A1 - Squat Focus';
    SELECT session_schedule_id INTO gzcl_b1_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'GZCL Method (GZCLP)' AND ss.name = 'Day B1 - OHP Focus';
    SELECT session_schedule_id INTO gzcl_a2_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'GZCL Method (GZCLP)' AND ss.name = 'Day A2 - Bench Focus';
    SELECT session_schedule_id INTO gzcl_b2_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'GZCL Method (GZCLP)' AND ss.name = 'Day B2 - Deadlift Focus';

    SELECT session_schedule_id INTO nsuns_day1_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'nSuns 5/3/1 Linear Progression' AND ss.name = 'Day 1: Bench Press / OHP';
    SELECT session_schedule_id INTO nsuns_day2_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'nSuns 5/3/1 Linear Progression' AND ss.name = 'Day 2: Squat / Sumo Deadlift';
    SELECT session_schedule_id INTO nsuns_day3_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'nSuns 5/3/1 Linear Progression' AND ss.name = 'Day 3: OHP / Incline Bench';
    SELECT session_schedule_id INTO nsuns_day4_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'nSuns 5/3/1 Linear Progression' AND ss.name = 'Day 4: Deadlift / Front Squat';

    SELECT session_schedule_id INTO phul_upper_power_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHUL - Power Hypertrophy Upper Lower' AND ss.name = 'Day 1: Upper Power';
    SELECT session_schedule_id INTO phul_lower_power_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHUL - Power Hypertrophy Upper Lower' AND ss.name = 'Day 2: Lower Power';
    SELECT session_schedule_id INTO phul_upper_hyp_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHUL - Power Hypertrophy Upper Lower' AND ss.name = 'Day 4: Upper Hypertrophy';
    SELECT session_schedule_id INTO phul_lower_hyp_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHUL - Power Hypertrophy Upper Lower' AND ss.name = 'Day 5: Lower Hypertrophy';

    SELECT session_schedule_id INTO phat_upper_power_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHAT - Power Hypertrophy Adaptive Training' AND ss.name = 'Day 1: Upper Body Power';
    SELECT session_schedule_id INTO phat_lower_power_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHAT - Power Hypertrophy Adaptive Training' AND ss.name = 'Day 2: Lower Body Power';
    SELECT session_schedule_id INTO phat_back_shoulders_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHAT - Power Hypertrophy Adaptive Training' AND ss.name = 'Day 4: Back and Shoulders Hypertrophy';
    SELECT session_schedule_id INTO phat_lower_hyp_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHAT - Power Hypertrophy Adaptive Training' AND ss.name = 'Day 5: Lower Body Hypertrophy';
    SELECT session_schedule_id INTO phat_chest_arms_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'PHAT - Power Hypertrophy Adaptive Training' AND ss.name = 'Day 6: Chest and Arms Hypertrophy';

    SELECT session_schedule_id INTO jugg_squat_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'The Juggernaut Method' AND ss.name = 'Day 1: Squat Focus';
    SELECT session_schedule_id INTO jugg_bench_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'The Juggernaut Method' AND ss.name = 'Day 2: Bench Press Focus';
    SELECT session_schedule_id INTO jugg_deadlift_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'The Juggernaut Method' AND ss.name = 'Day 3: Deadlift Focus';
    SELECT session_schedule_id INTO jugg_ohp_id FROM session_schedule ss JOIN plan p ON ss.plan_id = p.plan_id WHERE p.name = 'The Juggernaut Method' AND ss.name = 'Day 4: Overhead Press Focus';

    -- Get base exercise IDs
    SELECT base_exercise_id INTO ex_squat FROM base_exercise WHERE name = 'Squat';
    SELECT base_exercise_id INTO ex_bench FROM base_exercise WHERE name = 'Bench press';
    SELECT base_exercise_id INTO ex_deadlift FROM base_exercise WHERE name = 'Deadlift';
    SELECT base_exercise_id INTO ex_ohp FROM base_exercise WHERE name = 'Overhead press';
    SELECT base_exercise_id INTO ex_lat_pulldown FROM base_exercise WHERE name = 'Lat pulldown';
    SELECT base_exercise_id INTO ex_bicep_curl FROM base_exercise WHERE name = 'Bicep curl';
    SELECT base_exercise_id INTO ex_front_squat FROM base_exercise WHERE name = 'Front Squat';
    SELECT base_exercise_id INTO ex_incline_press FROM base_exercise WHERE name = 'Incline chest press';
    SELECT base_exercise_id INTO ex_romanian_dl FROM base_exercise WHERE name = 'Romanian Deadlift';
    SELECT base_exercise_id INTO ex_leg_press FROM base_exercise WHERE name = 'Leg Press';
    SELECT base_exercise_id INTO ex_leg_curl FROM base_exercise WHERE name = 'Hamstring curl';
    SELECT base_exercise_id INTO ex_leg_ext FROM base_exercise WHERE name = 'Leg Extension';
    SELECT base_exercise_id INTO ex_calf_raise FROM base_exercise WHERE name = 'Calf raise';
    SELECT base_exercise_id INTO ex_barbell_row FROM base_exercise WHERE name = 'Barbell Row';
    SELECT base_exercise_id INTO ex_lateral_raise FROM base_exercise WHERE name = 'Lateral raise';
    SELECT base_exercise_id INTO ex_pullups FROM base_exercise WHERE name = 'Pull-ups';
    SELECT base_exercise_id INTO ex_dips FROM base_exercise WHERE name = 'Dips';
    SELECT base_exercise_id INTO ex_sumo_deadlift FROM base_exercise WHERE name = 'Sumo Deadlifts';
    SELECT base_exercise_id INTO ex_close_grip_bench FROM base_exercise WHERE name = 'Close-Grip Bench Press';
    SELECT base_exercise_id INTO ex_tricep_ext FROM base_exercise WHERE name = 'Overhead tricep extension';
    SELECT base_exercise_id INTO ex_dumbbell_row FROM base_exercise WHERE name = 'Dumbbell Row';
    SELECT base_exercise_id INTO ex_face_pulls FROM base_exercise WHERE name = 'Face Pulls';
    SELECT base_exercise_id INTO ex_preacher_curl FROM base_exercise WHERE name = 'Preacher Curls';
    SELECT base_exercise_id INTO ex_hammer_curl FROM base_exercise WHERE name = 'Hammer Curls';
    SELECT base_exercise_id INTO ex_lying_tricep_ext FROM base_exercise WHERE name = 'Lying Tricep Extensions';
    SELECT base_exercise_id INTO ex_cable_row FROM base_exercise WHERE name = 'Seated pulley row';
    SELECT base_exercise_id INTO ex_dumbbell_flyes FROM base_exercise WHERE name = 'Dumbbell Flyes';
    SELECT base_exercise_id INTO ex_upright_row FROM base_exercise WHERE name = 'Upright Rows';
    SELECT base_exercise_id INTO ex_walking_lunge FROM base_exercise WHERE name = 'Walking Lunges';
    SELECT base_exercise_id INTO ex_seated_calf FROM base_exercise WHERE name = 'Seated Calf Raise';
    SELECT base_exercise_id INTO ex_incline_db_press FROM base_exercise WHERE name = 'Dumbbell incline press';
    SELECT base_exercise_id INTO ex_cable_crossover FROM base_exercise WHERE name = 'Cable Crossovers';
    SELECT base_exercise_id INTO ex_spider_curl FROM base_exercise WHERE name = 'Spider Curls';
    SELECT base_exercise_id INTO ex_cable_pressdown FROM base_exercise WHERE name = 'Tricep Pushdowns';
    SELECT base_exercise_id INTO ex_incline_db_curl FROM base_exercise WHERE name = 'Incline Dumbbell Curls';
    SELECT base_exercise_id INTO ex_shrug FROM base_exercise WHERE name = 'Shrug';
    SELECT base_exercise_id INTO ex_glute_ham_raise FROM base_exercise WHERE name = 'Glute-Ham Raise';
    SELECT base_exercise_id INTO ex_push_press FROM base_exercise WHERE name = 'Push Press';
    SELECT base_exercise_id INTO ex_pause_squat FROM base_exercise WHERE name = 'Pause Squats';
    SELECT base_exercise_id INTO ex_good_morning FROM base_exercise WHERE name = 'Good Mornings';

    -- ========================================================================
    -- GZCL EXERCISES
    -- ========================================================================

    -- GZCL Day A1: Squat Focus
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        -- T1: Squat
        (uuid_generate_v1mc(), ex_squat, gzcl_a1_id, 3, 5, '00:04:00', 1000, 5000, 'T1 Main Lift: Heavy squats at ~85-100% of 2-3RM. Final set is AMRAP. Add 10 lbs per workout.', NULL, NULL),
        -- T2: Bench Press
        (uuid_generate_v1mc(), ex_bench, gzcl_a1_id, 10, 3, '00:02:30', 2000, 2500, 'T2 Secondary Lift: Moderate weight bench press at ~65-75% 1RM. Final set is AMRAP.', NULL, NULL),
        -- T3: Lat Pulldown
        (uuid_generate_v1mc(), ex_lat_pulldown, gzcl_a1_id, 15, 3, '00:01:30', 3000, 2500, 'T3 Accessory: Light weight for 15+ reps. Final set AMRAP, add weight when you hit 25+ reps.', NULL, NULL),
        -- T3: Dumbbell Row
        (uuid_generate_v1mc(), ex_dumbbell_row, gzcl_a1_id, 15, 3, '00:01:30', 4000, 2500, 'T3 Accessory: Light weight for 15+ reps. Final set AMRAP, add weight when you hit 25+ reps.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- GZCL Day B1: OHP Focus
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        -- T1: Overhead Press
        (uuid_generate_v1mc(), ex_ohp, gzcl_b1_id, 3, 5, '00:04:00', 1000, 2500, 'T1 Main Lift: Heavy OHP at ~85-100% of 2-3RM. Final set is AMRAP. Add 5 lbs per workout.', NULL, NULL),
        -- T2: Deadlift
        (uuid_generate_v1mc(), ex_deadlift, gzcl_b1_id, 10, 3, '00:02:30', 2000, 5000, 'T2 Secondary Lift: Moderate weight deadlift at ~65-75% 1RM. Final set is AMRAP.', NULL, NULL),
        -- T3: Bicep Curl
        (uuid_generate_v1mc(), ex_bicep_curl, gzcl_b1_id, 15, 3, '00:01:30', 3000, 2500, 'T3 Accessory: Light weight for 15+ reps. Final set AMRAP, add weight when you hit 25+ reps.', NULL, NULL),
        -- T3: Tricep Extension
        (uuid_generate_v1mc(), ex_tricep_ext, gzcl_b1_id, 15, 3, '00:01:30', 4000, 2500, 'T3 Accessory: Light weight for 15+ reps. Final set AMRAP, add weight when you hit 25+ reps.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- GZCL Day A2: Bench Focus
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        -- T1: Bench Press
        (uuid_generate_v1mc(), ex_bench, gzcl_a2_id, 3, 5, '00:04:00', 1000, 2500, 'T1 Main Lift: Heavy bench press at ~85-100% of 2-3RM. Final set is AMRAP. Add 5 lbs per workout.', NULL, NULL),
        -- T2: Squat
        (uuid_generate_v1mc(), ex_squat, gzcl_a2_id, 10, 3, '00:02:30', 2000, 5000, 'T2 Secondary Lift: Moderate weight squat at ~65-75% 1RM. Final set is AMRAP.', NULL, NULL),
        -- T3: Lat Pulldown
        (uuid_generate_v1mc(), ex_lat_pulldown, gzcl_a2_id, 15, 3, '00:01:30', 3000, 2500, 'T3 Accessory: Light weight for 15+ reps. Final set AMRAP, add weight when you hit 25+ reps.', NULL, NULL),
        -- T3: Dumbbell Row
        (uuid_generate_v1mc(), ex_dumbbell_row, gzcl_a2_id, 15, 3, '00:01:30', 4000, 2500, 'T3 Accessory: Light weight for 15+ reps. Final set AMRAP, add weight when you hit 25+ reps.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- GZCL Day B2: Deadlift Focus
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        -- T1: Deadlift
        (uuid_generate_v1mc(), ex_deadlift, gzcl_b2_id, 3, 5, '00:04:00', 1000, 5000, 'T1 Main Lift: Heavy deadlift at ~85-100% of 2-3RM. Final set is AMRAP. Add 10 lbs per workout.', NULL, NULL),
        -- T2: Overhead Press
        (uuid_generate_v1mc(), ex_ohp, gzcl_b2_id, 10, 3, '00:02:30', 2000, 2500, 'T2 Secondary Lift: Moderate weight OHP at ~65-75% 1RM. Final set is AMRAP.', NULL, NULL),
        -- T3: Bicep Curl
        (uuid_generate_v1mc(), ex_bicep_curl, gzcl_b2_id, 15, 3, '00:01:30', 3000, 2500, 'T3 Accessory: Light weight for 15+ reps. Final set AMRAP, add weight when you hit 25+ reps.', NULL, NULL),
        -- T3: Tricep Extension
        (uuid_generate_v1mc(), ex_tricep_ext, gzcl_b2_id, 15, 3, '00:01:30', 4000, 2500, 'T3 Accessory: Light weight for 15+ reps. Final set AMRAP, add weight when you hit 25+ reps.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- ========================================================================
    -- nSuns EXERCISES
    -- ========================================================================
    -- Note: nSuns has complex percentage-based sets. We'll use representative
    -- rep ranges. In practice, users would follow the percentage scheme.
    -- ========================================================================

    -- nSuns Day 1: Bench Press / OHP
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        -- Bench Press (9 sets with varying reps)
        (uuid_generate_v1mc(), ex_bench, nsuns_day1_id, 5, 1, '00:02:30', 1000, 2500, 'Set 1: 5 reps at 75% TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_bench, nsuns_day1_id, 3, 1, '00:02:30', 1100, 2500, 'Set 2: 3 reps at 85% TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_bench, nsuns_day1_id, 1, 1, '00:02:30', 1200, 2500, 'Set 3: 1+ reps AMRAP at 95% TM - determines progression', NULL, NULL),
        (uuid_generate_v1mc(), ex_bench, nsuns_day1_id, 3, 6, '00:02:30', 1300, 2500, 'Sets 4-9: Back-off sets at varying percentages (90%, 85%, 80%, 75%, 70%, 65% for 3-5 reps each)', NULL, NULL),
        -- OHP (8 sets)
        (uuid_generate_v1mc(), ex_ohp, nsuns_day1_id, 6, 1, '00:02:00', 2000, 2500, 'Set 1: 6 reps at 50% of Bench TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_ohp, nsuns_day1_id, 5, 1, '00:02:00', 2100, 2500, 'Set 2: 5 reps at 60% of Bench TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_ohp, nsuns_day1_id, 5, 6, '00:02:00', 2200, 2500, 'Sets 3-8: Volume work at 70% of Bench TM (3-8 reps per set)', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- nSuns Day 2: Squat / Sumo Deadlift
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        -- Squat (9 sets)
        (uuid_generate_v1mc(), ex_squat, nsuns_day2_id, 5, 1, '00:03:00', 1000, 5000, 'Set 1: 5 reps at 75% TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_squat, nsuns_day2_id, 3, 1, '00:03:00', 1100, 5000, 'Set 2: 3 reps at 85% TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_squat, nsuns_day2_id, 1, 1, '00:03:00', 1200, 5000, 'Set 3: 1+ reps AMRAP at 95% TM - determines progression', NULL, NULL),
        (uuid_generate_v1mc(), ex_squat, nsuns_day2_id, 3, 6, '00:03:00', 1300, 5000, 'Sets 4-9: Back-off sets at varying percentages', NULL, NULL),
        -- Sumo Deadlift (8 sets)
        (uuid_generate_v1mc(), ex_sumo_deadlift, nsuns_day2_id, 5, 2, '00:02:30', 2000, 5000, 'Sets 1-2: 5 reps at 50-60% of Squat TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_sumo_deadlift, nsuns_day2_id, 5, 6, '00:02:30', 2100, 5000, 'Sets 3-8: Volume work at 70% of Squat TM (3-8 reps per set)', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- nSuns Day 3: OHP / Incline Bench
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        -- OHP (9 sets)
        (uuid_generate_v1mc(), ex_ohp, nsuns_day3_id, 5, 1, '00:02:30', 1000, 2500, 'Set 1: 5 reps at 75% TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_ohp, nsuns_day3_id, 3, 1, '00:02:30', 1100, 2500, 'Set 2: 3 reps at 85% TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_ohp, nsuns_day3_id, 1, 1, '00:02:30', 1200, 2500, 'Set 3: 1+ reps AMRAP at 95% TM - determines progression', NULL, NULL),
        (uuid_generate_v1mc(), ex_ohp, nsuns_day3_id, 4, 6, '00:02:30', 1300, 2500, 'Sets 4-9: Back-off sets (3-5 reps each)', NULL, NULL),
        -- Incline Bench (8 sets)
        (uuid_generate_v1mc(), ex_incline_press, nsuns_day3_id, 6, 1, '00:02:00', 2000, 2500, 'Set 1: 6 reps at 40% of OHP TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_incline_press, nsuns_day3_id, 5, 1, '00:02:00', 2100, 2500, 'Set 2: 5 reps at 50% of OHP TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_incline_press, nsuns_day3_id, 5, 6, '00:02:00', 2200, 2500, 'Sets 3-8: Volume work at 60% of OHP TM (3-8 reps per set)', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- nSuns Day 4: Deadlift / Front Squat
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        -- Deadlift (9 sets)
        (uuid_generate_v1mc(), ex_deadlift, nsuns_day4_id, 5, 1, '00:03:00', 1000, 5000, 'Set 1: 5 reps at 75% TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_deadlift, nsuns_day4_id, 3, 1, '00:03:00', 1100, 5000, 'Set 2: 3 reps at 85% TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_deadlift, nsuns_day4_id, 1, 1, '00:03:00', 1200, 5000, 'Set 3: 1+ reps AMRAP at 95% TM - determines progression', NULL, NULL),
        (uuid_generate_v1mc(), ex_deadlift, nsuns_day4_id, 3, 6, '00:03:00', 1300, 5000, 'Sets 4-9: Back-off sets all at 3 reps', NULL, NULL),
        -- Front Squat (8 sets)
        (uuid_generate_v1mc(), ex_front_squat, nsuns_day4_id, 5, 2, '00:02:30', 2000, 5000, 'Sets 1-2: 5 reps at 35-45% of Deadlift TM', NULL, NULL),
        (uuid_generate_v1mc(), ex_front_squat, nsuns_day4_id, 5, 6, '00:02:30', 2100, 5000, 'Sets 3-8: Volume work at 55% of Deadlift TM (3-8 reps per set)', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- ========================================================================
    -- PHUL EXERCISES
    -- ========================================================================

    -- PHUL Day 1: Upper Power
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_bench, phul_upper_power_id, 4, 4, '00:04:00', 1000, 2500, 'Barbell Bench Press: 3-5 reps. Primary chest/triceps/shoulders strength builder.', NULL, NULL),
        (uuid_generate_v1mc(), ex_barbell_row, phul_upper_power_id, 4, 4, '00:04:00', 2000, 2500, 'Barbell Bent-Over Row: 3-5 reps. Primary back/biceps strength builder.', NULL, NULL),
        (uuid_generate_v1mc(), ex_ohp, phul_upper_power_id, 6, 4, '00:03:30', 3000, 2500, 'Overhead Press: 5-8 reps. Shoulder strength and mass.', NULL, NULL),
        (uuid_generate_v1mc(), ex_lat_pulldown, phul_upper_power_id, 8, 4, '00:02:30', 4000, 2500, 'Lat Pulldown or Pull-Ups: 6-10 reps. Back width and biceps.', NULL, NULL),
        (uuid_generate_v1mc(), ex_bicep_curl, phul_upper_power_id, 8, 3, '00:02:00', 5000, 2500, 'Barbell Curl: 6-10 reps. Biceps strength.', NULL, NULL),
        (uuid_generate_v1mc(), ex_lying_tricep_ext, phul_upper_power_id, 8, 3, '00:02:00', 6000, 2500, 'Skullcrusher or Tricep Extension: 6-10 reps. Triceps strength.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- PHUL Day 2: Lower Power
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_squat, phul_lower_power_id, 4, 4, '00:04:00', 1000, 5000, 'Barbell Squat: 3-5 reps. Primary leg strength builder.', NULL, NULL),
        (uuid_generate_v1mc(), ex_deadlift, phul_lower_power_id, 4, 4, '00:04:00', 2000, 5000, 'Barbell Deadlift: 3-5 reps. Posterior chain strength, overall power.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_press, phul_lower_power_id, 12, 4, '00:02:30', 3000, 5000, 'Leg Press: 10-15 reps. Quad volume work.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_curl, phul_lower_power_id, 8, 4, '00:02:00', 4000, 2500, 'Leg Curl: 6-10 reps. Hamstring isolation.', NULL, NULL),
        (uuid_generate_v1mc(), ex_calf_raise, phul_lower_power_id, 8, 4, '00:01:30', 5000, 2500, 'Calf Exercise (Standing or Seated): 6-10 reps. Calf strength and size.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- PHUL Day 4: Upper Hypertrophy
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_incline_press, phul_upper_hyp_id, 10, 4, '00:01:30', 1000, 2500, 'Incline Barbell Bench Press: 8-12 reps. Upper chest development.', NULL, NULL),
        (uuid_generate_v1mc(), ex_dumbbell_flyes, phul_upper_hyp_id, 10, 4, '00:01:30', 2000, 2500, 'Flat Bench Dumbbell Flye: 8-12 reps. Chest stretch and contraction.', NULL, NULL),
        (uuid_generate_v1mc(), ex_cable_row, phul_upper_hyp_id, 10, 4, '00:01:30', 3000, 2500, 'Seated Cable Row: 8-12 reps. Back thickness.', NULL, NULL),
        (uuid_generate_v1mc(), ex_dumbbell_row, phul_upper_hyp_id, 10, 4, '00:01:30', 4000, 2500, 'One-Arm Dumbbell Row: 8-12 reps. Back detail and imbalance correction.', NULL, NULL),
        (uuid_generate_v1mc(), ex_lateral_raise, phul_upper_hyp_id, 10, 4, '00:01:30', 5000, 2500, 'Dumbbell Lateral Raise: 8-12 reps. Shoulder width (lateral delts).', NULL, NULL),
        (uuid_generate_v1mc(), ex_incline_db_curl, phul_upper_hyp_id, 10, 4, '00:01:30', 6000, 2500, 'Seated Incline Dumbbell Curl: 8-12 reps. Biceps hypertrophy.', NULL, NULL),
        (uuid_generate_v1mc(), ex_cable_pressdown, phul_upper_hyp_id, 10, 4, '00:01:30', 7000, 2500, 'Cable Tricep Extension: 8-12 reps. Triceps hypertrophy.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- PHUL Day 5: Lower Hypertrophy
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_front_squat, phul_lower_hyp_id, 10, 4, '00:02:30', 1000, 5000, 'Front Squat: 8-12 reps. Quad-focused squat variation.', NULL, NULL),
        (uuid_generate_v1mc(), ex_walking_lunge, phul_lower_hyp_id, 10, 4, '00:02:00', 2000, 2500, 'Barbell Lunge: 8-12 reps. Unilateral leg development.', NULL, NULL),
        (uuid_generate_v1mc(), ex_romanian_dl, phul_lower_hyp_id, 10, 4, '00:02:30', 3000, 5000, 'Romanian Deadlift: 8-12 reps. Hamstring and glute hypertrophy.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_curl, phul_lower_hyp_id, 12, 4, '00:01:30', 4000, 2500, 'Leg Curl: 8-15 reps. Hamstring isolation.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_ext, phul_lower_hyp_id, 12, 4, '00:01:30', 5000, 2500, 'Leg Extension: 8-15 reps. Quad isolation.', NULL, NULL),
        (uuid_generate_v1mc(), ex_calf_raise, phul_lower_hyp_id, 12, 4, '00:01:30', 6000, 2500, 'Seated or Standing Calf Raise: 8-15 reps. Calf hypertrophy.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- ========================================================================
    -- PHAT EXERCISES
    -- ========================================================================

    -- PHAT Day 1: Upper Body Power
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_barbell_row, phat_upper_power_id, 4, 3, '00:04:00', 1000, 2500, 'Bent-Over Row or Pendlay Row: 3-5 reps. Back power and thickness.', NULL, NULL),
        (uuid_generate_v1mc(), ex_pullups, phat_upper_power_id, 8, 2, '00:03:30', 2000, 2500, 'Weighted Pull-Ups: 6-10 reps. Back width and strength.', NULL, NULL),
        (uuid_generate_v1mc(), ex_bench, phat_upper_power_id, 4, 3, '00:04:00', 3000, 2500, 'Barbell Bench Press: 3-5 reps. Chest power.', NULL, NULL),
        (uuid_generate_v1mc(), ex_dips, phat_upper_power_id, 8, 2, '00:02:30', 4000, 2500, 'Weighted Dips: 6-10 reps. Chest and triceps power.', NULL, NULL),
        (uuid_generate_v1mc(), ex_ohp, phat_upper_power_id, 4, 3, '00:03:30', 5000, 2500, 'Seated Barbell Overhead Press: 3-5 reps. Shoulder power.', NULL, NULL),
        (uuid_generate_v1mc(), ex_bicep_curl, phat_upper_power_id, 4, 3, '00:02:30', 6000, 2500, 'Barbell Curl: 3-5 reps. Biceps strength.', NULL, NULL),
        (uuid_generate_v1mc(), ex_lying_tricep_ext, phat_upper_power_id, 8, 3, '00:02:00', 7000, 2500, 'Skullcrusher: 6-10 reps. Triceps strength.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- PHAT Day 2: Lower Body Power
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_squat, phat_lower_power_id, 4, 3, '00:04:00', 1000, 5000, 'Barbell Squat: 3-5 reps. Leg power foundation.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_ext, phat_lower_power_id, 8, 2, '00:02:00', 2000, 2500, 'Leg Extension: 6-10 reps. Quad isolation.', NULL, NULL),
        (uuid_generate_v1mc(), ex_romanian_dl, phat_lower_power_id, 6, 3, '00:03:30', 3000, 5000, 'Romanian Deadlift: 5-8 reps. Hamstring and posterior chain power.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_curl, phat_lower_power_id, 8, 2, '00:02:00', 4000, 2500, 'Lying Leg Curl: 6-10 reps. Hamstring isolation.', NULL, NULL),
        (uuid_generate_v1mc(), ex_calf_raise, phat_lower_power_id, 8, 3, '00:02:00', 5000, 2500, 'Standing Calf Raise: 6-10 reps. Calf power.', NULL, NULL),
        (uuid_generate_v1mc(), ex_seated_calf, phat_lower_power_id, 8, 2, '00:01:30', 6000, 2500, 'Seated Calf Raise: 6-10 reps. Soleus development.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- PHAT Day 4: Back and Shoulders Hypertrophy
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_barbell_row, phat_back_shoulders_id, 3, 6, '00:01:30', 1000, 2500, 'Bent-Over Row (Speed Work): 6 sets x 3 reps at 65-70% of power day weight. Explosive power and technique.', NULL, NULL),
        (uuid_generate_v1mc(), ex_cable_row, phat_back_shoulders_id, 10, 3, '00:01:30', 2000, 2500, 'Seated Cable Row: 8-12 reps. Back thickness.', NULL, NULL),
        (uuid_generate_v1mc(), ex_dumbbell_row, phat_back_shoulders_id, 12, 2, '00:01:30', 3000, 2500, 'Dumbbell Row or Shrug: 12-15 reps. Back detail or trap development.', NULL, NULL),
        (uuid_generate_v1mc(), ex_lat_pulldown, phat_back_shoulders_id, 17, 2, '00:01:00', 4000, 2500, 'Close-Grip Pulldown: 15-20 reps. Back width, biceps pump.', NULL, NULL),
        (uuid_generate_v1mc(), ex_ohp, phat_back_shoulders_id, 10, 3, '00:01:30', 5000, 2500, 'Seated Dumbbell Press: 8-12 reps. Shoulder hypertrophy.', NULL, NULL),
        (uuid_generate_v1mc(), ex_upright_row, phat_back_shoulders_id, 12, 2, '00:01:30', 6000, 2500, 'Upright Row: 12-15 reps. Shoulders and traps.', NULL, NULL),
        (uuid_generate_v1mc(), ex_lateral_raise, phat_back_shoulders_id, 15, 3, '00:01:00', 7000, 2500, 'Dumbbell Lateral Raise: 12-20 reps. Lateral delt development.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- PHAT Day 5: Lower Body Hypertrophy
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_squat, phat_lower_hyp_id, 3, 6, '00:01:30', 1000, 5000, 'Squat (Speed Work): 6 sets x 3 reps at 65-70% of power day weight. Explosive leg power.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_press, phat_lower_hyp_id, 12, 2, '00:01:30', 2000, 5000, 'Leg Press: 12-15 reps. Quad and glute volume.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_ext, phat_lower_hyp_id, 17, 3, '00:01:00', 3000, 2500, 'Leg Extension: 15-20 reps. Quad pump and detail.', NULL, NULL),
        (uuid_generate_v1mc(), ex_romanian_dl, phat_lower_hyp_id, 10, 3, '00:02:00', 4000, 5000, 'Romanian Deadlift: 8-12 reps. Hamstring hypertrophy.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_curl, phat_lower_hyp_id, 17, 2, '00:01:00', 5000, 2500, 'Lying/Seated Leg Curl: 12-20 reps. Hamstring pump.', NULL, NULL),
        (uuid_generate_v1mc(), ex_calf_raise, phat_lower_hyp_id, 10, 3, '00:01:30', 6000, 2500, 'Standing Calf Raise: 8-12 reps. Gastrocnemius hypertrophy.', NULL, NULL),
        (uuid_generate_v1mc(), ex_seated_calf, phat_lower_hyp_id, 15, 3, '00:01:00', 7000, 2500, 'Seated Calf Raise: 12-20 reps. Soleus hypertrophy.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- PHAT Day 6: Chest and Arms Hypertrophy
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_bench, phat_chest_arms_id, 3, 6, '00:01:30', 1000, 2500, 'Flat Dumbbell Press (Speed Work): 6 sets x 3 reps at 65-70% of power day weight. Explosive chest power.', NULL, NULL),
        (uuid_generate_v1mc(), ex_incline_db_press, phat_chest_arms_id, 10, 3, '00:01:30', 2000, 2500, 'Incline Dumbbell Press: 8-12 reps. Upper chest hypertrophy.', NULL, NULL),
        (uuid_generate_v1mc(), ex_dumbbell_flyes, phat_chest_arms_id, 12, 3, '00:01:30', 3000, 2500, 'Machine Press: 12-15 reps. Chest volume.', NULL, NULL),
        (uuid_generate_v1mc(), ex_cable_crossover, phat_chest_arms_id, 17, 2, '00:01:00', 4000, 2500, 'Incline Cable Flye: 15-20 reps. Chest stretch and pump.', NULL, NULL),
        (uuid_generate_v1mc(), ex_preacher_curl, phat_chest_arms_id, 10, 3, '00:01:30', 5000, 2500, 'Preacher Curl: 8-12 reps. Biceps hypertrophy.', NULL, NULL),
        (uuid_generate_v1mc(), ex_hammer_curl, phat_chest_arms_id, 12, 2, '00:01:30', 6000, 2500, 'Dumbbell Concentration Curl: 12-15 reps. Biceps peak.', NULL, NULL),
        (uuid_generate_v1mc(), ex_spider_curl, phat_chest_arms_id, 17, 2, '00:01:00', 7000, 2500, 'Spider Curl: 15-20 reps. Biceps pump.', NULL, NULL),
        (uuid_generate_v1mc(), ex_tricep_ext, phat_chest_arms_id, 10, 3, '00:01:30', 8000, 2500, 'Seated Tricep Extension: 8-12 reps. Triceps mass.', NULL, NULL),
        (uuid_generate_v1mc(), ex_cable_pressdown, phat_chest_arms_id, 12, 2, '00:01:00', 9000, 2500, 'Cable Pressdown with Rope: 12-15 reps. Triceps detail.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- ========================================================================
    -- JUGGERNAUT METHOD EXERCISES
    -- ========================================================================
    -- Note: Juggernaut uses wave periodization. These are representative sets.
    -- In practice, sets/reps change based on which wave (10s, 8s, 5s, 3s) and
    -- which week (Accumulation, Intensification, Realization, Deload).
    -- ========================================================================

    -- Juggernaut Day 1: Squat Focus
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_squat, jugg_squat_id, 10, 3, '00:02:30', 1000, 5000, 'Main Squat: Rep range varies by wave (10s/8s/5s/3s). Final set is AMRAP. Week 1 example: 10, 10, 10+ reps at 60%, 67.5%, 75% TM.', NULL, NULL),
        (uuid_generate_v1mc(), ex_front_squat, jugg_squat_id, 6, 4, '00:02:00', 2000, 5000, 'Assistance: Front Squat or Pause Squat - 5-8 reps. Targets weaknesses.', NULL, NULL),
        (uuid_generate_v1mc(), ex_romanian_dl, jugg_squat_id, 8, 3, '00:02:00', 3000, 5000, 'Assistance: Romanian Deadlift - 8 reps. Posterior chain support.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- Juggernaut Day 2: Bench Press Focus
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_bench, jugg_bench_id, 10, 3, '00:02:30', 1000, 2500, 'Main Bench: Rep range varies by wave (10s/8s/5s/3s). Final set is AMRAP. Week 1 example: 10, 10, 10+ reps at 60%, 67.5%, 75% TM.', NULL, NULL),
        (uuid_generate_v1mc(), ex_close_grip_bench, jugg_bench_id, 6, 4, '00:02:00', 2000, 2500, 'Assistance: Close-Grip Bench or Incline Press - 5-8 reps. Targets weaknesses.', NULL, NULL),
        (uuid_generate_v1mc(), ex_barbell_row, jugg_bench_id, 9, 4, '00:01:30', 3000, 2500, 'Assistance: Dumbbell Row - 8-10 reps. Upper back support.', NULL, NULL),
        (uuid_generate_v1mc(), ex_tricep_ext, jugg_bench_id, 10, 3, '00:01:30', 4000, 2500, 'Assistance: Tricep work - 8-12 reps.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- Juggernaut Day 3: Deadlift Focus
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_deadlift, jugg_deadlift_id, 10, 3, '00:02:30', 1000, 5000, 'Main Deadlift: Rep range varies by wave (10s/8s/5s/3s). Final set is AMRAP. Week 1 example: 10, 10, 10+ reps at 60%, 67.5%, 75% TM.', NULL, NULL),
        (uuid_generate_v1mc(), ex_pause_squat, jugg_deadlift_id, 6, 4, '00:02:00', 2000, 5000, 'Assistance: Squat variation - 5-8 reps. Leg strength support.', NULL, NULL),
        (uuid_generate_v1mc(), ex_leg_curl, jugg_deadlift_id, 9, 3, '00:01:30', 3000, 2500, 'Assistance: Leg Curl or Glute-Ham Raise - 8-10 reps. Hamstring work.', NULL, NULL),
        (uuid_generate_v1mc(), ex_barbell_row, jugg_deadlift_id, 9, 3, '00:01:30', 4000, 2500, 'Assistance: Upper back work - 8-10 reps.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

    -- Juggernaut Day 4: Overhead Press Focus
    INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
    VALUES
        (uuid_generate_v1mc(), ex_ohp, jugg_ohp_id, 10, 3, '00:02:30', 1000, 2500, 'Main OHP: Rep range varies by wave (10s/8s/5s/3s). Final set is AMRAP. Week 1 example: 10, 10, 10+ reps at 60%, 67.5%, 75% TM.', NULL, NULL),
        (uuid_generate_v1mc(), ex_push_press, jugg_ohp_id, 6, 4, '00:02:00', 2000, 2500, 'Assistance: Push Press or Incline Press - 5-8 reps. Overhead strength support.', NULL, NULL),
        (uuid_generate_v1mc(), ex_pullups, jugg_ohp_id, 7, 4, '00:01:30', 3000, 2500, 'Assistance: Pull-Ups or Rows - 5-10 reps. Back balance.', NULL, NULL),
        (uuid_generate_v1mc(), ex_lateral_raise, jugg_ohp_id, 12, 3, '00:01:30', 4000, 2500, 'Assistance: Lateral Raises - 12-15 reps. Shoulder health and size.', NULL, NULL)
    ON CONFLICT (exercise_id) DO NOTHING;

END $$;

-- ============================================================================
-- MIGRATION COMPLETE
-- ============================================================================
-- Summary:
-- - 5 powerbuilding programs added (GZCL, nSuns, PHUL, PHAT, Juggernaut)
-- - 21 session schedules created (workout days)
-- - 100+ exercise configurations created
-- - All exercises reference existing base_exercise entries
-- - Proper step_increment values: 2500g (upper), 5000g (lower)
-- - All progression_limit set to 1.0 (standard)
-- - Comprehensive descriptions with tier systems and progression notes
-- ============================================================================
