#!/usr/bin/env python3
"""
Quick local verification of migrations using SQLite.
Catches SQL errors and duplicate key violations before CI.
"""

import sqlite3
import re
import sys
from pathlib import Path


def main():
    print("🔍 Verifying migrations locally with SQLite...")

    # Create in-memory SQLite database
    conn = sqlite3.connect(':memory:')
    cursor = conn.cursor()

    print("\n📝 Loading Phase 1 migrations (username generation)...")

    # Create tables
    cursor.execute('''
        CREATE TABLE username_adjectives (
            word TEXT PRIMARY KEY,
            category TEXT
        )
    ''')

    cursor.execute('''
        CREATE TABLE username_nouns (
            word TEXT PRIMARY KEY,
            category TEXT
        )
    ''')

    # Read migration file
    migration_file = Path('database/026_Auth_Username_Generator.sql')
    content = migration_file.read_text()

    # Extract INSERT statements
    adj_match = re.search(
        r'INSERT INTO username_adjectives.*?VALUES(.*?);',
        content,
        re.DOTALL
    )

    noun_match = re.search(
        r'INSERT INTO username_nouns.*?VALUES(.*?);',
        content,
        re.DOTALL
    )

    if not adj_match or not noun_match:
        print("❌ Could not find INSERT statements")
        return 1

    # Load adjectives
    print("  → Loading adjectives...")
    try:
        cursor.execute(f"INSERT INTO username_adjectives VALUES{adj_match.group(1)}")
        conn.commit()
    except sqlite3.IntegrityError as e:
        print(f"  ❌ Error loading adjectives: {e}")
        return 1

    # Load nouns
    print("  → Loading nouns...")
    try:
        cursor.execute(f"INSERT INTO username_nouns VALUES{noun_match.group(1)}")
        conn.commit()
    except sqlite3.IntegrityError as e:
        print(f"  ❌ Error loading nouns: {e}")
        return 1

    # Verify counts
    print("\n📊 Verification Results:")

    adj_count = cursor.execute("SELECT COUNT(*) FROM username_adjectives").fetchone()[0]
    noun_count = cursor.execute("SELECT COUNT(*) FROM username_nouns").fetchone()[0]

    print(f"  ✓ Adjectives loaded: {adj_count}")
    print(f"  ✓ Nouns loaded: {noun_count}")

    total = adj_count * noun_count
    print(f"  ✓ Total combinations: {adj_count} × {noun_count} = {total:,}")

    # Check for duplicates (should be impossible but verify)
    print("\n🔎 Checking for duplicates...")

    dup_adj = cursor.execute('''
        SELECT word, COUNT(*) as cnt
        FROM username_adjectives
        GROUP BY word
        HAVING cnt > 1
    ''').fetchall()

    dup_noun = cursor.execute('''
        SELECT word, COUNT(*) as cnt
        FROM username_nouns
        GROUP BY word
        HAVING cnt > 1
    ''').fetchall()

    if dup_adj:
        print("  ❌ Duplicate adjectives found:")
        for word, count in dup_adj:
            print(f"    - {word}: {count} occurrences")
        return 1

    if dup_noun:
        print("  ❌ Duplicate nouns found:")
        for word, count in dup_noun:
            print(f"    - {word}: {count} occurrences")
        return 1

    print("  ✓ No duplicates found")

    # Sample some words
    print("\n📝 Sample generated usernames:")
    sample_adj = cursor.execute("SELECT word FROM username_adjectives ORDER BY RANDOM() LIMIT 3").fetchall()
    sample_noun = cursor.execute("SELECT word FROM username_nouns WHERE category = 'gymrat' LIMIT 3").fetchall()

    for adj, in sample_adj:
        for noun, in sample_noun:
            print(f"  • {adj}{noun}")

    print("\n✅ All migrations verified successfully!")
    print("   Ready for CI deployment")

    conn.close()
    return 0


if __name__ == '__main__':
    sys.exit(main())
