-- ================================================================
-- PHASE 3: ALGORITHM TRIGGER CONFIGURATION
-- Configures which tables trigger which algorithms
-- Date: January 25, 2026
-- Time: 5 minutes to run
-- Impact: ⭐⭐⭐⭐⭐ Enables multi-algorithm coordination!
-- ================================================================

-- ================================================================
-- STEP 1: Add trigger configuration columns
-- ================================================================

ALTER TABLE search_config 
ADD COLUMN IF NOT EXISTS triggers_body_figures BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS triggers_csv_flash BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS triggers_deep_insight BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS csv_category TEXT,
ADD COLUMN IF NOT EXISTS csv_title_he TEXT,
ADD COLUMN IF NOT EXISTS csv_title_en TEXT,
ADD COLUMN IF NOT EXISTS csv_row_count INTEGER;

-- ================================================================
-- STEP 2: Configure Body Figure Triggers (Algorithm 2)
-- These tables contain acupoint data → trigger body figure display
-- ================================================================

UPDATE search_config 
SET triggers_body_figures = true 
WHERE table_name IN (
    'Dr_roni_bible',                    -- Priority 1 - Most authoritative!
    'acupuncture_points',               -- Priority 6
    'dr_roni_acupuncture_points'        -- Priority 3
);

-- ================================================================
-- STEP 3: Configure CSV Flash Triggers (Algorithm 3)
-- These tables have associated CSV knowledge bases
-- ================================================================

-- Pulse Diagnosis
UPDATE search_config 
SET triggers_csv_flash = true,
    csv_category = 'pulse',
    csv_title_he = 'דופק - ידע מעמיק',
    csv_title_en = 'Pulse Diagnosis Deep Dive',
    csv_row_count = 23
WHERE table_name = 'tcm_pulse_diagnosis';

-- Tongue Diagnosis
UPDATE search_config 
SET triggers_csv_flash = true,
    csv_category = 'tongue',
    csv_title_he = 'לשון - ידע מעמיק',
    csv_title_en = 'Tongue Diagnosis Deep Dive',
    csv_row_count = 20
WHERE table_name = 'tcm_tongue_diagnosis';

-- Zang Fu Syndromes
UPDATE search_config 
SET triggers_csv_flash = true,
    csv_category = 'syndrome',
    csv_title_he = 'תסמונות - ידע מעמיק',
    csv_title_en = 'Syndrome Patterns Deep Dive',
    csv_row_count = 15
WHERE table_name = 'zangfu_syndromes';

-- Training Syllabus
UPDATE search_config 
SET triggers_csv_flash = true,
    csv_category = 'training',
    csv_title_he = 'סילבוס - 48 נושאי לימוד',
    csv_title_en = 'Training Syllabus - 48 Topics',
    csv_row_count = 48
WHERE table_name = 'tcm_training_syllabus';

-- QA Knowledge Base
UPDATE search_config 
SET triggers_csv_flash = true,
    csv_category = 'qa',
    csv_title_he = 'שאלות ותשובות - 2,325 מקרים',
    csv_title_en = 'Q&A Knowledge Base - 2,325 Cases',
    csv_row_count = 2325
WHERE table_name = 'qa_knowledge_base';

-- ================================================================
-- STEP 4: Create CSV metadata table for flash panel
-- ================================================================

CREATE TABLE IF NOT EXISTS csv_flash_metadata (
    id SERIAL PRIMARY KEY,
    category TEXT UNIQUE NOT NULL,
    title_hebrew TEXT NOT NULL,
    title_english TEXT NOT NULL,
    description_he TEXT,
    description_en TEXT,
    row_count INTEGER,
    icon TEXT DEFAULT '📊',
    color TEXT DEFAULT '#3b82f6',
    enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Insert metadata for all CSV categories
INSERT INTO csv_flash_metadata 
(category, title_hebrew, title_english, description_he, description_en, row_count, icon, color, enabled)
VALUES
('pulse', 'דופק - ידע מעמיק', 'Pulse Diagnosis Deep Dive', 
 '23 סוגי דופק עם תיאורים קליניים מפורטים', 
 '23 pulse types with detailed clinical descriptions', 
 23, '💓', '#e74c3c', true),

('tongue', 'לשון - ידע מעמיק', 'Tongue Diagnosis Deep Dive', 
 '20 ממצאי לשון עם משמעות קלינית', 
 '20 tongue findings with clinical significance', 
 20, '👅', '#e91e63', true),

('syndrome', 'תסמונות - ידע מעמיק', 'Syndrome Patterns Deep Dive', 
 'תסמונות זנג-פו מלאות עם עקרונות טיפול', 
 'Complete Zang-Fu syndromes with treatment principles', 
 15, '🔬', '#9c27b0', true),

('training', 'סילבוס מקצועי', 'Professional Training Syllabus', 
 '48 נושאי לימוד: דופק, לשון, 5 אלמנטים', 
 '48 training topics: Pulse, Tongue, 5 Elements', 
 48, '🎓', '#667eea', true),

('qa', 'שאלות ותשובות', 'Q&A Knowledge Base', 
 '2,325 מקרים קליניים בעברית', 
 '2,325 clinical cases in Hebrew', 
 2325, '❓', '#10b981', true),

('elements', '5 האלמנטים', 'Five Elements Theory', 
 'תורת 5 האלמנטים המלאה', 
 'Complete Five Elements theory', 
 5, '⭐', '#f59e0b', true)

ON CONFLICT (category) DO UPDATE SET
    title_hebrew = EXCLUDED.title_hebrew,
    title_english = EXCLUDED.title_english,
    description_he = EXCLUDED.description_he,
    description_en = EXCLUDED.description_en,
    row_count = EXCLUDED.row_count,
    icon = EXCLUDED.icon,
    color = EXCLUDED.color,
    enabled = EXCLUDED.enabled;

-- ================================================================
-- STEP 5: Create algorithm coordination table
-- Tracks which algorithms fire for each search
-- ================================================================

CREATE TABLE IF NOT EXISTS algorithm_execution_log (
    id SERIAL PRIMARY KEY,
    search_session_id TEXT,
    algorithm_name TEXT NOT NULL,  -- 'priority_search', 'body_figures', 'csv_flash'
    triggered_by_table TEXT,
    execution_time_ms INTEGER,
    result_count INTEGER,
    success BOOLEAN DEFAULT true,
    error_message TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_algo_log_session ON algorithm_execution_log(search_session_id);
CREATE INDEX IF NOT EXISTS idx_algo_log_name ON algorithm_execution_log(algorithm_name);
CREATE INDEX IF NOT EXISTS idx_algo_log_date ON algorithm_execution_log(created_at);

-- ================================================================
-- STEP 6: Verification queries
-- ================================================================

-- Show all trigger configurations
SELECT 
    priority,
    table_name,
    description,
    triggers_body_figures as '🎨 Body Fig',
    triggers_csv_flash as '📊 CSV Flash',
    csv_category,
    csv_title_he,
    csv_row_count
FROM search_config
WHERE enabled = true
ORDER BY priority;

-- Show CSV flash metadata
SELECT 
    icon,
    category,
    title_hebrew,
    title_english,
    row_count,
    color,
    enabled
FROM csv_flash_metadata
ORDER BY 
    CASE category
        WHEN 'pulse' THEN 1
        WHEN 'tongue' THEN 2
        WHEN 'syndrome' THEN 3
        WHEN 'training' THEN 4
        WHEN 'qa' THEN 5
        WHEN 'elements' THEN 6
        ELSE 99
    END;

-- Summary of algorithm triggers
SELECT 
    '✅ Algorithm Trigger Configuration Complete!' as status,
    COUNT(*) FILTER (WHERE triggers_body_figures = true) as body_figure_triggers,
    COUNT(*) FILTER (WHERE triggers_csv_flash = true) as csv_flash_triggers,
    COUNT(*) as total_enabled_tables
FROM search_config
WHERE enabled = true;

-- ================================================================
-- STEP 7: Create helper functions for JavaScript
-- ================================================================

-- Function to get CSV metadata for triggered categories
CREATE OR REPLACE FUNCTION get_csv_flash_data(categories TEXT[])
RETURNS TABLE (
    category TEXT,
    title_he TEXT,
    title_en TEXT,
    description_he TEXT,
    row_count INTEGER,
    icon TEXT,
    color TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cfm.category,
        cfm.title_hebrew,
        cfm.title_english,
        cfm.description_he,
        cfm.row_count,
        cfm.icon,
        cfm.color
    FROM csv_flash_metadata cfm
    WHERE cfm.category = ANY(categories)
      AND cfm.enabled = true
    ORDER BY 
        CASE cfm.category
            WHEN 'pulse' THEN 1
            WHEN 'tongue' THEN 2
            WHEN 'syndrome' THEN 3
            WHEN 'training' THEN 4
            WHEN 'qa' THEN 5
            WHEN 'elements' THEN 6
            ELSE 99
        END;
END;
$$ LANGUAGE plpgsql;

-- Test the function
SELECT * FROM get_csv_flash_data(ARRAY['pulse', 'tongue', 'training']);

-- ================================================================
-- STEP 8: Create algorithm coordination view
-- ================================================================

CREATE OR REPLACE VIEW v_algorithm_triggers AS
SELECT 
    sc.table_name,
    sc.priority,
    sc.description,
    sc.triggers_body_figures,
    sc.triggers_csv_flash,
    sc.csv_category,
    cfm.title_hebrew as csv_title_he,
    cfm.icon as csv_icon,
    cfm.color as csv_color
FROM search_config sc
LEFT JOIN csv_flash_metadata cfm ON sc.csv_category = cfm.category
WHERE sc.enabled = true
ORDER BY sc.priority;

-- Show the view
SELECT * FROM v_algorithm_triggers;

-- ================================================================
-- DONE! ✅
-- ================================================================

-- Next steps:
-- 1. Verify trigger configurations
-- 2. Check CSV flash metadata
-- 3. Test helper functions
-- 4. Ready for JavaScript integration!

SELECT '⚙️ Algorithm Triggers Configured! Ready for Multi-Algorithm Magic!' as message;
