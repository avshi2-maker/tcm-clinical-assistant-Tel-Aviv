# Step-by-Step Translation Guide

## 📋 STEP 1: Download Files from Claude

Download these 4 files from Claude (they're in the outputs):

1. ✅ `translate_offline.py` - The translation script
2. ✅ `dr_roni_points_to_translate.json` - Test data (3 points)
3. ✅ `upload_translations.py` - For uploading to Supabase later
4. ✅ `READY_TO_TRANSLATE.md` - Full documentation

**Where to save them:**
```
C:\tcm-clinical-assistant-Tel-Aviv\
```

---

## 📋 STEP 2: Install Python Package

Open **Command Prompt** or **PowerShell** and run:

```bash
pip install google-generativeai
```

**Expected output:**
```
Successfully installed google-generativeai-...
```

**If you get an error**, try:
```bash
python -m pip install google-generativeai
```

---

## 📋 STEP 3: Verify Files Are in Place

In Command Prompt, navigate to your directory:

```bash
cd C:\tcm-clinical-assistant-Tel-Aviv
dir
```

**You should see:**
- translate_offline.py
- dr_roni_points_to_translate.json
- upload_translations.py

---

## 📋 STEP 4: Run Test Translation (3 Points)

Still in the same directory, run:

```bash
python translate_offline.py
```

**What happens:**
1. Script loads 3 test points
2. Connects to Gemini API
3. Translates each point to Hebrew (takes ~15 seconds total)
4. Saves results to `dr_roni_translations_hebrew.json`

**You'll see output like:**
```
🚀 OFFLINE DR. RONI TRANSLATION
✅ Loaded 3 points from dr_roni_points_to_translate.json
⏳ Need translation: 3 points
Press Enter to start translation...

📍 Point 1/3: Bl1 - Bright Eyes
  🔄 Translating (attempt 1/3)...
  ✅ Translated successfully!
  💾 Saved to dr_roni_translations_hebrew.json

📍 Point 2/3: Bl2 - Bamboo Gathering
  🔄 Translating (attempt 1/3)...
  ✅ Translated successfully!
  💾 Saved to dr_roni_translations_hebrew.json

📍 Point 3/3: Bl3 - Eyebrows Ascension
  🔄 Translating (attempt 1/3)...
  ✅ Translated successfully!
  💾 Saved to dr_roni_translations_hebrew.json

🎉 TRANSLATION COMPLETE!
✅ Total translations: 3 points
```

---

## 📋 STEP 5: Check the Results

Open the results file:

```bash
type dr_roni_translations_hebrew.json
```

Or open it in Notepad/VS Code to see the Hebrew translations.

**You should see Hebrew text like:**
- chinese_pinyin_hebrew: "ג'ינג מינג"
- english_name_hebrew: "עיניים בהירות"
- location_hebrew: "1 פן מהפינה המדיאלית של העין"
- etc.

---

## 📋 STEP 6: Export Full Dataset from Supabase

**IMPORTANT:** The test only translated 3 points. For the full 313 points:

### Option A: When Supabase Works (Best Option)
1. Open Supabase dashboard in browser
2. Go to SQL Editor
3. Run this query (NO backticks):
   ```
   SELECT * FROM dr_roni_complete ORDER BY point_code;
   ```
4. Click "Download CSV"
5. Save as `dr_roni_complete.csv`
6. Run: `python csv_to_json.py` (if you have this script)
7. This creates the full dataset JSON

### Option B: Use Manual Export from Browser
1. Go to your Supabase project
2. Table Editor → dr_roni_complete
3. Export to JSON
4. Save as `dr_roni_points_to_translate.json` (replace the test file)

---

## 📋 STEP 7: Translate Full Dataset

Once you have the full 313 points in `dr_roni_points_to_translate.json`:

```bash
python translate_offline.py
```

**This will take approximately 40 minutes** (5 seconds per point × 313 points)

**Progress updates every 10 points:**
```
📊 Progress: 10/313 (3.2%)
⏱️  Elapsed: 0.8 min | Remaining: ~25.2 min
```

**The script saves after EACH point**, so if it crashes, you can just run it again and it will resume from where it stopped.

---

## 📋 STEP 8: Upload to Supabase (When Connection Works)

After translation is complete, upload to database:

```bash
python upload_translations.py
```

This will:
1. Read `dr_roni_translations_hebrew.json`
2. Connect to Supabase
3. Update each point's Hebrew fields
4. Show progress as it uploads

---

## 🚨 Troubleshooting

### Error: "Cannot find dr_roni_points_to_translate.json"
**Solution:** Make sure you're in the correct directory:
```bash
cd C:\tcm-clinical-assistant-Tel-Aviv
```

### Error: "No module named 'google.generativeai'"
**Solution:** Install the package:
```bash
pip install google-generativeai
```

### Error: "Rate limit exceeded"
**Solution:** The script will automatically wait 60 seconds and retry. Just let it run.

### Error: "API key invalid"
**Solution:** Check that the API key in translate_offline.py is correct:
```python
GEMINI_API_KEY = "AIzaSyDbdRLN5bsxh3QxwYPwc6e6A8FNLWs1MQ0"
```

### Translation produces gibberish
**Solution:** Make sure your terminal supports UTF-8. In PowerShell:
```powershell
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
```

---

## ✅ Success Checklist

- [ ] Downloaded 4 files from Claude
- [ ] Installed google-generativeai package
- [ ] Files are in C:\tcm-clinical-assistant-Tel-Aviv\
- [ ] Ran test translation (3 points) successfully
- [ ] Verified Hebrew translations look correct
- [ ] Exported full 313 points from Supabase
- [ ] Ran full translation (40 minutes)
- [ ] Uploaded results to Supabase

---

## 💡 Tips

1. **Run test first** - Always verify with 3 points before running full dataset
2. **Don't interrupt** - Script saves progress, but let it complete if possible
3. **Check costs** - Gemini Flash is very cheap (~$0.15 for 313 points)
4. **Backup results** - Copy dr_roni_translations_hebrew.json somewhere safe
5. **Resume works** - If script stops, just run it again - it skips already-translated points

---

## 📞 Need Help?

If stuck, check:
1. Is Python installed? `python --version`
2. Is package installed? `pip list | findstr google`
3. Are files in the right place? `dir`
4. Is internet working? (needed for Gemini API)

