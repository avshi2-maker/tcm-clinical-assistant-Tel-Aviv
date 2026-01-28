# 🚀 QUICK REFERENCE GUIDE - Deep Thinking Search

## ⚡ DAILY USE

### How to Search
1. Go to: https://avshi2-maker.github.io/tcm-clinical-assistant-Tel-Aviv/
2. Find blue box "🧠 חשיבה עמוקה"
3. Select category dropdown
4. Type search term
5. Click "חפש"

### Working Categories
✅ **נקודות דיקור** (Acupuncture Points) - 53 points
✅ **תסמונות** (Syndromes) - 313 syndromes

### Search Tips
- Works in Hebrew OR English
- Case-insensitive
- Searches names, symptoms, indications
- Shows max 10 results

---

## 🔧 IF SOMETHING BREAKS

### Problem: No results
**Fix:** Check spelling, try different terms

### Problem: Error message
**Fix:** Refresh page (Ctrl+F5)

### Problem: Module not working
**Contact:** Check GitHub or create issue

---

## 📝 TO UPDATE THE CODE

### Location
**File:** `C:\tcm-clinical-assistant-Tel-Aviv\index.html`
**Function:** `searchDeepThinking()` (line 587)

### Push Changes
```bash
cd /c/tcm-clinical-assistant-Tel-Aviv
git add index.html
git commit -m "Your message"
git push origin main
```

Wait 1-2 minutes for GitHub Pages to update.

---

## 📊 DATABASE INFO

**Supabase URL:** https://iqfglrwjemogoycbzltt.supabase.co

### Tables
- `acupuncture_points` - 53 records
- `zangfu_syndromes` - 313 records

### Column Names (Important!)
**Acupuncture Points:**
- `point_name` (e.g., "LI4")
- `hebrew_name`
- `indication`

**Syndromes:**
- `name_en` (English name)
- `name_he` (Hebrew name)
- `symptoms_he`
- `treatment_he`

---

## 🎯 FUTURE FEATURES TO ADD

1. **Voice Input** - Web Speech API
2. **AI Analysis** - Claude API integration
3. **More Categories** - Herbs, treatments, theory
4. **Export Reports** - PDF generation

---

**Quick Support:** Check HANDOVER_REPORT.md for full details
