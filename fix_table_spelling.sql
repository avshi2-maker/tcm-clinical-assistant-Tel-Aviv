-- ================================================================
-- FIX TABLE NAME SPELLING ISSUE
-- Problem: Data in "accupanture_points" (wrong spelling)
-- Solution: Create correct "acupuncture_points" table and copy data
-- ================================================================

-- Step 1: Create the CORRECTLY spelled table
CREATE TABLE IF NOT EXISTS acupuncture_points (
    id SERIAL PRIMARY KEY,
    point_number TEXT NOT NULL,
    warning_level TEXT,
    explanation TEXT,
    point_number_hebrew TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Step 2: Copy all 90 rows from wrong table to correct table
INSERT INTO acupuncture_points (point_number, warning_level, explanation, point_number_hebrew)
SELECT point_number, warning_level, explanation, point_number_hebrew 
FROM accupanture_points;

-- Step 3: Verify data copied correctly
SELECT COUNT(*) as total_rows FROM acupuncture_points;

-- Step 4: (Optional) Delete the wrong table after verifying
-- Uncomment this line only AFTER you verify the data copied correctly:
-- DROP TABLE accupanture_points;

-- ✅ SUCCESS! You should see 90 rows in acupuncture_points table.
