-- ============================================================================
-- Compound Exercise Metadata Migration
-- Created: 2025-11-23
-- Description: Populates metadata for 15 compound exercises including:
--              - Exercise attributes (level, mechanic, force, category, equipment)
--              - Step-by-step instructions
--              - Primary and secondary muscle groups
-- Source: /home/user/workout_app/docs/exercise-metadata/compound-exercises.md
-- ============================================================================

-- ============================================================================
-- PULL-UPS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'pull_up_bar'),
    instructions = ARRAY[
        'Step up and grasp bar with overhand wide grip (slightly wider than shoulder-width)',
        'Hang with arms and shoulders fully extended, engage your core',
        'Pull your body up by driving elbows down and back until chin is above bar',
        'Keep chest up and squeeze shoulder blades together at top',
        'Lower body with control until arms and shoulders are fully extended',
        'Maintain straight body alignment throughout - point toes, straighten knees, squeeze glutes',
        'Avoid swinging or using momentum',
        'Repeat for desired repetitions'
    ]
WHERE base_exercise_id = 'ebb32783-f125-4242-a0ad-17912534d844'; -- Pull-ups

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('ebb32783-f125-4242-a0ad-17912534d844',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'), 0)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('ebb32783-f125-4242-a0ad-17912534d844',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'), 0),
    ('ebb32783-f125-4242-a0ad-17912534d844',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'forearms'), 1),
    ('ebb32783-f125-4242-a0ad-17912534d844',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'), 2),
    ('ebb32783-f125-4242-a0ad-17912534d844',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'rhomboids'), 3),
    ('ebb32783-f125-4242-a0ad-17912534d844',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'), 4)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- CHIN-UPS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'pull_up_bar'),
    instructions = ARRAY[
        'Grasp bar with underhand (supinated) grip, hands about shoulder-width apart',
        'Pull shoulder blades back and down, bring chest up with head looking forward',
        'Hang with arms fully extended, inhale and engage core',
        'Initiate pull by driving shoulder blades down and elbows toward body',
        'Continue pulling until collar bone reaches the bar',
        'Squeeze upper back and lat muscles at the top',
        'Slowly lower body back to starting position with control',
        'Allow shoulder blades to move away from spine as you descend',
        'Repeat without momentum or swinging'
    ]
WHERE base_exercise_id = 'b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac'; -- Chin-ups

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'), 0),
    ('b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'forearms'), 0),
    ('b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'), 1),
    ('b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'rhomboids'), 2),
    ('b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'), 3),
    ('b3b2de3d-7f75-4a92-81c0-dcc22f57c3ac',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'), 4)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- FRONT SQUAT
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Set barbell in squat rack at upper chest height',
        'Step under bar and position it across front deltoids and clavicles (front rack position)',
        'Use clean grip (fingers under bar) or cross-arm grip based on mobility',
        'Lift elbows high to create a shelf for the bar, keeping upper back tight',
        'Unrack the bar and step back, feet shoulder-width apart, toes slightly out',
        'Keep head facing forward, chest up, and core braced',
        'Descend by breaking at knees and hips simultaneously, keeping torso upright',
        'Lower until thighs are at least parallel to floor, maintaining elevated elbows',
        'Drive through heels and midfoot to return to standing position',
        'Keep knees tracking over toes throughout movement'
    ]
WHERE base_exercise_id = '10845aff-07ac-4359-a8dd-ce99442e33d5'; -- Front Squat

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('10845aff-07ac-4359-a8dd-ce99442e33d5',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 0),
    ('10845aff-07ac-4359-a8dd-ce99442e33d5',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('10845aff-07ac-4359-a8dd-ce99442e33d5',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('10845aff-07ac-4359-a8dd-ce99442e33d5',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 1),
    ('10845aff-07ac-4359-a8dd-ce99442e33d5',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 2),
    ('10845aff-07ac-4359-a8dd-ce99442e33d5',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'adductors'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- DIPS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dip_station'),
    instructions = ARRAY[
        'Mount dip bars with arms straight, shoulders positioned above hands',
        'For triceps emphasis: Keep torso upright and elbows close to body',
        'For chest emphasis: Lean forward slightly and allow elbows to flare out',
        'Lower body by bending arms until shoulders are slightly below elbows or slight stretch in chest',
        'Maintain control throughout descent - don''t drop too fast',
        'Press through hands to extend arms and return to starting position',
        'Keep core engaged and avoid excessive swinging',
        'Fully extend arms at top without locking out aggressively',
        'Repeat for desired repetitions'
    ]
WHERE base_exercise_id = '2659f231-981f-4f2f-ba3f-1e4fa12728bc'; -- Dips

-- Insert primary muscles (can target either triceps or chest depending on form)
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('2659f231-981f-4f2f-ba3f-1e4fa12728bc',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'), 0),
    ('2659f231-981f-4f2f-ba3f-1e4fa12728bc',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('2659f231-981f-4f2f-ba3f-1e4fa12728bc',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'), 0),
    ('2659f231-981f-4f2f-ba3f-1e4fa12728bc',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'rhomboids'), 1),
    ('2659f231-981f-4f2f-ba3f-1e4fa12728bc',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'lats'), 2)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- ROMANIAN DEADLIFT (RDL)
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Start standing upright holding barbell at thigh height (use rack to start at proper height)',
        'Stand with feet hip-width apart, slight bend in knees (about 15 degrees)',
        'Maintain this knee angle throughout - knees stay locked at slight bend',
        'Brace core and pull shoulder blades back, maintaining neutral spine',
        'Hinge at hips, pushing them backward as you lower the bar',
        'Keep bar close to body as it travels down shins, maintaining flat back',
        'Lower until you feel deep stretch in hamstrings (typically when bar reaches mid-shin or weights touch floor)',
        'Stop when hamstrings are at full length or torso is parallel to ground',
        'Squeeze glutes and drive hips forward to return to starting position',
        'Take 2-3 seconds on the descent, maintain control throughout'
    ]
WHERE base_exercise_id = 'ebe84120-4658-49f9-b15c-c3fc72dd6608'; -- Romanian Deadlift

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('ebe84120-4658-49f9-b15c-c3fc72dd6608',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('ebe84120-4658-49f9-b15c-c3fc72dd6608',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1),
    ('ebe84120-4658-49f9-b15c-c3fc72dd6608',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 2)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('ebe84120-4658-49f9-b15c-c3fc72dd6608',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'adductors'), 0),
    ('ebe84120-4658-49f9-b15c-c3fc72dd6608',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'), 1),
    ('ebe84120-4658-49f9-b15c-c3fc72dd6608',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'forearms'), 2),
    ('ebe84120-4658-49f9-b15c-c3fc72dd6608',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- POWER CLEAN
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'expert',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'power'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Stand with feet hip-width apart, bar over arches of feet, toes slightly out',
        'Grip bar just outside thighs with overhand grip (hook grip recommended)',
        'Squat down with chest up, shoulders over bar, arms straight, back flat',
        'Begin pull by driving through floor with legs, maintaining back angle',
        'As bar passes knees, explosively extend hips, knees, and ankles (triple extension)',
        'Keep bar close to body throughout pull - should brush thighs',
        'Once fully extended, pull elbows up and out to begin moving under bar',
        'Quickly move feet into receiving stance and drop into partial squat',
        'Catch bar on front of shoulders in front rack position with elbows high',
        'Stand to complete the lift',
        'Lower bar back to starting position with control'
    ]
WHERE base_exercise_id = 'f9d74097-5636-43ed-84d5-a458c56b3b5b'; -- Power Clean

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 0),
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1),
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 2),
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'), 0),
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'), 1),
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'), 2),
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 3),
    ('f9d74097-5636-43ed-84d5-a458c56b3b5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'forearms'), 4)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- GOOD MORNINGS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Set barbell in squat rack at shoulder height',
        'Position bar on upper back (similar to back squat position)',
        'Unrack bar and step back with feet hip to shoulder-width apart',
        'Maintain slight bend in knees (soft knees, not locked)',
        'Keep back straight with slight arch, shoulder blades squeezed',
        'Brace core and maintain neutral spine throughout',
        'Hinge at hips, pushing butt back (not bending at waist)',
        'Lower torso forward until parallel to floor or mild stretch in hamstrings',
        'Stop before losing neutral spine or excessive hamstring stretch',
        'Drive hips forward to return to starting position',
        'Keep knees and back position constant throughout movement'
    ]
WHERE base_exercise_id = '11dc85bd-96e4-4b57-a0c0-84872acb61c6'; -- Good Mornings

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('11dc85bd-96e4-4b57-a0c0-84872acb61c6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('11dc85bd-96e4-4b57-a0c0-84872acb61c6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 1),
    ('11dc85bd-96e4-4b57-a0c0-84872acb61c6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 2)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('11dc85bd-96e4-4b57-a0c0-84872acb61c6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'adductors'), 0),
    ('11dc85bd-96e4-4b57-a0c0-84872acb61c6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- BOX SQUATS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Position box or bench behind squat rack at appropriate height (typically parallel or slightly below)',
        'Set up barbell on back as for regular squat',
        'Unrack bar and position yourself so box is directly behind you',
        'Stand with feet shoulder-width or slightly wider, toes out',
        'Keep head facing forward, back straight, feet flat on floor',
        'Descend by sitting back and down, maintaining upright torso',
        'Keep knees apart, tracking over toes throughout movement',
        'Sit down on box with control - do NOT fall onto or bounce off box',
        'Pause briefly on box while maintaining tension',
        'Explode upward by driving through feet to return to standing',
        'Break the eccentric/concentric chain with the pause for explosive strength'
    ]
WHERE base_exercise_id = 'e0f8bfdb-4e94-40a4-90e6-b535f3a893fa'; -- Box Squats

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('e0f8bfdb-4e94-40a4-90e6-b535f3a893fa',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 0),
    ('e0f8bfdb-4e94-40a4-90e6-b535f3a893fa',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('e0f8bfdb-4e94-40a4-90e6-b535f3a893fa',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('e0f8bfdb-4e94-40a4-90e6-b535f3a893fa',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 1),
    ('e0f8bfdb-4e94-40a4-90e6-b535f3a893fa',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hip_flexors'), 2),
    ('e0f8bfdb-4e94-40a4-90e6-b535f3a893fa',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'adductors'), 3),
    ('e0f8bfdb-4e94-40a4-90e6-b535f3a893fa',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 4)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- GLUTE-HAM RAISE (GHR)
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'expert',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'machine'),
    instructions = ARRAY[
        'Adjust GHD so knees are just behind the pad and feet are secure between ankle pads',
        'Position thighs (just above knees) pressed against pad, feet flat against platform',
        'Start with knees bent, hips extended, torso upright (or start parallel to ground depending on variation)',
        'Lower upper body to floor with control, keeping back straight and core tight',
        'Avoid letting hips drop or sag - maintain straight body line',
        'Use hamstrings to pull torso back up to starting position',
        'Do not lock out knees at bottom - maintain tension in hamstrings',
        'Repeat with control - this is an extremely difficult movement'
    ]
WHERE base_exercise_id = 'b0507715-5e1a-43cb-9697-0d15e4740ed6'; -- Glute-Ham Raise

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('b0507715-5e1a-43cb-9697-0d15e4740ed6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('b0507715-5e1a-43cb-9697-0d15e4740ed6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('b0507715-5e1a-43cb-9697-0d15e4740ed6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'), 0),
    ('b0507715-5e1a-43cb-9697-0d15e4740ed6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 1),
    ('b0507715-5e1a-43cb-9697-0d15e4740ed6',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 2)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- BULGARIAN SPLIT SQUATS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'bench'),
    instructions = ARRAY[
        'Set bench or box at knee height (approximately)',
        'Stand facing away from bench, 2-3 feet in front of it',
        'Place rear foot (laces down) on bench for balance',
        'Position front foot so knee will be directly above ankle at bottom',
        'Test a few reps to find ideal stance - back knee should be under hips at bottom',
        'Hold dumbbells at sides, barbell on back, or use bodyweight only',
        'Keep torso upright with slight forward lean acceptable, maintain neutral spine',
        'Engage core and descend by flexing front knee',
        'Lower until back knee lightly touches ground beneath hip',
        'Back leg provides minimal support - this is a single-leg movement',
        'Drive through front heel to return to starting position',
        'Keep front knee tracking over toes, not past toes',
        'Maintain vertical drive path - not pushing forward or backward',
        'Complete all reps on one side before switching'
    ]
WHERE base_exercise_id = '96d6be35-ae4e-4174-872e-c28764998a1a'; -- Bulgarian Split Squats

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('96d6be35-ae4e-4174-872e-c28764998a1a',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 0),
    ('96d6be35-ae4e-4174-872e-c28764998a1a',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('96d6be35-ae4e-4174-872e-c28764998a1a',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('96d6be35-ae4e-4174-872e-c28764998a1a',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'adductors'), 1),
    ('96d6be35-ae4e-4174-872e-c28764998a1a',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'), 2),
    ('96d6be35-ae4e-4174-872e-c28764998a1a',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- WALKING LUNGES
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbell'),
    instructions = ARRAY[
        'Stand tall with feet about shoulder-width apart',
        'Hold dumbbells at sides, barbell on back, or hands on hips',
        'Brace core and maintain upright torso throughout',
        'Take a large step forward with one leg (not too far to overextend)',
        'Lower body by bending both knees until front thigh is parallel to floor',
        'Back knee should be bent with shin parallel to floor, hovering above ground',
        'Keep front knee tracking over toes, not past toes',
        'Maintain upright torso - avoid leaning too far forward or backward',
        'Step your foot in line with your hip, not crossing centerline',
        'Push through front foot to stand and step back leg forward into next lunge',
        'Continue alternating legs, "walking" forward',
        'Keep hips squared and facing forward throughout',
        'Maintain core engagement and stable torso'
    ]
WHERE base_exercise_id = '4be09662-74c5-4b7c-ad35-37848e4248e8'; -- Walking Lunges

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('4be09662-74c5-4b7c-ad35-37848e4248e8',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 0),
    ('4be09662-74c5-4b7c-ad35-37848e4248e8',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('4be09662-74c5-4b7c-ad35-37848e4248e8',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('4be09662-74c5-4b7c-ad35-37848e4248e8',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'), 1),
    ('4be09662-74c5-4b7c-ad35-37848e4248e8',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hip_flexors'), 2),
    ('4be09662-74c5-4b7c-ad35-37848e4248e8',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- SUMO DEADLIFTS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Stand with feet wider than shoulder-width (1.5-2x shoulder width)',
        'Point toes outward at 30-45 degree angle',
        'Bar should be close to shins, approximately over middle of feet',
        'Squat down and grip bar with hands inside legs, shoulder-width or narrower',
        'Position hips closer to bar than conventional deadlift, more upright torso',
        'Keep chest up, shoulders over or slightly in front of bar, back flat',
        'Brace core and engage lats - "pull slack out of bar"',
        'Drive through heels and push knees out to initiate lift',
        'Keep bar close to body as it travels up shins',
        'Extend hips and knees simultaneously to stand upright',
        'Squeeze glutes at top for full lockout',
        'Lower bar with control by pushing hips back and bending knees'
    ]
WHERE base_exercise_id = 'cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9'; -- Sumo Deadlifts

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 0),
    ('cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1),
    ('cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'adductors'), 2)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 1),
    ('cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'), 2),
    ('cc5ff2d7-f26d-49db-9978-c9d76eb7a5f9',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'forearms'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- PUSH PRESS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'power'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Set barbell in squat rack at upper chest height',
        'Position bar on front of shoulders in front rack position',
        'Unrack and step back with feet hip to shoulder-width apart',
        'Keep elbows slightly in front of bar, core tight',
        'Perform small, controlled knee bend - quarter squat depth',
        'Keep torso upright during dip, don''t lean forward',
        'Explosively extend hips, knees, and ankles (drive through heels)',
        'As momentum carries bar upward, press bar overhead',
        'Press bar in straight vertical line, moving head slightly back',
        'Lock out arms fully overhead with bar over mid-foot',
        'Lower bar back to front rack position with control',
        'Reset and repeat - the dip should be quick and shallow'
    ]
WHERE base_exercise_id = 'fe537e1e-1313-4419-a26f-26adca068352'; -- Push Press

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('fe537e1e-1313-4419-a26f-26adca068352',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'), 0),
    ('fe537e1e-1313-4419-a26f-26adca068352',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'triceps'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('fe537e1e-1313-4419-a26f-26adca068352',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'chest'), 0),
    ('fe537e1e-1313-4419-a26f-26adca068352',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'), 1),
    ('fe537e1e-1313-4419-a26f-26adca068352',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 2),
    ('fe537e1e-1313-4419-a26f-26adca068352',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 3),
    ('fe537e1e-1313-4419-a26f-26adca068352',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 4),
    ('fe537e1e-1313-4419-a26f-26adca068352',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'), 5)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- PAUSE SQUATS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Set up barbell on back exactly as you would for regular back squat',
        'Unrack and position feet shoulder-width apart, toes slightly out',
        'Descend into squat with normal controlled tempo',
        'Upon reaching bottom position (thighs parallel or below), stop all movement',
        'Hold motionless pause for 2-3 seconds minimum',
        'Relax legs as much as possible while maintaining tight, braced trunk',
        'Do NOT let hips sink lower or position shift during pause',
        'Eliminate any stretch reflex with the pause duration',
        'After pause, drive up explosively with maximum force',
        'Maintain straight vertical bar path during ascent',
        'Complete rep at full standing position',
        'Repeat for programmed repetitions'
    ]
WHERE base_exercise_id = 'b15b673e-1174-45b9-b810-65ca02afd727'; -- Pause Squats

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('b15b673e-1174-45b9-b810-65ca02afd727',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 0),
    ('b15b673e-1174-45b9-b810-65ca02afd727',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('b15b673e-1174-45b9-b810-65ca02afd727',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 0),
    ('b15b673e-1174-45b9-b810-65ca02afd727',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 1),
    ('b15b673e-1174-45b9-b810-65ca02afd727',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 2),
    ('b15b673e-1174-45b9-b810-65ca02afd727',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'adductors'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- TRAP BAR DEADLIFTS
-- ============================================================================

-- Update base exercise metadata
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'trap_bar'),
    instructions = ARRAY[
        'Load trap bar with appropriate weight plates',
        'Step inside the center of the trap bar',
        'Position feet hip to shoulder-width apart, directly under hips',
        'Squat down and grasp handles with neutral grip (palms facing inward)',
        'Assume position with hips between high (deadlift) and low (squat)',
        'Keep chest up, shoulders back, spine neutral, core braced',
        'Take deep breath and engage core maximally',
        'Drive through mid-foot and heels, extending hips and knees simultaneously',
        'Stand up to full height with hips fully extended',
        'Shoulders and hips should rise at same rate - torso angle stays constant',
        'Lower weight back down with control, maintaining neutral spine',
        'Weight should remain centered around body throughout movement'
    ]
WHERE base_exercise_id = 'afef5a3a-0e6a-4a23-83b3-f76028235c5b'; -- Trap Bar Deadlifts

-- Insert primary muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'quadriceps'), 0),
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'glutes'), 1),
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'hamstrings'), 2),
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'erector_spinae'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- Insert secondary muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
VALUES
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'traps'), 0),
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'forearms'), 1),
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'abs'), 2),
    ('afef5a3a-0e6a-4a23-83b3-f76028235c5b',
     (SELECT muscle_group_id FROM muscle_group WHERE name = 'calves'), 3)
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- ============================================================================
-- Migration Summary
-- ============================================================================

-- This migration has populated metadata for 15 compound exercises:
-- 1. Pull-ups (intermediate, pull, bodyweight)
-- 2. Chin-ups (intermediate, pull, bodyweight)
-- 3. Front Squat (intermediate, push, barbell)
-- 4. Dips (intermediate, push, dip station)
-- 5. Romanian Deadlift (intermediate, pull, barbell)
-- 6. Power Clean (expert, pull, barbell) - categorized as 'power'
-- 7. Good Mornings (intermediate, pull, barbell)
-- 8. Box Squats (intermediate, push, barbell)
-- 9. Glute-Ham Raise (expert, pull, machine)
-- 10. Bulgarian Split Squats (intermediate, push, bench)
-- 11. Walking Lunges (intermediate, push, dumbbell)
-- 12. Sumo Deadlifts (intermediate, pull, barbell)
-- 13. Push Press (intermediate, push, barbell) - categorized as 'power'
-- 14. Pause Squats (intermediate, push, barbell)
-- 15. Trap Bar Deadlifts (intermediate, pull, trap bar)

-- Each exercise now includes:
-- - Difficulty level (intermediate or expert)
-- - Mechanic type (compound)
-- - Force direction (push or pull)
-- - Exercise category (strength or power)
-- - Required equipment type
-- - 8-14 detailed instruction steps
-- - Primary muscle groups (1-4 muscles)
-- - Secondary muscle groups (2-6 muscles)

-- All inserts use ON CONFLICT DO NOTHING to ensure idempotency
-- Equipment and muscle references use SELECT subqueries for reliability
