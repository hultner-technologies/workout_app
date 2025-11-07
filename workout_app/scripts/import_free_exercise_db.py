#!/usr/bin/env python3
"""
Import exercises from free-exercise-db into the workout app database.

This script:
1. Reads exercises from free-exercise-db/dist/exercises.json
2. Detects potential duplicates in existing database
3. Generates SQL audit scripts for manual review and merging
4. Imports new exercises into base_exercise table
5. Logs all operations for tracking

Usage:
    python -m workout_app.scripts.import_free_exercise_db --help
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


class ExerciseImporter:
    """Handles importing exercises from free-exercise-db into database"""

    def __init__(self, db_url: str, exercises_file: Path, output_dir: Path):
        self.db_url = db_url
        self.exercises_file = exercises_file
        self.output_dir = output_dir
        self.output_dir.mkdir(parents=True, exist_ok=True)
        
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
        """
        Find potential duplicate exercises in database using fuzzy matching.
        Returns list of (base_exercise_id, name, similarity_score)
        """
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

            # Try fuzzy match using trigram similarity (requires pg_trgm extension)
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
        """Generate SQL script to merge duplicate exercise data"""
        merge_sql = f"""
-- ============================================================================
-- Merge: {exercise.name} (free-exercise-db) -> {existing_name} (existing)
-- ============================================================================
-- Source ID: {exercise.id}
-- Existing ID: {existing_id}

-- Option 1: Update existing exercise with new metadata
UPDATE base_exercise
SET 
    -- Add source ID as alias if not already present
    aliases = CASE 
        WHEN NOT ('{exercise.id}' = ANY(COALESCE(aliases, ARRAY[]::text[]))) 
        THEN COALESCE(aliases, ARRAY[]::text[]) || ARRAY['{exercise.id}']
        ELSE aliases
    END,
    
    -- Update metadata fields only if currently NULL
    level = COALESCE(level, {f"'{exercise.level}'" if exercise.level else 'NULL'}),
    mechanic = COALESCE(mechanic, {f"'{exercise.mechanic}'" if exercise.mechanic else 'NULL'}),
    force = COALESCE(force, {f"'{exercise.force}'" if exercise.force else 'NULL'}),
    category = COALESCE(category, {f"'{exercise.category}'" if exercise.category else 'NULL'}),
    equipment = COALESCE(equipment, {f"'{exercise.equipment}'" if exercise.equipment else 'NULL'}),
    
    -- Merge muscle arrays
    primary_muscles = CASE
        WHEN primary_muscles IS NULL OR array_length(primary_muscles, 1) IS NULL
        THEN {f"ARRAY{exercise.primary_muscles}::text[]" if exercise.primary_muscles else 'NULL'}
        ELSE primary_muscles
    END,
    
    secondary_muscles = CASE
        WHEN secondary_muscles IS NULL OR array_length(secondary_muscles, 1) IS NULL
        THEN {f"ARRAY{exercise.secondary_muscles}::text[]" if exercise.secondary_muscles else 'NULL'}
        ELSE secondary_muscles
    END,
    
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

-- Option 2: Skip merge (already has good data)
-- (Comment out the UPDATE above and do nothing)

"""
        return merge_sql

    def import_exercise(self, conn, exercise: Exercise, check_duplicates: bool = True) -> bool:
        """
        Import a single exercise into database.
        Returns True if imported, False if skipped (duplicate found).
        """
        try:
            # Check for duplicates
            if check_duplicates:
                duplicates = self.find_potential_duplicates(conn, exercise)
                if duplicates:
                    self.stats['potential_duplicates'] += 1
                    logger.info(f"Found {len(duplicates)} potential duplicate(s) for '{exercise.name}'")
                    
                    # Log duplicate for review
                    duplicate_info = {
                        'exercise': exercise.name,
                        'source_id': exercise.id,
                        'matches': [
                            {'id': str(dup[0]), 'name': dup[1], 'score': float(dup[2])}
                            for dup in duplicates
                        ]
                    }
                    
                    # Append to duplicate log
                    self._append_to_log(self.duplicate_log_file, duplicate_info)
                    
                    # Generate merge SQL for best match
                    best_match = duplicates[0]
                    merge_sql = self.generate_merge_sql(exercise, str(best_match[0]), best_match[1])
                    
                    # Append to merge script
                    with open(self.merge_script_file, 'a') as f:
                        f.write(merge_sql)
                    
                    return False

            # No duplicates, insert as new exercise
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO base_exercise (
                        name,
                        description,
                        level,
                        mechanic,
                        force,
                        category,
                        equipment,
                        primary_muscles,
                        secondary_muscles,
                        instructions,
                        image_urls,
                        source_id,
                        source_name,
                        aliases
                    ) VALUES (
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    )
                    RETURNING base_exercise_id
                    """,
                    (
                        exercise.name,
                        f"Imported from free-exercise-db",
                        exercise.level,
                        exercise.mechanic,
                        exercise.force,
                        exercise.category,
                        exercise.equipment,
                        exercise.primary_muscles,
                        exercise.secondary_muscles,
                        exercise.instructions,
                        exercise.to_image_urls(),
                        exercise.id,
                        'free-exercise-db',
                        [exercise.id]  # Store source ID as alias
                    )
                )
                
                new_id = cur.fetchone()[0]
                logger.info(f"Imported '{exercise.name}' as {new_id}")
                self.stats['imported'] += 1
                
                # Log import
                self._append_to_log(self.import_log_file, {
                    'exercise': exercise.name,
                    'source_id': exercise.id,
                    'new_id': str(new_id),
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
            logger.warning("Fuzzy matching will not be available")

    def run(self, dry_run: bool = False, skip_duplicate_check: bool = False):
        """Run the import process"""
        logger.info("=" * 80)
        logger.info("Starting Free Exercise DB Import")
        logger.info("=" * 80)
        
        # Load exercises
        exercises = self.load_exercises()
        
        # Connect to database
        conn = self.connect()
        
        try:
            # Enable fuzzy matching extension
            self.enable_trigram_extension(conn)
            
            # Initialize merge script file with header
            with open(self.merge_script_file, 'w') as f:
                f.write(f"""-- Merge Script for Duplicate Exercises
-- Generated: {datetime.now().isoformat()}
-- 
-- INSTRUCTIONS:
-- 1. Review each merge suggestion below
-- 2. Choose to either:
--    a) Run the UPDATE to merge data into existing exercise
--    b) Comment out the UPDATE to skip the merge
-- 3. Save your changes
-- 4. Run this script against your database
--
-- WARNING: This script modifies existing data. Review carefully!

BEGIN;

""")
            
            # Process each exercise
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
                    # Dry run - just check for duplicates
                    duplicates = self.find_potential_duplicates(conn, exercise)
                    if duplicates:
                        self.stats['potential_duplicates'] += 1
                        logger.info(f"[DRY RUN] Would skip '{exercise.name}' (duplicate found)")
                    else:
                        self.stats['new_exercises'] += 1
                        logger.info(f"[DRY RUN] Would import '{exercise.name}'")
            
            # Finalize merge script
            with open(self.merge_script_file, 'a') as f:
                f.write("\n-- Review the changes above, then uncomment to commit:\n")
                f.write("-- COMMIT;\n")
                f.write("\n-- Or rollback if you want to cancel:\n")
                f.write("ROLLBACK;\n")
            
        finally:
            conn.close()
        
        # Print summary
        self._print_summary(dry_run)

    def _print_summary(self, dry_run: bool):
        """Print import summary"""
        logger.info("=" * 80)
        logger.info("Import Summary")
        logger.info("=" * 80)
        logger.info(f"Total exercises processed: {self.stats['total_exercises']}")
        logger.info(f"New exercises {'to be imported' if dry_run else 'imported'}: {self.stats['new_exercises']}")
        logger.info(f"Potential duplicates found: {self.stats['potential_duplicates']}")
        
        if not dry_run:
            logger.info(f"Successfully imported: {self.stats['imported']}")
            logger.info(f"Errors: {self.stats['errors']}")
        
        logger.info("")
        logger.info("Output files:")
        logger.info(f"  Merge script: {self.merge_script_file}")
        logger.info(f"  Duplicate log: {self.duplicate_log_file}")
        
        if not dry_run:
            logger.info(f"  Import log: {self.import_log_file}")
        
        logger.info("")
        logger.info("Next steps:")
        if self.stats['potential_duplicates'] > 0:
            logger.info(f"  1. Review merge script: {self.merge_script_file}")
            logger.info(f"  2. Edit to select which merges to apply")
            logger.info(f"  3. Run the script against your database")
        else:
            logger.info("  No duplicates found - all exercises imported successfully!")


def main():
    parser = argparse.ArgumentParser(description='Import exercises from free-exercise-db')
    parser.add_argument(
        '--db-url',
        default=os.getenv('DATABASE_URL'),
        help='Database URL (default: from DATABASE_URL env var)'
    )
    parser.add_argument(
        '--exercises-file',
        type=Path,
        default=Path(__file__).parent.parent.parent.parent / 'free-exercise-db' / 'dist' / 'exercises.json',
        help='Path to exercises.json file'
    )
    parser.add_argument(
        '--output-dir',
        type=Path,
        default=Path(__file__).parent.parent.parent.parent / 'database' / 'import_logs',
        help='Directory for output files'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Run without making changes to database'
    )
    parser.add_argument(
        '--skip-duplicate-check',
        action='store_true',
        help='Skip duplicate checking and import all exercises'
    )
    
    args = parser.parse_args()
    
    # Validate inputs
    if not args.db_url:
        parser.error("Database URL required (--db-url or DATABASE_URL env var)")
    
    if not args.exercises_file.exists():
        parser.error(f"Exercises file not found: {args.exercises_file}")
    
    # Run import
    importer = ExerciseImporter(
        db_url=args.db_url,
        exercises_file=args.exercises_file,
        output_dir=args.output_dir
    )
    
    importer.run(
        dry_run=args.dry_run,
        skip_duplicate_check=args.skip_duplicate_check
    )


if __name__ == '__main__':
    main()
