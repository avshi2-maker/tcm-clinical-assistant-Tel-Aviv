-- ============================================================================
-- DR. RONI ACUPUNCTURE POINTS - UPDATE SEARCH CONFIGURATION
-- ============================================================================
-- Run this AFTER importing all Hebrew translations
-- This enables Hebrew search on the dr_roni_acupuncture_points table
-- ============================================================================

-- Update search_config to include all Hebrew fields
UPDATE search_config
SET search_fields = ARRAY[
    'point_code',              -- e.g., "Lu 2", "ST 36"
    'chinese_name',            -- e.g., "YUN MEN", "ZU SAN LI"
    'chinese_name_hebrew',     -- e.g., "יון מן", "זו סאן לי"
    'english_name',            -- e.g., "Cloud Door", "Leg Three Miles"
    'english_name_hebrew',     -- e.g., "שער העננים", "רגל שלושה מיילים"
    'location',                -- English location description
    'location_hebrew',         -- Hebrew location description
    'indications',             -- English indications
    'indications_hebrew'       -- Hebrew indications (MOST IMPORTANT for search!)
],
enabled = true,
priority = 8  -- High priority (show before general knowledge base)
WHERE table_name = 'dr_roni_acupuncture_points';

-- Verify the update
SELECT 
    table_name,
    search_fields,
    enabled,
    priority
FROM search_config
WHERE table_name = 'dr_roni_acupuncture_points';

-- ============================================================================
-- EXPECTED RESULT:
-- ============================================================================
-- table_name: dr_roni_acupuncture_points
-- search_fields: {point_code, chinese_name, chinese_name_hebrew, english_name, 
--                 english_name_hebrew, location, location_hebrew, indications, 
--                 indications_hebrew}
-- enabled: true
-- priority: 8
-- ============================================================================

-- Test Hebrew search (should return results now!)
SELECT 
    point_code,
    english_name,
    english_name_hebrew,
    indications_hebrew
FROM dr_roni_acupuncture_points
WHERE indications_hebrew ILIKE '%כאב ראש%'
ORDER BY point_code
LIMIT 10;

-- Expected: ~30 results including LI4, GB20, GV20, ST8, BL2, Yintang, etc.

-- Test another search
SELECT 
    point_code,
    english_name,
    english_name_hebrew,
    indications_hebrew
FROM dr_roni_acupuncture_points
WHERE indications_hebrew ILIKE '%עייפות%'
   OR indications_hebrew ILIKE '%חולשה%'
ORDER BY point_code
LIMIT 10;

-- Expected: ~20 results including ST36, SP6, KI3, CV4, CV6, etc.

-- ============================================================================
-- STATISTICS: Check translation completeness
-- ============================================================================

SELECT 
    COUNT(*) as total_points,
    COUNT(chinese_name_hebrew) as translated_chinese_name,
    COUNT(english_name_hebrew) as translated_english_name,
    COUNT(indications_hebrew) as translated_indications,
    COUNT(contraindications_hebrew) as translated_contraindications,
    ROUND(100.0 * COUNT(indications_hebrew) / COUNT(*), 1) as percent_complete
FROM dr_roni_acupuncture_points;

-- Expected:
-- total_points: 461
-- translated_chinese_name: 461
-- translated_english_name: 461
-- translated_indications: 461
-- translated_contraindications: ~400-461 (some may be NULL if original was empty)
-- percent_complete: 100.0%

-- ============================================================================
-- POPULAR SEARCH TERMS TEST
-- ============================================================================

-- Test 1: Headache (כאב ראש)
SELECT COUNT(*) as results, 'כאב ראש' as search_term
FROM dr_roni_acupuncture_points
WHERE indications_hebrew ILIKE '%כאב ראש%'
   OR english_name_hebrew ILIKE '%כאב ראש%';

-- Test 2: Back pain (כאב גב)
SELECT COUNT(*) as results, 'כאב גב' as search_term
FROM dr_roni_acupuncture_points
WHERE indications_hebrew ILIKE '%כאב גב%'
   OR indications_hebrew ILIKE '%גב%';

-- Test 3: Fatigue (עייפות)
SELECT COUNT(*) as results, 'עייפות' as search_term
FROM dr_roni_acupuncture_points
WHERE indications_hebrew ILIKE '%עייפות%'
   OR indications_hebrew ILIKE '%חולשה%';

-- Test 4: Insomnia (נדודי שינה)
SELECT COUNT(*) as results, 'נדודי שינה' as search_term
FROM dr_roni_acupuncture_points
WHERE indications_hebrew ILIKE '%שינה%'
   OR indications_hebrew ILIKE '%נדודי%';

-- Test 5: Digestion (עיכול)
SELECT COUNT(*) as results, 'עיכול' as search_term
FROM dr_roni_acupuncture_points
WHERE indications_hebrew ILIKE '%עיכול%'
   OR indications_hebrew ILIKE '%קיבה%';

-- ============================================================================
-- SUCCESS CRITERIA:
-- ============================================================================
-- ✅ search_config updated with 9 Hebrew-enabled fields
-- ✅ "כאב ראש" returns ~25-35 points
-- ✅ "כאב גב" returns ~20-30 points
-- ✅ "עייפות" returns ~15-25 points
-- ✅ "נדודי שינה" returns ~10-20 points
-- ✅ Translation completeness: 100%
-- ============================================================================

-- Done! Hebrew search is now enabled for Dr. Roni's acupuncture points! 🎉
