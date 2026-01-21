# SUPABASE SETUP - QUICK REFERENCE
**For: Yin-Yang Questionnaire Body Image Integration**

---

## 🔑 STEP 1: GET YOUR CREDENTIALS

### From Supabase Dashboard:
1. Go to https://supabase.com/dashboard
2. Select your project
3. Click "Settings" (gear icon)
4. Click "API"
5. Copy these two values:

```
Project URL: https://xxxxxxxxxxxxx.supabase.co
anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 📊 STEP 2: VERIFY TABLE STRUCTURE

### Required Table: `tcm_body_images`

Run this SQL in Supabase SQL Editor to create the table if it doesn't exist:

```sql
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

-- Create policy to allow public read access
CREATE POLICY "Allow public read access" 
ON tcm_body_images 
FOR SELECT 
TO public 
USING (true);
```

---

## 📝 STEP 3: INSERT SAMPLE DATA

Here's example data to test with:

```sql
INSERT INTO tcm_body_images (
  body_part, 
  image_url, 
  acupoint_codes, 
  acupoint_coordinates, 
  pattern_relevance
) VALUES 
(
  'hand_dorsal',
  'https://example.com/images/hand_dorsal.jpg',
  ARRAY['LI4', 'SI3', 'TB3'],
  '{
    "LI4": {"x": 245, "y": 180, "name": "合谷"},
    "SI3": {"x": 310, "y": 220, "name": "后溪"},
    "TB3": {"x": 290, "y": 160, "name": "中渚"}
  }'::jsonb,
  ARRAY['yin_deficiency', 'yang_deficiency', 'mixed']
),
(
  'foot_medial',
  'https://example.com/images/foot_medial.jpg',
  ARRAY['SP6', 'KI3', 'LR3'],
  '{
    "SP6": {"x": 180, "y": 240, "name": "三阴交"},
    "KI3": {"x": 210, "y": 280, "name": "太溪"},
    "LR3": {"x": 250, "y": 320, "name": "太冲"}
  }'::jsonb,
  ARRAY['yin_deficiency', 'yin_def_yang_excess']
),
(
  'abdomen',
  'https://example.com/images/abdomen.jpg',
  ARRAY['CV4', 'CV6', 'ST25'],
  '{
    "CV4": {"x": 300, "y": 280, "name": "关元"},
    "CV6": {"x": 300, "y": 240, "name": "气海"},
    "ST25": {"x": 260, "y": 260, "name": "天枢"}
  }'::jsonb,
  ARRAY['yang_deficiency', 'yang_def_yin_excess', 'mixed']
);
```

---

## 🧪 STEP 4: TEST CONNECTION

### In Browser Console:
```javascript
// Test basic connection
const { data, error } = await supabase
  .from('tcm_body_images')
  .select('*')
  .limit(1);

if (error) {
  console.error('Connection failed:', error);
} else {
  console.log('Success! Sample data:', data);
}
```

### Test Pattern-Specific Query:
```javascript
// Test querying by pattern
const { data, error } = await supabase
  .from('tcm_body_images')
  .select('*')
  .contains('pattern_relevance', ['yin_deficiency']);

console.log('Images for Yin Deficiency:', data);
```

---

## 🖼️ STEP 5: IMAGE REQUIREMENTS

### Image Format Guidelines:
- **File format:** JPG or PNG
- **Size:** 800-1200px wide (optimize for web)
- **Background:** Neutral/white background preferred
- **Quality:** High-res but compressed (<500KB per image)

### Upload to Supabase Storage:
1. In Supabase Dashboard → Storage
2. Create bucket named `tcm-images` (make it public)
3. Upload your images
4. Copy the public URL for each image

Example URL format:
```
https://xxxxx.supabase.co/storage/v1/object/public/tcm-images/hand_dorsal.jpg
```

---

## 📍 STEP 6: MAPPING ACUPOINT COORDINATES

### How to Find Coordinates:
1. Open image in image editor (Photoshop, GIMP, etc.)
2. Enable ruler/coordinates display
3. Hover over acupoint location
4. Note X,Y pixel coordinates
5. Add to database

### Coordinate System:
- Origin (0,0) is **top-left corner**
- X increases to the right
- Y increases downward
- Use pixel values relative to image dimensions

Example:
```
Image: 800px × 600px
Acupoint at center: {"x": 400, "y": 300}
```

---

## 🎯 STEP 7: PATTERN MAPPING

### Pattern Names in Database:
Use these exact strings in `pattern_relevance` array:

```javascript
'balanced'              // 陰陽平衡
'yin_deficiency'        // 陰虛
'yang_deficiency'       // 陽虛
'yin_def_yang_excess'   // 陰虛陽亢
'yang_def_yin_excess'   // 陽虛陰盛
'mixed'                 // 混合型
```

### Which Images to Show:
- **Balanced:** No acupoint images (patient is healthy)
- **Yin Deficiency:** Show cooling, nourishing points
- **Yang Deficiency:** Show warming, tonifying points
- **Mixed Patterns:** Show combination of relevant points

---

## 🐛 TROUBLESHOOTING

### Error: "Failed to fetch"
- Check if Supabase URL is correct
- Verify anon key is valid
- Check browser console for CORS errors

### Error: "relation does not exist"
- Table name might be different
- Check exact table name in Supabase dashboard
- Ensure table is in `public` schema

### Error: "row-level security policy violation"
- Enable RLS policy (see Step 2)
- Create SELECT policy for public access

### Images Don't Load
- Check if image URLs are publicly accessible
- Test URL in browser directly
- Verify CORS settings on image host
- Check if Supabase Storage bucket is public

### Acupoints in Wrong Position
- Verify coordinate system (top-left origin)
- Check if image was resized (coordinates won't match)
- Use percentages instead of pixels if images vary in size

---

## 📋 CHECKLIST BEFORE DEPLOYMENT

- [ ] Supabase credentials added to HTML file
- [ ] `tcm_body_images` table created
- [ ] RLS policies configured
- [ ] Sample data inserted and tested
- [ ] Images uploaded to Supabase Storage
- [ ] Image URLs are publicly accessible
- [ ] Acupoint coordinates verified
- [ ] Pattern relevance correctly mapped
- [ ] Test query returns data successfully
- [ ] Browser console shows no errors

---

## 🚀 DEPLOYMENT SNIPPET

Replace these lines in your HTML (around line 50-55):

```javascript
// BEFORE (placeholder values)
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';

// AFTER (your actual values)
const SUPABASE_URL = 'https://xxxxxxxxxxxxx.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4eHh4eHh4eHh4eHgiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTYzMjE1MjYwMCwiZXhwIjoxOTQ3NzI4NjAwfQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
```

Test immediately after updating!

---

## 📞 NEED HELP?

If you're stuck:
1. Check Supabase documentation: https://supabase.com/docs
2. Test queries in Supabase SQL Editor
3. Use browser DevTools Network tab to debug
4. Share error messages with developer community

---

**Estimated Time to Complete:** 30-60 minutes (if images and data are ready)

Good luck! 🎉
