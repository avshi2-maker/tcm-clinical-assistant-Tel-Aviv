-- ============================================================================
-- DR. RONI ACUPUNCTURE POINTS - ADD HEBREW COLUMNS
-- ============================================================================
-- This adds Hebrew translation columns to dr_roni_acupuncture_points table
-- Run this FIRST before importing translations
-- ============================================================================

-- Add Hebrew translation columns
ALTER TABLE dr_roni_acupuncture_points
ADD COLUMN IF NOT EXISTS chinese_name_hebrew TEXT,
ADD COLUMN IF NOT EXISTS english_name_hebrew TEXT,
ADD COLUMN IF NOT EXISTS location_hebrew TEXT,
ADD COLUMN IF NOT EXISTS indications_hebrew TEXT,
ADD COLUMN IF NOT EXISTS contraindications_hebrew TEXT,
ADD COLUMN IF NOT EXISTS tcm_actions_hebrew TEXT,
ADD COLUMN IF NOT EXISTS anatomy_hebrew TEXT,
ADD COLUMN IF NOT EXISTS needling_hebrew TEXT,
ADD COLUMN IF NOT EXISTS description_hebrew TEXT,
ADD COLUMN IF NOT EXISTS search_keywords_hebrew TEXT[];

-- Create GIN index for Hebrew keyword search (fast array search)
CREATE INDEX IF NOT EXISTS idx_dr_roni_search_hebrew 
ON dr_roni_acupuncture_points USING GIN(search_keywords_hebrew);

-- Create regular indexes for Hebrew text fields
CREATE INDEX IF NOT EXISTS idx_dr_roni_english_name_hebrew 
ON dr_roni_acupuncture_points(english_name_hebrew);

CREATE INDEX IF NOT EXISTS idx_dr_roni_indications_hebrew 
ON dr_roni_acupuncture_points USING gin(to_tsvector('simple', indications_hebrew));

-- Verify columns were added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'dr_roni_acupuncture_points' 
  AND column_name LIKE '%hebrew%'
ORDER BY column_name;

-- Check table status
SELECT 
    COUNT(*) as total_rows,
    COUNT(chinese_name_hebrew) as rows_with_hebrew,
    COUNT(*) - COUNT(chinese_name_hebrew) as rows_needing_translation
FROM dr_roni_acupuncture_points;

-- ============================================================================
-- Expected result: 
-- - 10 new columns added (9 text + 1 array)
-- - 3 indexes created
-- - total_rows: 461
-- - rows_with_hebrew: 0 (before translation)
-- - rows_needing_translation: 461
-- ============================================================================
