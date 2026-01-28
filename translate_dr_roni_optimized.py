#!/usr/bin/env python3
"""
Dr. Roni Complete Points - Hebrew Translation Script
Uses Gemini Flash 3 API (gemini-2.0-flash-exp)
Optimized batch translation: 1 API call per point
"""

import os
import json
import time
from datetime import datetime
from supabase import create_client, Client
import google.generativeai as genai

# ============================================================================
# CONFIGURATION
# ============================================================================

# Supabase Configuration
SUPABASE_URL = "https://oaitwmdwuoionjbmgkws.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9haXR3bWR3dW9pb25qYm1na3dzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY5MzA4NjcsImV4cCI6MjA1MjUwNjg2N30.qkNjQUtUQgY8qRQnb-rjBnqI-BH7XfGfLr52HQxTPcs"

# Gemini Configuration
GEMINI_API_KEY = "AIzaSyDbdRLN5bsxh3QxwYPwc6e6A8FNLWs1MQ0"
MODEL_NAME = "gemini-2.0-flash-exp"  # Gemini Flash 3

# Rate Limiting
REQUESTS_PER_MINUTE = 15  # Gemini Flash 3 limit
SECONDS_BETWEEN_REQUESTS = 60 / REQUESTS_PER_MINUTE + 1  # ~5 seconds

# Fields to translate
FIELDS_TO_TRANSLATE = [
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

# ============================================================================
# INITIALIZE CLIENTS
# ============================================================================

print("🔧 Initializing Supabase and Gemini Flash 3...")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel(MODEL_NAME)

print(f"✅ Connected to Supabase")
print(f"✅ Using Gemini Flash 3 ({MODEL_NAME})")
print()

# ============================================================================
# TRANSLATION FUNCTION - BATCH MODE
# ============================================================================

def translate_point_batch(point_data: dict, point_number: int, total_points: int) -> dict:
    """
    Translate all fields for one point in a single API call (batch mode).
    
    Returns dict with all translated fields or None if error.
    """
    point_code = point_data.get('point_code', 'Unknown')
    english_name = point_data.get('english_name', 'Unknown')
    
    print(f"📍 Point {point_number}/{total_points}: {point_code} - {english_name}")
    
    # Build prompt with all fields to translate
    prompt_parts = [
        "You are a professional medical translator specializing in Traditional Chinese Medicine (TCM).",
        "Translate the following acupuncture point information from English to Hebrew.",
        "Maintain medical accuracy and professional terminology.",
        "Preserve all formatting, line breaks, and special characters.",
        "",
        "IMPORTANT: Return ONLY a JSON object with these exact keys:",
        "chinese_pinyin_hebrew, english_name_hebrew, etymology_hebrew, description_hebrew,",
        "location_hebrew, needling_hebrew, functions_hebrew, secondary_functions_hebrew,",
        "cautions_hebrew, notes_hebrew",
        "",
        "NO markdown, NO code blocks, NO explanations - ONLY the JSON object.",
        "",
        "Acupuncture Point Information to Translate:",
        "============================================",
        ""
    ]
    
    # Add all fields to translate
    for english_field, _ in FIELDS_TO_TRANSLATE:
        value = point_data.get(english_field, '')
        if value:
            prompt_parts.append(f"**{english_field}:**")
            prompt_parts.append(str(value))
            prompt_parts.append("")
    
    prompt_parts.append("Now translate all fields to Hebrew and return as JSON.")
    
    prompt = "\n".join(prompt_parts)
    
    # Try translation with retry
    max_retries = 3
    for attempt in range(max_retries):
        try:
            print(f"  🔄 Translating all fields (attempt {attempt + 1}/{max_retries})...")
            
            response = model.generate_content(prompt)
            response_text = response.text.strip()
            
            # Clean response (remove markdown if present)
            if response_text.startswith("```json"):
                response_text = response_text.split("```json")[1].split("```")[0].strip()
            elif response_text.startswith("```"):
                response_text = response_text.split("```")[1].split("```")[0].strip()
            
            # Parse JSON
            translated_fields = json.loads(response_text)
            
            # Validate all required fields are present
            missing_fields = []
            for _, hebrew_field in FIELDS_TO_TRANSLATE:
                if hebrew_field not in translated_fields:
                    missing_fields.append(hebrew_field)
            
            if missing_fields:
                print(f"  ⚠️  Missing fields: {missing_fields}")
                if attempt < max_retries - 1:
                    print(f"  🔄 Retrying...")
                    time.sleep(2)
                    continue
                else:
                    print(f"  ❌ Failed after {max_retries} attempts")
                    return None
            
            print(f"  ✅ Translated all {len(FIELDS_TO_TRANSLATE)} fields successfully!")
            return translated_fields
            
        except json.JSONDecodeError as e:
            print(f"  ⚠️  JSON parse error: {e}")
            if attempt < max_retries - 1:
                print(f"  🔄 Retrying...")
                time.sleep(2)
                continue
            else:
                print(f"  ❌ Failed to parse JSON after {max_retries} attempts")
                return None
                
        except Exception as e:
            print(f"  ⚠️  Translation error: {e}")
            if "429" in str(e) or "quota" in str(e).lower():
                wait_time = 60
                print(f"  ⏳ Rate limit hit, waiting {wait_time} seconds...")
                time.sleep(wait_time)
                continue
            elif attempt < max_retries - 1:
                print(f"  🔄 Retrying...")
                time.sleep(2)
                continue
            else:
                print(f"  ❌ Failed after {max_retries} attempts")
                return None
    
    return None

# ============================================================================
# SAVE TO DATABASE
# ============================================================================

def save_translation_to_db(point_id: int, translated_fields: dict):
    """Save translated fields to database."""
    try:
        # Update the point with Hebrew translations
        response = supabase.table('dr_roni_complete').update(
            translated_fields
        ).eq('id', point_id).execute()
        
        print(f"  💾 Saved to database")
        return True
        
    except Exception as e:
        print(f"  ❌ Database error: {e}")
        return False

# ============================================================================
# MAIN TRANSLATION LOOP
# ============================================================================

def main():
    print("=" * 80)
    print("🚀 DR. RONI COMPLETE - HEBREW TRANSLATION")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    print()
    
    # Get all points from database
    print("📊 Loading points from database...")
    response = supabase.table('dr_roni_complete').select('*').order('point_code').execute()
    points = response.data
    
    print(f"✅ Loaded {len(points)} points")
    print()
    
    # Filter points that need translation
    points_to_translate = []
    for point in points:
        # Check if any Hebrew field is empty
        needs_translation = False
        for _, hebrew_field in FIELDS_TO_TRANSLATE:
            if not point.get(hebrew_field):
                needs_translation = True
                break
        
        if needs_translation:
            points_to_translate.append(point)
    
    already_done = len(points) - len(points_to_translate)
    
    print(f"✅ Already translated: {already_done} points")
    print(f"⏳ Need translation: {len(points_to_translate)} points")
    print()
    
    if len(points_to_translate) == 0:
        print("🎉 All points already translated!")
        return
    
    # Estimate time and cost
    estimated_minutes = (len(points_to_translate) * SECONDS_BETWEEN_REQUESTS) / 60
    estimated_cost = len(points_to_translate) * 0.0005  # Rough estimate
    
    print(f"⏱️  Estimated time: {estimated_minutes:.1f} minutes")
    print(f"💰 Estimated cost: ${estimated_cost:.2f}")
    print()
    
    input("Press Enter to start translation...")
    print()
    
    # Translation loop
    start_time = time.time()
    translated_count = 0
    failed_points = []
    
    for i, point in enumerate(points_to_translate, 1):
        try:
            # Translate all fields in batch
            translated_fields = translate_point_batch(point, i, len(points_to_translate))
            
            if translated_fields:
                # Save to database
                success = save_translation_to_db(point['id'], translated_fields)
                
                if success:
                    translated_count += 1
                else:
                    failed_points.append(point['point_code'])
            else:
                print(f"  ❌ Translation failed")
                failed_points.append(point['point_code'])
            
            # Progress update every 10 points
            if i % 10 == 0:
                elapsed = time.time() - start_time
                avg_time_per_point = elapsed / i
                remaining_points = len(points_to_translate) - i
                estimated_remaining = (remaining_points * avg_time_per_point) / 60
                
                print()
                print(f"  📊 Progress: {i}/{len(points_to_translate)} ({i/len(points_to_translate)*100:.1f}%)")
                print(f"  ⏱️  Elapsed: {elapsed/60:.1f} min | Remaining: ~{estimated_remaining:.1f} min")
                print()
            
            # Rate limiting (wait between requests)
            if i < len(points_to_translate):
                time.sleep(SECONDS_BETWEEN_REQUESTS)
            
        except KeyboardInterrupt:
            print()
            print("⚠️  Translation interrupted by user!")
            print(f"✅ Translated: {translated_count} points")
            print(f"⏳ Remaining: {len(points_to_translate) - i} points")
            print()
            print("💡 Run the script again to continue from where you left off.")
            return
            
        except Exception as e:
            print(f"  ❌ Unexpected error: {e}")
            failed_points.append(point['point_code'])
            continue
    
    # Final summary
    elapsed_total = time.time() - start_time
    
    print()
    print("=" * 80)
    print("🎉 TRANSLATION COMPLETE!")
    print("=" * 80)
    print(f"✅ Successfully translated: {translated_count} points")
    print(f"❌ Failed: {len(failed_points)} points")
    print(f"⏱️  Total time: {elapsed_total/60:.1f} minutes")
    print()
    
    if failed_points:
        print("Failed points:")
        for code in failed_points:
            print(f"  - {code}")
        print()
        print("💡 You can re-run the script to retry failed points.")
    else:
        print("🎊 All points translated successfully!")
    
    print()

# ============================================================================
# RUN
# ============================================================================

if __name__ == "__main__":
    main()
