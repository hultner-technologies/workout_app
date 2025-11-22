-- Athletic Programs Migration
-- Created: 2025-11-22
-- Purpose: Add 5 evidence-based athletic development programs to the database
--
-- Programs included:
-- 1. Westside for Skinny Bastards (WS4SB) - Joe DeFranco
-- 2. Tactical Barbell - K. Black
-- 3. Starting Strength (with Power Clean) - Mark Rippetoe
-- 4. Simple and Sinister - Pavel Tsatsouline
-- 5. Conjugate Method (General Population) - Louie Simmons
--
-- Data is only inserted if not already present (using ON CONFLICT DO NOTHING)

-- =============================================================================
-- PLANS (Workout Programs)
-- =============================================================================

INSERT INTO plan (plan_id, name, description, links, data)
VALUES
    -- Westside for Skinny Bastards
    (
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120001',
        'Westside for Skinny Bastards (WS4SB)',
        'Westside for Skinny Bastards is a modified version of the famous Westside Barbell Conjugate Method, adapted specifically for athletes, hardgainers, and younger lifters who need to build both strength and muscle mass. Created by renowned strength coach Joe DeFranco in 2008, this program takes the principles used by elite powerlifters and modifies them for the general athletic population.

The program addresses a common problem: many young athletes and "skinny bastards" (hardgainers) struggle to build size and strength using traditional bodybuilding or powerlifting programs. WS4SB bridges this gap by combining max effort strength work, repetition work for hypertrophy, and strategic exercise selection that won''t interfere with sport-specific training.

**Key Features:**
- Max Effort Method: Build absolute strength with heavy (3-5 RM) compound movements
- Repetition Effort Method: Build muscle mass with higher rep work (especially for upper body)
- Exercise Rotation: Rotate max effort exercises every 2-3 weeks to prevent accommodation
- Flexible Structure: Available as 3-day or 4-day split
- No Specialty Equipment Required: Modified from Westside to work in standard gyms

**Program Structure:**
The original 3-day split focuses on max effort upper, max effort lower, and repetition effort upper. The advanced 4-day split (Part III) adds dynamic effort lower body work for more experienced trainees who need additional speed-strength development.

**Progression:**
On max effort days, rotate the main exercise every 2-3 weeks and aim to break your previous record on that specific exercise variation each week. When you can complete all prescribed reps on accessory work, add weight using the smallest increments available (5-10 lbs upper body, 10-20 lbs lower body).

**Who Should Use This:**
- Athletes who need strength + size
- Hardgainers struggling to build muscle
- People with sport-specific training alongside lifting
- Those who want structure but exercise variety

**Program Duration:**
Minimum 12 weeks to see significant results. Can be run indefinitely with proper exercise rotation. Deload every 4-6 weeks by reducing volume and intensity 40-50%.',
        ARRAY[
            'https://www.defrancostraining.com/',
            'https://www.defrancostraining.com/westside-for-skinny-bastards-part1/',
            'https://www.defrancostraining.com/westside-for-skinny-bastards-part2/',
            'https://www.defrancostraining.com/westside-for-skinny-bastards-part3/',
            'https://liftvault.com/programs/strength/westside-for-skinny-bastards-spreadsheet/'
        ],
        jsonb_build_object(
            'author', 'Joe DeFranco',
            'type', 'conjugate',
            'difficulty', 'intermediate',
            'frequency', '3-4 days per week',
            'session_duration', '60-90 minutes'
        )
    ),

    -- Tactical Barbell
    (
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120002',
        'Tactical Barbell',
        'Tactical Barbell is a minimalist strength and conditioning system specifically designed for military personnel, law enforcement officers, firefighters, and other tactical professionals who need to maintain multiple fitness attributes simultaneously. Unlike sport-specific programs that focus on a single quality, Tactical Barbell recognizes that tactical athletes must maintain strength, endurance, work capacity, and tactical skills concurrently.

The program was developed by K. Black (pseudonym for operational security) based on years of experience in military and tactical operations. The system addresses a critical problem: traditional strength programs often interfere with conditioning and skill work, while endurance programs can decrease strength. Tactical Barbell solves this through minimalist strength templates that build and maintain strength without excessive fatigue.

**Key Features:**
- Minimalist Exercise Selection: Focus on 3-4 barbell movements per session
- Sub-maximal Training: Uses 70-95% loads to build strength while managing fatigue
- Wave Periodization: 6-week cycles with built-in deload (Week 4)
- Multiple Templates: Fighter (2x/week), Operator (3x/week), and others
- Percentage-Based Programming: All training based on tested 1RM percentages
- Sustainable: Designed for year-round training, not peaking for competition

**Program Structure:**
The Operator template (most popular) trains 3x per week using clusters of 3-4 exercises. Each 6-week block follows a wave: 70/80/90% for weeks 1-3, then 75/85/95% for weeks 4-6. The Fighter template uses the same progression but trains only 2x per week with all four main lifts each session.

**6-Week Wave Progression:**
- Week 1: 3x5 @ 70% | Week 2: 3x5 @ 80% | Week 3: 3x3 @ 90%
- Week 4: 3x5 @ 75% (deload) | Week 5: 3x5 @ 85% | Week 6: 3x2 @ 95%

After completing a block, retest maxes and begin the next cycle with updated percentages.

**Who Should Use This:**
- Military, law enforcement, firefighters, first responders
- Athletes needing to maintain multiple fitness qualities
- People with unpredictable schedules requiring flexible training
- Those who value minimalism and sustainability

**Program Duration:**
Designed to run indefinitely with 6-week blocks. Test maxes every 6-12 weeks. Minimum 12-18 weeks (2-3 blocks) to assess effectiveness.',
        ARRAY[
            'https://www.tacticalbarbell.com/',
            'https://tacticalbarbell.com/forum/',
            'https://www.tacticalbarbell.com/operator-options/',
            'https://liftvault.com/programs/strength/tactical-barbell/',
            'https://www.amazon.com/Tactical-Barbell-Definitive-Strength-Operational/dp/1537302167'
        ],
        jsonb_build_object(
            'author', 'K. Black',
            'type', 'linear periodization',
            'difficulty', 'beginner to intermediate',
            'frequency', '2-3 days per week',
            'session_duration', '45-60 minutes'
        )
    ),

    -- Starting Strength (with Power Clean)
    (
        'c3d4e5f6-a7b8-11ef-8a1b-0242ac120003',
        'Starting Strength (with Power Clean)',
        'Starting Strength is arguably the most famous novice barbell training program in the world, designed by Mark Rippetoe, a legendary strength coach with over 40 years of experience. The program is built on a simple but profound principle: untrained individuals (novices) can recover from and adapt to training stress within 48-72 hours, allowing them to add weight to the bar every single workout for an extended period—a phenomenon called "linear progression" or the "novice effect."

The program uses only five barbell exercises: the squat, deadlift, bench press, overhead press, and power clean, with chin-ups as the primary assistance exercise. This minimalist approach produces the greatest strength adaptations per unit of time invested.

**Power Clean Philosophy:**
Rippetoe has a specific philosophy regarding Olympic lifts: the power clean is valuable for teaching explosive hip extension and training the nervous system to produce power, making it superior to accessory exercises for athletic development. However, competitive Olympic lifts (snatch and clean & jerk) are NOT recommended for the general population—they require extensive technical coaching and don''t produce strength gains superior to squats and deadlifts.

The power clean serves a specific purpose: it teaches rapid force production and provides a training stimulus that enhances deadlift performance while developing explosive power. It''s programmed on alternate days from deadlifts, typically after the trainee has built a foundation of strength in the basic lifts.

**Key Features:**
- Linear Progression: Add weight every single workout
- Compound Movements Only: Squat, deadlift, bench, press, power clean, chin-ups
- Minimal Effective Dose: Maximum results from minimum time
- Proven Track Record: Tens of thousands of documented successes
- Power Development: Power clean develops explosive strength

**Program Structure:**
Phase 1 (Weeks 1-4): Squat every session, alternating press/bench and deadlifting every workout.
Phase 2 (Weeks 4-8+): Add power cleans, alternating with deadlifts. Deadlift becomes 1x/week, power cleans 1-2x/week.

**Progression:**
Add weight every workout: Squat +5-10 lbs, Deadlift +10-20 lbs initially (then +5-10 lbs), Bench +5 lbs (then +2.5 lbs), Press +5 lbs (then +2.5 lbs, eventually microloading), Power Clean +5-10 lbs. When you fail 3x5 for three consecutive sessions, deload 10-20% and work back up with smaller jumps.

**Who Should Use This:**
- Complete beginners to barbell training
- People wanting maximum strength gains as fast as possible
- Those willing to commit to linear progression
- Athletes needing foundational strength before sport-specific training

**Program Duration:**
Novice phase runs 3-9 months depending on age, bodyweight, recovery, and starting strength. After linear progression stalls, transition to Texas Method or other intermediate programming.',
        ARRAY[
            'https://startingstrength.com/',
            'https://startingstrength.com/get-started/programs',
            'https://startingstrength.com/article/the-power-clean',
            'https://startingstrength.com/video/when-to-add-the-olympic-lifts',
            'https://startingstrengthmirror.fandom.com/wiki/The_Starting_Strength_Novice/Beginner_Programs',
            'https://www.amazon.com/Starting-Strength-Basic-Barbell-Training/dp/0982522738'
        ],
        jsonb_build_object(
            'author', 'Mark Rippetoe',
            'type', 'linear progression',
            'difficulty', 'beginner',
            'frequency', '3 days per week',
            'session_duration', '45-90 minutes'
        )
    ),

    -- Simple and Sinister
    (
        'd4e5f6a7-b8c9-11ef-8a1b-0242ac120004',
        'Simple and Sinister',
        'Simple and Sinister is a minimalist kettlebell program designed by Pavel Tsatsouline, the man credited with bringing Russian kettlebell training to the West. The program embodies Pavel''s philosophy of "strength as a skill" and demonstrates that extraordinary results can be achieved through perfect execution of just two exercises: the kettlebell swing and the Turkish get-up.

The program''s genius lies in its extreme simplicity and focus on movement quality over quantity. Every session consists of exactly 100 one-arm kettlebell swings (10 sets of 10) and 10 Turkish get-ups (5 per side). That''s it. No periodization, no complex programming, no variety. You perform this same workout 5-6 days per week, progressively using heavier kettlebells as you meet specific time and weight standards.

**Key Features:**
- Ultimate Minimalism: Only 2 exercises
- Daily Practice: 5-6 days per week, 20-30 minutes
- Timed Standards: Progress measured by time and weight milestones
- Strong Endurance: Develops ability to generate force repeatedly without fatigue
- Movement Quality: Focus on perfect technique, not max effort
- Sustainability: Minimal fatigue allows for daily training

**Weight Standards (Men):**
- Timeless Simple: 100 swings + 10 get-ups with 32 kg (no time limit)
- Simple: 100 swings with 32 kg in 5 min + 10 get-ups with 32 kg in 10 min
- Sinister: 100 swings with 48 kg in 5 min + 10 get-ups with 48 kg in 10 min

**Weight Standards (Women):**
- Timeless Simple: 100 swings with 24 kg + 10 get-ups with 16 kg (no time limit)
- Simple: 100 swings with 24 kg in 5 min + 10 get-ups with 16 kg in 10 min
- Sinister: 100 swings with 32 kg in 5 min + 10 get-ups with 24 kg in 10 min

**Program Structure:**
Every session: Warm-up (prying goblet squat, halos, hip bridges), 100 one-arm swings (10x10, alternating arms every 10 reps), 1 minute rest, 10 Turkish get-ups (alternating sides each rep).

**Progression:**
Pavel recommends "leap of faith" progression—large jumps in weight (8 kg) rather than small increments. When you achieve a standard with one weight, jump to the next heavier bell. Most practitioners take 6-12 months for Timeless Simple, 1-2 years for Simple, 3-5+ years for Sinister (if ever).

**Who Should Use This:**
- People limited by time (20-30 min/day)
- Kettlebell enthusiasts
- Those prioritizing movement quality and longevity
- People needing concurrent strength/conditioning without program interference
- Martial artists, climbers, or athletes with primary sport training

**Program Duration:**
Designed to be practiced indefinitely. Minimum 3-6 months to experience significant benefits. No deload required—take rest days based on life demands.',
        ARRAY[
            'https://www.strongfirst.com/',
            'https://www.strongfirst.com/achieve/sinister/',
            'https://www.amazon.com/Kettlebell-Simple-Sinister-Revised-Updated/dp/0989892433',
            'https://www.strongfirst.com/community/forums/kettlebell.8/',
            'https://www.qldkettlebells.com.au/blog/kettlebell-simple-and-sinister'
        ],
        jsonb_build_object(
            'author', 'Pavel Tsatsouline',
            'type', 'daily practice',
            'difficulty', 'all levels',
            'frequency', '5-6 days per week',
            'session_duration', '20-30 minutes',
            'equipment', 'kettlebells only'
        )
    ),

    -- Conjugate Method (General Population)
    (
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120005',
        'Conjugate Method (General Population)',
        'The Conjugate Method is a revolutionary training system developed by Louie Simmons at Westside Barbell, based on Soviet and Bulgarian periodization research. While originally designed for elite powerlifters, the principles have been adapted for general population strength training, athletic development, and tactical fitness. The method''s core innovation is the simultaneous development of multiple strength qualities through varied training stresses—what Simmons calls "concurrent periodization."

Traditional periodization requires athletes to focus on one quality at a time (hypertrophy, then strength, then power), which can lead to detraining of previously developed qualities. The Conjugate Method solves this by training maximum strength, dynamic strength (speed-strength), and repetition work for hypertrophy within the same week.

**Three Training Methods:**
1. **Maximum Effort Method:** Work up to maximal loads (1-3 RM) to develop absolute strength
2. **Dynamic Effort Method:** Move sub-maximal loads (50-60%) with maximal speed to develop rate of force development
3. **Repetition Method:** Perform exercises to muscular fatigue (8-15 reps) for hypertrophy and work capacity

**Key Features:**
- 4-Day Upper/Lower Split: Max Effort Lower, Max Effort Upper, Dynamic Effort Lower, Dynamic Effort Upper
- Exercise Rotation: Rotate max effort exercises every 1-3 weeks to prevent accommodation
- Concurrent Development: Train all qualities (max strength, speed, hypertrophy) simultaneously
- Accommodating Resistance: Advanced trainees can add bands/chains (optional for general population)
- Weakness-Based Programming: Accessory work targets individual weak points

**General Population Adaptations:**
The raw Westside method is NOT appropriate for most people. Key adaptations include:
- Reduced max effort frequency (every 2-3 weeks instead of weekly)
- Simplified exercise selection (no specialty bars required)
- Reduced total volume (fewer accessory exercises)
- Removing or minimizing bands/chains
- Longer exercise rotations (2-3 weeks instead of weekly)
- Some coaches replace dynamic effort bench with repetition work for hypertrophy

**Program Structure:**
- Monday: Max Effort Lower (work up to 1-3 RM on squat/deadlift variant + accessories)
- Wednesday: Max Effort Upper (work up to 1-3 RM on bench/press variant + accessories)
- Friday: Dynamic Effort Lower (8-12 sets x 2 reps @ 50-60% box squats + accessories)
- Saturday/Sunday: Dynamic Effort Upper (9 sets x 3 reps @ 50-60% bench with 3 grips + accessories)

**Max Effort Exercise Rotation Examples:**
Lower: Box squats, free squats, front squats, deadlifts (conventional/sumo), rack pulls, good mornings
Upper: Bench press (various grips), floor press, incline bench, board press, overhead press

**Progression:**
Rotate max effort exercises every 1-3 weeks, aiming to beat your previous record on that specific variant. Dynamic effort weight stays constant for 3 weeks, then retest maxes or rotate exercise. Accessory work uses double progression (increase reps, then weight).

**Who Should Use This:**
- Intermediate to advanced lifters
- Powerlifters or strength sport competitors
- People who get bored with repetitive programs
- Those with access to equipment and time for 4 day/week training

**Program Duration:**
Minimum 12-16 weeks to adapt to the system. Run continuously with deloads every 4-6 weeks (reduce volume 40-50%, skip max effort). Can be run indefinitely with proper exercise rotation.',
        ARRAY[
            'https://www.westside-barbell.com/',
            'https://www.westside-barbell.com/pages/conjugate-method',
            'https://www.westside-barbell.com/blogs/the-blog/starting-conjugate-training-walkthrough',
            'https://www.westside-barbell.com/blogs/the-blog/the-basic-template-breakdown',
            'https://www.syattfitness.com/westside-barbell/the-westside-barbell-conjugate-method-a-users-guide/',
            'https://www.elitefts.com/education/16-week-conjugate-periodization-program-for-novice-powerlifters/'
        ],
        jsonb_build_object(
            'author', 'Louie Simmons',
            'type', 'conjugate periodization',
            'difficulty', 'intermediate to advanced',
            'frequency', '4 days per week',
            'session_duration', '60-90 minutes'
        )
    )
ON CONFLICT (plan_id) DO NOTHING;

-- =============================================================================
-- SESSION SCHEDULES (Workout Days/Sessions within Programs)
-- =============================================================================

INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
    -- Westside for Skinny Bastards (3-Day Version)
    (
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120101',
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120001',
        'Max Effort Upper Body',
        'Work up to a max set of 3-5 reps on a rotating pressing exercise. Focus on absolute strength development.

**A. Max Effort Lift** (Work up to 3-5 RM)
Rotate exercise every 2-3 weeks: Bench press variations (thick bar, floor press, board press, incline, close-grip, decline), rack lockouts. Work up from ~50% adding weight each set. Rest 3-5 minutes.

**B. Supplemental Lift** (3-4 sets x 6-10 reps)
Examples: DB bench press, DB incline press, military press. Rest 2-3 minutes.

**C. Horizontal Rowing** (4 sets x 10-15 reps)
Examples: Barbell rows, DB rows, seated cable rows, chest-supported rows. Rest 90 seconds.

**D. Rear Delt/Upper Back** (2-3 sets x 12-15 reps)
Examples: Face pulls, rear delt flyes, band pull-aparts. Rest 60-90 seconds.

**E. Weighted Abdominals** (3-4 sets x 8-15 reps)
Examples: Weighted sit-ups, cable crunches, weighted side bends. Rest 60 seconds.',
        1.0,
        ARRAY[
            'https://www.defrancostraining.com/westside-for-skinny-bastards-part1/',
            'https://archive.t-nation.com/training/westside-for-skinny-bastards-1/'
        ],
        jsonb_build_object(
            'day_type', 'max_effort',
            'focus', 'upper_body',
            'rest_days_before_repeat', 4
        )
    ),
    (
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120102',
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120001',
        'Max Effort Lower Body',
        'Work up to a max set of 5 reps on a rotating squat or deadlift variation. Build absolute lower body strength and power.

**A. Max Effort Lift** (Work up to 5 RM)
Rotate exercise every 2-3 weeks: Box squats (various bars), free squats, deadlifts (conventional/sumo), trap bar deadlifts, rack pulls. Work up from ~50% adding weight each set. Rest 3-5 minutes.

**B. Unilateral Movement** (2-3 sets x 6-10 per leg)
Examples: Bulgarian split squats, walking lunges, step-ups. Rest 90 seconds.

**C. Hamstring/Posterior Chain** (3 sets x 8-12 reps)
Examples: Glute-ham raises, Romanian deadlifts, leg curls, back extensions. Rest 90 seconds.

**D. Ground-Based Abdominals** (3-4 sets x 10-15 reps)
Examples: Hanging leg raises, ab wheel rollouts, planks (or time). Rest 60 seconds.',
        1.0,
        ARRAY[
            'https://www.defrancostraining.com/westside-for-skinny-bastards-part1/'
        ],
        jsonb_build_object(
            'day_type', 'max_effort',
            'focus', 'lower_body',
            'rest_days_before_repeat', 4
        )
    ),
    (
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120103',
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120001',
        'Repetition Effort Upper Body',
        'Focus on building muscle mass through high-rep work. This day replaces the traditional dynamic effort upper day for better hypertrophy in younger athletes and hardgainers.

**A. Repetition Lift** (3 sets x max reps)
Work up to 3 sets of max reps: DB bench press or barbell bench (60-70% 1RM). Rest 90 seconds between sets.

**B/C. Lat/Upper Back Superset** (3-4 sets x 8-12 reps each)
B. Vertical pulling: Lat pulldowns, chin-ups, pull-ups
C. Upper back: Face pulls, rear delt work, shrugs
Minimal rest between exercises, 90 seconds between supersets.

**D. Biceps** (3 sets x 8-10 reps)
Examples: Barbell curls, DB curls, hammer curls. Rest 60 seconds.

**E. Triceps** (3 sets x 8-10 reps)
Examples: Overhead extensions, pushdowns, close-grip bench. Rest 60 seconds.',
        1.0,
        ARRAY[
            'https://www.defrancostraining.com/westside-for-skinny-bastards-part1/'
        ],
        jsonb_build_object(
            'day_type', 'repetition_effort',
            'focus', 'upper_body_hypertrophy',
            'rest_days_before_repeat', 4
        )
    ),
    (
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120104',
        'a1b2c3d4-e5f6-11ef-8a1b-0242ac120001',
        'Dynamic Effort Lower Body (WS4SB III)',
        'Advanced 4-day split option. Develop explosive speed-strength with dynamic box squats. This session is only for WS4SB Part III.

**A. Dynamic Box Squats** (8-10 sets x 2 reps @ 50-60% 1RM)
Explosive concentric, controlled eccentric. Rest 45-60 seconds. Optional: Add bands/chains for advanced trainees.

**B. Unilateral Movement** (2-3 sets x 6-10 per leg)
Same as Max Effort Lower Day. Rest 90 seconds.

**C. Hamstring/Posterior Chain** (3 sets x 8-12 reps)
Same as Max Effort Lower Day. Rest 90 seconds.

**D. Abdominals** (3-4 sets x 10-15 reps)
Same as Max Effort Lower Day. Rest 60 seconds.',
        1.0,
        ARRAY[
            'https://www.defrancostraining.com/westside-for-skinny-bastards-part3/'
        ],
        jsonb_build_object(
            'day_type', 'dynamic_effort',
            'focus', 'lower_body_speed',
            'rest_days_before_repeat', 4,
            'advanced_variation', true
        )
    ),

    -- Tactical Barbell - Operator Template
    (
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120201',
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120002',
        'Operator Day 1 (Squat/Bench/Pull-ups)',
        'Tactical Barbell Operator Template - Session 1. Perform all exercises at current week''s percentage.

**Week Progression (6-week wave):**
- Week 1: 3x5 @ 70% | Week 2: 3x5 @ 80% | Week 3: 3x3 @ 90%
- Week 4: 3x5 @ 75% | Week 5: 3x5 @ 85% | Week 6: 3x2 @ 95%

**Exercises:**
1. Back Squat: 3 sets (reps/% based on current week)
2. Bench Press: 3 sets (reps/% based on current week)
3. Weighted Pull-ups: 3 sets (reps/% based on current week)

Rest 3-5 minutes between sets. After 6 weeks, retest maxes and begin new cycle with updated percentages.',
        1.0,
        ARRAY[
            'https://www.tacticalbarbell.com/operator-options/'
        ],
        jsonb_build_object(
            'template', 'operator',
            'day_number', 1,
            'frequency', '3x per week',
            'wave_week_1', '3x5@70%',
            'wave_week_2', '3x5@80%',
            'wave_week_3', '3x3@90%',
            'wave_week_4', '3x5@75%',
            'wave_week_5', '3x5@85%',
            'wave_week_6', '3x2@95%'
        )
    ),
    (
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120202',
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120002',
        'Operator Day 2 (Squat/Bench/Deadlift)',
        'Tactical Barbell Operator Template - Session 2. Perform all exercises at current week''s percentage.

**Exercises:**
1. Back Squat: 3 sets (reps/% based on current week)
2. Bench Press: 3 sets (reps/% based on current week)
3. Deadlift: 3 sets (reps/% based on current week) - Note: Deadlifts typically done 2x per week, not all 3 sessions

Follow same 6-week wave progression as Day 1. Rest 3-5 minutes between sets.',
        1.0,
        ARRAY[
            'https://www.tacticalbarbell.com/operator-options/'
        ],
        jsonb_build_object(
            'template', 'operator',
            'day_number', 2,
            'frequency', '3x per week'
        )
    ),
    (
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120203',
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120002',
        'Operator Day 3 (Squat/Bench/Pull-ups)',
        'Tactical Barbell Operator Template - Session 3. Same as Day 1.

**Exercises:**
1. Back Squat: 3 sets (reps/% based on current week)
2. Bench Press: 3 sets (reps/% based on current week)
3. Weighted Pull-ups: 3 sets (reps/% based on current week)

Follow same 6-week wave progression. Rest 3-5 minutes between sets.',
        1.0,
        ARRAY[
            'https://www.tacticalbarbell.com/operator-options/'
        ],
        jsonb_build_object(
            'template', 'operator',
            'day_number', 3,
            'frequency', '3x per week'
        )
    ),

    -- Tactical Barbell - Fighter Template
    (
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120204',
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120002',
        'Fighter Day 1 (All Lifts)',
        'Tactical Barbell Fighter Template - Session 1. Train only 2x per week with all four main lifts each session.

**Week Progression (same 6-week wave as Operator):**
Week 1: 3x5 @ 70% | Week 2: 3x5 @ 80% | Week 3: 3x3 @ 90%
Week 4: 3x5 @ 75% | Week 5: 3x5 @ 85% | Week 6: 3x2 @ 95%

**Exercises:**
1. Back Squat: 3 sets
2. Bench Press: 3 sets
3. Overhead Press: 3 sets
4. Deadlift: 3 sets

All exercises use current week''s rep/percentage scheme. Rest 3-5 minutes between exercises.',
        1.0,
        ARRAY[
            'https://www.tacticalbarbell.com/',
            'https://liftvault.com/programs/strength/tactical-barbell/'
        ],
        jsonb_build_object(
            'template', 'fighter',
            'day_number', 1,
            'frequency', '2x per week'
        )
    ),
    (
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120205',
        'b2c3d4e5-f6a7-11ef-8a1b-0242ac120002',
        'Fighter Day 2 (All Lifts)',
        'Tactical Barbell Fighter Template - Session 2. Same as Day 1.

**Exercises:**
1. Back Squat: 3 sets
2. Bench Press: 3 sets
3. Overhead Press: 3 sets
4. Deadlift: 3 sets

All exercises use current week''s rep/percentage scheme. Rest 3-5 minutes between exercises.',
        1.0,
        ARRAY[
            'https://www.tacticalbarbell.com/'
        ],
        jsonb_build_object(
            'template', 'fighter',
            'day_number', 2,
            'frequency', '2x per week'
        )
    ),

    -- Starting Strength (with Power Clean)
    (
        'c3d4e5f6-a7b8-11ef-8a1b-0242ac120301',
        'c3d4e5f6-a7b8-11ef-8a1b-0242ac120003',
        'Workout A (Squat/Press/Deadlift or Power Clean)',
        'Starting Strength Workout A. Squat every session, overhead press, and alternate between deadlift and power clean.

**Phase 1 (Weeks 1-4):**
1. Squat: 3x5 (add 5-10 lbs per session)
2. Overhead Press: 3x5 (add 5 lbs, then 2.5 lbs, eventually microload)
3. Deadlift: 1x5 (add 10-20 lbs initially, then 5-10 lbs)

**Phase 2 (After Week 4-8):**
1. Squat: 3x5
2. Overhead Press: 3x5
3. Deadlift OR Power Clean (alternate - deadlift 1x/week, power clean 1-2x/week)
   - Deadlift: 1x5
   - Power Clean: 5x3 (focus on technique, add 5-10 lbs per session)
4. Chin-ups: 3 sets to failure or weighted sets of 5-10

Rest 3-5 minutes between sets. Add weight every single workout according to progression guidelines.',
        1.0,
        ARRAY[
            'https://startingstrength.com/get-started/programs',
            'https://startingstrength.com/article/the-power-clean'
        ],
        jsonb_build_object(
            'workout_type', 'A',
            'frequency', '3x per week alternating',
            'linear_progression', true
        )
    ),
    (
        'c3d4e5f6-a7b8-11ef-8a1b-0242ac120302',
        'c3d4e5f6-a7b8-11ef-8a1b-0242ac120003',
        'Workout B (Squat/Bench/Deadlift or Power Clean)',
        'Starting Strength Workout B. Squat every session, bench press, and alternate between deadlift and power clean.

**Phase 1 (Weeks 1-4):**
1. Squat: 3x5 (add 5-10 lbs per session)
2. Bench Press: 3x5 (add 5 lbs initially, then 2.5 lbs, eventually microload)
3. Deadlift: 1x5 (add 10-20 lbs initially, then 5-10 lbs)

**Phase 2 (After Week 4-8):**
1. Squat: 3x5
2. Bench Press: 3x5
3. Deadlift OR Power Clean (alternate)
   - Deadlift: 1x5
   - Power Clean: 5x3
4. Chin-ups: 3 sets to failure or weighted sets of 5-10

Rest 3-5 minutes between sets. The program alternates A/B/A one week, then B/A/B the next week.',
        1.0,
        ARRAY[
            'https://startingstrength.com/get-started/programs'
        ],
        jsonb_build_object(
            'workout_type', 'B',
            'frequency', '3x per week alternating',
            'linear_progression', true
        )
    ),

    -- Simple and Sinister
    (
        'd4e5f6a7-b8c9-11ef-8a1b-0242ac120401',
        'd4e5f6a7-b8c9-11ef-8a1b-0242ac120004',
        'Daily Practice Session',
        'Simple and Sinister daily practice. Same workout every day, 5-6 days per week.

**Warm-up (5-10 minutes):**
- Prying Goblet Squat: 5-10 reps
- Halos: 5 each direction
- Hip Bridges: 10-20 reps

**Main Work:**

**A. One-Arm Kettlebell Swings** (100 total reps)
- Structure: 10 sets x 10 reps (alternating arms: 10L, 10R, 10L, 10R...)
- Timing: Perform one set every 30 seconds (on the :00 and :30)
- Total time: 5 minutes for Simple standard
- Technique: Hardstyle swing, explosive hip snap, horizontal trajectory
- Breathing: Forceful exhale at top (like blowing out candles)

**Rest: 1 minute**

**B. Turkish Get-Up** (10 total reps)
- Structure: 10 sets x 1 rep, alternating sides (1L, 1R, 1L, 1R...)
- Timing: Perform one get-up every minute
- Total time: 10 minutes for Simple standard
- Technique: Slow, controlled, maintain vertical arm with kettlebell
- Note: This is a movement practice, not a grind

**Standards:**

Men - Timeless Simple: 32kg swings + 32kg get-ups (no time limit)
Men - Simple: 32kg swings in 5min + 32kg get-ups in 10min
Men - Sinister: 48kg swings in 5min + 48kg get-ups in 10min

Women - Timeless Simple: 24kg swings + 16kg get-ups (no time limit)
Women - Simple: 24kg swings in 5min + 16kg get-ups in 10min
Women - Sinister: 32kg swings in 5min + 24kg get-ups in 10min

Progression: Use large weight jumps (8kg). When you achieve a standard, progress to next heavier kettlebell. Test time standards every 4-6 weeks.',
        1.0,
        ARRAY[
            'https://www.strongfirst.com/achieve/sinister/',
            'https://www.qldkettlebells.com.au/blog/kettlebell-simple-and-sinister'
        ],
        jsonb_build_object(
            'frequency', '5-6 days per week',
            'total_swings', 100,
            'total_getups', 10,
            'swing_timing', 'every 30 seconds',
            'getup_timing', 'every minute',
            'men_simple_weight_kg', 32,
            'men_sinister_weight_kg', 48,
            'women_simple_swing_kg', 24,
            'women_simple_getup_kg', 16,
            'women_sinister_swing_kg', 32,
            'women_sinister_getup_kg', 24
        )
    ),

    -- Conjugate Method (General Population)
    (
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120501',
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120005',
        'Max Effort Lower Body',
        'Work up to a 1-3 rep max on a rotating lower body exercise. Rotate main exercise every 1-3 weeks.

**A. Max Effort Lift** (Work up to 1-3 RM)
Rotation options (change every 1-3 weeks):
- Box squats (various heights, various bars)
- Free squats (various stances)
- Front squats
- Safety squat bar squats
- Deadlifts (conventional)
- Deadlifts (sumo)
- Rack pulls
- Good mornings

Protocol: Work up from 50-60% in sets of 3-5 reps, eventually reaching 1-3RM. Total: 5-8 working sets. Rest 3-5 minutes between heavy sets.

**B. Supplemental Lower Body** (3-4 sets x 6-10 reps)
Examples: Lunges, split squats, step-ups, belt squats. Rest 2 minutes.

**C. Posterior Chain/Hamstring** (3-4 sets x 8-12 reps)
Examples: Romanian deadlifts, glute-ham raises, back extensions, leg curls. Rest 90 seconds.

**D. Abs/Core** (3-4 sets x 10-20 reps)
Examples: Weighted sit-ups, ab wheel, hanging leg raises. Rest 60 seconds.

Total accessory exercises: 3-6 movements after max effort lift.',
        1.0,
        ARRAY[
            'https://www.westside-barbell.com/blogs/the-blog/starting-conjugate-training-walkthrough'
        ],
        jsonb_build_object(
            'day', 'Monday',
            'method', 'max_effort',
            'focus', 'lower_body',
            'rotation_frequency_weeks', '1-3'
        )
    ),
    (
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120502',
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120005',
        'Max Effort Upper Body',
        'Work up to a 1-3 rep max on a rotating pressing exercise. Rotate main exercise every 1-3 weeks.

**A. Max Effort Lift** (Work up to 1-3 RM)
Rotation options (change every 1-3 weeks):
- Bench press (various grips)
- Floor press
- Incline bench press (various angles)
- Board press (2-board, 3-board, 4-board)
- Close-grip bench press
- Overhead press
- Incline press

Protocol: Work up from 50-60% in sets of 3-5 reps, eventually reaching 1-3RM. Total: 5-8 working sets. Rest 3-5 minutes between heavy sets.

**B. Supplemental Pressing** (3-4 sets x 6-10 reps)
Examples: DB bench, DB incline, overhead press variations. Rest 2 minutes.

**C. Horizontal Pulling** (4-5 sets x 8-12 reps)
Examples: Barbell rows, DB rows, chest-supported rows, seated cable rows. Rest 90 seconds.

**D. Vertical Pulling** (3-4 sets x 6-12 reps)
Examples: Chin-ups, pull-ups, lat pulldowns. Rest 90 seconds.

**E. Rear Delts/Upper Back** (3-4 sets x 12-15 reps)
Examples: Face pulls, rear delt flyes, band pull-aparts. Rest 60 seconds.

**F. Arms (optional)** (2-3 sets x 10-15 reps each)
Triceps: Pushdowns, overhead extensions, close-grip pressing
Biceps: Curls, hammer curls
Rest 60 seconds.

Total accessory exercises: 4-6 movements after max effort lift.',
        1.0,
        ARRAY[
            'https://www.westside-barbell.com/blogs/the-blog/starting-conjugate-training-walkthrough'
        ],
        jsonb_build_object(
            'day', 'Wednesday',
            'method', 'max_effort',
            'focus', 'upper_body',
            'rotation_frequency_weeks', '1-3'
        )
    ),
    (
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120503',
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120005',
        'Dynamic Effort Lower Body',
        'Develop explosive speed-strength with dynamic box squats. Focus on bar speed, not absolute weight.

**A. Dynamic Effort Squats** (8-12 sets x 2 reps @ 50-60% 1RM)
Exercise: Box squats or free squats
Weight: 50-60% of 1RM (without bands/chains)
Rest: 45-60 seconds
Tempo: Explosive concentric (stand up as fast as possible), controlled eccentric
Notes: Focus on speed, not grinding reps. Optional: Add bands/chains for advanced trainees (5-20% additional load at top).

**B. Dynamic Effort Deadlifts (optional)** (6-8 sets x 1 rep @ 60-70% 1RM)
Can substitute speed pulls, deficit deadlifts, rack pulls, or regular deadlifts
Rest: 60 seconds
Tempo: Explosive from floor

**C. Unilateral/Accessory Lower** (3 sets x 8-10 per leg)
Examples: Bulgarian split squats, walking lunges, single-leg press. Rest 90 seconds.

**D. Posterior Chain** (3-4 sets x 10-15 reps)
Examples: Glute-ham raises, back extensions, leg curls, pull-throughs. Rest 60-90 seconds.

**E. Abs/Core** (3-4 sets x 10-20 reps or time)
Examples: Planks, ab wheel, cable crunches. Rest 60 seconds.

Total accessory exercises: 2-4 movements after dynamic work.

Progression: Weight stays constant for 3 weeks, then retest max and recalculate percentages OR rotate exercise.',
        1.0,
        ARRAY[
            'https://www.westside-barbell.com/blogs/the-blog/the-basic-template-breakdown'
        ],
        jsonb_build_object(
            'day', 'Friday',
            'method', 'dynamic_effort',
            'focus', 'lower_body',
            'intensity_percent', '50-60%'
        )
    ),
    (
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120504',
        'e5f6a7b8-c9d0-11ef-8a1b-0242ac120005',
        'Dynamic Effort Upper Body',
        'Develop pressing speed and explosive power with dynamic bench press using multiple grips.

**A. Dynamic Effort Bench Press** (9 sets x 3 reps @ 50-60% 1RM)
Structure: 3 sets with 3 different grips (9 total sets)
Weight: 50-60% of 1RM
Rest: 45-60 seconds between sets
Tempo: Explosive concentric, controlled eccentric

Grip variations:
1. Close grip (pinky on smooth part of bar)
2. Medium grip (index finger on rings)
3. Wide grip (outside the rings)

Notes: Move bar as fast as possible. If bar speed slows, reduce weight. Optional: Add bands/chains for advanced trainees.

**General Population Note:** Some coaches recommend replacing this with repetition work for non-powerlifters, as most people need muscle mass more than speed work.

**B. Vertical Pulling** (4-5 sets x 6-10 reps)
Examples: Weighted chin-ups, pull-ups, lat pulldowns. Rest 90 seconds.

**C. Horizontal Pulling** (3-4 sets x 8-12 reps)
Examples: Barbell rows, cable rows, DB rows. Rest 90 seconds.

**D. Shoulders** (3-4 sets x 8-12 reps)
Examples: DB press, lateral raises, overhead press. Rest 90 seconds.

**E. Arms** (3-4 sets x 10-15 reps each)
Triceps: Overhead extensions, pushdowns, dips
Biceps: Curls, hammer curls
Rest: 60 seconds

Total accessory exercises: 2-4 movements after dynamic work.',
        1.0,
        ARRAY[
            'https://www.westside-barbell.com/blogs/the-blog/the-basic-template-breakdown'
        ],
        jsonb_build_object(
            'day', 'Saturday or Sunday',
            'method', 'dynamic_effort',
            'focus', 'upper_body',
            'intensity_percent', '50-60%',
            'grip_variations', 3
        )
    )
ON CONFLICT (session_schedule_id) DO NOTHING;

-- =============================================================================
-- NOTES ON EXERCISE CONFIGURATIONS
-- =============================================================================

-- Note: Individual exercise configurations (linking base_exercise to session_schedule)
-- are intentionally omitted from this migration because these programs emphasize:
--
-- 1. Exercise Rotation (WS4SB, Conjugate): Main lifts rotate every 1-3 weeks
-- 2. Percentage-Based Training (Tactical Barbell): Exercises use %RM not fixed weights
-- 3. Linear Progression (Starting Strength): Add weight every session
-- 4. Standardized Movements (Simple & Sinister): Only 2 exercises with weight-based standards
--
-- The session_schedule descriptions contain comprehensive exercise selection guidance,
-- set/rep schemes, rest periods, and progression protocols. Users can create custom
-- exercise configurations based on their current training block, available equipment,
-- and individual needs.
--
-- Many required exercises (Power Clean, Box Squat, Floor Press, Turkish Get-Up, etc.)
-- have already been added to the base_exercise table in the 080_seed_data.sql file.

-- =============================================================================
-- MIGRATION COMPLETE
-- =============================================================================

-- Summary of programs added:
-- 1. Westside for Skinny Bastards - 4 session schedules (3-day + advanced 4-day option)
-- 2. Tactical Barbell - 5 session schedules (3 Operator days + 2 Fighter days)
-- 3. Starting Strength (with Power Clean) - 2 session schedules (Workout A & B)
-- 4. Simple and Sinister - 1 session schedule (daily practice)
-- 5. Conjugate Method (General Population) - 4 session schedules (ME Lower/Upper, DE Lower/Upper)
--
-- Total: 5 plans, 16 session schedules
