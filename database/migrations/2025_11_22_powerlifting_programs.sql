-- =============================================================================
-- Powerlifting Programs Migration
-- Created: 2025-11-22
-- Description: Adds 5 evidence-based powerlifting programs to the database
--              - Starting Strength
--              - Madcow 5x5
--              - Texas Method
--              - Wendler 5/3/1
--              - Smolov Program
-- =============================================================================

-- =============================================================================
-- PROGRAM 1: STARTING STRENGTH
-- =============================================================================
INSERT INTO plan (plan_id, name, description, links, data)
VALUES (
    'a1b2c3d4-5678-4abc-9def-111111111111',
    'Starting Strength',
    '## Starting Strength: Basic Barbell Training

**Level:** Beginner
**Duration:** 3-9 months
**Frequency:** 3 days per week
**Progression:** Linear progression - add weight every workout

### Description

Starting Strength is a novice linear progression program designed for absolute beginners to develop foundational strength using fundamental barbell movements. Created by Mark Rippetoe, a legendary strength coach and former competitive powerlifter, the program focuses on learning proper technique for the basic barbell exercises while building strength through simple, consistent progression.

The program is built around the principle that beginners can add weight to the bar every single workout session (linear progression), which works exceptionally well for novice lifters who have not yet adapted to resistance training.

**Important Note:** Starting Strength uses **3x5** (3 sets of 5 reps), not 5x5. The program was designed with 3 working sets of 5 to allow for sustainable progression without the excessive fatigue that 5x5 can cause as weights get heavy.

### Structure

The program alternates between two workouts (A and B) three times per week (Monday, Wednesday, Friday or similar non-consecutive days). Each workout focuses on compound movements that work multiple muscle groups simultaneously.

### Progression

**Weight Increments per Session:**

For most trainees:
- **Squat:** +10-15 lbs per workout initially, then +5 lbs as it gets harder
- **Deadlift:** +15-20 lbs per workout initially, then +10 lbs, then +5 lbs
- **Bench Press:** +5 lbs per workout, sometimes +2.5 lbs for lighter trainees
- **Overhead Press:** +2.5-5 lbs per workout (use microplates)
- **Power Clean:** +2.5-5 lbs per workout

For smaller/lighter trainees or females:
- Squat: +5 lbs per workout
- Deadlift: +10 lbs per workout
- Presses: +2.5 lbs per workout (requires 1.25 lb microplates)

### Who Should Do This Program

- Complete beginners with little to no barbell training experience
- Typical duration: 3-9 months depending on age, gender, bodyweight, and recovery capacity
- Young males (18-35, 180+ lbs): 6-9 months of linear progression is common
- Older males (40+): 3-6 months
- Females: 3-6 months typically

The program ends when you can no longer add weight to the bar session-to-session after multiple resets.',
    ARRAY[
        'https://startingstrength.com/get-started/programs',
        'https://www.amazon.com/Starting-Strength-Basic-Barbell-Training/dp/0982522738',
        'https://startingstrengthmirror.fandom.com/wiki/FAQ:The_Program',
        'https://www.athlegan.com/starting-strength'
    ],
    NULL
) ON CONFLICT (plan_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
    (
        'a1b2c3d4-5678-4abc-9def-222222222222',
        'a1b2c3d4-5678-4abc-9def-111111111111',
        'Workout A',
        '## Workout A

This workout focuses on squat, overhead press, and deadlift. You will perform this workout on Monday and Friday of week 1, then Wednesday of week 2, alternating throughout the program.

**Exercise Order:**
1. Squat: 3x5
2. Overhead Press: 3x5
3. Deadlift: 1x5 (only 1 set due to its taxing nature)

**Rest Periods:** 3-5 minutes between sets for squats and deadlifts, 3-5 minutes for presses.

**Note:** Warm-up sets are not included in the set counts. Always warm up progressively before your working sets.',
        1.0,
        ARRAY['https://startingstrength.com/get-started/programs'],
        NULL
    ),
    (
        'a1b2c3d4-5678-4abc-9def-333333333333',
        'a1b2c3d4-5678-4abc-9def-111111111111',
        'Workout B',
        '## Workout B

This workout focuses on squat, bench press, and deadlift (or power clean after phase 2). You will perform this workout on Wednesday of week 1, then Monday and Friday of week 2, alternating throughout the program.

**Exercise Order:**
1. Squat: 3x5
2. Bench Press: 3x5
3. Deadlift: 1x5 (Phase 1) OR Power Clean: 5x3 (Phase 2+)

**Rest Periods:** 3-5 minutes between sets for squats, 3-5 minutes for bench press.

**Note:** After 3-8 weeks, deadlift becomes too heavy to recover from when done every session. Power clean replaces deadlift on Day B to develop explosive power while allowing recovery.',
        1.0,
        ARRAY['https://startingstrength.com/get-started/programs'],
        NULL
    )
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links)
VALUES
    -- Workout A exercises
    (
        'a1b2c3d4-5678-4abc-9def-444444444444',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'a1b2c3d4-5678-4abc-9def-222222222222',
        5,
        3,
        '00:05:00',
        1000,
        2500, -- +5 lbs initially
        '3 working sets of 5 reps. Add 10-15 lbs initially, then 5 lbs per workout when progress slows. Warm up with progressive sets first.',
        ARRAY['https://www.youtube.com/watch?v=SW_C1A-rejs&feature=youtu.be&t=1m04s']
    ),
    (
        'a1b2c3d4-5678-4abc-9def-555555555555',
        '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
        'a1b2c3d4-5678-4abc-9def-222222222222',
        5,
        3,
        '00:05:00',
        2000,
        1250, -- +2.5 lbs per workout (microplates recommended)
        '3 working sets of 5 reps. Add 2.5-5 lbs per workout. This exercise progresses slower than others - be patient and use microplates.',
        ARRAY['https://vimeo.com/96081016']
    ),
    (
        'a1b2c3d4-5678-4abc-9def-666666666666',
        '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
        'a1b2c3d4-5678-4abc-9def-222222222222',
        5,
        1,
        '00:05:00',
        3000,
        5000, -- +10 lbs initially
        'Only 1 working set of 5 reps due to the taxing nature of deadlifts. Add 15-20 lbs initially, then 10 lbs, then 5 lbs as you progress.',
        ARRAY['https://www.youtube.com/watch?v=JCXUYuzwNrM&feature=youtu.be&t=1m25s']
    ),
    -- Workout B exercises
    (
        'a1b2c3d4-5678-4abc-9def-777777777777',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'a1b2c3d4-5678-4abc-9def-333333333333',
        5,
        3,
        '00:05:00',
        1000,
        2500, -- +5 lbs
        '3 working sets of 5 reps. Add 10-15 lbs initially, then 5 lbs per workout when progress slows.',
        ARRAY['https://www.youtube.com/watch?v=SW_C1A-rejs&feature=youtu.be&t=1m04s']
    ),
    (
        'a1b2c3d4-5678-4abc-9def-888888888888',
        '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
        'a1b2c3d4-5678-4abc-9def-333333333333',
        5,
        3,
        '00:05:00',
        2000,
        2500, -- +5 lbs per workout
        '3 working sets of 5 reps. Add 5 lbs per workout, or 2.5 lbs for lighter trainees.',
        NULL
    ),
    (
        'a1b2c3d4-5678-4abc-9def-999999999999',
        'f9d74097-5636-43ed-84d5-a458c56b3b5b', -- Power Clean
        'a1b2c3d4-5678-4abc-9def-333333333333',
        3,
        5,
        '00:03:00',
        3000,
        1250, -- +2.5-5 lbs
        '5 sets of 3 reps. Replaces deadlift after Phase 2 (weeks 3-8+). Focus on explosive power and proper technique. Use lighter weight than deadlift.',
        NULL
    )
ON CONFLICT (exercise_id) DO NOTHING;

-- =============================================================================
-- PROGRAM 2: MADCOW 5x5
-- =============================================================================
INSERT INTO plan (plan_id, name, description, links, data)
VALUES (
    'b1b2c3d4-5678-4abc-9def-111111111111',
    'Madcow 5x5',
    '## Madcow 5x5 Intermediate Program

**Level:** Intermediate
**Duration:** 8-12 weeks per cycle
**Frequency:** 3 days per week (Heavy-Light-Medium)
**Progression:** Weekly linear progression

### Description

Madcow 5x5 is an intermediate strength program designed for lifters who have exhausted linear progression on beginner programs like Starting Strength or StrongLifts 5x5. Based on Bill Starr''s original work with football players, the program was adapted and popularized online by a user known as "Madcow."

The fundamental philosophy is weekly linear periodization using the Heavy-Light-Medium (HLM) training approach. Unlike beginner programs where you add weight every workout, Madcow 5x5 has you add weight every week. This slower progression allows for adequate recovery between heavy training sessions.

### Structure

**Monday - Volume Day:** High volume with ramped sets (4x9, 5x7, 7x5, etc.)
**Wednesday - Light/Recovery Day:** Intentionally lighter to facilitate recovery
**Friday - Intensity Day:** Set new personal records with heavy triples

The program uses "ramped sets" for main lifts, meaning you progressively increase the weight across the sets, with only the final set being a true working set at maximum weight.

### Progression

**Weekly Weight Increases:**
- Each week, add 2.5-5% to your top sets on Monday and Friday
- Typical increments:
  - Squat/Deadlift: +5-10 lbs per week
  - Bench Press: +2.5-5 lbs per week
  - Overhead Press: +2.5-5 lbs per week
  - Barbell Row: +2.5-5 lbs per week

### Who Should Do This Program

- Lifters with 1-2 years of solid training experience
- Those who can no longer add weight every workout
- Successfully completed Starting Strength or similar novice program
- Ready for weekly progression instead of daily

The program typically runs for 8-12 weeks before requiring a reset or transition to a different training approach.',
    ARRAY[
        'https://stronglifts.com/madcow-5x5/',
        'https://www.hevyapp.com/madcow-5x5/',
        'https://liftvault.com/programs/strength/madcow-5x5-spreadsheet/',
        'http://www.oocities.org/elitemadcow1/5x5_Program/Linear_5x5.htm'
    ],
    NULL
) ON CONFLICT (plan_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
    (
        'b1b2c3d4-5678-4abc-9def-222222222222',
        'b1b2c3d4-5678-4abc-9def-111111111111',
        'Monday - Volume Day',
        '## Monday - Volume Day

This is the highest volume day of the week. You will perform ramped sets, meaning you increase weight each set, with only the 5th set being your "true" working set at target weight. Sets 1-4 serve as progressive warm-up to the top set.

**Main Lifts (Ramped Sets):**
- Squat: 5x5 ramped
- Bench Press: 5x5 ramped
- Barbell Row: 5x5 ramped

**Rest Periods:** 3-5 minutes between sets

**Example progression:** If your target top set is 315 lbs, you might do: 225x5, 250x5, 275x5, 300x5, 315x5

This is the highest total workload day - expect significant fatigue.',
        1.0,
        ARRAY['https://stronglifts.com/madcow-5x5/'],
        NULL
    ),
    (
        'b1b2c3d4-5678-4abc-9def-333333333333',
        'b1b2c3d4-5678-4abc-9def-111111111111',
        'Wednesday - Light/Recovery Day',
        '## Wednesday - Light/Recovery Day

This day is intentionally lighter to facilitate recovery. Focus on technique and speed - this should NOT be exhausting.

**Main Lifts:**
- Squat: 4x5 at 80% of Monday''s top set weight
- Overhead Press: 4x5 ramped
- Deadlift: 4x5 ramped (or 1x5 working set)

**Rest Periods:** 2-4 minutes between sets

**Important:** Should feel refreshing, not taxing. You should leave the gym feeling good, not fatigued. Some variations use front squats instead of back squats for reduced lower back stress.',
        0.8,
        ARRAY['https://stronglifts.com/madcow-5x5/'],
        NULL
    ),
    (
        'b1b2c3d4-5678-4abc-9def-444444444444',
        'b1b2c3d4-5678-4abc-9def-111111111111',
        'Friday - Intensity Day',
        '## Friday - Intensity Day

This is where you set new personal records every week. The 1x3 set should be heavier than anything you lifted on Monday.

**Main Lifts (Pyramid Structure):**
- Squat: 4x5 ramped, 1x3 (PR weight), 1x8 (backoff at 80%)
- Bench Press: 4x5 ramped, 1x3 (PR weight), 1x8 (backoff at 80%)
- Barbell Row: 4x5 ramped, 1x3 (PR weight), 1x8 (backoff at 80%)

**Rest Periods:** 4-7 minutes between heavy sets

**Example:** If Monday''s top set was 315x5, Friday might be: 235x5, 265x5, 295x5, 315x5, 330x3 (NEW PR), 265x8 (backoff)

The backoff set (1x8) provides additional volume at a manageable weight after your PR attempt.',
        1.0,
        ARRAY['https://stronglifts.com/madcow-5x5/'],
        NULL
    )
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links)
VALUES
    -- Monday - Volume Day exercises
    (
        'b1b2c3d4-5678-4abc-9def-555555555555',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'b1b2c3d4-5678-4abc-9def-222222222222',
        5,
        5,
        '00:05:00',
        1000,
        2500, -- +5 lbs per week to top set
        'Ramped sets: increase weight each set. Only the 5th set is your true working weight. Add 5-10 lbs per week to your top set.',
        NULL
    ),
    (
        'b1b2c3d4-5678-4abc-9def-666666666666',
        '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
        'b1b2c3d4-5678-4abc-9def-222222222222',
        5,
        5,
        '00:04:00',
        2000,
        1250, -- +2.5-5 lbs per week to top set
        'Ramped sets: increase weight each set. Add 2.5-5 lbs per week to your top set.',
        NULL
    ),
    (
        'b1b2c3d4-5678-4abc-9def-777777777777',
        '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', -- Barbell Row
        'b1b2c3d4-5678-4abc-9def-222222222222',
        5,
        5,
        '00:04:00',
        3000,
        1250, -- +2.5-5 lbs per week
        'Ramped sets: increase weight each set. Add 2.5-5 lbs per week to your top set.',
        NULL
    ),
    -- Wednesday - Light/Recovery Day exercises
    (
        'b1b2c3d4-5678-4abc-9def-888888888888',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'b1b2c3d4-5678-4abc-9def-333333333333',
        5,
        4,
        '00:03:00',
        1000,
        0, -- No progression - based on Monday's weight (80%)
        'Use 80% of Monday''s top set weight for all 4 sets. This is recovery work - focus on speed and technique.',
        NULL
    ),
    (
        'b1b2c3d4-5678-4abc-9def-999999999999',
        '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
        'b1b2c3d4-5678-4abc-9def-333333333333',
        5,
        4,
        '00:03:00',
        2000,
        1250, -- +2.5-5 lbs per week
        'Ramped sets: increase weight each set. Add 2.5-5 lbs per week to your top set.',
        NULL
    ),
    (
        'b1b2c3d4-5678-4abc-9def-aaaaaaaaaaaa',
        '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
        'b1b2c3d4-5678-4abc-9def-333333333333',
        5,
        4,
        '00:04:00',
        3000,
        2500, -- +5-10 lbs per week
        'Can do 4x5 ramped or just 1x5 working set. This is lighter deadlift work to avoid overtraining.',
        NULL
    ),
    -- Friday - Intensity Day exercises (using data field for pyramid structure)
    (
        'b1b2c3d4-5678-4abc-9def-bbbbbbbbbbbb',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'b1b2c3d4-5678-4abc-9def-444444444444',
        3,
        1,
        '00:05:00',
        1000,
        2500, -- +5 lbs per week to PR set
        'Pyramid: 4x5 ramped, then 1x3 at NEW PR weight (heavier than Monday), then 1x8 backoff at 80% of the triple. The 1x3 should be a new weekly record.',
        NULL
    ),
    (
        'b1b2c3d4-5678-4abc-9def-cccccccccccc',
        '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
        'b1b2c3d4-5678-4abc-9def-444444444444',
        3,
        1,
        '00:05:00',
        2000,
        1250, -- +2.5-5 lbs per week
        'Pyramid: 4x5 ramped, then 1x3 at NEW PR weight, then 1x8 backoff at 80%. Set a new 3-rep record each week.',
        NULL
    ),
    (
        'b1b2c3d4-5678-4abc-9def-dddddddddddd',
        '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', -- Barbell Row
        'b1b2c3d4-5678-4abc-9def-444444444444',
        3,
        1,
        '00:04:00',
        3000,
        1250, -- +2.5-5 lbs per week
        'Pyramid: 4x5 ramped, then 1x3 at NEW PR weight, then 1x8 backoff at 80%.',
        NULL
    )
ON CONFLICT (exercise_id) DO NOTHING;

-- =============================================================================
-- PROGRAM 3: TEXAS METHOD
-- =============================================================================
INSERT INTO plan (plan_id, name, description, links, data)
VALUES (
    'c1b2c3d4-5678-4abc-9def-111111111111',
    'Texas Method',
    '## The Texas Method

**Level:** Intermediate
**Duration:** 6-18+ months
**Frequency:** 3 days per week (Volume-Light-Intensity)
**Progression:** Weekly progression on intensity day

### Description

The Texas Method is an intermediate barbell training program specifically designed for lifters who have exhausted the gains from linear progression programs but haven''t yet reached advanced status. Created by Glenn Pendlay while coaching the Wichita Falls Weightlifting Club in the early 2000s, the program was introduced to the broader strength training community through Mark Rippetoe and Lon Kilgore''s book "Practical Programming for Strength Training."

The program is built on a brilliant weekly periodization scheme that separates volume and intensity into distinct training days. Monday provides high-volume stress, Wednesday allows for active recovery with lighter weights, and Friday challenges you to set a new personal record on a heavy single set.

### Structure

**Monday - Volume Day:** 5x5 at ~90% of Friday''s weight for high volume stress
**Wednesday - Light/Recovery Day:** Varied lighter work for active recovery
**Friday - Intensity Day:** 1x5 PR attempt at new 5-rep max

An interesting origin story: the program emerged when lifters in Pendlay''s gym began "cheating" by doing only one heavy set of five reps on Friday instead of five sets. When Pendlay observed that these lifters were actually making better progress, he formalized this approach into the Texas Method.

### Progression

**Weekly Progression Guidelines:**
- Squat: +5 lbs per week
- Deadlift: +5-10 lbs per week
- Bench Press: +2.5-5 lbs per week
- Overhead Press: +2.5 lbs per week

As you advance, you may need to modify the rep scheme on intensity day:
- Phase 1 (Months 1-3): 1x5 PR on intensity day
- Phase 2 (Months 4-6): Transition to 1x3 PR as 5RM progress slows
- Phase 3 (Months 7+): May transition to 1x1 or 2x2

### Who Should Do This Program

- Lifters with 6-18 months of consistent training
- Successfully completed Starting Strength or similar program
- Can squat at least 1.5x bodyweight
- Ready for weekly personal records
- Excellent recovery practices (sleep, nutrition, stress management)

The program represents the minimum effective dose of training for intermediate lifters—enough stress to drive adaptation without exceeding recovery capacity.',
    ARRAY[
        'https://www.otpbooks.com/glenn-pendlay-the-texas-method/',
        'https://startingstrength.com/article/the_texas_method',
        'https://www.powerliftingtowin.com/texas-method/',
        'https://legionathletics.com/texas-method/',
        'https://www.oldschoollabs.com/texas-method/'
    ],
    NULL
) ON CONFLICT (plan_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
    (
        'c1b2c3d4-5678-4abc-9def-222222222222',
        'c1b2c3d4-5678-4abc-9def-111111111111',
        'Monday - Volume Day',
        '## Monday - Volume Day

This is the highest volume day - you will accumulate significant fatigue. Use approximately 90% of the weight you''ll attempt on Friday for your 5x5 work sets. This should feel challenging but not like maximal effort.

**Main Lifts:**
- Squat: 5x5 at ~90% of Friday''s planned weight
- Bench Press OR Overhead Press: 5x5 at ~90% of Friday''s weight
- Deadlift: 1x5 (every other week) OR Power Clean: 5x3

**Rest Periods:** 5-7 minutes between squat sets, 3-5 minutes for other lifts

**Important:** Focus on quality reps and technique. Total workout time: 90-120 minutes with adequate rest. As you get stronger, you may need to reduce volume to 85% or even 80% of Friday''s weight to recover adequately.',
        1.0,
        ARRAY['https://startingstrength.com/article/the_texas_method'],
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-333333333333',
        'c1b2c3d4-5678-4abc-9def-111111111111',
        'Wednesday - Light/Recovery Day',
        '## Wednesday - Light/Recovery Day

This day should NOT be taxing. Focus on technique, speed, and movement quality. You should leave the gym feeling refreshed, not fatigued.

**Option 1 (Light Back Squat):**
- Squat: 2x5 at 80% of Monday''s weight
- Overhead Press OR Bench Press (opposite of Monday): 3x5 light
- Chin-ups or Pull-ups: 3x8-10

**Option 2 (Front Squat Variant):**
- Front Squat: 3x3 at 70-75% of back squat
- Light Press work: 3x5

**Rest Periods:** 2-3 minutes

**Important:** Total workout time should be 45-60 minutes. Some lifters prefer front squats for reduced lower back stress. This is active recovery - don''t add extra volume.',
        0.8,
        ARRAY['https://startingstrength.com/article/the_texas_method'],
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-444444444444',
        'c1b2c3d4-5678-4abc-9def-111111111111',
        'Friday - Intensity Day',
        '## Friday - Intensity Day

This is where you set new personal records every week. Warm up thoroughly with progressive singles or doubles. The single set of 5 should be a true maximal effort for that day.

**Main Lifts:**
- Squat: 1x5 at new 5RM PR (or 1x3, or 1x1 in later phases)
- Bench Press OR Overhead Press: 1x5 PR (alternates with Monday)
- Deadlift: 1x5 PR (every other week) OR Power Clean: 5x3 moderate

**Rest Periods:** Take as much rest as needed before PR sets (10-15 minutes not uncommon)

**Progression:**
- If you successfully complete all 5 reps, add weight next week
- If you fail, repeat the same weight or adjust training loads
- Total workout time: 60-90 minutes including thorough warm-up

**Note:** As the program progresses, you may transition from 1x5 to 1x3 or 1x1 to continue making progress.',
        1.0,
        ARRAY['https://startingstrength.com/article/the_texas_method'],
        NULL
    )
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links)
VALUES
    -- Monday - Volume Day exercises
    (
        'c1b2c3d4-5678-4abc-9def-555555555555',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'c1b2c3d4-5678-4abc-9def-222222222222',
        5,
        5,
        '00:06:00',
        1000,
        2500, -- +5 lbs per week (to Friday's PR)
        'Use ~90% of Friday''s planned 5RM weight. All 5 sets at same weight. As you advance, may need to reduce to 85% or 80%. Focus on quality reps.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-666666666666',
        '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
        'c1b2c3d4-5678-4abc-9def-222222222222',
        5,
        5,
        '00:05:00',
        2000,
        1250, -- +2.5-5 lbs per week
        'Use ~90% of Friday''s planned 5RM weight. All 5 sets at same weight. Alternates with overhead press each week.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-777777777777',
        '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
        'c1b2c3d4-5678-4abc-9def-222222222222',
        5,
        1,
        '00:05:00',
        3000,
        2500, -- +5-10 lbs per week
        'Perform every other week only (alternates with Friday). Single working set. Too taxing to do every week at this intensity.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-888888888888',
        'f9d74097-5636-43ed-84d5-a458c56b3b5b', -- Power Clean
        'c1b2c3d4-5678-4abc-9def-222222222222',
        3,
        5,
        '00:03:00',
        4000,
        1250, -- +2.5-5 lbs per week
        'Alternative to deadlift on weeks when not deadlifting. Focus on explosive power and technique.',
        NULL
    ),
    -- Wednesday - Light/Recovery Day exercises
    (
        'c1b2c3d4-5678-4abc-9def-999999999999',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat (light)
        'c1b2c3d4-5678-4abc-9def-333333333333',
        5,
        2,
        '00:03:00',
        1000,
        0, -- No progression - based on Monday (80%)
        'Use 80% of Monday''s weight. Only 2 sets. Focus on speed and technique. Should feel light and refreshing.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-aaaaaaaaaaaa',
        '10845aff-07ac-4359-a8dd-ce99442e33d5', -- Front Squat (alternative)
        'c1b2c3d4-5678-4abc-9def-333333333333',
        3,
        3,
        '00:03:00',
        1500,
        0, -- No progression - based on back squat
        'Alternative to light back squat. Use 70-75% of back squat weight. Reduces lower back stress while maintaining leg work.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-bbbbbbbbbbbb',
        '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press (light)
        'c1b2c3d4-5678-4abc-9def-333333333333',
        5,
        3,
        '00:03:00',
        2000,
        0, -- Light work
        'Light press work. If you benched Monday, press Wednesday. Focus on technique.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-cccccccccccc',
        'b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac', -- Chin-ups
        'c1b2c3d4-5678-4abc-9def-333333333333',
        10,
        3,
        '00:02:00',
        3000,
        0, -- Bodyweight or add weight when ready
        'Bodyweight chin-ups. Add weight when you can do 3x10 easily. Back work to support deadlifts and rows.',
        NULL
    ),
    -- Friday - Intensity Day exercises
    (
        'c1b2c3d4-5678-4abc-9def-dddddddddddd',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'c1b2c3d4-5678-4abc-9def-444444444444',
        5,
        1,
        '00:10:00',
        1000,
        2500, -- +5 lbs per week
        'Single set of 5 at NEW 5RM PR. Warm up thoroughly. Add 5 lbs per week. If progress stalls, may transition to 1x3 or 1x1 in later phases.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-eeeeeeeeeeee',
        '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
        'c1b2c3d4-5678-4abc-9def-444444444444',
        5,
        1,
        '00:10:00',
        2000,
        1250, -- +2.5-5 lbs per week
        'Single set of 5 at NEW 5RM PR. Alternates with overhead press. Take as much rest as needed before the set.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-ffffffffffff',
        '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
        'c1b2c3d4-5678-4abc-9def-444444444444',
        5,
        1,
        '00:10:00',
        3000,
        2500, -- +5-10 lbs per week
        'Single set of 5 at NEW 5RM PR. Every other week only (alternates with Monday). Major PR attempt.',
        NULL
    ),
    (
        'c1b2c3d4-5678-4abc-9def-000000000001',
        'f9d74097-5636-43ed-84d5-a458c56b3b5b', -- Power Clean
        'c1b2c3d4-5678-4abc-9def-444444444444',
        3,
        5,
        '00:03:00',
        4000,
        1250, -- +2.5-5 lbs
        'Moderate weight power cleans on weeks when not deadlifting. Focus on explosive speed rather than maximal weight.',
        NULL
    )
ON CONFLICT (exercise_id) DO NOTHING;

-- =============================================================================
-- PROGRAM 4: WENDLER 5/3/1
-- =============================================================================
INSERT INTO plan (plan_id, name, description, links, data)
VALUES (
    'd1b2c3d4-5678-4abc-9def-111111111111',
    'Wendler 5/3/1',
    '## Wendler 5/3/1

**Level:** Intermediate to Advanced
**Duration:** Indefinite (4-week cycles)
**Frequency:** 4 days per week
**Progression:** Monthly progression based on training max

### Description

Wendler 5/3/1 is a percentage-based strength training program built on monthly progression cycles and submaximal training. Created by Jim Wendler, a former elite powerlifter with a 1000 lb squat, 675 lb bench, and 700 lb deadlift, the program was born from Wendler''s frustration with overly complex programs.

The philosophy emphasizes "start light, progress slowly" and "train, don''t test." Unlike programs that have you constantly working at your limits, 5/3/1 uses a "training max" (90% of your true 1-rep max) to calculate all working weights. This built-in submaximal approach ensures you accumulate quality reps and volume without burning out.

### Structure

**Weekly Schedule:**
- Day 1: Overhead Press + assistance work
- Day 2: Deadlift + assistance work
- Day 3: Bench Press + assistance work
- Day 4: Squat + assistance work

Each 4-week cycle follows this pattern:
- **Week 1:** 5+ week (sets of 5 reps, AMRAP final set at 85% TM)
- **Week 2:** 3+ week (sets of 3 reps, AMRAP final set at 90% TM)
- **Week 3:** 5/3/1+ week (5, 3, 1+ reps, AMRAP final set at 95% TM)
- **Week 4:** Deload week (light recovery week)

### Training Max and Percentages

**Calculate Training Max:** TM = 0.90 × your true 1RM

**Week 1 percentages:** 65%, 75%, 85% (AMRAP)
**Week 2 percentages:** 70%, 80%, 90% (AMRAP)
**Week 3 percentages:** 75%, 85%, 95% (AMRAP)
**Week 4 percentages:** 40%, 50%, 60% (deload)

The "+" means AMRAP (As Many Reps As Possible) - push beyond prescribed reps but leave 1 in the tank.

### Progression

After completing Week 4 (deload), increase your Training Max:
- Squat: +5-10 lbs
- Deadlift: +5-10 lbs
- Bench Press: +2.5-5 lbs
- Overhead Press: +2.5-5 lbs

**AMRAP targets:**
- Week 1 (85% TM): Should get 8-12+ reps
- Week 2 (90% TM): Should get 5-8+ reps
- Week 3 (95% TM): Should get 3-6+ reps

### Who Should Do This Program

- Intermediate to advanced lifters
- Athletes looking to build strength while maintaining conditioning
- Anyone wanting sustainable long-term progression
- Can be run indefinitely with proper cycling
- Many lifters run variations of 5/3/1 for years

The beauty of 5/3/1 is that it''s designed to be a long-term training philosophy, not a short-term program.',
    ARRAY[
        'https://www.jimwendler.com',
        'https://www.typeatraining.com/blog/5-3-1-program-guide-jim-wendlers-proven-strength-system/',
        'https://blackironbeast.com/5/3/1/calculator',
        'https://liftvault.com/programs/powerlifting/jim-wendlers-531-spreadsheet/',
        'https://barbend.com/5-3-1-program/',
        'https://www.setforset.com/blogs/news/531-workout-program'
    ],
    NULL
) ON CONFLICT (plan_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
    (
        'd1b2c3d4-5678-4abc-9def-222222222222',
        'd1b2c3d4-5678-4abc-9def-111111111111',
        'Day 1 - Overhead Press',
        '## Overhead Press Day

**Main Lift:** Overhead Press

**Week 1:** Warm-up, then 5 @ 65% TM, 5 @ 75% TM, 5+ @ 85% TM
**Week 2:** Warm-up, then 3 @ 70% TM, 3 @ 80% TM, 3+ @ 90% TM
**Week 3:** Warm-up, then 5 @ 75% TM, 3 @ 85% TM, 1+ @ 95% TM
**Week 4:** Deload - 5 @ 40% TM, 5 @ 50% TM, 5 @ 60% TM

**Assistance Work:**
- Push: 50-100 total reps (dips, push-ups, tricep work)
- Pull: 50-100 total reps (rows, chin-ups, face pulls)
- Single-leg/Core: 0-50 total reps

**Important:** The "+" sets are AMRAP (as many reps as possible) but leave 1 rep in the tank. Don''t go to absolute failure.

**Note:** All percentages are based on your Training Max (90% of true 1RM), not your actual 1RM.',
        1.0,
        ARRAY['https://www.jimwendler.com'],
        NULL
    ),
    (
        'd1b2c3d4-5678-4abc-9def-333333333333',
        'd1b2c3d4-5678-4abc-9def-111111111111',
        'Day 2 - Deadlift',
        '## Deadlift Day

**Main Lift:** Deadlift

**Week 1:** Warm-up, then 5 @ 65% TM, 5 @ 75% TM, 5+ @ 85% TM
**Week 2:** Warm-up, then 3 @ 70% TM, 3 @ 80% TM, 3+ @ 90% TM
**Week 3:** Warm-up, then 5 @ 75% TM, 3 @ 85% TM, 1+ @ 95% TM
**Week 4:** Deload - 5 @ 40% TM, 5 @ 50% TM, 5 @ 60% TM

**Assistance Work:**
- Push: 50-100 total reps
- Pull: 50-100 total reps (especially important for back)
- Single-leg/Core: 0-50 total reps

**AMRAP Targets:**
- Week 1 @ 85% TM: Shoot for 8-12 reps
- Week 2 @ 90% TM: Shoot for 5-8 reps
- Week 3 @ 95% TM: Shoot for 3-6 reps

**Note:** If hitting fewer reps than these targets, your Training Max may be too high.',
        1.0,
        ARRAY['https://www.jimwendler.com'],
        NULL
    ),
    (
        'd1b2c3d4-5678-4abc-9def-444444444444',
        'd1b2c3d4-5678-4abc-9def-111111111111',
        'Day 3 - Bench Press',
        '## Bench Press Day

**Main Lift:** Bench Press

**Week 1:** Warm-up, then 5 @ 65% TM, 5 @ 75% TM, 5+ @ 85% TM
**Week 2:** Warm-up, then 3 @ 70% TM, 3 @ 80% TM, 3+ @ 90% TM
**Week 3:** Warm-up, then 5 @ 75% TM, 3 @ 85% TM, 1+ @ 95% TM
**Week 4:** Deload - 5 @ 40% TM, 5 @ 50% TM, 5 @ 60% TM

**Assistance Work:**
- Push: 50-100 total reps (especially important for chest/triceps)
- Pull: 50-100 total reps (rows for balance)
- Single-leg/Core: 0-50 total reps

**Week 3 Example:** If your TM is 315 lbs:
- Warm up progressively
- Set 1: 236 lbs × 5
- Set 2: 268 lbs × 3
- Set 3: 299 lbs × 1+ (shoot for 3-6 reps)

This is the heaviest week - very challenging AMRAP set at 95% TM.',
        1.0,
        ARRAY['https://www.jimwendler.com'],
        NULL
    ),
    (
        'd1b2c3d4-5678-4abc-9def-555555555555',
        'd1b2c3d4-5678-4abc-9def-111111111111',
        'Day 4 - Squat',
        '## Squat Day

**Main Lift:** Squat

**Week 1:** Warm-up, then 5 @ 65% TM, 5 @ 75% TM, 5+ @ 85% TM
**Week 2:** Warm-up, then 3 @ 70% TM, 3 @ 80% TM, 3+ @ 90% TM
**Week 3:** Warm-up, then 5 @ 75% TM, 3 @ 85% TM, 1+ @ 95% TM
**Week 4:** Deload - 5 @ 40% TM, 5 @ 50% TM, 5 @ 60% TM

**Assistance Work:**
- Push: 50-100 total reps
- Pull: 50-100 total reps
- Single-leg/Core: 0-50 total reps (lunges, leg curls, ab work)

**Cycle Progression:**
After completing Week 4, increase your Squat Training Max by 5-10 lbs and begin a new 4-week cycle.

**Week 4 Deload:** This week should feel very easy. Resist the urge to add weight or reps. Purpose is active recovery and preparation for the next cycle.',
        1.0,
        ARRAY['https://www.jimwendler.com'],
        NULL
    )
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links)
VALUES
    -- Overhead Press Day
    (
        'd1b2c3d4-5678-4abc-9def-666666666666',
        '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead Press
        'd1b2c3d4-5678-4abc-9def-222222222222',
        5,
        3,
        '00:03:00',
        1000,
        1250, -- +2.5-5 lbs per cycle (after 4 weeks)
        'Week 1: 5@65%, 5@75%, 5+@85% TM | Week 2: 3@70%, 3@80%, 3+@90% TM | Week 3: 5@75%, 3@85%, 1+@95% TM | Week 4: 5@40%, 5@50%, 5@60% TM. All percentages based on Training Max (90% of 1RM). Final set each week is AMRAP - leave 1 rep in tank.',
        NULL
    ),
    -- Deadlift Day
    (
        'd1b2c3d4-5678-4abc-9def-777777777777',
        '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
        'd1b2c3d4-5678-4abc-9def-333333333333',
        5,
        3,
        '00:05:00',
        1000,
        2500, -- +5-10 lbs per cycle
        'Week 1: 5@65%, 5@75%, 5+@85% TM | Week 2: 3@70%, 3@80%, 3+@90% TM | Week 3: 5@75%, 3@85%, 1+@95% TM | Week 4: 5@40%, 5@50%, 5@60% TM. AMRAP targets: Wk1: 8-12 reps, Wk2: 5-8 reps, Wk3: 3-6 reps.',
        NULL
    ),
    -- Bench Press Day
    (
        'd1b2c3d4-5678-4abc-9def-888888888888',
        '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench Press
        'd1b2c3d4-5678-4abc-9def-444444444444',
        5,
        3,
        '00:03:00',
        1000,
        1250, -- +2.5-5 lbs per cycle
        'Week 1: 5@65%, 5@75%, 5+@85% TM | Week 2: 3@70%, 3@80%, 3+@90% TM | Week 3: 5@75%, 3@85%, 1+@95% TM | Week 4: 5@40%, 5@50%, 5@60% TM. Week 3 has the heaviest AMRAP set at 95% TM.',
        NULL
    ),
    -- Squat Day
    (
        'd1b2c3d4-5678-4abc-9def-999999999999',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'd1b2c3d4-5678-4abc-9def-555555555555',
        5,
        3,
        '00:05:00',
        1000,
        2500, -- +5-10 lbs per cycle
        'Week 1: 5@65%, 5@75%, 5+@85% TM | Week 2: 3@70%, 3@80%, 3+@90% TM | Week 3: 5@75%, 3@85%, 1+@95% TM | Week 4: 5@40%, 5@50%, 5@60% TM (deload). After Week 4, add 5-10 lbs to Training Max and start new cycle.',
        NULL
    )
ON CONFLICT (exercise_id) DO NOTHING;

-- =============================================================================
-- PROGRAM 5: SMOLOV SQUAT PROGRAM
-- =============================================================================
INSERT INTO plan (plan_id, name, description, links, data)
VALUES (
    'e1b2c3d4-5678-4abc-9def-111111111111',
    'Smolov Squat Program',
    '## Smolov Squat Routine

**Level:** Advanced/Elite
**Duration:** 13 weeks total
**Frequency:** 3-4 days per week (varies by phase)
**Progression:** Prescribed weekly progression
**Focus:** SQUAT SPECIALIZATION

### ⚠️ WARNING - READ BEFORE STARTING

Smolov is notoriously brutal and has a 30-50% dropout rate. This program is NOT for everyone.

**DO NOT ATTEMPT if you:**
- Have less than 2-3 years of serious barbell training
- Cannot squat at least 1.5x bodyweight
- Have any knee, hip, or lower back issues
- Work a physically demanding job
- Cannot commit to perfect sleep (8-10 hours) and nutrition (often 4000+ calories)
- Have other life stressors
- Are training for anything other than max squat strength

**Many coaches state this program is designed for athletes using performance-enhancing drugs.**

### Description

The Smolov Squat Routine is an extreme 13-week squat specialization program designed to add 80-100 pounds to your squat max. Created by Russian Master of Sports Sergey Smolov, this program emerged from Soviet-era strength training methods.

Smolov is NOT a balanced full-body program. It is a squat-focused peaking cycle that places squatting at the absolute center of training. During the base mesocycle, you will squat 4 days per week with weekly rep counts reaching an astounding 136 reps.

### Structure - 5 Phases

1. **Introduction Microcycle (Weeks 1-2):** 3 days/week preparation
2. **Base Mesocycle (Weeks 3-6):** 4 days/week - EXTREMELY HIGH VOLUME (136 reps/week)
3. **Switching Phase (Weeks 7-8):** 3 days/week lighter recovery work
4. **Intense Mesocycle (Weeks 9-12):** 3 days/week very heavy weights
5. **Taper Week (Week 13):** 2 light sessions + 1RM test

### Expected Gains

If completed successfully:
- **Minimum:** 40-50 lbs on squat 1RM
- **Typical:** 60-80 lbs
- **Exceptional:** 80-100+ lbs

### Base Mesocycle (The Brutal Phase)

This is the most infamous part of Smolov. Week 3-6 pattern:

- **Monday:** 4x9 @ 70% + weekly increment
- **Wednesday:** 5x7 @ 75% + weekly increment
- **Friday:** 7x5 @ 80% + weekly increment
- **Saturday:** 10x3 @ 85% + weekly increment

**Total weekly reps: 136**

Week 3→4: Add 20 lbs | Week 4→5: Add 10-20 lbs | Week 5→6: Add 10 lbs

### Recovery Requirements

- **Sleep:** 8-10 hours minimum nightly
- **Nutrition:** Massive caloric surplus (500+ over maintenance, often 4000+ calories)
- **Stress:** Minimal life and work stress
- **Other Training:** Minimize or eliminate all other training

### Who MIGHT Be Ready

- 3+ years of consistent barbell training
- Squat 400+ lbs (men) or 250+ lbs (women)
- Can commit to perfect recovery
- Willing to make squatting #1 priority for 13 weeks
- Have successfully completed high-volume programs before
- Excellent squat technique

**Note:** This program is best used as a peaking cycle before a powerlifting competition, not as general strength development.',
    ARRAY[
        'https://www.smolovjr.com/smolov-squat-routine/',
        'https://en.wikipedia.org/wiki/Smolov_Squat_Routine',
        'https://legionathletics.com/smolov-squat-program/',
        'https://liftvault.com/programs/powerlifting/peaking/smolov/',
        'https://powerliftingtechnique.com/smolov/',
        'https://kylehuntfitness.com/the-smolov-squat-program-add-100lbs-to-your-squat/'
    ],
    NULL
) ON CONFLICT (plan_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
    (
        'e1b2c3d4-5678-4abc-9def-222222222222',
        'e1b2c3d4-5678-4abc-9def-111111111111',
        'Base Mesocycle - Monday (4x9)',
        '## Base Mesocycle - Monday

**Weeks 3-6:** This is the brutal high-volume phase. You will squat 4 days per week.

**Monday Workout:**
- Squat: 4 sets × 9 reps @ 70% 1RM + weekly increment

**Weekly Progression:**
- Week 3: 70% of 1RM
- Week 4: Add 20 lbs to working weight
- Week 5: Add another 10-20 lbs
- Week 6: Add another 10 lbs

**Rest Periods:** 2-4 minutes minimum between sets

**Notes:**
- This is volume day - highest total reps
- All 4 sets at the same weight
- Eat massive amounts of food (500+ calorie surplus)
- Sleep 8-10 hours minimum
- Week 6 is the hardest week of the entire program

**Example:** If your 1RM is 405 lbs, Week 3 would be 4x9 @ 283 lbs (70% of 405)',
        1.0,
        ARRAY['https://www.smolovjr.com/smolov-squat-routine/'],
        NULL
    ),
    (
        'e1b2c3d4-5678-4abc-9def-333333333333',
        'e1b2c3d4-5678-4abc-9def-111111111111',
        'Base Mesocycle - Wednesday (5x7)',
        '## Base Mesocycle - Wednesday

**Weeks 3-6:** Day 2 of the 4-day per week schedule.

**Wednesday Workout:**
- Squat: 5 sets × 7 reps @ 75% 1RM + weekly increment

**Weekly Progression:**
- Week 3: 75% of 1RM
- Week 4: Add 20 lbs to working weight
- Week 5: Add another 10-20 lbs
- Week 6: Add another 10 lbs

**Rest Periods:** 2-4 minutes minimum between sets

**Notes:**
- Higher intensity than Monday (75% vs 70%)
- All 5 sets at the same weight
- Focus on technique even when fatigued
- This is mid-week - recovery is crucial

**Example:** If your 1RM is 405 lbs, Week 3 would be 5x7 @ 304 lbs (75% of 405)',
        1.0,
        ARRAY['https://www.smolovjr.com/smolov-squat-routine/'],
        NULL
    ),
    (
        'e1b2c3d4-5678-4abc-9def-444444444444',
        'e1b2c3d4-5678-4abc-9def-111111111111',
        'Base Mesocycle - Friday (7x5)',
        '## Base Mesocycle - Friday

**Weeks 3-6:** Day 3 of the 4-day per week schedule.

**Friday Workout:**
- Squat: 7 sets × 5 reps @ 80% 1RM + weekly increment

**Weekly Progression:**
- Week 3: 80% of 1RM
- Week 4: Add 20 lbs to working weight
- Week 5: Add another 10-20 lbs
- Week 6: Add another 10 lbs

**Rest Periods:** 3-5 minutes between sets

**Notes:**
- Higher intensity (80%), fewer reps per set
- 7 sets - this is a grind
- All sets at the same weight
- Maintain perfect technique despite fatigue

**Example:** If your 1RM is 405 lbs, Week 3 would be 7x5 @ 324 lbs (80% of 405)',
        1.0,
        ARRAY['https://www.smolovjr.com/smolov-squat-routine/'],
        NULL
    ),
    (
        'e1b2c3d4-5678-4abc-9def-555555555555',
        'e1b2c3d4-5678-4abc-9def-111111111111',
        'Base Mesocycle - Saturday (10x3)',
        '## Base Mesocycle - Saturday

**Weeks 3-6:** Day 4 of the 4-day per week schedule. FINAL DAY of the week.

**Saturday Workout:**
- Squat: 10 sets × 3 reps @ 85% 1RM + weekly increment

**Weekly Progression:**
- Week 3: 85% of 1RM
- Week 4: Add 20 lbs to working weight
- Week 5: Add another 10-20 lbs
- Week 6: Add another 10 lbs

**Rest Periods:** 3-5 minutes between sets, take more if needed

**Notes:**
- HIGHEST intensity of the week (85%)
- 10 sets of 3 - focus on quality
- All sets at the same weight
- This completes your weekly 136 total reps
- After this, take Sunday + Monday off before next week''s Monday session

**Example:** If your 1RM is 405 lbs, Week 3 would be 10x3 @ 344 lbs (85% of 405)

**Total Base Mesocycle Weekly Volume:**
- Monday: 36 reps (4×9)
- Wednesday: 35 reps (5×7)
- Friday: 35 reps (7×5)
- Saturday: 30 reps (10×3)
- **TOTAL: 136 REPS**',
        1.0,
        ARRAY['https://www.smolovjr.com/smolov-squat-routine/'],
        NULL
    )
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links)
VALUES
    -- Base Mesocycle - Monday
    (
        'e1b2c3d4-5678-4abc-9def-666666666666',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'e1b2c3d4-5678-4abc-9def-222222222222',
        9,
        4,
        '00:03:00',
        1000,
        0, -- Progression is programmed, not user-controlled
        '4 sets of 9 reps. Week 3: 70% 1RM | Week 4: +20 lbs | Week 5: +10-20 lbs | Week 6: +10 lbs. All sets same weight. This is the volume day - highest total reps of the week.',
        NULL
    ),
    -- Base Mesocycle - Wednesday
    (
        'e1b2c3d4-5678-4abc-9def-777777777777',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'e1b2c3d4-5678-4abc-9def-333333333333',
        7,
        5,
        '00:03:00',
        1000,
        0, -- Progression is programmed
        '5 sets of 7 reps. Week 3: 75% 1RM | Week 4: +20 lbs | Week 5: +10-20 lbs | Week 6: +10 lbs. All sets same weight. Higher intensity than Monday.',
        NULL
    ),
    -- Base Mesocycle - Friday
    (
        'e1b2c3d4-5678-4abc-9def-888888888888',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'e1b2c3d4-5678-4abc-9def-444444444444',
        5,
        7,
        '00:04:00',
        1000,
        0, -- Progression is programmed
        '7 sets of 5 reps. Week 3: 80% 1RM | Week 4: +20 lbs | Week 5: +10-20 lbs | Week 6: +10 lbs. All sets same weight. Higher intensity, fewer reps per set.',
        NULL
    ),
    -- Base Mesocycle - Saturday
    (
        'e1b2c3d4-5678-4abc-9def-999999999999',
        '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
        'e1b2c3d4-5678-4abc-9def-555555555555',
        3,
        10,
        '00:04:00',
        1000,
        0, -- Progression is programmed
        '10 sets of 3 reps. Week 3: 85% 1RM | Week 4: +20 lbs | Week 5: +10-20 lbs | Week 6: +10 lbs. Highest intensity of the week. This completes 136 total weekly reps. Rest 3-5 min between sets.',
        NULL
    )
ON CONFLICT (exercise_id) DO NOTHING;

-- =============================================================================
-- MIGRATION SUMMARY
-- =============================================================================
-- This migration adds 5 comprehensive powerlifting programs:
--
-- 1. Starting Strength - Beginner linear progression (2 sessions)
-- 2. Madcow 5x5 - Intermediate weekly progression (3 sessions)
-- 3. Texas Method - Intermediate volume/intensity split (3 sessions)
-- 4. Wendler 5/3/1 - Intermediate/Advanced monthly cycles (4 sessions)
-- 5. Smolov - Advanced squat specialization (4 base mesocycle sessions shown)
--
-- Total additions:
-- - 5 Plans
-- - 16 Session Schedules
-- - 33 Exercises
--
-- All programs use existing base_exercise entries from the database.
-- Safe to re-run with ON CONFLICT DO NOTHING clauses.
-- =============================================================================
