-- ============================================================================
-- Specialty Exercise Metadata Migration
-- Created: 2025-11-23
-- Description: Populates metadata for specialty, functional, and CrossFit exercises
--              including kettlebell movements, advanced gymnastics, powerlifting
--              variations, and accessory work.
-- Source Files: /docs/exercise-metadata/specialty-exercises.md
--               /docs/exercise-metadata/pressing-variations.md
-- ============================================================================

-- ============================================================================
-- KETTLEBELL EXERCISES
-- ============================================================================

-- Turkish Get-Up
UPDATE base_exercise
SET
    level = 'expert',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'kettlebell'),
    instructions = ARRAY[
        'Starting Position: Lie on your back with right knee bent, right foot flat on ground. Left leg and left arm extended at 45-degree angle. Right arm extended overhead holding kettlebell, knuckles pointing to ceiling. Eyes locked on kettlebell.',
        'Roll to Elbow: Roll onto left side and prop yourself up on left elbow, using hand and palm to grip the floor.',
        'Press to Hand: Pull through left hand to lift torso off ground, coming up onto left hand.',
        'Hip Extension: Drive through right foot to lift hips off ground while sweeping left leg underneath.',
        'Low Lunge: Position yourself in a low lunge with left knee down.',
        'Stand Up: Press into right foot to stand, keeping kettlebell overhead.',
        'Reverse: Reverse the entire sequence to return to starting position.',
        'SAFETY: Keep eyes on kettlebell throughout entire movement. Arm should never break the chain - never bend at wrist or elbow. Control each movement - full Get Up should take at least 30 seconds. Start with bodyweight before adding load. Men start with 16kg, women with 8kg for first loaded attempts.'
    ],
    links = ARRAY[
        'https://www.strongfirst.com/community/threads/turkish-get-up-technique-detail.16265/',
        'https://kettlebellsworkouts.com/7-steps-of-the-kettlebell-turkish-get-up/',
        'https://gymless.org/mastering-the-kettlebell-turkish-get-up-a-guide-to-technique-benefits-and-safety/'
    ]
WHERE base_exercise_id = '8a98e6b8-ff15-4c44-999c-f0d19c867b45';

SELECT set_exercise_muscles(
    '8a98e6b8-ff15-4c44-999c-f0d19c867b45',
    ARRAY['abs', 'shoulders', 'glutes', 'quadriceps', 'triceps'],
    ARRAY['traps', 'obliques', 'lats', 'forearms', 'hamstrings', 'calves', 'erector_spinae']
);

-- Kettlebell Swing (One-Arm)
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'kettlebell'),
    instructions = ARRAY[
        'Setup: Place kettlebell on ground in front of you. Stand with feet shoulder-width apart.',
        'Two-Hand Start: Always start with both hands on kettlebell to square shoulders and prevent bad form.',
        'Hip Hinge: Push hips back, slight knee bend (not a squat). Maintain neutral spine.',
        'Single Arm Grip: Transfer to single hand grip, shoulder packed and scapula engaged.',
        'Swing: Drive hips forward explosively to swing kettlebell. Power comes from hip extension, not arms.',
        'Free Arm: Mirror the movement of working arm with free arm to keep shoulders square throughout arc of swing.',
        'Control Descent: Control the descent, maintaining rotational stability through core and obliques.',
        'SAFETY: Rotational stability is key. Keep shoulder packed throughout. Mirror movement with non-working arm. This is a hip hinge, not a squat. Start with two hands on bell every rep.'
    ],
    links = ARRAY[
        'https://www.strongfirst.com/community/threads/one-arm-swings.25846/',
        'https://www.strongfirst.com/free-hand-one-arm-swing/',
        'https://kettlebellsworkouts.com/kettlebell-swing-one-hand/'
    ]
WHERE base_exercise_id = '5a3bca2d-b34b-4c97-9d48-5f436c7a21b3';

SELECT set_exercise_muscles(
    '5a3bca2d-b34b-4c97-9d48-5f436c7a21b3',
    ARRAY['glutes', 'hamstrings'],
    ARRAY['abs', 'obliques', 'lats', 'shoulders', 'traps', 'forearms']
);

-- Halos
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'static',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'kettlebell'),
    instructions = ARRAY[
        'Starting Position: Stand with feet shoulder-width apart, knees slightly bent. Hold kettlebell upside down by horns (handles), bottom facing up.',
        'Brace Core: Exhale sharply, draw abdominals to spine, shoulders back and down, shoulder blades retracted.',
        'Circle Right: Begin rotating kettlebell to right, bringing it behind head in smooth, controlled movement.',
        'Lower at Neck: Drop height slightly as kettlebell reaches back of neck.',
        'Complete Circle: Bring kettlebell back to starting position, completing full circle.',
        'Reverse Direction: Perform equal reps in opposite direction.',
        'SAFETY: Keep weight as close to head as possible. Head and neck stay completely locked with neutral spine. Move slowly and controlled. Start with light weight (8-12kg).'
    ],
    links = ARRAY[
        'https://kettlebellsworkouts.com/kettlebell-halo/',
        'https://www.menshealth.com/fitness/a28701803/kettlebell-halo-exercise/',
        'https://www.kettlebellkings.com/blogs/default-blog/kettlebell-halo-exercise'
    ]
WHERE base_exercise_id = '75e864ec-c666-4b08-b0b0-794ffb647773';

SELECT set_exercise_muscles(
    '75e864ec-c666-4b08-b0b0-794ffb647773',
    ARRAY['shoulders'],
    ARRAY['traps', 'triceps', 'abs']
);

-- Prying Goblet Squat
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'static',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'kettlebell'),
    instructions = ARRAY[
        'Setup: Hold kettlebell by horns at chest level. Feet slightly wider than shoulder-width.',
        'Active Negative: Pull yourself down into squat using hip flexors. This is an active movement, not passive drop.',
        'Bottom Position: Descend until hip crease is lower than top of knee. Pin elbows to insides of knees.',
        'Prying Motion: Use elbows to gently push knees outward while simultaneously using knees to push elbows inward. This creates tension.',
        'Hold and Breathe: Hold position for 30-60 seconds, breathing deeply. With each exhale, try to sink slightly deeper.',
        'Explore Range: Gently rock side to side, finding tight spots and working through them.',
        'SAFETY: This is a mobility drill, not a strength exercise. Use light to moderate weight. Focus on opening hips, not loading them. Breathe continuously - never hold breath.'
    ],
    links = ARRAY[
        'https://www.strongfirst.com/community/threads/prying-goblet-squat-for-hips-what-works-like-it-for-shoulders.6382/',
        'https://rkcblog.dragondoor.com/perfecting-squat-mechanics-with-prying-goblet-squat/',
        'https://www.strongfirst.com/kettlebell-simple-sinister-tips-for-heavy-goblet-squats/'
    ]
WHERE base_exercise_id = 'f36724da-1dba-4516-88ba-2596084c5289';

SELECT set_exercise_muscles(
    'f36724da-1dba-4516-88ba-2596084c5289',
    ARRAY['quadriceps', 'glutes', 'hip_flexors'],
    ARRAY['abs', 'adductors']
);

-- ============================================================================
-- CROSSFIT / FUNCTIONAL EXERCISES
-- ============================================================================

-- Wall Balls
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'medicine_ball'),
    instructions = ARRAY[
        'Setup: Stand facing wall at arm''s length, feet shoulder-width apart. Hold medicine ball at chest level, elbows tucked.',
        'Squat: Push hips back, bend knees to lower into deep squat until hip crease is below knees.',
        'Drive Up: Explosively extend hips, knees, and ankles, driving through heels.',
        'Throw: Use leg momentum to thrust ball overhead toward 9-10 foot wall target.',
        'Catch: Catch rebounding ball at chest level.',
        'Absorb: Immediately descend into next squat to absorb impact and maintain rhythm.',
        'SAFETY: Stand at proper distance from wall (arm''s length). Catch ball at chest, not overhead. Use legs to generate power, not just arms. Maintain upright torso throughout squat. Control the descent to protect knees. CrossFit Standards: Men 20 lb ball to 10 ft, Women 14 lb ball to 9 ft.'
    ],
    links = ARRAY[
        'https://www.crossfit.com/essentials/the-wall-ball',
        'https://wodprep.com/blog/ultimate-guide-wall-balls/',
        'https://www.coachweb.com/medicine-ball-exercises-and-workouts/6542/how-to-do-wall-balls-and-why-it-s-worth-putting-yourself'
    ]
WHERE base_exercise_id = '72e02183-5cc1-4ee4-83f9-166611edd1bf';

SELECT set_exercise_muscles(
    '72e02183-5cc1-4ee4-83f9-166611edd1bf',
    ARRAY['quadriceps', 'glutes', 'hamstrings'],
    ARRAY['shoulders', 'chest', 'triceps', 'abs', 'traps']
);

-- Box Jumps
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'box'),
    instructions = ARRAY[
        'Setup: Stand facing box, feet hip-width apart, 6-12 inches from box.',
        'Loading Phase: Bend slightly at hips and knees, swing arms back. This is a small dip, not a deep squat.',
        'Jump: Explosively extend hips, knees, ankles while swinging arms forward and up. Drive knees toward chest.',
        'Land Softly: Land on box with entire foot, knees slightly bent, in athletic position. Land like a cat - soft and controlled.',
        'Stand Tall: Fully extend hips and knees at top of box.',
        'Step Down: Step down one foot at a time (safer) or jump down for advanced athletes.',
        'SAFETY: Start with low box height (12-15 inches). Soft, controlled landings reduce joint stress. Step down between reps for safety. Warm up thoroughly before plyometrics. Ensure box is stable and secure. Standards: Beginner 12-15", Intermediate 20-24", Advanced 24-30", CrossFit Women 20", Men 24".'
    ],
    links = ARRAY[
        'https://theprogrm.com/box-jump-tutorial/',
        'https://outperformsports.com/box-jump-guide/',
        'https://sweat.com/blogs/fitness/box-jumps'
    ]
WHERE base_exercise_id = 'a08ae9ef-4819-4612-a32f-a07930d6cdfc';

SELECT set_exercise_muscles(
    'a08ae9ef-4819-4612-a32f-a07930d6cdfc',
    ARRAY['quadriceps', 'glutes', 'calves'],
    ARRAY['hamstrings', 'hip_flexors', 'abs']
);

-- Burpees
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'bodyweight'),
    instructions = ARRAY[
        'Starting Position: Stand with feet shoulder-width apart.',
        'Squat Down: Drop into squat position, place hands on floor in front of feet.',
        'Plank Position: Jump or step feet back to plank position. Shoulders parallel to wrists, core engaged, back straight.',
        'Push-Up (Optional): Perform push-up or lower chest to floor (CrossFit standard requires chest to touch floor).',
        'Return to Squat: Jump or step feet back to squat position.',
        'Jump: Explosively jump up, reaching arms overhead. Hip and knees must fully extend.',
        'SAFETY: Maintain neutral spine in plank position. Control descent in push-up phase. Land softly from jump. Engage core throughout movement. Scale if needed - step instead of jump.'
    ],
    links = ARRAY[
        'https://www.crossfit.com/essentials/burpees-and-workouts',
        'https://barbend.com/burpees/',
        'https://invictusfitness.com/blog/burpees/'
    ]
WHERE base_exercise_id = '81a79bda-b4c5-4615-a3ad-b6264ce0d8eb';

SELECT set_exercise_muscles(
    '81a79bda-b4c5-4615-a3ad-b6264ce0d8eb',
    ARRAY['chest', 'quadriceps', 'glutes', 'shoulders'],
    ARRAY['triceps', 'hamstrings', 'calves', 'abs']
);

-- Handstand Push-ups (HSPU)
UPDATE base_exercise
SET
    level = 'expert',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'bodyweight'),
    instructions = ARRAY[
        'Setup (Strict): Face wall, place hands shoulder-width apart on floor, approximately 6-12 inches from wall.',
        'Kick to Handstand: Kick feet up to wall. Only heels should touch wall. Elbows completely locked.',
        'Descend: Tuck chin slightly. Lower head toward floor in controlled manner until head and hands form triangle (tripod).',
        'Press Up: Drive through hands to press back to lockout. Keep body tight.',
        'Kipping (Advanced): Only attempt after mastering 10+ strict HSPU. Bring lower spine to wall while bending knees. Violently open hips and kick to ceiling using momentum to press up.',
        'SAFETY: MASTER strict HSPU before attempting kipping. Strict strength protects neck and spine during kipping. Build strength with progressions. Prerequisites for strict: multiple strict shoulder press reps, 30+ second handstand hold, 10+ elevated pike push-ups. Prerequisites for kipping: 10+ strict HSPU first.'
    ],
    links = ARRAY[
        'https://www.crossfit.com/essentials/hspu-and-you-master-the-movement',
        'https://wodprep.com/blog/handstand-push-ups-ultimate-guide/',
        'https://theprogrm.com/handstand-push-up-technique/'
    ]
WHERE base_exercise_id = '150c4890-e1d3-4c1f-ae85-1c23c0c933c2';

SELECT set_exercise_muscles(
    '150c4890-e1d3-4c1f-ae85-1c23c0c933c2',
    ARRAY['shoulders', 'triceps'],
    ARRAY['chest', 'traps', 'abs']
);

-- Toes-to-Bar (T2B)
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'pull_up_bar'),
    instructions = ARRAY[
        'Strict T2B - Hang: Dead hang from pull-up bar, arms locked.',
        'Strict T2B - Lift: Using core and hip flexors, raise legs until toes touch bar between hands.',
        'Strict T2B - Lower: Control descent back to dead hang.',
        'Kipping T2B - Kip Swing: Establish rhythmic kip swing moving between arch and hollow positions.',
        'Kipping T2B - Arch Position: Push away from bar slightly, chest forward, small arch in back.',
        'Kipping T2B - Hollow Position: Pull back toward bar, ribs down to belly button, fire up hip flexors and lats.',
        'Kipping T2B - Lift Toes: From hollow position, drive toes to bar.',
        'SAFETY: Build strict strength before kipping. Maintain grip strength throughout set. Control the swing. Start with knee raises. Protect shoulders by maintaining active hang. Prerequisites: 30+ second bar hang, basic core strength, 8-12 controlled knee raises.'
    ],
    links = ARRAY[
        'https://www.crossfit.com/essentials/crossfit-toes-to-bar-rx-plan',
        'https://theprogrm.com/toes-to-bar-progression/',
        'https://wodprep.com/blog/crossfit-toes-to-bar/'
    ]
WHERE base_exercise_id = 'c59ef814-9b83-43c2-9fd9-78946041d8c6';

SELECT set_exercise_muscles(
    'c59ef814-9b83-43c2-9fd9-78946041d8c6',
    ARRAY['hip_flexors', 'abs', 'obliques'],
    ARRAY['lats', 'forearms', 'traps']
);

-- Thruster
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Setup: Bar in front rack position (racked on shoulders), hands just outside shoulders. Elbows high. Feet shoulder-width, toes slightly out.',
        'Descend: Push hips back and down, maintain upright torso. Descend until hip crease is below knees (full front squat depth).',
        'Drive Up: Explosively extend hips and knees, driving through heels.',
        'Press Overhead: Use momentum from leg drive to press bar overhead. Hips and knees extend rapidly to aid elevation.',
        'Lockout: Fully extend arms overhead, bar over middle of foot. Hips, knees, and arms all locked out.',
        'Return: Lower bar back to front rack position, immediately descend into next rep.',
        'SAFETY: Maintain upright torso in squat. Use leg drive, not just arms. Control bar path (straight line overhead). Proper front rack mobility required. Core stays braced throughout. Prerequisites: proper front squat mechanics, overhead press capability, front rack mobility, basic overhead mobility. CrossFit Standards: full depth squat (hip crease below knee), full lockout overhead (hips, knees, elbows extended), bar finishes over middle of body.'
    ],
    links = ARRAY[
        'https://www.crossfit.com/essentials/the-thruster-potent-tool',
        'https://www.coachweb.com/full-body-exercises/6500/how-to-do-the-thruster',
        'https://www.boxrox.com/thruster-crossfit-exercise/'
    ]
WHERE base_exercise_id = '5e3749e4-ed93-4a3e-b921-f20d2526f2f7';

SELECT set_exercise_muscles(
    '5e3749e4-ed93-4a3e-b921-f20d2526f2f7',
    ARRAY['quadriceps', 'shoulders'],
    ARRAY['glutes', 'hamstrings', 'abs', 'triceps', 'traps']
);

-- ============================================================================
-- SPECIALTY BARBELL EXERCISES
-- ============================================================================

-- Floor Press
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Setup: Lie on floor under barbell (in rack or have spotter hand off). Wedge upper back into ground, establish strong torso brace.',
        'Grip: Grip bar with hands positioned to allow maximal tricep force (typically slightly narrower than bench press grip).',
        'Unrack: Lift bar from rack or take handoff. Position bar over chest, elbows locked.',
        'Descend: Lower bar with control. Allow triceps to lay completely flat on floor (triceps parallel with ground from elbow to shoulder).',
        'Pause: Brief pause with triceps on floor. Maintain tension.',
        'Press: Drive bar back to lockout, emphasizing tricep extension.',
        'SAFETY: Use rack or spotter for setup/unrack. Control descent - don''t bounce elbows off floor. Maintain stable position (can''t use leg drive like bench). Start lighter than bench press max. Keep wrists straight and stable. Westside Barbell Programming: Common max effort upper exercise, typically 1-3 reps for max effort work, great for lockout strength development.'
    ],
    links = ARRAY[
        'https://www.westside-barbell.com/blogs/the-blog/basic-press-variations',
        'https://www.westside-barbell.com/blogs/the-blog/bench-press-builders'
    ]
WHERE base_exercise_id = '9f285bb0-30b3-480a-8acf-f60b892671c2';

SELECT set_exercise_muscles(
    '9f285bb0-30b3-480a-8acf-f60b892671c2',
    ARRAY['triceps', 'chest'],
    ARRAY['shoulders']
);

-- Board Press
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Setup: Lie on bench as for regular bench press. Have partner hold board(s) on chest.',
        'Board Selection: 1-2 boards for missing just above chest, 3 boards for mid-range, 4-5 boards for lockout weakness.',
        'Unrack: Unrack barbell, position over chest.',
        'Descent: Lower bar to boards with control. Bar should touch boards, not crash.',
        'Pause: Brief pause on boards.',
        'Press: Drive bar to lockout, emphasizing lockout strength and tricep engagement.',
        'SAFETY: Requires spotter/partner to hold boards. Use slightly heavier than regular bench (reduced ROM). Maintain shoulder blade retraction. Control descent to boards. Can use significantly more weight - be conservative. Selecting Board Height: Missing at lockout use 4-5 boards, missing mid-range use 3 boards, missing just off chest use 1-2 boards. Programming: 4-6 week blocks, add load or volume progressively, typically close grip for lockout issues, wide grip if missing off chest.'
    ],
    links = ARRAY[
        'https://powerliftingtechnique.com/boards-for-bench-press/',
        'https://www.powerrackstrength.com/why-you-should-be-board-pressing/',
        'https://bonvecstrength.com/2023/10/12/top-5-triceps-exercises-to-improve-your-bench-press-lockout/'
    ]
WHERE base_exercise_id = '47b1b5b3-a404-4dfa-9bd7-967f8f6d2da5';

SELECT set_exercise_muscles(
    '47b1b5b3-a404-4dfa-9bd7-967f8f6d2da5',
    ARRAY['chest', 'triceps'],
    ARRAY['shoulders']
);

-- Safety Squat Bar (SSB) Squats
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'safety_squat_bar'),
    instructions = ARRAY[
        'Setup: Position SSB on back, padded yokes resting on traps/shoulders. Grasp handles in front of body.',
        'Stance: Feet shoulder-width apart or slightly wider, toes slightly out.',
        'Brace: Take deep breath, brace core hard. Bar camber creates forward pull - must resist.',
        'Descent: Push hips back and down, maintain upright torso (more upright than regular squat). Descend to depth.',
        'Bottom: Maintain tension, resist forward pull of bar. Upper back works hard here.',
        'Ascent: Drive through heels, extend hips and knees. Fight to keep torso upright.',
        'Lockout: Fully extend hips and knees, maintain core brace.',
        'SAFETY: Bar creates significant forward pull - requires upper back strength. Easier on shoulders than regular barbell. Start with lighter weight than regular squat (60-70%). Maintain rigid torso throughout. Can be harder to breathe - practice breathing mechanics. Benefits: Reduced shoulder stress/mobility requirements, increased quadriceps activation, enhanced upper back development, excellent for working around injuries. Powerlifting Applications: Common accessory for powerlifters, builds squat strength with different pattern, addresses upper back weakness.'
    ]
WHERE base_exercise_id = '056f9388-add7-4df0-9aa8-1fe60fe72944';

SELECT set_exercise_muscles(
    '056f9388-add7-4df0-9aa8-1fe60fe72944',
    ARRAY['quadriceps', 'glutes'],
    ARRAY['hamstrings', 'traps', 'abs', 'erector_spinae']
);

-- ============================================================================
-- ACCESSORY EXERCISES
-- ============================================================================

-- Cable Kickbacks (Glute)
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    instructions = ARRAY[
        'Setup: Attach ankle cuff to cable machine at lowest setting. Secure around working ankle.',
        'Position: Face cable machine, hold on for support. Hinge slightly forward at hips, engage core for neutral spine.',
        'Starting Position: Working leg slightly off ground, slight bend in knee. Standing leg stable.',
        'Movement: Move leg out and up in arc movement (not a kick). Extend hip until leg is behind body.',
        'Contraction: Squeeze glutes hard at top. Pause 1 second.',
        'Return: Slowly return to starting position with control. Maintain tension throughout.',
        'SAFETY: Brace upper body against machine (don''t use momentum). Keep core engaged to protect lower back. Control the movement (no kicking/swinging). Maintain slight knee bend throughout. Don''t hyperextend lower back. Benefits: Constant tension throughout ROM, direct glute isolation, improves balance and coordination, unilateral training (addresses imbalances), low risk when performed correctly.'
    ],
    links = ARRAY[
        'https://www.puregym.com/exercises/glutes/glute-kickbacks/cable-kickbacks/',
        'https://www.ammfitness.co.uk/information-advice/cable-glute-kickbacks',
        'https://barbend.com/glute-kickbacks/'
    ]
WHERE base_exercise_id = 'bb70a47a-a0a9-4259-a74e-fbf2fdd1741d';

SELECT set_exercise_muscles(
    'bb70a47a-a0a9-4259-a74e-fbf2fdd1741d',
    ARRAY['glutes'],
    ARRAY['hamstrings', 'calves', 'quadriceps', 'abs']
);

-- Ab Wheel Rollouts
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'static',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'ab_wheel'),
    instructions = ARRAY[
        'Starting Position: Begin on knees, hands on ab wheel handles. Wheel positioned under chest. Hips over knees, hands shoulder-width apart.',
        'Pre-Tension: Engage shoulders and hips. Brace core hard, squeeze glutes. Rotate shoulders outward to engage lats.',
        'Roll Out: Slowly roll wheel forward, extending arms. Keep core maximally tight - fight extension. The farther forward, the tighter abs should be.',
        'End Position: Roll as far as possible while maintaining neutral spine. Do NOT let hips sag or back arch.',
        'Return: Pull wheel back to starting position, maintaining core tension throughout.',
        'SAFETY: This exercise has inherent injury risk - requires proper progression. Core must be strong enough to prevent hyperextension. Start with partial ROM only. Keep soft bend in elbows (protect shoulders). Stop if back arches - you''ve gone too far. Prerequisites: Solid plank hold (60+ seconds), weighted plank (10-25 lbs for 60 seconds), strong anti-extension core strength, no lower back issues. Testing Readiness: If you can hold weighted plank (10-25 lbs) for one minute, you can likely experiment with ab rollouts safely.'
    ],
    links = ARRAY[
        'https://barbend.com/ab-rollouts/',
        'https://www.menshealth.com/fitness/a30677116/ab-roller-exercises/',
        'https://www.puregym.com/exercises/abs/ab-wheel-rollouts/'
    ]
WHERE base_exercise_id = '7ae1201f-4995-48fb-9238-c4e018a91bb3';

SELECT set_exercise_muscles(
    '7ae1201f-4995-48fb-9238-c4e018a91bb3',
    ARRAY['abs'],
    ARRAY['obliques', 'hip_flexors', 'lats', 'shoulders']
);

-- Hip Bridges (Glute Bridge)
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'bodyweight'),
    instructions = ARRAY[
        'Starting Position: Lie on back, knees bent, feet flat on ground hip-width apart. Feet approximately 6-8 inches from glutes. Toes pointed straight ahead. Arms at sides.',
        'Brace: Engage abs and glutes before movement begins.',
        'Lift: Squeeze glutes and drive through heels to lift hips toward ceiling. Raise hips as high as possible without arching back.',
        'Top Position: Body forms straight line from knees to hips to shoulders. Squeeze glutes maximally. Hold 2 seconds.',
        'Lower: Slowly lower hips back to floor while maintaining tension in glutes and abs.',
        'SAFETY: Don''t arch lower back (use glutes, not back). Keep ribs down (don''t flare). Drive through heels, not toes. Maintain neutral spine throughout. Control the descent. Benefits: Builds glute strength, improves core stability, reduces lower back pain, strengthens while stretching hip flexors, improves running speed and jumping ability, counteracts sitting (hip flexor tightness). Programming: 2-3 sets x 12-20 reps for endurance/activation, 3-4 sets x 8-12 reps weighted for strength, daily for hip health and glute activation, pre-workout for glute activation.'
    ],
    links = ARRAY[
        'https://blog.nasm.org/how-to-do-a-glute-bridge',
        'https://www.webmd.com/fitness-exercise/how-to-do-glute-bridge',
        'https://petersenpt.com/glute-bridge-benefits'
    ]
WHERE base_exercise_id = 'e4e92a81-f95b-43a4-9510-a44a7bd212f1';

SELECT set_exercise_muscles(
    'e4e92a81-f95b-43a4-9510-a44a7bd212f1',
    ARRAY['glutes'],
    ARRAY['hamstrings', 'abs', 'hip_flexors']
);

-- Split Squats (Bulgarian Split Squat)
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'bodyweight'),
    instructions = ARRAY[
        'Setup: Stand facing away from bench. Place top of rear foot on bench (laces down), standing leg forward. Find balance.',
        'Stance Width: Front foot far enough forward that knee stays over ankle during descent. Adjust for quad vs glute emphasis: Quad focus = front foot closer to bench, Glute focus = front foot farther from bench.',
        'Descent: Keeping chest upright, bend front knee and lower down. Rear leg relaxed, just for balance. Hips can hinge forward slightly, knee can extend to or just over toes.',
        'Bottom Position: Lower until rear knee nearly touches floor or comfortable depth reached. Weight primarily on front leg.',
        'Ascent: Drive through front foot to return to starting position. Focus on front leg doing the work.',
        'SAFETY: This is single-leg exercise - rear leg only for balance. Control the descent (don''t crash down). Keep torso relatively upright. Start without weight to find balance. Adjust stance to avoid knee pain. Benefits: Unilateral training (prevents strength imbalances), greater glute and hamstring activation vs back squat, improves balance and stability, addresses left-right differences, increased core and knee stabilizer engagement, less spinal loading than bilateral squats. Programming: 3-4 sets x 8-12 reps per leg, can be primary leg exercise or accessory, perform both legs before resting or alternate legs, 2-3x per week for leg development.'
    ],
    links = ARRAY[
        'https://www.gymshark.com/blog/article/how-to-bulgarian-split-squat',
        'https://www.menshealth.com/uk/how-tos/a735581/barbell-bulgarian-split-squat1/',
        'https://www.healthline.com/health/fitness-exercise/bulgarian-split-squat'
    ]
WHERE base_exercise_id = '7dab1f6e-a886-4888-a397-82ff4a0bea2e';

SELECT set_exercise_muscles(
    '7dab1f6e-a886-4888-a397-82ff4a0bea2e',
    ARRAY['quadriceps', 'glutes'],
    ARRAY['hamstrings', 'calves', 'abs']
);

-- ============================================================================
-- GRIP VARIATION EXERCISES
-- ============================================================================

-- Wide-Grip Pull-Ups
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'pull_up_bar'),
    instructions = ARRAY[
        'Grip: Grasp pull-up bar with pronated (overhand) grip wider than shoulder-width. Thumbs pointing toward each other.',
        'Dead Hang: Start from dead hang, arms extended (not locked), shoulders engaged (don''t hang passively).',
        'Activation: Depress shoulder blades, squeeze glutes, brace abs. Take deep breath.',
        'Pull: Drive elbows straight down toward floor. Pull chest toward bar, leading with elbows.',
        'Top Position: Continue until collarbone reaches bar or chin clears bar. Squeeze upper back and lats hard.',
        'Descent: Lower with control to almost full extension. Maintain shoulder engagement.',
        'SAFETY: Avoid completely locking out at bottom (protects elbow/shoulder ligaments). Don''t swing or use momentum. Keep shoulders depressed (down, not shrugged). Wider grip = more shoulder stress, ensure adequate mobility. Build up volume gradually. Grip Width Effects: Wider grip = more lat activation, Narrower grip = more bicep involvement. Find balance between lat emphasis and shoulder safety. Prerequisites: Multiple regular pull-ups (8-10 reps), adequate shoulder mobility, shoulder stability.'
    ],
    links = ARRAY[
        'https://www.muscleandstrength.com/exercises/wide-grip-pull-up.html',
        'https://www.healthline.com/health/wide-grip-pull-ups',
        'https://gymnastgem.com/wide-grip-pull-ups/'
    ]
WHERE base_exercise_id = '1bd4b3e7-da5e-477b-b2f7-f2b7957baf69';

SELECT set_exercise_muscles(
    '1bd4b3e7-da5e-477b-b2f7-f2b7957baf69',
    ARRAY['lats'],
    ARRAY['traps', 'rhomboids', 'biceps', 'forearms']
);

-- ============================================================================
-- PRESSING VARIATIONS
-- ============================================================================

-- Wide-Grip Bench Press
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Grip: Grip barbell 1.5 to 2x shoulder width. In powerlifting, maximum is 81cm (index fingers on hash marks).',
        'Setup: Lie on bench, retract shoulder blades and dig them into bench. Feet flat on floor, slight arch in lower back.',
        'Unrack: Unrack bar, position over upper chest/clavicle area.',
        'Descent: Lower bar to lower chest/nipple line with control. Elbows at 45-75 degree angle from body (not fully flared).',
        'Touch: Brief touch (don''t bounce) on chest.',
        'Press: Drive bar back up. Forearms should be perpendicular to floor at bottom. Squeeze chest hard.',
        'Lockout: Return to starting position over upper chest, arms extended.',
        'SAFETY: Requires excellent shoulder mobility and pec strength. Shoulder torque 1.5x greater than regular bench. Reduced range of motion (benefit for powerlifters). Start conservative with weight. Ensure adequate warm-up and shoulder prep. Benefits: Bodybuilding - Increased pec activation (2x more pec fibers recruited vs narrow), Powerlifting - Reduced ROM = more weight lifted, Outer chest development, Variation for plateau breaking. Prerequisites: Solid bench press technique, good shoulder mobility, pectoral strength, no shoulder issues.'
    ],
    links = ARRAY[
        'https://powerliftingtechnique.com/wide-grip-bench-press/',
        'https://steelsupplements.com/blogs/steel-blog/how-to-wide-grip-bench-press-form-benefits',
        'https://www.ironsidetraining.com/blog/bench-press-grip-widths-101'
    ]
WHERE base_exercise_id = '079ff44e-2dd6-4d48-bf11-a49c3f4e0f45';

SELECT set_exercise_muscles(
    '079ff44e-2dd6-4d48-bf11-a49c3f4e0f45',
    ARRAY['chest'],
    ARRAY['shoulders', 'triceps']
);

-- Close-Grip Bench Press
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Grip: Grip barbell approximately shoulder-width apart (just narrower than regular bench). Not extremely narrow.',
        'Setup: Lie on bench, retract shoulder blades, feet flat. Maintain natural arch in lower back.',
        'Unrack: Unrack bar, position over upper chest.',
        'Descent: Lower bar to upper ribcage (not lower chest) with elbows tucked close to torso. Elbows 0-30 degrees from sides.',
        'Bottom Position: Bar touches upper ribcage. Forearms vertical, elbows slightly in front of bar.',
        'Press: Drive bar back to lockout, emphasizing tricep extension.',
        'Lockout: Full elbow extension. Wrists, elbows, shoulders aligned.',
        'SAFETY: Keep elbows tucked (not flared). Don''t use extremely narrow grip (wrist stress). Touch upper ribcage, not lower chest. Lighter weight than regular bench. Excellent for tricep development without isolation exercises. Benefits: Primary tricep builder, improves bench press lockout, less shoulder stress than wide grip, builds upper chest, excellent for powerlifters with lockout weakness. Programming: Hypertrophy 3-4 sets x 6-10 reps at 60-70% of 1RM, Strength 3-5 sets x 3-5 reps at 75-85% of 1RM. Number one supplementary exercise for bench press (many coaches).'
    ],
    links = ARRAY[
        'https://barbend.com/close-grip-bench-press/',
        'https://learn.athleanx.com/articles/close-grip-bench-press',
        'https://powerliftingtechnique.com/bench-press-lockout/'
    ]
WHERE base_exercise_id = '48a24998-5466-4e5c-af83-fc2de2cd6c4c';

SELECT set_exercise_muscles(
    '48a24998-5466-4e5c-af83-fc2de2cd6c4c',
    ARRAY['triceps', 'chest'],
    ARRAY['shoulders']
);

-- Incline Barbell Bench Press
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Setup: Set incline bench to 30-45 degrees (optimal: 30 degrees for maximum upper chest activation). Position feet flat on the ground.',
        'Position: Lie flat on the bench with shoulder blades completely retracted.',
        'Grip: Grip barbell with hands slightly wider than shoulder-width apart.',
        'Unrack: Unrack the barbell with arms extended.',
        'Lower: Lower the barbell toward your upper chest/sternum with controlled tempo. Tuck elbows at approximately 45-degree angle (not flared out).',
        'Pause: Inhale as you lower the barbell. Pause 1-2 seconds at bottom position.',
        'Press: Exhale while pushing barbell back to starting position. Avoid locking out elbows at top.',
        'SAFETY: Always use a spotter when lifting heavy weights. Ensure bench is stable and properly locked at desired angle. Start with 5-10 minutes light cardio and dynamic stretches before lifting. Use lighter warm-up sets to prepare joints and muscles. Keep back flat against bench to avoid excessive lumbar stress. Research shows 30° provides optimal upper chest activation while minimizing shoulder strain. Stop immediately if you experience shoulder pain. Programming: Beginners 2-3 sets of 6-12 reps with light-moderate weight, Intermediate/Advanced 3-4 sets of 8-12 reps for hypertrophy, Strength 3-5 sets of 3-6 reps with heavier loads.'
    ],
    links = ARRAY[
        'https://us.myprotein.com/thezone/training/incline-barbell-bench-press-exercise-technique/',
        'https://www.masterclass.com/articles/incline-bench-press-guide',
        'https://learn.athleanx.com/articles/incline-bench-press-mistakes',
        'https://whitecoattrainer.com/blog/incline-bench-press',
        'https://legionathletics.com/incline-bench-press/'
    ]
WHERE base_exercise_id = '913b28dd-6d15-4621-83de-e4804fe6c973';

SELECT set_exercise_muscles(
    '913b28dd-6d15-4621-83de-e4804fe6c973',
    ARRAY['chest'],
    ARRAY['shoulders', 'triceps', 'lats', 'traps', 'forearms']
);

-- Dumbbell Row
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbell'),
    instructions = ARRAY[
        'Setup (Single-Arm): Place left knee and left hand on flat bench. Keep right foot firmly planted on floor. Hold dumbbell in right hand with neutral grip.',
        'Position: Position body in straight diagonal line with shoulders slightly higher than hips. Keep back flat and head in neutral position.',
        'Row: Squeeze shoulder blades together and drive elbow toward ceiling. Pull dumbbell up while keeping elbow close to body (not flared).',
        'Top Position: Row weight until elbow is in line with or slightly past torso. Keep shoulders level throughout movement (avoid rotation). Squeeze lat muscles at top of movement.',
        'Lower: Lower dumbbell with control to full arm extension. Allow full scapular protraction at bottom.',
        'Two-Arm Version: Stand with feet hip-width apart, holding dumbbells. Hinge at hips with slight knee bend. Keep back flat and core engaged. Row both dumbbells simultaneously to sides of torso.',
        'SAFETY: Keep core engaged throughout to protect lower back. Avoid excessive twisting/rotation that can strain spine. Use weight you can control with proper form. Rest 24-48 hours before training same muscle groups. Stop if you feel lower back strain (may indicate form breakdown). For those with lower back issues, consider chest-supported variation.'
    ],
    links = ARRAY[
        'https://www.menshealth.com/fitness/a64312182/how-to-do-dumbbell-rows/',
        'https://www.issaonline.com/blog/post/dumbbell-row-muscles-worked-proper-form-variations-more',
        'https://learn.athleanx.com/articles/back-for-men/how-to-do-dumbbell-rows',
        'https://www.strengthlog.com/dumbbell-row/',
        'https://health.clevelandclinic.org/dumbbell-rows'
    ]
WHERE base_exercise_id = 'cc50696f-1aad-422e-a192-12c9bfd0cc25';

SELECT set_exercise_muscles(
    'cc50696f-1aad-422e-a192-12c9bfd0cc25',
    ARRAY['lats'],
    ARRAY['rhomboids', 'traps', 'shoulders', 'biceps', 'triceps', 'abs', 'erector_spinae']
);

-- Close-Grip Pulldown
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    instructions = ARRAY[
        'Setup: Attach close-grip V-bar or narrow straight bar to high pulley. Adjust thigh pad to secure legs in place.',
        'Position: Sit on seat with feet flat on floor. Grip handle with neutral (palms facing) or narrow pronated grip. Keep hands approximately 6-8 inches apart. Sit tall with chest up and core braced.',
        'Pull: Initiate by depressing shoulder blades downward. Pull handle toward upper chest/chin area. Drive elbows down toward hips (think "elbows to pockets").',
        'Contract: Continue until elbows are in line with or slightly behind torso. Pull handle to just below chin level. Squeeze lats hard at bottom of movement.',
        'Return: Slowly return to starting position with control. Allow arms to fully extend and scapulae to elevate at top.',
        'Form Cues: Keep torso upright or with slight backward lean (10-15 degrees). Maintain natural arch in lower back. Chest stays up throughout movement. Focus on pulling with lats, not just arms.',
        'SAFETY: Don''t pull bar behind neck (increases shoulder impingement risk). Avoid jerking or using excessive momentum. Ensure thigh pad is properly secured before starting. Start with lighter weight to master form. Close-grip places body in stronger biomechanical position. Increased range of motion compared to wide grip allows better lat contraction.'
    ],
    links = ARRAY[
        'https://www.muscleandstrength.com/exercises/close-grip-pull-down.html',
        'https://blog.nasm.org/biomechanics-of-the-lat-pulldown',
        'https://anabolicaliens.com/blogs/the-signal/close-grip-lat-pulldown-101-form-benefits-and-variations',
        'https://www.setforset.com/blogs/news/close-grip-lat-pulldown',
        'https://legionathletics.com/close-grip-lat-pulldown/'
    ]
WHERE base_exercise_id = '6e908c05-7b15-46e9-8ab5-43628307e828';

SELECT set_exercise_muscles(
    '6e908c05-7b15-46e9-8ab5-43628307e828',
    ARRAY['lats'],
    ARRAY['rhomboids', 'traps', 'shoulders', 'biceps', 'forearms', 'abs']
);

-- Machine Chest Press
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    instructions = ARRAY[
        'Setup: Adjust seat height so handles align with mid-chest level. Sit with back and shoulders firmly against backrest.',
        'Position: Plant feet flat on floor. Grip handles with wrists straight (straight line from hand to wrist). Retract shoulder blades slightly.',
        'Push: Push handles forward/outward until arms are extended. Avoid locking elbows at full extension. Squeeze chest muscles at peak contraction.',
        'Return: Slowly return handles to starting position with control. Maintain contact between back/shoulders and pad throughout.',
        'Breathing: Breathe out during push phase, inhale during return.',
        'SAFETY: Machines provide fixed path, which is safer for beginners. Less risk than free weights (no spotter needed). Better for advanced trainees who can control full ROM. Beginners may struggle to achieve full range of motion. Adjust weight incrementally to avoid shoulder strain. Ensure machine is properly maintained and functional. Programming: Beginners 3 sets of 10-12 reps at light-moderate weight (20-25% bodyweight), Intermediate 3-4 sets of 8-10 reps with heavier resistance, Advanced 4 sets of 8 reps with maximum weight.'
    ],
    links = ARRAY[
        'https://www.menshealth.com/fitness/a68989176/chest-press-machine/',
        'https://www.strengthlog.com/machine-chest-press/',
        'https://www.healthline.com/health/exercise-fitness/chest-press',
        'https://www.puregym.com/blog/how-to-use-the-chest-press/'
    ]
WHERE base_exercise_id = 'f02e3ded-bef5-45e7-8364-1b5b0c1b9ee5';

SELECT set_exercise_muscles(
    'f02e3ded-bef5-45e7-8364-1b5b0c1b9ee5',
    ARRAY['chest'],
    ARRAY['shoulders', 'triceps', 'biceps', 'traps', 'abs']
);

-- Rack Chins
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'squat_rack'),
    instructions = ARRAY[
        'Setup: Position barbell securely in rack at appropriate height. Stand under bar with feet on ground.',
        'Grip: Grasp bar with supinated (underhand) grip, hands shoulder-width apart. Body should be at an angle (not vertical like regular chin-ups).',
        'Activation: Brace abdominal muscles to create full-body tension. Simultaneously pull shoulder blades down and back.',
        'Pull: Pull elbows toward body while squeezing upper back. Continue pulling until collarbone reaches the bar.',
        'Control: Keep legs as still as possible throughout. Maintain neutral neck position (head facing forward).',
        'Lower: Slowly lower with control to starting position.',
        'SAFETY: Ensure barbell is securely positioned in rack before starting. Check that rack is stable and won''t tip. Rest 24-48 hours between training sessions for recovery. Stop immediately if you experience shoulder or elbow pain. Well-executed chin-ups/rack chins build back strength, but poor form can cause harm. Avoid kipping or excessive swinging which increases injury risk. Maintain firm grip throughout to prevent falling. Benefits: Great progression exercise toward full chin-ups/pull-ups. Allows partial bodyweight lifting (feet on ground support some weight). Easier on joints compared to full bodyweight chin-ups. Can improve full chin-up strength even for advanced lifters.'
    ],
    links = ARRAY[
        'https://www.webmd.com/fitness-exercise/how-to-do-chin-up',
        'https://www.masterclass.com/articles/chin-up-guide',
        'https://barbend.com/chin-up/',
        'https://legionathletics.com/chin-up/',
        'https://www.acefitness.org/continuing-education/prosource/february-2016/5799/ace-technique-series-chin-ups/',
        'https://terminatortraining.com/blogs/ttm-blogs/underrated-exercises-part-4'
    ]
WHERE base_exercise_id = 'b230fe6e-9f8f-4bdf-9154-2b86f52f36bb';

SELECT set_exercise_muscles(
    'b230fe6e-9f8f-4bdf-9154-2b86f52f36bb',
    ARRAY['lats', 'biceps'],
    ARRAY['traps', 'rhomboids', 'erector_spinae', 'shoulders', 'abs']
);

-- Cable Pressdown with Rope
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),
    instructions = ARRAY[
        'Setup: Attach rope handle to upper position of cable pulley. Grip rope with overhand grip (palms facing each other).',
        'Position: Take one step back from machine. Position feet hip-width apart or staggered stance. Stand upright with slight forward lean. Position elbows in front of hips, tucked close to sides.',
        'Starting: Begin with rope at upper chest level.',
        'Press Down: Push rope down by extending elbows. At bottom, split rope ends slightly apart (externally rotate).',
        'Extend: Continue until arms are fully extended. Squeeze triceps hard at bottom position.',
        'Return: Slowly return rope upward with control. Keep elbows stationary throughout (pivot point).',
        'Form Cues: Keep elbows pinned to sides (don''t let them drift forward/back). Maintain natural arch in lower back. Torso should remain relatively vertical. Focus on triceps doing the work, not shoulders/back.',
        'SAFETY: Rope allows greater range of motion than straight bar. Provides consistent tension throughout movement (vs free weights). Start with lighter weight to master form. Avoid wrist strain by keeping wrists neutral. Stop if you feel elbow pain. Cable machine is safer than some free weight alternatives for isolation work.'
    ],
    links = ARRAY[
        'https://squatwolf.com/blogs/fitness/triceps-pushdown',
        'https://muscularstrength.com/article/how-to-cable-triceps-pushdown-golden-rules',
        'https://www.strengthlog.com/tricep-pushdown-with-rope/',
        'https://www.acefitness.org/resources/everyone/exercise-library/185/triceps-pushdowns/',
        'https://anabolicaliens.com/blogs/the-signal/the-tricep-pushdown-101-form-benefits-and-alternatives'
    ]
WHERE base_exercise_id = '345b6f8d-5550-4424-ba81-852399bb6716';

SELECT set_exercise_muscles(
    '345b6f8d-5550-4424-ba81-852399bb6716',
    ARRAY['triceps'],
    ARRAY['shoulders', 'abs', 'traps']
);

-- Behind-the-Neck Overhead Press
UPDATE base_exercise
SET
    level = 'expert',
    mechanic = 'compound',
    force = 'push',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Setup: Set barbell in rack at upper chest height. Sit or stand with feet shoulder-width apart.',
        'Grip: Grip bar with hands positioned so elbows are at 90 degrees. Duck head forward and position bar on upper back/traps. Ensure shoulder blades are retracted.',
        'Press: Engage core and maintain neutral spine. Press bar overhead until arms are extended (don''t lock elbows). Keep movement controlled and smooth (no jerking).',
        'Lower: Lower bar back to upper back/trap position. Don''t force bar down if shoulder mobility is limited. Keep head neutral (avoid jutting head forward).',
        'CRITICAL WARNING: This is a HIGH-RISK EXERCISE. Requires exceptional shoulder external rotation range, scapular retraction capability, and adequate thoracic spine mobility. Most people lack adequate shoulder mobility for safe execution. Tight pectorals (rounded shoulders) significantly increase injury risk.',
        'INJURY RISKS: Rotator cuff tears - Significant stress on rotator cuff muscles/tendons. Shoulder impingement - Compression of shoulder joint structures. Neck injury - Bar can hit neck or back of head. Cervical disc herniation - Excessive pressure on neck vertebrae.',
        'WHO SHOULD AVOID: Beginners (explicitly not recommended), those with current or past shoulder injuries, those with current or past neck injuries, anyone with limited shoulder mobility, those with poor thoracic spine mobility, individuals with tight chest muscles/rounded shoulders.',
        'SAFER ALTERNATIVES: Standard overhead press (front), dumbbell shoulder press, landmine press, Arnold press. Many strength coaches recommend avoiding this exercise entirely. Benefits can be achieved through safer alternatives.'
    ],
    links = ARRAY[
        'https://www.healthline.com/health/behind-the-neck-press',
        'https://archive.t-nation.com/training/tip-dont-fear-the-behind-the-neck-press/',
        'https://healtheh.com/blog/behind-the-neck-press',
        'https://www.menshealth.com/fitness/a41979316/behind-neck-press-alternatives/',
        'https://dumbbellsdirect.com/blogs/barbell-exercisesspecific-movements/behind-the-neck-press'
    ]
WHERE base_exercise_id = '39f0fbb0-f7f8-446e-95e3-eb88e745a7ee';

SELECT set_exercise_muscles(
    '39f0fbb0-f7f8-446e-95e3-eb88e745a7ee',
    ARRAY['shoulders'],
    ARRAY['triceps', 'traps', 'rotator_cuff', 'abs']
);

-- Bent-Knee Sit-Ups
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'bodyweight'),
    instructions = ARRAY[
        'Setup: Lie on mat with knees bent at 90-degree angle. Place feet flat on floor (can anchor if needed). Position hands lightly behind head OR crossed over chest. Press lower back into mat to engage core. Tuck chin slightly toward chest.',
        'Engage: Engage core muscles by drawing navel toward spine.',
        'Lift: Exhale and lift head, shoulders, and upper back off mat. Curl torso up toward thighs/knees. Lift hands toward or slightly past knees. Don''t sit all the way up—stop when hands touch/pass knees.',
        'Hold: Hold briefly at top.',
        'Lower: Inhale and slowly lower back down with control. Keep lower back pressed to mat throughout.',
        'Form Points: Hands support head weight but don''t pull on neck. Movement comes from abs, not momentum. Keep chin tucked in neutral position. Controlled tempo both directions. Full engagement of deep core muscles.',
        'SAFETY: Primary concern is neck strain from pulling with hands. Keep movements slow and controlled. Don''t anchor feet too securely (can over-activate hip flexors). May not be suitable for those with lower back issues. Ensure proper breathing throughout (don''t hold breath). Modern fitness experts often recommend planks/crunches as safer alternatives. Stop if you experience neck or lower back pain. Research shows bent-knee version activates abs more than hip flexors compared to straight-leg.'
    ],
    links = ARRAY[
        'https://dragogym.club/en/blog/sit-up-workout',
        'https://pubmed.ncbi.nlm.nih.gov/25970493/',
        'https://www.healthline.com/health/sit-ups-benefits',
        'https://www.menshealth.com/fitness/a20694953/bent-knee-situp/',
        'https://magmafitness.com/blogs/magma-blog/common-mistakes-to-avoid-when-doing-sit-ups'
    ]
WHERE base_exercise_id = 'f9abf9ce-fee7-4510-9739-e43272189e2e';

SELECT set_exercise_muscles(
    'f9abf9ce-fee7-4510-9739-e43272189e2e',
    ARRAY['abs'],
    ARRAY['obliques', 'hip_flexors', 'lower_back']
);

-- Straight-Leg Deadlifts
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Setup: Stand with feet hip-width apart. Grip barbell with hands shoulder-width apart (or slightly wider). Begin with barbell at hip level or on rack. Keep knees slightly bent ("soft knees" - not locked). Engage core and retract shoulder blades.',
        'Hinge: Brace core and maintain neutral spine. Hinge at hips and lean torso forward. Keep knees in slight bend throughout (don''t lock them).',
        'Lower: Lower barbell down toward floor along front of legs. Go only as far as hamstring flexibility allows while maintaining flat back. Stop when you feel significant hamstring stretch (typically mid-shin). Don''t round lower back at any point.',
        'Return: Drive hips forward to return to starting position. Squeeze glutes at top.',
        'Form Points: Movement is almost purely hip hinge (minimal knee involvement). Bar stays very close to body throughout. Back remains neutral/flat (no rounding). Range of motion varies based on hamstring flexibility.',
        'SAFETY - TECHNIQUE CRITICAL: LOWER BACK INJURY from rounding spine or using excessive weight. HAMSTRING TEARS/AVULSIONS from overstretching with poor flexibility. Risk significantly increases with tight hamstrings. Adequate hamstring flexibility is essential. Must maintain neutral spine throughout entire ROM. Don''t force depth beyond your flexibility. Start with light weight to master hip hinge pattern. Consider hamstring stretching protocol before implementing this exercise.',
        'EXPERT OPINIONS: Some experts consider it risky due to back stress potential. Others state it''s safe when performed with proper form and appropriate weight. General consensus: Higher injury risk than conventional deadlift if done incorrectly. Not recommended for beginners. Those with lower back issues should avoid or use extreme caution. Romanian Deadlift (RDL) is often considered safer alternative. Use lifting belt for heavy loads. Film yourself or work with coach to ensure neutral spine. When done properly: Excellent hamstring and posterior chain developer, can be as safe as conventional deadlifts, requires dedicated focus on form over weight.'
    ],
    links = ARRAY[
        'https://www.advancedhumanperformance.com/the-worst-way-to-perform-deadlifts-and-rdls',
        'https://www.strengthlog.com/stiff-legged-deadlift/',
        'https://barbend.com/stiff-leg-deadlift/',
        'https://fitnessvolt.com/stiff-leg-deadlift/',
        'https://legionathletics.com/stiff-leg-deadlift/'
    ]
WHERE base_exercise_id = '3df73c19-9001-4f2e-ae59-4bf185522d57';

SELECT set_exercise_muscles(
    '3df73c19-9001-4f2e-ae59-4bf185522d57',
    ARRAY['hamstrings', 'erector_spinae', 'glutes'],
    ARRAY['traps', 'rhomboids', 'forearms', 'abs', 'calves']
);

-- Dumbbell Pullovers
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbell'),
    instructions = ARRAY[
        'Setup: Lie supine (face up) on flat bench. Position head as close to end of bench as possible. Plant feet flat on floor. Hold one end of dumbbell with both hands, palms facing ceiling. Start with dumbbell directly over chest. Keep arms almost straight with slight elbow bend. Tuck shoulder blades down and together.',
        'Lower: Maintain slight elbow bend throughout movement. Lower dumbbell in arc motion over and behind head. Continue until biceps are next to ears or you feel deep stretch. Keep upper arms close to head.',
        'Stretch: Feel stretch in lats/chest for 1-2 seconds at bottom.',
        'Return: Reverse movement and return dumbbell over chest. Squeeze chest/lats at top position.',
        'Targeting: For Chest emphasis - Keep arms straighter (without locking), angle elbows outward. For Lat emphasis - Keep elbows bent more, keep dumbbell close to body, flare elbows out.',
        'SAFETY: Start with lighter weight to master movement pattern. Ensure dumbbell is secure in grip (use both hands on one end). Don''t drop weight behind head uncontrolled. Stop if you feel shoulder discomfort. While it works shoulders indirectly (via lat/tricep involvement), benefits shoulder mobility. Excellent "finisher" exercise after main pressing/pulling work. Research shows more effective for pecs than lats, despite working both.'
    ],
    links = ARRAY[
        'https://www.muscleandstrength.com/exercises/dumbbell-pullover.html',
        'https://www.ironmaster.com/blog/dumbbell-pullover-for-pecs-or-lats/',
        'https://learn.athleanx.com/articles/back-for-men/how-to-do-dumbbell-pullovers',
        'https://legionathletics.com/dumbbell-pullover/',
        'https://barbend.com/dumbbell-pullover-guide/'
    ]
WHERE base_exercise_id = '45a46ae8-09d3-4151-8b72-3f434165aade';

SELECT set_exercise_muscles(
    '45a46ae8-09d3-4151-8b72-3f434165aade',
    ARRAY['chest', 'lats'],
    ARRAY['triceps', 'abs', 'shoulders']
);

-- Wrist Curls
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbell'),
    instructions = ARRAY[
        'Setup (Seated Standard): Sit on weight bench. Rest forearm on thigh with wrist extending just beyond knee. Hold dumbbell with underhand grip (palms facing up). Let wrist hang in relaxed position.',
        'Execute Standard: Allow dumbbell to roll down toward fingertips. Slowly curl wrist upward, raising dumbbell. Lift as high as comfortably possible. Ensure forearm remains stationary (only wrist moves). Squeeze at top of movement. Slowly lower back to starting position.',
        'Reverse Wrist Curl (Extension): Turn hand so palm faces down (overhand grip). Allow dumbbell to roll toward palm/fingers. Slowly extend wrist upward (lift back of hand). Lower with control back to starting position.',
        'SAFETY: This is a small muscle group - use lighter weights than you think. Focus on higher reps (12-20) with controlled tempo. Emphasize time under tension over heavy weight. For progressive overload, increase reps or reduce rest time rather than adding weight. Slow, controlled movements prevent muscle strain. Excellent for grip strength development. Important for rock climbers, martial artists, and those doing heavy lifting. Can help prevent/rehab tennis elbow and other forearm issues when done properly.'
    ],
    links = ARRAY[
        'https://www.ifastfitness.com/blogs/blog/how-to-do-wrist-curl',
        'https://learn.athleanx.com/articles/how-to-do-wrist-curls',
        'https://www.menshealth.com/fitness/a42551348/why-its-time-to-drop-the-wrist-curl-and-try-these-3-moves/',
        'https://www.livestrong.com/article/13767452-wrist-curls/',
        'https://squatwolf.com/blogs/fitness/wrist-curls'
    ]
WHERE base_exercise_id = 'a2a36126-07e2-4104-a1e4-5671484dab17';

SELECT set_exercise_muscles(
    'a2a36126-07e2-4104-a1e4-5671484dab17',
    ARRAY['forearms'],
    ARRAY[]::text[]
);

-- ============================================================================
-- Summary
-- ============================================================================
-- Total exercises updated: 31
-- Kettlebell exercises: 4 (Turkish Get-Up, One-Arm Swing, Halos, Prying Goblet Squat)
-- CrossFit/Functional: 6 (Wall Balls, Box Jumps, Burpees, HSPU, T2B, Thruster)
-- Specialty Barbell: 3 (Floor Press, Board Press, SSB Squats)
-- Accessory: 4 (Cable Kickbacks, Ab Wheel, Hip Bridges, Split Squats)
-- Grip Variations: 1 (Wide-Grip Pull-Ups)
-- Pressing Variations: 13 (Wide/Close-Grip Bench, Incline Barbell Bench, Dumbbell Row,
--                           Close-Grip Pulldown, Machine Chest Press, Rack Chins,
--                           Cable Pressdown, BTN Press, Bent-Knee Sit-Ups, Straight-Leg DL,
--                           Dumbbell Pullovers, Wrist Curls)
