-- INSERT LU1 (LUNG 1) - THE FINAL MISSING POINT!
-- This completes the database to 100% for all 11 syndromes

-- Find current max ID and add LU1
DO $$
DECLARE
    next_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(id), 0) + 1 INTO next_id FROM dr_roni_complete;
    
    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id,
        'LU1',
        'Middle Palace',
        'הארמון האמצעי',
        'על הצד הלטרלי‑קדמי של החזה, במרווח הבין‑צלעי הראשון, 6 צון לטרלית לקו האמצע הקדמי, כ‑1 צון מתחת ל‑LU2 ומתחת לקצה הלטרלי של הקלביקולה.',
        'נקודת מו‑קדמית של הריאה ונקודת מפגש ריאה‑טחול; מפזרת ומורידה צ׳י ריאה, מטהרת ליחה ואש בחזה, פותחת את החזה ומקלה על שיעול, אסתמה וקוצר נשימה.'
    );
END $$;
