#!/usr/bin/env python3
"""
DR. RONI COMPLETE - HEBREW TRANSLATION
=======================================

Translates Dr. Roni's complete acupuncture database to Hebrew.

Translates:
- 313 acupuncture points
- 10 fields per point
- ~3,130 total translations

Uses: Gemini 2.0 Flash
Cost: ~$0.15
Time: ~30 minutes

Usage: python translate_dr_roni_complete.py
"""

import os
import sys
import time
import google.generativeai as genai
from supabase import create_client, Client

# ============================================================================
# CONFIGURATION
# ============================================================================

SUPABASE_URL = 'https://iqfglrwjemogoycbzltt.supabase.co'
SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTM4ODMsImV4cCI6MjA4NDEyOTg4M30.DTREv3efs86_HzESyWm-7480ImfEVgC6T-xBdS6A2F8'
GEMINI_API_KEY = 'AIzaSyBMULiu2FBFIExlGHyAgKjqIq2ebyV2xcs'

# Configure Gemini
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel('gemini-2.0-flash-exp')

# Initialize Supabase
supabase: Client = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

# ============================================================================
# TRANSLATION FUNCTION
# ============================================================================

def translate_to_hebrew(text, field_name, point_code):
    """Translate text to Hebrew using Gemini"""
    
    if not text or text.strip() == '':
        return None
    
    prompt = f"""Translate this acupuncture point information to Hebrew.

Point: {point_code}
Field: {field_name}

Text to translate:
{text}

Instructions:
- Translate to natural, professional Hebrew
- Keep medical terminology accurate
- Preserve meaning and clinical significance
- For Chinese pinyin, provide Hebrew transliteration
- Return ONLY the Hebrew translation, no explanations

Hebrew translation:"""

    try:
        response = model.generate_content(prompt)
        hebrew_text = response.text.strip()
        return hebrew_text
    except Exception as e:
        print(f"  ⚠️  Translation error for {point_code} ({field_name}): {str(e)}")
        return None

# ============================================================================
# MAIN TRANSLATION PROCESS
# ============================================================================

def main():
    print("=" * 70)
    print("🎯 DR. RONI COMPLETE - HEBREW TRANSLATION")
    print("=" * 70)
    
    # Fetch all points
    print("\n📥 Fetching points from Supabase...")
    response = supabase.table('dr_roni_complete').select('*').execute()
    points = response.data
    
    print(f"✅ Found {len(points)} points to translate")
    print(f"⏱️  Estimated time: ~30 minutes")
    print(f"💰 Estimated cost: ~$0.15")
    
    input("\nPress Enter to start translation...")
    
    # Fields to translate
    fields_to_translate = [
        ('chinese_pinyin', 'chinese_pinyin_hebrew'),
        ('english_name', 'english_name_hebrew'),
        ('etymology', 'etymology_hebrew'),
        ('description', 'description_hebrew'),
        ('location', 'location_hebrew'),
        ('needling', 'needling_hebrew'),
        ('functions', 'functions_hebrew'),
        ('secondary_functions', 'secondary_functions_hebrew'),
        ('cautions', 'cautions_hebrew'),
        ('notes', 'notes_hebrew')
    ]
    
    print("\n" + "=" * 70)
    print("🔄 STARTING TRANSLATION")
    print("=" * 70)
    
    total_translated = 0
    start_time = time.time()
    
    for idx, point in enumerate(points, 1):
        point_code = point['point_code']
        
        print(f"\n📍 Point {idx}/{len(points)}: {point_code} - {point.get('english_name', 'N/A')}")
        
        # Prepare update data
        update_data = {}
        field_count = 0
        
        # Translate each field
        for source_field, target_field in fields_to_translate:
            source_text = point.get(source_field)
            
            if source_text and source_text.strip():
                print(f"  🔄 {source_field}...", end=" ", flush=True)
                
                hebrew_text = translate_to_hebrew(source_text, source_field, point_code)
                
                if hebrew_text:
                    update_data[target_field] = hebrew_text
                    field_count += 1
                    total_translated += 1
                    print("✅")
                else:
                    print("⚠️")
                
                # Rate limiting
                time.sleep(0.5)
        
        # Create search keywords
        keywords = []
        if update_data.get('english_name_hebrew'):
            keywords.append(update_data['english_name_hebrew'])
        if update_data.get('chinese_pinyin_hebrew'):
            keywords.append(update_data['chinese_pinyin_hebrew'])
        keywords.append(point_code)
        
        update_data['search_keywords_hebrew'] = keywords
        
        # Update database
        if update_data:
            try:
                supabase.table('dr_roni_complete').update(update_data).eq('id', point['id']).execute()
                print(f"  💾 Saved {field_count} Hebrew fields")
            except Exception as e:
                print(f"  ❌ Database error: {str(e)}")
        
        # Progress update every 10 points
        if idx % 10 == 0:
            elapsed = time.time() - start_time
            avg_time = elapsed / idx
            remaining = (len(points) - idx) * avg_time
            print(f"\n  ⏱️  Progress: {idx}/{len(points)} ({idx/len(points)*100:.1f}%)")
            print(f"  ⏰ Estimated time remaining: {remaining/60:.1f} minutes")
    
    # Summary
    elapsed_total = time.time() - start_time
    
    print("\n" + "=" * 70)
    print("🎉 TRANSLATION COMPLETE!")
    print("=" * 70)
    print(f"📊 Statistics:")
    print(f"   - Points translated: {len(points)}")
    print(f"   - Total fields: {total_translated}")
    print(f"   - Time taken: {elapsed_total/60:.1f} minutes")
    print(f"   - Average per point: {elapsed_total/len(points):.1f} seconds")
    print("=" * 70)
    
    print("\n🚀 Next steps:")
    print("   1. Update search config in Supabase")
    print("   2. Test Hebrew search on website")
    print("   3. Celebrate! 🎉")
    print("=" * 70)

if __name__ == '__main__':
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n⚠️  Translation interrupted by user")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ Error: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
