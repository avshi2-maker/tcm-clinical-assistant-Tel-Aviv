# COMPLETE SUPABASE SETUP FOR BODY IMAGES

## Step 1: Create the Table (if not exists)

```sql
-- Create the tcm_body_images table
CREATE TABLE IF NOT EXISTS tcm_body_images (
  id SERIAL PRIMARY KEY,
  body_part VARCHAR(100) NOT NULL,
  image_url TEXT NOT NULL,
  acupoint_codes TEXT[] NOT NULL,
  acupoint_coordinates JSONB NOT NULL,
  pattern_relevance TEXT[] NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE tcm_body_images ENABLE ROW LEVEL SECURITY;

-- Create policy for public read access
DROP POLICY IF EXISTS "Allow public read access" ON tcm_body_images;
CREATE POLICY "Allow public read access" 
ON tcm_body_images 
FOR SELECT 
TO public 
USING (true);

-- Create policy for authenticated write access (optional)
DROP POLICY IF EXISTS "Allow authenticated insert" ON tcm_body_images;
CREATE POLICY "Allow authenticated insert" 
ON tcm_body_images 
FOR INSERT 
TO authenticated 
WITH CHECK (true);
```

---

## Step 2: Get Your Image URLs

Your images are stored in:
`https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/`

To get the exact filenames:
1. Go to: https://supabase.com/dashboard/project/iqfglrwjemogoycbzltt/storage/buckets/tcm-body-images
2. Note down each filename
3. Replace `FILENAME.jpg` below with actual filenames

---

## Step 3: Insert Data with Your Actual Image URLs

### Template (Update with your actual filenames)

```sql
-- IMPORTANT: Replace 'your_filename.jpg' with actual filenames from your storage!

-- Hand Dorsal - For Yin & Yang Deficiency
INSERT INTO tcm_body_images (body_part, image_url, acupoint_codes, acupoint_coordinates, pattern_relevance)
VALUES (
  'hand_dorsal',
  'https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/hand_dorsal.jpg',
  ARRAY['LI4', 'SI3', 'TB3', 'LI5'],
  '{
    "LI4": {"x": 245, "y": 180, "name": "合谷 Hegu"},
    "SI3": {"x": 310, "y": 220, "name": "后溪 Houxi"},
    "TB3": {"x": 290, "y": 160, "name": "中渚 Zhongzhu"},
    "LI5": {"x": 260, "y": 140, "name": "阳溪 Yangxi"}
  }'::jsonb,
  ARRAY['yin_deficiency', 'yang_deficiency', 'mixed']
);

-- Foot Medial - For Yin Deficiency
INSERT INTO tcm_body_images (body_part, image_url, acupoint_codes, acupoint_coordinates, pattern_relevance)
VALUES (
  'foot_medial',
  'https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/foot_medial.jpg',
  ARRAY['SP6', 'KI3', 'KI6', 'LV8'],
  '{
    "SP6": {"x": 180, "y": 240, "name": "三阴交 Sanyinjiao"},
    "KI3": {"x": 210, "y": 280, "name": "太溪 Taixi"},
    "KI6": {"x": 195, "y": 295, "name": "照海 Zhaohai"},
    "LV8": {"x": 165, "y": 220, "name": "曲泉 Ququan"}
  }'::jsonb,
  ARRAY['yin_deficiency', 'yin_def_yang_excess']
);

-- Abdomen - For Yang Deficiency
INSERT INTO tcm_body_images (body_part, image_url, acupoint_codes, acupoint_coordinates, pattern_relevance)
VALUES (
  'abdomen',
  'https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/abdomen.jpg',
  ARRAY['REN4', 'REN6', 'REN8', 'REN12', 'ST25'],
  '{
    "REN4": {"x": 300, "y": 340, "name": "关元 Guanyuan"},
    "REN6": {"x": 300, "y": 300, "name": "气海 Qihai"},
    "REN8": {"x": 300, "y": 260, "name": "神阙 Shenque"},
    "REN12": {"x": 300, "y": 220, "name": "中脘 Zhongwan"},
    "ST25": {"x": 260, "y": 320, "name": "天枢 Tianshu"}
  }'::jsonb,
  ARRAY['yang_deficiency', 'yang_def_yin_excess', 'mixed']
);

-- Lower Back - For Yang Deficiency
INSERT INTO tcm_body_images (body_part, image_url, acupoint_codes, acupoint_coordinates, pattern_relevance)
VALUES (
  'back_lower',
  'https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/back_lower.jpg',
  ARRAY['BL20', 'BL23', 'DU4', 'BL52'],
  '{
    "BL20": {"x": 280, "y": 220, "name": "脾俞 Pishu"},
    "BL23": {"x": 280, "y": 280, "name": "肾俞 Shenshu"},
    "DU4": {"x": 300, "y": 300, "name": "命门 Mingmen"},
    "BL52": {"x": 250, "y": 310, "name": "志室 Zhishi"}
  }'::jsonb,
  ARRAY['yang_deficiency', 'mixed']
);

-- Leg Anterior - For Yang & Mixed patterns
INSERT INTO tcm_body_images (body_part, image_url, acupoint_codes, acupoint_coordinates, pattern_relevance)
VALUES (
  'leg_anterior',
  'https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/leg_anterior.jpg',
  ARRAY['ST36', 'ST40', 'SP9', 'GB34'],
  '{
    "ST36": {"x": 220, "y": 380, "name": "足三里 Zusanli"},
    "ST40": {"x": 210, "y": 450, "name": "丰隆 Fenglong"},
    "SP9": {"x": 260, "y": 420, "name": "阴陵泉 Yinlingquan"},
    "GB34": {"x": 240, "y": 400, "name": "阳陵泉 Yanglingquan"}
  }'::jsonb,
  ARRAY['yin_def_yang_excess', 'yang_deficiency', 'mixed']
);

-- Forearm Palmar - For Yin Deficiency & Heart patterns
INSERT INTO tcm_body_images (body_part, image_url, acupoint_codes, acupoint_coordinates, pattern_relevance)
VALUES (
  'forearm_palmar',
  'https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/forearm_palmar.jpg',
  ARRAY['HT7', 'PC6', 'HT3', 'PC8'],
  '{
    "HT7": {"x": 280, "y": 320, "name": "神门 Shenmen"},
    "PC6": {"x": 300, "y": 280, "name": "内关 Neiguan"},
    "HT3": {"x": 250, "y": 200, "name": "少海 Shaohai"},
    "PC8": {"x": 300, "y": 380, "name": "劳宫 Laogong"}
  }'::jsonb,
  ARRAY['yin_deficiency', 'balanced']
);

-- Foot Dorsal - For Liver patterns
INSERT INTO tcm_body_images (body_part, image_url, acupoint_codes, acupoint_coordinates, pattern_relevance)
VALUES (
  'foot_dorsal',
  'https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/foot_dorsal.jpg',
  ARRAY['LV3', 'LV2', 'GB41', 'ST44'],
  '{
    "LV3": {"x": 350, "y": 420, "name": "太冲 Taichong"},
    "LV2": {"x": 370, "y": 460, "name": "行间 Xingjian"},
    "GB41": {"x": 280, "y": 380, "name": "足临泣 Zulinqi"},
    "ST44": {"x": 320, "y": 450, "name": "内庭 Neiting"}
  }'::jsonb,
  ARRAY['yin_def_yang_excess', 'mixed']
);

-- Leg Medial - For Spleen & Kidney patterns
INSERT INTO tcm_body_images (body_part, image_url, acupoint_codes, acupoint_coordinates, pattern_relevance)
VALUES (
  'leg_medial',
  'https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/leg_medial.jpg',
  ARRAY['SP6', 'SP9', 'SP10', 'LV8'],
  '{
    "SP6": {"x": 220, "y": 380, "name": "三阴交 Sanyinjiao"},
    "SP9": {"x": 240, "y": 300, "name": "阴陵泉 Yinlingquan"},
    "SP10": {"x": 260, "y": 220, "name": "血海 Xuehai"},
    "LV8": {"x": 200, "y": 280, "name": "曲泉 Ququan"}
  }'::jsonb,
  ARRAY['yang_deficiency', 'yin_deficiency', 'mixed']
);
```

---

## Step 4: Verify Data

```sql
-- Check if data was inserted
SELECT body_part, array_length(acupoint_codes, 1) as num_points, pattern_relevance
FROM tcm_body_images
ORDER BY id;

-- Get all data
SELECT * FROM tcm_body_images;

-- Test query for specific pattern
SELECT body_part, image_url, acupoint_codes
FROM tcm_body_images
WHERE 'yin_deficiency' = ANY(pattern_relevance);
```

---

## Step 5: Test in Browser

Open the `supabase-test.html` file to:
1. ✅ Test connection
2. ✅ List all storage files
3. ✅ View database records
4. ✅ Preview images

---

## Coordinate Adjustment Guide

If dots appear in wrong positions, you need to adjust coordinates:

### Method 1: Visual Inspection
1. Open image in browser: `https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-body-images/YOUR_FILE.jpg`
2. Right-click → Inspect Element
3. Note image dimensions (e.g., 800x1200)
4. Estimate acupoint position as percentage
5. Calculate: x = width × percentage, y = height × percentage

### Method 2: Image Editor
1. Download image from Supabase
2. Open in Photoshop/GIMP/Paint.NET
3. Enable coordinates display
4. Hover over each acupoint location
5. Note X,Y values
6. Update database

### Update Query Example:
```sql
UPDATE tcm_body_images
SET acupoint_coordinates = '{
  "LI4": {"x": 245, "y": 180, "name": "合谷 Hegu"},
  "SI3": {"x": 310, "y": 220, "name": "后溪 Houxi"}
}'::jsonb
WHERE body_part = 'hand_dorsal';
```

---

## Quick Reference: Pattern to Body Parts

### Yin Deficiency (陰虛)
**Shows:** Foot medial, Forearm palmar, Leg medial
**Points:** KI3, KI6, SP6, LV8, HT7, PC6

### Yang Deficiency (陽虛)  
**Shows:** Abdomen, Back lower, Leg anterior, Leg medial
**Points:** ST36, REN4, REN8, DU4, BL20, BL23

### Balanced (陰陽平衡)
**Shows:** Forearm palmar (minimal points)
**Points:** Basic balance points

### Yin Def + Yang Excess (陰虛陽亢)
**Shows:** Foot medial, Foot dorsal, Leg anterior
**Points:** Mixed cooling and clearing

### Yang Def + Yin Excess (陽虛陰盛)
**Shows:** Abdomen, Back lower
**Points:** Warming and drying

### Mixed (混合型)
**Shows:** Hand dorsal, Leg anterior, Back lower, Foot dorsal, Leg medial
**Points:** Combination approach

---

## Troubleshooting

### Images Don't Load
```sql
-- Check if URLs are correct
SELECT body_part, 
       CASE 
         WHEN image_url LIKE 'https://iqfglrwjemogoycbzltt.supabase.co%' THEN '✅ Correct'
         ELSE '❌ Wrong URL'
       END as url_status
FROM tcm_body_images;
```

### No Images Appear After Quiz
1. Check browser console (F12) for errors
2. Verify pattern classification is working
3. Confirm pattern names match database: `yin_deficiency`, `yang_deficiency`, etc.
4. Test query manually in Supabase

### Dots in Wrong Position
1. View image dimensions
2. Adjust coordinates proportionally
3. Test incremental changes (±50 pixels)
4. Update database with new coordinates

---

## Next Steps

1. ✅ Run Step 1 SQL (create table)
2. ✅ Get your actual image filenames from Supabase Storage
3. ✅ Update Step 3 SQL with correct filenames
4. ✅ Run Step 3 SQL (insert data)
5. ✅ Run Step 4 SQL (verify)
6. ✅ Open `supabase-test.html` to preview
7. ✅ Open `index.html` and test Yin-Yang questionnaire
8. ✅ Adjust coordinates if needed

---

**Your body images will now appear automatically based on the questionnaire results!** 🎉
