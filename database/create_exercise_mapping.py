#!/usr/bin/env python3
"""
Create comprehensive mapping of custom exercises to their matches.
Tracks both source_id (free-exercise-db) and base_exercise_id (existing DB).
"""

import json
import csv
from pathlib import Path

# Existing database exercises with their UUIDs (from restored production DB)
EXISTING_DB = {
    # Equipment-prefix matches (base exercises with NULL equipment)
    "cable bicep curl": ("bee63c0c-05c8-11ed-824f-673da9665bfa", "Bicep curl"),
    "cable lateral raise": ("a3532824-4bc2-11ee-8c75-ebab3389e058", "Lateral raise"),
    "cable overhead press": ("1a7bd55a-31ba-11ed-aa8c-63d32f2aae22", "Overhead press"),
    "dumbbell lateral raise": ("a3532824-4bc2-11ee-8c75-ebab3389e058", "Lateral raise"),
    "dumbell overhead press": ("1a7bd55a-31ba-11ed-aa8c-63d32f2aae22", "Overhead press"),
    "dumbell bench press": ("02a1a38a-70f9-11ef-bc64-d72b6479cb97", "Bench press"),
    "kettlebell overhead press": ("1a7bd55a-31ba-11ed-aa8c-63d32f2aae22", "Overhead press"),
    "machine bicep curl": ("bee63c0c-05c8-11ed-824f-673da9665bfa", "Bicep curl"),
    "machine overhead press": ("1a7bd55a-31ba-11ed-aa8c-63d32f2aae22", "Overhead press"),
    "smith squat": ("1a826cd0-31ba-11ed-aa8c-67424ddf3bd1", "Squat"),

    # Exact matches
    "lateral raise": ("a3532824-4bc2-11ee-8c75-ebab3389e058", "Lateral raise"),
    "bench press": ("02a1a38a-70f9-11ef-bc64-d72b6479cb97", "Bench press"),
    "machine lateral raise": ("292952c2-dc9e-11ee-b3ef-bb9c1105deaa", "Machine lateral raise"),
    "machine crunch": ("a34d401c-4bc2-11ee-8c75-a75e6f336c22", "Machine crunch"),

    # Additional matches found
    "lat pulldown machine": ("28c781a0-dc9e-11ee-b3ef-b3d83ae9ef50", "Lat pulldown"),
    "t-bar row machine": ("29d5069e-dc9e-11ee-b3ef-574f7b65abee", "T-Bar row"),
    "pulley row": ("bef59bde-05c8-11ed-824f-efb3c762cda1", "Seated pulley row †"),
    "smith machine calf raise": ("bef283ae-05c8-11ed-824f-870b793b71df", "Calf raise"),
    "ez-bar preacher curl": ("2a163cfe-dc9e-11ee-b3ef-575801647e7d", "EZ-bar bicep curl"),
    "flat bench press backoff": ("2885f762-dc9e-11ee-b3ef-0fa909073fa5", "Flat dumbbell press backoff"),
    "high incline smith presss": ("29b44c42-dc9e-11ee-b3ef-53720d6ec33a", "High incline smith press"),
    "sandbag step-up": ("28e81f6e-dc9e-11ee-b3ef-5b9f8379af2d", "Dumbbell step up"),
    "dumbbell toe raises": ("bef283ae-05c8-11ed-824f-870b793b71df", "Calf raise"),
}

# Free-exercise-db matches (source_id from JSON files)
FREE_EXERCISE_DB = {
    # High priority
    "pull-up": "Pullups",
    "pullup": "Pullups",
    "pull up": "Pullups",

    "machine chest fly": "Butterfly",
    "chest fly machine": "Butterfly",

    "leg press": "Leg_Press",
    "cybex leg-press": "Leg_Press",

    # Medium priority
    "machine row": "Leverage_Iso_Row",
    "preacher curl machine": "Machine_Preacher_Curls",
    "bicep preacher curl machine": "Machine_Preacher_Curls",
    "machine preacher curl": "Machine_Preacher_Curls",
    "reverse machine fly": "Reverse_Machine_Flyes",
    "barbell preacher curl": "Preacher_Curl",
    "machine chest press": "Leverage_Chest_Press",
    "machine shoulder press": "Machine_Shoulder_Military_Press",
    "shoulder press machine": "Machine_Shoulder_Military_Press",

    # ISO-lateral (assuming Leverage = ISO-lateral)
    "iso-lateral bench press": "Leverage_Chest_Press",
    "iso-lateral bench press machine": "Leverage_Chest_Press",
    "iso lateral chest press": "Leverage_Chest_Press",
    "iso-lateral shoulder press": "Leverage_Shoulder_Press",
    "iso-lateral shoulder press machine": "Leverage_Shoulder_Press",

    # Single use
    "chin-up": "Chin-Up",
    "chin up": "Chin-Up",
    "push press": "Push_Press",
    "assisted pullup": "Band_Assisted_Pull-Up",
    "body weight lunges": "Bodyweight_Walking_Lunge",
    "dumbbell lying tricep extension": "Lying_Dumbbell_Tricep_Extension",
    "ez-bar lying tricep extension": "Lying_Close-Grip_Barbell_Triceps_Extension_Behind_The_Head",
    "seated leg extension": "Leg_Extensions",
    "leg press calf-press": "Calf_Press_On_The_Leg_Press_Machine",
    "one-legged elevated squat": "Split_Squats",
}

# Exercises to create (not in DB or free-exercise-db)
CREATE_NEW = {
    "bayesian bicep curl": {
        "name": "Bayesian bicep curl",
        "aliases": ["Behind-the-back curl", "Face-away cable curl"],
        "level": "Beginner",
        "mechanic": "Isolation",
        "force": "Pull",
        "equipment": "Cable",
        "category": "Strength",
        "primary_muscles": ["Biceps"],
        "secondary_muscles": [],
    },
    "cable reverse fly": {
        "name": "Cable reverse fly",
        "aliases": ["Reverse chest fly"],
        "level": "Beginner",
        "mechanic": "Isolation",
        "force": "Pull",
        "equipment": "Cable",
        "category": "Strength",
        "primary_muscles": ["Shoulders"],
        "secondary_muscles": ["Middle Back"],
    },
}

def normalize_name(name):
    """Normalize for case-insensitive matching."""
    return name.lower().strip().replace("_", " ").replace("-", " ")

def create_mapping():
    """Create comprehensive CSV mapping."""

    mappings = []

    print("Creating comprehensive exercise mapping...")
    print("="*80)

    # Process existing DB matches
    print("\n## Existing Database Matches")
    for custom_norm, (base_id, base_name) in EXISTING_DB.items():
        mappings.append({
            "custom_name_normalized": custom_norm,
            "match_type": "existing_db",
            "base_exercise_id": base_id,
            "base_exercise_name": base_name,
            "source_id": None,
            "free_exercise_db_name": None,
        })
        print(f"  {custom_norm} → {base_name} ({base_id})")

    # Process free-exercise-db matches
    print(f"\n## Free-Exercise-DB Matches")
    for custom_norm, source_id in FREE_EXERCISE_DB.items():
        # Load metadata from JSON
        json_path = Path(f"free-exercise-db/exercises/{source_id}.json")
        if json_path.exists():
            with open(json_path, 'r') as f:
                data = json.load(f)
                exercise_name = data['name']
        else:
            exercise_name = source_id.replace("_", " ").replace("-", " ")

        mappings.append({
            "custom_name_normalized": custom_norm,
            "match_type": "free_exercise_db",
            "base_exercise_id": None,
            "base_exercise_name": None,
            "source_id": source_id,
            "free_exercise_db_name": exercise_name,
        })
        print(f"  {custom_norm} → {exercise_name} (source_id: {source_id})")

    # Process new exercises to create
    print(f"\n## New Exercises to Create")
    for custom_norm, metadata in CREATE_NEW.items():
        mappings.append({
            "custom_name_normalized": custom_norm,
            "match_type": "create_new",
            "base_exercise_id": "TO_BE_GENERATED",
            "base_exercise_name": metadata["name"],
            "source_id": None,
            "free_exercise_db_name": None,
        })
        print(f"  {custom_norm} → CREATE NEW: {metadata['name']}")

    # Write CSV
    csv_path = "EXERCISE_MAPPING.csv"
    with open(csv_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=[
            "custom_name_normalized",
            "match_type",
            "base_exercise_id",
            "base_exercise_name",
            "source_id",
            "free_exercise_db_name"
        ])
        writer.writeheader()
        writer.writerows(mappings)

    print(f"\n{'='*80}")
    print(f"Created mapping: {csv_path}")
    print(f"Total mappings: {len(mappings)}")
    print(f"  - Existing DB: {sum(1 for m in mappings if m['match_type'] == 'existing_db')}")
    print(f"  - Free-Exercise-DB: {sum(1 for m in mappings if m['match_type'] == 'free_exercise_db')}")
    print(f"  - Create New: {sum(1 for m in mappings if m['match_type'] == 'create_new')}")

if __name__ == "__main__":
    create_mapping()
