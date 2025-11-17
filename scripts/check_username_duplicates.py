#!/usr/bin/env python3
"""
Check for duplicate words in username generation migration.

Usage:
    python scripts/check_username_duplicates.py [migration_file]

Exit codes:
    0 - No duplicates found
    1 - Duplicates found
"""

import re
import sys


def check_duplicates(file_path='database/026_Auth_Username_Generator.sql'):
    """Check for duplicate words in the username generation migration."""

    # Read the file
    with open(file_path, 'r') as f:
        content = f.read()

    all_good = True

    # Extract adjectives section
    adj_match = re.search(
        r'INSERT INTO username_adjectives.*?VALUES(.*?);',
        content,
        re.DOTALL
    )

    if adj_match:
        adj_words = re.findall(r"\('([^']+)',", adj_match.group(1))
        adj_duplicates = [
            word for word in set(adj_words) if adj_words.count(word) > 1
        ]

        if adj_duplicates:
            print("❌ DUPLICATE ADJECTIVES FOUND:")
            for dup in sorted(adj_duplicates):
                indices = [i for i, word in enumerate(adj_words) if word == dup]
                print(f"  - {dup}: positions {indices}")
            all_good = False
        else:
            print(f"✓ No duplicate adjectives ({len(adj_words)} total)")

    # Extract nouns section
    noun_match = re.search(
        r'INSERT INTO username_nouns.*?VALUES(.*?);',
        content,
        re.DOTALL
    )

    if noun_match:
        noun_words = re.findall(r"\('([^']+)',", noun_match.group(1))
        noun_duplicates = [
            word for word in set(noun_words) if noun_words.count(word) > 1
        ]

        if noun_duplicates:
            print("❌ DUPLICATE NOUNS FOUND:")
            for dup in sorted(noun_duplicates):
                indices = [i for i, word in enumerate(noun_words) if word == dup]
                print(f"  - {dup}: positions {indices}")
            all_good = False
        else:
            print(f"✓ No duplicate nouns ({len(noun_words)} total)")

    if all_good:
        print("\n✅ All checks passed - no duplicates found!")
        print(f"   Adjectives: {len(adj_words)} unique words")
        print(f"   Nouns: {len(noun_words)} unique words")
        total = len(adj_words) * len(noun_words)
        print(f"   Total combinations: {len(adj_words)} × {len(noun_words)} = {total:,}")
        return 0
    else:
        print("\n❌ Duplicates found - please fix before committing!")
        return 1


if __name__ == '__main__':
    file_path = sys.argv[1] if len(sys.argv) > 1 else 'database/026_Auth_Username_Generator.sql'
    sys.exit(check_duplicates(file_path))
