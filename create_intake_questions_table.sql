-- ============================================================================
-- TCM CLINICAL ASSISTANT - THERAPIST INTAKE QUESTIONS TABLE
-- Purpose: Store 450 intake questions therapists ask patients during assessment
-- File: create_intake_questions_table.sql
-- Date: January 24, 2026
-- ============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: tcm_intake_questions
-- Purpose: Therapist intake questionnaire (450 questions across 30 categories)
-- ============================================================================

CREATE TABLE IF NOT EXISTS tcm_intake_questions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  row_number INTEGER,
  category_hebrew TEXT NOT NULL,
  category_english TEXT NOT NULL,
  question_id TEXT NOT NULL,
  question_hebrew TEXT NOT NULL,
  question_english TEXT NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  display_order INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(question_id, category_hebrew)
);

-- ============================================================================
-- INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_intake_category_heb ON tcm_intake_questions(category_hebrew);
CREATE INDEX IF NOT EXISTS idx_intake_category_eng ON tcm_intake_questions(category_english);
CREATE INDEX IF NOT EXISTS idx_intake_question_id ON tcm_intake_questions(question_id);
CREATE INDEX IF NOT EXISTS idx_intake_active ON tcm_intake_questions(is_active);
CREATE INDEX IF NOT EXISTS idx_intake_display_order ON tcm_intake_questions(display_order);

-- ============================================================================
-- FULL-TEXT SEARCH SUPPORT
-- ============================================================================

-- Add search vector column
ALTER TABLE tcm_intake_questions 
  ADD COLUMN IF NOT EXISTS search_vector tsvector
  GENERATED ALWAYS AS (
    to_tsvector('simple', 
      coalesce(question_hebrew, '') || ' ' || 
      coalesce(question_english, '') || ' ' ||
      coalesce(category_hebrew, '')
    )
  ) STORED;

-- Create GIN index for fast full-text search
CREATE INDEX IF NOT EXISTS idx_intake_search 
  ON tcm_intake_questions USING GIN(search_vector);

-- ============================================================================
-- HELPER FUNCTION: Get questions by category
-- ============================================================================

CREATE OR REPLACE FUNCTION get_intake_questions_by_category(cat TEXT)
RETURNS TABLE (
  question_id TEXT,
  question_hebrew TEXT,
  question_english TEXT,
  display_order INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    tiq.question_id,
    tiq.question_hebrew,
    tiq.question_english,
    tiq.row_number as display_order
  FROM tcm_intake_questions tiq
  WHERE tiq.is_active = TRUE
    AND (
      tiq.category_hebrew ILIKE '%' || cat || '%' OR
      tiq.category_english ILIKE '%' || cat || '%'
    )
  ORDER BY tiq.row_number ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- HELPER FUNCTION: Search questions
-- ============================================================================

CREATE OR REPLACE FUNCTION search_intake_questions(search_term TEXT)
RETURNS TABLE (
  question_id TEXT,
  category_hebrew TEXT,
  question_hebrew TEXT,
  question_english TEXT,
  relevance REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    tiq.question_id,
    tiq.category_hebrew,
    tiq.question_hebrew,
    tiq.question_english,
    ts_rank(tiq.search_vector, websearch_to_tsquery('simple', search_term)) as relevance
  FROM tcm_intake_questions tiq
  WHERE tiq.is_active = TRUE
    AND tiq.search_vector @@ websearch_to_tsquery('simple', search_term)
  ORDER BY relevance DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- VIEW: Categories with question counts
-- ============================================================================

CREATE OR REPLACE VIEW intake_categories_summary AS
SELECT 
  category_hebrew,
  category_english,
  COUNT(*) as question_count,
  MIN(row_number) as first_question_number,
  MAX(row_number) as last_question_number
FROM tcm_intake_questions
WHERE is_active = TRUE
GROUP BY category_hebrew, category_english
ORDER BY category_hebrew;

-- ============================================================================
-- COMMENTS
-- ============================================================================

COMMENT ON TABLE tcm_intake_questions IS 'Therapist intake questions - 450 questions across 30 categories for patient assessment';
COMMENT ON COLUMN tcm_intake_questions.question_id IS 'Unique identifier for each question within its category';
COMMENT ON COLUMN tcm_intake_questions.category_hebrew IS 'Question category in Hebrew';
COMMENT ON COLUMN tcm_intake_questions.category_english IS 'Question category in English';
COMMENT ON FUNCTION get_intake_questions_by_category IS 'Retrieve all active questions for a specific category';
COMMENT ON FUNCTION search_intake_questions IS 'Full-text search across all intake questions';

-- ============================================================================
-- SUCCESS MESSAGE
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '✅ ========================================';
  RAISE NOTICE '✅ INTAKE QUESTIONS TABLE CREATED!';
  RAISE NOTICE '✅ ========================================';
  RAISE NOTICE '';
  RAISE NOTICE '📋 Table: tcm_intake_questions';
  RAISE NOTICE '🔍 Search function: search_intake_questions(term)';
  RAISE NOTICE '📊 Category view: intake_categories_summary';
  RAISE NOTICE '';
  RAISE NOTICE 'Next step: Upload the 450 questions using Python script';
  RAISE NOTICE '';
END $$;
