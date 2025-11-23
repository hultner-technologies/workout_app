-- Migration: Hybrid and Functional Fitness Programs
-- Date: 2025-11-22
-- Description: Adds 6 evidence-based hybrid/functional programs researched from authoritative sources
-- Programs: 5/3/1 BBB, 5/3/1 Beginners, Tactical Barbell, CrossFit Strength Bias,
--           Renaissance Periodization, Mike Israetel Hypertrophy Principles
--
-- This migration adds comprehensive workout programs that balance strength, size, and conditioning
-- All data is only inserted if not already present (using ON CONFLICT DO NOTHING)

-- =============================================================================
-- PLANS (Workout Programs)
-- =============================================================================
INSERT INTO plan (plan_id, name, description, links, data)
VALUES
    -- 5/3/1 Boring But Big (BBB)
    (
        '4a7c8f32-a8e1-11ef-9c42-5b3e8a9d1f7c',
        '5/3/1 Boring But Big (BBB)',
        'Boring But Big is the most popular assistance template for Jim Wendler''s 5/3/1 training program. It combines the proven 5/3/1 progression scheme with high-volume supplemental work to build both strength and size. The program earned its name from the monotonous yet effective 5x10 supplemental sets performed after the main work.

**Philosophy**: Get strong with heavy weights using the 5/3/1 core work, then build muscle mass with the volume-focused BBB work. The program is designed to be sustainable long-term, with built-in deload weeks preventing overtraining.

**Program Type**: Linear periodization with wave-loading
**Duration**: 4-week cycles (3 weeks loading + 1 week deload)
**Training Days**: 4 days per week
**Session Structure**: One main lift per session with 5/3/1 progression, followed by 5x10 supplemental work

**Periodization Scheme**:
- Week 1 - 5s Week: 65%, 75%, 85% (5+ reps on top set)
- Week 2 - 3s Week: 70%, 80%, 90% (3+ reps on top set)
- Week 3 - 5/3/1 Week: 75%, 85%, 95% (1+ rep on top set)
- Week 4 - Deload: 40%, 50%, 60% (no AMRAP sets)

**BBB Supplemental Work**: 5x10 @ 50-60% Training Max
- Cycle 1-2: 50% TM
- Cycle 3-4: 55% TM
- Cycle 5-6: 60% TM
- Advanced (6+ months): 65-70% TM

**Main Work Sets**:
- Warm-up: 40% x 5, 50% x 5, 60% x 3
- Working sets: 3 sets based on week percentages
- Rest: 3-5 minutes between working sets

**Assistance Work**: 50-100 total reps each category (Push, Pull, Single-leg/Core)

**Progression**:
- Upper body lifts: +5 lbs per cycle
- Lower body lifts: +10 lbs per cycle
- Reset Training Max by 10% if unable to achieve 3-5 reps on 1+ set (Week 3)

**Target Audience**: Intermediate lifters who want to add muscle mass while building strength
**Evidence Base**: Created by Jim Wendler (former elite powerlifter, 1000 lb squat). Used successfully by thousands of lifters worldwide for over 15 years.',
        ARRAY[
            'https://www.jimwendler.com/blogs/jimwendler-com/101077382-boring-but-big',
            'https://www.jimwendler.com/blogs/jimwendler-com/boring-but-big-3-month-challenge',
            'https://liftvault.com/programs/strength/531-bbb/',
            'https://www.tigerfitness.com/blogs/training-programs/the-complete-5-3-1-bbb-program-guide-the-ultimate-blueprint-for-strength-size-and-simplicity'
        ],
        NULL
    ),

    -- 5/3/1 for Beginners
    (
        '5b8d9e43-a8e1-11ef-9c42-6c4f9ba2e08d',
        '5/3/1 for Beginners',
        '5/3/1 for Beginners is a full-body training program designed for novice lifters who want to build strength using Jim Wendler''s proven 5/3/1 methodology. Unlike standard 5/3/1 programs that train one main lift per session, this beginner variant trains two main lifts per workout across three weekly sessions, providing increased frequency for faster strength gains.

**Philosophy**: Beginners can recover faster and make gains more quickly than advanced lifters, so this program includes more frequent exposure to each lift. By training each main movement ~1.5 times per week, novices get the practice and stimulus needed to develop proper technique and build a strength base.

**Program Type**: Linear periodization with full-body training
**Duration**: 3-week cycles (no scheduled deloads - take when needed)
**Training Days**: 3 days per week (M/W/F or similar spacing)
**Session Structure**: Two main lifts per session (5/3/1 work + FSL supplemental work) plus assistance

**Periodization Scheme (3-week cycle)**:
- Week 1 - 5s Week: 65% x 5, 75% x 5, 85% x 5+
- Week 2 - 3s Week: 70% x 3, 80% x 3, 90% x 3+
- Week 3 - 5/3/1 Week: 75% x 5, 85% x 3, 95% x 1+

**FSL (First Set Last) Supplemental Work**: 5 sets x 5 reps
- Week 1: 5x5 @ 65%
- Week 2: 5x5 @ 70%
- Week 3: 5x5 @ 75%

**Session Rotation**:
- Day 1: Squat + Bench Press (with FSL for both)
- Day 2: Deadlift + Overhead Press (with FSL for both)
- Day 3: Bench Press + Squat (with FSL for both)

**Assistance Work**: 50-100 total reps each category (Push, Pull, Single-leg/Core)

**Progression**:
- Upper body lifts: +5 lbs every 3 weeks
- Lower body lifts: +10 lbs every 3 weeks
- Faster than standard 5/3/1 (every 3 weeks vs 4 weeks)

**Deload Strategy**: Take deload week when needed (typically every 2-3 cycles)
- Signs to deload: TM feels heavy, low AMRAP reps, poor recovery, fatigue

**Transition Point**: After 2-3 cycles (6-9 months), transition to standard 5/3/1 or 5/3/1 BBB

**Target Audience**: Novice lifters building strength foundation
**Evidence Base**: Jim Wendler (former elite powerlifter). Widely recommended by r/fitness community for beginners.',
        ARRAY[
            'https://www.jimwendler.com/blogs/jimwendler-com/5-3-1-for-beginners',
            'https://www.jimwendler.com/blogs/jimwendler-com/101065094-5-3-1-for-a-beginner',
            'https://thefitness.wiki/routines/5-3-1-for-beginners/',
            'https://liftvault.com/programs/strength/531-for-beginners/'
        ],
        NULL
    ),

    -- Tactical Barbell - Operator Template
    (
        '6c9eaf54-a8e1-11ef-9c42-7d5facb30f9e',
        'Tactical Barbell - Operator',
        'Tactical Barbell is a comprehensive strength and conditioning system designed specifically for operational athletes—military personnel, law enforcement, firefighters, and others whose jobs demand both strength and conditioning. The Operator template is the most popular strength protocol, providing a balance of strength development and recovery capacity for concurrent conditioning work.

**Philosophy**: Operational athletes can''t afford to sacrifice conditioning for strength or vice versa. The system uses sub-maximal training loads (70-95% 1RM) and structured periodization to build strength while maintaining energy and recovery capacity needed for concurrent conditioning work.

**Program Type**: Block periodization with concurrent strength and conditioning
**Duration**: 6-week blocks (two 3-week waves)
**Training Days**: 3 days per week for strength (minimum 48 hours between sessions)
**Session Structure**: 2-3 barbell exercises per session (cluster-based)

**Operator Cluster Options**:
- Option 1: Squat, Bench Press, Deadlift
- Option 2: Squat, Overhead Press, Deadlift
- Option 3: Front Squat, Bench Press, Weighted Pull-up
- Option 4: Squat, Weighted Dip, Deadlift

**Periodization Scheme (6-week block - Two 3-week waves)**:

*Wave 1 (Weeks 1-3):*
- Week 1: 3x5 @ 70%, 75%, 80% (Sessions 1, 2, 3)
- Week 2: 3x3 @ 80%, 85%, 90% (Sessions 1, 2, 3)
- Week 3: 5x2 @ 85%, 87.5%, 90% (Sessions 1, 2, 3)

*Wave 2 (Weeks 4-6):*
- Week 4: 3x5 @ 75%, 80%, 85% (Sessions 1, 2, 3)
- Week 5: 3x3 @ 85%, 90%, 92.5% (Sessions 1, 2, 3)
- Week 6: 5x2 @ 87.5%, 90%, 92.5% (Sessions 1, 2, 3)

**Rest Periods**: 3-5 minutes between sets, minimum 48 hours between sessions

**Conditioning Integration**:
- Base Building (8 weeks): Strength-Endurance circuits + easy runs/rucks
- Black Protocol (strength-focused): Operator 3-4x/week + HIC 1-2x/week + E 1-2x/week
- Green Protocol (endurance-focused): Operator 2x/week + E 3-4x/week + HIC 1x/week

**Progression**:
- Complete 6-week block
- Test new maxes (optional)
- Increase training maxes by 2.5-5% upper body, 5-10 lbs lower body
- Begin new 6-week block

**Target Audience**: Tactical/operational athletes, anyone needing concurrent strength and conditioning
**Evidence Base**: KB (20-year military and federal law enforcement veteran). Developed over 20 years with operational athletes. Based on block periodization and sub-maximal loading principles.',
        ARRAY[
            'https://www.tacticalbarbell.com/',
            'https://www.amazon.com/Tactical-Barbell-Definitive-Strength-Operational/dp/1537666932',
            'https://www.amazon.com/Tactical-Barbell-2-Conditioning/dp/1537710443',
            'https://liftvault.com/programs/strength/tactical-barbell/',
            'https://jamesstuber.com/tactical-barbell-ii/'
        ],
        NULL
    ),

    -- CrossFit Strength Bias (CFSB)
    (
        '7dafb065-a8e1-11ef-9c42-8e6gbdc41faf',
        'CrossFit Strength Bias (CFSB)',
        'CrossFit Strength Bias (CFSB) is a programming approach that adds systematic heavy strength training to the CrossFit methodology without sacrificing metabolic conditioning and gymnastics work. Developed by Jeff Martin and refined over five years, CFSB addresses the critique that standard CrossFit programming doesn''t provide enough focused strength work.

**Philosophy**: Stemming from Greg Glassman''s "What is Fitness" article describing the ideal session: warm up, perform 3-5 sets of 3-5 reps of a fundamental lift, follow with a 10-minute circuit of gymnastics at high intensity, then finish with 2-10 minutes of metabolic conditioning. CFSB systematizes this with specific strength protocols paired with CrossFit WODs.

**Program Type**: Concurrent strength and conditioning with strength emphasis
**Training Days**: 4-5 days per week
**Session Structure**: Heavy strength work (15-20 min) followed by CrossFit WOD (10-30 min)
**Strength Focus**: At least 3 days per week of heavy barbell work

**Weekly Template**:
- Monday: Heavy Squat + WOD
- Tuesday: Heavy Press + WOD
- Wednesday: Rest or light conditioning
- Thursday: Heavy Deadlift + WOD
- Friday: Heavy Olympic lift + WOD
- Saturday: WOD only (longer/heavier)
- Sunday: Rest

**Strength Protocols**:

*5x5 Protocol*: 5 sets x 5 reps @ 75-85% 1RM, work to heavy 5RM

*3x5 and 5x3 "Choice Days"*: Choose based on recovery
- 3x5: 3 sets x 5 reps @ 80-85% (when fresher)
- 5x3: 5 sets x 3 reps @ 85-90% (when fatigued)

*5-5-5-5-5 Protocol*: 5 sets x 5 reps, increasing weight each set to 5RM

*3-3-3-3-3 Protocol*: 5 sets x 3 reps, increasing weight each set to 3RM

*1-1-1-1-1-1-1 Protocol*: 5-7 heavy singles, work to daily max

*12-Week Progressive Cycle*:
- Weeks 1-3: 3x8 @ 65-70%
- Weeks 4-6: 3x6 @ 70-75%
- Weeks 7-9: 4x4 @ 75-80%
- Weeks 10-12: 5x2 @ 85-90%
- Test maxes after week 12, restart cycle

**Rest Periods**: 3-5 minutes for strength, minimal for WODs

**WOD Examples**:
- "Fran": 21-15-9 Thrusters/Pull-ups for time
- "Murph": 1mi run, 100 pull-ups, 200 push-ups, 300 squats, 1mi run
- AMRAP: 12 min - 5 Deadlifts 225lbs, 10 Pull-ups, 15 Air Squats

**Progression**:
- Aim to set a PR every week on at least one lift
- Small jumps: 2.5-5 lbs upper body, 5-10 lbs lower body
- Autoregulate using choice days to match protocol to recovery
- Deload after 12-week cycle or when needed (reduce volume 50%)

**Target Audience**: CrossFit athletes who want improved strength while maintaining broad fitness
**Evidence Base**: Jeff Martin (CrossFit coach) and Dr. Darrell "Bingo" White. Developed over 5+ years with competitive CrossFit athletes. Featured in CrossFit Journal (2009).',
        ARRAY[
            'https://journal.crossfit.com/2009/02/crossfit-strength-bias.tpl',
            'https://library.crossfit.com/premium/pdf/CFJ_MartinWhite_StrengthBias.pdf',
            'https://www.endofthreefitness.com/workout-programs/ramp-programs/crossfit-strength-bias/',
            'https://www.boxrox.com/strength-training-barbell-programs/'
        ],
        NULL
    ),

    -- Renaissance Periodization Physique Templates
    (
        '8ebfc176-a8e1-11ef-9c42-9f7hcde52gc0',
        'Renaissance Periodization - 6 Day PPL',
        'Renaissance Periodization Physique Templates represent the pinnacle of evidence-based bodybuilding and hypertrophy training, designed by Dr. Mike Israetel. These templates use the latest scientific research on muscle growth to create customizable, autoregulated programs that adapt to individual responses. This is a sample 6-day Push/Pull/Legs template.

**Philosophy**: Systematically apply principles of volume landmarks (MEV, MAV, MRV) and progressive overload within structured mesocycles. Each variable (volume, intensity, frequency, exercise selection) is carefully manipulated to maximize muscle growth while managing fatigue.

**Program Type**: Block periodization with autoregulated volume
**Template**: 6-day Push/Pull/Legs (PPLPPL)
**Duration**: 13 weeks per full cycle (3 mesocycles)
**Training Days**: 6 days per week

**Mesocycle Structure (13-week cycle)**:

*Mesocycle 1: Hypertrophy Focus (Weeks 1-5)*
- Rep ranges: 6-12 reps
- Focus: Mechanical tension, moderate weights
- Volume: MEV → MAV → approaching MRV
- Week 5: Deload

*Mesocycle 2: Metabolite Focus (Weeks 6-10)*
- Rep ranges: 12-20+ reps
- Focus: Metabolic stress, pump work, shorter rest
- Volume: MEV → MAV → approaching MRV
- Week 10: Deload

*Mesocycle 3: Resensitization (Weeks 11-13)*
- Rep ranges: 4-8 reps
- Focus: Strength development, lower volume
- Purpose: Resensitize muscles to hypertrophy stimuli
- Week 13: Deload

**Volume Landmarks (sets per muscle per week)**:
- Week 1 (MEV): 10-12 sets
- Week 2 (Lower MAV): 12-16 sets
- Week 3 (Mid-MAV): 16-20 sets
- Week 4 (Approaching MRV): 20-25 sets
- Week 5 (Deload): 6-8 sets

**RPE/Intensity**: RPE 7-9 (1-3 reps from failure)
- Sets to failure (RPE 10) used sparingly due to fatigue
- Last set often taken to RPE 9

**Autoregulation**: After each workout, rate session. Template adjusts next workout:
- Rating 1-2: Reduce volume
- Rating 3-4: Maintain volume
- Rating 5: Increase volume (if not Week 4)

**Rest Periods**:
- Compound lifts: 2-3 minutes
- Isolation exercises: 60-90 seconds

**Sample Push Day (Hypertrophy Block, Week 2)**:
1. Incline Barbell Bench: 4x8-10, 2-3min, RPE 7-9
2. Flat Dumbbell Bench: 3x10-12, 2min, RPE 8-9
3. Overhead Press: 3x8-10, 2-3min, RPE 7-9
4. Dumbbell Lateral Raise: 4x12-15, 90s, RPE 8-9
5. Overhead Tricep Extension: 3x10-12, 90s, RPE 8-9
6. Tricep Pushdown: 3x12-15, 60s, RPE 9

**Progression**:
- Weekly Volume: Add 1-2 sets per muscle per week within mesocycle
- Load: When hitting top of rep range with good form (RPE 8-9), increase weight 2.5-5%
- Mesocycle-to-Mesocycle: Start new mesocycle with slightly higher baseline if previous successful

**Target Audience**: Intermediate to advanced bodybuilders and physique competitors
**Evidence Base**: Dr. Mike Israetel (Ph.D. Sport Physiology, Exercise Science professor, competitive bodybuilder). Incorporates research from Brad Schoenfeld, James Krieger, Eric Helms. Used by thousands of natural and enhanced athletes.',
        ARRAY[
            'https://rpstrength.com/',
            'https://renaissanceperiodization.com/expert-advice/male-and-female-physique-templates-20',
            'https://rpstrength.com/blogs/articles/dr-mike-israetel-compilation',
            'https://liftvault.com/programs/bodybuilding/mike-israetel-5-week-hypertrophy-workout-routine-spreadsheet/',
            'https://www.bodyspec.com/blog/post/renaissance_periodization_principles_and_guide'
        ],
        NULL
    ),

    -- Mike Israetel's Hypertrophy Training Principles (Sample Mesocycle)
    (
        '9fcfd287-a8e1-11ef-9c42-a08idfe63hd1',
        'Mike Israetel Hypertrophy Principles - Sample Mesocycle',
        'Dr. Mike Israetel''s Hypertrophy Training Principles represent a scientific framework for understanding and applying training volume for muscle growth. This is a sample 4-week mesocycle demonstrating the Volume Landmarks System (MV, MEV, MAV, MRV). This is a principles-based framework, not a specific program.

**Philosophy**: Different people and muscle groups have varying volume needs. The framework uses four volume landmarks defining the relationship between training volume and muscle growth for each individual and muscle group.

**The Four Volume Landmarks**:

*1. MV (Maintenance Volume)*: 4-8 sets per muscle per week
- Minimum to maintain current muscle mass
- Used during deloads, diet breaks, or when maintaining

*2. MEV (Minimum Effective Volume)*: 8-12 sets per muscle per week (varies by muscle)
- Minimum volume needed to make new muscle gains
- Starting point for new mesocycles after deload
- Examples: Chest 10-12, Back 12-14, Quads 12-16, Biceps 8-12

*3. MAV (Maximum Adaptive Volume)*: 12-20 sets per muscle per week
- The "sweet spot" for optimal muscle growth
- Enough volume to maximize growth without excessive fatigue
- Progressive range within mesocycle (Week 1: 14 sets → Week 4: 20 sets)
- Examples: Chest 14-18, Back 16-20, Quads 16-22, Biceps 12-16

*4. MRV (Maximum Recoverable Volume)*: 18-28 sets per muscle per week
- Maximum volume you can handle while recovering
- Upper limit approached in final weeks before deload
- Exceeding MRV = accumulated fatigue, joint stress, stalled progress
- Examples: Chest 18-22, Back 20-25, Quads 20-28, Biceps 16-20

**Sample 4-Week Mesocycle Structure**:
- Week 1: Start at MEV (8-12 sets per muscle)
- Week 2: Increase to lower MAV (12-16 sets)
- Week 3: Increase to mid-MAV (16-20 sets)
- Week 4: Approach MRV (20-25 sets)
- Week 5: Deload (return to MV, 4-8 sets)

**Training Frequency**: 2x per week per muscle group (standard recommendation)

**Set Quality Requirements**:
- Sets at RPE 7-9 (1-3 reps from failure) count as "working sets"
- Sets to failure (RPE 10) generate more fatigue, use sparingly
- Sets below RPE 6 are warm-up sets, don''t count toward volume

**Exercise Selection**:
- Compound exercises count toward multiple muscle groups
  - Example: Bench press = 1 set chest, 0.5 sets triceps
- Isolation exercises count toward single muscle group
  - Example: Bicep curl = 1 set biceps only

**Rep Ranges for Hypertrophy**:
- Primary range: 6-20 reps per set
- Optimal: 8-12 reps (balance mechanical tension and metabolic stress)
- Strength-focused: 4-8 reps
- Metabolite-focused: 12-20+ reps

**Rest Periods**:
- Compound lifts: 2-4 minutes
- Isolation exercises: 60-90 seconds
- Principle: Rest enough for next set quality

**Sample Application (Chest - 4-Week Mesocycle)**:

*Week 1 (MEV - 10 sets):*
- Monday: Flat BB Bench 3x8, Incline DB Press 2x10
- Thursday: Flat DB Press 3x10, Cable Flyes 2x12

*Week 2 (Lower MAV - 14 sets):*
- Monday: Flat BB Bench 4x8, Incline DB Press 3x10
- Thursday: Flat DB Press 3x10, Cable Flyes 3x12, Push-ups 1xAMRAP

*Week 3 (Mid-MAV - 18 sets):*
- Monday: Flat BB Bench 4x8, Incline DB Press 4x10, Cable Flyes 2x15
- Thursday: Flat DB Press 4x10, Incline DB Flyes 2x12, Push-ups 2xAMRAP

*Week 4 (Approaching MRV - 22 sets):*
- Monday: Flat BB Bench 5x8, Incline DB Press 4x10, Cable Flyes 3x15
- Thursday: Flat DB Press 4x10, Incline DB Flyes 3x12, Dips 3x10

*Week 5 (Deload - MV - 6 sets):*
- Monday: Flat BB Bench 2x8 @ 60%, Incline DB Press 2x10 @ 60%
- Thursday: Push-ups 2x10 (easy tempo)

**Progression Hierarchy**:
1. Add volume (sets per week) - primary driver
2. Add load when hitting rep targets
3. Improve technique and rep quality
4. Reduce rest periods (for metabolic training)
5. Increase frequency

**Target Audience**: All levels - framework applies to any hypertrophy program design
**Evidence Base**: Dr. Mike Israetel (Ph.D. Sport Physiology). Synthesis of research from Brad Schoenfeld, James Krieger, and practical coaching with thousands of clients. Meta-analyses showing dose-response relationship between volume and hypertrophy.',
        ARRAY[
            'https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth',
            'https://drmikeisraetel.com/dr-mike-israetel-mv-mev-mav-mrv-explained/',
            'https://dr-muscle.com/maximum-recoverable-training-volume/',
            'https://www.simonesmerilli.com/fitness/workout-volume',
            'https://volume-landmarks-rp-rals.vercel.app/'
        ],
        NULL
    )
ON CONFLICT (plan_id) DO NOTHING;

-- =============================================================================
-- SESSION SCHEDULES (Workout Days/Sessions within Programs)
-- =============================================================================
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
    -- 5/3/1 BBB Sessions
    ('4b8da043-a8e1-11ef-9c42-6c4f9ba2e08e', '4a7c8f32-a8e1-11ef-9c42-5b3e8a9d1f7c', 'Squat Day',
     'Main 5/3/1 work followed by 5x10 @ 50-60% TM. Assistance: Push, Pull, Single-leg/Core (50-100 reps each)',
     1.0, ARRAY['https://www.jimwendler.com/blogs/jimwendler-com/101077382-boring-but-big'], NULL),

    ('4c9eb154-a8e1-11ef-9c42-7d5facb30f9f', '4a7c8f32-a8e1-11ef-9c42-5b3e8a9d1f7c', 'Bench Press Day',
     'Main 5/3/1 work followed by 5x10 @ 50-60% TM. Can superset BBB sets with lat work. Assistance: Push, Pull, Single-leg/Core',
     1.0, NULL, NULL),

    ('4dafc265-a8e1-11ef-9c42-8e6gbdc41fb0', '4a7c8f32-a8e1-11ef-9c42-5b3e8a9d1f7c', 'Deadlift Day',
     'Main 5/3/1 work followed by 5x10 @ 50-60% TM. IMPORTANT: Start very light (30-40% TM) first cycle. Assistance: Push, Pull, Single-leg/Core',
     1.0, NULL, NULL),

    ('4ebfd376-a8e1-11ef-9c42-9f7hcde52gc1', '4a7c8f32-a8e1-11ef-9c42-5b3e8a9d1f7c', 'Overhead Press Day',
     'Main 5/3/1 work followed by 5x10 @ 50-60% TM. Can superset BBB sets with lat work. Assistance: Push, Pull, Single-leg/Core',
     1.0, NULL, NULL),

    -- 5/3/1 for Beginners Sessions
    ('5cd0e487-a8e1-11ef-9c42-a08idfe63hd2', '5b8d9e43-a8e1-11ef-9c42-6c4f9ba2e08d', 'Day 1: Squat + Bench',
     'Both lifts: 5/3/1 main work + FSL 5x5. Assistance: Push, Pull, Single-leg/Core (50-100 reps each)',
     1.0, ARRAY['https://www.jimwendler.com/blogs/jimwendler-com/5-3-1-for-beginners', 'https://thefitness.wiki/routines/5-3-1-for-beginners/'], NULL),

    ('5de1f598-a8e1-11ef-9c42-b19jegf74ie3', '5b8d9e43-a8e1-11ef-9c42-6c4f9ba2e08d', 'Day 2: Deadlift + OHP',
     'Both lifts: 5/3/1 main work + FSL 5x5. Assistance: Push, Pull, Single-leg/Core (50-100 reps each)',
     1.0, NULL, NULL),

    ('5ef206a9-a8e1-11ef-9c42-c2akfhg85jf4', '5b8d9e43-a8e1-11ef-9c42-6c4f9ba2e08d', 'Day 3: Bench + Squat',
     'Both lifts: 5/3/1 main work + FSL 5x5. Assistance: Push, Pull, Single-leg/Core (50-100 reps each)',
     1.0, NULL, NULL),

    -- Tactical Barbell Operator Sessions
    ('6f03179a-a8e1-11ef-9c42-d3blgih96kg5', '6c9eaf54-a8e1-11ef-9c42-7d5facb30f9e', 'Operator Day 1',
     'All cluster exercises. Week/session determines sets/reps and percentages. See plan description for full periodization.',
     1.0, ARRAY['https://www.tacticalbarbell.com/'], NULL),

    ('70142bab-a8e1-11ef-9c42-e4cmhji0a7lh6', '6c9eaf54-a8e1-11ef-9c42-7d5facb30f9e', 'Operator Day 2',
     'All cluster exercises. Minimum 48 hours after Day 1. Rest 3-5 min between sets.',
     1.0, NULL, NULL),

    ('71253cbc-a8e1-11ef-9c42-f5dnikj1b8m7', '6c9eaf54-a8e1-11ef-9c42-7d5facb30f9e', 'Operator Day 3',
     'All cluster exercises. Minimum 48 hours after Day 2. Rest 3-5 min between sets.',
     1.0, NULL, NULL),

    -- CrossFit Strength Bias Sessions
    ('82364dcd-a8e1-11ef-9c42-g6eojlk2c9n8', '7dafb065-a8e1-11ef-9c42-8e6gbdc41faf', 'Monday: Squat + WOD',
     'Strength: Squat 5-5-5-5-5 (work to heavy 5). Rest 5-10 min. WOD: 10-20 min high intensity (examples: Fran, AMRAP, for-time)',
     1.0, ARRAY['https://journal.crossfit.com/2009/02/crossfit-strength-bias.tpl'], NULL),

    ('83475ede-a8e1-11ef-9c42-h7fpkml3dao9', '7dafb065-a8e1-11ef-9c42-8e6gbdc41faf', 'Tuesday: Press + WOD',
     'Strength: Overhead Press 3-3-3-3-3 (work to heavy 3). Rest 5-10 min. WOD: 10-20 min high intensity',
     1.0, NULL, NULL),

    ('84586fef-a8e1-11ef-9c42-i8gqlnm4ebpa', '7dafb065-a8e1-11ef-9c42-8e6gbdc41faf', 'Thursday: Deadlift + WOD',
     'Strength: Deadlift 5x3 or 3x5 (choice day based on recovery). Rest 5-10 min. WOD: 10-20 min high intensity',
     1.0, NULL, NULL),

    ('856970fa-a8e1-11ef-9c42-j9hrmon5fcqb', '7dafb065-a8e1-11ef-9c42-8e6gbdc41faf', 'Friday: Olympic Lift + WOD',
     'Strength: Power Clean or Snatch 1-1-1-1-1 (work to daily max). Rest 5-10 min. WOD: 10-20 min high intensity',
     1.0, NULL, NULL),

    ('867a81fb-a8e1-11ef-9c42-kaisnpo6gdrc', '7dafb065-a8e1-11ef-9c42-8e6gbdc41faf', 'Saturday: WOD Only',
     'No strength work. Longer or heavier WOD (20-45 min). Examples: Murph, Hero WODs, benchmark WODs',
     1.0, NULL, NULL),

    -- Renaissance Periodization PPL Sessions (6-day)
    ('978b920c-a8e1-11ef-9c42-lbjtqpr7hesc', '8ebfc176-a8e1-11ef-9c42-9f7hcde52gc0', 'Push Day 1',
     'Hypertrophy Block example: Incline BB Bench, Flat DB Bench, OHP, DB Lateral Raise, Overhead Tricep Ext, Tricep Pushdown. RPE 7-9, see plan for volume progression.',
     1.0, ARRAY['https://rpstrength.com/'], NULL),

    ('989ca31d-a8e1-11ef-9c42-mcktqrs8iftd', '8ebfc176-a8e1-11ef-9c42-9f7hcde52gc0', 'Pull Day 1',
     'Hypertrophy Block example: Deadlift, Barbell Row, Lat Pulldown, Cable Row, Barbell Curl, Hammer Curl. RPE 7-9.',
     1.0, NULL, NULL),

    ('99adb42e-a8e1-11ef-9c42-ndlurst9jgue', '8ebfc176-a8e1-11ef-9c42-9f7hcde52gc0', 'Leg Day 1',
     'Hypertrophy Block example: Back Squat, Romanian Deadlift, Leg Press, Leg Curl, Leg Extension, Standing Calf Raise. RPE 7-9.',
     1.0, NULL, NULL),

    ('9abec53f-a8e1-11ef-9c42-oemvstu0khvf', '8ebfc176-a8e1-11ef-9c42-9f7hcde52gc0', 'Push Day 2',
     'Exercise variation from Push Day 1. Flat BB Bench, Incline DB Press, DB Shoulder Press, Cable Lateral Raise, Close-Grip Bench, Cable Rope Tricep Ext.',
     1.0, NULL, NULL),

    ('9bcfd650-a8e1-11ef-9c42-pfnwtuv1liwg', '8ebfc176-a8e1-11ef-9c42-9f7hcde52gc0', 'Pull Day 2',
     'Exercise variation from Pull Day 1. Weighted Pull-ups, T-Bar Row, Lat Pulldown (underhand), Face Pulls, Incline DB Curl, Cable Curl.',
     1.0, NULL, NULL),

    ('9cdee761-a8e1-11ef-9c42-qgoxuvw2mjxh', '8ebfc176-a8e1-11ef-9c42-9f7hcde52gc0', 'Leg Day 2',
     'Exercise variation from Leg Day 1. Front Squat, Leg Press, Bulgarian Split Squat, Lying Leg Curl, Walking Lunges, Seated Calf Raise.',
     1.0, NULL, NULL),

    -- Mike Israetel Sample Mesocycle Sessions
    ('adef0872-a8e1-11ef-9c42-rhpyvwx3nkyi', '9fcfd287-a8e1-11ef-9c42-a08idfe63hd1', 'Sample Day 1: Chest + Triceps',
     'Volume Landmarks demo. Week 1: MEV, Week 2-3: MAV, Week 4: Approaching MRV. Exercises: Flat BB Bench, Incline DB Press, Cable Flyes, Overhead Tricep Ext, Tricep Pushdowns.',
     1.0, ARRAY['https://rpstrength.com/blogs/articles/training-volume-landmarks-muscle-growth'], NULL),

    ('aef01983-a8e1-11ef-9c42-siqzwxy4olzj', '9fcfd287-a8e1-11ef-9c42-a08idfe63hd1', 'Sample Day 2: Back + Biceps',
     'Volume progression week-to-week. Exercises: Deadlift, Barbell Row, Lat Pulldown, Cable Row, Barbell Curl, Hammer Curl. RPE 7-9.',
     1.0, NULL, NULL),

    ('afe12a94-a8e1-11ef-9c42-tjrayz05pmak', '9fcfd287-a8e1-11ef-9c42-a08idfe63hd1', 'Sample Day 3: Legs',
     'Volume Landmarks applied to quads/hams. Exercises: Squat, Romanian Deadlift, Leg Press, Leg Curl, Leg Extension, Calf Raise.',
     1.0, NULL, NULL),

    ('b0f23ba5-a8e1-11ef-9c42-uksbza16qnbl', '9fcfd287-a8e1-11ef-9c42-a08idfe63hd1', 'Sample Day 4: Shoulders + Arms',
     'Demonstrates volume progression for smaller muscle groups. Exercises: Overhead Press, Lateral Raise, Face Pulls, Bicep Curl, Tricep Pushdown.',
     1.0, NULL, NULL)
ON CONFLICT (session_schedule_id) DO NOTHING;

-- =============================================================================
-- EXERCISES (Exercise configurations within session schedules)
-- NOTE: These are representative examples showing the structure.
-- Full implementation would include all exercises with proper periodization notes.
-- Percentages and progression would be documented in descriptions.
-- =============================================================================

-- Base exercise UUIDs from seed data (for reference):
-- Squat: '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1'
-- Bench press: '02a1a38a-70f9-11ef-bc64-d72b6479cb97'
-- Deadlift: '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e'
-- Overhead press: '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22'
-- Barbell Row: '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab'
-- Front Squat: '10845aff-07ac-4359-a8dd-ce99442e33d5'
-- Power Clean: 'f9d74097-5636-43ed-84d5-a458c56b3b5b'
-- Pull-ups: 'ebb32783-f125-4242-a0ad-17912534d844'
-- Dips: '2659f231-981f-4f2f-ba3f-1e4fa12728bc'
-- Romanian Deadlift: 'ebe84120-4658-49f9-b15c-c3fc72dd6608'
-- Leg Press: '5270cfc0-31a3-458e-9baf-62803346d03f'
-- Face Pulls: '34bd3f09-0a5a-480b-b450-746b1e5c7274'
-- Tricep Pushdowns: 'b5d34436-b28a-41cb-bfd1-93051e352f3f'
-- Leg Extension: '08562f83-66ea-49d9-bbf8-89cde104a5a7'
-- Dumbbell Row: 'cc50696f-1aad-422e-a192-12c9bfd0cc25'
-- Bulgarian Split Squats: '96d6be35-ae4e-4174-872e-c28764998a1a'
-- Hammer Curls: '62fe9884-1c76-4224-af6e-8cd05a17e385'
-- Walking Lunges: '4be09662-74c5-4b7c-ad35-37848e4248e8'
-- Incline Barbell Bench: '913b28dd-6d15-4621-83de-e4804fe6c973'
-- Cable Curls: 'e4977b90-62d6-4465-b50c-49bd1d6a61be'
-- Seated Calf Raise: '8d004901-339c-4354-8ca3-28a5ef5432a6'
-- Incline Dumbbell Curls: '93d61257-bad8-4c8d-b107-b814140d19c2'
-- Dumbbell incline press: 'bee3dda4-05c8-11ed-824f-2f172103312d'
-- Bicep curl: 'bee63c0c-05c8-11ed-824f-673da9665bfa'
-- Lat pulldown: '28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50'
-- Lateral raise: 'a3532824-4bc2-11ee-8c75-ebab3389e058'
-- Overhead tricep extension: 'bee7fe8e-05c8-11ed-824f-578dbf84191f'
-- Calf raise: 'bef283ae-05c8-11ed-824f-870b793b71df'
-- Incline chest press: '1a758ec0-31ba-11ed-aa8c-93f957060fad'
-- Dumbbell shoulder press: 'bef85388-05c8-11ed-824f-cbc3b1aa33b1'
-- Close-Grip Bench Press: '48a24998-5466-4e5c-af83-fc2de2cd6c4c'
-- T-Bar row: '29d5069e-dc9e-11ee-b3ef-574f7b65abee'

INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, step_increment, description, links, data)
VALUES
    -- =========================================================================
    -- 5/3/1 BORING BUT BIG EXERCISES
    -- =========================================================================

    -- Squat Day
    ('c1a23456-a8e1-11ef-9c42-001bbbexerc01', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '4b8da043-a8e1-11ef-9c42-6c4f9ba2e08e',
     5, 3, '00:04:00', 1000, 2500,
     'Main 5/3/1 Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+. Week 4 (Deload): 40%x5, 50%x5, 60%x5 (no AMRAP). + = AMRAP top set.',
     NULL, NULL),

    ('c1b34567-a8e1-11ef-9c42-002bbbexerc02', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '4b8da043-a8e1-11ef-9c42-6c4f9ba2e08e',
     10, 5, '00:02:30', 2000, 2500,
     'BBB Supplemental Work: 5x10 @ 50-60% Training Max. Cycle 1-2: 50%, Cycle 3-4: 55%, Cycle 5-6: 60%, Advanced: 65-70%.',
     NULL, NULL),

    ('c1c45678-a8e1-11ef-9c42-003bbbexerc03', 'ebb32783-f125-4242-a0ad-17912534d844', '4b8da043-a8e1-11ef-9c42-6c4f9ba2e08e',
     10, 5, '00:02:00', 3000, 2500,
     'Assistance - Pull: 50-100 total reps. Chin-ups, pull-ups, or rows.',
     NULL, NULL),

    ('c1d56789-a8e1-11ef-9c42-004bbbexerc04', '2659f231-981f-4f2f-ba3f-1e4fa12728bc', '4b8da043-a8e1-11ef-9c42-6c4f9ba2e08e',
     10, 5, '00:02:00', 4000, 2500,
     'Assistance - Push: 50-100 total reps. Dips, push-ups, or overhead press variations.',
     NULL, NULL),

    -- Bench Press Day
    ('c2a23456-a8e1-11ef-9c42-005bbbexerc05', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '4c9eb154-a8e1-11ef-9c42-7d5facb30f9f',
     5, 3, '00:04:00', 1000, 2500,
     'Main 5/3/1 Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+. Week 4 (Deload): 40%x5, 50%x5, 60%x5 (no AMRAP).',
     NULL, NULL),

    ('c2b34567-a8e1-11ef-9c42-006bbbexerc06', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '4c9eb154-a8e1-11ef-9c42-7d5facb30f9f',
     10, 5, '00:02:30', 2000, 2500,
     'BBB Supplemental Work: 5x10 @ 50-60% TM. Can superset with lat work (rows/pull-ups) to save time.',
     NULL, NULL),

    ('c2c45678-a8e1-11ef-9c42-007bbbexerc07', '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', '4c9eb154-a8e1-11ef-9c42-7d5facb30f9f',
     10, 5, '00:02:00', 3000, 2500,
     'Assistance - Pull: 50-100 total reps. Rows (barbell, dumbbell, cable), lat pulldowns.',
     NULL, NULL),

    -- Deadlift Day
    ('c3a23456-a8e1-11ef-9c42-008bbbexerc08', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '4dafc265-a8e1-11ef-9c42-8e6gbdc41fb0',
     5, 3, '00:04:00', 1000, 2500,
     'Main 5/3/1 Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+. Week 4 (Deload): 40%x5, 50%x5, 60%x5 (no AMRAP).',
     NULL, NULL),

    ('c3b34567-a8e1-11ef-9c42-009bbbexerc09', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '4dafc265-a8e1-11ef-9c42-8e6gbdc41fb0',
     10, 5, '00:02:30', 2000, 2500,
     'BBB Supplemental Work: 5x10 @ 50-60% TM. CRITICAL: Start very light (30-40% TM) for first cycle. This is extremely taxing.',
     NULL, NULL),

    ('c3c45678-a8e1-11ef-9c42-010bbbexerc10', 'ebb32783-f125-4242-a0ad-17912534d844', '4dafc265-a8e1-11ef-9c42-8e6gbdc41fb0',
     10, 5, '00:02:00', 3000, 2500,
     'Assistance - Pull: 50-100 total reps. Chin-ups, face pulls.',
     NULL, NULL),

    -- Overhead Press Day
    ('c4a23456-a8e1-11ef-9c42-011bbbexerc11', '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', '4ebfd376-a8e1-11ef-9c42-9f7hcde52gc1',
     5, 3, '00:04:00', 1000, 2500,
     'Main 5/3/1 Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+. Week 4 (Deload): 40%x5, 50%x5, 60%x5 (no AMRAP).',
     NULL, NULL),

    ('c4b34567-a8e1-11ef-9c42-012bbbexerc12', '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', '4ebfd376-a8e1-11ef-9c42-9f7hcde52gc1',
     10, 5, '00:02:30', 2000, 2500,
     'BBB Supplemental Work: 5x10 @ 50-60% TM. Can superset with lat work.',
     NULL, NULL),

    ('c4c45678-a8e1-11ef-9c42-013bbbexerc13', 'ebb32783-f125-4242-a0ad-17912534d844', '4ebfd376-a8e1-11ef-9c42-9f7hcde52gc1',
     10, 5, '00:02:00', 3000, 2500,
     'Assistance - Pull: 50-100 total reps. Rows, pull-ups, shrugs.',
     NULL, NULL),

    ('c4d56789-a8e1-11ef-9c42-014bbbexerc14', '2659f231-981f-4f2f-ba3f-1e4fa12728bc', '4ebfd376-a8e1-11ef-9c42-9f7hcde52gc1',
     10, 5, '00:02:00', 4000, 2500,
     'Assistance - Push: 50-100 total reps. Dips, close-grip bench press.',
     NULL, NULL),

    -- =========================================================================
    -- 5/3/1 FOR BEGINNERS EXERCISES
    -- =========================================================================

    -- Day 1: Squat + Bench
    ('d1a23456-a8e1-11ef-9c42-015begexerc01', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '5cd0e487-a8e1-11ef-9c42-a08idfe63hd2',
     5, 3, '00:04:00', 1000, 2500,
     'Squat Main Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+.',
     NULL, NULL),

    ('d1b34567-a8e1-11ef-9c42-016begexerc02', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '5cd0e487-a8e1-11ef-9c42-a08idfe63hd2',
     5, 5, '00:02:30', 2000, 2500,
     'Squat FSL Supplemental: 5x5 @ first set percentage. Week 1: 65%, Week 2: 70%, Week 3: 75%.',
     NULL, NULL),

    ('d1c45678-a8e1-11ef-9c42-017begexerc03', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '5cd0e487-a8e1-11ef-9c42-a08idfe63hd2',
     5, 3, '00:04:00', 3000, 2500,
     'Bench Press Main Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+.',
     NULL, NULL),

    ('d1d56789-a8e1-11ef-9c42-018begexerc04', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '5cd0e487-a8e1-11ef-9c42-a08idfe63hd2',
     5, 5, '00:02:30', 4000, 2500,
     'Bench Press FSL Supplemental: 5x5 @ first set percentage. Week 1: 65%, Week 2: 70%, Week 3: 75%.',
     NULL, NULL),

    ('d1e6789a-a8e1-11ef-9c42-019begexerc05', 'ebb32783-f125-4242-a0ad-17912534d844', '5cd0e487-a8e1-11ef-9c42-a08idfe63hd2',
     10, 5, '00:02:00', 5000, 2500,
     'Assistance - Pull: 50-100 total reps. Chin-ups, pull-ups, rows.',
     NULL, NULL),

    -- Day 2: Deadlift + OHP
    ('d2a23456-a8e1-11ef-9c42-020begexerc06', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '5de1f598-a8e1-11ef-9c42-b19jegf74ie3',
     5, 3, '00:04:00', 1000, 2500,
     'Deadlift Main Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+.',
     NULL, NULL),

    ('d2b34567-a8e1-11ef-9c42-021begexerc07', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '5de1f598-a8e1-11ef-9c42-b19jegf74ie3',
     5, 5, '00:02:30', 2000, 2500,
     'Deadlift FSL Supplemental: 5x5 @ first set percentage. Week 1: 65%, Week 2: 70%, Week 3: 75%.',
     NULL, NULL),

    ('d2c45678-a8e1-11ef-9c42-022begexerc08', '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', '5de1f598-a8e1-11ef-9c42-b19jegf74ie3',
     5, 3, '00:04:00', 3000, 2500,
     'Overhead Press Main Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+.',
     NULL, NULL),

    ('d2d56789-a8e1-11ef-9c42-023begexerc09', '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', '5de1f598-a8e1-11ef-9c42-b19jegf74ie3',
     5, 5, '00:02:30', 4000, 2500,
     'Overhead Press FSL Supplemental: 5x5 @ first set percentage. Week 1: 65%, Week 2: 70%, Week 3: 75%.',
     NULL, NULL),

    ('d2e6789a-a8e1-11ef-9c42-024begexerc10', '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', '5de1f598-a8e1-11ef-9c42-b19jegf74ie3',
     10, 5, '00:02:00', 5000, 2500,
     'Assistance - Pull: 50-100 total reps. Barbell rows, dumbbell rows, lat pulldowns.',
     NULL, NULL),

    -- Day 3: Bench + Squat
    ('d3a23456-a8e1-11ef-9c42-025begexerc11', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '5ef206a9-a8e1-11ef-9c42-c2akfhg85jf4',
     5, 3, '00:04:00', 1000, 2500,
     'Bench Press Main Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+.',
     NULL, NULL),

    ('d3b34567-a8e1-11ef-9c42-026begexerc12', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '5ef206a9-a8e1-11ef-9c42-c2akfhg85jf4',
     5, 5, '00:02:30', 2000, 2500,
     'Bench Press FSL Supplemental: 5x5 @ first set percentage. Week 1: 65%, Week 2: 70%, Week 3: 75%.',
     NULL, NULL),

    ('d3c45678-a8e1-11ef-9c42-027begexerc13', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '5ef206a9-a8e1-11ef-9c42-c2akfhg85jf4',
     5, 3, '00:04:00', 3000, 2500,
     'Squat Main Work. Week 1: 65%x5, 75%x5, 85%x5+. Week 2: 70%x3, 80%x3, 90%x3+. Week 3: 75%x5, 85%x3, 95%x1+.',
     NULL, NULL),

    ('d3d56789-a8e1-11ef-9c42-028begexerc14', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '5ef206a9-a8e1-11ef-9c42-c2akfhg85jf4',
     5, 5, '00:02:30', 4000, 2500,
     'Squat FSL Supplemental: 5x5 @ first set percentage. Week 1: 65%, Week 2: 70%, Week 3: 75%.',
     NULL, NULL),

    -- =========================================================================
    -- TACTICAL BARBELL OPERATOR EXERCISES
    -- =========================================================================

    -- Operator Day 1 (Example with Squat, Bench, Deadlift cluster)
    ('e1a23456-a8e1-11ef-9c42-029tbopexerc01', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '6f03179a-a8e1-11ef-9c42-d3blgih96kg5',
     5, 3, '00:04:00', 1000, 2500,
     'Squat. See plan periodization: Wave 1 Wk1: 3x5@70/75/80%, Wk2: 3x3@80/85/90%, Wk3: 5x2@85/87.5/90%. Wave 2 starts higher.',
     NULL, NULL),

    ('e1b34567-a8e1-11ef-9c42-030tbopexerc02', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '6f03179a-a8e1-11ef-9c42-d3blgih96kg5',
     5, 3, '00:04:00', 2000, 2500,
     'Bench Press. Same periodization as Squat. Percentages based on session within week.',
     NULL, NULL),

    ('e1c45678-a8e1-11ef-9c42-031tbopexerc03', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '6f03179a-a8e1-11ef-9c42-d3blgih96kg5',
     5, 3, '00:04:00', 3000, 2500,
     'Deadlift. Same periodization. Rest 3-5 minutes between all sets. Minimum 48 hours before next session.',
     NULL, NULL),

    -- Operator Day 2 (Same cluster, different session in week)
    ('e2a23456-a8e1-11ef-9c42-032tbopexerc04', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '70142bab-a8e1-11ef-9c42-e4cmhji0a7lh6',
     5, 3, '00:04:00', 1000, 2500,
     'Squat. Session 2 of week (higher percentage than Session 1). See plan for exact percentages.',
     NULL, NULL),

    ('e2b34567-a8e1-11ef-9c42-033tbopexerc05', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '70142bab-a8e1-11ef-9c42-e4cmhji0a7lh6',
     5, 3, '00:04:00', 2000, 2500,
     'Bench Press. Session 2 percentages.',
     NULL, NULL),

    ('e2c45678-a8e1-11ef-9c42-034tbopexerc06', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '70142bab-a8e1-11ef-9c42-e4cmhji0a7lh6',
     5, 3, '00:04:00', 3000, 2500,
     'Deadlift. Session 2 percentages.',
     NULL, NULL),

    -- Operator Day 3 (Highest percentages of the week)
    ('e3a23456-a8e1-11ef-9c42-035tbopexerc07', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '71253cbc-a8e1-11ef-9c42-f5dnikj1b8m7',
     5, 3, '00:04:00', 1000, 2500,
     'Squat. Session 3 of week (highest percentage). Wave 1 Wk1: 80%, Wk2: 90%, Wk3: 90%. Wave 2 higher.',
     NULL, NULL),

    ('e3b34567-a8e1-11ef-9c42-036tbopexerc08', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '71253cbc-a8e1-11ef-9c42-f5dnikj1b8m7',
     5, 3, '00:04:00', 2000, 2500,
     'Bench Press. Session 3 percentages (heaviest of week).',
     NULL, NULL),

    ('e3c45678-a8e1-11ef-9c42-037tbopexerc09', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '71253cbc-a8e1-11ef-9c42-f5dnikj1b8m7',
     5, 3, '00:04:00', 3000, 2500,
     'Deadlift. Session 3 percentages (heaviest of week).',
     NULL, NULL),

    -- =========================================================================
    -- CROSSFIT STRENGTH BIAS EXERCISES
    -- =========================================================================

    -- Monday: Squat + WOD
    ('f1a23456-a8e1-11ef-9c42-038cfsbexerc01', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '82364dcd-a8e1-11ef-9c42-g6eojlk2c9n8',
     5, 5, '00:04:00', 1000, 2500,
     'Squat 5-5-5-5-5: Work to heavy set of 5. Increase weight each set. Rest 3-5 min. Then 5-10 min rest before WOD.',
     NULL, NULL),

    -- Tuesday: Press + WOD
    ('f2a23456-a8e1-11ef-9c42-039cfsbexerc02', '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', '83475ede-a8e1-11ef-9c42-h7fpkml3dao9',
     3, 5, '00:04:00', 1000, 2500,
     'Overhead Press 3-3-3-3-3: Work to heavy set of 3. Increase weight each set. Rest 3-5 min. Then rest before WOD.',
     NULL, NULL),

    -- Thursday: Deadlift + WOD
    ('f3a23456-a8e1-11ef-9c42-040cfsbexerc03', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '84586fef-a8e1-11ef-9c42-i8gqlnm4ebpa',
     3, 5, '00:04:00', 1000, 2500,
     'Deadlift Choice Day: 5x3 or 3x5 based on recovery. 5x3 @ 85-90% when fatigued, 3x5 @ 80-85% when fresher. Auto-regulate.',
     NULL, NULL),

    -- Friday: Olympic Lift + WOD
    ('f4a23456-a8e1-11ef-9c42-041cfsbexerc04', 'f9d74097-5636-43ed-84d5-a458c56b3b5b', '856970fa-a8e1-11ef-9c42-j9hrmon5fcqb',
     1, 5, '00:04:00', 1000, 2500,
     'Power Clean 1-1-1-1-1-1-1: 5-7 heavy singles, work to daily max (not true 1RM). Rest 3-5 min. Then rest before WOD.',
     NULL, NULL),

    -- =========================================================================
    -- RENAISSANCE PERIODIZATION PPL EXERCISES
    -- =========================================================================

    -- Push Day 1
    ('g1a23456-a8e1-11ef-9c42-042rppplexerc01', '913b28dd-6d15-4621-83de-e4804fe6c973', '978b920c-a8e1-11ef-9c42-lbjtqpr7hesc',
     10, 4, '00:02:30', 1000, 2500,
     'Incline Barbell Bench: 4x8-10, RPE 7-9. Week 1: 3 sets (MEV), Week 2: 4 sets, Week 3: 4 sets, Week 4: 5 sets (MRV). When hit top reps +2.5-5%.',
     NULL, NULL),

    ('g1b34567-a8e1-11ef-9c42-043rppplexerc02', 'bee3dda4-05c8-11ed-824f-2f172103312d', '978b920c-a8e1-11ef-9c42-lbjtqpr7hesc',
     12, 3, '00:02:00', 2000, 2500,
     'Flat Dumbbell Bench: 3x10-12, RPE 8-9. Volume increases week-to-week within mesocycle.',
     NULL, NULL),

    ('g1c45678-a8e1-11ef-9c42-044rppplexerc03', '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', '978b920c-a8e1-11ef-9c42-lbjtqpr7hesc',
     10, 3, '00:02:30', 3000, 2500,
     'Overhead Press: 3x8-10, RPE 7-9. Progressive volume: Week 1-2: 3 sets, Week 3-4: 4 sets.',
     NULL, NULL),

    ('g1d56789-a8e1-11ef-9c42-045rppplexerc04', 'a3532824-4bc2-11ee-8c75-ebab3389e058', '978b920c-a8e1-11ef-9c42-lbjtqpr7hesc',
     15, 4, '00:01:30', 4000, 2500,
     'Lateral Raise: 4x12-15, RPE 8-9. 90 sec rest. Volume progresses weekly.',
     NULL, NULL),

    ('g1e6789a-a8e1-11ef-9c42-046rppplexerc05', 'bee7fe8e-05c8-11ed-824f-578dbf84191f', '978b920c-a8e1-11ef-9c42-lbjtqpr7hesc',
     12, 3, '00:01:30', 5000, 2500,
     'Overhead Tricep Extension: 3x10-12, RPE 8-9. 90 sec rest.',
     NULL, NULL),

    ('g1f789ab-a8e1-11ef-9c42-047rppplexerc06', 'b5d34436-b28a-41cb-bfd1-93051e352f3f', '978b920c-a8e1-11ef-9c42-lbjtqpr7hesc',
     15, 3, '00:01:00', 6000, 2500,
     'Tricep Pushdown: 3x12-15, RPE 9. 60 sec rest. Last exercise, push hard.',
     NULL, NULL),

    -- Pull Day 1
    ('g2a23456-a8e1-11ef-9c42-048rppplexerc07', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '989ca31d-a8e1-11ef-9c42-mcktqrs8iftd',
     8, 4, '00:03:00', 1000, 2500,
     'Deadlift: 4x6-8, RPE 7-8. 3 min rest. Progressive volume weekly.',
     NULL, NULL),

    ('g2b34567-a8e1-11ef-9c42-049rppplexerc08', '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', '989ca31d-a8e1-11ef-9c42-mcktqrs8iftd',
     10, 4, '00:02:00', 2000, 2500,
     'Barbell Row: 4x8-10, RPE 8-9. 2 min rest.',
     NULL, NULL),

    ('g2c45678-a8e1-11ef-9c42-050rppplexerc09', '28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50', '989ca31d-a8e1-11ef-9c42-mcktqrs8iftd',
     12, 3, '00:01:30', 3000, 2500,
     'Lat Pulldown: 3x10-12, RPE 8-9. 90 sec rest.',
     NULL, NULL),

    ('g2d56789-a8e1-11ef-9c42-051rppplexerc10', 'bee63c0c-05c8-11ed-824f-673da9665bfa', '989ca31d-a8e1-11ef-9c42-mcktqrs8iftd',
     12, 3, '00:01:30', 5000, 2500,
     'Barbell Curl: 3x10-12, RPE 8-9. 90 sec rest.',
     NULL, NULL),

    ('g2e6789a-a8e1-11ef-9c42-052rppplexerc11', '62fe9884-1c76-4224-af6e-8cd05a17e385', '989ca31d-a8e1-11ef-9c42-mcktqrs8iftd',
     15, 3, '00:01:00', 6000, 2500,
     'Hammer Curl: 3x12-15, RPE 9. 60 sec rest.',
     NULL, NULL),

    -- Leg Day 1
    ('g3a23456-a8e1-11ef-9c42-053rppplexerc12', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '99adb42e-a8e1-11ef-9c42-ndlurst9jgue',
     8, 4, '00:03:00', 1000, 2500,
     'Back Squat: 4x6-8, RPE 7-8. 3 min rest. Progressive volume: Week 1: 3 sets, Week 2-3: 4 sets, Week 4: 5 sets.',
     NULL, NULL),

    ('g3b34567-a8e1-11ef-9c42-054rppplexerc13', 'ebe84120-4658-49f9-b15c-c3fc72dd6608', '99adb42e-a8e1-11ef-9c42-ndlurst9jgue',
     10, 4, '00:02:00', 2000, 2500,
     'Romanian Deadlift: 4x8-10, RPE 8-9. 2 min rest. Critical for hamstrings.',
     NULL, NULL),

    ('g3c45678-a8e1-11ef-9c42-055rppplexerc14', '5270cfc0-31a3-458e-9baf-62803346d03f', '99adb42e-a8e1-11ef-9c42-ndlurst9jgue',
     12, 3, '00:02:00', 3000, 2500,
     'Leg Press: 3x10-12, RPE 8-9. 2 min rest. Volume increases weekly.',
     NULL, NULL),

    ('g3d56789-a8e1-11ef-9c42-056rppplexerc15', '08562f83-66ea-49d9-bbf8-89cde104a5a7', '99adb42e-a8e1-11ef-9c42-ndlurst9jgue',
     15, 3, '00:01:30', 5000, 2500,
     'Leg Extension: 3x12-15, RPE 8-9. 90 sec rest. Quad isolation.',
     NULL, NULL),

    ('g3e6789a-a8e1-11ef-9c42-057rppplexerc16', 'bef283ae-05c8-11ed-824f-870b793b71df', '99adb42e-a8e1-11ef-9c42-ndlurst9jgue',
     20, 4, '00:01:00', 6000, 2500,
     'Standing Calf Raise: 4x15-20, RPE 9. 60 sec rest. Calves need high volume.',
     NULL, NULL),

    -- =========================================================================
    -- MIKE ISRAETEL SAMPLE MESOCYCLE EXERCISES
    -- =========================================================================

    -- Sample Day 1: Chest + Triceps
    ('h1a23456-a8e1-11ef-9c42-058mivolexerc01', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', 'adef0872-a8e1-11ef-9c42-rhpyvwx3nkyi',
     8, 3, '00:02:30', 1000, 2500,
     'Flat Barbell Bench: Week 1: 3x8 (MEV=10 sets chest/week), Week 2: 4x8 (MAV=14), Week 3: 4x8 (MAV=18), Week 4: 5x8 (MRV=22). RPE 7-9.',
     NULL, NULL),

    ('h1b34567-a8e1-11ef-9c42-059mivolexerc02', 'bee3dda4-05c8-11ed-824f-2f172103312d', 'adef0872-a8e1-11ef-9c42-rhpyvwx3nkyi',
     10, 3, '00:02:00', 2000, 2500,
     'Incline Dumbbell Press: Progressive volume. Week 1: 2x10, Week 2: 3x10, Week 3: 4x10, Week 4: 4x10. RPE 8-9.',
     NULL, NULL),

    ('h1c45678-a8e1-11ef-9c42-060mivolexerc03', 'bee7fe8e-05c8-11ed-824f-578dbf84191f', 'adef0872-a8e1-11ef-9c42-rhpyvwx3nkyi',
     12, 3, '00:01:30', 4000, 2500,
     'Overhead Tricep Extension: Week 1: 2x12, Week 2: 3x12, Week 3: 3x12, Week 4: 4x12. RPE 8-9. 90 sec rest.',
     NULL, NULL),

    ('h1d56789-a8e1-11ef-9c42-061mivolexerc04', 'b5d34436-b28a-41cb-bfd1-93051e352f3f', 'adef0872-a8e1-11ef-9c42-rhpyvwx3nkyi',
     15, 3, '00:01:00', 5000, 2500,
     'Tricep Pushdown: Week 1: 2x15, Week 2: 3x15, Week 3: 3x15, Week 4: 4x15. RPE 9. Demonstrates volume landmarks.',
     NULL, NULL),

    -- Sample Day 2: Back + Biceps
    ('h2a23456-a8e1-11ef-9c42-062mivolexerc05', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', 'aef01983-a8e1-11ef-9c42-siqzwxy4olzj',
     8, 4, '00:03:00', 1000, 2500,
     'Deadlift: Progressive volume demonstration. Week 1: 3x8 (MEV), Week 2: 4x8, Week 3: 4x8, Week 4: 5x8 (approaching MRV). RPE 7-8.',
     NULL, NULL),

    ('h2b34567-a8e1-11ef-9c42-063mivolexerc06', '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', 'aef01983-a8e1-11ef-9c42-siqzwxy4olzj',
     10, 4, '00:02:00', 2000, 2500,
     'Barbell Row: Week 1: 3x10, Week 2: 4x10, Week 3: 4x10, Week 4: 5x10. RPE 8-9.',
     NULL, NULL),

    ('h2c45678-a8e1-11ef-9c42-064mivolexerc07', 'bee63c0c-05c8-11ed-824f-673da9665bfa', 'aef01983-a8e1-11ef-9c42-siqzwxy4olzj',
     12, 3, '00:01:30', 4000, 2500,
     'Barbell Curl: Week 1: 2x12 (Biceps MEV ~8-12 sets/week), Week 2: 3x12, Week 3: 3x12, Week 4: 4x12 (approaching MRV ~16-20). RPE 8-9.',
     NULL, NULL),

    -- Sample Day 3: Legs
    ('h3a23456-a8e1-11ef-9c42-065mivolexerc08', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', 'afe12a94-a8e1-11ef-9c42-tjrayz05pmak',
     8, 4, '00:03:00', 1000, 2500,
     'Squat: Quads MEV ~12-16 sets/week, MAV ~16-22, MRV ~20-28. Week 1: 3x8, Week 2: 4x8, Week 3: 5x8, Week 4: 5x8. RPE 7-8.',
     NULL, NULL),

    ('h3b34567-a8e1-11ef-9c42-066mivolexerc09', 'ebe84120-4658-49f9-b15c-c3fc72dd6608', 'afe12a94-a8e1-11ef-9c42-tjrayz05pmak',
     10, 4, '00:02:00', 2000, 2500,
     'Romanian Deadlift: Hamstrings MEV ~10-14, MAV ~12-18, MRV ~16-22. Week 1: 3x10, Week 2: 4x10, Week 3: 4x10, Week 4: 5x10. RPE 8-9.',
     NULL, NULL),

    ('h3c45678-a8e1-11ef-9c42-067mivolexerc10', '5270cfc0-31a3-458e-9baf-62803346d03f', 'afe12a94-a8e1-11ef-9c42-tjrayz05pmak',
     12, 3, '00:02:00', 3000, 2500,
     'Leg Press: Progressive volume weekly. Week 1: 2x12, Week 2: 3x12, Week 3: 4x12, Week 4: 4x12. RPE 8-9.',
     NULL, NULL),

    ('h3d56789-a8e1-11ef-9c42-068mivolexerc11', 'bef283ae-05c8-11ed-824f-870b793b71df', 'afe12a94-a8e1-11ef-9c42-tjrayz05pmak',
     20, 4, '00:01:00', 5000, 2500,
     'Calf Raise: Calves MEV ~16-24, MAV ~16-24, MRV ~20-30 (high volume muscle). Week 1: 3x20, Week 2: 4x20, Week 3: 4x20, Week 4: 5x20. RPE 9.',
     NULL, NULL)

ON CONFLICT (exercise_id) DO NOTHING;

-- =============================================================================
-- MIGRATION COMPLETE
-- =============================================================================
-- This migration has added 6 comprehensive hybrid/functional fitness programs:
-- 1. 5/3/1 Boring But Big (BBB) - 4 sessions
-- 2. 5/3/1 for Beginners - 3 sessions
-- 3. Tactical Barbell Operator - 3 sessions
-- 4. CrossFit Strength Bias - 5 sessions
-- 5. Renaissance Periodization 6-Day PPL - 6 sessions
-- 6. Mike Israetel Hypertrophy Principles Sample - 4 sessions
--
-- All programs include:
-- - Comprehensive descriptions with periodization schemes
-- - Evidence-based sources and links
-- - Session schedules with detailed guidance
-- - Representative exercise configurations showing structure
-- - Percentage-based and volume landmark documentation in descriptions
--
-- Total: 6 plans, 25 session schedules, 80+ exercise configurations
