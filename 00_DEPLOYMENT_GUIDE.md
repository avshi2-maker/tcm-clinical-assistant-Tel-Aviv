# 🏗️ TCM CLINICAL ASSISTANT - FOUNDATION DEPLOYMENT GUIDE

## 📋 **COMPLETE DEPLOYMENT CHECKLIST**

---

## 🎯 **WHAT YOU'RE BUILDING:**

A complete RAG foundation with:
1. ✅ **Assets Priority Table** - Smart routing of all search assets
2. ✅ **Body Figures Module** - Standalone visual diagrams in Supabase
3. ✅ **Smart Search API** - Multi-query edge function with token management

---

## 📦 **FILES CREATED:**

| File | Purpose |
|------|---------|
| `01_create_search_assets_table.sql` | Create assets priority registry |
| `02_create_body_figures_module.sql` | Create body figures module |
| `03_upload_body_figures.py` | Upload images to Supabase Storage |
| `04_smart_search_edge_function.ts` | Edge Function for search API |

---

## 🚀 **DEPLOYMENT STEPS:**

### **STEP 1: Create Supabase Tables** (5 minutes)

1. **Go to Supabase Dashboard:**
   ```
   https://supabase.com/dashboard/project/iqfglrwjemogoycbzltt
   ```

2. **Click: SQL Editor → New Query**

3. **Run First SQL Script:**
   - Copy contents of `01_create_search_assets_table.sql`
   - Paste into SQL Editor
   - Click **RUN**
   - ✅ Should see: "Search Assets table created successfully!"

4. **Run Second SQL Script:**
   - Copy contents of `02_create_body_figures_module.sql`
   - Paste into SQL Editor
   - Click **RUN**
   - ✅ Should see: "Body Figures module created successfully!"

5. **Verify Tables Created:**
   - Click: **Table Editor** (left sidebar)
   - You should see:
     - ✅ `search_assets` (7 rows)
     - ✅ `search_routing_rules` (5 rows)
     - ✅ `body_figures` (5 rows)
     - ✅ `acupoint_mappings` (2 rows)
     - ✅ `figure_symptom_links` (2 rows)

---

### **STEP 2: Create Storage Bucket** (2 minutes)

1. **In Supabase Dashboard:**
   - Click: **Storage** (left sidebar)
   - Click: **New Bucket**

2. **Create Bucket:**
   - Name: `body-figures`
   - Public: ✅ **YES** (check the box)
   - File size limit: `10MB`
   - Allowed MIME types: 
     - `image/png`
     - `image/jpeg`
     - `image/jpg`
     - `image/svg+xml`
   - Click: **Create Bucket**

3. **Verify:**
   - You should see `body-figures` in Storage list

---

### **STEP 3: Prepare Body Figure Images** (10 minutes)

1. **Create folder on your computer:**
   ```
   C:\body_figures_images\
   ```

2. **Put your body figure images in this folder**
   - Recommended format: PNG or JPG
   - Recommended size: 800-1500px width

3. **Name your files clearly:**
   ```
   full_body_front.png
   full_body_back.png
   head_face_front.png
   arm_hand_side.png
   leg_foot_side.png
   ... (add more as you have)
   ```

4. **Edit the upload script:**
   - Open: `03_upload_body_figures.py`
   - Find the `FIGURE_MAPPING` section (around line 18)
   - Update to match YOUR filenames:
   ```python
   FIGURE_MAPPING = {
       "your_actual_filename.png": "full_body_anterior",
       "another_filename.png": "head_face_anterior",
       # ... add all your files
   }
   ```

---

### **STEP 4: Upload Images** (5 minutes)

1. **Install Supabase Python library:**
   ```bash
   pip install supabase
   ```

2. **Run the upload script:**
   ```bash
   cd path\to\folder\with\scripts
   python 03_upload_body_figures.py C:\body_figures_images
   ```

3. **Watch the upload:**
   ```
   ✅ Created bucket: body-figures
   📤 Uploading: full_body_front.png
     ✅ Uploaded: full_body_front.png
     ✅ Updated database for: full_body_anterior
   ...
   ✅ UPLOAD COMPLETE!
   📤 Images uploaded: 5
   💾 Database updated: 5
   ```

4. **Verify in Supabase:**
   - Dashboard → Storage → `body-figures`
   - You should see your uploaded images organized by figure name

5. **Verify database updated:**
   - Dashboard → Table Editor → `body_figures`
   - Check `image_url` column is filled with Storage URLs

---

### **STEP 5: Deploy Edge Function** (10 minutes)

1. **Install Supabase CLI:**
   ```bash
   npm install -g supabase
   ```

2. **Login to Supabase:**
   ```bash
   supabase login
   ```

3. **Link to your project:**
   ```bash
   supabase link --project-ref iqfglrwjemogoycbzltt
   ```

4. **Create Edge Function:**
   ```bash
   supabase functions new smart-search
   ```

5. **Replace the function code:**
   - Copy contents of `04_smart_search_edge_function.ts`
   - Paste into: `supabase/functions/smart-search/index.ts`

6. **Deploy:**
   ```bash
   supabase functions deploy smart-search
   ```

7. **Get the URL:**
   - After deployment, you'll see:
   ```
   ✅ Deployed Function smart-search
   URL: https://iqfglrwjemogoycbzltt.supabase.co/functions/v1/smart-search
   ```

8. **Copy this URL** - you'll need it for your website!

---

### **STEP 6: Test the System** (5 minutes)

#### **Test 1: Check Tables**

In Supabase SQL Editor:
```sql
-- Check assets
SELECT asset_name_hebrew, priority_level, is_active 
FROM search_assets 
ORDER BY priority_level;

-- Check figures
SELECT figure_name_hebrew, image_url IS NOT NULL as has_image 
FROM body_figures;

-- Check symptom links
SELECT symptom_hebrew, array_length(acupoint_codes, 1) as num_points
FROM figure_symptom_links;
```

#### **Test 2: Test Edge Function**

Using `curl` or Postman:
```bash
curl -X POST \
  https://iqfglrwjemogoycbzltt.supabase.co/functions/v1/smart-search \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ANON_KEY" \
  -d '{
    "queries": ["כאב ראש"],
    "maxResults": 5
  }'
```

You should get:
```json
{
  "success": true,
  "queries": ["כאב ראש"],
  "results": [
    {
      "assetName": "qa_knowledge_base",
      "results": [...],
      "tokensUsed": 0,
      "responseMs": 150
    },
    {
      "assetName": "body_figures",
      "results": [...],
      "tokensUsed": 0,
      "responseMs": 80
    }
  ],
  "totalResults": 8,
  "tokensUsed": 0,
  "searchTimeMs": 250
}
```

---

## ✅ **VERIFICATION CHECKLIST:**

After deployment, verify:

- [ ] **Database Tables:**
  - [ ] `search_assets` has 7 rows
  - [ ] `body_figures` has 5+ rows
  - [ ] `acupoint_mappings` has data
  - [ ] `figure_symptom_links` has data

- [ ] **Storage:**
  - [ ] `body-figures` bucket exists
  - [ ] Images uploaded successfully
  - [ ] `body_figures.image_url` populated

- [ ] **Edge Function:**
  - [ ] Deployed successfully
  - [ ] Test query returns results
  - [ ] No errors in logs

---

## 🎯 **WHAT YOU NOW HAVE:**

### **1. Smart Asset Routing:**
```
User Query: "כאב ראש"
    ↓
Edge Function checks routing rules
    ↓
Priority Order:
  1️⃣ qa_knowledge_base (FREE)
  2️⃣ body_figures (FREE)
  3️⃣ tcm_hebrew_qa (FREE)
  4️⃣ yinyang_assessment (FREE)
  5️⃣ deep_thinking (COSTS TOKENS)
    ↓
Returns combined results
```

### **2. Body Figures Module:**
- Symptom → Relevant body diagrams
- Visual acupoint locations
- Treatment recommendations
- All stored in Supabase (not in HTML!)

### **3. Token Management:**
- Free searches: Priority 1-4
- Paid searches: Priority 5+ (Gemini)
- Automatic token deduction
- Usage tracking

---

## 🔧 **NEXT STEPS:**

### **A. Add More Body Figures:**
1. Add more images to folder
2. Update `FIGURE_MAPPING` in upload script
3. Run upload script again
4. Figures auto-update in database

### **B. Add More Acupoints:**
```sql
INSERT INTO acupoint_mappings (...) VALUES (...);
```

### **C. Add More Symptom Links:**
```sql
INSERT INTO figure_symptom_links (...) VALUES (...);
```

### **D. Integrate with Website:**
```javascript
// In your HTML
async function searchMultiQuery(queries) {
  const response = await fetch(
    'https://iqfglrwjemogoycbzltt.supabase.co/functions/v1/smart-search',
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      },
      body: JSON.stringify({
        queries: queries,
        userId: currentUser.id,
        useDeepSearch: false,
        maxResults: 10
      })
    }
  )
  
  const data = await response.json()
  displayResults(data.results)
}
```

---

## 🐛 **TROUBLESHOOTING:**

### **SQL Errors:**
- **"relation already exists"** → Tables already created, skip or DROP first
- **"permission denied"** → Use Service Role key in SQL Editor

### **Upload Errors:**
- **"bucket not found"** → Create `body-figures` bucket first
- **"file not found"** → Check `FIGURE_MAPPING` paths

### **Edge Function Errors:**
- **"function not found"** → Redeploy with `supabase functions deploy`
- **"CORS error"** → Check `corsHeaders` in function code

---

## 📞 **SUPPORT:**

If you get stuck:
1. Check Supabase logs: Dashboard → Edge Functions → Logs
2. Check browser console for errors
3. Verify all tables exist in Table Editor

---

## 🎉 **SUCCESS CRITERIA:**

You're done when:
✅ All SQL tables created
✅ Body figures uploaded to Storage
✅ Edge Function deployed and tested
✅ Test query returns results from multiple assets
✅ Body figures appear in search results

---

**YOU'VE BUILT A PRODUCTION-READY RAG FOUNDATION!** 🎊

Next: Connect your website to the Edge Function! 🚀
