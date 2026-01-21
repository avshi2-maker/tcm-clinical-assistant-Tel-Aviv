# Supabase Configuration Management

## 📁 File: `supabase-config.js`

### Purpose
Centralized Supabase configuration for the TCM Clinical Assistant application. This eliminates the need to update API keys in multiple files.

---

## 🔧 How It Works

### 1. Single Source of Truth
All Supabase credentials are stored in one file: `supabase-config.js`

### 2. Automatic Loading
The config file creates a global object: `window.TCM_SUPABASE`

### 3. Used by All Pages
- `index.html` - Main application
- `yin-yang-assessment-ENHANCED.html` - Yin-Yang module
- `pulse-gallery.html` - Pulse diagnostic module (if needed)
- Any future modules

---

## 📋 Usage

### In HTML Files

**Step 1: Include Scripts (in order)**
```html
<head>
    <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
    <script src="supabase-config.js"></script>
</head>
```

**Step 2: Access Client**
```javascript
// Use the centralized client
const supabaseClient = window.TCM_SUPABASE.client;

// Query as normal
const { data, error } = await supabaseClient
    .from('yin_yang_symptoms')
    .select('*');
```

---

## 🔑 Updating API Key

**When you need to update the Supabase key:**

1. Open `supabase-config.js`
2. Find line: `const SUPABASE_ANON_KEY = '...'`
3. Replace with new key from Supabase Dashboard
4. Save file
5. **That's it!** All pages automatically use the new key

---

## 🎯 Benefits

✅ **Update once, apply everywhere**  
✅ **No duplicate keys in multiple files**  
✅ **Easy to maintain**  
✅ **Consistent across all modules**  
✅ **Built-in connection testing**  

---

## 🔒 Security Notes

### Safe for Public Use
- The `anon` key is designed to be public
- Protected by Row Level Security (RLS) in Supabase
- Only allows read access to permitted tables

### Never Commit
- ❌ Do NOT commit `service_role` key
- ❌ Do NOT share admin credentials
- ✅ The `anon` key is safe in public repos

---

## 🧪 Testing Connection

Open browser console and run:
```javascript
await window.TCM_SUPABASE.testConnection();
```

Should see: `✅ Supabase connection successful!`

---

## 📊 Quick Reference

### Available Properties
```javascript
window.TCM_SUPABASE.client       // Supabase client instance
window.TCM_SUPABASE.url          // Supabase project URL
window.TCM_SUPABASE.version      // Config version
window.TCM_SUPABASE.testConnection()  // Test function
window.TCM_SUPABASE.tables       // Table name constants
```

### Table Names
```javascript
window.TCM_SUPABASE.tables.yinYangSymptoms    // 'yin_yang_symptoms'
window.TCM_SUPABASE.tables.yinYangProtocols   // 'yin_yang_pattern_protocols'
window.TCM_SUPABASE.tables.acupoints          // 'tcm_acupoints'
window.TCM_SUPABASE.tables.images             // 'tcm_body_images'
window.TCM_SUPABASE.tables.formulas           // 'tcm_formulas'
```

---

## 📅 Change Log

### Version 1.0.0 (January 21, 2026)
- ✅ Initial centralized configuration
- ✅ Added to index.html
- ✅ Added to yin-yang-assessment-ENHANCED.html
- ✅ Updated Supabase anon key
- ✅ Added connection test utility
- ✅ Added table name constants

---

## 🆘 Troubleshooting

### Error: "Supabase library not loaded"
**Solution:** Add Supabase CDN before config:
```html
<script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>
<script src="supabase-config.js"></script>
```

### Error: "TCM_SUPABASE is not defined"
**Solution:** Ensure `supabase-config.js` loaded successfully. Check browser console for errors.

### Error: "401 Unauthorized"
**Solution:** 
1. Check API key is correct in `supabase-config.js`
2. Verify RLS policies allow `anon` read access
3. Run SQL to enable public access (see deployment docs)

---

## 👥 Team Communication

**When sharing with team members:**
1. Send them `supabase-config.js`
2. Tell them to include it in HTML head
3. Show them: `const client = window.TCM_SUPABASE.client`

**No more asking: "What's the Supabase key?"** ✨

---

Created: January 21, 2026  
Updated: January 21, 2026  
Maintainer: TCM Clinical Assistant Team
