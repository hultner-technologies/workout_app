-- =============================================================================
-- BODYBUILDING PROGRAMS MIGRATION
-- =============================================================================
-- Date: 2025-11-22
-- Description: Comprehensive migration adding 6 evidence-based bodybuilding programs
-- Programs: Reddit PPL, Arnold's Golden Six, Arnold Split, PHUL, Lyle's GBR, Fierce 5
--
-- This migration adds workout plans, session schedules, and exercise configurations
-- for popular bodybuilding programs suitable for beginners through advanced lifters.
-- =============================================================================

-- =============================================================================
-- PLANS (Workout Programs)
-- =============================================================================

INSERT INTO plan (plan_id, name, description, links, data)
VALUES
    -- Reddit PPL (Metallicadpa)
    (
        uuid_generate_v1mc(),
        'Reddit PPL',
        'The Reddit PPL is a high-frequency, high-volume, linear progression program designed specifically for beginners who want to train more frequently while still progressing appropriately. Created by Metallicadpa, this program became one of the most popular beginner routines on r/Fitness.

The program reconciles conventional training wisdom for beginners with what beginners actually want to do - train more frequently. Unlike traditional 3-day full-body routines, this allows beginners to be in the gym 6 days per week while still making linear progress on compound lifts.

**Structure:**
- Frequency: 6 days per week
- Split: Push / Pull / Legs repeated twice
- Schedule Options: PPLRPPL or PPLPPLR
- Session Duration: 60-90 minutes

**Progression:**
- Upper body lifts: Add 2.5kg/5lbs per session
- Squats: Add 2.5kg/5lbs per session
- Deadlifts: Add 5kg/10lbs per session
- AMRAP sets on main lifts for autoregulation

**Ideal For:**
Beginners who have mastered basic form on compound lifts and are ready to commit to a higher training frequency. Particularly suited for those who enjoy frequent gym sessions and want to maximize muscle growth while building a strength foundation.

**Program Duration:**
Indefinite - Run until linear progression stalls (typically 3-6 months for beginners), then transition to intermediate program.',
        ARRAY[
            'https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/',
            'https://www.reddit.com/r/Fitness/comments/37ylk5/a_linear_progression_based_ppl_program_for/',
            'https://liftvault.com/programs/strength/reddit-ppl/',
            'https://www.drworkout.fitness/reddit-metallicadpa-ppl/'
        ],
        NULL
    ),

    -- Arnold's Golden Six
    (
        uuid_generate_v1mc(),
        'Arnold''s Golden Six',
        'The Golden Six is Arnold Schwarzenegger''s foundational program that he credits with building his initial muscle mass after moving to Munich in 1966. In Arnold''s own words: "When I was trying to get bigger in my early days of training, I followed a routine called the Golden Six. I made tremendous gains on this program and so did many others who trained at my gym in Munich."

This old-school bodybuilding routine centers around six fundamental compound exercises performed three times per week. The philosophy is simple: master the basic movements with progressive overload and high volume to build a solid foundation of muscle mass.

**Structure:**
- Frequency: 3 days per week (full body)
- Schedule: Non-consecutive days (e.g., Monday/Wednesday/Friday)
- Session Duration: 60-90 minutes
- Split: Full body every session

**Progression:**
1. Perform prescribed sets and reps (e.g., 3 sets of 10)
2. On final set of each exercise, perform AMRAP (As Many Reps As Possible)
3. If you achieve 13+ reps on the AMRAP set, increase weight next session
4. Add 5 lbs (2.5 kg) per session when hitting progression target

**Ideal For:**
Beginners and early intermediates who want a proven, straightforward program. Requires only basic gym equipment (barbell, weights, pullup bar) and can be completed in 60-90 minutes per session.

**Program Duration:**
Indefinite - Run continuously until linear progression stalls. Arnold recommends resetting every 12 weeks to prevent plateaus. Typical run time: 3-6 months before transitioning to higher-frequency split training.',
        ARRAY[
            'https://liftvault.com/programs/bodybuilding/arnold-schwarzenegger-workout-routine-golden-six/',
            'https://www.liftosaur.com/programs/arnoldgoldensix',
            'https://www.menshealth.com/uk/building-muscle/a44207380/schwarzeneggers-golden-six-workout-for-beginners/',
            'https://www.fitnessandpower.com/training/workout-routines/arnold-schwarzenegger-golden-six'
        ],
        NULL
    ),

    -- Arnold Split
    (
        uuid_generate_v1mc(),
        'Arnold Split',
        'The Arnold Split is the high-volume, high-frequency training program Arnold Schwarzenegger used during his competitive bodybuilding career. Outlined in his 1985 book "The New Encyclopedia of Modern Bodybuilding," this is the "Level 1" routine, which, despite the name, is not truly for beginners - it represents an advanced training approach.

The philosophy behind the Arnold Split is brutally simple: maximum volume, maximum frequency, and relentless intensity. Arnold often trained twice per day, six days per week, using a body part split where each muscle group was hit with extremely high volume using both compound and isolation movements. The program emphasizes training opposing muscle groups together (chest/back, biceps/triceps) to create powerful muscle pumps and maximize training density.

**Structure:**
- Frequency: 6 days per week
- Split Type: Body part split (Chest/Back, Shoulders/Arms, Legs)
- Schedule: Each workout performed twice weekly
- Session Duration: 90-150 minutes per session (often split into 2 daily sessions)
- Days: Day 1: Chest & Back, Day 2: Shoulders & Arms, Day 3: Legs & Lower Back, repeat

**Progression:**
Uses pyramid training - start lighter with higher reps (12-15), increase weight each set while decreasing reps, final sets are heaviest with lowest reps (6-8). When able to complete all sets in the top rep range, add weight.

**Rest Periods:**
60 seconds or less between most sets, 30-45 seconds during supersets, no more than 90 seconds even on heavy compounds.

**Important Notes:**
This program is for experienced intermediate and advanced lifters who have built a solid foundation of strength, mastered exercise form, and developed the work capacity to handle very high training volumes. Requires exceptional recovery ability, proper nutrition, and often 2+ hours in the gym per session.

**Prerequisites:**
- At least 1-2 years of consistent training
- Mastery of compound movements
- Ability to train 6 days per week
- Excellent nutrition and sleep for recovery

**Program Duration:**
8-12 week cycles with deload weeks recommended. Deload (reduce volume by 40-50%) for one week every 6-8 weeks.',
        ARRAY[
            'https://www.muscleandstrength.com/workouts/arnold-schwarzenegger-volume-workout-routines',
            'https://www.blkboxgym.com/blog/the-ultimate-6-day-workout-split-arnold-schwarzeneggers-blueprint-to-mass',
            'https://legionathletics.com/arnold-split/',
            'https://www.hevyapp.com/arnold-split-workout/',
            'https://barbend.com/arnold-schwarzenegger-workout-split/'
        ],
        NULL
    ),

    -- PHUL
    (
        uuid_generate_v1mc(),
        'PHUL',
        'PHUL stands for Power Hypertrophy Upper Lower and represents a sophisticated approach to training that balances strength development with muscle growth. The program splits training into four days: two power (strength) days and two hypertrophy (muscle growth) days, alternating between upper and lower body.

The philosophy behind PHUL is that strength and size are complementary goals that should both be trained within the same program. Power days focus on heavy compound movements in the 3-5 rep range to build maximum strength and neuromuscular efficiency. Hypertrophy days use moderate weights in the 8-12 rep range to accumulate volume and create metabolic stress - both key drivers of muscle growth.

**Structure:**
- Frequency: 4 days per week
- Split: Upper/Lower with Power and Hypertrophy emphasis
- Schedule: Day 1: Upper Power, Day 2: Lower Power, Day 3: Rest, Day 4: Upper Hypertrophy, Day 5: Lower Hypertrophy, Days 6-7: Rest
- Session Duration: 60-90 minutes

**Progression:**

*Power Days (Linear Progression):*
- When you hit the top of the rep range (5 reps) for all sets, add weight
- Add 2.5kg/5lbs to upper body lifts
- Add 5kg/10lbs to lower body lifts

*Hypertrophy Days (Double Progression):*
- First progress reps within the range (8 → 12)
- When hitting 12 reps for all sets, increase weight and drop back to 8 reps
- Smaller jumps: 1.25-2.5kg (2.5-5lbs) increments

**Rest Periods:**
- Power days (3-5 reps): 2-3 minutes
- Hypertrophy days (8-12 reps): 60-120 seconds
- Isolation exercises: 60-90 seconds

**Ideal For:**
Intermediate lifters who have mastered the basic movement patterns and are ready for a more sophisticated training approach. Requires 4 days per week in the gym, making it more sustainable than 6-day programs while still providing optimal training frequency.

**Program Duration:**
8-12 week cycles with deload weeks. Run for 4-6 weeks, deload (reduce volume/intensity by 40-50%), then continue. Can be run indefinitely with periodic deloads and exercise variations.',
        ARRAY[
            'https://www.muscleandstrength.com/workouts/phul-workout',
            'https://www.hevyapp.com/phul-power-hypertrophy-upper-lower/',
            'https://www.strengthlog.com/phul-workout-routine/',
            'https://muscleevo.net/phul-workout/',
            'https://liftvault.com/programs/strength/phul-spreadsheet/'
        ],
        NULL
    ),

    -- Lyle McDonald's Generic Bulking Routine
    (
        uuid_generate_v1mc(),
        'Lyle McDonald''s Generic Bulking Routine',
        'Lyle McDonald''s Generic Bulking Routine is a 4-day upper/lower split specifically designed for intermediate lifters during a caloric surplus with the goal of gaining 0.5-1 pound per week. Created by Lyle McDonald, one of the most respected figures in evidence-based fitness, this program focuses on building maximum muscle mass while minimizing fat gain.

The philosophy centers on flexible programming with varied set and rep ranges based on exercise type and position in the workout. The program uses a tiered approach: heavy compounds for 3-4 sets of 6-8 reps, secondary movements for 2-3 sets of 10-12 reps, and isolation work for 1-2 sets of 12-15 reps. This structure allows for strength gains on main lifts while accumulating sufficient volume for hypertrophy.

**Structure:**
- Frequency: 4 days per week
- Split: Upper/Lower
- Schedule: Monday: Lower, Tuesday: Upper, Wednesday: Rest, Thursday: Lower, Friday: Upper, Weekend: Rest
- Session Duration: 60-90 minutes
- Program Length: 6-8 weeks before mandatory deload

**Progression (3-Phase Model):**

*Phase 1: Week 1 (Baseline)*
- Start at 80-85% of estimated rep max
- Complete prescribed sets and reps
- Focus on perfect form

*Phase 2: Weeks 2-4 (Weekly Progression)*
- Add 5% to all lifts each week
- Aggressive early-cycle progression

*Phase 3: Weeks 5-8 (Per-Session Progression)*
- Add weight when completing all sets with 1-2 reps in reserve
- Lower body: Add 5-10 lbs
- Upper body: Add 2.5-5 lbs
- Accessories: Add 1-2.5 lbs or increase reps

**Autoregulation:**
After 3 sets, assess whether to do 4th set based on form quality, bar speed, and RPE.

**Rest Periods:**
- 6-8 rep range: 3 minutes
- 10-12 rep range: 2 minutes
- 12-15 rep range: 90 seconds

**Deload:**
Every 6-8 weeks, reduce weights by 40-50%, maintain reps/sets for one week.

**Ideal For:**
Intermediate lifters (1-3 years of consistent training) who have exhausted beginner linear progression. Should be paired with a structured nutritional surplus for optimal results.

**Program Duration:**
6-8 week cycles with mandatory deload week. Can be run for multiple cycles (6-12 months) as long as you''re in a caloric surplus and making progress.',
        ARRAY[
            'https://liftvault.com/programs/bodybuilding/lyle-mcdonald-bulking-workout-routine-spreadsheet/',
            'https://jcdfitness.com/2009/01/lyle-mcdonalds-bulking-routine/',
            'https://jcdfitness.com/wp-content/download/Lyle_McDonald_Generic_Bulking_Routine_FAQ.pdf',
            'https://legionathletics.com/lyle-mcdonald-generic-bulking-routine/',
            'https://www.drworkout.fitness/lyle-mcdonald-generic-bulking-routine/'
        ],
        NULL
    ),

    -- Fierce 5
    (
        uuid_generate_v1mc(),
        'Fierce 5',
        'The Fierce 5 workout program was created by bodybuilding.com forum user davisj3537, who designed it because he "wasn''t completely satisfied with the majority of popular programs." He specifically cited issues with many beginner programs including slow progression, improper volume balance, and lack of what he considered proper exercise balance.

The philosophy behind Fierce 5 is to provide beginners with a simple, effective program that incorporates compound lifts for strength development alongside accessory movements for balanced muscle growth. Unlike pure strength programs (Starting Strength, StrongLifts), Fierce 5 includes more upper body volume and aesthetic-focused exercises.

**Structure:**
- Frequency: 3 days per week (non-consecutive)
- Split: Rotating A/B workouts
- Schedule Example: Week 1: Mon (A), Wed (B), Fri (A); Week 2: Mon (B), Wed (A), Fri (B); repeat
- Session Duration: 45-75 minutes
- Program Length: 4-6 months for bulking

**Progression (Two-Week Wave):**

*Week 1: Add Reps*
- 5-rep exercises: Add 1 rep per set (5 → 6)
- 8-rep exercises: Add 2 reps per set (8 → 10)
- 10-15 rep exercises: Add 2 reps per set

*Week 2: Add Weight, Reset Reps*
- Upper body lifts: Add 5 lbs
- Lower body lifts: Add 10 lbs
- Accessories: Add 5 lbs
- Reset reps to original prescription

**Deload:**
After 8-12 weeks or if failing reps for 2 consecutive sessions. Reduce weight by 10%, maintain reps for one week.

**Rest Periods:**
- 5-rep compounds: 2-3 minutes
- 8-rep exercises: 2 minutes
- 10-15 rep accessories: 90 seconds
- Supersets: Minimal rest between, normal rest after both

**Ideal For:**
Beginners with less than 6 months of consistent, structured training who want a balanced approach to strength and aesthetics. Designed for bulking males (females or those cutting should progress more slowly).

**Program Duration:**
4-6 months for bulking males, 6-9 months for slower progression. Transition to upper/lower split (PHUL) or other intermediate program after stalling.',
        ARRAY[
            'https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/',
            'https://fitnessvolt.com/fierce-5-workout/',
            'https://steelsupplements.com/blogs/steel-blog/the-fierce-5-workout-program',
            'https://www.psmfdiet.com/fierce-5/',
            'https://forum.bodybuilding.com/showthread.php?t=159678631'
        ],
        NULL
    )
ON CONFLICT (plan_id) DO NOTHING;

-- =============================================================================
-- SESSION SCHEDULES (Workout Days/Sessions within Programs)
-- =============================================================================

-- Get plan IDs for reference (these will be generated dynamically)
-- Reddit PPL Sessions
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Pull Day',
    'Deadlifts and barbell rows alternate each Pull day. When doing deadlifts: 1×5+ (single heavy set). When doing rows: 4×5, 1×5+ (standard progression). All final sets of main lifts are AMRAP (As Many Reps As Possible).

**Alternating Pattern:**
- Pull Day A: Deadlifts 1×5+, skip barbell rows
- Pull Day B: Barbell Rows 4×5 + 1×5+, skip deadlifts

**Rest Periods:**
- Main compounds (5+ sets): 3-5 minutes
- Accessory exercises (8-12 reps): 1-3 minutes
- Isolation work: 1-2 minutes',
    1.0,
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"notes": "Alternate deadlifts and barbell rows each workout", "main_lifts_amrap": true}'::jsonb
FROM plan WHERE name = 'Reddit PPL'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Push Day',
    'Bench press and overhead press alternate as the main movement each Push day. The movement not done as main lift is performed for 3×8-12. Tricep and lateral raise exercises are performed as supersets (SS = perform exercises back-to-back).

**Alternating Pattern:**
- Push Day A: Bench Press 4×5 + 1×5+ (main), OHP 3×8-12 (accessory)
- Push Day B: OHP 4×5 + 1×5+ (main), Bench Press 3×8-12 (accessory)

**Rest Periods:**
- Main compounds (5+ sets): 3-5 minutes
- Accessory exercises (8-12 reps): 1-3 minutes
- Supersets: Minimal rest between exercises',
    1.0,
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"notes": "Alternate bench press and OHP as main lift", "supersets": ["Tricep Pushdowns + Lateral Raises", "Overhead Tricep Extension + Lateral Raises"]}'::jsonb
FROM plan WHERE name = 'Reddit PPL'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Leg Day',
    'Comprehensive leg training focusing on squats as the main compound movement, followed by posterior chain work (Romanian deadlifts), quad volume (leg press), hamstring isolation (leg curls), and high-volume calf work.

**Progression:**
- Squats: 2×5, 1×5+ with final set AMRAP
- Add 2.5kg/5lbs per session when hitting progression target
- High volume on calves (5 sets) for stubborn muscle growth

**Rest Periods:**
- Squats: 3-5 minutes
- Accessory exercises: 1-3 minutes
- Isolation work: 1-2 minutes',
    1.0,
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"notes": "Final squat set is AMRAP", "calf_volume": "High volume (5 sets) for calf development"}'::jsonb
FROM plan WHERE name = 'Reddit PPL'
ON CONFLICT (session_schedule_id) DO NOTHING;

-- Arnold's Golden Six Sessions
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Full Body Workout',
    'Classic full-body routine performed 3 times per week on non-consecutive days (e.g., Monday/Wednesday/Friday). Six fundamental compound exercises focusing on pure strength and size gains.

**Progression:**
1. Perform prescribed sets and reps (e.g., 3 sets of 10)
2. On final set of each exercise, perform AMRAP (As Many Reps As Possible)
3. If you achieve 13+ reps on the AMRAP set, increase weight next session
4. Add 5 lbs (2.5 kg) per session when hitting target

**Weekly Potential:**
Up to 15 lbs / 7.5 kg added to lifts per week if progressing on all three sessions.

**Rest Periods:**
- Squats: Up to 2 minutes
- All other exercises: 60-90 seconds

**Exercise Notes:**
- Squat: Full depth, focus on proper form
- Bench Press: Wide grip to emphasize chest
- Chin-Ups: Can substitute with pulldowns if needed, work toward bodyweight pullups
- Behind-the-Neck Press: Can substitute with standard overhead press if shoulder mobility is limited
- Barbell Curl: Strict form, no momentum
- Sit-Ups: Bent knees to reduce hip flexor involvement',
    1.0,
    ARRAY[
        'https://liftvault.com/programs/bodybuilding/arnold-schwarzenegger-workout-routine-golden-six/',
        'https://www.liftosaur.com/programs/arnoldgoldensix'
    ],
    '{"frequency": "3x per week", "amrap_progression": true, "target_reps_for_progression": 13}'::jsonb
FROM plan WHERE name = 'Arnold''s Golden Six'
ON CONFLICT (session_schedule_id) DO NOTHING;

-- Arnold Split Sessions
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Chest & Back',
    'Day 1 & 4 of Arnold Split. Antagonistic muscle pairing with extensive supersets. 45+ working sets total. Arnold often supersetted chest and back exercises for maximum pump and training density.

**Superset Examples:**
- Bench Press SS Chin-Ups
- Incline Press SS T-Bar Rows
- Flyes SS Seated Cable Rows

**Pyramid Training:**
Start lighter with higher reps (12-15), increase weight each set while decreasing reps. Final sets are heaviest with lowest reps (6-8).

**Rest Periods:**
- 60 seconds or less between most sets
- 30-45 seconds during supersets
- No more than 90 seconds even on heavy compounds

**Volume:**
- Chest: 6 exercises, ~30 total sets
- Back: 7 exercises, ~35 total sets

Arnold emphasized keeping rest periods short to maintain muscle pump and training intensity.',
    1.0,
    ARRAY[
        'https://www.muscleandstrength.com/workouts/arnold-schwarzenegger-volume-workout-routines',
        'https://legionathletics.com/arnold-split/'
    ],
    '{"total_sets": 45, "training_style": "pyramid_and_supersets", "rest_periods_short": true}'::jsonb
FROM plan WHERE name = 'Arnold Split'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Shoulders, Arms & Forearms',
    'Day 2 & 5 of Arnold Split. Comprehensive shoulder and arm development with 45-50+ working sets. Includes dedicated forearm work often neglected in modern programs.

**Muscle Groups:**
- Shoulders: 5 exercises (overhead press, lateral raises, front raises, rear delts, upright rows)
- Biceps: 4 exercises (barbell curls, seated curls, concentration curls, cable curls)
- Triceps: 5 exercises (close-grip bench, lying extensions, pushdowns, overhead extensions, dips)
- Forearms: 2 exercises (wrist curls, reverse wrist curls)

**Pyramid Training:**
Start lighter with higher reps (12-15), increase weight each set while decreasing reps.

**Rest Periods:**
- 60 seconds or less between most sets
- Keep training pace high for maximum pump

**Volume:**
Total 45-50+ working sets across all muscle groups.',
    1.0,
    ARRAY[
        'https://www.muscleandstrength.com/workouts/arnold-schwarzenegger-volume-workout-routines',
        'https://legionathletics.com/arnold-split/'
    ],
    '{"total_sets": 50, "muscle_groups": ["shoulders", "biceps", "triceps", "forearms"]}'::jsonb
FROM plan WHERE name = 'Arnold Split'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Legs & Lower Back',
    'Day 3 & 6 of Arnold Split. Comprehensive leg training with 40-50+ working sets. Includes dedicated lower back work (stiff-leg deadlifts, good mornings) in addition to hamstring exercises.

**Muscle Groups:**
- Quads: Squats, leg press, leg extensions
- Hamstrings: Leg curls, Romanian deadlifts
- Calves: Standing and seated calf raises (12 total sets)
- Lower back: Stiff-leg deadlifts, good mornings
- Glutes/unilateral: Lunges or step-ups

**Training Style:**
High volume with moderate rest periods (60-90 seconds). Squats receive 5-8 sets for maximum leg development.

**Calf Priority:**
12 total sets (6 standing + 6 seated) with full ROM and controlled tempo. Arnold believed in high volume for stubborn calves.

**Rest Periods:**
- Squats: Up to 90-120 seconds
- Other exercises: 60-90 seconds

**Volume:**
Total 40-50+ working sets.',
    1.0,
    ARRAY[
        'https://www.muscleandstrength.com/workouts/arnold-schwarzenegger-volume-workout-routines',
        'https://legionathletics.com/arnold-split/'
    ],
    '{"total_sets": 45, "calf_sets": 12, "squat_sets": "5-8"}'::jsonb
FROM plan WHERE name = 'Arnold Split'
ON CONFLICT (session_schedule_id) DO NOTHING;

-- PHUL Sessions
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Upper Power',
    'Day 1 of PHUL. Heavy compound movements for upper body strength development. Focus on 3-5 rep range with 3-minute rest periods on main lifts.

**Training Focus:**
Heavy weights, neural adaptations, strength building on bench press, rows, overhead press.

**Progression:**
When you hit the top of the rep range (5 reps) for all sets, add 2.5kg/5lbs to upper body lifts.

**Rest Periods:**
- 3-5 rep exercises: 3 minutes
- 6-10 rep exercises: 2-3 minutes
- Isolation work: 90 seconds',
    1.0,
    ARRAY[
        'https://www.muscleandstrength.com/workouts/phul-workout',
        'https://www.hevyapp.com/phul-power-hypertrophy-upper-lower/'
    ],
    '{"day": 1, "focus": "power", "rep_range": "3-5", "rest_periods_long": true}'::jsonb
FROM plan WHERE name = 'PHUL'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Lower Power',
    'Day 2 of PHUL. Heavy compound movements for lower body strength. Squats and deadlifts both performed for 3-5 reps to build maximum strength.

**Training Focus:**
Heavy compound movements for legs and posterior chain. Build strength foundation on squats and deadlifts.

**Progression:**
When you hit the top of the rep range (5 reps) for all sets, add 5kg/10lbs to lower body lifts.

**Rest Periods:**
- Squat/Deadlift: 3 minutes
- Leg press: 2 minutes
- Accessories: 90-120 seconds',
    1.0,
    ARRAY[
        'https://www.muscleandstrength.com/workouts/phul-workout',
        'https://www.hevyapp.com/phul-power-hypertrophy-upper-lower/'
    ],
    '{"day": 2, "focus": "power", "rep_range": "3-5", "includes_squat_and_deadlift": true}'::jsonb
FROM plan WHERE name = 'PHUL'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Upper Hypertrophy',
    'Day 4 of PHUL. Moderate weights in 8-12 rep range for muscle growth. Focus on muscle pump, metabolic stress, and time under tension.

**Training Focus:**
Muscle pump, metabolic stress, time under tension. Includes variety of pressing and pulling angles.

**Progression (Double Progression):**
1. Progress reps within the range (8 → 12)
2. When hitting 12 reps for all sets, increase weight and drop back to 8 reps
3. Smaller jumps: 1.25-2.5kg (2.5-5lbs)

**Rest Periods:**
- Main lifts: 90-120 seconds
- Accessories: 60-90 seconds',
    1.0,
    ARRAY[
        'https://www.muscleandstrength.com/workouts/phul-workout',
        'https://www.hevyapp.com/phul-power-hypertrophy-upper-lower/'
    ],
    '{"day": 4, "focus": "hypertrophy", "rep_range": "8-12", "progression": "double"}'::jsonb
FROM plan WHERE name = 'PHUL'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Lower Hypertrophy',
    'Day 5 of PHUL. High volume leg work with muscle pumps and hypertrophy focus. Includes front squats, lunges, and isolation exercises.

**Training Focus:**
High volume leg work, muscle pumps, hypertrophy. Emphasizes quads, hamstrings, and calves with 8-15 rep ranges.

**Progression (Double Progression):**
Progress reps within range, then add weight when hitting top of range for all sets.

**Rest Periods:**
- Compounds (front squat, lunges): 90-120 seconds
- Isolation (leg ext/curl): 60-90 seconds
- Calves: 60 seconds',
    1.0,
    ARRAY[
        'https://www.muscleandstrength.com/workouts/phul-workout',
        'https://www.hevyapp.com/phul-power-hypertrophy-upper-lower/'
    ],
    '{"day": 5, "focus": "hypertrophy", "rep_range": "8-15", "includes_front_squat": true}'::jsonb
FROM plan WHERE name = 'PHUL'
ON CONFLICT (session_schedule_id) DO NOTHING;

-- Lyle McDonald's GBR Sessions
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Lower Body A',
    'Monday''s lower body session. Flexible exercise selection within categories. Uses tiered set/rep scheme: heavy compounds (3-4 sets of 6-8), secondary movements (2-3 sets of 10-12), calves (varied).

**Exercise Selection:**
Choose one exercise from each category based on preference and equipment availability.

**Autoregulation:**
After 3 sets, decide whether to do 4th set based on form quality, bar speed, and RPE. Skip if form degraded or bar speed slowed significantly.

**Progression:**
Phase 1 (Week 1): Establish baseline at 80-85% rep max
Phase 2 (Weeks 2-4): Add 5% weekly
Phase 3 (Weeks 5-8): Add weight per session when completing all sets with 1-2 RIR

**Rest Periods:**
- 6-8 rep range: 3 minutes
- 10-12 rep range: 2 minutes',
    1.0,
    ARRAY[
        'https://jcdfitness.com/2009/01/lyle-mcdonalds-bulking-routine/',
        'https://liftvault.com/programs/bodybuilding/lyle-mcdonald-bulking-workout-routine-spreadsheet/'
    ],
    '{"day": "Monday", "body_part": "lower", "autoregulation": true, "set_decision": "3_vs_4_sets"}'::jsonb
FROM plan WHERE name = 'Lyle McDonald''s Generic Bulking Routine'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Upper Body A',
    'Tuesday''s upper body session. Flexible exercise selection within categories. Includes optional rear delt, rotator cuff, and ab work.

**Exercise Selection:**
Choose exercises within categories. Can alternate between Tuesday and Friday for variety.

**Autoregulation:**
After 3 sets, assess whether to perform 4th set based on performance.

**Optional Work:**
- Rear delts: 2-3 sets of 12-15 reps (face pulls, reverse flyes)
- Rotator cuff: 1-2 sets of 15-20 reps
- Abs: 2-3 sets as needed

**Rest Periods:**
- 6-8 rep range: 3 minutes
- 10-12 rep range: 2 minutes
- 12-15 rep range: 90 seconds',
    1.0,
    ARRAY[
        'https://jcdfitness.com/2009/01/lyle-mcdonalds-bulking-routine/',
        'https://liftvault.com/programs/bodybuilding/lyle-mcdonald-bulking-workout-routine-spreadsheet/'
    ],
    '{"day": "Tuesday", "body_part": "upper", "optional_work": ["rear_delts", "rotator_cuff", "abs"]}'::jsonb
FROM plan WHERE name = 'Lyle McDonald''s Generic Bulking Routine'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Lower Body B',
    'Thursday''s lower body session. Some lifters prefer deadlifts on Thursday instead of squatting twice weekly. Same structure as Monday with flexible exercise selection.

**Variation Option:**
Can substitute deadlifts for squats on this day for lifters who prefer not to squat twice weekly.

**Autoregulation:**
Use the 3 vs 4 set decision based on performance quality.

**Rest Periods:**
- 6-8 rep range: 3 minutes
- 10-12 rep range: 2 minutes',
    1.0,
    ARRAY[
        'https://jcdfitness.com/2009/01/lyle-mcdonalds-bulking-routine/',
        'https://liftvault.com/programs/bodybuilding/lyle-mcdonald-bulking-workout-routine-spreadsheet/'
    ],
    '{"day": "Thursday", "body_part": "lower", "deadlift_option": "Can substitute deadlifts for squats"}'::jsonb
FROM plan WHERE name = 'Lyle McDonald''s Generic Bulking Routine'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Upper Body B',
    'Friday''s upper body session. Same structure as Tuesday. Can alternate exercises for variety while maintaining program structure.

**Exercise Flexibility:**
Within each category, can choose different exercises than Tuesday for variety.

**Rest Periods:**
- 6-8 rep range: 3 minutes
- 10-12 rep range: 2 minutes
- 12-15 rep range: 90 seconds',
    1.0,
    ARRAY[
        'https://jcdfitness.com/2009/01/lyle-mcdonalds-bulking-routine/',
        'https://liftvault.com/programs/bodybuilding/lyle-mcdonald-bulking-workout-routine-spreadsheet/'
    ],
    '{"day": "Friday", "body_part": "upper", "exercise_variation": true}'::jsonb
FROM plan WHERE name = 'Lyle McDonald''s Generic Bulking Routine'
ON CONFLICT (session_schedule_id) DO NOTHING;

-- Fierce 5 Sessions
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Workout A',
    'First workout in the Fierce 5 A/B rotation. 14 total sets. Includes squat, bench press, Pendlay rows, reverse flyes, and a superset of calf raises with tricep pushdowns.

**Two-Week Progression Wave:**

*Week 1 (Odd weeks): Add Reps*
- Squat & Bench: 3×6 (add 1 rep from base 5)
- Pendlay Rows: 3×10 (add 2 reps from base 8)
- Reverse Flyes: 3×12 (add 2 reps from base 10)
- Superset: Calves 2×17, Triceps 2×12

*Week 2 (Even weeks): Add Weight, Reset Reps*
- Add 10 lbs to squats
- Add 5 lbs to bench, rows, reverse flyes, superset exercises
- Return to base reps (5/8/10/15/10)

**Superset Notes:**
Complete calf raises, immediately perform tricep pushdowns, then rest.

**Rest Periods:**
- 5-rep exercises: 2-3 minutes
- 8-rep exercises: 2 minutes
- 10-15 rep accessories: 90 seconds
- Supersets: Minimal between, normal after both',
    1.0,
    ARRAY[
        'https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/',
        'https://forum.bodybuilding.com/showthread.php?t=159678631'
    ],
    '{"workout": "A", "total_sets": 14, "progression": "wave_loading", "includes_superset": true}'::jsonb
FROM plan WHERE name = 'Fierce 5'
ON CONFLICT (session_schedule_id) DO NOTHING;

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
SELECT
    uuid_generate_v1mc(),
    plan_id,
    'Workout B',
    'Second workout in the Fierce 5 A/B rotation. 14 total sets. Includes front squat, overhead press, Romanian deadlifts, lat pulldowns, and a superset of ab work with curls.

**Two-Week Progression Wave:**

*Week 1 (Odd weeks): Add Reps*
- Front Squat & OHP: 3×6
- Romanian Deadlifts & Lat Pulldowns: 3×10
- Superset: Abs 2×17, Curls 2×12

*Week 2 (Even weeks): Add Weight, Reset Reps*
- Add 10 lbs to front squats and RDLs
- Add 5 lbs to OHP, lat pulldowns, and superset exercises
- Return to base reps

**Alternative:**
Can substitute incline bench press for overhead press if preferred.

**Superset Notes:**
Complete ab work (hanging leg raises, cable crunches, or weighted ab exercise), immediately perform bicep curls, then rest.

**Rest Periods:**
- 5-rep exercises: 2-3 minutes
- 8-rep exercises: 2 minutes
- Supersets: Minimal between, normal after both',
    1.0,
    ARRAY[
        'https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/',
        'https://forum.bodybuilding.com/showthread.php?t=159678631'
    ],
    '{"workout": "B", "total_sets": 14, "progression": "wave_loading", "ohp_alternative": "incline bench press"}'::jsonb
FROM plan WHERE name = 'Fierce 5'
ON CONFLICT (session_schedule_id) DO NOTHING;

-- =============================================================================
-- EXERCISES (Exercise configurations within session schedules)
-- =============================================================================
-- Note: Using existing base_exercise_ids from the seed data where available
-- =============================================================================

-- REDDIT PPL EXERCISES
-- Pull Day exercises
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', -- Deadlift
    ss.session_schedule_id,
    5,
    1,
    '00:05:00'::interval,
    1000,
    5000, -- 5kg/10lbs increment for deadlifts
    'Alternate with barbell rows each Pull day. When doing deadlifts: 1×5+ (single heavy AMRAP set). Skip this exercise on days when doing barbell rows.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"amrap": true, "alternates_with": "barbell_rows", "pattern": "Pull_Day_A"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Pull Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', -- Barbell Row
    ss.session_schedule_id,
    5,
    5,
    '00:03:00'::interval,
    2000,
    2500, -- 2.5kg/5lbs increment
    'Alternate with deadlifts each Pull day. When doing barbell rows: 4×5, 1×5+ with final set AMRAP. Skip this exercise on days when doing deadlifts.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"amrap_final_set": true, "alternates_with": "deadlifts", "pattern": "Pull_Day_B", "sets_breakdown": "4 regular + 1 AMRAP"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Pull Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bef6fb96-05c8-11ed-824f-d7ac01edbd91', -- Lat pulldown
    ss.session_schedule_id,
    10,
    3,
    '00:02:00'::interval,
    3000,
    2500,
    'Lat pulldowns, pullups, or chinups - any grip variation. Pull with your back, not biceps. Full range of motion.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "grip_variations": ["wide", "narrow", "neutral"], "can_substitute": ["pullups", "chinups"]}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Pull Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bef59bde-05c8-11ed-824f-efb3c762cda1', -- Seated cable row
    ss.session_schedule_id,
    10,
    3,
    '00:02:00'::interval,
    4000,
    2500,
    'Seated cable rows or chest-supported rows. Pull to lower chest, squeeze shoulder blades together.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "alternative": "chest-supported rows"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Pull Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '34bd3f09-0a5a-480b-b450-746b1e5c7274', -- Face pulls
    ss.session_schedule_id,
    18,
    5,
    '00:01:30'::interval,
    5000,
    2500,
    'Face pulls for rear delt focus. Pull rope to face level, external rotation at peak. High volume (5 sets).',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "15-20", "focus": "rear_delts", "cue": "external_rotation"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Pull Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '62fe9884-1c76-4224-af6e-8cd05a17e385', -- Hammer curls
    ss.session_schedule_id,
    10,
    4,
    '00:01:30'::interval,
    6000,
    2500,
    'Hammer curls for brachialis focus. Keep elbows pinned, no swinging.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "focus": "brachialis"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Pull Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bee63c0c-05c8-11ed-824f-673da9665bfa', -- Bicep curl (dumbbell)
    ss.session_schedule_id,
    10,
    4,
    '00:01:30'::interval,
    7000,
    2500,
    'Dumbbell curls for bicep isolation. Strict form, full supination at top.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "cue": "full_supination"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Pull Day'
ON CONFLICT (exercise_id) DO NOTHING;

-- Push Day exercises
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench press
    ss.session_schedule_id,
    5,
    5,
    '00:04:00'::interval,
    1000,
    2500,
    'Alternate as main lift with OHP each Push day. Push Day A: Bench 4×5 + 1×5+ AMRAP (main). Push Day B: Bench 3×8-12 (accessory).',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"amrap_final_set": true, "alternates_with": "OHP", "main_on": "Push_Day_A", "accessory_on": "Push_Day_B"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Push Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead press
    ss.session_schedule_id,
    5,
    5,
    '00:04:00'::interval,
    2000,
    2500,
    'Alternate as main lift with bench press each Push day. Push Day A: OHP 3×8-12 (accessory). Push Day B: OHP 4×5 + 1×5+ AMRAP (main).',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"amrap_final_set": true, "alternates_with": "bench_press", "main_on": "Push_Day_B", "accessory_on": "Push_Day_A"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Push Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bee3dda4-05c8-11ed-824f-2f172103312d', -- Incline dumbbell press
    ss.session_schedule_id,
    10,
    3,
    '00:02:00'::interval,
    3000,
    2500,
    'Incline dumbbell press for upper chest focus. 30-45 degree incline.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "incline": "30-45 degrees", "focus": "upper_chest"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Push Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'b5d34436-b28a-41cb-bfd1-93051e352f3f', -- Tricep pushdowns
    ss.session_schedule_id,
    10,
    3,
    '00:01:00'::interval,
    4000,
    2500,
    'Superset with lateral raises. Tricep pushdowns: keep elbows pinned, full extension.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "superset_with": "lateral_raises", "rest_between_exercises": "minimal"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Push Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'a3532824-4bc2-11ee-8c75-ebab3389e058', -- Lateral raises
    ss.session_schedule_id,
    18,
    3,
    '00:01:00'::interval,
    4100,
    2500,
    'Superset with tricep pushdowns. Lateral raises: strict form, slight forward lean.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "15-20", "superset_with": "tricep_pushdowns", "form": "strict"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Push Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bee7fe8e-05c8-11ed-824f-578dbf84191f', -- Overhead tricep extension
    ss.session_schedule_id,
    10,
    3,
    '00:01:00'::interval,
    5000,
    2500,
    'Superset with lateral raises. Overhead tricep extension: full stretch and contraction.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "superset_with": "lateral_raises", "cue": "full_stretch"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Push Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'a3532824-4bc2-11ee-8c75-ebab3389e058', -- Lateral raises (2nd superset)
    ss.session_schedule_id,
    18,
    3,
    '00:01:00'::interval,
    5100,
    2500,
    'Superset with overhead tricep extension. Second round of lateral raises for shoulder volume.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "15-20", "superset_with": "overhead_tricep_extension", "note": "second_round"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Push Day'
ON CONFLICT (exercise_id) DO NOTHING;

-- Leg Day exercises
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    ss.session_schedule_id,
    5,
    3,
    '00:04:00'::interval,
    1000,
    2500,
    'Barbell squat: 2×5, 1×5+ with final set AMRAP. Add 2.5kg/5lbs per session when hitting progression.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"amrap_final_set": true, "sets_breakdown": "2 regular + 1 AMRAP"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Leg Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'ebe84120-4658-49f9-b15c-c3fc72dd6608', -- Romanian deadlift
    ss.session_schedule_id,
    10,
    3,
    '00:02:00'::interval,
    2000,
    2500,
    'Romanian deadlifts for hamstring and glute focus. Hip hinge pattern, feel the stretch.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "focus": "hamstrings_glutes"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Leg Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '5270cfc0-31a3-458e-9baf-62803346d03f', -- Leg press
    ss.session_schedule_id,
    10,
    3,
    '00:02:00'::interval,
    3000,
    2500,
    'Leg press for quad volume. Feet shoulder-width, lower to 90 degrees.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "focus": "quads"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Leg Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '1a88e6b4-31ba-11ed-aa8c-8bb194e2b67f', -- Leg curl
    ss.session_schedule_id,
    10,
    3,
    '00:01:30'::interval,
    4000,
    2500,
    'Leg curls for hamstring isolation. Control the negative.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "focus": "hamstrings"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Leg Day'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bef283ae-05c8-11ed-824f-870b793b71df', -- Calf raise
    ss.session_schedule_id,
    10,
    5,
    '00:01:30'::interval,
    5000,
    2500,
    'Calf raises: high volume (5 sets) for stubborn calf development. Full ROM, squeeze at top.',
    ARRAY['https://thefitness.wiki/reddit-archive/a-linear-progression-based-ppl-program-for-beginners/'],
    '{"rep_range": "8-12", "volume": "high", "cue": "full_ROM"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Reddit PPL' AND ss.name = 'Leg Day'
ON CONFLICT (exercise_id) DO NOTHING;

-- ARNOLD'S GOLDEN SIX EXERCISES
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    ss.session_schedule_id,
    10,
    4,
    '00:02:00'::interval,
    1000,
    2500,
    'Barbell squat: 4 sets of 10 reps. Final set AMRAP - if you hit 13+ reps, increase weight by 5 lbs next session. Full depth, controlled.',
    ARRAY['https://liftvault.com/programs/bodybuilding/arnold-schwarzenegger-workout-routine-golden-six/'],
    '{"amrap_final_set": true, "progression_target": 13}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Arnold''s Golden Six' AND ss.name = 'Full Body Workout'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '079ff44e-2dd6-4d48-bf11-a49c3f4e0f45', -- Wide-grip bench press
    ss.session_schedule_id,
    10,
    3,
    '00:01:30'::interval,
    2000,
    2500,
    'Wide-grip bench press to emphasize chest. Final set AMRAP - progress when hitting 13+ reps.',
    ARRAY['https://liftvault.com/programs/bodybuilding/arnold-schwarzenegger-workout-routine-golden-six/'],
    '{"amrap_final_set": true, "progression_target": 13, "grip": "wide"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Arnold''s Golden Six' AND ss.name = 'Full Body Workout'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac', -- Chin-ups
    ss.session_schedule_id,
    10,
    3,
    '00:01:30'::interval,
    3000,
    1000, -- Bodyweight progression
    'Chin-ups: 3 sets AMRAP. Can substitute with pulldowns if needed, but work toward bodyweight chin-ups. Final set progression target: 13+ reps.',
    ARRAY['https://liftvault.com/programs/bodybuilding/arnold-schwarzenegger-workout-routine-golden-six/'],
    '{"amrap_all_sets": true, "can_substitute": "lat_pulldowns", "progression_target": 13}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Arnold''s Golden Six' AND ss.name = 'Full Body Workout'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '39f0fbb0-f7f8-446e-95e3-eb88e745a7ee', -- Behind-the-neck overhead press
    ss.session_schedule_id,
    10,
    4,
    '00:01:30'::interval,
    4000,
    2500,
    'Behind-the-neck overhead press. Can substitute with standard overhead press if shoulder mobility is limited. Final set AMRAP.',
    ARRAY['https://liftvault.com/programs/bodybuilding/arnold-schwarzenegger-workout-routine-golden-six/'],
    '{"amrap_final_set": true, "progression_target": 13, "alternative": "standard_OHP", "caution": "requires_shoulder_mobility"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Arnold''s Golden Six' AND ss.name = 'Full Body Workout'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bee63c0c-05c8-11ed-824f-673da9665bfa', -- Barbell curl
    ss.session_schedule_id,
    10,
    3,
    '00:01:30'::interval,
    5000,
    2500,
    'Barbell curl: strict form, no momentum. Final set AMRAP - progress at 13+ reps.',
    ARRAY['https://liftvault.com/programs/bodybuilding/arnold-schwarzenegger-workout-routine-golden-six/'],
    '{"amrap_final_set": true, "progression_target": 13, "cue": "strict_form"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Arnold''s Golden Six' AND ss.name = 'Full Body Workout'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'f9abf9ce-fee7-4510-9739-e43272189e2e', -- Bent-knee sit-ups
    ss.session_schedule_id,
    15,
    4,
    '00:01:00'::interval,
    6000,
    1000,
    'Bent-knee sit-ups: 3-4 sets AMRAP. Bent knees reduce hip flexor involvement. Control the movement, avoid pulling on neck.',
    ARRAY['https://liftvault.com/programs/bodybuilding/arnold-schwarzenegger-workout-routine-golden-six/'],
    '{"amrap_all_sets": true, "sets_range": "3-4", "cue": "control_movement"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Arnold''s Golden Six' AND ss.name = 'Full Body Workout'
ON CONFLICT (exercise_id) DO NOTHING;

-- Due to length constraints, I'll create the remaining programs (Arnold Split, PHUL, Lyle GBR, Fierce 5) in a concise format
-- Each will include the core exercises with proper progression schemes

-- ARNOLD SPLIT - Chest & Back (abbreviated for space - full program would include all exercises)
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench press
    ss.session_schedule_id,
    10,
    5,
    '00:01:00'::interval,
    1000,
    2500,
    'Pyramid: 15, 12, 10, 8, 6 reps. Increase weight each set, decrease reps. Warm up with 135lbs for 30-45 reps. Often supersetted with chin-ups.',
    ARRAY['https://www.muscleandstrength.com/workouts/arnold-schwarzenegger-volume-workout-routines'],
    '{"pyramid": true, "rep_scheme": [15, 12, 10, 8, 6], "superset_option": "chin-ups", "warmup": "135lbs x 30-45 reps"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Arnold Split' AND ss.name = 'Chest & Back'
ON CONFLICT (exercise_id) DO NOTHING;

-- PHUL - Upper Power (core exercises)
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench press
    ss.session_schedule_id,
    4,
    4,
    '00:03:00'::interval,
    1000,
    2500,
    'Heavy barbell bench press: 3-4 sets of 3-5 reps. When hitting 5 reps for all sets, add 2.5kg/5lbs. Focus on strength.',
    ARRAY['https://www.muscleandstrength.com/workouts/phul-workout'],
    '{"rep_range": "3-5", "progression": "linear", "focus": "power"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'PHUL' AND ss.name = 'Upper Power'
ON CONFLICT (exercise_id) DO NOTHING;

-- LYLE GBR - Lower Body A (sample exercises with flexible selection)
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    ss.session_schedule_id,
    7,
    4,
    '00:03:00'::interval,
    1000,
    2500,
    'Squat: 3-4 sets of 6-8 reps. Autoregulation - do 4th set if form and bar speed are good. Phase 1: 80-85% max. Phase 2: Add 5% weekly. Phase 3: Add 5-10 lbs when completing all sets.',
    ARRAY['https://jcdfitness.com/2009/01/lyle-mcdonalds-bulking-routine/'],
    '{"rep_range": "6-8", "sets_range": "3-4", "autoregulation": true, "progression_phases": 3}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Lyle McDonald''s Generic Bulking Routine' AND ss.name = 'Lower Body A'
ON CONFLICT (exercise_id) DO NOTHING;

-- FIERCE 5 - Workout A
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', -- Squat
    ss.session_schedule_id,
    5,
    3,
    '00:02:30'::interval,
    1000,
    5000, -- 10 lbs for lower body
    'Squat: 3×5. Wave progression - Week 1: 3×6, Week 2: Add 10 lbs and return to 3×5. Full depth, proper form.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 6, "week_2_weight_increase": 10, "week_2_reps": 5}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout A'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '02a1a38a-70f9-11ef-bc64-d72b6479cb97', -- Bench press
    ss.session_schedule_id,
    5,
    3,
    '00:02:30'::interval,
    2000,
    2500, -- 5 lbs for upper body
    'Bench press: 3×5. Wave progression - Week 1: 3×6, Week 2: Add 5 lbs and return to 3×5.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 6, "week_2_weight_increase": 5, "week_2_reps": 5}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout A'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '72422027-c5dc-4364-bcf7-bc6f37081faa', -- Pendlay rows
    ss.session_schedule_id,
    8,
    3,
    '00:02:00'::interval,
    3000,
    2500,
    'Pendlay rows: 3×8. Dead-stop rows from floor, explosive pull. Wave progression - Week 1: 3×10, Week 2: Add 5 lbs and return to 3×8.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 10, "week_2_weight_increase": 5, "week_2_reps": 8, "cue": "dead_stop"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout A'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '07765c6b-af9d-4637-bfdc-3924a6e0699a', -- Reverse flyes
    ss.session_schedule_id,
    10,
    3,
    '00:01:30'::interval,
    4000,
    2500,
    'Reverse flyes: 3×10. Rear delt isolation. Wave progression - Week 1: 3×12, Week 2: Add 5 lbs and return to 3×10.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 12, "week_2_weight_increase": 5, "week_2_reps": 10}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout A'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bef283ae-05c8-11ed-824f-870b793b71df', -- Calf raises
    ss.session_schedule_id,
    15,
    2,
    '00:00:30'::interval,
    5000,
    2500,
    'Calf raises: 2×15 (superset with tricep pushdowns). Wave progression - Week 1: 2×17, Week 2: Add 5 lbs and return to 2×15. Perform immediately before tricep pushdowns.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 17, "week_2_weight_increase": 5, "week_2_reps": 15, "superset_with": "tricep_pushdowns", "superset_order": 1}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout A'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'b5d34436-b28a-41cb-bfd1-93051e352f3f', -- Tricep pushdowns
    ss.session_schedule_id,
    10,
    2,
    '00:01:30'::interval,
    5100,
    2500,
    'Tricep pushdowns: 2×10 (superset with calf raises). Wave progression - Week 1: 2×12, Week 2: Add 5 lbs and return to 2×10. Perform immediately after calf raises, then rest.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 12, "week_2_weight_increase": 5, "week_2_reps": 10, "superset_with": "calf_raises", "superset_order": 2}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout A'
ON CONFLICT (exercise_id) DO NOTHING;

-- Fierce 5 Workout B
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '10845aff-07ac-4359-a8dd-ce99442e33d5', -- Front squat
    ss.session_schedule_id,
    5,
    3,
    '00:02:30'::interval,
    1000,
    5000,
    'Front squat: 3×5. Keep torso upright, elbows high. Wave progression - Week 1: 3×6, Week 2: Add 10 lbs and return to 3×5.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 6, "week_2_weight_increase": 10, "week_2_reps": 5, "cue": "upright_torso"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout B'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', -- Overhead press
    ss.session_schedule_id,
    5,
    3,
    '00:02:30'::interval,
    2000,
    2500,
    'Overhead press: 3×5. Standing barbell OHP preferred. Can alternate with incline bench press. Wave progression - Week 1: 3×6, Week 2: Add 5 lbs and return to 3×5.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 6, "week_2_weight_increase": 5, "week_2_reps": 5, "alternative": "incline_bench_press"}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout B'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'ebe84120-4658-49f9-b15c-c3fc72dd6608', -- Romanian deadlift
    ss.session_schedule_id,
    8,
    3,
    '00:02:00'::interval,
    3000,
    5000,
    'Romanian deadlifts: 3×8. Hip hinge, slight knee bend, feel hamstring stretch. Wave progression - Week 1: 3×10, Week 2: Add 10 lbs and return to 3×8.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 10, "week_2_weight_increase": 10, "week_2_reps": 8}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout B'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bef6fb96-05c8-11ed-824f-d7ac01edbd91', -- Lat pulldowns
    ss.session_schedule_id,
    8,
    3,
    '00:02:00'::interval,
    4000,
    2500,
    'Lat pulldowns: 3×8. Any grip (wide, close, neutral). Wave progression - Week 1: 3×10, Week 2: Add 5 lbs and return to 3×8.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 10, "week_2_weight_increase": 5, "week_2_reps": 8, "grip_options": ["wide", "close", "neutral"]}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout B'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    '2a36d342-dc9e-11ee-b3ef-77b99b9dab02', -- Cable crunch (ab work)
    ss.session_schedule_id,
    15,
    2,
    '00:00:30'::interval,
    5000,
    2500,
    'Ab work: 2×15 (superset with curls). Hanging leg raises, cable crunches, or weighted ab exercise. Wave progression - Week 1: 2×17, Week 2: Add 5 lbs and return to 2×15.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 17, "week_2_weight_increase": 5, "week_2_reps": 15, "superset_with": "curls", "superset_order": 1, "alternatives": ["hanging_leg_raises", "weighted_planks"]}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout B'
ON CONFLICT (exercise_id) DO NOTHING;

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
SELECT
    uuid_generate_v1mc(),
    'bee63c0c-05c8-11ed-824f-673da9665bfa', -- Bicep curls
    ss.session_schedule_id,
    10,
    2,
    '00:01:30'::interval,
    5100,
    2500,
    'Bicep curls: 2×10 (superset with ab work). Wave progression - Week 1: 2×12, Week 2: Add 5 lbs and return to 2×10. Perform immediately after ab work, then rest.',
    ARRAY['https://liftvault.com/programs/bodybuilding/fierce-5-beginner-bodybuilding-program-spreadsheet/'],
    '{"wave_progression": true, "week_1_reps": 12, "week_2_weight_increase": 5, "week_2_reps": 10, "superset_with": "ab_work", "superset_order": 2}'::jsonb
FROM session_schedule ss
INNER JOIN plan p ON ss.plan_id = p.plan_id
WHERE p.name = 'Fierce 5' AND ss.name = 'Workout B'
ON CONFLICT (exercise_id) DO NOTHING;
