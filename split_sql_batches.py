#!/usr/bin/env python3
"""
DR. RONI SQL BATCH SPLITTER
============================

Splits dr_roni_translations.sql into 10 smaller files for easy import to Supabase.

Usage:
    python split_sql_batches.py

Output:
    dr_roni_batch_01.sql (points 1-50)
    dr_roni_batch_02.sql (points 51-100)
    ...
    dr_roni_batch_10.sql (points 451-461)
"""

import os
import re

def split_sql_file():
    """Split the large SQL file into 10 batches"""
    
    input_file = 'dr_roni_translations.sql'
    
    # Check if file exists
    if not os.path.exists(input_file):
        print(f"❌ Error: {input_file} not found!")
        print(f"   Make sure you're in: C:\\tcm-clinical-assistant-Tel-Aviv\\")
        input("\nPress Enter to exit...")
        return
    
    print("="*60)
    print("🔪 DR. RONI SQL BATCH SPLITTER")
    print("="*60)
    print(f"\n📥 Reading {input_file}...")
    
    # Read the file
    with open(input_file, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Split by UPDATE statements
    # Pattern: -- Point N: ...
    parts = re.split(r'(-- Point \d+:)', content)
    
    # Reconstruct updates (header + point marker + update)
    updates = []
    header = parts[0]  # First part is the header
    
    for i in range(1, len(parts), 2):
        if i+1 < len(parts):
            point_marker = parts[i]
            update_content = parts[i+1]
            updates.append(point_marker + update_content)
    
    total_updates = len(updates)
    print(f"✅ Found {total_updates} UPDATE statements")
    
    # Calculate batch size
    batch_size = 50
    num_batches = (total_updates + batch_size - 1) // batch_size
    
    print(f"\n🔪 Splitting into {num_batches} batches...")
    
    # Create batches
    for batch_num in range(num_batches):
        start_idx = batch_num * batch_size
        end_idx = min((batch_num + 1) * batch_size, total_updates)
        
        batch_updates = updates[start_idx:end_idx]
        
        # Create filename
        output_file = f'dr_roni_batch_{batch_num+1:02d}.sql'
        
        # Write batch file
        with open(output_file, 'w', encoding='utf-8') as f:
            # Write header
            f.write("-- ============================================================================\n")
            f.write(f"-- DR. RONI ACUPUNCTURE POINTS - HEBREW TRANSLATIONS - BATCH {batch_num+1}\n")
            f.write("-- ============================================================================\n")
            f.write(f"-- Points {start_idx+1} to {end_idx}\n")
            f.write(f"-- Total in this batch: {len(batch_updates)}\n")
            f.write("-- ============================================================================\n\n")
            
            # Write updates
            for update in batch_updates:
                f.write(update)
        
        print(f"  ✅ Created {output_file} (points {start_idx+1}-{end_idx})")
    
    print("\n" + "="*60)
    print("🎉 SPLITTING COMPLETE!")
    print("="*60)
    print(f"\n📁 Created {num_batches} batch files:")
    for i in range(num_batches):
        print(f"   {i+1}. dr_roni_batch_{i+1:02d}.sql")
    
    print(f"\n🚀 Next steps:")
    print(f"   1. Open Supabase SQL Editor")
    print(f"   2. Open dr_roni_batch_01.sql in Notepad")
    print(f"   3. Copy all content")
    print(f"   4. Paste in Supabase SQL Editor")
    print(f"   5. Click 'Run'")
    print(f"   6. Wait for 'Success. No rows returned'")
    print(f"   7. Repeat for batches 2-{num_batches}")
    print("="*60)
    
    input("\nPress Enter to exit...")

if __name__ == "__main__":
    try:
        split_sql_file()
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        input("\nPress Enter to exit...")
