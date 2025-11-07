#!/usr/bin/env python3
"""
Generate alias mappings for exercises.
Groups custom names by their matched exercise to create comprehensive aliases.
"""

import csv
import json
from pathlib import Path
from collections import defaultdict

def load_mapping():
    """Load the exercise mapping CSV."""
    with open('EXERCISE_MAPPING.csv', 'r') as f:
        reader = csv.DictReader(f)
        return list(reader)

def generate_aliases():
    """Generate alias mappings grouped by exercise."""

    mappings = load_mapping()

    # Group by exercise (either existing DB or free-exercise-db)
    existing_db_aliases = defaultdict(set)
    free_db_aliases = defaultdict(set)

    for row in mappings:
        custom_name = row['custom_name_normalized']
        match_type = row['match_type']

        if match_type == 'existing_db':
            key = (row['base_exercise_id'], row['base_exercise_name'])
            existing_db_aliases[key].add(custom_name)

        elif match_type == 'free_exercise_db':
            key = (row['source_id'], row['free_exercise_db_name'])
            free_db_aliases[key].add(custom_name)

    print("="*80)
    print("ALIAS MAPPINGS FOR MIGRATION")
    print("="*80)

    # Existing DB exercises (already in database, just add aliases)
    print("\n## 1. Existing Database Exercises - Add Aliases")
    print("-" * 80)
    existing_count = 0
    for (base_id, base_name), aliases in sorted(existing_db_aliases.items(), key=lambda x: x[0][1]):
        # Skip if the only alias is the same as the base name (normalized)
        base_norm = base_name.lower().strip()
        unique_aliases = [a for a in aliases if a != base_norm]

        if unique_aliases:
            existing_count += len(unique_aliases)
            print(f"\n{base_name} ({base_id})")
            print(f"  Add aliases: {', '.join(sorted(unique_aliases))}")

    # Free-exercise-db exercises (need to import from JSON)
    print("\n\n## 2. Free-Exercise-DB Exercises - Import with Aliases")
    print("-" * 80)
    free_count = 0
    free_exercises = []

    for (source_id, db_name), aliases in sorted(free_db_aliases.items(), key=lambda x: x[1]):
        # Load metadata from JSON
        json_path = Path(f"free-exercise-db/exercises/{source_id}.json")
        if not json_path.exists():
            print(f"WARNING: {json_path} not found")
            continue

        with open(json_path, 'r') as f:
            data = json.load(f)

        # Get unique aliases (exclude exact match to name)
        name_norm = data['name'].lower().strip()
        unique_aliases = [a for a in aliases if a != name_norm]

        if unique_aliases:
            free_count += len(unique_aliases)

        exercise_info = {
            'source_id': source_id,
            'name': data['name'],
            'level': data.get('level', 'beginner'),
            'mechanic': data.get('mechanic', 'compound'),
            'equipment': data.get('equipment', None),
            'force': data.get('force', None),
            'category': data.get('category', 'strength'),
            'primary_muscles': data.get('primaryMuscles', []),
            'secondary_muscles': data.get('secondaryMuscles', []),
            'aliases': sorted(unique_aliases),
            'custom_names': sorted(aliases)
        }
        free_exercises.append(exercise_info)

        print(f"\n{data['name']} (source_id: {source_id})")
        print(f"  Level: {exercise_info['level']}, Mechanic: {exercise_info['mechanic']}, Equipment: {exercise_info['equipment']}")
        print(f"  Primary: {', '.join(exercise_info['primary_muscles'])}")
        if exercise_info['secondary_muscles']:
            print(f"  Secondary: {', '.join(exercise_info['secondary_muscles'])}")
        if unique_aliases:
            print(f"  Add aliases: {', '.join(unique_aliases)}")

    # Save detailed JSON for migration script
    with open('FREE_EXERCISE_DB_TO_IMPORT.json', 'w') as f:
        json.dump(free_exercises, f, indent=2)

    print("\n" + "="*80)
    print("SUMMARY")
    print("="*80)
    print(f"Existing DB exercises with new aliases: {len([k for k,v in existing_db_aliases.items() if len([a for a in v if a != k[1].lower().strip()]) > 0])}")
    print(f"  Total aliases to add: {existing_count}")
    print(f"\nFree-Exercise-DB exercises to import: {len(free_exercises)}")
    print(f"  Total aliases to add: {free_count}")
    print(f"\nOutput files:")
    print(f"  - FREE_EXERCISE_DB_TO_IMPORT.json (for migration script)")

    return existing_db_aliases, free_db_aliases

if __name__ == "__main__":
    generate_aliases()
