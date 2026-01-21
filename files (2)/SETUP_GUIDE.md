# BODY IMAGES IMPLEMENTATION - SETUP GUIDE
**For: Yin-Yang Questionnaire Enhanced Version**

---

## ✅ WHAT'S NEW IN THIS VERSION

I've successfully added the body images with acupoint overlays feature! Here's what's been implemented:

### New Features:
1. **Automatic Body Image Loading** - Queries Supabase `tcm_body_images` table based on the diagnosed pattern
2. **Acupoint Dot Overlays** - Red dots appear on images at specified coordinates
3. **Interactive Tooltips** - Hover over dots to see acupoint codes and Chinese names
4. **Responsive Grid Layout** - Images display in a beautiful grid that adapts to screen size
5. **Legend for Each Image** - Lists all acupoints shown in each body part image
6. **Professional Styling** - Blue gradient background, hover effects, and clean design

---

## 🗄️ DATABASE SETUP

You need to add data to your `tcm_body_images` table. Here's how:

### Step 1: Create the Table (if not exists)

Go to Supabase SQL Editor and run:

```sql
-- Create table
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
CREATE POLICY "Allow public read access" 
ON tcm_body_images 
FOR SELECT 
TO public 
USING (true);
```

### Step 2: Prepare Your Images

You need body part images. You can:

**Option A: Use Free TCM Body Images**
- Search for "acupuncture body chart" images
- Use sites like Pixabay, Unsplash (royalty-free)
- Or create simple body outlines in Canva

**Option B: Upload to Supabase Storage**
1. In Supabase Dashboard → Storage
2. Create a bucket called `tcm-images` (make it **public**)
3. Upload your images
4. Copy the public URL for each image

Example URL format:
```
https://iqfglrwjemogoycbzltt.supabase.co/storage/v1/object/public/tcm-images/hand_dorsal.jpg
```

### Step 3: Find Acupoint Coordinates

Open your image in an image editor and note pixel positions:

1. Open image in Photoshop, GIMP, Paint.NET, or even MS Paint
2. Hover cursor over acupoint location
3. Note X,Y coordinates (bottom-left of most editors)
4. Write them down

**Example:**
- Image size: 800px × 600px
- LI4 (合谷) is at position X=245, Y=180
- SI3 (后溪) is at position X=310, Y=220

---

## 📝 SAMPLE DATA TO INSERT

Here's complete sample data you can insert right now to test:

```sql
-- Sample 1: Hand (Dorsal View)
INSERT INTO tcm_body_images (
  body_part, 
  image_url, 
  acupoint_codes, 
  acupoint_coordinates, 
  pattern_relevance
) VALUES (
  'hand_dorsal',
  'https://images.unsplash.com/photo-1517398823963-c2dc6fc3e837?w=800',
  ARRAY['LI4', 'SI3', 'TB3', 'LI5'],
  '{
    "LI4": {"x": 245, "y": 180, "name": "合谷 - Hegu"},
    "SI3": {"x": 310, "y": 220, "name": "后溪 - Houxi"},
    "TB3": {"x": 290, "y": 160, "name": "中渚 - Zhongzhu"},
    "LI5": {"x": 260, "y": 140, "name": "阳溪 - Yangxi"}
  }'::jsonb,
  ARRAY['yin_deficiency', 'yang_deficiency', 'mixed']
);

-- Sample 2: Foot (Medial View)
INSERT INTO tcm_body_images (
  body_part, 
  image_url, 
  acupoint_codes, 
  acupoint_coordinates, 
  pattern_relevance
) VALUES (
  'foot_medial',
  'https://images.unsplash.com/photo-1595508064774-5ff825ff0f81?w=800',
  ARRAY['SP6', 'KI3', 'LR3', 'KI6'],
  '{
    "SP6": {"x": 180, "y": 240, "name": "三阴交 - Sanyinjiao"},
    "KI3": {"x": 210, "y": 280, "name": "太溪 - Taixi"},
    "LR3": {"x": 350, "y": 420, "name": "太冲 - Taichong"},
    "KI6": {"x": 195, "y": 295, "name": "照海 - Zhaohai"}
  }'::jsonb,
  ARRAY['yin_deficiency', 'yin_def_yang_excess']
);

-- Sample 3: Abdomen
INSERT INTO tcm_body_images (
  body_part, 
  image_url, 
  acupoint_codes, 
  acupoint_coordinates, 
  pattern_relevance
) VALUES (
  'abdomen',
  'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
  ARRAY['CV4', 'CV6', 'ST25', 'CV12'],
  '{
    "CV4": {"x": 300, "y": 340, "name": "关元 - Guanyuan"},
    "CV6": {"x": 300, "y": 300, "name": "气海 - Qihai"},
    "ST25": {"x": 260, "y": 320, "name": "天枢 - Tianshu"},
    "CV12": {"x": 300, "y": 220, "name": "中脘 - Zhongwan"}
  }'::jsonb,
  ARRAY['yang_deficiency', 'yang_def_yin_excess', 'mixed']
);

-- Sample 4: Lower Back
INSERT INTO tcm_body_images (
  body_part, 
  image_url, 
  acupoint_codes, 
  acupoint_coordinates, 
  pattern_relevance
) VALUES (
  'back',
  'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800',
  ARRAY['BL23', 'BL20', 'GV4', 'BL52'],
  '{
    "BL23": {"x": 280, "y": 280, "name": "肾俞 - Shenshu"},
    "BL20": {"x": 280, "y": 220, "name": "脾俞 - Pishu"},
    "GV4": {"x": 300, "y": 300, "name": "命门 - Mingmen"},
    "BL52": {"x": 250, "y": 310, "name": "志室 - Zhishi"}
  }'::jsonb,
  ARRAY['yang_deficiency', 'mixed']
);

-- Sample 5: Leg Anterior (for Yang patterns)
INSERT INTO tcm_body_images (
  body_part, 
  image_url, 
  acupoint_codes, 
  acupoint_coordinates, 
  pattern_relevance
) VALUES (
  'leg_anterior',
  'https://images.unsplash.com/photo-1434682772747-f16d3ea162c3?w=800',
  ARRAY['ST36', 'ST40', 'SP9', 'GB34'],
  '{
    "ST36": {"x": 220, "y": 380, "name": "足三里 - Zusanli"},
    "ST40": {"x": 210, "y": 450, "name": "丰隆 - Fenglong"},
    "SP9": {"x": 260, "y": 420, "name": "阴陵泉 - Yinlingquan"},
    "GB34": {"x": 240, "y": 400, "name": "阳陵泉 - Yanglingquan"}
  }'::jsonb,
  ARRAY['yin_def_yang_excess', 'yang_excess', 'mixed']
);
```

**IMPORTANT NOTES:**
- The image URLs above are placeholder Unsplash photos - they're NOT actual TCM body diagrams
- Replace these URLs with your own body part images
- The coordinates are examples - you'll need to adjust them for your actual images
- The Chinese names are authentic acupoint names

---

## 🧪 TESTING THE FEATURE

### Step 1: Insert Sample Data
Run the SQL above in Supabase SQL Editor

### Step 2: Open Your Enhanced HTML File
Open the `index.html` file in a web browser

### Step 3: Take the Questionnaire
1. Click "שאלון יין-יאנג" button
2. Answer all 11 questions
3. Click the purple submit button
4. Scroll down on results page

### Step 4: Verify Body Images Appear
You should see:
- A blue section titled "נקודות דיקור רלוונטיות"
- Grid of body part images
- Red dots on each image
- Hover over dots to see tooltips with acupoint names
- Legend below each image listing all points

### What to Check:
✅ Images load successfully
✅ Red dots appear at correct positions
✅ Tooltips show on hover
✅ Legend lists all acupoints
✅ Different patterns show different images
✅ No JavaScript errors in browser console (F12)

---

## 🐛 TROUBLESHOOTING

### Issue: No Images Appear
**Possible Causes:**
1. No data in `tcm_body_images` table → Insert sample data
2. Pattern name mismatch → Check console for pattern name
3. Database connection issue → Check Supabase credentials

**Solution:**
```javascript
// Open browser console (F12) and check:
console.log('Pattern detected:', pattern);
console.log('Querying for:', dbPattern);

// Then manually test the query:
const test = await supabaseClient
  .from('tcm_body_images')
  .select('*')
  .contains('pattern_relevance', ['yin_deficiency']);
console.log('Test query result:', test);
```

### Issue: Dots Appear in Wrong Positions
**Solution:**
The coordinates need to match your actual image. To fix:
1. Open your image in an editor
2. Find the exact pixel position of each acupoint
3. Update the coordinates in the database

### Issue: Images Don't Load (404 Error)
**Solution:**
1. Check if image URLs are publicly accessible
2. Try opening image URL directly in browser
3. If using Supabase Storage, ensure bucket is public
4. Check CORS settings if images are from external domain

---

## 📐 HOW TO MAP YOUR OWN COORDINATES

### Method 1: Using Photoshop/GIMP
1. Open image
2. Enable "Info" panel (Window → Info)
3. Hover cursor → see X,Y coordinates
4. Note them down

### Method 2: Using Free Online Tool
1. Go to https://www.image-map.net/
2. Upload your image
3. Click "Rectangle" tool
4. Click on acupoint locations
5. Copy the coordinates from generated code

### Method 3: Using Browser DevTools
1. Add image to HTML with this code:
```html
<img src="your-image.jpg" onclick="console.log(event.offsetX, event.offsetY)" />
```
2. Open browser console (F12)
3. Click on acupoint locations
4. Console shows X,Y coordinates

---

## 🎨 CUSTOMIZATION OPTIONS

### Change Dot Color
In the CSS section (line ~120), change:
```css
circle.setAttribute('fill', '#ef4444'); /* Red */
```
To:
```css
circle.setAttribute('fill', '#3b82f6'); /* Blue */
circle.setAttribute('fill', '#10b981'); /* Green */
circle.setAttribute('fill', '#f59e0b'); /* Amber */
```

### Change Dot Size
```css
circle.setAttribute('r', '8'); /* Default: 8px radius */
```
Change to `'10'` for larger, `'6'` for smaller

### Add Pulsing Animation
Add to CSS:
```css
@keyframes pulse {
  0%, 100% { opacity: 0.85; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.2); }
}

.acupoint-dot {
  animation: pulse 2s ease-in-out infinite;
}
```

---

## 📊 PATTERN TO IMAGES MAPPING

Based on the code, here's which patterns show which images:

| Pattern | Database Value | Recommended Body Parts |
|---------|----------------|------------------------|
| Yin Deficiency | `yin_deficiency` | Hand dorsal, Foot medial, Lower back |
| Yang Deficiency | `yang_deficiency` | Abdomen, Lower back, Hand dorsal |
| Balanced | `balanced` | (Usually none - patient is healthy) |
| Yin Def + Yang Excess | `yin_def_yang_excess` | Foot medial, Leg anterior |
| Yang Def + Yin Excess | `yang_def_yin_excess` | Abdomen, Lower back |
| Mixed | `mixed` | Hand dorsal, Leg anterior, Lower back |

---

## 🚀 PRODUCTION CHECKLIST

Before going live:
- [ ] Replace placeholder images with real TCM body diagrams
- [ ] Verify all acupoint coordinates are accurate
- [ ] Test on mobile devices (responsive layout)
- [ ] Verify Supabase RLS policies are correct
- [ ] Add print-friendly CSS for body images
- [ ] Test with all 6 pattern types
- [ ] Verify tooltips work on touch devices
- [ ] Check loading performance with multiple images
- [ ] Add fallback message if images fail to load
- [ ] Document acupoint selection rationale for practitioners

---

## 🎯 NEXT STEPS

1. **Get Real Images:** Find or create proper TCM body diagrams
2. **Upload to Supabase Storage:** Store images in your Supabase project
3. **Map Coordinates:** Carefully map each acupoint position
4. **Test Thoroughly:** Try all patterns and verify accuracy
5. **Gather Feedback:** Show to TCM practitioners for validation

---

## 💡 ADVANCED FEATURES (Future Enhancements)

Consider adding:
- **Zoom functionality** on images
- **Acupoint descriptions** (not just names)
- **Treatment protocols** for each point
- **Multiple image angles** for same body part
- **3D body model** (using Three.js)
- **Print-optimized view** for clinical use
- **Export to PDF** with images included

---

**Your enhanced version is ready to test! Good luck! 🎉**

Let me know if you encounter any issues or need help setting up the database.
