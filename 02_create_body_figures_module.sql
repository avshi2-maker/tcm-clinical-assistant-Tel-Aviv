-- ============================================================================
-- TCM CLINICAL ASSISTANT - BODY FIGURES MODULE
-- File: 02_create_body_figures_module.sql
-- Purpose: Standalone module for body diagrams with acupoint mapping
-- Author: Claude AI for TCM Clinic
-- Date: January 2026
-- ============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- TABLE: body_figures (Main body diagram catalog)
-- ============================================================================

CREATE TABLE IF NOT EXISTS body_figures (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  figure_name TEXT NOT NULL UNIQUE,
  figure_name_hebrew TEXT NOT NULL,
  body_region TEXT NOT NULL, -- 'head', 'torso', 'arms', 'legs', 'back', 'full_body'
  view_type TEXT NOT NULL, -- 'anterior', 'posterior', 'lateral', 'meridian'
  image_url TEXT, -- URL from Supabase Storage
  svg_data TEXT, -- Optional SVG for interactive points
  description_hebrew TEXT,
  tags TEXT[], -- For search: ['כאב_ראש', 'חרדה', 'עייפות']
  is_active BOOLEAN DEFAULT TRUE,
  display_order INTEGER,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_figures_region ON body_figures(body_region, is_active);
CREATE INDEX IF NOT EXISTS idx_figures_tags ON body_figures USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_figures_order ON body_figures(display_order);

-- ============================================================================
-- TABLE: acupoint_mappings (Acupoints on each figure)
-- ============================================================================

CREATE TABLE IF NOT EXISTS acupoint_mappings (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  figure_id UUID REFERENCES body_figures(id) ON DELETE CASCADE,
  acupoint_code TEXT NOT NULL, -- 'LI4', 'ST36', 'SP6'
  acupoint_name_hebrew TEXT,
  x_coordinate DECIMAL(5,2), -- Position on image (percentage 0-100)
  y_coordinate DECIMAL(5,2),
  description_hebrew TEXT,
  indications TEXT[], -- ['כאב_ראש', 'חרדה', 'עיכול']
  meridian TEXT, -- 'Liver', 'Spleen', 'Stomach'
  meridian_hebrew TEXT,
  function_category TEXT[], -- ['tonify_qi', 'calm_shen', 'move_blood']
  is_master_point BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_acupoint_code ON acupoint_mappings(acupoint_code);
CREATE INDEX IF NOT EXISTS idx_acupoint_figure ON acupoint_mappings(figure_id);
CREATE INDEX IF NOT EXISTS idx_acupoint_indications ON acupoint_mappings USING GIN(indications);
CREATE INDEX IF NOT EXISTS idx_acupoint_meridian ON acupoint_mappings(meridian);

-- ============================================================================
-- TABLE: figure_symptom_links (Symptom → Figure connections)
-- ============================================================================

CREATE TABLE IF NOT EXISTS figure_symptom_links (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  symptom_hebrew TEXT NOT NULL,
  symptom_english TEXT,
  figure_ids UUID[], -- Array of relevant figure IDs
  acupoint_codes TEXT[], -- Recommended points for this symptom
  priority INTEGER DEFAULT 5,
  description_hebrew TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_symptom_hebrew ON figure_symptom_links(symptom_hebrew);
CREATE INDEX IF NOT EXISTS idx_symptom_priority ON figure_symptom_links(priority);

-- ============================================================================
-- POPULATE: Sample Body Figures
-- ============================================================================

INSERT INTO body_figures (
  figure_name,
  figure_name_hebrew,
  body_region,
  view_type,
  description_hebrew,
  tags,
  display_order
) VALUES

('full_body_anterior', 'גוף מלא - קדמי', 'full_body', 'anterior',
 'תצוגה קדמית מלאה של הגוף עם כל המרידיאנים',
 ARRAY['כללי', 'מרידיאנים'], 1),

('full_body_posterior', 'גוף מלא - אחורי', 'full_body', 'posterior',
 'תצוגה אחורית עם שלפוחית השתן וכליות',
 ARRAY['גב', 'כליות'], 2),

('head_face_anterior', 'ראש ופנים - קדמי', 'head', 'anterior',
 'נקודות דיקור בראש ופנים לכאבי ראש וחרדה',
 ARRAY['ראש', 'פנים', 'כאב_ראש', 'חרדה'], 3),

('hand_arm_lateral', 'יד וזרוע - צד', 'arms', 'lateral',
 'נקודות דיקור בזרוע ויד כולל LI4',
 ARRAY['זרוע', 'יד', 'LI4'], 4),

('leg_foot_lateral', 'רגל וכף רגל - צד', 'legs', 'lateral',
 'נקודות ברגל כולל ST36, SP6',
 ARRAY['רגל', 'ST36', 'SP6'], 5)

ON CONFLICT (figure_name) DO UPDATE SET
  figure_name_hebrew = EXCLUDED.figure_name_hebrew,
  description_hebrew = EXCLUDED.description_hebrew,
  tags = EXCLUDED.tags,
  updated_at = NOW();

-- ============================================================================
-- POPULATE: Key Acupoint Mappings
-- ============================================================================

INSERT INTO acupoint_mappings (
  figure_id,
  acupoint_code,
  acupoint_name_hebrew,
  description_hebrew,
  indications,
  meridian,
  meridian_hebrew,
  function_category,
  is_master_point
) 
SELECT
  (SELECT id FROM body_figures WHERE figure_name = 'hand_arm_lateral' LIMIT 1),
  'LI4', 'הה גו', 'נקודת מאסטר לכאבים',
  ARRAY['כאב_ראש', 'כאב_שיניים', 'הקלה_כללית'],
  'Large Intestine', 'מעי גס',
  ARRAY['move_qi', 'stop_pain'],
  TRUE
WHERE EXISTS (SELECT 1 FROM body_figures WHERE figure_name = 'hand_arm_lateral')
ON CONFLICT DO NOTHING;

INSERT INTO acupoint_mappings (
  figure_id,
  acupoint_code,
  acupoint_name_hebrew,
  description_hebrew,
  indications,
  meridian,
  meridian_hebrew,
  function_category,
  is_master_point
)
SELECT
  (SELECT id FROM body_figures WHERE figure_name = 'leg_foot_lateral' LIMIT 1),
  'ST36', 'צו סאן לי', 'נקודת טוניפיקציה ראשית',
  ARRAY['עייפות', 'עיכול', 'חיזוק_כללי'],
  'Stomach', 'קיבה',
  ARRAY['tonify_qi', 'strengthen_spleen'],
  TRUE
WHERE EXISTS (SELECT 1 FROM body_figures WHERE figure_name = 'leg_foot_lateral')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- POPULATE: Symptom Links
-- ============================================================================

INSERT INTO figure_symptom_links (
  symptom_hebrew,
  symptom_english,
  figure_ids,
  acupoint_codes,
  priority,
  description_hebrew
)
SELECT
  'כאב ראש',
  'headache',
  ARRAY[(SELECT id FROM body_figures WHERE figure_name = 'head_face_anterior'),
        (SELECT id FROM body_figures WHERE figure_name = 'hand_arm_lateral')],
  ARRAY['GB20', 'LI4', 'YIN-TANG'],
  1,
  'כאבי ראש - טיפול בנקודות מקומיות ומרוחקות'
WHERE EXISTS (SELECT 1 FROM body_figures WHERE figure_name = 'head_face_anterior')
ON CONFLICT DO NOTHING;

INSERT INTO figure_symptom_links (
  symptom_hebrew,
  symptom_english,
  figure_ids,
  acupoint_codes,
  priority,
  description_hebrew
)
SELECT
  'עייפות',
  'fatigue',
  ARRAY[(SELECT id FROM body_figures WHERE figure_name = 'leg_foot_lateral')],
  ARRAY['ST36', 'SP6', 'CV6'],
  2,
  'עייפות - חיזוק כללי'
WHERE EXISTS (SELECT 1 FROM body_figures WHERE figure_name = 'leg_foot_lateral')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- FUNCTION: Get figures by symptom
-- ============================================================================

CREATE OR REPLACE FUNCTION get_figures_by_symptom(symptom TEXT)
RETURNS TABLE (
  figure_id UUID,
  figure_name_hebrew TEXT,
  acupoint_codes TEXT[],
  priority INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    UNNEST(fsl.figure_ids) as figure_id,
    bf.figure_name_hebrew,
    fsl.acupoint_codes,
    fsl.priority
  FROM figure_symptom_links fsl
  CROSS JOIN LATERAL UNNEST(fsl.figure_ids) AS figure_id_val
  JOIN body_figures bf ON bf.id = figure_id_val
  WHERE fsl.symptom_hebrew ILIKE '%' || symptom || '%'
     OR fsl.symptom_english ILIKE '%' || symptom || '%'
  ORDER BY fsl.priority ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- Success message
-- ============================================================================

DO $$
BEGIN
  RAISE NOTICE '✅ Body Figures module created successfully!';
  RAISE NOTICE '🫀 Total figures: %', (SELECT COUNT(*) FROM body_figures);
  RAISE NOTICE '📍 Total acupoints: %', (SELECT COUNT(*) FROM acupoint_mappings);
  RAISE NOTICE '🔗 Total symptom links: %', (SELECT COUNT(*) FROM figure_symptom_links);
END $$;
