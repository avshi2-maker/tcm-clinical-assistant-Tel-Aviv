// ================================================================
// UPDATED YIN-YANG MODULE - LOADS FROM SUPABASE
// Replace the hardcoded patternDefinitions with this code
// ================================================================

// Global variable to store patterns loaded from database
let patternDefinitions = {};

// FUNCTION: Load patterns from Supabase
async function loadYinYangPatterns() {
    try {
        console.log('🔄 Loading yin-yang patterns from Supabase...');
        
        const { data, error } = await supabaseClient
            .from('yin_yang_pattern_definitions')
            .select('*');
        
        if (error) throw error;
        
        if (!data || data.length === 0) {
            console.error('❌ No yin-yang patterns found in database!');
            alert('שגיאה: לא נמצאו דפוסי יין-יאנג במאגר');
            return false;
        }
        
        // Convert database rows to the format the module expects
        patternDefinitions = {};
        
        data.forEach(pattern => {
            patternDefinitions[pattern.pattern_id] = {
                name: pattern.name_he,
                name_en: pattern.name_en,
                name_cn: pattern.name_cn,
                badge_class: pattern.badge_class,
                patient_friendly: pattern.patient_friendly_he,
                typical_signs: pattern.typical_signs || [],
                tcm_notes: pattern.tcm_notes,
                safety_flags: pattern.safety_flags || []
            };
        });
        
        console.log(`✅ Loaded ${data.length} yin-yang patterns from database`);
        console.log('Patterns:', Object.keys(patternDefinitions));
        
        return true;
        
    } catch (error) {
        console.error('❌ Error loading yin-yang patterns:', error);
        alert('שגיאה בטעינת דפוסי יין-יאנג: ' + error.message);
        return false;
    }
}

// FUNCTION: Initialize yin-yang module
async function initYinYangModule() {
    // Load patterns from database BEFORE using the module
    const loaded = await loadYinYangPatterns();
    
    if (!loaded) {
        console.error('❌ Yin-yang module cannot function without pattern data');
        return;
    }
    
    console.log('✅ Yin-yang module initialized with database patterns');
    
    // Now the rest of your yin-yang module code can use patternDefinitions
    // as it did before - no other changes needed!
}

// ================================================================
// CALL THIS ON PAGE LOAD
// ================================================================
// Add this to your main initialization function:
// await initYinYangModule();

// ================================================================
// EXAMPLE USAGE IN YOUR EXISTING CODE
// ================================================================
// Your existing code that uses patternDefinitions will work as-is!
// For example:
//
// function displayYinYangResult(pattern) {
//     const patternInfo = patternDefinitions[pattern];  // ← Still works!
//     console.log(patternInfo.name);
//     console.log(patternInfo.typical_signs);
//     // ... rest of your code unchanged
// }

// ================================================================
// NOTE: The only change needed is to call initYinYangModule()
// BEFORE any code that uses patternDefinitions
// ================================================================
