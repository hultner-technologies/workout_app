-- Isolation & Accessory Exercise Metadata Migration
-- Created: 2025-11-23
-- Purpose: Populate metadata for 20 isolation and accessory exercises
-- Source: /docs/exercise-metadata/isolation-exercises.md

-- =============================================================================
-- REFERENCE DATA: Muscle Groups
-- =============================================================================

-- Insert muscle groups (only if not already present)
INSERT INTO muscle_group (name, display_name, description)
VALUES
    ('posterior_deltoids', 'Posterior Deltoids', 'Rear shoulder muscles'),
    ('rhomboids', 'Rhomboids', 'Upper back muscles between shoulder blades'),
    ('middle_trapezius', 'Middle Trapezius', 'Middle portion of trapezius muscle'),
    ('lower_trapezius', 'Lower Trapezius', 'Lower portion of trapezius muscle'),
    ('rotator_cuff', 'Rotator Cuff', 'Shoulder stabilizer muscles'),
    ('teres_major', 'Teres Major', 'Shoulder muscle'),
    ('triceps_brachii', 'Triceps Brachii', 'Three-headed arm extensor muscle'),
    ('anconeus', 'Anconeus', 'Small elbow extensor muscle'),
    ('forearm_extensors', 'Forearm Extensors', 'Wrist and finger extensor muscles'),
    ('quadriceps', 'Quadriceps', 'Four-headed thigh muscles'),
    ('vastus_lateralis', 'Vastus Lateralis', 'Outer quad muscle'),
    ('vastus_medialis', 'Vastus Medialis', 'Inner quad muscle'),
    ('vastus_intermedius', 'Vastus Intermedius', 'Deep quad muscle'),
    ('rectus_femoris', 'Rectus Femoris', 'Quad muscle crossing hip and knee'),
    ('gluteus_maximus', 'Gluteus Maximus', 'Large buttock muscle'),
    ('hamstrings', 'Hamstrings', 'Posterior thigh muscles'),
    ('biceps_femoris', 'Biceps Femoris', 'Lateral hamstring muscle'),
    ('semitendinosus', 'Semitendinosus', 'Medial hamstring muscle'),
    ('semimembranosus', 'Semimembranosus', 'Medial hamstring muscle'),
    ('adductors', 'Adductors', 'Inner thigh muscles'),
    ('adductor_magnus', 'Adductor Magnus', 'Large inner thigh muscle'),
    ('calves', 'Calves', 'Lower leg muscles'),
    ('gastrocnemius', 'Gastrocnemius', 'Upper calf muscle'),
    ('soleus', 'Soleus', 'Deep calf muscle'),
    ('core_stabilizers', 'Core Stabilizers', 'Abdominal and trunk stabilizer muscles'),
    ('biceps_brachii', 'Biceps Brachii', 'Two-headed arm flexor muscle'),
    ('brachialis', 'Brachialis', 'Deep elbow flexor muscle'),
    ('brachioradialis', 'Brachioradialis', 'Forearm muscle'),
    ('forearm_flexors', 'Forearm Flexors', 'Wrist and finger flexor muscles'),
    ('wrist_stabilizers', 'Wrist Stabilizers', 'Wrist stabilizer muscles'),
    ('erector_spinae', 'Erector Spinae', 'Lower back muscles'),
    ('multifidus', 'Multifidus', 'Deep spinal stabilizer'),
    ('quadratus_lumborum', 'Quadratus Lumborum', 'Deep lower back muscle'),
    ('pectoralis_major', 'Pectoralis Major', 'Large chest muscle'),
    ('pectoralis_minor', 'Pectoralis Minor', 'Small chest muscle'),
    ('sternal_head', 'Sternal Head', 'Lower portion of pectoralis major'),
    ('clavicular_head', 'Clavicular Head', 'Upper portion of pectoralis major'),
    ('anterior_deltoids', 'Anterior Deltoids', 'Front shoulder muscles'),
    ('serratus_anterior', 'Serratus Anterior', 'Side chest muscle'),
    ('lateral_deltoids', 'Lateral Deltoids', 'Side shoulder muscles'),
    ('upper_trapezius', 'Upper Trapezius', 'Upper portion of trapezius'),
    ('latissimus_dorsi', 'Latissimus Dorsi', 'Large back muscles'),
    ('tibialis_posterior', 'Tibialis Posterior', 'Deep calf muscle')
ON CONFLICT (name) DO NOTHING;

-- =============================================================================
-- REFERENCE DATA: Equipment Types
-- =============================================================================

-- Insert equipment types (only if not already present)
INSERT INTO equipment_type (name, display_name, description)
VALUES
    ('cable_machine', 'Cable Machine', 'Cable pulley system for resistance exercises'),
    ('resistance_band', 'Resistance Band', 'Elastic band for resistance training'),
    ('leg_extension_machine', 'Leg Extension Machine', 'Machine for isolated quadriceps work'),
    ('leg_press_machine', 'Leg Press Machine', 'Machine for compound leg exercises'),
    ('dumbbells', 'Dumbbells', 'Free weight handheld equipment'),
    ('hyperextension_bench', 'Hyperextension Bench', '45-degree bench for back extensions'),
    ('flat_bench', 'Flat Bench', 'Horizontal bench for various exercises'),
    ('incline_bench', 'Incline Bench', 'Adjustable angle bench'),
    ('decline_bench', 'Decline Bench', 'Negative angle bench'),
    ('barbell', 'Barbell', 'Long bar with weight plates'),
    ('ez_bar', 'EZ Curl Bar', 'Curved barbell for arm exercises'),
    ('power_rack', 'Power Rack', 'Squat rack with safety pins'),
    ('preacher_bench', 'Preacher Bench', 'Scott bench for arm isolation'),
    ('seated_calf_machine', 'Seated Calf Raise Machine', 'Machine for seated calf raises'),
    ('dual_cable_machine', 'Dual Cable Machine', 'Cable machine with two independent pulleys')
ON CONFLICT (name) DO NOTHING;

-- =============================================================================
-- REFERENCE DATA: Exercise Category
-- =============================================================================

-- Insert exercise category (only if not already present)
INSERT INTO exercise_category (name, display_name, description)
VALUES
    ('strength', 'Strength Training', 'Resistance exercises for muscle building and strength'),
    ('isolation', 'Isolation Exercise', 'Single-joint exercises targeting specific muscles'),
    ('accessory', 'Accessory Exercise', 'Supporting exercises for main lifts')
ON CONFLICT (name) DO NOTHING;

-- =============================================================================
-- EXERCISE METADATA: Base Exercise Updates
-- =============================================================================

-- 1. Face Pulls
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable_machine'),
    instructions = ARRAY[
        'Position cable pulley at top position, just above head height',
        'Attach rope accessory and grasp each end with overhand or underhand grip',
        'Take several steps back until weight comes off stack, arms extended in front',
        'Pull rope handles toward your forehead/face while keeping elbows high',
        'Externally rotate shoulders as you pull, separating the rope ends',
        'Hold briefly at peak contraction, then return to start with control'
    ]
WHERE base_exercise_id = '34bd3f09-0a5a-480b-b450-746b1e5c7274';

-- 2. Tricep Pushdowns
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable_machine'),
    instructions = ARRAY[
        'Position cable attachment at upper position on cable machine',
        'Grasp attachment with overhand grip, hands at comfortable width',
        'Tuck elbows at your sides, positioned directly in front of hips',
        'Push attachment down explosively until arms are fully extended',
        'Pause briefly at bottom, maximally contracting triceps',
        'Return to starting position slowly and controlled (2-3 second eccentric)'
    ]
WHERE base_exercise_id = 'b5d34436-b28a-41cb-bfd1-93051e352f3f';

-- 3. Leg Extension
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'leg_extension_machine'),
    instructions = ARRAY[
        'Adjust machine seat so knees align with machine''s pivot point',
        'Set pad position to rest on top of shins just above ankles',
        'Grip handles at sides of seat for stability',
        'Engage core and extend both legs simultaneously',
        'Lift pad until legs are completely straight (full extension)',
        'Hold peak contraction for 1 second, squeeze quadriceps hard',
        'Lower weight back to starting position in controlled manner'
    ]
WHERE base_exercise_id = '08562f83-66ea-49d9-bbf8-89cde104a5a7';

-- 4. Leg Press
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'compound',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'leg_press_machine'),
    instructions = ARRAY[
        'Adjust seat so knees are at 90-degree angle when feet are on platform',
        'Place feet on platform at desired width and height',
        'Keep back and head pressed firmly against pad throughout movement',
        'Release safety handles and lower platform with control',
        'Lower until knees reach approximately 90 degrees',
        'Push platform away by extending legs, driving through heels',
        'Maintain constant core tension and avoid rounding lower back'
    ]
WHERE base_exercise_id = '5270cfc0-31a3-458e-9baf-62803346d03f';

-- 5. Cable Curls
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable_machine'),
    instructions = ARRAY[
        'Attach desired handle to low cable pulley position',
        'Stand facing cable machine, grasp handle with underhand grip',
        'Keep elbows tucked at sides, positioned just in front of hips',
        'Engage core, maintain neutral spine throughout movement',
        'Curl bar toward chest by bending elbows, keeping upper arms stationary',
        'Squeeze biceps hard at peak contraction',
        'Lower weight with control, resisting the negative for 2-3 seconds'
    ]
WHERE base_exercise_id = 'e4977b90-62d6-4465-b50c-49bd1d6a61be';

-- 6. Hammer Curls
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbells'),
    instructions = ARRAY[
        'Stand with feet shoulder-width apart holding dumbbells at sides',
        'Grip dumbbells with neutral grip (palms facing inward/toward body)',
        'Keep elbows locked close to sides throughout entire movement',
        'Curl dumbbells up toward shoulders, keeping neutral grip',
        'Lift until forearms are roughly parallel to floor',
        'Squeeze brachialis and forearms at top, hold for 1-2 seconds',
        'Lower dumbbells with control back to starting position'
    ]
WHERE base_exercise_id = '62fe9884-1c76-4224-af6e-8cd05a17e385';

-- 7. Hyperextensions
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'accessory'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'hyperextension_bench'),
    instructions = ARRAY[
        'Position yourself in hyperextension machine with feet anchored',
        'Adjust pad so hips rest on pad at 45-degree angle',
        'Cross arms over chest or behind head',
        'Initiate movement by flexing glutes and engaging hamstrings',
        'Extend hips to raise torso until body forms straight line',
        'Avoid overextending lower back past neutral spine',
        'Lower with control back to starting position'
    ]
WHERE base_exercise_id = 'cad62a1a-538f-408a-95d3-de74f54f6710';

-- 8. Dumbbell Flyes
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'isolation',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbells'),
    instructions = ARRAY[
        'Lie back on flat bench with dumbbell in each hand',
        'Drive shoulder blades back into bench to set stable shoulder position',
        'Press dumbbells to starting position above chest, arms extended',
        'Maintain slight bend in elbows (forearms perpendicular to ground)',
        'Lower weights out to sides in wide arc, moving only at shoulders',
        'Lower to comfortable point where you feel deep stretch on chest',
        'Bring weights back together using chest adduction (not pressing)',
        'Stop weights just before they touch at top, maintaining tension'
    ]
WHERE base_exercise_id = '1e4eee1f-d2fd-4b66-94b7-1de2ac4484c9';

-- 9. Upright Rows
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Stand with feet shoulder-width apart',
        'Grip barbell with hands slightly narrower than shoulder-width',
        'Let barbell hang at arm''s length in front of thighs',
        'Keep bar close to torso throughout movement',
        'Pull barbell upward toward chin, leading with elbows',
        'Stop when elbows are level with shoulders (not higher)',
        'Lower barbell with control back to starting position'
    ]
WHERE base_exercise_id = 'd4cbce8f-0a69-4274-84eb-171bd63c7429';

-- 10. Rack Pulls
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'power_rack'),
    instructions = ARRAY[
        'Set safety pins in power rack at knee height',
        'Load barbell on pins and position yourself with barbell against body',
        'Grip barbell just outside thighs with overhand or mixed grip',
        'Position shoulders slightly in front of bar',
        'Brace core and maintain neutral spine',
        'Initiate pull by driving hips forcefully toward bar',
        'Pull bar up along body to full lockout',
        'Squeeze traps and upper back hard at top',
        'Lower with control back to pins'
    ]
WHERE base_exercise_id = '17724820-ed82-4129-adba-8805a7912b65';

-- 11. Pendlay Rows
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Stand with feet hip-width apart, barbell on floor in front of you',
        'Bend at hips with back flat and parallel to floor',
        'Grip barbell with overhand grip, hands just wider than shoulder-width',
        'Keep core activated and back braced in rigid position',
        'Pull barbell explosively from floor toward lower chest',
        'Drive elbows behind you as you lift, hinging at elbows',
        'Touch bar to chest/upper abdomen at top',
        'Lower barbell all the way back to floor with control',
        'Reset completely between each rep (dead stop)'
    ]
WHERE base_exercise_id = '72422027-c5dc-4364-bcf7-bc6f37081faa';

-- 12. Reverse Flyes
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbells'),
    instructions = ARRAY[
        'Hinge from hips until torso is almost parallel to floor',
        'Hold dumbbells with arms hanging straight down from shoulders',
        'Keep slight bend in elbows throughout movement',
        'Maintain flat back and engaged core',
        'Pull dumbbells laterally out to sides and upward',
        'Lead with elbows, focusing on rear delts',
        'Lift until arms are roughly parallel to floor',
        'Squeeze rear delts and upper back at top',
        'Lower with control back to starting position'
    ]
WHERE base_exercise_id = '07765c6b-af9d-4637-bfdc-3924a6e0699a';

-- 13. Concentration Curls
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dumbbells'),
    instructions = ARRAY[
        'Sit on end of flat bench with legs spread apart',
        'Hold dumbbell in one hand with arm hanging between legs',
        'Brace elbow against inside of same-side thigh',
        'Extend arm fully at bottom, palm facing away from body',
        'Curl dumbbell up toward shoulder in strict arc',
        'Focus intensely on bicep contraction',
        'Squeeze hard at top for 1-2 seconds',
        'Lower dumbbell slowly and controlled to full extension'
    ]
WHERE base_exercise_id = '458fcd22-1454-468e-85e1-2ab3f1dcd107';

-- 14. Lying Tricep Extensions (Skullcrushers)
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'isolation',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'ez_bar'),
    instructions = ARRAY[
        'Lie flat on bench with feet firmly planted on floor',
        'Hold EZ bar with close grip (hands 6-8 inches apart)',
        'Press bar to starting position with arms extended above chest',
        'Angle arms slightly back toward head (not perpendicular to body)',
        'Lower bar by bending only at elbows',
        'Lower bar toward forehead or just behind top of head',
        'Pause briefly at bottom stretch',
        'Extend arms back to starting position by contracting triceps'
    ]
WHERE base_exercise_id = 'fff636b5-bec0-447f-92d1-750aa5dff4d4';

-- 15. Stiff-Leg Deadlifts
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'compound',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'strength'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'barbell'),
    instructions = ARRAY[
        'Stand holding barbell with overhand grip at hip level',
        'Position feet hip-width apart, toes pointing forward',
        'Keep legs nearly straight with very slight knee bend',
        'Maintain neutral spine and engaged core',
        'Hinge at hips, pushing glutes back as you lower bar',
        'Lower barbell down along front of legs, keeping bar close',
        'Lower until you feel deep stretch in hamstrings',
        'Drive hips forward to return to standing position',
        'Squeeze glutes at top of movement'
    ]
WHERE base_exercise_id = '319c7d1d-b56c-4e40-be50-f9fcfc8d971a';

-- 16. Preacher Curls
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'preacher_bench'),
    instructions = ARRAY[
        'Adjust preacher bench so pad rests just under armpits when seated',
        'Sit with chest against pad, feet flat on floor',
        'Grasp bar with underhand grip at shoulder-width',
        'Extend arms fully with upper arms flat against pad',
        'Curl bar upward, contracting biceps',
        'Lift until bar reaches shoulder height',
        'Squeeze biceps hard at top for 1-2 seconds',
        'Lower slowly below 90-degree joint angle for full stretch'
    ]
WHERE base_exercise_id = 'f75617d8-885d-4aa9-9afe-4e0d01199de9';

-- 17. Spider Curls
UPDATE base_exercise
SET
    level = 'intermediate',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'incline_bench'),
    instructions = ARRAY[
        'Set incline bench to approximately 45-60 degrees',
        'Lie face down (prone) with chest against incline pad',
        'Let arms hang straight down toward floor on front side of bench',
        'Grasp bar with underhand grip at shoulder-width',
        'Curl bar up by bending elbows only',
        'Lift until biceps are fully contracted',
        'Squeeze biceps maximally at top for 1-2 seconds',
        'Lower bar slowly and controlled to full arm extension'
    ]
WHERE base_exercise_id = 'b1166ffb-47ca-4d88-8276-9caf893e1367';

-- 18. Incline Dumbbell Curls
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'pull',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'incline_bench'),
    instructions = ARRAY[
        'Set incline bench to 45-60 degrees (60 degrees recommended)',
        'Sit back on bench with back and head fully supported',
        'Hold dumbbells with arms hanging naturally downward',
        'Maintain good posture with chest up and shoulders back',
        'Keep elbows pointed down and slightly behind body',
        'Curl dumbbells up by bending elbows only',
        'Squeeze biceps at top, then lower slowly with control',
        'Lower to full arm extension to maximize stretch'
    ]
WHERE base_exercise_id = '93d61257-bad8-4c8d-b107-b814140d19c2';

-- 19. Seated Calf Raise
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'seated_calf_machine'),
    instructions = ARRAY[
        'Adjust seated calf raise machine so knees bend at 90 degrees',
        'Position knee pad comfortably just above knees',
        'Place balls of feet on platform with toes pointing forward',
        'Release safety mechanism and ensure weight rests on knees',
        'Lower heels by dorsiflexing ankles to fully stretched position',
        'Push up onto tiptoes by plantarflexing ankles',
        'Pause at top for 1-2 seconds',
        'Squeeze calf muscles maximally at peak contraction',
        'Lower back to starting position with control'
    ]
WHERE base_exercise_id = '8d004901-339c-4354-8ca3-28a5ef5432a6';

-- 20. Cable Crossovers
UPDATE base_exercise
SET
    level = 'beginner',
    mechanic = 'isolation',
    force = 'push',
    category_id = (SELECT category_id FROM exercise_category WHERE name = 'isolation'),
    equipment_type_id = (SELECT equipment_type_id FROM equipment_type WHERE name = 'dual_cable_machine'),
    instructions = ARRAY[
        'Set cable pulleys at desired height (high, mid, or low)',
        'Attach D-handles to each cable',
        'Stand in center of cable station, feet staggered for stability',
        'Grasp one handle in each hand with palms facing forward',
        'Lean torso slightly forward (about 15-20 degrees)',
        'Begin with arms extended out to sides, slight elbow bend',
        'Bring handles together in wide arc toward center of body',
        'Squeeze chest hard at peak contraction for 1-2 seconds',
        'Return to starting position slowly, resisting the eccentric'
    ]
WHERE base_exercise_id = 'cd8d7cdd-7394-4bb6-aba1-684003577483';

-- =============================================================================
-- MUSCLE GROUP JUNCTION TABLES: Primary Muscles
-- =============================================================================

-- 1. Face Pulls - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '34bd3f09-0a5a-480b-b450-746b1e5c7274', muscle_group_id, 0 FROM muscle_group WHERE name = 'posterior_deltoids'
UNION ALL
SELECT '34bd3f09-0a5a-480b-b450-746b1e5c7274', muscle_group_id, 1 FROM muscle_group WHERE name = 'rhomboids'
UNION ALL
SELECT '34bd3f09-0a5a-480b-b450-746b1e5c7274', muscle_group_id, 2 FROM muscle_group WHERE name = 'middle_trapezius'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 2. Tricep Pushdowns - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'b5d34436-b28a-41cb-bfd1-93051e352f3f', muscle_group_id, 0 FROM muscle_group WHERE name = 'triceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 3. Leg Extension - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '08562f83-66ea-49d9-bbf8-89cde104a5a7', muscle_group_id, 0 FROM muscle_group WHERE name = 'quadriceps'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 4. Leg Press - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '5270cfc0-31a3-458e-9baf-62803346d03f', muscle_group_id, 0 FROM muscle_group WHERE name = 'quadriceps'
UNION ALL
SELECT '5270cfc0-31a3-458e-9baf-62803346d03f', muscle_group_id, 1 FROM muscle_group WHERE name = 'gluteus_maximus'
UNION ALL
SELECT '5270cfc0-31a3-458e-9baf-62803346d03f', muscle_group_id, 2 FROM muscle_group WHERE name = 'hamstrings'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 5. Cable Curls - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'e4977b90-62d6-4465-b50c-49bd1d6a61be', muscle_group_id, 0 FROM muscle_group WHERE name = 'biceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 6. Hammer Curls - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '62fe9884-1c76-4224-af6e-8cd05a17e385', muscle_group_id, 0 FROM muscle_group WHERE name = 'brachialis'
UNION ALL
SELECT '62fe9884-1c76-4224-af6e-8cd05a17e385', muscle_group_id, 1 FROM muscle_group WHERE name = 'brachioradialis'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 7. Hyperextensions - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'cad62a1a-538f-408a-95d3-de74f54f6710', muscle_group_id, 0 FROM muscle_group WHERE name = 'erector_spinae'
UNION ALL
SELECT 'cad62a1a-538f-408a-95d3-de74f54f6710', muscle_group_id, 1 FROM muscle_group WHERE name = 'gluteus_maximus'
UNION ALL
SELECT 'cad62a1a-538f-408a-95d3-de74f54f6710', muscle_group_id, 2 FROM muscle_group WHERE name = 'hamstrings'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 8. Dumbbell Flyes - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '1e4eee1f-d2fd-4b66-94b7-1de2ac4484c9', muscle_group_id, 0 FROM muscle_group WHERE name = 'pectoralis_major'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 9. Upright Rows - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'd4cbce8f-0a69-4274-84eb-171bd63c7429', muscle_group_id, 0 FROM muscle_group WHERE name = 'lateral_deltoids'
UNION ALL
SELECT 'd4cbce8f-0a69-4274-84eb-171bd63c7429', muscle_group_id, 1 FROM muscle_group WHERE name = 'upper_trapezius'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 10. Rack Pulls - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '17724820-ed82-4129-adba-8805a7912b65', muscle_group_id, 0 FROM muscle_group WHERE name = 'upper_trapezius'
UNION ALL
SELECT '17724820-ed82-4129-adba-8805a7912b65', muscle_group_id, 1 FROM muscle_group WHERE name = 'latissimus_dorsi'
UNION ALL
SELECT '17724820-ed82-4129-adba-8805a7912b65', muscle_group_id, 2 FROM muscle_group WHERE name = 'erector_spinae'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 11. Pendlay Rows - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 0 FROM muscle_group WHERE name = 'latissimus_dorsi'
UNION ALL
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 1 FROM muscle_group WHERE name = 'middle_trapezius'
UNION ALL
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 2 FROM muscle_group WHERE name = 'rhomboids'
UNION ALL
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 3 FROM muscle_group WHERE name = 'posterior_deltoids'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 12. Reverse Flyes - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '07765c6b-af9d-4637-bfdc-3924a6e0699a', muscle_group_id, 0 FROM muscle_group WHERE name = 'posterior_deltoids'
UNION ALL
SELECT '07765c6b-af9d-4637-bfdc-3924a6e0699a', muscle_group_id, 1 FROM muscle_group WHERE name = 'rhomboids'
UNION ALL
SELECT '07765c6b-af9d-4637-bfdc-3924a6e0699a', muscle_group_id, 2 FROM muscle_group WHERE name = 'middle_trapezius'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 13. Concentration Curls - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '458fcd22-1454-468e-85e1-2ab3f1dcd107', muscle_group_id, 0 FROM muscle_group WHERE name = 'biceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 14. Lying Tricep Extensions - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'fff636b5-bec0-447f-92d1-750aa5dff4d4', muscle_group_id, 0 FROM muscle_group WHERE name = 'triceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 15. Stiff-Leg Deadlifts - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '319c7d1d-b56c-4e40-be50-f9fcfc8d971a', muscle_group_id, 0 FROM muscle_group WHERE name = 'hamstrings'
UNION ALL
SELECT '319c7d1d-b56c-4e40-be50-f9fcfc8d971a', muscle_group_id, 1 FROM muscle_group WHERE name = 'gluteus_maximus'
UNION ALL
SELECT '319c7d1d-b56c-4e40-be50-f9fcfc8d971a', muscle_group_id, 2 FROM muscle_group WHERE name = 'erector_spinae'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 16. Preacher Curls - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'f75617d8-885d-4aa9-9afe-4e0d01199de9', muscle_group_id, 0 FROM muscle_group WHERE name = 'biceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 17. Spider Curls - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'b1166ffb-47ca-4d88-8276-9caf893e1367', muscle_group_id, 0 FROM muscle_group WHERE name = 'biceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 18. Incline Dumbbell Curls - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '93d61257-bad8-4c8d-b107-b814140d19c2', muscle_group_id, 0 FROM muscle_group WHERE name = 'biceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 19. Seated Calf Raise - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '8d004901-339c-4354-8ca3-28a5ef5432a6', muscle_group_id, 0 FROM muscle_group WHERE name = 'soleus'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 20. Cable Crossovers - Primary Muscles
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'cd8d7cdd-7394-4bb6-aba1-684003577483', muscle_group_id, 0 FROM muscle_group WHERE name = 'pectoralis_major'
UNION ALL
SELECT 'cd8d7cdd-7394-4bb6-aba1-684003577483', muscle_group_id, 1 FROM muscle_group WHERE name = 'pectoralis_minor'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- =============================================================================
-- MUSCLE GROUP JUNCTION TABLES: Secondary Muscles
-- =============================================================================

-- 1. Face Pulls - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '34bd3f09-0a5a-480b-b450-746b1e5c7274', muscle_group_id, 0 FROM muscle_group WHERE name = 'rotator_cuff'
UNION ALL
SELECT '34bd3f09-0a5a-480b-b450-746b1e5c7274', muscle_group_id, 1 FROM muscle_group WHERE name = 'lower_trapezius'
UNION ALL
SELECT '34bd3f09-0a5a-480b-b450-746b1e5c7274', muscle_group_id, 2 FROM muscle_group WHERE name = 'teres_major'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 2. Tricep Pushdowns - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'b5d34436-b28a-41cb-bfd1-93051e352f3f', muscle_group_id, 0 FROM muscle_group WHERE name = 'anconeus'
UNION ALL
SELECT 'b5d34436-b28a-41cb-bfd1-93051e352f3f', muscle_group_id, 1 FROM muscle_group WHERE name = 'forearm_extensors'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 4. Leg Press - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '5270cfc0-31a3-458e-9baf-62803346d03f', muscle_group_id, 0 FROM muscle_group WHERE name = 'adductors'
UNION ALL
SELECT '5270cfc0-31a3-458e-9baf-62803346d03f', muscle_group_id, 1 FROM muscle_group WHERE name = 'calves'
UNION ALL
SELECT '5270cfc0-31a3-458e-9baf-62803346d03f', muscle_group_id, 2 FROM muscle_group WHERE name = 'core_stabilizers'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 5. Cable Curls - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'e4977b90-62d6-4465-b50c-49bd1d6a61be', muscle_group_id, 0 FROM muscle_group WHERE name = 'brachialis'
UNION ALL
SELECT 'e4977b90-62d6-4465-b50c-49bd1d6a61be', muscle_group_id, 1 FROM muscle_group WHERE name = 'brachioradialis'
UNION ALL
SELECT 'e4977b90-62d6-4465-b50c-49bd1d6a61be', muscle_group_id, 2 FROM muscle_group WHERE name = 'forearm_flexors'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 6. Hammer Curls - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '62fe9884-1c76-4224-af6e-8cd05a17e385', muscle_group_id, 0 FROM muscle_group WHERE name = 'biceps_brachii'
UNION ALL
SELECT '62fe9884-1c76-4224-af6e-8cd05a17e385', muscle_group_id, 1 FROM muscle_group WHERE name = 'forearm_flexors'
UNION ALL
SELECT '62fe9884-1c76-4224-af6e-8cd05a17e385', muscle_group_id, 2 FROM muscle_group WHERE name = 'wrist_stabilizers'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 7. Hyperextensions - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'cad62a1a-538f-408a-95d3-de74f54f6710', muscle_group_id, 0 FROM muscle_group WHERE name = 'multifidus'
UNION ALL
SELECT 'cad62a1a-538f-408a-95d3-de74f54f6710', muscle_group_id, 1 FROM muscle_group WHERE name = 'quadratus_lumborum'
UNION ALL
SELECT 'cad62a1a-538f-408a-95d3-de74f54f6710', muscle_group_id, 2 FROM muscle_group WHERE name = 'core_stabilizers'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 8. Dumbbell Flyes - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '1e4eee1f-d2fd-4b66-94b7-1de2ac4484c9', muscle_group_id, 0 FROM muscle_group WHERE name = 'anterior_deltoids'
UNION ALL
SELECT '1e4eee1f-d2fd-4b66-94b7-1de2ac4484c9', muscle_group_id, 1 FROM muscle_group WHERE name = 'serratus_anterior'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 9. Upright Rows - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'd4cbce8f-0a69-4274-84eb-171bd63c7429', muscle_group_id, 0 FROM muscle_group WHERE name = 'anterior_deltoids'
UNION ALL
SELECT 'd4cbce8f-0a69-4274-84eb-171bd63c7429', muscle_group_id, 1 FROM muscle_group WHERE name = 'rhomboids'
UNION ALL
SELECT 'd4cbce8f-0a69-4274-84eb-171bd63c7429', muscle_group_id, 2 FROM muscle_group WHERE name = 'biceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 10. Rack Pulls - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '17724820-ed82-4129-adba-8805a7912b65', muscle_group_id, 0 FROM muscle_group WHERE name = 'rhomboids'
UNION ALL
SELECT '17724820-ed82-4129-adba-8805a7912b65', muscle_group_id, 1 FROM muscle_group WHERE name = 'posterior_deltoids'
UNION ALL
SELECT '17724820-ed82-4129-adba-8805a7912b65', muscle_group_id, 2 FROM muscle_group WHERE name = 'gluteus_maximus'
UNION ALL
SELECT '17724820-ed82-4129-adba-8805a7912b65', muscle_group_id, 3 FROM muscle_group WHERE name = 'hamstrings'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 11. Pendlay Rows - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 0 FROM muscle_group WHERE name = 'erector_spinae'
UNION ALL
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 1 FROM muscle_group WHERE name = 'core_stabilizers'
UNION ALL
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 2 FROM muscle_group WHERE name = 'gluteus_maximus'
UNION ALL
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 3 FROM muscle_group WHERE name = 'hamstrings'
UNION ALL
SELECT '72422027-c5dc-4364-bcf7-bc6f37081faa', muscle_group_id, 4 FROM muscle_group WHERE name = 'biceps_brachii'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 12. Reverse Flyes - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '07765c6b-af9d-4637-bfdc-3924a6e0699a', muscle_group_id, 0 FROM muscle_group WHERE name = 'rotator_cuff'
UNION ALL
SELECT '07765c6b-af9d-4637-bfdc-3924a6e0699a', muscle_group_id, 1 FROM muscle_group WHERE name = 'lower_trapezius'
UNION ALL
SELECT '07765c6b-af9d-4637-bfdc-3924a6e0699a', muscle_group_id, 2 FROM muscle_group WHERE name = 'teres_major'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 13. Concentration Curls - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '458fcd22-1454-468e-85e1-2ab3f1dcd107', muscle_group_id, 0 FROM muscle_group WHERE name = 'brachialis'
UNION ALL
SELECT '458fcd22-1454-468e-85e1-2ab3f1dcd107', muscle_group_id, 1 FROM muscle_group WHERE name = 'brachioradialis'
UNION ALL
SELECT '458fcd22-1454-468e-85e1-2ab3f1dcd107', muscle_group_id, 2 FROM muscle_group WHERE name = 'forearm_flexors'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 14. Lying Tricep Extensions - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'fff636b5-bec0-447f-92d1-750aa5dff4d4', muscle_group_id, 0 FROM muscle_group WHERE name = 'anconeus'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 15. Stiff-Leg Deadlifts - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '319c7d1d-b56c-4e40-be50-f9fcfc8d971a', muscle_group_id, 0 FROM muscle_group WHERE name = 'adductor_magnus'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 16. Preacher Curls - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'f75617d8-885d-4aa9-9afe-4e0d01199de9', muscle_group_id, 0 FROM muscle_group WHERE name = 'brachialis'
UNION ALL
SELECT 'f75617d8-885d-4aa9-9afe-4e0d01199de9', muscle_group_id, 1 FROM muscle_group WHERE name = 'brachioradialis'
UNION ALL
SELECT 'f75617d8-885d-4aa9-9afe-4e0d01199de9', muscle_group_id, 2 FROM muscle_group WHERE name = 'forearm_flexors'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 17. Spider Curls - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'b1166ffb-47ca-4d88-8276-9caf893e1367', muscle_group_id, 0 FROM muscle_group WHERE name = 'brachialis'
UNION ALL
SELECT 'b1166ffb-47ca-4d88-8276-9caf893e1367', muscle_group_id, 1 FROM muscle_group WHERE name = 'brachioradialis'
UNION ALL
SELECT 'b1166ffb-47ca-4d88-8276-9caf893e1367', muscle_group_id, 2 FROM muscle_group WHERE name = 'forearm_flexors'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 18. Incline Dumbbell Curls - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '93d61257-bad8-4c8d-b107-b814140d19c2', muscle_group_id, 0 FROM muscle_group WHERE name = 'brachialis'
UNION ALL
SELECT '93d61257-bad8-4c8d-b107-b814140d19c2', muscle_group_id, 1 FROM muscle_group WHERE name = 'brachioradialis'
UNION ALL
SELECT '93d61257-bad8-4c8d-b107-b814140d19c2', muscle_group_id, 2 FROM muscle_group WHERE name = 'anterior_deltoids'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 19. Seated Calf Raise - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT '8d004901-339c-4354-8ca3-28a5ef5432a6', muscle_group_id, 0 FROM muscle_group WHERE name = 'gastrocnemius'
UNION ALL
SELECT '8d004901-339c-4354-8ca3-28a5ef5432a6', muscle_group_id, 1 FROM muscle_group WHERE name = 'tibialis_posterior'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- 20. Cable Crossovers - Secondary Muscles
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id, sort_order)
SELECT 'cd8d7cdd-7394-4bb6-aba1-684003577483', muscle_group_id, 0 FROM muscle_group WHERE name = 'anterior_deltoids'
UNION ALL
SELECT 'cd8d7cdd-7394-4bb6-aba1-684003577483', muscle_group_id, 1 FROM muscle_group WHERE name = 'serratus_anterior'
UNION ALL
SELECT 'cd8d7cdd-7394-4bb6-aba1-684003577483', muscle_group_id, 2 FROM muscle_group WHERE name = 'core_stabilizers'
ON CONFLICT (base_exercise_id, muscle_group_id) DO NOTHING;

-- =============================================================================
-- Migration Complete
-- =============================================================================

-- Summary:
-- - 20 isolation/accessory exercises updated with full metadata
-- - Added reference data for muscle groups and equipment types
-- - Populated primary and secondary muscle junction tables
-- - All exercises now have level, mechanic, force, instructions, and equipment
