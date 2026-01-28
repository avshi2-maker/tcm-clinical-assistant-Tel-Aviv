#!/usr/bin/env python3
"""
FIX DR. RONI SQL - USE POINT_CODE INSTEAD OF ID
================================================

The original SQL used WHERE id = N, but the database has non-sequential IDs.
This script regenerates the SQL using WHERE point_code = 'XX' instead.

Usage:
    python fix_dr_roni_sql.py

Input: dr_roni_translations.sql (original)
Output: dr_roni_translations_FIXED.sql
"""

import re
import os

def fix_sql_file():
    """Fix SQL to use point_code instead of id"""
    
    input_file = 'dr_roni_translations.sql'
    output_file = 'dr_roni_translations_FIXED.sql'
    
    # Check if file exists
    if not os.path.exists(input_file):
        print(f"❌ Error: {input_file} not found!")
        input("\nPress Enter to exit...")
        return
    
    print("="*60)
    print("🔧 FIXING DR. RONI SQL")
    print("="*60)
    print(f"\n📥 Reading {input_file}...")
    
    # Read the file
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    print("✅ File loaded")
    
    # Pattern to find: -- Point N: CODE
    # Example: -- Point 1: Lu 2
    point_pattern = re.compile(r'-- Point (\d+): (.+)')
    
    # Pattern to find: WHERE id = N;
    where_pattern = re.compile(r'WHERE id = (\d+);')
    
    # Split into lines for processing
    lines = content.split('\n')
    fixed_lines = []
    current_point_code = None
    updates_fixed = 0
    
    print("\n🔄 Processing updates...")
    
    for line in lines:
        # Check if this is a point marker
        point_match = point_pattern.match(line)
        if point_match:
            point_num = point_match.group(1)
            current_point_code = point_match.group(2).strip()
            fixed_lines.append(line)
            continue
        
        # Check if this is a WHERE id line
        where_match = where_pattern.match(line)
        if where_match and current_point_code:
            # Replace with WHERE point_code
            # Escape single quotes in point_code
            safe_code = current_point_code.replace("'", "''")
            new_line = f"WHERE point_code = '{safe_code}';"
            fixed_lines.append(new_line)
            updates_fixed += 1
            if updates_fixed % 50 == 0:
                print(f"  ✅ Fixed {updates_fixed} UPDATE statements...")
            continue
        
        # Keep all other lines as-is
        fixed_lines.append(line)
    
    # Write fixed file
    print(f"\n💾 Saving to {output_file}...")
    with open(output_file, 'w', encoding='utf-8') as f:
        f.write('\n'.join(fixed_lines))
    
    print(f"✅ Fixed SQL saved!")
    
    print("\n" + "="*60)
    print("🎉 FIX COMPLETE!")
    print("="*60)
    print(f"📊 Statistics:")
    print(f"   - UPDATE statements fixed: {updates_fixed}")
    print(f"   - Now using: WHERE point_code = 'XX'")
    print(f"   - Output file: {output_file}")
    
    print(f"\n🚀 Next steps:")
    print(f"   1. Run split script on FIXED file:")
    print(f"      python split_sql_batches_fixed.py")
    print(f"   2. Import the new batches to Supabase")
    print(f"   3. Verify: All 461 points should have Hebrew!")
    print("="*60)
    
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    try:
        fix_sql_file()
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        input("\nPress Enter to exit...")
