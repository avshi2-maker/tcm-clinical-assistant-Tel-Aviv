#!/usr/bin/env python3
"""
Convert CSV export from Supabase to JSON format
For offline translation
"""

import csv
import json
import sys

print("=" * 60)
print("📄 CSV TO JSON CONVERTER")
print("=" * 60)
print()

# Check for CSV file
csv_file = "dr_roni_complete.csv"
json_file = "dr_roni_points_to_translate.json"

print(f"Looking for: {csv_file}")

try:
    # Read CSV
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        data = list(reader)
    
    print(f"✅ Read {len(data)} rows from CSV")
    
    # Convert id field to integer if present
    for row in data:
        if 'id' in row and row['id']:
            try:
                row['id'] = int(row['id'])
            except ValueError:
                pass
    
    # Write JSON
    print(f"💾 Writing to {json_file}...")
    with open(json_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f"✅ Created {json_file}")
    print()
    print("🎉 SUCCESS!")
    print()
    print("Next step:")
    print(f"  python translate_offline.py")
    print()
    
except FileNotFoundError:
    print(f"❌ ERROR: Cannot find {csv_file}")
    print()
    print("How to create it:")
    print("  1. Go to Supabase SQL Editor")
    print("  2. Run: SELECT * FROM dr_roni_complete ORDER BY point_code;")
    print("  3. Click 'Download CSV' button")
    print(f"  4. Save as {csv_file} in this folder")
    print()
    sys.exit(1)
    
except Exception as e:
    print(f"❌ ERROR: {e}")
    sys.exit(1)
