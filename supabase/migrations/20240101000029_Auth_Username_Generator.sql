-- Supabase Auth Integration: Username Generation System
--
-- This migration creates the table-based username generation system.
-- Implements Reddit-style readable usernames with GymR8 branding.
--
-- Components:
--   1. username_adjectives table with 140 words
--   2. username_nouns table with 182 words
--   3. generate_unique_username() function
--
-- Namespace: 140 × 182 = 25,480 base combinations (~254 million with numbers)
-- Examples: SwoleRat, IronLifter, BuffBarbell, RippedGymRat
--
-- Created: 2025-11-16
-- Author: Generated from SUPABASE_AUTH_INTEGRATION_PLAN.md

-- =============================================================================
-- CREATE WORD TABLES
-- =============================================================================

CREATE TABLE username_adjectives (
  word text PRIMARY KEY,
  category text,
  created_at timestamptz DEFAULT now()
);

CREATE TABLE username_nouns (
  word text PRIMARY KEY,
  category text,
  created_at timestamptz DEFAULT now()
);

COMMENT ON TABLE username_adjectives IS
  'Adjectives for generating Reddit-style usernames. Organized by category for easy management and future theming features.';

COMMENT ON TABLE username_nouns IS
  'Nouns for generating Reddit-style usernames. Includes GymR8 branding (Rat, Barbell, Lifter, etc.)';

-- =============================================================================
-- SEED ADJECTIVES (140 words)
-- =============================================================================

INSERT INTO username_adjectives (word, category) VALUES
  -- Positive traits (12 words)
  ('Happy', 'emotion'), ('Jolly', 'emotion'), ('Cheerful', 'emotion'), ('Bright', 'quality'),
  ('Sunny', 'nature'), ('Friendly', 'personality'), ('Kind', 'personality'), ('Gentle', 'personality'),
  ('Calm', 'personality'), ('Peaceful', 'quality'), ('Serene', 'quality'), ('Tranquil', 'quality'),

  -- Speed & movement (8 words)
  ('Quick', 'movement'), ('Swift', 'movement'), ('Rapid', 'movement'), ('Fast', 'movement'),
  ('Agile', 'quality'), ('Nimble', 'quality'), ('Fleet', 'movement'), ('Speedy', 'movement'),

  -- Intelligence & wisdom (8 words)
  ('Wise', 'mental'), ('Clever', 'mental'), ('Smart', 'mental'), ('Brilliant', 'mental'),
  ('Sharp', 'mental'), ('Keen', 'mental'), ('Astute', 'mental'), ('Savvy', 'mental'),

  -- Strength & power (8 words)
  ('Strong', 'physical'), ('Mighty', 'physical'), ('Powerful', 'physical'), ('Robust', 'physical'),
  ('Sturdy', 'physical'), ('Solid', 'physical'), ('Tough', 'physical'), ('Hardy', 'physical'),

  -- Bravery & courage (8 words)
  ('Brave', 'personality'), ('Bold', 'personality'), ('Daring', 'personality'), ('Fearless', 'personality'),
  ('Valiant', 'personality'), ('Heroic', 'personality'), ('Gallant', 'personality'), ('Noble', 'personality'),

  -- Freedom & independence (8 words)
  ('Free', 'concept'), ('Wild', 'concept'), ('Rogue', 'concept'), ('Rebel', 'concept'),
  ('Maverick', 'concept'), ('Wandering', 'concept'), ('Roaming', 'concept'), ('Drifting', 'concept'),

  -- Purity & truth (8 words)
  ('Pure', 'quality'), ('True', 'quality'), ('Honest', 'quality'), ('Clear', 'quality'),
  ('Genuine', 'quality'), ('Real', 'quality'), ('Authentic', 'quality'), ('Sincere', 'quality'),

  -- Royalty & grandeur (8 words)
  ('Royal', 'status'), ('Grand', 'status'), ('Majestic', 'status'), ('Regal', 'status'),
  ('Imperial', 'status'), ('Sovereign', 'status'), ('Glorious', 'status'), ('Exalted', 'status'),

  -- Magic & fantasy (8 words)
  ('Magic', 'fantasy'), ('Mystic', 'fantasy'), ('Arcane', 'fantasy'), ('Ethereal', 'fantasy'),
  ('Enchanted', 'fantasy'), ('Fabled', 'fantasy'), ('Mythic', 'fantasy'), ('Legendary', 'fantasy'),

  -- Metals & gems (12 words)
  ('Golden', 'material'), ('Silver', 'material'), ('Crystal', 'material'), ('Amber', 'material'),
  ('Ruby', 'material'), ('Jade', 'material'), ('Emerald', 'material'), ('Sapphire', 'material'),
  ('Diamond', 'material'), ('Bronze', 'material'), ('Platinum', 'material'), ('Pearl', 'material'),

  -- Space & cosmic (8 words)
  ('Cosmic', 'space'), ('Stellar', 'space'), ('Lunar', 'space'), ('Solar', 'space'),
  ('Astral', 'space'), ('Galactic', 'space'), ('Nebular', 'space'), ('Celestial', 'space'),

  -- Time & era (8 words)
  ('Ancient', 'time'), ('Modern', 'time'), ('Future', 'time'), ('Eternal', 'time'),
  ('Timeless', 'time'), ('Primal', 'time'), ('Classic', 'time'), ('Vintage', 'time'),

  -- Greek alphabet & special (12 words)
  ('Sigma', 'greek'), ('Beta', 'greek'), ('Gamma', 'greek'), ('Delta', 'greek'),
  ('Omega', 'greek'), ('Prime', 'concept'), ('Mega', 'concept'), ('Ultra', 'concept'),
  ('Super', 'concept'), ('Hyper', 'concept'), ('Neo', 'concept'), ('Quantum', 'concept'),

  -- Technology (8 words)
  ('Cyber', 'tech'), ('Digital', 'tech'), ('Pixel', 'tech'), ('Binary', 'tech'),
  ('Vector', 'tech'), ('Matrix', 'tech'), ('Circuit', 'tech'), ('Silicon', 'tech'),

  -- Style & cool (8 words)
  ('Cool', 'style'), ('Epic', 'style'), ('Awesome', 'style'), ('Rad', 'style'),
  ('Fresh', 'style'), ('Slick', 'style'), ('Elite', 'style'), ('Smooth', 'style'),

  -- Nature qualities (8 words)
  ('Verdant', 'nature'), ('Lush', 'nature'), ('Vibrant', 'nature'), ('Radiant', 'nature'),
  ('Glowing', 'nature'), ('Shining', 'nature'), ('Gleaming', 'nature'), ('Sparkling', 'nature'),

  -- Gym & Fitness themed - GymR8 branding (20 words)
  ('Swole', 'fitness'), ('Buff', 'fitness'), ('Ripped', 'fitness'), ('Shredded', 'fitness'),
  ('Jacked', 'fitness'), ('Pumped', 'fitness'), ('Built', 'fitness'), ('Toned', 'fitness'),
  ('Lean', 'fitness'), ('Massive', 'fitness'), ('Beastly', 'fitness'), ('Hardcore', 'fitness'),
  ('Iron', 'gym'), ('Steel', 'gym'), ('Titanium', 'gym'), ('Granite', 'gym'),
  ('Grind', 'gym'), ('Hustle', 'gym'), ('Alpha', 'fitness'), ('Peak', 'fitness');

-- =============================================================================
-- SEED NOUNS (182 words)
-- =============================================================================

INSERT INTO username_nouns (word, category) VALUES
  -- Large mammals (20 words)
  ('Panda', 'mammal'), ('Tiger', 'mammal'), ('Lion', 'mammal'), ('Bear', 'mammal'),
  ('Wolf', 'mammal'), ('Fox', 'mammal'), ('Deer', 'mammal'), ('Otter', 'mammal'),
  ('Leopard', 'mammal'), ('Jaguar', 'mammal'), ('Panther', 'mammal'), ('Cheetah', 'mammal'),
  ('Lynx', 'mammal'), ('Cougar', 'mammal'), ('Bison', 'mammal'), ('Buffalo', 'mammal'),
  ('Moose', 'mammal'), ('Elk', 'mammal'), ('Rhino', 'mammal'), ('Hippo', 'mammal'),

  -- Birds (16 words)
  ('Eagle', 'bird'), ('Falcon', 'bird'), ('Hawk', 'bird'), ('Owl', 'bird'),
  ('Raven', 'bird'), ('Sparrow', 'bird'), ('Phoenix', 'bird'), ('Condor', 'bird'),
  ('Crane', 'bird'), ('Heron', 'bird'), ('Swan', 'bird'), ('Dove', 'bird'),
  ('Finch', 'bird'), ('Robin', 'bird'), ('Cardinal', 'bird'), ('Bluejay', 'bird'),

  -- Sea creatures (12 words)
  ('Dolphin', 'sea'), ('Shark', 'sea'), ('Whale', 'sea'), ('Seal', 'sea'),
  ('Penguin', 'sea'), ('Turtle', 'sea'), ('Orca', 'sea'), ('Manta', 'sea'),
  ('Nautilus', 'sea'), ('Kraken', 'sea'), ('Barracuda', 'sea'), ('Marlin', 'sea'),

  -- Mythical creatures (8 words)
  ('Dragon', 'mythical'), ('Griffin', 'mythical'), ('Unicorn', 'mythical'), ('Pegasus', 'mythical'),
  ('Chimera', 'mythical'), ('Hydra', 'mythical'), ('Basilisk', 'mythical'), ('Sphinx', 'mythical'),

  -- Geography & landscapes (16 words)
  ('River', 'geography'), ('Mountain', 'geography'), ('Ocean', 'geography'), ('Forest', 'geography'),
  ('Desert', 'geography'), ('Valley', 'geography'), ('Canyon', 'geography'), ('Meadow', 'geography'),
  ('Peak', 'geography'), ('Ridge', 'geography'), ('Summit', 'geography'), ('Glacier', 'geography'),
  ('Volcano', 'geography'), ('Island', 'geography'), ('Peninsula', 'geography'), ('Plateau', 'geography'),

  -- Weather & sky (12 words)
  ('Storm', 'weather'), ('Thunder', 'weather'), ('Lightning', 'weather'), ('Rain', 'weather'),
  ('Snow', 'weather'), ('Wind', 'weather'), ('Cloud', 'weather'), ('Mist', 'weather'),
  ('Frost', 'weather'), ('Blizzard', 'weather'), ('Tempest', 'weather'), ('Gale', 'weather'),

  -- Celestial (12 words)
  ('Star', 'celestial'), ('Moon', 'celestial'), ('Sun', 'celestial'), ('Comet', 'celestial'),
  ('Galaxy', 'celestial'), ('Nebula', 'celestial'), ('Cosmos', 'celestial'), ('Planet', 'celestial'),
  ('Meteor', 'celestial'), ('Aurora', 'celestial'), ('Pulsar', 'celestial'), ('Quasar', 'celestial'),

  -- Fantasy roles (20 words)
  ('Knight', 'fantasy'), ('Wizard', 'fantasy'), ('Ninja', 'fantasy'), ('Samurai', 'fantasy'),
  ('Ranger', 'fantasy'), ('Hunter', 'fantasy'), ('Warrior', 'fantasy'), ('Guardian', 'fantasy'),
  ('Sage', 'fantasy'), ('Oracle', 'fantasy'), ('Prophet', 'fantasy'), ('Scholar', 'fantasy'),
  ('Paladin', 'fantasy'), ('Druid', 'fantasy'), ('Monk', 'fantasy'), ('Rogue', 'fantasy'),
  ('Archer', 'fantasy'), ('Mage', 'fantasy'), ('Cleric', 'fantasy'), ('Shaman', 'fantasy'),

  -- Arts & creativity (8 words)
  ('Artist', 'arts'), ('Poet', 'arts'), ('Bard', 'arts'), ('Scribe', 'arts'),
  ('Painter', 'arts'), ('Dancer', 'arts'), ('Singer', 'arts'), ('Player', 'arts'),

  -- Trees & plants (12 words)
  ('Oak', 'plant'), ('Pine', 'plant'), ('Willow', 'plant'), ('Maple', 'plant'),
  ('Cedar', 'plant'), ('Birch', 'plant'), ('Aspen', 'plant'), ('Redwood', 'plant'),
  ('Bamboo', 'plant'), ('Lotus', 'plant'), ('Rose', 'plant'), ('Iris', 'plant'),

  -- Gemstones & minerals (8 words)
  ('Opal', 'mineral'), ('Topaz', 'mineral'), ('Onyx', 'mineral'), ('Quartz', 'mineral'),
  ('Obsidian', 'mineral'), ('Flint', 'mineral'), ('Marble', 'mineral'), ('Granite', 'mineral'),

  -- Concepts & abstract (12 words)
  ('Spirit', 'concept'), ('Shadow', 'concept'), ('Light', 'concept'), ('Echo', 'concept'),
  ('Dream', 'concept'), ('Vision', 'concept'), ('Phantom', 'concept'), ('Spectre', 'concept'),
  ('Ember', 'concept'), ('Flame', 'concept'), ('Blaze', 'concept'), ('Spark', 'concept'),

  -- Gym & Fitness themed - GymR8 branding (32 words total)
  -- THE STAR! 🐀
  ('Rat', 'gymrat'), ('GymRat', 'gymrat'), ('IronRat', 'gymrat'), ('SwoleRat', 'gymrat'),

  -- Gym equipment (8 words)
  ('Barbell', 'equipment'), ('Dumbbell', 'equipment'), ('Kettlebell', 'equipment'), ('Plate', 'equipment'),
  ('Rack', 'equipment'), ('Cable', 'equipment'), ('Machine', 'equipment'), ('Bench', 'equipment'),

  -- Gym roles & personas (12 words)
  ('Lifter', 'athlete'), ('Powerlifter', 'athlete'), ('Bodybuilder', 'athlete'), ('Athlete', 'athlete'),
  ('Crusher', 'athlete'), ('Grinder', 'athlete'), ('Beast', 'athlete'), ('Tank', 'athlete'),
  ('Bull', 'athlete'), ('Titan', 'athlete'), ('Giant', 'athlete'), ('Champion', 'athlete'),

  -- Gym concepts (8 words)
  ('Gains', 'concept'), ('Pump', 'concept'), ('Rep', 'concept'), ('Set', 'concept'),
  ('PR', 'concept'), ('Max', 'concept'), ('Iron', 'concept'), ('Steel', 'concept');

-- =============================================================================
-- CREATE INDEXES FOR PERFORMANCE
-- =============================================================================

-- Note: random() in index is not useful for actual indexing, but we include
-- these for potential future query optimization on the base columns
CREATE INDEX idx_username_adjectives_category ON username_adjectives(category);
CREATE INDEX idx_username_nouns_category ON username_nouns(category);

-- =============================================================================
-- USERNAME GENERATION FUNCTION
-- =============================================================================

CREATE OR REPLACE FUNCTION generate_unique_username()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  selected_adjective text;
  selected_noun text;
  new_username text;
  username_exists boolean;
  attempt_count integer := 0;
  max_attempts integer := 5;
BEGIN
  LOOP
    -- Select random adjective and noun from tables
    SELECT word INTO selected_adjective
    FROM username_adjectives
    ORDER BY random()
    LIMIT 1;

    SELECT word INTO selected_noun
    FROM username_nouns
    ORDER BY random()
    LIMIT 1;

    -- Generate AdjectiveNoun combination (e.g., SwoleRat, IronLifter)
    new_username := selected_adjective || selected_noun;

    -- Add random 2-4 digit number if we've had collisions
    IF attempt_count > 0 THEN
      new_username := new_username || (10 + floor(random() * 9990))::text;
    END IF;

    -- Check if username already exists in app_user
    SELECT EXISTS(SELECT 1 FROM app_user WHERE username = new_username)
    INTO username_exists;

    -- Exit loop if username is unique
    EXIT WHEN NOT username_exists;

    attempt_count := attempt_count + 1;

    -- Safety check: prevent infinite loop
    -- After 5 attempts, guarantee uniqueness with timestamp
    IF attempt_count >= max_attempts THEN
      new_username := new_username || extract(epoch from now())::bigint::text;
      EXIT;
    END IF;
  END LOOP;

  RETURN new_username;
END;
$$;

COMMENT ON FUNCTION generate_unique_username() IS
  'Generates a unique Reddit-style username using the AdjectiveNoun pattern. '
  'Examples: SwoleRat, IronLifter, BuffBarbell, MightyBeast. '
  'Includes GymR8 branding with gym/fitness themed words. '
  'Handles collisions by appending random numbers (e.g., SwoleRat42). '
  'Namespace: 140 adjectives × 182 nouns = 25,480 base combinations.';
