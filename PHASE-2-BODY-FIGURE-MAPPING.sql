-- ================================================================
-- PHASE 2: BODY FIGURE ACUPOINT MAPPING
-- Automated mapping from Dr. Roni's 461 points to body diagrams
-- Date: January 25, 2026
-- Time: 5 minutes to run
-- Impact: ⭐⭐⭐⭐⭐ Enables Body Figure BOOM algorithm!
-- ================================================================

-- ================================================================
-- STEP 1: Create mapping table
-- ================================================================

CREATE TABLE IF NOT EXISTS body_figure_acupoint_mapping (
    id SERIAL PRIMARY KEY,
    body_figure_id INTEGER,                    -- Links to tcm_body_images
    body_part TEXT NOT NULL,                   -- 'head', 'hand', 'leg', 'arm', 'foot', 'torso', 'back'
    body_region TEXT DEFAULT 'general',         -- 'front', 'back', 'side', 'general'
    acupoint_code TEXT NOT NULL,               -- 'LI4', 'ST36', 'GB20', etc.
    meridian TEXT,                             -- 'Large Intestine', 'Stomach', etc.
    point_name_eng TEXT,                       -- English name
    x_position INTEGER,                        -- Optional: pixel X coordinate
    y_position INTEGER,                        -- Optional: pixel Y coordinate
    created_at TIMESTAMP DEFAULT NOW()
);

-- ================================================================
-- STEP 2: Populate from Dr_roni_bible (AUTOMATED!)
-- Maps 461 points to 8 body figure categories
-- ================================================================

INSERT INTO body_figure_acupoint_mapping 
(body_figure_id, body_part, body_region, acupoint_code, meridian, point_name_eng)
SELECT 
    -- Smart mapping based on body_part text
    CASE 
        -- Head & Face (Figure 1)
        WHEN body_part ILIKE '%head%' OR 
             body_part ILIKE '%face%' OR 
             body_part ILIKE '%ear%' OR
             body_part ILIKE '%eye%' OR
             body_part ILIKE '%nose%' OR
             body_part ILIKE '%mouth%' OR
             body_part ILIKE '%temple%' OR
             body_part ILIKE '%forehead%' OR
             body_part ILIKE '%scalp%' 
        THEN 1
        
        -- Hand & Fingers (Figure 2)
        WHEN body_part ILIKE '%hand%' OR 
             body_part ILIKE '%finger%' OR
             body_part ILIKE '%palm%' OR
             body_part ILIKE '%thumb%'
        THEN 2
        
        -- Leg & Knee (Figure 3)
        WHEN body_part ILIKE '%leg%' OR 
             body_part ILIKE '%knee%' OR
             body_part ILIKE '%thigh%' OR
             body_part ILIKE '%calf%' OR
             body_part ILIKE '%shin%'
        THEN 3
        
        -- Arm & Elbow (Figure 4)
        WHEN body_part ILIKE '%arm%' OR 
             body_part ILIKE '%elbow%' OR
             body_part ILIKE '%shoulder%' OR
             body_part ILIKE '%forearm%' OR
             body_part ILIKE '%upper arm%'
        THEN 4
        
        -- Foot & Ankle (Figure 5)
        WHEN body_part ILIKE '%foot%' OR 
             body_part ILIKE '%ankle%' OR
             body_part ILIKE '%toe%' OR
             body_part ILIKE '%heel%' OR
             body_part ILIKE '%sole%'
        THEN 5
        
        -- Chest & Abdomen (Figure 6)
        WHEN body_part ILIKE '%chest%' OR 
             body_part ILIKE '%abdomen%' OR
             body_part ILIKE '%stomach%' OR
             body_part ILIKE '%breast%' OR
             body_part ILIKE '%ribs%' OR
             body_part ILIKE '%sternum%'
        THEN 6
        
        -- Back & Spine (Figure 7)
        WHEN body_part ILIKE '%back%' OR 
             body_part ILIKE '%spine%' OR
             body_part ILIKE '%lumbar%' OR
             body_part ILIKE '%scapula%' OR
             body_part ILIKE '%sacrum%'
        THEN 7
        
        -- Neck (add to Head)
        WHEN body_part ILIKE '%neck%' OR
             body_part ILIKE '%throat%'
        THEN 1
        
        -- Wrist (add to Hand)
        WHEN body_part ILIKE '%wrist%'
        THEN 2
        
        -- Hip (add to Torso)
        WHEN body_part ILIKE '%hip%' OR
             body_part ILIKE '%pelvis%'
        THEN 6
        
        -- General/Multiple regions
        ELSE 8
    END as body_figure_id,
    
    body_part,
    'general' as body_region,
    point_code as acupoint_code,
    meridian,
    english_name as point_name_eng
    
FROM Dr_roni_bible
WHERE body_part IS NOT NULL AND body_part != '';

-- ================================================================
-- STEP 3: Create indexes for fast lookup
-- ================================================================

CREATE INDEX IF NOT EXISTS idx_body_mapping_figure ON body_figure_acupoint_mapping(body_figure_id);
CREATE INDEX IF NOT EXISTS idx_body_mapping_point ON body_figure_acupoint_mapping(acupoint_code);
CREATE INDEX IF NOT EXISTS idx_body_mapping_part ON body_figure_acupoint_mapping(body_part);
CREATE INDEX IF NOT EXISTS idx_body_mapping_meridian ON body_figure_acupoint_mapping(meridian);

-- ================================================================
-- STEP 4: Verification queries
-- ================================================================

-- Count points per body figure
SELECT 
    body_figure_id,
    CASE body_figure_id
        WHEN 1 THEN 'Head & Face'
        WHEN 2 THEN 'Hand & Fingers'
        WHEN 3 THEN 'Leg & Knee'
        WHEN 4 THEN 'Arm & Elbow'
        WHEN 5 THEN 'Foot & Ankle'
        WHEN 6 THEN 'Chest & Abdomen'
        WHEN 7 THEN 'Back & Spine'
        WHEN 8 THEN 'General/Multiple'
        ELSE 'Unknown'
    END as body_region_name,
    COUNT(*) as acupoint_count,
    COUNT(DISTINCT meridian) as meridian_count
FROM body_figure_acupoint_mapping
GROUP BY body_figure_id
ORDER BY body_figure_id;

-- Show sample points for each body figure
SELECT 
    body_figure_id,
    string_agg(acupoint_code, ', ' ORDER BY acupoint_code) as sample_points
FROM (
    SELECT DISTINCT ON (body_figure_id, acupoint_code) 
        body_figure_id, 
        acupoint_code
    FROM body_figure_acupoint_mapping
) t
GROUP BY body_figure_id
ORDER BY body_figure_id;

-- Total points mapped
SELECT 
    '✅ Body Figure Mapping Complete!' as status,
    COUNT(*) as total_mappings,
    COUNT(DISTINCT acupoint_code) as unique_points,
    COUNT(DISTINCT body_figure_id) as body_figures
FROM body_figure_acupoint_mapping;

-- ================================================================
-- STEP 5: Create helper function for JavaScript
-- ================================================================

-- Function to get body figures for acupoint codes
CREATE OR REPLACE FUNCTION get_body_figures_for_points(point_codes TEXT[])
RETURNS TABLE (
    body_figure_id INTEGER,
    acupoint_codes TEXT[],
    point_count INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        bfam.body_figure_id,
        array_agg(DISTINCT bfam.acupoint_code) as acupoint_codes,
        COUNT(DISTINCT bfam.acupoint_code)::INTEGER as point_count
    FROM body_figure_acupoint_mapping bfam
    WHERE bfam.acupoint_code = ANY(point_codes)
    GROUP BY bfam.body_figure_id
    ORDER BY point_count DESC;
END;
$$ LANGUAGE plpgsql;

-- Test the function
SELECT * FROM get_body_figures_for_points(ARRAY['LI4', 'ST36', 'GB20']);

-- ================================================================
-- DONE! ✅
-- ================================================================

-- Next steps:
-- 1. Verify total mappings (should be ~461)
-- 2. Check distribution across body figures
-- 3. Test helper function with sample points
-- 4. Ready for Body Figure BOOM algorithm!

SELECT '🎨 Body Figure Mapping Ready for BOOM Algorithm!' as message;
