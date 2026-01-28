-- ================================================================
-- API SEARCH OPTIMIZATION - PHASE 1: PRIORITY SYSTEM
-- Date: January 25, 2026
-- Execution Time: ~15 minutes
-- Impact: ⭐⭐⭐⭐⭐ CRITICAL - Fixes Dr_roni_bible not being searched!
-- ================================================================

-- ================================================================
-- STEP 1: Check if priority column exists
-- ================================================================

SELECT column_name, data_type, column_default
FROM information_schema.columns 
WHERE table_name = 'search_config'
ORDER BY ordinal_position;

-- ================================================================
-- STEP 2: Add priority column (if not exists)
-- ================================================================

ALTER TABLE search_config 
ADD COLUMN IF NOT EXISTS priority INTEGER DEFAULT 99;

-- ================================================================
-- STEP 3: Add search_fields column for future flexibility
-- ================================================================

ALTER TABLE search_config 
ADD COLUMN IF NOT EXISTS search_fields TEXT[] DEFAULT ARRAY[]::TEXT[];

-- ================================================================
-- STEP 4: Add weight column for relevance scoring (Phase 4)
-- ================================================================

ALTER TABLE search_config 
ADD COLUMN IF NOT EXISTS weight INTEGER DEFAULT 5;

-- ================================================================
-- STEP 5: Configure TIER 1 - CRITICAL (Priority 1-3)
-- ================================================================

-- Priority 1: Dr_roni_bible - MOST AUTHORITATIVE
INSERT INTO search_config (table_name, description, enabled, priority, weight, search_fields)
VALUES (
    'Dr_roni_bible',
    'Dr. Roni Sapir PhD - 461 Acupuncture Points (30 years experience) - MOST AUTHORITATIVE SOURCE',
    true,
    1,
    10,
    ARRAY['point_code', 'meridian', 'chinese_name', 'english_name', 'description', 'indications', 'location']
)
ON CONFLICT (table_name) DO UPDATE SET
    priority = EXCLUDED.priority,
    weight = EXCLUDED.weight,
    description = EXCLUDED.description,
    search_fields = EXCLUDED.search_fields,
    enabled = EXCLUDED.enabled;

-- Priority 2: qa_knowledge_base - Direct Q&A
UPDATE search_config 
SET priority = 2,
    weight = 9,
    description = 'Q&A Knowledge Base - Direct Clinical Answers',
    search_fields = ARRAY['question', 'answer', 'category', 'tags', 'keywords']
WHERE table_name = 'qa_knowledge_base';

-- Priority 3: dr_roni_acupuncture_points
UPDATE search_config 
SET priority = 3,
    weight = 8,
    description = 'Dr. Roni Acupuncture Points Clinical Database',
    search_fields = ARRAY['point_name_heb', 'point_name_eng', 'indications', 'location', 'tcm_actions', 'clinical_notes']
WHERE table_name = 'dr_roni_acupuncture_points';

-- ================================================================
-- STEP 6: Configure TIER 2 - HIGH PRIORITY (Priority 4-7)
-- ================================================================

-- Priority 4: acupuncture_points
UPDATE search_config 
SET priority = 4,
    weight = 7,
    description = 'Standard Acupuncture Points Reference Database',
    search_fields = ARRAY['point_name', 'english_name', 'chinese_name', 'indications', 'location']
WHERE table_name = 'acupuncture_points';

-- Priority 5: zangfu_syndromes
UPDATE search_config 
SET priority = 5,
    weight = 7,
    description = 'Zang Fu Organ Syndrome Patterns - Core TCM Diagnosis',
    search_fields = ARRAY['syndrome_name_he', 'syndrome_name_en', 'main_symptoms', 'pathology', 'treatment_principles']
WHERE table_name = 'zangfu_syndromes';

-- Priority 6: tcm_training_syllabus - Educational Q&A
INSERT INTO search_config (table_name, description, enabled, priority, weight, search_fields)
VALUES (
    'tcm_training_syllabus',
    '48 Training Q&A Topics - Educational Material (Pulse, Tongue, Elements)',
    true,
    6,
    6,
    ARRAY['question', 'answer', 'category', 'number', 'difficulty', 'tags']
)
ON CONFLICT (table_name) DO UPDATE SET
    priority = EXCLUDED.priority,
    weight = EXCLUDED.weight,
    description = EXCLUDED.description,
    search_fields = EXCLUDED.search_fields,
    enabled = EXCLUDED.enabled;

-- Priority 7: v_symptom_acupoints - Symptom mapping VIEW
UPDATE search_config 
SET priority = 7,
    weight = 6,
    description = 'Symptom to Acupoint Mapping - Clinical Quick Reference',
    search_fields = ARRAY['symptom_name', 'point_name', 'category']
WHERE table_name = 'v_symptom_acupoints';

-- ================================================================
-- STEP 7: Configure TIER 3 - MEDIUM PRIORITY (Priority 8-10)
-- ================================================================

-- Priority 8: tcm_pulse_diagnosis
UPDATE search_config 
SET priority = 8,
    weight = 5,
    description = 'TCM Pulse Diagnosis Patterns and Characteristics',
    search_fields = ARRAY['pulse_name_he', 'pulse_name_en', 'pulse_name_cn', 'characteristics', 'clinical_significance', 'indications']
WHERE table_name = 'tcm_pulse_diagnosis';

-- Priority 9: tcm_tongue_diagnosis
UPDATE search_config 
SET priority = 9,
    weight = 5,
    description = 'TCM Tongue Diagnosis Findings and Patterns',
    search_fields = ARRAY['finding_he', 'finding_en', 'finding_cn', 'characteristics', 'clinical_significance', 'pattern_diagnosis']
WHERE table_name = 'tcm_tongue_diagnosis';

-- Priority 10: yin_yang_symptoms
UPDATE search_config 
SET priority = 10,
    weight = 4,
    description = 'Yin Yang Symptom Classification System',
    search_fields = ARRAY['symptom_he', 'symptom_en', 'category', 'pattern']
WHERE table_name = 'yin_yang_symptoms';

-- ================================================================
-- STEP 8: Configure TIER 4 - SUPPORT (Priority 11-13)
-- ================================================================

-- Priority 11: yin_yang_pattern_protocols
UPDATE search_config 
SET priority = 11,
    weight = 3,
    description = 'Yin Yang Pattern Treatment Protocols',
    search_fields = ARRAY['pattern_name_he', 'pattern_name_en', 'treatment_principles', 'acupoints']
WHERE table_name = 'yin_yang_pattern_protocols';

-- Priority 12: acupuncture_point_warnings
UPDATE search_config 
SET priority = 12,
    weight = 3,
    description = 'Acupuncture Point Safety Warnings and Contraindications',
    search_fields = ARRAY['warning_he', 'warning_en', 'point_name', 'severity', 'contraindication']
WHERE table_name = 'acupuncture_point_warnings';

-- Priority 13: tcm_body_images
UPDATE search_config 
SET priority = 13,
    weight = 2,
    description = 'TCM Body Diagram Images - Visual Reference Material',
    search_fields = ARRAY['body_part', 'region_name_he', 'region_name_en', 'meridian']
WHERE table_name = 'tcm_body_images';

-- ================================================================
-- STEP 9: Verify the configuration
-- ================================================================

SELECT 
    priority,
    weight,
    table_name,
    description,
    enabled,
    array_length(search_fields, 1) as field_count,
    search_fields
FROM search_config 
WHERE enabled = true
ORDER BY priority;

-- ================================================================
-- STEP 10: Verify critical tables have data
-- ================================================================

SELECT 'Dr_roni_bible' as table_name, COUNT(*) as row_count 
FROM Dr_roni_bible
UNION ALL
SELECT 'tcm_training_syllabus', COUNT(*) 
FROM tcm_training_syllabus
UNION ALL
SELECT 'acupuncture_points', COUNT(*) 
FROM acupuncture_points
UNION ALL
SELECT 'qa_knowledge_base', COUNT(*) 
FROM qa_knowledge_base
ORDER BY table_name;

-- ================================================================
-- STEP 11: Check which tables exist in database
-- ================================================================

SELECT 
    sc.table_name,
    sc.priority,
    sc.enabled,
    CASE 
        WHEN t.table_name IS NOT NULL THEN '✅ Exists'
        ELSE '❌ Missing'
    END as table_status
FROM search_config sc
LEFT JOIN information_schema.tables t 
    ON sc.table_name = t.table_name 
    AND t.table_schema = 'public'
WHERE sc.enabled = true
ORDER BY sc.priority;

-- ================================================================
-- DONE! ✅
-- ================================================================
-- Next steps:
-- 1. Update JavaScript getDefaultSearchFields() function
-- 2. Test search to verify priorities work
-- 3. Proceed to Phase 3 (Smart Result Limiting)
-- ================================================================

-- Quick verification query - run this after updates:
SELECT COUNT(*) as total_enabled_tables,
       COUNT(DISTINCT priority) as priority_levels,
       MIN(priority) as highest_priority,
       MAX(priority) as lowest_priority
FROM search_config 
WHERE enabled = true;
