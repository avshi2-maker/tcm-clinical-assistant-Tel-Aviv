#!/usr/bin/env python3
"""
TCM Clinical Assistant - Upload Therapist Intake Questions
Uploads 450 intake questions from CSV to Supabase
Author: Claude AI
Date: January 24, 2026
"""

import csv
import sys
from supabase import create_client, Client

# ============================================================================
# CONFIGURATION
# ============================================================================

SUPABASE_URL = "https://iqfglrwjemogoycbzltt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTM4ODMsImV4cCI6MjA4NDEyOTg4M30.DTREv3efs86_HzESyWm-7480ImfEVgC6T-xBdS6A2F8"

# CSV file name (put in same folder as this script)
CSV_FILE = "TCM_Hebrew_Questions_36x15_2026-01-24.csv"

# ============================================================================
# MAIN FUNCTION
# ============================================================================

def upload_intake_questions(csv_path: str):
    """
    Upload therapist intake questions from CSV to Supabase
    """
    
    print("=" * 70)
    print("  TCM THERAPIST INTAKE QUESTIONS - UPLOADER")
    print("=" * 70)
    print()
    
    # Connect to Supabase
    print("🔗 Connecting to Supabase...")
    try:
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected successfully!")
    except Exception as e:
        print(f"❌ Connection failed: {str(e)}")
        return False
    
    print()
    
    # Check if table exists
    print("🔍 Checking if table exists...")
    try:
        result = supabase.table('tcm_intake_questions').select("*", count='exact').limit(1).execute()
        existing_count = result.count if hasattr(result, 'count') else 0
        print(f"✅ Table exists with {existing_count} existing questions")
    except Exception as e:
        print(f"❌ Table does not exist!")
        print(f"   Error: {str(e)}")
        print()
        print("⚠️  Please run 'create_intake_questions_table.sql' first!")
        print("   Go to Supabase Dashboard → SQL Editor → Run the SQL script")
        return False
    
    print()
    
    # Read CSV
    print(f"📖 Reading CSV file: {csv_path}")
    try:
        questions = []
        
        with open(csv_path, 'r', encoding='utf-8-sig') as f:
            reader = csv.DictReader(f)
            
            for row in reader:
                questions.append({
                    'row_number': int(row['מספר שורה']),
                    'category_hebrew': row['קטגוריה'],
                    'category_english': row['קטגוריה (אנגלית)'],
                    'question_id': str(row['מזהה שאלה']),
                    'question_hebrew': row['שאלה בעברית'],
                    'question_english': row['שאלה באנגלית'],
                    'is_active': True,
                    'display_order': int(row['מספר שורה'])
                })
        
        print(f"✅ Read {len(questions)} questions from CSV")
        
        # Show sample
        if questions:
            print()
            print("📋 Sample question:")
            sample = questions[0]
            print(f"   Category: {sample['category_hebrew']} / {sample['category_english']}")
            print(f"   Question: {sample['question_hebrew'][:60]}...")
        
    except FileNotFoundError:
        print(f"❌ CSV file not found: {csv_path}")
        print(f"   Please put the CSV file in the same folder as this script")
        return False
    except Exception as e:
        print(f"❌ Error reading CSV: {str(e)}")
        return False
    
    print()
    
    # Count by category
    from collections import Counter
    categories = Counter(q['category_hebrew'] for q in questions)
    print(f"📊 Found {len(categories)} categories:")
    for cat, count in sorted(categories.items())[:10]:
        print(f"   • {cat}: {count} questions")
    if len(categories) > 10:
        print(f"   ... and {len(categories) - 10} more categories")
    
    print()
    
    # Confirm upload
    print("=" * 70)
    print("⚠️  READY TO UPLOAD")
    print("=" * 70)
    print(f"Questions to upload: {len(questions)}")
    print(f"Existing in database: {existing_count}")
    print()
    print("This will INSERT or UPDATE (upsert) all questions.")
    print("Existing questions will be updated if question_id matches.")
    print()
    
    confirm = input("Continue? (yes/no): ").strip().lower()
    if confirm != 'yes':
        print("❌ Upload cancelled")
        return False
    
    print()
    
    # Upload in batches
    print("📤 Uploading to Supabase...")
    
    batch_size = 100
    total = len(questions)
    uploaded = 0
    errors = []
    
    for i in range(0, total, batch_size):
        batch = questions[i:i+batch_size]
        batch_num = (i // batch_size) + 1
        total_batches = (total + batch_size - 1) // batch_size
        
        try:
            result = supabase.table('tcm_intake_questions').upsert(
                batch,
                on_conflict='question_id,category_hebrew'
            ).execute()
            
            uploaded += len(batch)
            print(f"  ✅ Batch {batch_num}/{total_batches}: Uploaded {uploaded}/{total} questions")
            
        except Exception as e:
            error_msg = f"Batch {batch_num} failed: {str(e)[:100]}"
            errors.append(error_msg)
            print(f"  ❌ {error_msg}")
    
    print()
    
    # Verify final count
    try:
        result = supabase.table('tcm_intake_questions').select("*", count='exact').limit(1).execute()
        final_count = result.count if hasattr(result, 'count') else 0
        
        print("=" * 70)
        print("✅ UPLOAD COMPLETE!")
        print("=" * 70)
        print(f"📊 Questions uploaded: {uploaded}")
        print(f"📊 Total in database: {final_count}")
        print(f"📊 Categories: {len(categories)}")
        
        if errors:
            print()
            print(f"⚠️  {len(errors)} errors occurred:")
            for error in errors[:5]:
                print(f"   • {error}")
            if len(errors) > 5:
                print(f"   ... and {len(errors) - 5} more errors")
        
        print()
        print("🎉 Your intake questions are now in Supabase!")
        print()
        print("Next steps:")
        print("1. Test search: SELECT * FROM tcm_intake_questions WHERE category_hebrew = 'אבחון דופק ולשון';")
        print("2. Use function: SELECT * FROM get_intake_questions_by_category('דופק');")
        print("3. Full-text search: SELECT * FROM search_intake_questions('כאב ראש');")
        print()
        
        return True
        
    except Exception as e:
        print(f"⚠️  Could not verify final count: {str(e)}")
        return uploaded > 0

# ============================================================================
# RUN
# ============================================================================

if __name__ == "__main__":
    print()
    
    # Check if CSV file path provided
    if len(sys.argv) > 1:
        csv_path = sys.argv[1]
    else:
        csv_path = CSV_FILE
    
    # Upload
    success = upload_intake_questions(csv_path)
    
    if success:
        print("✅ SUCCESS! All done!")
    else:
        print("❌ Upload failed. Please check errors above.")
    
    print()
