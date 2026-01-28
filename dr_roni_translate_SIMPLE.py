#!/usr/bin/env python3
"""
DR. RONI HEBREW TRANSLATION SCRIPT - SIMPLIFIED VERSION
========================================================

BEFORE RUNNING:
1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Click Settings → API
3. Copy "Project URL" and paste below at line 28
4. Copy "anon public" key and paste below at line 29
5. Get Gemini API key from: https://aistudio.google.com/apikey
6. Paste Gemini key below at line 30
7. Save this file
8. Run: python dr_roni_translate.py

Cost: ~$0.09
Time: ~30 minutes
"""

import json
import time
from typing import Dict, Optional

import google.generativeai as genai
from supabase import create_client, Client

# ============================================================================
# 🔑 PASTE YOUR API KEYS HERE (between the quotes):
# ============================================================================

SUPABASE_URL = "https://iqfglrwjemogoycbzltt.supabase.co"  # ← Your Supabase URL
SUPABASE_KEY = "PASTE_YOUR_SUPABASE_ANON_KEY_HERE"          # ← Your Supabase anon key
GEMINI_API_KEY = "PASTE_YOUR_GEMINI_API_KEY_HERE"           # ← Your Gemini API key

# ============================================================================
# Configuration (you can leave these as-is)
# ============================================================================

BATCH_SIZE = 10
DELAY_BETWEEN_BATCHES = 2  # seconds

FIELDS_TO_TRANSLATE = [
    'chinese_name',
    'english_name', 
    'location',
    'indications',
    'contraindications',
    'tcm_actions',
    'anatomy',
    'needling'
]

# ============================================================================
# Initialize APIs
# ============================================================================

print("="*60)
print("🎯 DR. RONI HEBREW TRANSLATION")
print("="*60)
print("\n🔧 Initializing APIs...")

# Check if keys are set
if "PASTE_YOUR" in SUPABASE_KEY:
    print("❌ ERROR: Please edit this file and paste your Supabase anon key!")
    print("   Line 29: SUPABASE_KEY = \"...\"")
    print("\n📍 Get it from: https://supabase.com/dashboard → Settings → API")
    input("\nPress Enter to exit...")
    exit(1)

if "PASTE_YOUR" in GEMINI_API_KEY:
    print("❌ ERROR: Please edit this file and paste your Gemini API key!")
    print("   Line 30: GEMINI_API_KEY = \"...\"")
    print("\n📍 Get it from: https://aistudio.google.com/apikey")
    input("\nPress Enter to exit...")
    exit(1)

try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    print("✅ Supabase connected")
except Exception as e:
    print(f"❌ Supabase connection failed: {e}")
    input("\nPress Enter to exit...")
    exit(1)

try:
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-1.5-flash')
    print("✅ Gemini API configured")
except Exception as e:
    print(f"❌ Gemini configuration failed: {e}")
    input("\nPress Enter to exit...")
    exit(1)

# ============================================================================
# Translation Functions
# ============================================================================

def translate_to_hebrew(english_text: str, field_name: str, context: Dict) -> Optional[str]:
    """Translate English text to Hebrew using Gemini API"""
    if not english_text or english_text.strip() == '':
        return None
    
    prompt = f"""You are a professional Traditional Chinese Medicine (TCM) translator.
Translate the following TCM acupuncture point information from English to Hebrew.

Context:
- Point Code: {context.get('point_code', 'N/A')}
- Point Name: {context.get('english_name', 'N/A')}
- Chinese Name: {context.get('chinese_name', 'N/A')}
- Field: {field_name}

IMPORTANT RULES:
1. Use professional Hebrew medical terminology
2. Keep TCM terms recognizable (e.g., "Qi" → "צ'י", "Lung" → "ריאות")
3. Maintain technical accuracy
4. Be concise and clear
5. Do NOT add explanations or notes
6. Return ONLY the Hebrew translation, nothing else

Text to translate:
{english_text}

Hebrew translation:"""

    try:
        response = model.generate_content(prompt)
        hebrew_text = response.text.strip()
        hebrew_text = hebrew_text.replace('```', '').replace('hebrew:', '').replace('Hebrew:', '').strip()
        return hebrew_text
    except Exception as e:
        print(f"⚠️ Translation error for {field_name}: {e}")
        return None

def translate_row(row: Dict, row_num: int, total: int) -> Dict:
    """Translate all fields for one acupuncture point"""
    print(f"\n📍 Row {row_num}/{total}: {row.get('point_code', 'N/A')} - {row.get('english_name', 'N/A')}")
    
    translations = {
        'id': row['id'],
        'point_code': row.get('point_code', ''),
    }
    
    context = {
        'point_code': row.get('point_code', ''),
        'english_name': row.get('english_name', ''),
        'chinese_name': row.get('chinese_name', '')
    }
    
    for field in FIELDS_TO_TRANSLATE:
        english_text = row.get(field)
        if english_text and english_text.strip():
            print(f"  🔄 {field}...", end='', flush=True)
            hebrew_text = translate_to_hebrew(english_text, field, context)
            translations[f"{field}_hebrew"] = hebrew_text
            print(" ✅")
            time.sleep(0.5)
        else:
            translations[f"{field}_hebrew"] = None
            print(f"  ⏭️  {field} (empty)")
    
    # Generate search keywords
    keywords = []
    if translations.get('english_name_hebrew'):
        keywords.append(translations['english_name_hebrew'])
    if translations.get('chinese_name_hebrew'):
        keywords.append(translations['chinese_name_hebrew'])
    if row.get('point_code'):
        keywords.append(row['point_code'])
    
    if translations.get('indications_hebrew'):
        terms = translations['indications_hebrew'].replace(',', ' ').split()[:5]
        keywords.extend(terms)
    
    translations['search_keywords_hebrew'] = list(set(keywords))
    
    return translations

# ============================================================================
# Main Translation Process
# ============================================================================

def main():
    print("\n📥 Fetching data from Supabase...")
    try:
        response = supabase.table('dr_roni_acupuncture_points').select('*').execute()
        rows = response.data
        total_rows = len(rows)
        print(f"✅ Fetched {total_rows} acupuncture points")
    except Exception as e:
        print(f"❌ Failed to fetch data: {e}")
        input("\nPress Enter to exit...")
        return
    
    print(f"\n🔄 Starting translation in batches of {BATCH_SIZE}...")
    all_translations = []
    
    for i in range(0, total_rows, BATCH_SIZE):
        batch = rows[i:i+BATCH_SIZE]
        batch_num = (i // BATCH_SIZE) + 1
        total_batches = (total_rows + BATCH_SIZE - 1) // BATCH_SIZE
        
        print(f"\n{'='*60}")
        print(f"📦 BATCH {batch_num}/{total_batches} (rows {i+1}-{min(i+BATCH_SIZE, total_rows)})")
        print(f"{'='*60}")
        
        for j, row in enumerate(batch):
            row_num = i + j + 1
            translations = translate_row(row, row_num, total_rows)
            all_translations.append(translations)
        
        if i + BATCH_SIZE < total_rows:
            print(f"\n⏸️  Waiting {DELAY_BETWEEN_BATCHES}s...")
            time.sleep(DELAY_BETWEEN_BATCHES)
    
    # Generate SQL
    print(f"\n📝 Generating SQL...")
    
    sql_statements = []
    sql_statements.append("-- DR. RONI ACUPUNCTURE POINTS - HEBREW TRANSLATIONS")
    sql_statements.append(f"-- Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    sql_statements.append(f"-- Total points: {total_rows}\n")
    
    for trans in all_translations:
        point_id = trans['id']
        point_code = trans['point_code']
        
        sql_statements.append(f"-- Point {point_id}: {point_code}")
        sql_statements.append(f"UPDATE dr_roni_acupuncture_points SET")
        
        updates = []
        for field in FIELDS_TO_TRANSLATE:
            hebrew_field = f"{field}_hebrew"
            value = trans.get(hebrew_field)
            if value:
                safe_value = value.replace("'", "''")
                updates.append(f"    {hebrew_field} = '{safe_value}'")
        
        keywords = trans.get('search_keywords_hebrew', [])
        if keywords:
            keywords_str = "ARRAY[" + ", ".join([f"'{k.replace(\"'\", \"''\")}'" for k in keywords]) + "]"
            updates.append(f"    search_keywords_hebrew = {keywords_str}")
        
        sql_statements.append(",\n".join(updates))
        sql_statements.append(f"WHERE id = {point_id};")
        sql_statements.append("")
    
    # Save files
    output_sql = 'dr_roni_translations.sql'
    print(f"\n💾 Saving to {output_sql}...")
    with open(output_sql, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_statements))
    print(f"✅ SQL file saved!")
    
    # Summary
    print("\n" + "="*60)
    print("🎉 TRANSLATION COMPLETE!")
    print("="*60)
    print(f"📊 Total points translated: {total_rows}")
    print(f"📁 Output file: {output_sql}")
    print(f"\n🚀 Next steps:")
    print(f"   1. Review the SQL file")
    print(f"   2. Import to Supabase (copy in batches)")
    print(f"   3. Run DR_RONI_04_SEARCH_CONFIG.sql")
    print(f"   4. Test search on website!")
    print("="*60)
    
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ Translation cancelled by user")
        input("\nPress Enter to exit...")
    except Exception as e:
        print(f"\n\n❌ Error: {e}")
        input("\nPress Enter to exit...")
