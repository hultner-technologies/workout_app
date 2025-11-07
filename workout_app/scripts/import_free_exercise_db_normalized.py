#!/usr/bin/env python3
"""
Import exercises from free-exercise-db into the workout app database (NORMALIZED VERSION).

This version uses the fully normalized schema with junction tables for muscles.

Usage:
    python -m workout_app.scripts.import_free_exercise_db_normalized --help
"""

import json
import argparse
import logging
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
import os
import sys

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

try:
    import psycopg2
    from psycopg2.extras import execute_values, Json
except ImportError:
    print("Error: psycopg2 not installed. Install with: poetry add psycopg2-binary")
    sys.exit(1)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


@dataclass
class Exercise:
    """Represents an exercise from free-exercise-db"""
    id: str
    name: str
    force: Optional[str]
    level: str
    mechanic: Optional[str]
    equipment: Optional[str]
    primary_muscles: List[str]
    secondary_muscles: List[str]
    instructions: List[str]
    category: str
    images: List[str]

    @classmethod
    def from_json(cls, data: Dict[str, Any]) -> 'Exercise':
        """Create Exercise from JSON data"""
        return cls(
            id=data['id'],
            name=data['name'],
            force=data.get('force'),
            level=data['level'],
            mechanic=data.get('mechanic'),
            equipment=data.get('equipment'),
            primary_muscles=data.get('primaryMuscles', []),
            secondary_muscles=data.get('secondaryMuscles', []),
            instructions=data.get('instructions', []),
            category=data['category'],
            images=data.get('images', [])
        )

    def to_image_urls(self, base_url: str = 'https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/') -> List[str]:
        """Convert image paths to full URLs"""
        return [f"{base_url}{img}" for img in self.images]


class ExerciseImporterNormalized:
    """Handles importing exercises into normalized schema"""

    def __init__(self, db_url: str, exercises_file: Path, output_dir: Path):
        self.db_url = db_url
        self.exercises_file = exercises_file
        self.output_dir = output_dir
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
        # Caches for foreign key lookups
        self.category_cache: Dict[str, str] = {}
        self.equipment_cache: Dict[str, str] = {}
        self.muscle_cache: Dict[str, str] = {}
        
        # Statistics
        self.stats = {
            'total_exercises': 0,
            'new_exercises': 0,
            'potential_duplicates': 0,
            'imported': 0,
            'errors': 0
        }
        
        # Logging files
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        self.merge_script_file = self.output_dir / f'merge_duplicates_{timestamp}.sql'
        self.import_log_file = self.output_dir / f'import_log_{timestamp}.json'
        self.duplicate_log_file = self.output_dir / f'duplicates_{timestamp}.json'

    def connect(self):
        """Connect to database"""
        logger.info("Connecting to database...")
        return psycopg2.connect(self.db_url)

    def load_caches(self, conn):
        """Load reference table caches for FK lookups"""
        logger.info("Loading reference table caches...")
        
        with conn.cursor() as cur:
            # Load categories
            cur.execute("SELECT category_id, name FROM exercise_category")
            self.category_cache = {row[1]: row[0] for row in cur.fetchall()}
            
            # Load equipment types
            cur.execute("SELECT equipment_type_id, name FROM equipment_type")
            self.equipment_cache = {row[1]: row[0] for row in cur.fetchall()}
            
            # Load muscle groups
            cur.execute("SELECT muscle_group_id, name FROM muscle_group")
            self.muscle_cache = {row[1]: row[0] for row in cur.fetchall()}
        
        logger.info(f"Loaded {len(self.category_cache)} categories, "
                   f"{len(self.equipment_cache)} equipment types, "
                   f"{len(self.muscle_cache)} muscle groups")

    def get_category_id(self, category_name: Optional[str]) -> Optional[str]:
        """Get category_id from cache"""
        if not category_name:
            return None
        return self.category_cache.get(category_name)

    def get_equipment_id(self, equipment_name: Optional[str]) -> Optional[str]:
        """Get equipment_type_id from cache"""
        if not equipment_name:
            return None
        return self.equipment_cache.get(equipment_name)

    def get_muscle_id(self, muscle_name: str) -> Optional[str]:
        """Get muscle_group_id from cache"""
        return self.muscle_cache.get(muscle_name)

    def load_exercises(self) -> List[Exercise]:
        """Load exercises from JSON file"""
        logger.info(f"Loading exercises from {self.exercises_file}")
        with open(self.exercises_file, 'r') as f:
            data = json.load(f)
        
        exercises = [Exercise.from_json(ex) for ex in data]
        self.stats['total_exercises'] = len(exercises)
        logger.info(f"Loaded {len(exercises)} exercises")
        return exercises

    def find_potential_duplicates(self, conn, exercise: Exercise) -> List[Tuple[str, str, float]]:
        """Find potential duplicate exercises"""
        with conn.cursor() as cur:
            # Try exact name match
            cur.execute(
                """
                SELECT base_exercise_id, name, 1.0 as score
                FROM base_exercise
                WHERE LOWER(name) = LOWER(%s)
                """,
                (exercise.name,)
            )
            exact_matches = cur.fetchall()
            if exact_matches:
                return exact_matches

            # Try alias match
            cur.execute(
                """
                SELECT base_exercise_id, name, 0.95 as score
                FROM base_exercise
                WHERE %s = ANY(aliases)
                """,
                (exercise.name,)
            )
            alias_matches = cur.fetchall()
            if alias_matches:
                return alias_matches

            # Try fuzzy match
            cur.execute(
                """
                SELECT base_exercise_id, name, similarity(name, %s) as score
                FROM base_exercise
                WHERE similarity(name, %s) > 0.5
                ORDER BY score DESC
                LIMIT 5
                """,
                (exercise.name, exercise.name)
            )
            fuzzy_matches = cur.fetchall()
            return fuzzy_matches

        return []

    def generate_merge_sql(self, exercise: Exercise, existing_id: str, existing_name: str):
        """Generate SQL for merging duplicate exercise"""
        # Build muscle merge logic
        primary_muscles_sql = ""
        for muscle in exercise.primary_muscles:
            muscle_id = self.get_muscle_id(muscle)
            if muscle_id:
                primary_muscles_sql += f"""
INSERT INTO base_exercise_primary_muscle (base_exercise_id, muscle_group_id)
VALUES ('{existing_id}', '{muscle_id}')
ON CONFLICT DO NOTHING;
"""
        
        secondary_muscles_sql = ""
        for muscle in exercise.secondary_muscles:
            muscle_id = self.get_muscle_id(muscle)
            if muscle_id:
                secondary_muscles_sql += f"""
INSERT INTO base_exercise_secondary_muscle (base_exercise_id, muscle_group_id)
VALUES ('{existing_id}', '{muscle_id}')
ON CONFLICT DO NOTHING;
"""
        
        category_id = self.get_category_id(exercise.category)
        equipment_id = self.get_equipment_id(exercise.equipment)
        
        merge_sql = f"""
-- ============================================================================
-- Merge: {exercise.name} (free-exercise-db) -> {existing_name} (existing)
-- ============================================================================
-- Source ID: {exercise.id}
-- Existing ID: {existing_id}

-- Option 1: Update existing exercise with new metadata
UPDATE base_exercise
SET 
    -- Add source ID as alias
    aliases = CASE 
        WHEN NOT ('{exercise.id}' = ANY(COALESCE(aliases, ARRAY[]::text[]))) 
        THEN COALESCE(aliases, ARRAY[]::text[]) || ARRAY['{exercise.id}']
        ELSE aliases
    END,
    
    -- Update metadata fields only if currently NULL
    level = COALESCE(level, {f"'{exercise.level}'" if exercise.level else 'NULL'}),
    mechanic = COALESCE(mechanic, {f"'{exercise.mechanic}'" if exercise.mechanic else 'NULL'}),
    force = COALESCE(force, {f"'{exercise.force}'" if exercise.force else 'NULL'}),
    category_id = COALESCE(category_id, {f"'{category_id}'" if category_id else 'NULL'}),
    equipment_type_id = COALESCE(equipment_type_id, {f"'{equipment_id}'" if equipment_id else 'NULL'}),
    
    -- Merge instructions
    instructions = CASE
        WHEN instructions IS NULL OR array_length(instructions, 1) IS NULL
        THEN ARRAY{exercise.instructions}::text[]
        ELSE instructions
    END,
    
    -- Merge images
    image_urls = CASE
        WHEN image_urls IS NULL OR array_length(image_urls, 1) IS NULL
        THEN ARRAY{exercise.to_image_urls()}::text[]
        ELSE image_urls
    END,
    
    -- Track source
    source_id = COALESCE(source_id, '{exercise.id}'),
    source_name = COALESCE(source_name, 'free-exercise-db')
    
WHERE base_exercise_id = '{existing_id}';

-- Merge primary muscles
{primary_muscles_sql}

-- Merge secondary muscles
{secondary_muscles_sql}

"""
        return merge_sql

    def import_exercise(self, conn, exercise: Exercise, check_duplicates: bool = True) -> bool:
        """Import a single exercise into normalized schema"""
        try:
            # Check for duplicates
            if check_duplicates:
                duplicates = self.find_potential_duplicates(conn, exercise)
                if duplicates:
                    self.stats['potential_duplicates'] += 1
                    logger.info(f"Found {len(duplicates)} potential duplicate(s) for '{exercise.name}'")
                    
                    # Log duplicate
                    duplicate_info = {
                        'exercise': exercise.name,
                        'source_id': exercise.id,
                        'matches': [
                            {'id': str(dup[0]), 'name': dup[1], 'score': float(dup[2])}
                            for dup in duplicates
                        ]
                    }
                    self._append_to_log(self.duplicate_log_file, duplicate_info)
                    
                    # Generate merge SQL
                    best_match = duplicates[0]
                    merge_sql = self.generate_merge_sql(exercise, str(best_match[0]), best_match[1])
                    with open(self.merge_script_file, 'a') as f:
                        f.write(merge_sql)
                    
                    return False

            # Get foreign key IDs
            category_id = self.get_category_id(exercise.category)
            equipment_id = self.get_equipment_id(exercise.equipment)

            # Insert base exercise
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO base_exercise (
                        name,
                        description,
                        level,
                        mechanic,
                        force,
                        category_id,
                        equipment_type_id,
                        instructions,
                        image_urls,
                        source_id,
                        source_name,
                        aliases
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    )
                    RETURNING base_exercise_id
                    """,
                    (
                        exercise.name,
                        f"Imported from free-exercise-db",
                        exercise.level,
                        exercise.mechanic,
                        exercise.force,
                        category_id,
                        equipment_id,
                        exercise.instructions,
                        exercise.to_image_urls(),
                        exercise.id,
                        'free-exercise-db',
                        [exercise.id]
                    )
                )
                
                new_id = cur.fetchone()[0]
                
                # Insert primary muscles using the helper function
                cur.execute(
                    "SELECT set_exercise_muscles(%s, %s, %s)",
                    (new_id, exercise.primary_muscles, exercise.secondary_muscles)
                )
                
                logger.info(f"Imported '{exercise.name}' as {new_id}")
                self.stats['imported'] += 1
                
                # Log import
                self._append_to_log(self.import_log_file, {
                    'exercise': exercise.name,
                    'source_id': exercise.id,
                    'new_id': str(new_id),
                    'primary_muscles': exercise.primary_muscles,
                    'secondary_muscles': exercise.secondary_muscles,
                    'timestamp': datetime.now().isoformat()
                })
                
                return True

        except Exception as e:
            logger.error(f"Error importing '{exercise.name}': {e}")
            self.stats['errors'] += 1
            return False

    def _append_to_log(self, log_file: Path, data: Dict):
        """Append data to JSON log file"""
        logs = []
        if log_file.exists():
            with open(log_file, 'r') as f:
                logs = json.load(f)
        
        logs.append(data)
        
        with open(log_file, 'w') as f:
            json.dump(logs, f, indent=2)

    def enable_trigram_extension(self, conn):
        """Enable pg_trgm extension for fuzzy matching"""
        try:
            with conn.cursor() as cur:
                cur.execute("CREATE EXTENSION IF NOT EXISTS pg_trgm")
                conn.commit()
                logger.info("Enabled pg_trgm extension for fuzzy matching")
        except Exception as e:
            logger.warning(f"Could not enable pg_trgm extension: {e}")

    def run(self, dry_run: bool = False, skip_duplicate_check: bool = False):
        """Run the import process"""
        logger.info("=" * 80)
        logger.info("Starting Free Exercise DB Import (Normalized Schema)")
        logger.info("=" * 80)
        
        # Load exercises
        exercises = self.load_exercises()
        
        # Connect to database
        conn = self.connect()
        
        try:
            # Load caches
            self.load_caches(conn)
            
            # Enable fuzzy matching
            self.enable_trigram_extension(conn)
            
            # Initialize merge script
            with open(self.merge_script_file, 'w') as f:
                f.write(f"""-- Merge Script for Duplicate Exercises (Normalized Schema)
-- Generated: {datetime.now().isoformat()}

BEGIN;

""")
            
            # Process exercises
            for i, exercise in enumerate(exercises, 1):
                if i % 100 == 0:
                    logger.info(f"Processed {i}/{len(exercises)} exercises...")
                
                if not dry_run:
                    imported = self.import_exercise(
                        conn, 
                        exercise,
                        check_duplicates=not skip_duplicate_check
                    )
                    
                    if imported:
                        self.stats['new_exercises'] += 1
                        conn.commit()
                else:
                    duplicates = self.find_potential_duplicates(conn, exercise)
                    if duplicates:
                        self.stats['potential_duplicates'] += 1
                    else:
                        self.stats['new_exercises'] += 1
            
            # Finalize merge script
            with open(self.merge_script_file, 'a') as f:
                f.write("\n-- COMMIT;\nROLLBACK;\n")
            
        finally:
            conn.close()
        
        # Print summary
        self._print_summary(dry_run)

    def _print_summary(self, dry_run: bool):
        """Print import summary"""
        logger.info("=" * 80)
        logger.info("Import Summary")
        logger.info("=" * 80)
        logger.info(f"Total exercises: {self.stats['total_exercises']}")
        logger.info(f"New exercises: {self.stats['new_exercises']}")
        logger.info(f"Duplicates: {self.stats['potential_duplicates']}")
        if not dry_run:
            logger.info(f"Imported: {self.stats['imported']}")
            logger.info(f"Errors: {self.stats['errors']}")
        logger.info(f"\nMerge script: {self.merge_script_file}")
        logger.info(f"Duplicate log: {self.duplicate_log_file}")
        if not dry_run:
            logger.info(f"Import log: {self.import_log_file}")


def main():
    parser = argparse.ArgumentParser(description='Import exercises (normalized schema)')
    parser.add_argument('--db-url', default=os.getenv('DATABASE_URL'))
    parser.add_argument('--exercises-file', type=Path,
                       default=Path(__file__).parent.parent.parent.parent / 'free-exercise-db' / 'dist' / 'exercises.json')
    parser.add_argument('--output-dir', type=Path,
                       default=Path(__file__).parent.parent.parent.parent / 'database' / 'import_logs')
    parser.add_argument('--dry-run', action='store_true')
    parser.add_argument('--skip-duplicate-check', action='store_true')
    
    args = parser.parse_args()
    
    if not args.db_url:
        parser.error("Database URL required")
    if not args.exercises_file.exists():
        parser.error(f"Exercises file not found: {args.exercises_file}")
    
    importer = ExerciseImporterNormalized(
        db_url=args.db_url,
        exercises_file=args.exercises_file,
        output_dir=args.output_dir
    )
    
    importer.run(dry_run=args.dry_run, skip_duplicate_check=args.skip_duplicate_check)


if __name__ == '__main__':
    main()
