#!/usr/bin/env python3
"""
Search free-exercise-db for matches to custom exercises.
"""

import json
import os
from pathlib import Path

# Custom exercises that need matching
CUSTOM_EXERCISES = [
    "Pull-up", "Machine chest fly", "ISO-lateral bench press", "ISO-lateral shoulder press",
    "Bayesian bicep curl", "Machine row", "Barbell preacher curl", "Leg press",
    "Machine chest press", "Machine shoulder press", "Preacher curl machine",
    "Reverse machine fly", "Assisted pullup", "Bicep preacher curl machine",
    "Cable reverse fly", "Chest fly machine", "Chin-up", "Leg press calf-press",
    "Machine preacher curl", "Push press", "Reverse chest fly",
    "Body weight lunges", "Dumbbell lying tricep extension", "EZ-Bar lying tricep extension",
    "One-legged elevated squat", "Seated leg extension", "Dumbbell toe raises"
]

def normalize_name(name):
    """Normalize exercise name for matching."""
    return name.lower().replace("-", " ").replace("_", " ")

def search_exercises():
    """Search for matches in free-exercise-db."""
    exercise_dir = Path("free-exercise-db/exercises")

    # Load all exercises with metadata
    all_exercises = {}
    for json_file in exercise_dir.glob("*.json"):
        try:
            with open(json_file, 'r') as f:
                data = json.load(f)
                norm_name = normalize_name(data['name'])
                all_exercises[norm_name] = {
                    'name': data['name'],
                    'level': data.get('level', 'N/A'),
                    'mechanic': data.get('mechanic', 'N/A'),
                    'equipment': data.get('equipment', 'N/A'),
                    'force': data.get('force', 'N/A'),
                    'category': data.get('category', 'N/A'),
                    'primary': ', '.join(data.get('primaryMuscles', [])),
                    'secondary': ', '.join(data.get('secondaryMuscles', [])),
                    'file': json_file.stem
                }
        except Exception as e:
            print(f"Error reading {json_file}: {e}")

    print(f"Loaded {len(all_exercises)} exercises from free-exercise-db\n")
    print("="*80)
    print("SEARCHING FOR MATCHES")
    print("="*80)

    for custom in CUSTOM_EXERCISES:
        norm_custom = normalize_name(custom)
        print(f"\n## {custom}")

        # Try exact match first
        if norm_custom in all_exercises:
            ex = all_exercises[norm_custom]
            print(f"✓ EXACT MATCH: {ex['name']}")
            print(f"  Level: {ex['level']}, Mechanic: {ex['mechanic']}, Equipment: {ex['equipment']}")
            print(f"  Force: {ex['force']}, Category: {ex['category']}")
            print(f"  Primary: {ex['primary']}")
            if ex['secondary']:
                print(f"  Secondary: {ex['secondary']}")
            continue

        # Try partial matches
        matches = []
        for norm_name, ex in all_exercises.items():
            # Check if custom name contains exercise name or vice versa
            if (norm_custom in norm_name or norm_name in norm_custom) and len(norm_name) > 3:
                matches.append(ex)

        if matches:
            print(f"⚠ PARTIAL MATCHES ({len(matches)}):")
            for ex in matches[:5]:  # Show top 5
                print(f"  - {ex['name']} ({ex['equipment']}, {ex['mechanic']})")
        else:
            print(f"✗ NO MATCH - Need to create new exercise")

if __name__ == "__main__":
    search_exercises()
