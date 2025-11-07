#!/usr/bin/env python3
"""
Generate final migration SQL for custom exercise cleanup.
Uses EXERCISE_MAPPING.csv and FREE_EXERCISE_DB_TO_IMPORT.json.
"""

import csv
import json
from datetime import datetime
from collections import defaultdict

# Muscle group mappings (from seed data)
MUSCLE_GROUPS = {
    "abdominals": "291da1e0-dc9e-11ee-b3ef-7b9d7d1c14f1",
    "abductors": "291e2a90-dc9e-11ee-b3ef-0b14dd6bbba1",
    "adductors": "291e77e8-dc9e-11ee-b3ef-6b62d3bfef00",
    "biceps": "291ec53e-dc9e-11ee-b3ef-6b1a5d976f88",
    "calves": "291f12a0-dc9e-11ee-b3ef-df36cb3b9059",
    "chest": "291f5ff2-dc9e-11ee-b3ef-7fb5b5a95a76",
    "forearms": "291fad44-dc9e-11ee-b3ef-57b14c42f862",
    "glutes": "291ffa96-dc9e-11ee-b3ef-9322e8fd1c50",
    "hamstrings": "292047e8-dc9e-11ee-b3ef-9bca5f029681",
    "lats": "29209544-dc9e-11ee-b3ef-1f5f81fa3097",
    "lower back": "2920e296-dc9e-11ee-b3ef-a775fef41aee",
    "middle back": "29212fe8-dc9e-11ee-b3ef-fbfe30e14d84",
    "neck": "29217d3a-dc9e-11ee-b3ef-070a3cbd4e2c",
    "quadriceps": "2921ca8c-dc9e-11ee-b3ef-3bb21e6d5d19",
    "shoulders": "292217de-dc9e-11ee-b3ef-fb36f9d6ca9d",
    "traps": "29226530-dc9e-11ee-b3ef-abe2a0a03bf6",
    "triceps": "2922b282-dc9e-11ee-b3ef-1f4f58bc00c7",
}

# Exercise category mappings
CATEGORIES = {
    "powerlifting": "291c7a78-dc9e-11ee-b3ef-af0efd3f7f01",
    "strength": "291cc7d0-dc9e-11ee-b3ef-d3a1e49ed5fb",
    "stretching": "291d1522-dc9e-11ee-b3ef-3b2c8f1d9f5c",
    "cardio": "291d6274-dc9e-11ee-b3ef-2f6c3b3cfb30",
    "olympic weightlifting": "291dafc6-dc9e-11ee-b3ef-d76d2bf8fb41",
    "strongman": "291dfd18-dc9e-11ee-b3ef-b3f30e0ac0d6",
    "plyometrics": "291e4a6a-dc9e-11ee-b3ef-7f48bf5e7f33",
}

# Equipment type mappings
EQUIPMENT_TYPES = {
    "barbell": "29197fc4-dc9e-11ee-b3ef-279e09e9cc1e",
    "dumbbell": "2919cd20-dc9e-11ee-b3ef-e7b45ca3d28b",
    "machine": "291a1a72-dc9e-11ee-b3ef-93adf1efd6f9",
    "cable": "291a67c4-dc9e-11ee-b3ef-3fec81d3ec60",
    "kettlebells": "291ab516-dc9e-11ee-b3ef-ebb7f8b6e9ce",
    "e-z curl bar": "291b0268-dc9e-11ee-b3ef-2b78b8b84ed6",
    "body only": None,  # NULL equipment
    "other": None,  # NULL equipment
    "none": None,
}

def load_existing_db_aliases():
    """Load aliases for existing DB exercises from CSV."""
    aliases_by_exercise = defaultdict(list)

    with open('EXERCISE_MAPPING.csv', 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['match_type'] == 'existing_db':
                base_id = row['base_exercise_id']
                custom_name = row['custom_name_normalized']
                base_name = row['base_exercise_name'].lower().strip()

                # Only add if different from base name
                if custom_name != base_name:
                    aliases_by_exercise[base_id].append(custom_name)

    return aliases_by_exercise

def load_free_exercise_db_imports():
    """Load exercises to import from JSON."""
    with open('FREE_EXERCISE_DB_TO_IMPORT.json', 'r') as f:
        return json.load(f)

def generate_migration():
    """Generate the complete migration SQL."""

    print("-- Migration: 076_CleanupCustomExercises.sql")
    print("-- Purpose: Clean up performed_exercises with null exercise_id")
    print(f"-- Generated: {datetime.now().isoformat()}")
    print("-- Author: Claude Code Agent")
    print()
    print("BEGIN;")
    print()

    # ========================================================================
    # PART 1: Add aliases to existing DB exercises
    # ========================================================================
    print("-- ============================================================================")
    print("-- PART 1: Add aliases to existing database exercises")
    print("-- ============================================================================")
    print()

    existing_aliases = load_existing_db_aliases()
    for base_id, aliases in sorted(existing_aliases.items()):
        for alias in sorted(set(aliases)):
            print(f"-- Add alias: {alias}")
            print(f"UPDATE base_exercise")
            print(f"SET aliases = CASE")
            print(f"    WHEN aliases IS NULL THEN ARRAY['{alias}']")
            print(f"    WHEN NOT (aliases @> ARRAY['{alias}']) THEN array_append(aliases, '{alias}')")
            print(f"    ELSE aliases")
            print(f"END")
            print(f"WHERE base_exercise_id = '{base_id}';")
            print()

    # ========================================================================
    # PART 2: Import from free-exercise-db
    # ========================================================================
    print("-- ============================================================================")
    print("-- PART 2: Import exercises from free-exercise-db")
    print("-- ============================================================================")
    print()

    free_exercises = load_free_exercise_db_imports()
    new_base_exercise_ids = {}

    for ex in free_exercises:
        import uuid
        base_id = str(uuid.uuid4())
        new_base_exercise_ids[ex['source_id']] = base_id

        # Normalize values
        level = ex['level'].lower() if ex['level'] else 'beginner'
        mechanic = ex['mechanic'].lower() if ex['mechanic'] else None
        force = ex['force'].lower() if ex['force'] else None
        equipment = ex['equipment'].lower() if ex['equipment'] else None
        category = ex['category'].lower() if ex['category'] else 'strength'

        # Build aliases array
        aliases_str = "NULL"
        if ex['aliases']:
            aliases_list = "', '".join(ex['aliases'])
            aliases_str = f"ARRAY['{aliases_list}']"

        print(f"-- {ex['name']} (source_id: {ex['source_id']})")
        print(f"INSERT INTO base_exercise (")
        mechanic_val = f"'{mechanic}'" if mechanic else 'NULL'
        force_val = f"'{force}'" if force else 'NULL'

        # Use SELECT subquery for equipment_type_id
        if equipment:
            equipment_val = f"(SELECT equipment_type_id FROM equipment_type WHERE name = '{equipment}')"
        else:
            equipment_val = 'NULL'

        print(f"    base_exercise_id, name, level, mechanic, force,")
        print(f"    equipment_type_id, category_id, source_id, source_name, aliases")
        print(f") VALUES (")
        print(f"    '{base_id}',")
        print(f"    '{ex['name']}',")
        print(f"    '{level}',")
        print(f"    {mechanic_val},")
        print(f"    {force_val},")
        print(f"    {equipment_val},")
        print(f"    (SELECT category_id FROM exercise_category WHERE name = '{category}'),")
        print(f"    '{ex['source_id']}',")
        print(f"    'free-exercise-db',")
        print(f"    {aliases_str}")
        print(f");")
        print()

        # Add primary muscles
        for muscle in ex['primary_muscles']:
            muscle_name = muscle.lower()
            print(f"INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)")
            print(f"VALUES ('{base_id}', (SELECT muscle_group_id FROM muscle_group WHERE name = '{muscle_name}'));")

        # Add secondary muscles
        for muscle in ex['secondary_muscles']:
            muscle_name = muscle.lower()
            print(f"INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)")
            print(f"VALUES ('{base_id}', (SELECT muscle_group_id FROM muscle_group WHERE name = '{muscle_name}'));")

        print()

    # ========================================================================
    # PART 3: Create new exercises
    # ========================================================================
    print("-- ============================================================================")
    print("-- PART 3: Create new custom exercises")
    print("-- ============================================================================")
    print()

    # Bayesian bicep curl
    bayesian_id = str(uuid.uuid4())
    print(f"-- Bayesian bicep curl")
    print(f"INSERT INTO base_exercise (")
    print(f"    base_exercise_id, name, level, mechanic, force,")
    print(f"    equipment_type_id, category_id, source_name, aliases")
    print(f") VALUES (")
    print(f"    '{bayesian_id}',")
    print(f"    'Bayesian bicep curl',")
    print(f"    'beginner',")
    print(f"    'isolation',")
    print(f"    'pull',")
    print(f"    (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),")
    print(f"    (SELECT category_id FROM exercise_category WHERE name = 'strength'),")
    print(f"    'Custom (User)',")
    print(f"    ARRAY['behind-the-back curl', 'face-away cable curl']")
    print(f");")
    print()
    print(f"INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)")
    print(f"VALUES ('{bayesian_id}', (SELECT muscle_group_id FROM muscle_group WHERE name = 'biceps'));")
    print()

    new_base_exercise_ids['bayesian bicep curl'] = bayesian_id

    # Cable reverse fly
    cable_fly_id = str(uuid.uuid4())
    print(f"-- Cable reverse fly")
    print(f"INSERT INTO base_exercise (")
    print(f"    base_exercise_id, name, level, mechanic, force,")
    print(f"    equipment_type_id, category_id, source_name, aliases")
    print(f") VALUES (")
    print(f"    '{cable_fly_id}',")
    print(f"    'Cable reverse fly',")
    print(f"    'beginner',")
    print(f"    'isolation',")
    print(f"    'pull',")
    print(f"    (SELECT equipment_type_id FROM equipment_type WHERE name = 'cable'),")
    print(f"    (SELECT category_id FROM exercise_category WHERE name = 'strength'),")
    print(f"    'Custom (User)',")
    print(f"    ARRAY['reverse chest fly']")
    print(f");")
    print()
    print(f"INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)")
    print(f"VALUES ('{cable_fly_id}', (SELECT muscle_group_id FROM muscle_group WHERE name = 'shoulders'));")
    print(f"INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)")
    print(f"VALUES ('{cable_fly_id}', (SELECT muscle_group_id FROM muscle_group WHERE name = 'middle back'));")
    print()

    new_base_exercise_ids['cable reverse fly'] = cable_fly_id

    # ========================================================================
    # PART 4: Create exercises in Unknown plan
    # ========================================================================
    print("-- ============================================================================")
    print("-- PART 4: Create exercises in Unknown plan")
    print("-- ============================================================================")
    print()
    print("DO $$")
    print("DECLARE")
    print("    v_unknown_plan_id uuid;")
    print("    v_session_schedule_id uuid;")
    print("    v_max_sort_order integer;")
    print("BEGIN")
    print("    -- Get Unknown plan and its session schedule")
    print("    SELECT plan_id INTO v_unknown_plan_id")
    print("    FROM plan WHERE name = 'Unknown';")
    print()
    print("    IF v_unknown_plan_id IS NULL THEN")
    print("        RAISE EXCEPTION 'Unknown plan not found';")
    print("    END IF;")
    print()
    print("    SELECT session_schedule_id INTO v_session_schedule_id")
    print("    FROM session_schedule")
    print("    WHERE plan_id = v_unknown_plan_id")
    print("    LIMIT 1;")
    print()
    print("    -- Create session_schedule if it doesn't exist")
    print("    IF v_session_schedule_id IS NULL THEN")
    print("        INSERT INTO session_schedule (session_schedule_id, plan_id, name, description, progression_limit)")
    print("        VALUES (uuid_generate_v1mc(), v_unknown_plan_id, 'Default', 'Auto-created for custom exercises', 1.0)")
    print("        RETURNING session_schedule_id INTO v_session_schedule_id;")
    print("    END IF;")
    print()
    print("    -- Get max sort order")
    print("    SELECT COALESCE(MAX(sort_order), 0) INTO v_max_sort_order")
    print("    FROM exercise")
    print("    WHERE session_schedule_id = v_session_schedule_id;")
    print()

    # Add exercises for each imported/created base_exercise
    sort_idx = 1
    all_new_ids = list(new_base_exercise_ids.items())

    for source_or_name, base_id in all_new_ids:
        print(f"    -- Exercise for: {source_or_name}")
        print(f"    INSERT INTO exercise (")
        print(f"        exercise_id, base_exercise_id, session_schedule_id,")
        print(f"        reps, sets, rest, sort_order")
        print(f"    ) VALUES (")
        print(f"        uuid_generate_v1mc(),")
        print(f"        '{base_id}',")
        print(f"        v_session_schedule_id,")
        print(f"        10,  -- default reps")
        print(f"        3,   -- default sets")
        print(f"        '60 seconds'::interval,  -- default rest")
        print(f"        v_max_sort_order + {sort_idx}")
        print(f"    );")
        print()
        sort_idx += 1

    print("END $$;")
    print()

    # ========================================================================
    # PART 5: Update performed_exercise records
    # ========================================================================
    print("-- ============================================================================")
    print("-- PART 5: Update performed_exercise records with exercise_id")
    print("-- ============================================================================")
    print()
    print("-- Update performed_exercises to reference exercises (any plan)")
    print("UPDATE performed_exercise pe")
    print("SET exercise_id = (")
    print("    SELECT e.exercise_id")
    print("    FROM exercise e")
    print("    JOIN base_exercise be ON e.base_exercise_id = be.base_exercise_id")
    print("    WHERE (")
    print("          -- Match by normalized name")
    print("          LOWER(TRIM(pe.name)) = LOWER(TRIM(be.name))")
    print("          -- Match by alias")
    print("          OR be.aliases @> ARRAY[LOWER(TRIM(pe.name))]")
    print("      )")
    print("    LIMIT 1")
    print(")")
    print("WHERE pe.exercise_id IS NULL;")
    print()

    # ========================================================================
    # PART 6: Verification
    # ========================================================================
    print("-- ============================================================================")
    print("-- PART 6: Verification")
    print("-- ============================================================================")
    print()
    print("DO $$")
    print("DECLARE")
    print("    v_null_count integer;")
    print("    v_updated_count integer;")
    print("BEGIN")
    print("    SELECT COUNT(*) INTO v_null_count")
    print("    FROM performed_exercise")
    print("    WHERE exercise_id IS NULL;")
    print()
    print("    SELECT COUNT(*) INTO v_updated_count")
    print("    FROM performed_exercise pe")
    print("    JOIN exercise e ON pe.exercise_id = e.exercise_id")
    print("    JOIN session_schedule ss ON e.session_schedule_id = ss.session_schedule_id")
    print("    JOIN plan p ON ss.plan_id = p.plan_id")
    print("    WHERE p.name = 'Unknown';")
    print()
    print("    RAISE NOTICE '================================================';")
    print("    RAISE NOTICE 'Migration Results:';")
    print("    RAISE NOTICE '================================================';")
    print("    RAISE NOTICE 'Performed exercises updated: %', v_updated_count;")
    print("    RAISE NOTICE 'Remaining NULL exercise_id: %', v_null_count;")
    print()
    print("    IF v_null_count > 0 THEN")
    print("        RAISE WARNING 'Still have % performed_exercises with null exercise_id!', v_null_count;")
    print("    ELSE")
    print("        RAISE NOTICE '✓ SUCCESS: All performed_exercises now have exercise_id';")
    print("    END IF;")
    print("END $$;")
    print()

    print("COMMIT;")
    print()
    print(f"-- Migration complete!")
    print(f"-- Added aliases to 13 existing exercises")
    print(f"-- Imported {len(free_exercises)} exercises from free-exercise-db")
    print(f"-- Created 2 new custom exercises")
    print(f"-- Total new exercises in Unknown plan: {len(all_new_ids)}")

if __name__ == "__main__":
    generate_migration()
