-- ============================================================================
-- TCM DIAGNOSTIC SYSTEM - DATABASE SCHEMA
-- ============================================================================
-- Created for: TCM Clinical Assistant
-- Purpose: Enable AI-powered syndrome diagnosis from patient symptoms
-- ============================================================================

-- TABLE 1: DIAGNOSTIC QUESTIONS
-- Pre-made questions therapists ask patients to identify symptoms
-- ============================================================================

CREATE TABLE IF NOT EXISTS diagnostic_questions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    symptom_code text NOT NULL,           -- e.g., "palpitations", "insomnia"
    question_he text NOT NULL,            -- Hebrew question
    question_en text NOT NULL,            -- English question
    category text NOT NULL,               -- e.g., "cardiac", "sleep", "digestion"
    created_at timestamptz DEFAULT NOW(),
    updated_at timestamptz DEFAULT NOW()
);

-- Indexes for fast searching
CREATE INDEX IF NOT EXISTS idx_diag_questions_symptom ON diagnostic_questions(symptom_code);
CREATE INDEX IF NOT EXISTS idx_diag_questions_category ON diagnostic_questions(category);

-- ============================================================================
-- TABLE 2: SYMPTOM-SYNDROME MAPPING
-- Links symptoms to syndromes with confidence scores (1-5)
-- Used by AI to calculate which syndrome best matches patient symptoms
-- ============================================================================

CREATE TABLE IF NOT EXISTS symptom_syndrome_mapping (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    symptom_code text NOT NULL,           -- Links to diagnostic_questions.symptom_code
    syndrome_code text NOT NULL,          -- e.g., "HT YIN XU", "LIV BL XU"
    confidence_level int NOT NULL,        -- 5=PRIMARY, 4=MAJOR, 3=COMMON, 2=MINOR, 1=RELATED
    description_he text,                  -- Why this symptom indicates this syndrome
    created_at timestamptz DEFAULT NOW(),
    
    CONSTRAINT confidence_check CHECK (confidence_level >= 1 AND confidence_level <= 5)
);

-- Indexes for fast syndrome matching
CREATE INDEX IF NOT EXISTS idx_symptom_syndrome_symptom ON symptom_syndrome_mapping(symptom_code);
CREATE INDEX IF NOT EXISTS idx_symptom_syndrome_syndrome ON symptom_syndrome_mapping(syndrome_code);
CREATE INDEX IF NOT EXISTS idx_symptom_syndrome_confidence ON symptom_syndrome_mapping(confidence_level DESC);

-- ============================================================================
-- TABLE 3: SYNDROME-TREATMENT POINTS
-- Links syndromes to recommended acupuncture points
-- Pulls point details from dr_roni_complete table
-- ============================================================================

CREATE TABLE IF NOT EXISTS syndrome_treatment_points (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    syndrome_code text NOT NULL,          -- e.g., "HT YIN XU"
    point_code text NOT NULL,             -- e.g., "HT6", "KID3"
    priority int NOT NULL,                -- 1=PRIMARY, 2=SECONDARY, 3=SUPPORTING
    technique_he text,                    -- e.g., "טונוס", "פיזור", "מוקסה"
    notes_he text,                        -- Clinical notes in Hebrew
    created_at timestamptz DEFAULT NOW(),
    
    CONSTRAINT priority_check CHECK (priority >= 1 AND priority <= 3)
);

-- Indexes for fast treatment point lookup
CREATE INDEX IF NOT EXISTS idx_treatment_points_syndrome ON syndrome_treatment_points(syndrome_code);
CREATE INDEX IF NOT EXISTS idx_treatment_points_point ON syndrome_treatment_points(point_code);
CREATE INDEX IF NOT EXISTS idx_treatment_points_priority ON syndrome_treatment_points(priority);

-- ============================================================================
-- UPDATE TRIGGERS
-- ============================================================================

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to diagnostic_questions
DROP TRIGGER IF EXISTS update_diagnostic_questions_updated_at ON diagnostic_questions;
CREATE TRIGGER update_diagnostic_questions_updated_at
    BEFORE UPDATE ON diagnostic_questions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- COMMENTS FOR DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE diagnostic_questions IS 'Pre-made diagnostic questions for symptom identification';
COMMENT ON TABLE symptom_syndrome_mapping IS 'Maps symptoms to syndromes with confidence scores for AI diagnosis';
COMMENT ON TABLE syndrome_treatment_points IS 'Recommended acupuncture points for each syndrome';

COMMENT ON COLUMN symptom_syndrome_mapping.confidence_level IS '5=PRIMARY symptom (highly diagnostic), 4=MAJOR, 3=COMMON, 2=MINOR, 1=RELATED';
COMMENT ON COLUMN syndrome_treatment_points.priority IS '1=PRIMARY point (essential), 2=SECONDARY (important), 3=SUPPORTING (helpful)';

-- ============================================================================
-- DIAGNOSTIC SYSTEM READY!
-- ============================================================================
-- Next steps:
-- 1. Run this schema file
-- 2. Run diagnostic_questions.sql (52 questions)
-- 3. Run symptom_syndrome_mapping.sql (96 mappings)
-- 4. Run syndrome_treatment_points.sql (66 point recommendations)
-- ============================================================================
