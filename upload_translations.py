#!/usr/bin/env python3
"""
Upload offline translations back to Supabase
Run this when your Supabase connection is restored
"""

import json
from supabase import create_client

# Supabase Configuration
SUPABASE_URL = "https://oaitwmdwuoionjbmgkws.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9haXR3bWR3dW9pb25qYm1na3dzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzY5MzA4NjcsImV4cCI6MjA1MjUwNjg2N30.qkNjQUtUQgY8qRQnb-rjBnqI-BH7XfGfLr52HQxTPcs"

INPUT_FILE = "dr_roni_translations_hebrew.json"

print("=" * 60)
print("📤 UPLOAD TRANSLATIONS TO SUPABASE")
print("=" * 60)
print()

# Load translations
try:
    print(f"📂 Loading translations from {INPUT_FILE}...")
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        translations = json.load(f)
    print(f"✅ Loaded {len(translations)} translations")
except FileNotFoundError:
    print(f"❌ ERROR: Cannot find {INPUT_FILE}")
    print()
    print("Run translate_offline.py first to create translations.")
    exit(1)
except Exception as e:
    print(f"❌ ERROR loading file: {e}")
    exit(1)

print()

# Connect to Supabase
try:
    print("🔗 Connecting to Supabase...")
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Test connection
    supabase.table('dr_roni_complete').select('id').limit(1).execute()
    print("✅ Connected to Supabase")
except Exception as e:
    print(f"❌ ERROR: Cannot connect to Supabase!")
    print(f"   {e}")
    print()
    print("Check your internet connection and try again.")
    exit(1)

print()
print("🚀 Starting upload...")
print()

# Upload each translation
uploaded = 0
failed = 0

for point_id, data in translations.items():
    try:
        point_code = data.get('point_code', 'Unknown')
        print(f"📤 Uploading: {point_code} (ID: {point_id})")
        
        # Update the point
        response = supabase.table('dr_roni_complete').update(
            data['translations']
        ).eq('id', int(point_id)).execute()
        
        print(f"   ✅ Uploaded")
        uploaded += 1
        
    except Exception as e:
        print(f"   ❌ Failed: {e}")
        failed += 1

print()
print("=" * 60)
print("🎉 UPLOAD COMPLETE!")
print("=" * 60)
print(f"✅ Successfully uploaded: {uploaded} points")
print(f"❌ Failed: {failed} points")
print()

if failed > 0:
    print("💡 Re-run this script to retry failed uploads.")
else:
    print("🎊 All translations uploaded successfully!")
    print()
    print("🗑️  You can now delete these files:")
    print(f"   - {INPUT_FILE}")
    print("   - dr_roni_points_to_translate.json")

print()
