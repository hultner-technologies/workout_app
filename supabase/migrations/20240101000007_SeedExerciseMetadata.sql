-- Seed data for exercise metadata reference tables
-- This populates reference tables with known values from free-exercise-db

-- ============================================================================
-- Muscle Groups
-- ============================================================================

INSERT INTO muscle_group (name, display_name, description) VALUES
    ('abdominals', 'Abdominals', 'Core abdominal muscles'),
    ('abductors', 'Abductors', 'Hip abductor muscles'),
    ('adductors', 'Adductors', 'Hip adductor muscles'),
    ('biceps', 'Biceps', 'Biceps brachii'),
    ('calves', 'Calves', 'Calf muscles (gastrocnemius and soleus)'),
    ('chest', 'Chest', 'Pectoral muscles'),
    ('forearms', 'Forearms', 'Forearm muscles'),
    ('glutes', 'Glutes', 'Gluteal muscles'),
    ('hamstrings', 'Hamstrings', 'Hamstring muscles'),
    ('lats', 'Lats', 'Latissimus dorsi'),
    ('lower back', 'Lower Back', 'Lower back muscles'),
    ('middle back', 'Middle Back', 'Middle back muscles'),
    ('neck', 'Neck', 'Neck muscles'),
    ('quadriceps', 'Quadriceps', 'Quadriceps femoris'),
    ('shoulders', 'Shoulders', 'Deltoid muscles'),
    ('traps', 'Traps', 'Trapezius muscles'),
    ('triceps', 'Triceps', 'Triceps brachii')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Equipment Types
-- ============================================================================

INSERT INTO equipment_type (name, display_name, description) VALUES
    ('barbell', 'Barbell', 'Standard barbell'),
    ('dumbbell', 'Dumbbell', 'Dumbbells'),
    ('body only', 'Body Weight', 'No equipment required'),
    ('machine', 'Machine', 'Exercise machine'),
    ('cable', 'Cable', 'Cable machine'),
    ('kettlebells', 'Kettlebells', 'Kettlebells'),
    ('bands', 'Resistance Bands', 'Resistance bands'),
    ('medicine ball', 'Medicine Ball', 'Medicine ball'),
    ('exercise ball', 'Exercise Ball', 'Swiss/stability ball'),
    ('foam roll', 'Foam Roller', 'Foam roller for SMR'),
    ('e-z curl bar', 'E-Z Curl Bar', 'E-Z curl bar'),
    ('other', 'Other Equipment', 'Other specialized equipment')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Exercise Categories
-- ============================================================================

INSERT INTO exercise_category (name, display_name, description) VALUES
    ('strength', 'Strength', 'Strength training exercises'),
    ('cardio', 'Cardio', 'Cardiovascular exercises'),
    ('stretching', 'Stretching', 'Flexibility and stretching exercises'),
    ('powerlifting', 'Powerlifting', 'Powerlifting-specific exercises'),
    ('olympic weightlifting', 'Olympic Weightlifting', 'Olympic weightlifting movements'),
    ('strongman', 'Strongman', 'Strongman training exercises'),
    ('plyometrics', 'Plyometrics', 'Explosive plyometric exercises')
ON CONFLICT (name) DO NOTHING;

-- ============================================================================
-- Indexes on reference tables
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_muscle_group_name ON muscle_group (name);
CREATE INDEX IF NOT EXISTS idx_equipment_type_name ON equipment_type (name);
CREATE INDEX IF NOT EXISTS idx_exercise_category_name ON exercise_category (name);
