-- ============================================================================
-- DR. RONI - FIXED - BATCH 10
-- ============================================================================
-- Points 451 to 461
-- Using: WHERE point_code = 'XX' (NOT id)
-- ============================================================================

-- Point 329: Liv 11
UPDATE dr_roni_acupuncture_points SET
    chinese_name_hebrew = 'יִין לְיֵאן',
    search_keywords_hebrew = ARRAY['Liv 11', 'יִין לְיֵאן']
WHERE point_code = 'Liv 11';

-- Point 331: Liv 13
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['Liv 13']
WHERE point_code = 'Liv 13';

-- Point 332: Liv 14
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['Liv 14']
WHERE point_code = 'Liv 14';

-- Point 333: CV 1
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['CV 1']
WHERE point_code = 'CV 1';

-- Point 334: CV 2
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['CV 2']
WHERE point_code = 'CV 2';

-- Point 338: CV 5
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['CV 5']
WHERE point_code = 'CV 5';

-- Point 339: CV 6
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['CV 6']
WHERE point_code = 'CV 6';

-- Point 341: CV7 is a yin cross roads. Here KID, CV and Chong meet up. It is located on the yin aspect of the body
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['CV7 is a yin cross roads. Here KID, CV and Chong meet up. It is located on the yin aspect of the body']
WHERE point_code = 'CV7 is a yin cross roads. Here KID, CV and Chong meet up. It is located on the yin aspect of the body';

-- Point 342: CV 8
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['CV 8']
WHERE point_code = 'CV 8';

-- Point 343: CV 9
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['CV 9']
WHERE point_code = 'CV 9';

-- Point 344: CV 10
UPDATE dr_roni_acupuncture_points SET
    search_keywords_hebrew = ARRAY['CV 10']
WHERE point_code = 'CV 10';
