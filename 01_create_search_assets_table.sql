-- ============================================================================
-- TCM CLINICAL ASSISTANT - SEARCH ASSETS PRIORITY TABLE
-- File: 01_create_search_assets_table.sql
-- Purpose: Central registry of all searchable assets with priority levels
-- Author: Claude AI for TCM Clinic
-- Date: January 2026
-- ============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: search_assets (RAG Priority Management)
-- ============================================================================

CREATE TABLE IF NOT EXISTS search_assets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  asset_name TEXT NOT NULL UNIQUE,
  asset_name_hebrew TEXT NOT NULL,
  asset_type TEXT NOT NULL, -- 'module', 'database', 'tool', 'gallery'
  priority_level INTEGER NOT NULL, -- 1 = highest, 10 = lowest
  is_active BOOLEAN DEFAULT TRUE,
  search_endpoint TEXT, -- URL or function name to query this asset
  requires_tokens BOOLEAN DEFAULT FALSE, -- Does it cost tokens?
  average_response_time_ms INTEGER, -- Performance metric
  description_hebrew TEXT,
  icon_emoji TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Add indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_assets_priority ON search_assets(priority_level, is_active);
CREATE INDEX IF NOT EXISTS idx_assets_active ON search_assets(is_active);
CREATE INDEX IF NOT EXISTS idx_assets_type ON search_assets(asset_type);

-- ============================================================================
-- POPULATE WITH CURRENT ASSETS
-- ============================================================================

INSERT INTO search_assets (
  asset_name, 
  asset_name_hebrew, 
  asset_type, 
  priority_level, 
  requires_tokens,
  search_endpoint,
  average_response_time_ms,
  description_hebrew,
  icon_emoji
) VALUES

-- PRIORITY 1: Main Q&A Knowledge Base (2,325 ROWS)
(
  'qa_knowledge_base',
  'מאגר שאלות ותשובות',
  'database',
  1,
  FALSE,
  'qa_knowledge_base',
  50,
  'מאגר ראשי של 2,325 שאלות ותשובות בעברית עם נקודות דיקור ופרמקופיאה',
  '📚'
),

-- PRIORITY 2: Yin-Yang Assessment Module
(
  'yinyang_assessment',
  'הערכת יין יאנג',
  'module',
  2,
  FALSE,
  'yinyang_module',
  100,
  'שאלון אבחון יין-יאנג מקיף עם 5 מערכות איברים',
  '☯️'
),

-- PRIORITY 3: Pulse & Tongue Gallery
(
  'pulse_tongue_gallery',
  'גלרית דופק לשון',
  'gallery',
  3,
  FALSE,
  'pulse_tongue_images',
  75,
  'תמונות ותיאורים של דופק ולשון לאבחון',
  '👅'
),

-- PRIORITY 4: Deep Research (Gemini API)
(
  'deep_thinking',
  'חשיבה עמוקה',
  'tool',
  4,
  TRUE, -- Uses tokens!
  'gemini_api',
  500,
  'מחקר מעמיק עם Gemini Flash 3 - עלות טוקנים',
  '🧠'
),

-- PRIORITY 5: Body Figures Module (NEW)
(
  'body_figures',
  'תמונות גוף ונקודות דיקור',
  'module',
  5,
  FALSE,
  'body_figures',
  80,
  'תמונות של גוף אדם עם מיפוי נקודות דיקור',
  '🫀'
),

-- PRIORITY 6: TCM Hebrew Q&A (1,499 Quick Questions)
(
  'tcm_hebrew_qa',
  'מאגר שאלות מוכן',
  'database',
  6,
  FALSE,
  'tcm_hebrew_qa',
  40,
  '1,499 שאלות מהירות מחולקות ל-23 קטגוריות',
  '🎯'
),

-- PRIORITY 7: Acupuncture Points Database
(
  'acupuncture_points',
  'מאגר נקודות דיקור',
  'database',
  7,
  FALSE,
  'acupuncture_points',
  60,
  'מאגר מלא של נקודות דיקור עם תיאורים',
  '📍'
)

ON CONFLICT (asset_name) DO UPDATE SET
  asset_name_hebrew = EXCLUDED.asset_name_hebrew,
  priority_level = EXCLUDED.priority_level,
  updated_at = NOW();

-- ============================================================================
-- TABLE: search_routing_rules (Query Pattern Matching)
-- ============================================================================

CREATE TABLE IF NOT EXISTS search_routing_rules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  rule_name TEXT NOT NULL UNIQUE,
  query_pattern TEXT NOT NULL, -- Regex or keywords
  priority_override INTEGER[], -- Override default priority
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_routing_active ON search_routing_rules(is_active);

-- Populate routing rules
INSERT INTO search_routing_rules (rule_name, query_pattern, priority_override, description) VALUES
  ('yin_yang_pattern', 'יין.*יאנג|יאנג.*יין|yin.*yang', ARRAY[2, 1, 5, 3], 'Prioritize Yin-Yang assessment for related queries'),
  ('pulse_tongue_pattern', 'דופק|לשון|pulse|tongue', ARRAY[3, 1, 5, 2], 'Prioritize pulse/tongue gallery'),
  ('acupoint_pattern', 'נקודת.*דיקור|אקופונקטורה|ST|SP|LV|GB|LI|BL|HT|PC|CV|DU', ARRAY[5, 7, 1], 'Prioritize body figures and acupoints'),
  ('body_region_pattern', 'ראש|גב|רגל|יד|בטן|חזה|צוואר', ARRAY[5, 1, 7], 'Prioritize body figures for body regions'),
  ('symptom_pattern', 'כאב|חרדה|עייפות|שינה|נדודי|דיכאון|לחץ', ARRAY[1, 5, 2, 6], 'Standard symptom search priority')
  
ON CONFLICT (rule_name) DO UPDATE SET
  query_pattern = EXCLUDED.query_pattern,
  priority_override = EXCLUDED.priority_override,
  description = EXCLUDED.description;

-- ============================================================================
-- Success message
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Search Assets table created successfully!';
  RAISE NOTICE '📊 Total assets: %', (SELECT COUNT(*) FROM search_assets);
  RAISE NOTICE '📋 Total routing rules: %', (SELECT COUNT(*) FROM search_routing_rules);
END $$;
