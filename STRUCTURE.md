# 📐 CODE STRUCTURE - TCM Clinical Assistant

**Version:** 1.0.0 IRONCLAD BASELINE  
**Total Lines:** 4562  
**File:** index.html

---

## 🗺️ **FILE MAP - EXACT LINE NUMBERS**

```
index.html (4562 lines)
│
├── HEAD SECTION (Lines 1-503)
│   ├── Meta tags (1-7)
│   ├── External libraries (8-9)
│   │   ├── Tailwind CSS
│   │   └── Supabase JS
│   └── CSS Styles (10-503)
│       ├── Panel layouts
│       ├── Component styles
│       ├── Animations
│       └── Custom classes
│
├── BODY START (Line 504)
│
├── 🔒 LEFT PANEL - 450 Questions (Lines 527-570)
│   │   ⚠️ PROTECTED - Screen RIGHT side
│   ├── Header (527-530)
│   ├── Category Dropdown (531-566)
│   │   └── 30 categories × 15 questions
│   └── Questions Container (569)
│       └── Populated by JavaScript
│
├── ⚠️ CENTER PANEL - Main Area (Lines 572-783)
│   │   MODIFIABLE - Safe to change
│   ├── Metrics Bar (574-633)
│   │   ├── Cost counter
│   │   ├── Timer
│   │   ├── Token count
│   │   └── Control buttons
│   ├── Blue Header (635-638)
│   │   └── Thin version ✅
│   ├── Main Content (653-793)
│   │   ├── Query Boxes (656-717)
│   │   │   ├── Query 1 (required)
│   │   │   ├── Query 2 (optional)
│   │   │   ├── Query 3 (optional)
│   │   │   └── Query 4 (voice)
│   │   ├── Buttons (719-736)
│   │   ├── Results Area (760)
│   │   └── Share Buttons (763-778)
│   └

── Status displays
│
├── 🔒 RIGHT PANEL - Clinical Modules (Lines 784-900)
│   │   ⚠️ PROTECTED - Screen LEFT side
│   ├── Header (798-800)
│   ├── Module 1: DR Roni (802-815)
│   │   └── 341 acupuncture points
│   ├── Module 2: Zang-Fu (817-830)
│   │   └── 11 syndromes
│   ├── Module 3: Clinical Symptoms (832-845)
│   │   └── 52 symptom questions
│   ├── Module 4: Pulse Gallery (847-856)
│   ├── Module 5: Yin-Yang (858-868)
│   └── Module 6: Training (870-900)
│
├── JAVASCRIPT SECTION (Lines 901-4562)
│   ├── Supabase Init (1850-1855)
│   ├── Core Functions (1900-2500)
│   │   ├── loadQuestions()
│   │   ├── performMultiQuery()
│   │   ├── displaySearchResults()
│   │   └── shareButtons functions
│   ├── Clinical Module Functions (4300-4550)
│   │   ├── toggleDrRoniPoints()
│   │   ├── loadDrRoniPoints()
│   │   ├── toggleZangFuSyndromes()
│   │   └── selectClinicalItem()
│   └── Yin-Yang Module (2600-4300)
│       └── Complete questionnaire system
│
└── CLOSING TAGS (4560-4562)
```

---

## 🔒 **PROTECTED SECTIONS - DETAILED**

### **1. LEFT PANEL (Lines 527-570)**

#### **Structure:**
```html
<div class="left-panel bg-gray-50 border-r">
    <!-- Header -->
    <div class="p-4 bg-gradient-to-r from-blue-600">
        <h3>📚 450 שאלות מוכנות</h3>
    </div>
    
    <!-- Category Filter -->
    <div class="p-3">
        <select id="categoryFilter" onchange="filterQuestions()">
            <option value="all">כל הקטגוריות (450)</option>
            <option value="אבחון דופק ולשון">אבחון דופק ולשון (15)</option>
            <!-- ... 28 more categories ... -->
        </select>
    </div>
    
    <!-- Questions Container -->
    <div id="quickQuestions" class="p-3 space-y-2" 
         style="max-height: 280px; overflow-y: auto;">
        <!-- Loaded by JavaScript -->
    </div>
</div>
```

#### **JavaScript Functions:**
```javascript
// Lines ~1900-2000
async function loadAllQuestions() { ... }
function filterQuestions() { ... }
function displayQuestions(questions) { ... }
function quickSearch(query) { ... }
```

#### **Why Protected:**
- Users click these daily
- Filtering logic is complex
- Any bug breaks workflow
- 450 questions loaded from Supabase

#### **CSS Dependencies:**
```css
.left-panel {
    width: 280px;
    height: 100vh;
    overflow-y: auto;
}

.quick-question {
    padding: 12px;
    border: 2px solid #e5e7eb;
    cursor: pointer;
    /* hover effects */
}
```

---

### **2. RIGHT PANEL (Lines 784-900)**

#### **Structure:**
```html
<div class="right-panel bg-gray-50 border-l">
    <!-- Header -->
    <div class="p-4 bg-gradient-to-r from-purple-600">
        <h3>🎯 מודולים קליניים</h3>
    </div>
    
    <!-- Module 1: DR Roni -->
    <div class="p-4 bg-gradient-to-br from-blue-500">
        <h4>📍 נקודות דיקור</h4>
        <p>341 נקודות • 14 מרידיאנים</p>
        <button onclick="toggleDrRoniPoints()">
            <span id="drRoniToggle">🔽</span> פתח מאגר
        </button>
        <div id="drRoniDropdown" class="hidden">
            <!-- Loaded by JavaScript -->
        </div>
    </div>
    
    <!-- Module 2: Zang-Fu -->
    <!-- Module 3: Symptoms -->
    <!-- Module 4: Pulse -->
    <!-- Module 5: Yin-Yang -->
    <!-- Module 6: Training -->
</div>
```

#### **JavaScript Functions:**
```javascript
// Lines ~4300-4550
async function toggleDrRoniPoints() { ... }
async function loadDrRoniPoints() { ... }
function displayDrRoniPoints(points) { ... }
async function loadZangFuSyndromes() { ... }
async function loadClinicalSymptoms() { ... }
function selectClinicalItem(code, text, id) { ... }
function addToQueryBox(text) { ... }
```

#### **Supabase Queries:**
```javascript
// DR Roni Points
const { data } = await supabaseClient
    .from('dr_roni_complete')
    .select('point_code, english_name_hebrew')
    .order('point_code')
    .limit(50);

// Zang-Fu Syndromes
const { data } = await supabaseClient
    .from('zangfu_syndromes')
    .select('syndrome_code, syndrome_name_he')
    .order('syndrome_code');

// Clinical Symptoms
const { data } = await supabaseClient
    .from('diagnostic_questions')
    .select('symptom_code, question_he, category')
    .order('category');
```

#### **Why Protected:**
- Complex dropdown logic
- Supabase integration working
- Selection flows to query boxes
- Any change breaks data flow

---

## ⚠️ **MODIFIABLE SECTION - CENTER PANEL**

### **Lines 572-783 - SAFE TO MODIFY**

#### **Current Structure:**
```html
<div class="flex-1 flex flex-col overflow-hidden">
    <!-- Metrics Bar (574-633) -->
    <div class="metrics-box flex justify-between">
        <!-- Cost, Timer, Tokens -->
    </div>
    
    <!-- Header (635-638) -->
    <div class="bg-gradient-to-r from-blue-600 py-3">
        <h1>קליניקה למטפל בדיקור...</h1>
    </div>
    
    <!-- Main Content (653-783) -->
    <div class="flex-1 overflow-y-auto p-6">
        <!-- Query Boxes -->
        <div class="space-y-3">
            <input id="searchInput1" />
            <input id="searchInput2" />
            <input id="searchInput3" />
            <input id="searchInput4" /> + Voice button
        </div>
        
        <!-- Buttons -->
        <button onclick="performMultiQuery()">🔍 הרץ חיפוש</button>
        
        <!-- Results -->
        <div id="searchResults"></div>
        
        <!-- Share Buttons -->
        <div id="shareButtons" class="hidden">
            <button onclick="downloadPDF()">💾 הורד PDF</button>
            <button onclick="emailReport()">📧 שלח במייל</button>
            <button onclick="shareWhatsApp()">📱 שתף בוואטסאפ</button>
            <button onclick="printReport()">🖨️ הדפס דוח</button>
        </div>
    </div>
</div>
```

#### **What You CAN Change:**
1. ✅ Add body diagram section
2. ✅ Split into 50/50 layout
3. ✅ Reorganize results display
4. ✅ Add new features
5. ✅ Improve styling

#### **What You MUST Keep:**
1. ⚠️ Query box IDs: `searchInput1-4`
2. ⚠️ Button onclick handlers
3. ⚠️ Results div ID: `searchResults`
4. ⚠️ Share buttons functionality

#### **Example Safe Modification:**
```html
<!-- ADD THIS: Body diagrams section -->
<div id="bodyDiagrams" class="mt-6 hidden">
    <h3>🧍 דיאגרמות גוף</h3>
    <div class="grid grid-cols-2 gap-4">
        <div>Front body diagram</div>
        <div>Back body diagram</div>
    </div>
</div>

<!-- KEEP: Original share buttons -->
<div id="shareButtons" class="hidden">
    <!-- Don't modify these -->
</div>
```

---

## 🎨 **CSS STRUCTURE**

### **Key Classes (Lines 10-503):**

```css
/* Panel Layouts */
.left-panel { width: 280px; }
.right-panel { width: 320px; }

/* Components */
.csv-box { /* CSV file indicators */ }
.query-box { /* Query input boxes */ }
.quick-question { /* 450 questions */ }
.clinical-item { /* Dropdown items */ }

/* Animations */
@keyframes glow { /* Active CSV glow */ }
@keyframes tick { /* Clock animation */ }

/* Yin-Yang Module */
.yin-yang-symbol { /* Complete styles */ }
```

### **Tailwind Classes Used:**
- `flex`, `flex-1`, `flex-col`
- `p-3`, `p-4`, `p-6`
- `bg-gradient-to-r`
- `rounded-lg`, `rounded-xl`
- `text-right` (RTL support)
- `hidden` (toggle visibility)

---

## 🔗 **DEPENDENCIES**

### **External Libraries:**

```html
<!-- Tailwind CSS -->
<script src="https://cdn.tailwindcss.com"></script>

<!-- Supabase JS Client -->
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
```

### **Supabase Tables Used:**
1. `dr_roni_complete` (341 points)
2. `zangfu_syndromes` (11 syndromes)
3. `diagnostic_questions` (52 symptoms)
4. `symptom_syndrome_mapping` (96 mappings)
5. `syndrome_treatment_points` (66 treatments)
6. `tcm_training_syllabus` (48 training items)

---

## 🧩 **KEY JAVASCRIPT FUNCTIONS**

### **Core Search Functions:**
```javascript
// Lines ~2092-2300
async function performMultiQuery() {
    // Main search execution
    // Calls searchMultipleQueries()
    // Displays results
}

async function searchMultipleQueries(queries) {
    // RAG search across CSV tables
    // Returns combined results
}

async function displaySearchResults(results) {
    // Formats and displays results
    // Shows CSV source indicators
}
```

### **Clinical Module Functions:**
```javascript
// Lines ~4300-4550
function toggleDrRoniPoints() {
    // Opens/closes DR Roni dropdown
}

async function loadDrRoniPoints() {
    // Loads 50 points from Supabase
    // Displays in dropdown
}

function selectClinicalItem(code, text, id) {
    // Handles item selection
    // Populates query box
}
```

### **Share Functions:**
```javascript
// Lines ~3500-3800
function downloadPDF() {
    // Generates PDF report
}

function emailReport() {
    // Opens email with report
}

function shareWhatsApp() {
    // Shares via WhatsApp
}

function printReport() {
    // Prints report
}
```

---

## 🎯 **MODIFICATION EXAMPLES**

### **✅ SAFE: Add Body Diagrams**

```html
<!-- In center panel, after searchResults div -->
<div id="bodyDiagrams" class="mt-6 hidden">
    <h3 class="text-lg font-bold text-right mb-4">
        🧍 דיאגרמות גוף ונקודות דיקור
    </h3>
    <div class="grid grid-cols-2 gap-4">
        <div class="bg-gray-100 rounded-lg p-4 min-h-[300px]">
            <!-- Front body SVG/image -->
        </div>
        <div class="bg-gray-100 rounded-lg p-4 min-h-[300px]">
            <!-- Back body SVG/image -->
        </div>
    </div>
</div>
```

**Add to JavaScript:**
```javascript
// In displaySearchResults(), add:
document.getElementById('bodyDiagrams').classList.remove('hidden');
```

### **✅ SAFE: Create 50/50 Split**

```html
<!-- Modify center panel main content -->
<div class="flex-1 flex flex-col p-6 gap-4">
    <!-- TOP 50%: Query boxes -->
    <div style="flex: 1; overflow-y: auto;">
        <!-- Move query boxes here -->
    </div>
    
    <!-- BOTTOM 50%: Results -->
    <div style="flex: 1; overflow-y: auto; background: #f9fafb;">
        <!-- Move results here -->
    </div>
</div>
```

### **❌ DANGEROUS: Don't Change**

```javascript
// DON'T change these IDs:
document.getElementById('searchInput1')  // Query boxes
document.getElementById('searchResults')  // Results area
document.getElementById('quickQuestions') // 450 questions

// DON'T modify these functions:
async function loadAllQuestions() { ... }  // Loads 450 questions
function toggleDrRoniPoints() { ... }      // Module dropdowns
```

---

## 📝 **CHANGE LOG FORMAT**

When making changes, document like this:

```markdown
### v1.1.0 - 2026-01-29 - Body Diagrams Added

**Changed:**
- Lines 760-800: Added bodyDiagrams section
- Lines 2300-2310: Show diagrams when results display

**Tested:**
- ✅ Diagrams appear after search
- ✅ Query boxes still work
- ✅ Protected panels unchanged
- ✅ No console errors

**Files Modified:**
- index.html (1 file)

**Database Changes:**
- None

**Breaking Changes:**
- None
```

---

## 🔍 **FINDING CODE SECTIONS**

### **Use These Search Terms:**

```bash
# Find left panel:
grep -n "left-panel" index.html

# Find right panel:
grep -n "right-panel" index.html

# Find center panel:
grep -n "CENTER PANEL" index.html

# Find specific function:
grep -n "function performMultiQuery" index.html

# Find Supabase calls:
grep -n "supabaseClient" index.html

# Find query boxes:
grep -n "searchInput" index.html
```

---

## ✅ **STRUCTURE VERIFICATION**

**Run these checks after changes:**

1. **Line count:**
   ```bash
   wc -l index.html
   # Should be ~4562 lines (±50 is OK)
   ```

2. **Protected sections intact:**
   ```bash
   grep -c "left-panel" index.html  # Should be 2
   grep -c "right-panel" index.html # Should be 2
   ```

3. **No syntax errors:**
   - Open in browser
   - Check console (F12)
   - Should be no red errors

---

## 📚 **RELATED DOCS**

- **README.md** - Overview & protection rules
- **DEPLOYMENT.md** - Git & deployment guide
- **API.md** - Supabase API reference (to be created)
- **TESTING.md** - Testing procedures (to be created)

---

**Last Updated:** 2026-01-28  
**Version:** 1.0.0 IRONCLAD BASELINE  
**Status:** 🔒 REFERENCE DOCUMENT
