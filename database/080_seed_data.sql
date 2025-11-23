-- Seed data for exercises, plans, and programs
-- This migration adds base exercises, workout plans, sessions, and exercise configurations
-- Data is only inserted if not already present (using ON CONFLICT DO NOTHING)

-- =============================================================================
-- PLANS (Workout Programs)
-- =============================================================================
INSERT INTO plan (plan_id, name, description, links, data)
VALUES
    (
        'bee1b196-05c8-11ed-824f-336037917fbc',
        'Julian Plan A',
        'If your arms are already as muscular [as these](https://assets.website-files.com/54a5a40be53a05f34703dd18/5793f75a0ad17d3c2b64c172_https-%252F%252Fd2mxuefqeaa7sj.cloudfront.net%252Fs_47BA25183F58123E5E1B386359348E6870986C628A36A91739F8545AFA7EFAAB_1468603592749_Male%2BPart-way%2BBody%2BTarget.jpg), you can skip exercise Plan A to start with the intermediate Plan B detailed momentarily.

Otherwise, even if you''ve lifted before, start with exercise Plan A.

Plan A entails of hitting each muscle group once per workout. It''s a starter plan without barbell squats and deadlifts, because these exercises can intimidate beginners from completing workouts. They''re also harder to do at home with just dumbbells.

And the point of this ramp-up period is to get you acclimated to working out with as few excuses as possible. I want you to build the habit of working out — so that it sticks.

(Barbell squats and deadlifts, however, do become critical in the intermediate plan you quickly transition to.)

For your first two months of working out, your inexperienced muscles will grow efficiently even with the lesser stimulus of starter Plan A. In other words, Plan A will produce the same results as the more intensive Plan B while requiring less effort and less time. This means you''re more likely to complete this program.

Eventually Plan A will stop producing size gains for you. When you fail to measure size gains on your arms after a week of working out on Plan A, switch to Plan B.

Gains on Plan A should stall around 8 weeks in if you''re properly following all the advice in this handbook. If the stall occurs sooner than 6 weeks, and you haven''t worked out extensively in the past year, you may be prematurely plateauing and should refer to the overcoming plateaus section at the bottom of the [cheat sheet](https://www.julian.com/guide/muscle/workout-plans#workout-plans).',
        ARRAY['https://www.julian.com/guide/muscle/workout-plans#plan-a-exercises', 'https://www.julian.com/guide/muscle/workout-plans#workout-plans'],
        NULL
    ),
    (
        '1a7118d6-31ba-11ed-aa8c-5bb53b47cd80',
        'Julian Plan B',
        'At the 8 week mark, your muscles will likely need greater stress to continue growing. So we change a few things:

- We increase the sets per exercise from 3 to 4.
- We switch to exercises that allow us to scale to heavier weights.
- We focus on specific muscles within each workout.
- Since exercise Plan B is more intense, we rest for 4 days between workout day **types**.

You can do all three workout types on back-to-back days if desired. But you must take 4 days of rest before repeating a day type. For example, you can do Day 1 on Monday, Day 2 on Tuesday, and Day 3 on Wednesday, but you have to wait until Friday to repeat Day 1, Saturday to repeat Day 2, and Sunday to repeat day 3.

There are no exceptions—even if your muscles "feel fine." If you wind up overworking your muscles, you can lose an entire workout''s worth of size gains. (You can try proving this to yourself if you''re feeling bold and measure closely.)

Here''s Plan B. As with Plan A, B exercises are chosen according to the criteria [here](https://www.julian.com/guide/muscle/workout-plans#exercise-selection) and [here](https://www.julian.com/guide/muscle/workout-plans#why-missing-exercises).

The order of exercises and workout days in Plan B is critical. Don''t rearrange them or you''ll risk not having the strength to complete all your sets.

The exercises are ordered to allow your muscles adequate recovery time so that exhaustion from one exercise doesn''t make it difficult to perform another that reuses a muscle group. (For example, you use your biceps when performing back exercises. So, avoid doing a back exercise right after a bicep exercise.)

One of the unique aspects of this program is how Plan B splits some exercises into two sessions per workout. Meaning, 2 sets of one exercise are performed at the beginning of a workout and the remaining 2 sets are performed at the end. (Read more [here](https://www.julian.com/guide/muscle/workout-plans#rest-times).)

Notes for exercise Plan B:

- The exercises in Plan B will require gym equipment, so if you''ve been working out from home, now''s the time to get into the gym. (Or, buy bigger at-home equipment if you have the room, motivation, and money. Something like [Tonal](http://tonal.com/) might get you partway there if you''re short on space.)
- You no longer have to do grip exercises if you don''t want to. Your grip strength should likely remain strong enough since you''ll be using it to lift heavy barbells now.',
        ARRAY['https://www.julian.com/guide/muscle/workout-plans#plan-b-exercises', 'https://www.julian.com/guide/muscle/workout-plans#workout-plans'],
        NULL
    ),
    (
        'dd92d5d4-4bc2-11ee-9095-778a89bd850c',
        'Unknown',
        NULL,
        NULL,
        NULL
    ),
    (
        '284d5466-dc9e-11ee-b3ef-4f07580c7c92',
        'Minimal program',
        'A minimal program based on advice from Jeff Nippards YouTube channel. The goal is to keep workouts under 45 minutes while maximising quality of those workouts using science based backing.

The program can be run anywnere from 2-5x per week.
12 week program length in 3 blocks.

Training day adaptaitions.
- 2 days / week
  - Full body split
  - Rest in between
- 3 days / week
  - Full body
  - Rest
  - Upper
  - Rest
  - Lower
- 4 days / week
  - Upper / Lower Split
  - Upper
  - Lower
  - Rest
  - Upper
  - Lower
- 5 days / week
  - Upper / Lower / PPL Split
  - Upper
  - Lower
  - Rest
  - Push
  - Pull
  - Legs
  - Rest',
        ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M'],
        NULL
    ),
    (
        '0288137a-70f9-11ef-bc64-4716ce67b981',
        'Barbell program',
        'Not really a program but rather just a collection of barbell exercises.
I use this as a powerlifting complement to my regular program.
I usually delete any exercise I don''t use.',
        NULL,
        NULL
    )
ON CONFLICT (plan_id) DO NOTHING;

-- =============================================================================
-- SESSION SCHEDULES (Workout Days/Sessions within Programs)
-- =============================================================================
INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit, links, data)
VALUES
    ('bee31900-05c8-11ed-824f-872e5282eee7', 'bee1b196-05c8-11ed-824f-336037917fbc', 'Day 1', NULL, 0.8, ARRAY['https://www.julian.com/guide/muscle/workout-plans#plan-a-exercises'], NULL),
    ('bef0b786-05c8-11ed-824f-c7108ba9ec59', 'bee1b196-05c8-11ed-824f-336037917fbc', 'Day 2', NULL, 0.8, NULL, NULL),
    ('befb3d3c-05c8-11ed-824f-eb993d0847d1', 'bee1b196-05c8-11ed-824f-336037917fbc', 'Day 3', NULL, 0.8, NULL, NULL),
    ('1a8dd67e-31ba-11ed-aa8c-cf1406502216', '1a7118d6-31ba-11ed-aa8c-5bb53b47cd80', 'Biceps, triceps, back', NULL, 1.0, NULL, NULL),
    ('1a73b686-31ba-11ed-aa8c-7f85836d1fff', '1a7118d6-31ba-11ed-aa8c-5bb53b47cd80', 'Chest, shoulders, abs', NULL, 1.0, ARRAY['https://www.julian.com/guide/muscle/workout-plans#plan-b-exercises'], NULL),
    ('1a81e990-31ba-11ed-aa8c-d3d6b6992450', '1a7118d6-31ba-11ed-aa8c-5bb53b47cd80', 'Legs, pickup', NULL, 1.0, NULL, NULL),
    ('e84522a2-4bc2-11ee-ae1a-074a37956741', 'dd92d5d4-4bc2-11ee-9095-778a89bd850c', 'Unknown', 'For excercises not belonging to a schedule', 1.0, NULL, NULL),
    ('285cdb34-dc9e-11ee-b3ef-1f58823052c0', '284d5466-dc9e-11ee-b3ef-4f07580c7c92', 'Full Body Day 1', NULL, 1.0, NULL, NULL),
    ('296beb5a-dc9e-11ee-b3ef-978e1fe7d3aa', '284d5466-dc9e-11ee-b3ef-4f07580c7c92', 'Full Body Day 2', NULL, 1.0, ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=405s'], NULL),
    ('2a577bf6-dc9e-11ee-b3ef-efb146b04eee', '284d5466-dc9e-11ee-b3ef-4f07580c7c92', 'Upper', NULL, 1.0, NULL, NULL),
    ('2afec44c-dc9e-11ee-b3ef-c7f6e8c29dde', '284d5466-dc9e-11ee-b3ef-4f07580c7c92', 'Lower', NULL, 1.0, NULL, NULL),
    ('0299d4c0-70f9-11ef-bc64-435fb303af94', '0288137a-70f9-11ef-bc64-4716ce67b981', 'Full barbell', NULL, 1.0, NULL, NULL)
ON CONFLICT (session_schedule_id) DO NOTHING;

-- =============================================================================
-- BASE EXERCISES (Exercise Library)
-- =============================================================================
INSERT INTO base_exercise (base_exercise_id, name, description, links, data, aliases)
VALUES

    ('bee3dda4-05c8-11ed-824f-2f172103312d', 'Dumbbell incline press', 'Do not bring your elbows below chest level.', ARRAY['https://vimeo.com/177967959'], NULL, ARRAY['Incline dumbbell press', 'DB incline press', 'Incline DB press']),
    ('bee63c0c-05c8-11ed-824f-673da9665bfa', 'Bicep curl', 'Keep your elbow still by your side. Slowly resist the lowering movement.', ARRAY['https://vimeo.com/177968823'], NULL, NULL),
    ('bee9b35a-05c8-11ed-824f-2f4f7d99bb13', 'Front raise', 'Do not raise much higher than perpendicular. Do not swing or build momentum.', ARRAY['https://vimeo.com/177969758'], NULL, NULL),
    ('beeb65a6-05c8-11ed-824f-0381614aaa56', 'Dumbbell squat', 'Listen to the advice <a target="_blank" href="https://www.youtube.com/watch?v=MeIiIdhvXT4&amp;feature=youtu.be&amp;t=1m6s">in this video</a> to learn proper form.', ARRAY['https://vimeo.com/177970342'], NULL, NULL),
    ('beed0910-05c8-11ed-824f-93404b8cc033', 'Hanging leg raise †', 'Do this exercise with a dumbbell between your feet. Follow the advice <a target="_blank" href="https://www.youtube.com/watch?v=BI7wrB3Crsc&amp;feature=youtu.be&amp;t=0m16s">in this video</a>.', ARRAY['https://vimeo.com/39560703'], NULL, NULL),
    ('beef158e-05c8-11ed-824f-93940690d5f2', 'Forearm curl up (25 reps)', 'Lift slowly. Do not expect much range of motion.', ARRAY['https://vimeo.com/177970644'], NULL, NULL),
    ('bef1149c-05c8-11ed-824f-3b537fb5b4ee', 'Dumbbell romanian deadlift', 'Listen to the advice <a target="_blank" href="https://www.youtube.com/watch?v=FQKfr1YDhEk&amp;feature=youtu.be&amp;t=22s">in this video</a> to learn proper form.', ARRAY['https://vimeo.com/177971032'], NULL, NULL),
    ('bef283ae-05c8-11ed-824f-870b793b71df', 'Calf raise', 'Lift slowly and squeeze your calf at the top of the movement.', ARRAY['https://vimeo.com/177971348'], NULL, NULL),
    ('bef4006c-05c8-11ed-824f-0fb53f8f059b', 'Shrug', 'Raise up high up as you can comfortably go.', ARRAY['https://vimeo.com/177971664'], NULL, NULL),
    ('bef59bde-05c8-11ed-824f-efb3c762cda1', 'Seated pulley row †', 'Do not use your biceps to pull — only your back. Pull as far as comfortably possible.', ARRAY['https://vimeo.com/178042607'], NULL, ARRAY['Seated cable row', 'Cable row', 'Seated row']),
    ('bef6fb96-05c8-11ed-824f-d7ac01edbd91', 'Lat pulldown †', 'Do not use your biceps to pull — only your back. Pull as far as comfortably possible.', ARRAY['https://vimeo.com/164080300'], NULL, NULL),
    ('bef85388-05c8-11ed-824f-cbc3b1aa33b1', 'Dumbbell shoulder press', 'Keep shoulders in their sockets. Do not arch your back.', ARRAY['https://vimeo.com/151248907'], NULL, NULL),
    ('bef9dc76-05c8-11ed-824f-b7b754c48d13', 'Forearm curl in', 'If you have difficulty increasing weight, increase your grip strength using hand grippers.', ARRAY['https://vimeo.com/178047269'], NULL, NULL),
    ('befb92aa-05c8-11ed-824f-4fae132ce8f0', 'Dumbbell press', 'Do not bring your elbows below chest level.', ARRAY['https://vimeo.com/178048727'], NULL, NULL),
    ('beffe7ba-05c8-11ed-824f-9709e8cc6573', 'Floor crunch', 'Return to the floor slowly; do not let gravity do the work for you.', ARRAY['https://vimeo.com/178050912'], NULL, NULL),
    ('bf01445c-05c8-11ed-824f-2717dcea2d76', 'Forearm curl back', 'If you have difficulty increasing weight, increase your grip strength using hand grippers.', ARRAY['https://vimeo.com/178047269'], NULL, NULL),
    ('1a79785a-31ba-11ed-aa8c-974677efc245', 'Pulley crunch', 'Return to the starting position slowly; do not let the rope''s tension do the lifting.', ARRAY['https://vimeo.com/178052126'], NULL, NULL),
    ('1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', 'Overhead press', 'Keep your back straight. Don''t lock your arms at the top of the motion.', ARRAY['https://vimeo.com/96081016'], NULL, NULL),
    ('1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', 'Squat', 'Listen to the advice [in this video](https://www.youtube.com/watch?v=SW_C1A-rejs&feature=youtu.be&t=1m04s) to learn proper form.', ARRAY['https://vimeo.com/178056008'], NULL, NULL),
    ('1a845edc-31ba-11ed-aa8c-770957cf1770', 'Oblique twist', 'Rotate as far as comfortably possible. Return slowly; do not let the pulley do the work.', ARRAY['https://vimeo.com/178079508'], NULL, NULL),
    ('1a88e6b4-31ba-11ed-aa8c-8bb194e2b67f', 'Hamstring curl', 'Lift slowly. Do not overextend your knees (joints); watch for discomfort.', ARRAY['https://vimeo.com/164443477'], NULL, ARRAY['Leg curl', 'Lying leg curl', 'Seated leg curl']),
    ('1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', 'Deadlift', 'Listen to the advice [in this video](https://www.youtube.com/watch?v=JCXUYuzwNrM&feature=youtu.be&t=1m25s) to learn proper form.', ARRAY['https://vimeo.com/178056325'], NULL, NULL),
    ('1a909be8-31ba-11ed-aa8c-733b86de1deb', 'Julian tricep extension', 'Pad your back with a folded yoga mat between you and the machine.', ARRAY['https://vimeo.com/177969524'], NULL, NULL),
    ('1a953284-31ba-11ed-aa8c-032e2bd7ee19', 'Forearm curl up', 'Lift slowly. Do not expect much range of motion.', ARRAY['https://vimeo.com/177970644'], NULL, NULL),
    ('a34d401c-4bc2-11ee-8c75-a75e6f336c22', 'Machine crunch', NULL, NULL, NULL, NULL),
    ('a3532824-4bc2-11ee-8c75-ebab3389e058', 'Lateral raise', NULL, NULL, NULL, NULL),
    ('28647506-dc9e-11ee-b3ef-5fa33cfe2e29', 'Flat dumbbell press heavy', 'First set heavy 4-6', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=38s'], NULL, NULL),
    ('2885f762-dc9e-11ee-b3ef-0fa909073fa5', 'Flat dumbbell press backoff', 'Second set back-off: 8-10', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=38s'], NULL, NULL),
    ('28a6d306-dc9e-11ee-b3ef-ff4dc2fcf322', 'Dumbbell romainain deadlift', 'Two sets 8-10, can use barbell but less time efficient', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=102s'], NULL, NULL),
    ('28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50', 'Lat pulldown', 'Two sets 10-12, first set overhand middle grip, second set underhand close grip. End with overhead curls', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=150s'], NULL, NULL),
    ('28e81f6e-dc9e-11ee-b3ef-5b9f8379af2d', 'Dumbbell step up', '1x8-10. One leg at a time, use straps', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=175s'], NULL, ARRAY['Step-ups', 'Step ups', 'DB step ups']),
    ('292952c2-dc9e-11ee-b3ef-bb9c1105deaa', 'Machine lateral raise', '1x12-15 + dropset, 30% reduction', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=297s'], NULL, NULL),
    ('294b4bca-dc9e-11ee-b3ef-bb47280d67c5', 'Leg press toe-press', '1x12-15. Seated is quicker but calf raise works. Dropset 30-40%, 1 sec pause at bottom.', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=355s'], NULL, NULL),
    ('29733bd0-dc9e-11ee-b3ef-0789357bba52', 'Hack squat heavy', '1x4-6 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=405s'], NULL, NULL),
    ('2993acda-dc9e-11ee-b3ef-cf7bc31697d6', 'Hack squat backoff', '1x8-10 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=405s'], NULL, NULL),
    ('29d5069e-dc9e-11ee-b3ef-574f7b65abee', 'T-Bar row', '1x10-12, superset with prev, can also reverse and run dumbbell row', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=483s'], NULL, ARRAY['T-Bar rows', 'T bar row']),
    ('29089d70-dc9e-11ee-b3ef-3b403f46b72b', 'Overhead cable tricep extension', 'One sets 12-15', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=227s'], NULL, NULL),
    ('1a758ec0-31ba-11ed-aa8c-93f957060fad', 'Incline chest press', 'Use just a slight incline. Listen to the advice [in this video](https://www.youtube.com/watch?v=rT7DgCr-3pg&feature=youtu.be&t=52s) to learn proper form.', ARRAY['https://vimeo.com/178057019'], NULL, ARRAY['Incline bench press']),
    ('29f5bc5e-dc9e-11ee-b3ef-c7aa53eb5778', 'Seated leg curl', '1x10-12 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=444s'], NULL, NULL),
    ('2a163cfe-dc9e-11ee-b3ef-575801647e7d', 'EZ-bar bicep curl', '1x12-15 + myoreps, supinated grip', ARRAY['https://youtu.be/eMjyvIQbn9M?t=577'], NULL, NULL),
    ('02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', 'Barbell Row', NULL, NULL, NULL, ARRAY['Bent-over row', 'Bent over barbell row', 'BB row']),
    ('29b44c42-dc9e-11ee-b3ef-53720d6ec33a', 'High incline smith press', '1x10-12, almost overhead 45-60°, superset with next', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=483s'], NULL, NULL),
    ('bee7fe8e-05c8-11ed-824f-578dbf84191f', 'Overhead tricep extension', 'On the way back up, extend your arms fully to feel the burn in your tricep.', ARRAY['https://vimeo.com/178050262'], NULL, ARRAY['Dumbbell overhead tricep extension''']),
    ('02a1a38a-70f9-11ef-bc64-d72b6479cb97', 'Bench press', NULL, NULL, NULL, ARRAY['Chest press']),
    ('2a36d342-dc9e-11ee-b3ef-77b99b9dab02', 'Cable crunch', 'Return to the starting position slowly; do not let the rope''s tension do the lifting.', ARRAY['https://vimeo.com/178052126', 'https://youtu.be/eMjyvIQbn9M?t=612'], NULL, ARRAY['Pulley crunch']),

    -- Top 10 Most Critical Exercises (Added 2025-11-22)
    ('ebb32783-f125-4242-a0ad-17912534d844', 'Pull-ups', 'Essential bodyweight pulling movement. Keep your core tight and pull until chin is over the bar. Lower with control.', NULL, NULL, ARRAY['Pullup', 'Pull up']),
    ('b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac', 'Chin-ups', 'Bodyweight pulling movement with supinated (underhand) grip. Pull until chin is over the bar.', NULL, NULL, ARRAY['Chinup', 'Chin up']),
    ('10845aff-07ac-4359-a8dd-ce99442e33d5', 'Front Squat', 'Key squat variation for quad development. Keep torso upright, elbows high. Bar rests on front delts.', NULL, NULL, ARRAY['Front squat barbell']),
    ('2659f231-981f-4f2f-ba3f-1e4fa12728bc', 'Dips', 'Essential bodyweight pressing movement. Lean forward slightly for chest emphasis, stay upright for triceps. Lower until upper arms are parallel to ground.', NULL, NULL, ARRAY['Bodyweight dips', 'Weighted dips', 'Chest dips', 'Tricep dips']),
    ('ebe84120-4658-49f9-b15c-c3fc72dd6608', 'Romanian Deadlift', 'Critical hamstring and posterior chain builder. Keep bar close to legs, slight knee bend, hinge at hips. Focus on hamstring stretch.', NULL, NULL, ARRAY['Barbell romanian deadlift', 'RDL', 'Barbell RDL']),
    ('5270cfc0-31a3-458e-9baf-62803346d03f', 'Leg Press', 'Primary machine-based leg builder. Place feet shoulder-width apart, lower until knees reach 90 degrees. Drive through heels.', NULL, NULL, ARRAY['Machine leg press', '45 degree leg press']),
    ('34bd3f09-0a5a-480b-b450-746b1e5c7274', 'Face Pulls', 'Critical rear delt and upper back health exercise. Pull rope to face level, focus on external rotation at peak contraction.', NULL, NULL, ARRAY['Cable face pulls', 'Rope face pulls']),
    ('b5d34436-b28a-41cb-bfd1-93051e352f3f', 'Tricep Pushdowns', 'Essential tricep isolation. Keep elbows pinned at sides, push down with control, squeeze triceps at bottom.', NULL, NULL, ARRAY['Cable pushdowns', 'Tricep pushdown', 'Cable tricep extensions', 'Rope pushdowns']),
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b', 'Power Clean', 'Key power development exercise. Explosive hip extension, catch in front rack position. Technical lift requiring proper coaching.', NULL, NULL, ARRAY['Barbell power clean', 'Clean']),

    -- Remaining High Priority Exercises (Used in 3-4 programs)
    ('08562f83-66ea-49d9-bbf8-89cde104a5a7', 'Leg Extension', 'Quad isolation exercise. Extend legs fully and squeeze at top. Control the negative.', NULL, NULL, ARRAY['Machine leg extension', 'Quad extension']),
    ('cc50696f-1aad-422e-a192-12c9bfd0cc25', 'Dumbbell Row', 'Single-arm horizontal pulling exercise. Support yourself on bench, pull dumbbell to hip. Keep back flat.', NULL, NULL, ARRAY['One-arm dumbbell row', 'Single arm dumbbell row', 'DB row']),
    ('48a24998-5466-4e5c-af83-fc2de2cd6c4c', 'Close-Grip Bench Press', 'Tricep-focused pressing movement. Hands shoulder-width or slightly narrower. Lower to mid-chest.', NULL, NULL, ARRAY['Close grip bench', 'CGBP', 'Narrow grip bench press']),
    ('e4977b90-62d6-4465-b50c-49bd1d6a61be', 'Cable Curls', 'Bicep isolation with constant tension from cables. Keep elbows stationary, curl smoothly.', NULL, NULL, ARRAY['Cable bicep curls', 'Cable curl', 'Low cable curls']),
    ('cad62a1a-538f-408a-95d3-de74f54f6710', 'Hyperextensions', 'Lower back and posterior chain exercise. Hinge at hips, maintain neutral spine throughout.', NULL, NULL, ARRAY['Back extensions', 'Hypers', '45-degree hyperextensions']),
    ('96d6be35-ae4e-4174-872e-c28764998a1a', 'Bulgarian Split Squats', 'Single-leg squat variation. Rear foot elevated, front foot flat. Great for quad and glute development.', NULL, NULL, ARRAY['Bulgarian split squat', 'Rear foot elevated split squat', 'RFESS']),
    ('62fe9884-1c76-4224-af6e-8cd05a17e385', 'Hammer Curls', 'Bicep and brachialis exercise with neutral grip. Keep elbows pinned, curl without rotating wrists.', NULL, NULL, ARRAY['Dumbbell hammer curls', 'Neutral grip curls']),
    ('11dc85bd-96e4-4b57-a0c0-84872acb61c6', 'Good Mornings', 'Hip hinge movement for posterior chain. Bar on upper back, hinge at hips with slight knee bend.', NULL, NULL, ARRAY['Barbell good mornings', 'Good morning']),
    ('e0f8bfdb-4e94-40a4-90e6-b535f3a893fa', 'Box Squats', 'Squat variation where you sit back onto a box. Teaches proper hip hinge, builds explosive power.', NULL, NULL, ARRAY['Barbell box squats', 'Box squat']),
    ('b0507715-5e1a-43cb-9697-0d15e4740ed6', 'Glute-Ham Raise', 'Advanced hamstring and glute exercise. Lower with control, use hamstrings to pull back up.', NULL, NULL, ARRAY['GHR', 'Glute ham raise', 'Nordic curls']),
    ('1e4eee1f-d2fd-4b66-94b7-1de2ac4484c9', 'Dumbbell Flyes', 'Chest isolation exercise. Slight bend in elbows, arc motion, stretch at bottom.', NULL, NULL, ARRAY['Dumbbell fly', 'DB flyes', 'Chest flyes']),
    ('d4cbce8f-0a69-4274-84eb-171bd63c7429', 'Upright Rows', 'Shoulder and trap exercise. Pull bar up along body to chest level. Elbows lead.', NULL, NULL, ARRAY['Barbell upright row', 'Upright row', 'Cable upright rows']),
    ('4be09662-74c5-4b7c-ad35-37848e4248e8', 'Walking Lunges', 'Dynamic lunge variation. Step forward into lunge, drive through heel to next rep. Great for legs and balance.', NULL, NULL, ARRAY['Barbell lunges', 'Barbell walking lunges', 'Dumbbell walking lunges', 'Lunge']),
    ('17724820-ed82-4129-adba-8805a7912b65', 'Rack Pulls', 'Partial deadlift from elevated position. Focus on lockout strength and upper back development.', NULL, NULL, ARRAY['Barbell rack pulls', 'Rack pull']),

    -- Medium Priority Exercises (Used in 2 programs)
    ('72422027-c5dc-4364-bcf7-bc6f37081faa', 'Pendlay Rows', 'Barbell row variation starting from floor each rep. Explosive pull, reset position between reps.', NULL, NULL, ARRAY['Pendlay row', 'Barbell pendlay rows']),
    ('07765c6b-af9d-4637-bfdc-3924a6e0699a', 'Reverse Flyes', 'Rear delt isolation. Bent over or on incline bench, arc dumbbells out to sides.', NULL, NULL, ARRAY['Rear delt flyes', 'Dumbbell reverse flyes', 'Bent over reverse flyes']),
    ('458fcd22-1454-468e-85e1-2ab3f1dcd107', 'Concentration Curls', 'Isolated bicep curl. Seated, elbow braced on inner thigh. Full stretch and contraction.', NULL, NULL, ARRAY['Dumbbell concentration curls', 'Concentration curl']),
    ('fff636b5-bec0-447f-92d1-750aa5dff4d4', 'Lying Tricep Extensions', 'Tricep isolation. Lower bar to forehead or behind head. Keep upper arms stationary.', NULL, NULL, ARRAY['Skullcrushers', 'Skull crushers', 'EZ-bar lying tricep extensions', 'Barbell lying tricep extensions']),
    ('319c7d1d-b56c-4e40-be50-f9fcfc8d971a', 'Stiff-Leg Deadlifts', 'Similar to RDL but with straighter legs. Emphasizes hamstrings and lower back stretch.', NULL, NULL, ARRAY['Stiff leg deadlift', 'Straight leg deadlift variation', 'SLDL']),
    ('913b28dd-6d15-4621-83de-e4804fe6c973', 'Incline Barbell Bench Press', 'Upper chest focus. Bar path to upper chest, 30-45 degree incline.', NULL, NULL, ARRAY['Incline bench press', 'Barbell incline press', 'Incline barbell press']),
    ('cd8d7cdd-7394-4bb6-aba1-684003577483', 'Cable Crossovers', 'Chest fly using cables. Cross hands in front, squeeze pecs at contraction.', NULL, NULL, ARRAY['Cable flyes', 'Incline cable flyes', 'Cable chest flyes', 'High to low cable crossovers']),
    ('b1166ffb-47ca-4d88-8276-9caf893e1367', 'Spider Curls', 'Bicep isolation on incline bench, chest facing down. Eliminates momentum.', NULL, NULL, ARRAY['Spider curl', 'Prone incline curls']),
    ('f75617d8-885d-4aa9-9afe-4e0d01199de9', 'Preacher Curls', 'Bicep isolation with arm braced on preacher bench. Prevents swinging.', NULL, NULL, ARRAY['Preacher curl', 'EZ-bar preacher curls', 'Dumbbell preacher curls', 'Cambered bar preacher curl']),
    ('93d61257-bad8-4c8d-b107-b814140d19c2', 'Incline Dumbbell Curls', 'Bicep exercise on incline bench. Allows greater stretch at bottom position.', NULL, NULL, ARRAY['Incline curls', 'Seated incline dumbbell curl', 'Incline DB curls']),
    ('8d004901-339c-4354-8ca3-28a5ef5432a6', 'Seated Calf Raise', 'Calf isolation targeting soleus. Knees bent at 90 degrees, focus on controlled reps.', NULL, NULL, ARRAY['Seated calf raises', 'Machine seated calf raise']),
    ('9f285bb0-30b3-480a-8acf-f60b892671c2', 'Floor Press', 'Bench press variant from floor. Limited range, emphasizes lockout strength.', NULL, NULL, ARRAY['Barbell floor press', 'Floor bench press']),
    ('47b1b5b3-a404-4dfa-9bd7-967f8f6d2da5', 'Board Press', 'Bench press with boards on chest to limit range. Trains specific sticking points.', NULL, NULL, ARRAY['2-board press', '3-board press', '4-board press', 'Board bench press']),
    ('bb70a47a-a0a9-4259-a74e-fbf2fdd1741d', 'Cable Kickbacks', 'Glute isolation using cable machine. Kick leg back against cable resistance.', NULL, NULL, ARRAY['Cable glute kickbacks', 'Glute kickbacks']),
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b', 'Trap Bar Deadlifts', 'Deadlift using trap/hex bar. More quad-dominant, easier on lower back.', NULL, NULL, ARRAY['Trap bar deadlift', 'Hex bar deadlifts', 'Diamond bar deadlifts']),
    ('056f9388-add7-4df0-9aa8-1fe60fe72944', 'Safety Squat Bar Squats', 'Squat using SSB with forward handles. More upright torso, quad emphasis.', NULL, NULL, ARRAY['SSB squats', 'Safety bar squats', 'Safety squat bar squat']),
    ('cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9', 'Sumo Deadlifts', 'Wide stance deadlift. More hip and quad involvement, less lower back stress.', NULL, NULL, ARRAY['Sumo deadlift', 'Wide stance deadlift']),
    ('fe537e1e-1313-4419-a26f-26adca068352', 'Push Press', 'Overhead press with leg drive. Explosive movement, allows heavier loads than strict press.', NULL, NULL, ARRAY['Barbell push press', 'Push jerk variant']),
    ('b15b673e-1174-45b9-b810-65ca02afd727', 'Pause Squats', 'Squat with pause at bottom. Builds strength out of the hole, eliminates stretch reflex.', NULL, NULL, ARRAY['Pause squat', 'Barbell pause squats', 'Paused squats']),
    ('079ff44e-2dd6-4d48-bf11-a49c3f4e0f45', 'Wide-Grip Bench Press', 'Bench press with hands wider than standard. Emphasizes chest stretch.', NULL, NULL, ARRAY['Wide grip bench', 'Wide bench press']),

    -- Low Priority Exercises (Used in 1 program)
    ('39f0fbb0-f7f8-446e-95e3-eb88e745a7ee', 'Behind-the-Neck Overhead Press', 'Overhead press with bar lowered behind head. Requires good shoulder mobility. Use with caution.', NULL, NULL, ARRAY['BTN press', 'Behind neck press']),
    ('f9abf9ce-fee7-4510-9739-e43272189e2e', 'Bent-Knee Sit-Ups', 'Classic abs exercise. Knees bent, feet anchored. Control the movement, avoid pulling on neck.', NULL, NULL, ARRAY['Sit-ups', 'Bent knee situps']),
    ('3df73c19-9001-4f2e-ae59-4bf185522d57', 'Straight-Leg Deadlifts', 'Deadlift with locked knees. Extreme hamstring stretch. Different from stiff-leg deadlifts.', NULL, NULL, ARRAY['Straight leg deadlift']),
    ('45a46ae8-09d3-4151-8b72-3f434165aade', 'Dumbbell Pullovers', 'Chest and lat exercise. Lying on bench, arc dumbbell overhead. Breathe deeply throughout.', NULL, NULL, ARRAY['DB pullovers', 'Pullover']),
    ('1bd4b3e7-da5e-477b-b2f7-f2b7957baf69', 'Wide-Grip Pull-Ups', 'Pull-up variation with hands wider than shoulders. Emphasizes lats.', NULL, NULL, ARRAY['Wide grip pullups']),
    ('a2a36126-07e2-4104-a1e4-5671484dab17', 'Wrist Curls', 'Forearm isolation. Curl weight with wrists only, forearms supported.', NULL, NULL, ARRAY['Barbell wrist curls', 'Dumbbell wrist curls', 'Reverse wrist curls']),
    ('f02e3ded-bef5-45e7-8364-1b5b0c1b9ee5', 'Machine Chest Press', 'Chest press on machine. Controlled path, good for isolation work.', NULL, NULL, ARRAY['Hammer strength chest press', 'Chest press machine']),
    ('b230fe6e-9f8f-4bdf-9154-2b86f52f36bb', 'Rack Chins', 'Chin-up variation with feet supported on rack. Allows adjustment of difficulty.', NULL, NULL, ARRAY['Rack chin-ups']),
    ('6e908c05-7b15-46e9-8ab5-43628307e828', 'Close-Grip Pulldown', 'Lat pulldown with narrow grip. Emphasizes lat width and biceps.', NULL, NULL, ARRAY['Close grip lat pulldown', 'Narrow grip pulldown']),
    ('345b6f8d-5550-4424-ba81-852399bb6716', 'Cable Pressdown with Rope', 'Tricep pressdown using rope attachment. Allows for better peak contraction.', NULL, NULL, ARRAY['Rope pressdowns', 'Cable rope pressdown']),
    ('7dab1f6e-a886-4888-a397-82ff4a0bea2e', 'Split Squats', 'Single-leg squat without rear foot elevation. Similar to lunge but stationary.', NULL, NULL, ARRAY['Stationary split squats', 'Non-Bulgarian split squats']),
    ('7ae1201f-4995-48fb-9238-c4e018a91bb3', 'Ab Wheel Rollouts', 'Core stability exercise. Roll wheel forward maintaining neutral spine. Very challenging.', NULL, NULL, ARRAY['Ab wheel', 'Ab rollouts', 'Wheel rollouts']),
    ('f36724da-1dba-4516-88ba-2596084c5289', 'Prying Goblet Squat', 'Mobility warm-up. Hold goblet squat position, use elbows to pry knees out.', NULL, NULL, ARRAY['Goblet squat prying']),
    ('75e864ec-c666-4b08-b0b0-794ffb647773', 'Halos', 'Shoulder mobility exercise. Circle kettlebell around head in controlled motion.', NULL, NULL, ARRAY['Kettlebell halos', 'KB halos']),
    ('e4e92a81-f95b-43a4-9510-a44a7bd212f1', 'Hip Bridges', 'Glute activation exercise. Lying on back, drive hips up. Squeeze glutes at top.', NULL, NULL, ARRAY['Glute bridges', 'Bodyweight hip bridge']),
    ('5a3bca2d-b34b-4c97-9d48-5f436c7a21b3', 'Kettlebell Swing (One-Arm)', 'Single-arm kettlebell swing. Explosive hip hinge, ballistic movement.', NULL, NULL, ARRAY['One-arm KB swing', 'Single arm kettlebell swing']),
    ('8a98e6b8-ff15-4c44-999c-f0d19c867b45', 'Turkish Get-Up', 'Complex full-body kettlebell movement. Multiple positions from lying to standing. Requires coaching.', NULL, NULL, ARRAY['TGU', 'Turkish getup', 'Kettlebell get-up']),
    ('5e3749e4-ed93-4a3e-b921-f20d2526f2f7', 'Thruster', 'Front squat to overhead press in one motion. Common in CrossFit. Very demanding.', NULL, NULL, ARRAY['Barbell thruster', 'Squat to press']),
    ('72e02183-5cc1-4ee4-83f9-166611edd1bf', 'Wall Balls', 'Squat with medicine ball, throw to target on wall. Catch and repeat. Cardio and strength.', NULL, NULL, ARRAY['Wall ball shots', 'Medicine ball wall balls']),
    ('a08ae9ef-4819-4612-a32f-a07930d6cdfc', 'Box Jumps', 'Explosive jump onto elevated box. Land softly, step down. Develops power.', NULL, NULL, ARRAY['Box jump', 'Plyometric box jumps']),
    ('81a79bda-b4c5-4615-a3ad-b6264ce0d8eb', 'Burpees', 'Full-body conditioning exercise. Drop to plank, push-up, jump to squat, jump up.', NULL, NULL, ARRAY['Burpee']),
    ('150c4890-e1d3-4c1f-ae85-1c23c0c933c2', 'Handstand Push-ups', 'Advanced bodyweight pressing. Inverted push-up against wall. Requires significant strength.', NULL, NULL, ARRAY['HSPU', 'Handstand pushups', 'Wall handstand push-ups']),
    ('c59ef814-9b83-43c2-9fd9-78946041d8c6', 'Toes-to-Bar', 'Hanging ab exercise. Pull toes to bar using core and hip flexors. Advanced movement.', NULL, NULL, ARRAY['TTB', 'Toes to bar'])
ON CONFLICT (base_exercise_id) DO NOTHING;
-- =============================================================================
-- EXERCISE SET TYPES (Set variations: regular, drop-set, myo-rep, etc.)
-- =============================================================================
INSERT INTO exercise_set_type (name, description, sort_order, has_subset)
VALUES
    ('regular', 'A regular standard set.', 20, false),
    ('pyramid-set', 'A set where you increase the weight after each set.', 50, true),
    ('other', 'A set that does not fit into the other categories.', 80, false),
    ('myo-rep', 'A set where you do a set to failure, rest for a short period, then do another set to failure, and so on.', 40, true),
    ('drop-set', 'A set where you decrease the weight after each set.', 30, true),
    ('AMRAP', 'As many reps as possible.', 70, false),
    ('warm-up', 'A warm-up set.', 10, false),
    ('super-set', 'A set where you do two exercises back to back.', 60, true)
ON CONFLICT (name) DO NOTHING;

-- =============================================================================
-- EXERCISES (Exercise configurations within session schedules)
-- =============================================================================
INSERT INTO exercise (exercise_id, base_exercise_id, session_schedule_id, reps, sets, rest, sort_order, data, step_increment, description, links)
VALUES
    ('3a64ddc0-4bc3-11ee-9fb0-57193db59c57', 'a34d401c-4bc2-11ee-8c75-a75e6f336c22', 'e84522a2-4bc2-11ee-ae1a-074a37956741', 10, 4, '00:05:00', 1000, NULL, 2500, NULL, NULL),
    ('3a6b3e4a-4bc3-11ee-9fb0-337f9cda562f', 'a3532824-4bc2-11ee-8c75-ebab3389e058', 'e84522a2-4bc2-11ee-ae1a-074a37956741', 15, 4, '00:05:00', 1000, NULL, 2500, NULL, NULL),
    ('02b45232-70f9-11ef-bc64-47b4adc522fd', '02a1a38a-70f9-11ef-bc64-d72b6479cb97', '0299d4c0-70f9-11ef-bc64-435fb303af94', 5, 5, '00:03:00', 1000, NULL, 2500, NULL, NULL),
    ('030c4e1a-70f9-11ef-bc64-035079a0ecd9', '02fa4f1c-70f9-11ef-bc64-d71449e2b9ab', '0299d4c0-70f9-11ef-bc64-435fb303af94', 5, 5, '00:03:00', 5000, NULL, 2500, NULL, NULL),
    ('2af0430e-dc9e-11ee-b3ef-1ff015a1e243', '2a36d342-dc9e-11ee-b3ef-77b99b9dab02', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 15, 2, '00:02:00', 9000, NULL, 2500, '1x12-15 + double dropset. ', ARRAY['https://youtu.be/eMjyvIQbn9M?t=612']),
    ('2a48e2c6-dc9e-11ee-b3ef-3b7010537b4a', '2a36d342-dc9e-11ee-b3ef-77b99b9dab02', '296beb5a-dc9e-11ee-b3ef-978e1fe7d3aa', 15, 2, '00:02:00', 7000, NULL, 2500, '1x12-15 + double dropset. ', ARRAY['https://youtu.be/eMjyvIQbn9M?t=612']),
    ('bee73e68-05c8-11ed-824f-8f871dfcd676', 'bee63c0c-05c8-11ed-824f-673da9665bfa', 'bee31900-05c8-11ed-824f-872e5282eee7', 10, 3, '00:05:00', 2000, NULL, 2500, 'Keep your elbow still by your side. Slowly resist the lowering movement.', ARRAY['https://vimeo.com/177968823']),
    ('bee8e60a-05c8-11ed-824f-8fc8463eb8df', 'bee7fe8e-05c8-11ed-824f-578dbf84191f', 'bee31900-05c8-11ed-824f-872e5282eee7', 10, 3, '00:05:00', 3000, NULL, 2500, 'On the way back up, extend your arms fully to feel the burn in your tricep.', ARRAY['https://vimeo.com/178050262']),
    ('beeaa72e-05c8-11ed-824f-af7d74e9c677', 'bee9b35a-05c8-11ed-824f-2f4f7d99bb13', 'bee31900-05c8-11ed-824f-872e5282eee7', 10, 3, '00:05:00', 4000, NULL, 2500, 'Do not raise much higher than perpendicular. Do not swing or build momentum.', ARRAY['https://vimeo.com/177969758']),
    ('beec44bc-05c8-11ed-824f-379501549100', 'beeb65a6-05c8-11ed-824f-0381614aaa56', 'bee31900-05c8-11ed-824f-872e5282eee7', 10, 3, '00:05:00', 5000, NULL, 2500, 'Listen to the advice <a target="_blank" href="https://www.youtube.com/watch?v=MeIiIdhvXT4&amp;feature=youtu.be&amp;t=1m6s">in this video</a> to learn proper form.', ARRAY['https://vimeo.com/177970342']),
    ('bef1e0d4-05c8-11ed-824f-8b713e555f8e', 'bef1149c-05c8-11ed-824f-3b537fb5b4ee', 'bef0b786-05c8-11ed-824f-c7108ba9ec59', 10, 3, '00:05:00', 1000, NULL, 2500, 'Listen to the advice <a target="_blank" href="https://www.youtube.com/watch?v=FQKfr1YDhEk&amp;feature=youtu.be&amp;t=22s">in this video</a> to learn proper form.', ARRAY['https://vimeo.com/177971032']),
    ('befa9c9c-05c8-11ed-824f-2b16a0a41076', 'bef9dc76-05c8-11ed-824f-b7b754c48d13', 'bef0b786-05c8-11ed-824f-c7108ba9ec59', 15, 3, '00:05:00', 7000, NULL, 2500, 'If you have difficulty increasing weight, increase your grip strength using hand grippers.', ARRAY['https://vimeo.com/178047269']),
    ('befd647c-05c8-11ed-824f-e3d978e58fe7', 'bee63c0c-05c8-11ed-824f-673da9665bfa', 'befb3d3c-05c8-11ed-824f-eb993d0847d1', 10, 3, '00:05:00', 2000, NULL, 2500, 'Keep your elbow still by your side. Slowly resist the lowering movement.', ARRAY['https://vimeo.com/177968823']),
    ('befe3dfc-05c8-11ed-824f-734786ca8dfa', 'bee7fe8e-05c8-11ed-824f-578dbf84191f', 'befb3d3c-05c8-11ed-824f-eb993d0847d1', 10, 3, '00:05:00', 3000, NULL, 2500, 'On the way back up, extend your arms fully to feel the burn in your tricep.', ARRAY['https://vimeo.com/178050262']),
    ('beff4288-05c8-11ed-824f-47afee4d7e0f', 'beeb65a6-05c8-11ed-824f-0381614aaa56', 'befb3d3c-05c8-11ed-824f-eb993d0847d1', 10, 3, '00:05:00', 4000, NULL, 2500, 'Listen to the advice <a target="_blank" href="https://www.youtube.com/watch?v=MeIiIdhvXT4&amp;feature=youtu.be&amp;t=1m6s">in this video</a> to learn proper form.', ARRAY['https://vimeo.com/177970342']),
    ('bf00ac4a-05c8-11ed-824f-7f2e05e94f62', 'beffe7ba-05c8-11ed-824f-9709e8cc6573', 'befb3d3c-05c8-11ed-824f-eb993d0847d1', 10, 3, '00:05:00', 5000, NULL, 2500, 'Return to the floor slowly; do not let gravity do the work for you.', ARRAY['https://vimeo.com/178050912']),
    ('bef4e4b4-05c8-11ed-824f-4bacf255eb1c', 'bef4006c-05c8-11ed-824f-0fb53f8f059b', 'bef0b786-05c8-11ed-824f-c7108ba9ec59', 10, 3, '00:05:00', 3000, NULL, 5000, 'Raise up high up as you can comfortably go.', ARRAY['https://vimeo.com/177971664']),
    ('bef92010-05c8-11ed-824f-5b29ea39efa5', 'bef85388-05c8-11ed-824f-cbc3b1aa33b1', 'bef0b786-05c8-11ed-824f-c7108ba9ec59', 10, 3, '00:05:00', 6000, NULL, 2000, 'Keep shoulders in their sockets. Do not arch your back.', ARRAY['https://vimeo.com/151248907']),
    ('befc5ac8-05c8-11ed-824f-23f9684d2d69', 'befb92aa-05c8-11ed-824f-4fae132ce8f0', 'befb3d3c-05c8-11ed-824f-eb993d0847d1', 10, 3, '00:05:00', 1000, NULL, 5000, 'Do not bring your elbows below chest level.', ARRAY['https://vimeo.com/178048727']),
    ('beee4cbc-05c8-11ed-824f-0f19267f9aa2', 'beed0910-05c8-11ed-824f-93404b8cc033', 'bee31900-05c8-11ed-824f-872e5282eee7', 10, 3, '00:05:00', 6000, NULL, 1000, 'Do this exercise with a dumbbell between your feet. Follow the advice <a target="_blank" href="https://www.youtube.com/watch?v=BI7wrB3Crsc&amp;feature=youtu.be&amp;t=0m16s">in this video</a>.', ARRAY['https://vimeo.com/39560703']),
    ('bef006ce-05c8-11ed-824f-e3ed9ea083f4', 'beef158e-05c8-11ed-824f-93940690d5f2', 'bee31900-05c8-11ed-824f-872e5282eee7', 25, 3, '00:05:00', 7000, NULL, 1000, 'Lift slowly. Do not expect much range of motion.', ARRAY['https://vimeo.com/177970644']),
    ('bf02011c-05c8-11ed-824f-d3fff1a9362e', 'bf01445c-05c8-11ed-824f-2717dcea2d76', 'befb3d3c-05c8-11ed-824f-eb993d0847d1', 15, 3, '00:05:00', 6000, NULL, 1000, 'If you have difficulty increasing weight, increase your grip strength using hand grippers.', ARRAY['https://vimeo.com/178047269']),
    ('bee54342-05c8-11ed-824f-3f82d7ee073a', 'bee3dda4-05c8-11ed-824f-2f172103312d', 'bee31900-05c8-11ed-824f-872e5282eee7', 10, 3, '00:05:00', 1000, NULL, 5000, 'Do not bring your elbows below chest level.', ARRAY['https://vimeo.com/177967959']),
    ('bef3504a-05c8-11ed-824f-af9e13d6145b', 'bef283ae-05c8-11ed-824f-870b793b71df', 'bef0b786-05c8-11ed-824f-c7108ba9ec59', 10, 3, '00:05:00', 2000, NULL, 5000, 'Lift slowly and squeeze your calf at the top of the movement.', ARRAY['https://vimeo.com/177971348']),
    ('1a77dac2-31ba-11ed-aa8c-0b1ee528d7dc', '1a758ec0-31ba-11ed-aa8c-93f957060fad', '1a73b686-31ba-11ed-aa8c-7f85836d1fff', 10, 2, '00:05:00', 1000, NULL, 2500, 'Use just a slight incline. Listen to the advice [in this video](https://www.youtube.com/watch?v=rT7DgCr-3pg&feature=youtu.be&t=52s) to learn proper form.', ARRAY['https://vimeo.com/178057019']),
    ('1a7ad38a-31ba-11ed-aa8c-136caacabbc3', '1a79785a-31ba-11ed-aa8c-974677efc245', '1a73b686-31ba-11ed-aa8c-7f85836d1fff', 10, 4, '00:05:00', 2000, NULL, 2500, 'Return to the starting position slowly; do not let the rope''s tension do the lifting.', ARRAY['https://vimeo.com/178052126']),
    ('1a7cd64e-31ba-11ed-aa8c-a388a9fb14c6', '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', '1a73b686-31ba-11ed-aa8c-7f85836d1fff', 10, 4, '00:05:00', 3000, NULL, 2500, 'Keep your back straight. Don''t lock your arms at the top of the motion.', ARRAY['https://vimeo.com/96081016']),
    ('1a7f6d28-31ba-11ed-aa8c-d34183e96597', '1a758ec0-31ba-11ed-aa8c-93f957060fad', '1a73b686-31ba-11ed-aa8c-7f85836d1fff', 10, 2, '00:05:00', 5000, NULL, 2500, 'Use just a slight incline. Listen to the advice [in this video](https://www.youtube.com/watch?v=rT7DgCr-3pg&feature=youtu.be&t=52s) to learn proper form.', ARRAY['https://vimeo.com/178057019']),
    ('1a836c70-31ba-11ed-aa8c-37e21534b9fe', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '1a81e990-31ba-11ed-aa8c-d3d6b6992450', 10, 4, '00:05:00', 1000, NULL, 2500, 'Listen to the advice [in this video](https://www.youtube.com/watch?v=SW_C1A-rejs&feature=youtu.be&t=1m04s) to learn proper form.', ARRAY['https://vimeo.com/178056008']),
    ('1a857c90-31ba-11ed-aa8c-d33d50b88f74', '1a845edc-31ba-11ed-aa8c-770957cf1770', '1a81e990-31ba-11ed-aa8c-d3d6b6992450', 10, 4, '00:05:00', 2000, NULL, 2500, 'Rotate as far as comfortably possible. Return slowly; do not let the pulley do the work.', ARRAY['https://vimeo.com/178079508']),
    ('1a869012-31ba-11ed-aa8c-fbda1150dff6', 'bef4006c-05c8-11ed-824f-0fb53f8f059b', '1a81e990-31ba-11ed-aa8c-d3d6b6992450', 10, 4, '00:05:00', 3000, NULL, 2500, 'Raise up high up as you can comfortably go.', ARRAY['https://vimeo.com/177971664']),
    ('1a8a0198-31ba-11ed-aa8c-0702550a983a', '1a88e6b4-31ba-11ed-aa8c-8bb194e2b67f', '1a81e990-31ba-11ed-aa8c-d3d6b6992450', 10, 3, '00:05:00', 5000, NULL, 2500, 'Lift slowly. Do not overextend your knees (joints); watch for discomfort.', ARRAY['https://vimeo.com/164443477']),
    ('1a8bf480-31ba-11ed-aa8c-8f842551e6b4', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '1a81e990-31ba-11ed-aa8c-d3d6b6992450', 10, 4, '00:05:00', 6000, NULL, 2500, 'Listen to the advice [in this video](https://www.youtube.com/watch?v=JCXUYuzwNrM&feature=youtu.be&t=1m25s) to learn proper form.', ARRAY['https://vimeo.com/178056325']),
    ('1a8d0cee-31ba-11ed-aa8c-fb83ddbc78b9', 'bef9dc76-05c8-11ed-824f-b7b754c48d13', '1a81e990-31ba-11ed-aa8c-d3d6b6992450', 15, 4, '00:05:00', 7000, NULL, 2500, 'If you have difficulty increasing weight, increase your grip strength using hand grippers.', ARRAY['https://vimeo.com/178047269']),
    ('2b3c9204-dc9e-11ee-b3ef-eb2eb576b9c7', '29733bd0-dc9e-11ee-b3ef-0789357bba52', '2afec44c-dc9e-11ee-b3ef-c7f6e8c29dde', 6, 1, '00:02:00', 4000, NULL, 2500, '1x4-6 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=405s']),
    ('1a91a402-31ba-11ed-aa8c-2b0e8f614651', '1a909be8-31ba-11ed-aa8c-733b86de1deb', '1a8dd67e-31ba-11ed-aa8c-cf1406502216', 10, 2, '00:05:00', 3000, NULL, 2500, 'Pad your back with a folded yoga mat between you and the machine.', ARRAY['https://vimeo.com/177969524']),
    ('1a92e04c-31ba-11ed-aa8c-cf89c31d02f5', 'bee63c0c-05c8-11ed-824f-673da9665bfa', '1a8dd67e-31ba-11ed-aa8c-cf1406502216', 10, 2, '00:05:00', 4000, NULL, 2500, 'Keep your elbow still by your side. Slowly resist the lowering movement.', ARRAY['https://vimeo.com/177968823']),
    ('1a944446-31ba-11ed-aa8c-ef3e308144cf', '1a909be8-31ba-11ed-aa8c-733b86de1deb', '1a8dd67e-31ba-11ed-aa8c-cf1406502216', 10, 2, '00:05:00', 5000, NULL, 2500, 'Pad your back with a folded yoga mat between you and the machine.', ARRAY['https://vimeo.com/177969524']),
    ('1a97b72a-31ba-11ed-aa8c-e75911621002', 'bee63c0c-05c8-11ed-824f-673da9665bfa', '1a8dd67e-31ba-11ed-aa8c-cf1406502216', 10, 2, '00:05:00', 7000, NULL, 2500, 'Keep your elbow still by your side. Slowly resist the lowering movement.', ARRAY['https://vimeo.com/177968823']),
    ('1a98e848-31ba-11ed-aa8c-9356ae62d3b2', 'bf01445c-05c8-11ed-824f-2717dcea2d76', '1a8dd67e-31ba-11ed-aa8c-cf1406502216', 15, 4, '00:05:00', 8000, NULL, 1000, 'If you have difficulty increasing weight, increase your grip strength using hand grippers.', ARRAY['https://vimeo.com/178047269']),
    ('1a809de2-31ba-11ed-aa8c-cb17f3b56ce6', 'bee9b35a-05c8-11ed-824f-2f4f7d99bb13', '1a73b686-31ba-11ed-aa8c-7f85836d1fff', 10, 4, '00:05:00', 6000, NULL, 1000, 'Do not raise much higher than perpendicular. Do not swing or build momentum.', ARRAY['https://vimeo.com/177969758']),
    ('1a87fb32-31ba-11ed-aa8c-c33abed0d41b', 'bef283ae-05c8-11ed-824f-870b793b71df', '1a81e990-31ba-11ed-aa8c-d3d6b6992450', 10, 4, '00:05:00', 4000, NULL, 5000, 'Lift slowly and squeeze your calf at the top of the movement.', ARRAY['https://vimeo.com/177971348']),
    ('1a965d58-31ba-11ed-aa8c-bf69ed93cfdc', '1a953284-31ba-11ed-aa8c-032e2bd7ee19', '1a8dd67e-31ba-11ed-aa8c-cf1406502216', 15, 4, '00:05:00', 6000, NULL, 1000, 'Lift slowly. Do not expect much range of motion.', ARRAY['https://vimeo.com/177970644']),
    ('bef66578-05c8-11ed-824f-83ee7fc2cced', 'bef59bde-05c8-11ed-824f-efb3c762cda1', 'bef0b786-05c8-11ed-824f-c7108ba9ec59', 10, 3, '00:05:00', 4000, NULL, 2500, 'Do not use your biceps to pull — only your back. Pull as far as comfortably possible.', ARRAY['https://vimeo.com/178042607']),
    ('1a8fadfa-31ba-11ed-aa8c-0b0975e770be', 'bef6fb96-05c8-11ed-824f-d7ac01edbd91', '1a8dd67e-31ba-11ed-aa8c-cf1406502216', 10, 4, '00:05:00', 2000, NULL, 2500, 'Do not use your biceps to pull — only your back. Pull as far as comfortably possible.', ARRAY['https://vimeo.com/164080300']),
    ('1a8e5a68-31ba-11ed-aa8c-4790019272c5', 'bef59bde-05c8-11ed-824f-efb3c762cda1', '1a8dd67e-31ba-11ed-aa8c-cf1406502216', 10, 4, '00:05:00', 1000, NULL, 2500, 'Do not use your biceps to pull — only your back. Pull as far as comfortably possible.', ARRAY['https://vimeo.com/178042607']),
    ('bef7ba18-05c8-11ed-824f-83b5b191a65d', 'bef6fb96-05c8-11ed-824f-d7ac01edbd91', 'bef0b786-05c8-11ed-824f-c7108ba9ec59', 10, 3, '00:05:00', 5000, NULL, 2500, 'Do not use your biceps to pull — only your back. Pull as far as comfortably possible.', ARRAY['https://vimeo.com/164080300']),
    ('1a7e10ea-31ba-11ed-aa8c-cbb8dd4cd17e', 'beed0910-05c8-11ed-824f-93404b8cc033', '1a73b686-31ba-11ed-aa8c-7f85836d1fff', 10, 4, '00:05:00', 4000, NULL, 2500, 'Do this exercise with a dumbbell between your feet. Follow the advice <a target="_blank" href="https://www.youtube.com/watch?v=BI7wrB3Crsc&amp;feature=youtu.be&amp;t=0m16s">in this video</a>.', ARRAY['https://vimeo.com/39560703']),
    ('28773506-dc9e-11ee-b3ef-f72b7d8193d1', '28647506-dc9e-11ee-b3ef-5fa33cfe2e29', '285cdb34-dc9e-11ee-b3ef-1f58823052c0', 6, 1, '00:02:00', 1000, NULL, 2500, 'First set heavy 4-6', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=38s']),
    ('2897fb06-dc9e-11ee-b3ef-971ad53d2ba7', '2885f762-dc9e-11ee-b3ef-0fa909073fa5', '285cdb34-dc9e-11ee-b3ef-1f58823052c0', 10, 1, '00:02:00', 2000, NULL, 2500, 'Second set back-off: 8-10', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=38s']),
    ('28b8e2c6-dc9e-11ee-b3ef-3fec68eb1378', '28a6d306-dc9e-11ee-b3ef-ff4dc2fcf322', '285cdb34-dc9e-11ee-b3ef-1f58823052c0', 10, 2, '00:02:00', 3000, NULL, 2500, 'Two sets 8-10, can use barbell but less time efficient', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=102s']),
    ('28d9888c-dc9e-11ee-b3ef-63badb3a33d0', '28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50', '285cdb34-dc9e-11ee-b3ef-1f58823052c0', 12, 2, '00:02:00', 4000, NULL, 2500, 'Two sets 10-12, first set overhand middle grip, second set underhand close grip. End with overhead curls', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=150s']),
    ('28fa1a98-dc9e-11ee-b3ef-7b60d2c44734', '28e81f6e-dc9e-11ee-b3ef-5b9f8379af2d', '285cdb34-dc9e-11ee-b3ef-1f58823052c0', 10, 1, '00:02:00', 5000, NULL, 2500, '1x8-10. One leg at a time, use straps', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=175s']),
    ('291abf6e-dc9e-11ee-b3ef-c7be43be58a2', '29089d70-dc9e-11ee-b3ef-3b403f46b72b', '285cdb34-dc9e-11ee-b3ef-1f58823052c0', 15, 1, '00:02:00', 6000, NULL, 2500, 'One sets 12-15', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=227s']),
    ('293b4afe-dc9e-11ee-b3ef-f7267aaf1177', '292952c2-dc9e-11ee-b3ef-bb9c1105deaa', '285cdb34-dc9e-11ee-b3ef-1f58823052c0', 15, 1, '00:02:00', 7000, NULL, 2500, '1x12-15 + dropset, 30% reduction', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=297s']),
    ('295d6daa-dc9e-11ee-b3ef-7b1d13c7b51c', '294b4bca-dc9e-11ee-b3ef-bb47280d67c5', '285cdb34-dc9e-11ee-b3ef-1f58823052c0', 15, 1, '00:02:00', 8000, NULL, 2500, '1x12-15. Seated is quicker but calf raise works. Dropset 30-40%, 1 sec pause at bottom.', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=355s']),
    ('29853204-dc9e-11ee-b3ef-5fcce77185d6', '29733bd0-dc9e-11ee-b3ef-0789357bba52', '296beb5a-dc9e-11ee-b3ef-978e1fe7d3aa', 6, 1, '00:02:00', 1000, NULL, 2500, '1x4-6 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=405s']),
    ('29a5c320-dc9e-11ee-b3ef-536ffa29494f', '2993acda-dc9e-11ee-b3ef-cf7bc31697d6', '296beb5a-dc9e-11ee-b3ef-978e1fe7d3aa', 10, 1, '00:02:00', 2000, NULL, 2500, '1x8-10 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=405s']),
    ('2a07df10-dc9e-11ee-b3ef-3b189eb703a7', '29f5bc5e-dc9e-11ee-b3ef-c7aa53eb5778', '296beb5a-dc9e-11ee-b3ef-978e1fe7d3aa', 12, 1, '00:02:00', 5000, NULL, 2500, '1x10-12 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=444s']),
    ('2a284a34-dc9e-11ee-b3ef-fbaf1d984113', '2a163cfe-dc9e-11ee-b3ef-575801647e7d', '296beb5a-dc9e-11ee-b3ef-978e1fe7d3aa', 15, 1, '00:02:00', 6000, NULL, 2500, '1x12-15 + myoreps, supinated grip', ARRAY['https://youtu.be/eMjyvIQbn9M?t=577']),
    ('2a5ee012-dc9e-11ee-b3ef-03ba1cb59430', '28647506-dc9e-11ee-b3ef-5fa33cfe2e29', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 6, 1, '00:02:00', 1000, NULL, 2500, 'First set heavy 4-6', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=38s']),
    ('2a710a26-dc9e-11ee-b3ef-0339f498ebaa', '2885f762-dc9e-11ee-b3ef-0fa909073fa5', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 10, 1, '00:02:00', 2000, NULL, 2500, 'Second set back-off: 8-10', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=38s']),
    ('2a831504-dc9e-11ee-b3ef-2307f11f69d8', '28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 12, 2, '00:02:00', 3000, NULL, 2500, 'Two sets 10-12, first set overhand middle grip, second set underhand close grip. End with overhead curls', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=150s']),
    ('2a953dec-dc9e-11ee-b3ef-9b358be81707', '29089d70-dc9e-11ee-b3ef-3b403f46b72b', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 15, 1, '00:02:00', 4000, NULL, 2500, 'One sets 12-15', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=227s']),
    ('2aa77390-dc9e-11ee-b3ef-4f61e69ed62b', '292952c2-dc9e-11ee-b3ef-bb9c1105deaa', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 15, 1, '00:02:00', 5000, NULL, 2500, '1x12-15 + dropset, 30% reduction', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=297s']),
    ('2ab9a8bc-dc9e-11ee-b3ef-5bff4f2d45e3', '29b44c42-dc9e-11ee-b3ef-53720d6ec33a', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 12, 2, '00:02:00', 6000, NULL, 2500, '1x10-12, almost overhead 45-60°, superset with next', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=483s']),
    ('2acbda96-dc9e-11ee-b3ef-0342ad958873', '29d5069e-dc9e-11ee-b3ef-574f7b65abee', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 12, 2, '00:02:00', 7000, NULL, 2500, '1x10-12, superset with prev, can also reverse and run dumbbell row', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=483s']),
    ('2ade0cd4-dc9e-11ee-b3ef-733ba2cbfb51', '2a163cfe-dc9e-11ee-b3ef-575801647e7d', '2a577bf6-dc9e-11ee-b3ef-efb146b04eee', 15, 1, '00:02:00', 8000, NULL, 2500, '1x12-15 + myoreps, supinated grip', ARRAY['https://youtu.be/eMjyvIQbn9M?t=577']),
    ('2b062d22-dc9e-11ee-b3ef-074aa69fb56a', '28a6d306-dc9e-11ee-b3ef-ff4dc2fcf322', '2afec44c-dc9e-11ee-b3ef-c7f6e8c29dde', 10, 2, '00:02:00', 1000, NULL, 2500, 'Two sets 8-10, can use barbell but less time efficient', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=102s']),
    ('2b184cd2-dc9e-11ee-b3ef-5b3e31be89ed', '28e81f6e-dc9e-11ee-b3ef-5b9f8379af2d', '2afec44c-dc9e-11ee-b3ef-c7f6e8c29dde', 10, 1, '00:02:00', 2000, NULL, 2500, '1x8-10. One leg at a time, use straps', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=175s']),
    ('2b2a5ecc-dc9e-11ee-b3ef-9ba5b01c0883', '294b4bca-dc9e-11ee-b3ef-bb47280d67c5', '2afec44c-dc9e-11ee-b3ef-c7f6e8c29dde', 15, 1, '00:02:00', 3000, NULL, 2500, '1x12-15. Seated is quicker but calf raise works. Dropset 30-40%, 1 sec pause at bottom.', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=355s']),
    ('2b4ecabe-dc9e-11ee-b3ef-837df600f405', '2993acda-dc9e-11ee-b3ef-cf7bc31697d6', '2afec44c-dc9e-11ee-b3ef-c7f6e8c29dde', 10, 1, '00:02:00', 5000, NULL, 2500, '1x8-10 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=405s']),
    ('2b60f9b4-dc9e-11ee-b3ef-a39a13f07c52', '29f5bc5e-dc9e-11ee-b3ef-c7aa53eb5778', '2afec44c-dc9e-11ee-b3ef-c7f6e8c29dde', 12, 1, '00:02:00', 6000, NULL, 2500, '1x10-12 + dropset', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=444s']),
    ('29c6645e-dc9e-11ee-b3ef-6714ba065f78', '29b44c42-dc9e-11ee-b3ef-53720d6ec33a', '296beb5a-dc9e-11ee-b3ef-978e1fe7d3aa', 12, 2, '00:00:30', 3000, NULL, 2500, '1x10-12, almost overhead 45-60°, superset with next', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=483s']),
    ('02c6b83c-70f9-11ef-bc64-2392e01e4338', '1a826cd0-31ba-11ed-aa8c-67424ddf3bd1', '0299d4c0-70f9-11ef-bc64-435fb303af94', 5, 5, '00:03:00', 2000, NULL, 2500, 'Listen to the advice [in this video](https://www.youtube.com/watch?v=SW_C1A-rejs&feature=youtu.be&t=1m04s) to learn proper form.', ARRAY['https://vimeo.com/178056008']),
    ('02d8c95a-70f9-11ef-bc64-f7db25d8f57f', '1a7bd55a-31ba-11ed-aa8c-63d32f2aae22', '0299d4c0-70f9-11ef-bc64-435fb303af94', 5, 5, '00:03:00', 3000, NULL, 2500, 'Keep your back straight. Don''t lock your arms at the top of the motion.', ARRAY['https://vimeo.com/96081016']),
    ('02eb22a8-70f9-11ef-bc64-9318ac9cf072', '1a8acb3c-31ba-11ed-aa8c-7bcd8a601b4e', '0299d4c0-70f9-11ef-bc64-435fb303af94', 5, 5, '00:03:00', 4000, NULL, 2500, 'Listen to the advice [in this video](https://www.youtube.com/watch?v=JCXUYuzwNrM&feature=youtu.be&t=1m25s) to learn proper form.', ARRAY['https://vimeo.com/178056325']),
    ('29e71a82-dc9e-11ee-b3ef-fb9b12bcfeb0', '29d5069e-dc9e-11ee-b3ef-574f7b65abee', '296beb5a-dc9e-11ee-b3ef-978e1fe7d3aa', 12, 2, '00:00:30', 4000, NULL, 2500, '1x10-12, superset with prev, can also reverse and run dumbbell row', ARRAY['https://www.youtube.com/watch?v=eMjyvIQbn9M&t=483s'])
ON CONFLICT (exercise_id) DO NOTHING;
