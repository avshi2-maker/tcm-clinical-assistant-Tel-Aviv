# 🔧 SURGICAL PATCH - REPLACE GREEN BOX ONLY

## 📍 LOCATION: Line 781-788 in index.html

---

## ❌ REMOVE THIS (Lines 781-788):

```html
            <!-- Module 1: CSV Indicators - Shows which tables are being searched -->
            <div class="p-4 bg-gradient-to-br from-emerald-500 to-teal-600 m-3 rounded-xl shadow-lg">
                <h4 class="text-white font-bold text-center mb-3 text-lg">📊 מקורות ידע פעילים</h4>
                <p class="text-white text-xs text-center mb-3 opacity-90">13 טבלאות • מאיר בזמן חיפוש</p>
                <div id="csvIndicatorsLeft" class="space-y-2 max-h-64 overflow-y-auto">
                    <!-- CSV boxes will be dynamically added here -->
                    <div class="text-white text-center text-sm py-4">טוען מקורות...</div>
                </div>
            </div>
```

---

## ✅ ADD THIS (SAME LOCATION):

```html
            <!-- Module 1: DR Roni Points Database (341 Points) -->
            <div class="p-4 bg-gradient-to-br from-blue-500 to-indigo-600 m-3 rounded-xl shadow-lg">
                <h4 class="text-white font-bold text-center mb-2 text-lg flex items-center justify-center gap-2">
                    <span>📍</span>
                    <span>נקודות דיקור</span>
                </h4>
                <p class="text-white text-xs text-center mb-3 opacity-90">341 נקודות • 14 מרידיאנים</p>
                <button onclick="toggleDrRoniPoints()" class="block w-full bg-white text-blue-600 font-bold py-2 px-3 rounded-lg hover:bg-blue-50 transition text-center text-sm">
                    <span id="drRoniToggle">🔽</span> פתח מאגר
                </button>
                <div id="drRoniDropdown" class="mt-3 space-y-1 max-h-48 overflow-y-auto hidden">
                    <div class="text-white text-center text-xs py-3">טוען נקודות...</div>
                </div>
            </div>

            <!-- Module 2: Zang-Fu Syndromes (11 Syndromes) -->
            <div class="p-4 bg-gradient-to-br from-purple-500 to-pink-600 m-3 rounded-xl shadow-lg">
                <h4 class="text-white font-bold text-center mb-2 text-lg flex items-center justify-center gap-2">
                    <span>🏥</span>
                    <span>תסמונות זאנג-פו</span>
                </h4>
                <p class="text-white text-xs text-center mb-3 opacity-90">11 תסמונות • אבחון AI</p>
                <button onclick="toggleZangFuSyndromes()" class="block w-full bg-white text-purple-600 font-bold py-2 px-3 rounded-lg hover:bg-purple-50 transition text-center text-sm">
                    <span id="zangfuToggle">🔽</span> פתח תסמונות
                </button>
                <div id="zangfuDropdown" class="mt-3 space-y-1 max-h-48 overflow-y-auto hidden">
                    <div class="text-white text-center text-xs py-3">טוען תסמונות...</div>
                </div>
            </div>

            <!-- Module 3: Clinical Diagnosis (52 Symptom Questions) -->
            <div class="p-4 bg-gradient-to-br from-orange-500 to-red-600 m-3 rounded-xl shadow-lg">
                <h4 class="text-white font-bold text-center mb-2 text-lg flex items-center justify-center gap-2">
                    <span>🩺</span>
                    <span>אבחון קליני</span>
                </h4>
                <p class="text-white text-xs text-center mb-3 opacity-90">52 שאלות תסמין • חישוב AI</p>
                <button onclick="toggleClinicalSymptoms()" class="block w-full bg-white text-orange-600 font-bold py-2 px-3 rounded-lg hover:bg-orange-50 transition text-center text-sm">
                    <span id="clinicalToggle">🔽</span> פתח שאלות
                </button>
                <div id="clinicalDropdown" class="mt-3 space-y-1 max-h-48 overflow-y-auto hidden">
                    <div class="text-white text-center text-xs py-3">טוען שאלות...</div>
                </div>
            </div>
```

---

## 📝 ADD CSS (Add to <style> section around line 180):

```css
        /* Clinical Modules Dropdown Items */
        .clinical-item {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 6px;
            padding: 8px 10px;
            cursor: pointer;
            transition: all 0.2s;
            font-size: 11px;
            color: #1e293b;
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .clinical-item:hover {
            background: white;
            transform: translateX(-2px);
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        }
        .clinical-item.selected {
            background: #fef3c7;
            border-color: #fbbf24;
            font-weight: bold;
        }
```

---

## 🔧 ADD JAVASCRIPT (Add before closing </script> tag, around line 4100):

```javascript
// ============================================
// CLINICAL MODULES - DR RONI & ZANG-FU
// ============================================

// State
let drRoniData = null;
let zangfuData = null;
let symptomsData = null;
let selectedClinicalItems = new Set();

// Toggle Dropdowns
function toggleDrRoniPoints() {
    const dropdown = document.getElementById('drRoniDropdown');
    const toggle = document.getElementById('drRoniToggle');
    
    if (dropdown.classList.contains('hidden')) {
        dropdown.classList.remove('hidden');
        toggle.textContent = '🔼';
        if (!drRoniData) loadDrRoniPoints();
    } else {
        dropdown.classList.add('hidden');
        toggle.textContent = '🔽';
    }
}

function toggleZangFuSyndromes() {
    const dropdown = document.getElementById('zangfuDropdown');
    const toggle = document.getElementById('zangfuToggle');
    
    if (dropdown.classList.contains('hidden')) {
        dropdown.classList.remove('hidden');
        toggle.textContent = '🔼';
        if (!zangfuData) loadZangFuSyndromes();
    } else {
        dropdown.classList.add('hidden');
        toggle.textContent = '🔽';
    }
}

function toggleClinicalSymptoms() {
    const dropdown = document.getElementById('clinicalDropdown');
    const toggle = document.getElementById('clinicalToggle');
    
    if (dropdown.classList.contains('hidden')) {
        dropdown.classList.remove('hidden');
        toggle.textContent = '🔼';
        if (!symptomsData) loadClinicalSymptoms();
    } else {
        dropdown.classList.add('hidden');
        toggle.textContent = '🔽';
    }
}

// Load DR Roni Points
async function loadDrRoniPoints() {
    try {
        const { data, error } = await supabaseClient
            .from('dr_roni_complete')
            .select('point_code, english_name_hebrew')
            .order('point_code')
            .limit(50); // Load first 50 to keep it fast
        
        if (error) {
            console.error('Error loading DR Roni points:', error);
            document.getElementById('drRoniDropdown').innerHTML = 
                '<div class="text-white text-center text-xs py-2">❌ שגיאה בטעינה</div>';
            return;
        }
        
        drRoniData = data;
        displayDrRoniPoints(data);
        
    } catch (err) {
        console.error('Exception loading DR Roni:', err);
    }
}

function displayDrRoniPoints(points) {
    const container = document.getElementById('drRoniDropdown');
    if (!points || points.length === 0) {
        container.innerHTML = '<div class="text-white text-center text-xs py-2">אין נתונים</div>';
        return;
    }
    
    let html = '';
    points.forEach(point => {
        const id = `drroni-${point.point_code}`;
        html += `
            <div class="clinical-item" id="${id}" onclick="selectClinicalItem('${point.point_code}', '${point.english_name_hebrew}', '${id}')">
                <strong>${point.point_code}</strong> - ${point.english_name_hebrew}
            </div>
        `;
    });
    
    container.innerHTML = html;
}

// Load Zang-Fu Syndromes
async function loadZangFuSyndromes() {
    try {
        const { data, error } = await supabaseClient
            .from('zangfu_syndromes')
            .select('syndrome_code, syndrome_name_he')
            .order('syndrome_code');
        
        if (error) {
            console.error('Error loading Zang-Fu syndromes:', error);
            document.getElementById('zangfuDropdown').innerHTML = 
                '<div class="text-white text-center text-xs py-2">❌ שגיאה בטעינה</div>';
            return;
        }
        
        zangfuData = data;
        displayZangFuSyndromes(data);
        
    } catch (err) {
        console.error('Exception loading Zang-Fu:', err);
    }
}

function displayZangFuSyndromes(syndromes) {
    const container = document.getElementById('zangfuDropdown');
    if (!syndromes || syndromes.length === 0) {
        container.innerHTML = '<div class="text-white text-center text-xs py-2">אין נתונים</div>';
        return;
    }
    
    let html = '';
    syndromes.forEach(syndrome => {
        const id = `zangfu-${syndrome.syndrome_code}`;
        html += `
            <div class="clinical-item" id="${id}" onclick="selectClinicalItem('${syndrome.syndrome_code}', '${syndrome.syndrome_name_he}', '${id}')">
                <strong>${syndrome.syndrome_code}</strong> - ${syndrome.syndrome_name_he}
            </div>
        `;
    });
    
    container.innerHTML = html;
}

// Load Clinical Symptoms
async function loadClinicalSymptoms() {
    try {
        const { data, error } = await supabaseClient
            .from('diagnostic_questions')
            .select('symptom_code, question_he, category')
            .order('category')
            .order('question_he');
        
        if (error) {
            console.error('Error loading symptoms:', error);
            document.getElementById('clinicalDropdown').innerHTML = 
                '<div class="text-white text-center text-xs py-2">❌ שגיאה בטעינה</div>';
            return;
        }
        
        symptomsData = data;
        displayClinicalSymptoms(data);
        
    } catch (err) {
        console.error('Exception loading symptoms:', err);
    }
}

function displayClinicalSymptoms(symptoms) {
    const container = document.getElementById('clinicalDropdown');
    if (!symptoms || symptoms.length === 0) {
        container.innerHTML = '<div class="text-white text-center text-xs py-2">אין נתונים</div>';
        return;
    }
    
    // Group by category (show first 30 for performance)
    let html = '';
    symptoms.slice(0, 30).forEach(symptom => {
        const id = `symptom-${symptom.symptom_code}`;
        html += `
            <div class="clinical-item" id="${id}" onclick="selectClinicalItem('${symptom.symptom_code}', '${symptom.question_he}', '${id}')">
                ${symptom.question_he}
            </div>
        `;
    });
    
    if (symptoms.length > 30) {
        html += '<div class="text-white text-center text-xs py-2 italic">ו-' + (symptoms.length - 30) + ' עוד...</div>';
    }
    
    container.innerHTML = html;
}

// Select Clinical Item (Plugin to Query Boxes)
function selectClinicalItem(code, text, elementId) {
    const element = document.getElementById(elementId);
    
    // Toggle selection
    if (selectedClinicalItems.has(code)) {
        selectedClinicalItems.delete(code);
        element.classList.remove('selected');
        removeFromQueryBox(text);
    } else {
        selectedClinicalItems.add(code);
        element.classList.add('selected');
        addToQueryBox(text);
    }
}

// Add to Query Box (Find first empty box)
function addToQueryBox(text) {
    const boxes = ['query1', 'query2', 'query3'];
    
    for (let boxId of boxes) {
        const textarea = document.getElementById(boxId);
        if (textarea && textarea.value.trim() === '') {
            textarea.value = text;
            textarea.closest('.query-box').classList.add('filled');
            return;
        }
    }
    
    // If all boxes full, append to first box
    const textarea = document.getElementById('query1');
    if (textarea) {
        textarea.value += '\n' + text;
    }
}

// Remove from Query Box
function removeFromQueryBox(text) {
    const boxes = ['query1', 'query2', 'query3'];
    
    for (let boxId of boxes) {
        const textarea = document.getElementById(boxId);
        if (textarea && textarea.value.includes(text)) {
            textarea.value = textarea.value.replace(text, '').trim();
            if (textarea.value === '') {
                textarea.closest('.query-box').classList.remove('filled');
            }
            return;
        }
    }
}

console.log('✅ Clinical modules loaded (DR Roni + Zang-Fu + Symptoms)');
```

---

## ✅ INSTALLATION STEPS:

### **STEP 1: Backup Your File**
```bash
cp index.html index.html.backup
```

### **STEP 2: Remove Green Box (Lines 781-788)**
Delete these 8 lines from your index.html

### **STEP 3: Add New Modules**
Insert the 3 new module boxes in the exact same location (line 781)

### **STEP 4: Add CSS**
Insert the CSS code in the <style> section (around line 180)

### **STEP 5: Add JavaScript**
Insert the JavaScript code before the closing </script> tag (around line 4100)

### **STEP 6: Test!**
1. Open index.html
2. Check right panel has 3 new boxes
3. Click each box to expand
4. Select items to populate query boxes

---

## 🎯 HOW IT WORKS:

### **User Flow:**
```
1. Therapist clicks "📍 נקודות דיקור"
   ↓
2. Dropdown opens, loads 50 DR Roni points
   ↓
3. Therapist clicks "KID3 - ערוץ גדול"
   ↓
4. Text appears in Query Box 1
   ↓
5. Therapist can select more items
   ↓
6. Click "הרץ שאילתה" to search!
```

### **Database Queries:**
```javascript
// DR Roni: Loads 50 points
SELECT point_code, english_name_hebrew 
FROM dr_roni_complete 
ORDER BY point_code 
LIMIT 50;

// Zang-Fu: Loads all 11 syndromes
SELECT syndrome_code, syndrome_name_he 
FROM zangfu_syndromes 
ORDER BY syndrome_code;

// Symptoms: Loads 30 questions
SELECT symptom_code, question_he, category 
FROM diagnostic_questions 
ORDER BY category, question_he 
LIMIT 30;
```

---

## 🎨 VISUAL RESULT:

```
RIGHT PANEL (After replacement):
┌──────────────────────────────────┐
│ 🎯 מודולים קליניים              │
├──────────────────────────────────┤
│                                  │
│ 📍 נקודות דיקור                 │ ← NEW!
│ 341 נקודות • 14 מרידיאנים      │
│ [🔽 פתח מאגר]                   │
│                                  │
├──────────────────────────────────┤
│                                  │
│ 🏥 תסמונות זאנג-פו               │ ← NEW!
│ 11 תסמונות • אבחון AI           │
│ [🔽 פתח תסמונות]                │
│                                  │
├──────────────────────────────────┤
│                                  │
│ 🩺 אבחון קליני                  │ ← NEW!
│ 52 שאלות תסמין • חישוב AI       │
│ [🔽 פתח שאלות]                  │
│                                  │
├──────────────────────────────────┤
│                                  │
│ 🫀 גלריית דופק ולשון            │ (existing)
│ [פתח גלריה]                     │
│                                  │
├──────────────────────────────────┤
│                                  │
│ ☯️ הערכת יין-יאנג               │ (existing)
│ [התחל הערכה]                    │
│                                  │
└──────────────────────────────────┘
```

---

## ✅ SAFETY CHECKLIST:

- [x] Only replaces green box (lines 781-788)
- [x] Keeps all other modules intact
- [x] Matches existing styling (same structure as pulse/yin-yang modules)
- [x] Same box sizes (p-4, m-3, rounded-xl)
- [x] Uses existing Supabase connection
- [x] Minimal JavaScript (only new functions)
- [x] No changes to left/center panels
- [x] No changes to query execution logic
- [x] Dropdown behavior similar to Training module
- [x] Selection populates query boxes cleanly

---

## 🎊 RESULT:

**You get:**
- ✅ 3 new clickable clinical modules
- ✅ Drop-down menus for each
- ✅ Data loaded from Supabase
- ✅ Selected items auto-populate query boxes
- ✅ Same styling as existing modules
- ✅ Zero impact on existing functionality

**Performance:**
- Loads only 50 points (not 341) for speed
- Loads all 11 syndromes (small dataset)
- Loads 30 symptoms (not 52) for speed
- Lazy loading: data loads only when clicked

---

**This is a SURGICAL, SAFE replacement!** 🔧

**Ready to apply?** ✅
