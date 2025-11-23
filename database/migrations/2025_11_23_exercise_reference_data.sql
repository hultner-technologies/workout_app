-- ============================================================================
-- Exercise Reference Data Migration
-- Created: 2025-11-23
-- Description: Populates reference tables for exercise metadata (muscle groups,
--              equipment types, and exercise categories)
-- ============================================================================

-- ============================================================================
-- Muscle Groups Reference Data
-- ============================================================================

INSERT INTO muscle_group (muscle_group_id, name, display_name, description)
VALUES
    -- Upper Body - Chest & Shoulders
    (uuid_generate_v1mc(), 'chest', 'Chest', 'Pectoral muscles (major and minor)'),
    (uuid_generate_v1mc(), 'shoulders', 'Shoulders', 'Deltoid muscles (anterior, lateral, and posterior)'),
    (uuid_generate_v1mc(), 'rotator_cuff', 'Rotator Cuff', 'Stabilizing muscles of the shoulder joint'),

    -- Upper Body - Arms
    (uuid_generate_v1mc(), 'triceps', 'Triceps', 'Posterior upper arm muscles'),
    (uuid_generate_v1mc(), 'biceps', 'Biceps', 'Anterior upper arm muscles'),
    (uuid_generate_v1mc(), 'forearms', 'Forearms', 'Lower arm muscles (flexors and extensors)'),

    -- Upper Body - Back
    (uuid_generate_v1mc(), 'lats', 'Lats', 'Latissimus dorsi muscles'),
    (uuid_generate_v1mc(), 'traps', 'Traps', 'Trapezius muscles (upper, middle, and lower)'),
    (uuid_generate_v1mc(), 'rhomboids', 'Rhomboids', 'Rhomboid muscles (major and minor)'),
    (uuid_generate_v1mc(), 'lower_back', 'Lower Back', 'Lumbar region muscles'),
    (uuid_generate_v1mc(), 'erector_spinae', 'Erector Spinae', 'Spinal erector muscles'),

    -- Core
    (uuid_generate_v1mc(), 'abs', 'Abs', 'Abdominal muscles (rectus abdominis)'),
    (uuid_generate_v1mc(), 'obliques', 'Obliques', 'Internal and external oblique muscles'),

    -- Lower Body - Hip & Glutes
    (uuid_generate_v1mc(), 'glutes', 'Glutes', 'Gluteal muscles (maximus, medius, and minimus)'),
    (uuid_generate_v1mc(), 'hip_flexors', 'Hip Flexors', 'Iliopsoas and related hip flexor muscles'),
    (uuid_generate_v1mc(), 'adductors', 'Adductors', 'Inner thigh muscles (adductor group)'),
    (uuid_generate_v1mc(), 'abductors', 'Abductors', 'Outer hip muscles (gluteus medius and minimus)'),

    -- Lower Body - Legs
    (uuid_generate_v1mc(), 'quadriceps', 'Quadriceps', 'Front thigh muscles (rectus femoris, vastus group)'),
    (uuid_generate_v1mc(), 'hamstrings', 'Hamstrings', 'Posterior thigh muscles (biceps femoris, semitendinosus, semimembranosus)'),
    (uuid_generate_v1mc(), 'calves', 'Calves', 'Lower leg muscles (gastrocnemius and soleus)')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Equipment Types Reference Data
-- ============================================================================

INSERT INTO equipment_type (equipment_type_id, name, display_name, description)
VALUES
    -- Free Weights
    (uuid_generate_v1mc(), 'barbell', 'Barbell', 'Standard Olympic barbell (45 lbs / 20 kg)'),
    (uuid_generate_v1mc(), 'dumbbell', 'Dumbbell', 'Free weight dumbbells (pairs or single)'),
    (uuid_generate_v1mc(), 'kettlebell', 'Kettlebell', 'Cast iron or steel weight with handle'),

    -- Specialty Bars
    (uuid_generate_v1mc(), 'trap_bar', 'Trap Bar', 'Hexagonal deadlift bar (hex bar)'),
    (uuid_generate_v1mc(), 'ez_bar', 'EZ Bar', 'Curved barbell for reduced wrist strain'),
    (uuid_generate_v1mc(), 'safety_squat_bar', 'Safety Squat Bar', 'Padded bar with forward-angled handles'),

    -- Machines & Cable Systems
    (uuid_generate_v1mc(), 'machine', 'Machine', 'Weight stack or plate-loaded exercise machine'),
    (uuid_generate_v1mc(), 'cable', 'Cable', 'Cable machine with adjustable pulley system'),

    -- Bodyweight & Portable
    (uuid_generate_v1mc(), 'bodyweight', 'Bodyweight', 'No equipment required (uses body weight)'),
    (uuid_generate_v1mc(), 'resistance_band', 'Resistance Band', 'Elastic resistance bands or tubes'),

    -- Fixed Equipment
    (uuid_generate_v1mc(), 'pull_up_bar', 'Pull-up Bar', 'Fixed or doorway-mounted bar for pull-ups'),
    (uuid_generate_v1mc(), 'dip_station', 'Dip Station', 'Parallel bars for dips and support holds'),
    (uuid_generate_v1mc(), 'squat_rack', 'Squat Rack', 'Power rack or squat stand with safety bars'),

    -- Accessories & Implements
    (uuid_generate_v1mc(), 'box', 'Box', 'Plyometric box or step platform'),
    (uuid_generate_v1mc(), 'medicine_ball', 'Medicine Ball', 'Weighted ball for dynamic movements'),
    (uuid_generate_v1mc(), 'ab_wheel', 'Ab Wheel', 'Wheel with handles for core rollout exercises'),
    (uuid_generate_v1mc(), 'foam_roller', 'Foam Roller', 'Cylindrical foam for myofascial release'),
    (uuid_generate_v1mc(), 'bench', 'Bench', 'Weight bench (flat, incline, or decline)'),

    -- Cardio Equipment
    (uuid_generate_v1mc(), 'treadmill', 'Treadmill', 'Motorized or manual running machine'),
    (uuid_generate_v1mc(), 'rowing_machine', 'Rowing Machine', 'Ergometer for rowing motion'),
    (uuid_generate_v1mc(), 'stationary_bike', 'Stationary Bike', 'Indoor cycling bike'),
    (uuid_generate_v1mc(), 'elliptical', 'Elliptical', 'Low-impact cardio machine'),

    -- Functional Training
    (uuid_generate_v1mc(), 'suspension_trainer', 'Suspension Trainer', 'TRX or similar suspension straps'),
    (uuid_generate_v1mc(), 'battle_rope', 'Battle Rope', 'Heavy rope for wave and slam exercises'),
    (uuid_generate_v1mc(), 'sled', 'Sled', 'Weighted sled for pushing or pulling'),
    (uuid_generate_v1mc(), 'sandbag', 'Sandbag', 'Weight-adjustable sandbag for functional training')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Exercise Categories Reference Data
-- ============================================================================

INSERT INTO exercise_category (category_id, name, display_name, description)
VALUES
    (uuid_generate_v1mc(), 'strength', 'Strength', 'Traditional strength training exercises focused on building maximal force production'),
    (uuid_generate_v1mc(), 'hypertrophy', 'Hypertrophy', 'Muscle building exercises optimized for muscle growth and size'),
    (uuid_generate_v1mc(), 'power', 'Power', 'Explosive movements combining strength and speed (Olympic lifts, plyometrics)'),
    (uuid_generate_v1mc(), 'cardio', 'Cardio', 'Cardiovascular endurance exercises (running, cycling, rowing)'),
    (uuid_generate_v1mc(), 'stretching', 'Stretching', 'Static and dynamic stretching exercises for flexibility'),
    (uuid_generate_v1mc(), 'mobility', 'Mobility', 'Joint mobility and range of motion exercises'),
    (uuid_generate_v1mc(), 'plyometric', 'Plyometric', 'Jump training and explosive bodyweight movements'),
    (uuid_generate_v1mc(), 'stability', 'Stability', 'Core stability and balance training exercises'),
    (uuid_generate_v1mc(), 'rehabilitation', 'Rehabilitation', 'Therapeutic exercises for injury recovery and prevention'),
    (uuid_generate_v1mc(), 'warmup', 'Warm-up', 'Exercises for preparing the body for training'),
    (uuid_generate_v1mc(), 'cooldown', 'Cool-down', 'Recovery exercises for post-workout')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Verification Queries (commented out - uncomment to verify data)
-- ============================================================================

-- SELECT COUNT(*) as muscle_group_count FROM muscle_group;
-- SELECT COUNT(*) as equipment_type_count FROM equipment_type;
-- SELECT COUNT(*) as exercise_category_count FROM exercise_category;

-- SELECT * FROM muscle_group ORDER BY name;
-- SELECT * FROM equipment_type ORDER BY name;
-- SELECT * FROM exercise_category ORDER BY name;
