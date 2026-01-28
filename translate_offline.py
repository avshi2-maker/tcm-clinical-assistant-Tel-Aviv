#!/usr/bin/env python3
"""
OFFLINE Dr. Roni Translation - Works WITHOUT Supabase!
Saves translations to JSON file, uploads later when connection restored
"""

import json
import time
from datetime import datetime

try:
    import google.genai as genai
    USE_NEW_SDK = True
    print("✅ Using new google-genai package")
except ImportError:
    try:
        import google.generativeai as genai
        USE_NEW_SDK = False
        print("⚠️  Using deprecated google.generativeai")
    except ImportError:
        print("❌ ERROR: No Gemini package found!")
        print("Install with: pip install google-generativeai")
        exit(1)

# ============================================================================
# CONFIGURATION
# ============================================================================

GEMINI_API_KEY = "AIzaSyBMULiu2FBFIExlGHyAgKjqIq2ebyV2xcs"
MODEL_NAME = "gemini-2.0-flash-exp"  # Gemini Flash 3

# File paths
INPUT_FILE = "dr_roni_points_to_translate.json"  # You'll create this
OUTPUT_FILE = "dr_roni_translations_hebrew.json"  # Script creates this

# Rate Limiting
SECONDS_BETWEEN_REQUESTS = 5

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
# INITIALIZE GEMINI
# ============================================================================

print("🔧 Initializing Gemini Flash 3...")
try:
    if USE_NEW_SDK:
        client = genai.Client(api_key=GEMINI_API_KEY)
        print("✅ Connected to Gemini Flash 3 (new SDK)")
    else:
        genai.configure(api_key=GEMINI_API_KEY)
        client = genai.GenerativeModel(MODEL_NAME)
        print("✅ Connected to Gemini Flash 3 (old SDK)")
except Exception as e:
    print(f"❌ ERROR: Cannot initialize Gemini!")
    print(f"   {e}")
    exit(1)

print()

# ============================================================================
# TRANSLATION FUNCTION
# ============================================================================

def translate_point_batch(point_data: dict, point_number: int, total_points: int) -> dict:
    """Translate all fields for one point."""
    
    point_code = point_data.get('point_code', 'Unknown')
    english_name = point_data.get('english_name', 'Unknown')
    
    print(f"📍 Point {point_number}/{total_points}: {point_code} - {english_name}")
    
    # Build prompt
    prompt_parts = [
        "You are a professional medical translator specializing in Traditional Chinese Medicine (TCM).",
        "Translate the following acupuncture point information from English to Hebrew.",
        "Maintain medical accuracy and professional terminology.",
        "",
        "Return ONLY a JSON object with these keys:",
        "chinese_pinyin_hebrew, english_name_hebrew, etymology_hebrew, description_hebrew,",
        "location_hebrew, needling_hebrew, functions_hebrew, secondary_functions_hebrew,",
        "cautions_hebrew, notes_hebrew",
        "",
        "NO markdown, NO explanations - ONLY the JSON object.",
        "",
        "Point Information:",
        ""
    ]
    
    for english_field, _ in FIELDS_TO_TRANSLATE:
        value = point_data.get(english_field, '')
        if value:
            prompt_parts.append(f"**{english_field}:** {value}")
            prompt_parts.append("")
    
    prompt = "\n".join(prompt_parts)
    
    # Try translation
    max_retries = 3
    for attempt in range(max_retries):
        try:
            print(f"  🔄 Translating (attempt {attempt + 1}/{max_retries})...")
            
            # Call Gemini
            if USE_NEW_SDK:
                response = client.models.generate_content(
                    model=MODEL_NAME,
                    contents=prompt
                )
                response_text = response.text.strip()
            else:
                response = client.generate_content(prompt)
                response_text = response.text.strip()
            
            # Clean response
            if response_text.startswith("```json"):
                response_text = response_text.split("```json")[1].split("```")[0].strip()
            elif response_text.startswith("```"):
                response_text = response_text.split("```")[1].split("```")[0].strip()
            
            # Parse JSON
            translated_fields = json.loads(response_text)
            
            print(f"  ✅ Translated successfully!")
            return translated_fields
            
        except Exception as e:
            error_str = str(e).lower()
            print(f"  ⚠️  Error: {e}")
            
            if "429" in str(e) or "rate" in error_str:
                print(f"  ⏳ Rate limit, waiting 60 seconds...")
                time.sleep(60)
                continue
            elif attempt < max_retries - 1:
                time.sleep(2)
                continue
            else:
                print(f"  ❌ Failed after {max_retries} attempts")
                return None
    
    return None

# ============================================================================
# MAIN
# ============================================================================

def main():
    print("=" * 80)
    print("🚀 OFFLINE DR. RONI TRANSLATION")
    print(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 80)
    print()
    
    # Load input data
    print("📂 Loading input data...")
    try:
        with open(INPUT_FILE, 'r', encoding='utf-8') as f:
            points = json.load(f)
        print(f"✅ Loaded {len(points)} points from {INPUT_FILE}")
    except FileNotFoundError:
        print(f"❌ ERROR: Cannot find {INPUT_FILE}")
        print()
        print("💡 Create this file first by:")
        print("   1. Go to Supabase when connection works")
        print("   2. Export dr_roni_complete table to JSON")
        print("   3. Save as dr_roni_points_to_translate.json")
        return
    except Exception as e:
        print(f"❌ ERROR loading file: {e}")
        return
    
    print()
    
    # Load existing translations if any
    existing_translations = {}
    try:
        with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
            existing_translations = json.load(f)
        print(f"✅ Found {len(existing_translations)} existing translations")
    except FileNotFoundError:
        print(f"📝 No existing translations, starting fresh")
    
    print()
    
    # Filter points that need translation
    points_to_translate = []
    for point in points:
        point_id = str(point.get('id'))
        if point_id not in existing_translations:
            points_to_translate.append(point)
    
    print(f"✅ Already translated: {len(existing_translations)} points")
    print(f"⏳ Need translation: {len(points_to_translate)} points")
    print()
    
    if len(points_to_translate) == 0:
        print("🎉 All points already translated!")
        return
    
    # Estimate
    estimated_minutes = (len(points_to_translate) * SECONDS_BETWEEN_REQUESTS) / 60
    print(f"⏱️  Estimated time: {estimated_minutes:.1f} minutes")
    print()
    
    input("Press Enter to start translation...")
    print()
    
    # Translation loop
    start_time = time.time()
    new_translations = 0
    
    for i, point in enumerate(points_to_translate, 1):
        try:
            translated_fields = translate_point_batch(point, i, len(points_to_translate))
            
            if translated_fields:
                # Save to results
                point_id = str(point['id'])
                existing_translations[point_id] = {
                    'point_code': point.get('point_code'),
                    'english_name': point.get('english_name'),
                    'translated_at': datetime.now().isoformat(),
                    'translations': translated_fields
                }
                new_translations += 1
                
                # Save after each point (so you don't lose progress!)
                with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
                    json.dump(existing_translations, f, ensure_ascii=False, indent=2)
                print(f"  💾 Saved to {OUTPUT_FILE}")
            
            # Progress update
            if i % 10 == 0:
                elapsed = time.time() - start_time
                remaining = (len(points_to_translate) - i) * SECONDS_BETWEEN_REQUESTS / 60
                print()
                print(f"  📊 Progress: {i}/{len(points_to_translate)} ({i/len(points_to_translate)*100:.1f}%)")
                print(f"  ⏱️  Elapsed: {elapsed/60:.1f} min | Remaining: ~{remaining:.1f} min")
                print()
            
            # Rate limiting
            if i < len(points_to_translate):
                time.sleep(SECONDS_BETWEEN_REQUESTS)
            
        except KeyboardInterrupt:
            print()
            print("⚠️  Interrupted by user!")
            print(f"✅ Translated: {new_translations} new points")
            print(f"💾 All progress saved to: {OUTPUT_FILE}")
            return
    
    # Summary
    print()
    print("=" * 80)
    print("🎉 TRANSLATION COMPLETE!")
    print("=" * 80)
    print(f"✅ Total translations: {len(existing_translations)} points")
    print(f"✅ New translations: {new_translations} points")
    print(f"💾 Saved to: {OUTPUT_FILE}")
    print()
    print("💡 NEXT STEP:")
    print("   When Supabase connection is restored, run:")
    print("   python upload_translations.py")
    print()

if __name__ == "__main__":
    main()
