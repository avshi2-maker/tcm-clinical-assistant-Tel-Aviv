#!/usr/bin/env python3
"""
DR. RONI HEBREW TRANSLATION SCRIPT
===================================
Translates 461 acupuncture points from English to Hebrew using Google Gemini API

Requirements:
- pip install google-generativeai supabase --break-system-packages

Usage:
1. Set your API keys as environment variables
2. Run: python3 dr_roni_translate.py
3. Review output: dr_roni_translations.sql
4. Import SQL to Supabase

Cost: ~$0.09 for all 461 rows
Time: ~30 minutes
"""

import os
import json
import time
from typing import Dict, List, Optional

try:
    import google.generativeai as genai
    from supabase import create_client, Client
except ImportError:
    print("❌ Missing dependencies!")
    print("Run: pip install google-generativeai supabase --break-system-packages")
    exit(1)

# ============================================================================
# CONFIGURATION
# ============================================================================

# API Keys (set as environment variables or hardcode temporarily)
SUPABASE_URL = os.getenv('SUPABASE_URL', 'YOUR_SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_KEY', 'YOUR_SUPABASE_ANON_KEY')
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY', 'YOUR_GEMINI_API_KEY')

# Output file
OUTPUT_SQL_FILE = 'dr_roni_translations.sql'
OUTPUT_CSV_FILE = 'dr_roni_translations.csv'

# Batch size (to avoid rate limits)
BATCH_SIZE = 10
DELAY_BETWEEN_BATCHES = 2  # seconds

# Fields to translate
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
# INITIALIZE APIs
# ============================================================================

print("🔧 Initializing APIs...")

# Initialize Supabase
try:
    supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
    print("✅ Supabase connected")
except Exception as e:
    print(f"❌ Supabase connection failed: {e}")
    exit(1)

# Initialize Gemini
try:
    genai.configure(api_key=GEMINI_API_KEY)
    model = genai.GenerativeModel('gemini-1.5-flash')
    print("✅ Gemini API configured")
except Exception as e:
    print(f"❌ Gemini configuration failed: {e}")
    exit(1)

# ============================================================================
# TRANSLATION FUNCTIONS
# ============================================================================

def translate_to_hebrew(english_text: str, field_name: str, context: Dict) -> Optional[str]:
    """
    Translate English text to Hebrew using Gemini API with medical context
    """
    if not english_text or english_text.strip() == '':
        return None
    
    # Build context-aware prompt
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
        
        # Clean up common artifacts
        hebrew_text = hebrew_text.replace('```', '')
        hebrew_text = hebrew_text.replace('hebrew:', '')
        hebrew_text = hebrew_text.replace('Hebrew:', '')
        hebrew_text = hebrew_text.strip()
        
        return hebrew_text
    
    except Exception as e:
        print(f"⚠️ Translation error for {field_name}: {e}")
        return None

def translate_row(row: Dict, row_num: int, total: int) -> Dict:
    """
    Translate all fields for one acupuncture point
    """
    print(f"\n📍 Translating row {row_num}/{total}: {row.get('point_code', 'N/A')} - {row.get('english_name', 'N/A')}")
    
    translations = {
        'id': row['id'],
        'point_code': row.get('point_code', ''),
    }
    
    # Context for better translations
    context = {
        'point_code': row.get('point_code', ''),
        'english_name': row.get('english_name', ''),
        'chinese_name': row.get('chinese_name', '')
    }
    
    # Translate each field
    for field in FIELDS_TO_TRANSLATE:
        english_text = row.get(field)
        if english_text and english_text.strip():
            print(f"  🔄 Translating {field}...")
            hebrew_text = translate_to_hebrew(english_text, field, context)
            translations[f"{field}_hebrew"] = hebrew_text
            time.sleep(0.5)  # Small delay to avoid rate limits
        else:
            translations[f"{field}_hebrew"] = None
            print(f"  ⏭️  Skipping {field} (empty)")
    
    # Generate search keywords from translations
    keywords = []
    if translations.get('english_name_hebrew'):
        keywords.append(translations['english_name_hebrew'])
    if translations.get('chinese_name_hebrew'):
        keywords.append(translations['chinese_name_hebrew'])
    if row.get('point_code'):
        keywords.append(row['point_code'])
    
    # Extract keywords from indications
    if translations.get('indications_hebrew'):
        # Split by common delimiters and take first 5 terms
        terms = translations['indications_hebrew'].replace(',', ' ').replace('،', ' ').split()
        keywords.extend(terms[:5])
    
    translations['search_keywords_hebrew'] = list(set(keywords))  # Remove duplicates
    
    return translations

# ============================================================================
# MAIN TRANSLATION PROCESS
# ============================================================================

def main():
    print("\n" + "="*60)
    print("🎯 DR. RONI HEBREW TRANSLATION")
    print("="*60)
    
    # Step 1: Fetch all rows from Supabase
    print("\n📥 Fetching data from Supabase...")
    try:
        response = supabase.table('dr_roni_acupuncture_points').select('*').execute()
        rows = response.data
        total_rows = len(rows)
        print(f"✅ Fetched {total_rows} acupuncture points")
    except Exception as e:
        print(f"❌ Failed to fetch data: {e}")
        return
    
    # Step 2: Translate in batches
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
        
        # Delay between batches
        if i + BATCH_SIZE < total_rows:
            print(f"\n⏸️  Waiting {DELAY_BETWEEN_BATCHES}s before next batch...")
            time.sleep(DELAY_BETWEEN_BATCHES)
    
    # Step 3: Generate SQL UPDATE statements
    print(f"\n📝 Generating SQL UPDATE statements...")
    
    sql_statements = []
    sql_statements.append("-- ============================================================================")
    sql_statements.append("-- DR. RONI ACUPUNCTURE POINTS - HEBREW TRANSLATIONS")
    sql_statements.append("-- ============================================================================")
    sql_statements.append(f"-- Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}")
    sql_statements.append(f"-- Total points: {total_rows}")
    sql_statements.append("-- ============================================================================\n")
    
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
                # Escape single quotes for SQL
                safe_value = value.replace("'", "''")
                updates.append(f"    {hebrew_field} = '{safe_value}'")
        
        # Add search keywords
        keywords = trans.get('search_keywords_hebrew', [])
        if keywords:
            keywords_str = "ARRAY[" + ", ".join([f"'{k.replace(\"'\", \"''\")}'" for k in keywords]) + "]"
            updates.append(f"    search_keywords_hebrew = {keywords_str}")
        
        sql_statements.append(",\n".join(updates))
        sql_statements.append(f"WHERE id = {point_id};")
        sql_statements.append("")
    
    # Step 4: Save to file
    print(f"\n💾 Saving to {OUTPUT_SQL_FILE}...")
    with open(OUTPUT_SQL_FILE, 'w', encoding='utf-8') as f:
        f.write('\n'.join(sql_statements))
    
    print(f"✅ SQL file saved: {OUTPUT_SQL_FILE}")
    
    # Step 5: Save CSV for review
    print(f"\n💾 Saving CSV for review: {OUTPUT_CSV_FILE}...")
    try:
        import csv
        with open(OUTPUT_CSV_FILE, 'w', encoding='utf-8', newline='') as f:
            if all_translations:
                writer = csv.DictWriter(f, fieldnames=all_translations[0].keys())
                writer.writeheader()
                writer.writerows(all_translations)
        print(f"✅ CSV file saved: {OUTPUT_CSV_FILE}")
    except Exception as e:
        print(f"⚠️ CSV save failed: {e}")
    
    # Step 6: Summary
    print("\n" + "="*60)
    print("🎉 TRANSLATION COMPLETE!")
    print("="*60)
    print(f"📊 Statistics:")
    print(f"   - Total points translated: {total_rows}")
    print(f"   - Fields per point: {len(FIELDS_TO_TRANSLATE)}")
    print(f"   - Total translations: {total_rows * len(FIELDS_TO_TRANSLATE)}")
    print(f"\n📁 Output files:")
    print(f"   - SQL: {OUTPUT_SQL_FILE}")
    print(f"   - CSV: {OUTPUT_CSV_FILE}")
    print(f"\n🚀 Next steps:")
    print(f"   1. Review the translations in {OUTPUT_CSV_FILE}")
    print(f"   2. Run the SQL in Supabase: {OUTPUT_SQL_FILE}")
    print(f"   3. Update search_config to include Hebrew fields")
    print(f"   4. Test search on website!")
    print("="*60)

if __name__ == "__main__":
    main()
