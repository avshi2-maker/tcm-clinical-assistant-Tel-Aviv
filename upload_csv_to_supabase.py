"""
========================================
TCM Clinical Assistant - CSV Batch Uploader
========================================
This script uploads all your Q&A CSV files to Supabase

Requirements:
    pip install pandas supabase python-dotenv

Usage:
    python upload_csv_to_supabase.py

Author: TCM Clinical Assistant Team
========================================
"""

import os
import re
import pandas as pd
from supabase import create_client, Client
from datetime import datetime
from typing import List, Dict

# ========================================
# CONFIGURATION
# ========================================

# Supabase credentials
SUPABASE_URL = "https://iqfglrwjemogoycbzltt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTM4ODMsImV4cCI6MjA4NDEyOTg4M30.DTREv3efs86_HzESyWm-7480ImfEVgC6T-xBdS6A2F8"
CSV_DIRECTORY = r"C:\Users\AvshiSapir\OneDrive\קבצים בעברית CSV 22 ינואר"

# Table name in Supabase
TABLE_NAME = "qa_knowledge_base"

# CSV column mapping
# Update these if your CSV columns have different names
CSV_COLUMNS = {
    'question': 'שאלה (Q)',
    'answer': 'תשובה (A)',
    'acupoints': 'נקודות דיקור (Acupuncture)',
    'description': 'תיאור (Description)',
    'pharmacopeia': 'פרמקופיאה (Pharmacopeia)'
}

# ========================================
# HELPER FUNCTIONS
# ========================================

def extract_point_codes(text: str) -> List[str]:
    """
    Extract acupuncture point codes from text
    Examples: LI4, ST36, GB20, REN17, etc.
    """
    if not text or pd.isna(text):
        return []
    
    # Pattern for standard acupuncture point codes
    pattern = r'\b([A-Z]{1,3})\s*[-]?\s*(\d{1,2}[A-Za-z]?)\b'
    matches = re.findall(pattern, str(text))
    
    point_codes = set()
    for match in matches:
        code = f"{match[0].upper()}{match[1]}"
        point_codes.add(code)
    
    return list(point_codes)


def get_category_from_filename(filename: str) -> str:
    """
    Extract category from filename
    Example: 'cardiology_hebrew_100qa.csv' -> 'cardiology'
    """
    # Remove path
    basename = os.path.basename(filename)
    
    # Remove extension
    name_without_ext = os.path.splitext(basename)[0]
    
    # Extract category (first part before underscore)
    parts = name_without_ext.split('_')
    return parts[0].lower() if parts else 'general'


def process_csv_file(filepath: str, category: str = None) -> List[Dict]:
    """
    Process a single CSV file and return list of records
    """
    try:
        # Read CSV file
        df = pd.read_csv(filepath, encoding='utf-8-sig')  # utf-8-sig to handle BOM
        
        # Get category from filename if not provided
        if not category:
            category = get_category_from_filename(filepath)
        
        records = []
        
        for index, row in df.iterrows():
            try:
                # Extract data from CSV
                question = str(row[CSV_COLUMNS['question']]) if CSV_COLUMNS['question'] in row else ''
                answer = str(row[CSV_COLUMNS['answer']]) if CSV_COLUMNS['answer'] in row else ''
                acupoints_text = str(row[CSV_COLUMNS['acupoints']]) if CSV_COLUMNS['acupoints'] in row else ''
                description = str(row[CSV_COLUMNS['description']]) if CSV_COLUMNS['description'] in row else ''
                pharmacopeia = str(row[CSV_COLUMNS['pharmacopeia']]) if CSV_COLUMNS['pharmacopeia'] in row else ''
                
                # Skip empty rows
                if not question or question == 'nan':
                    continue
                
                # Extract point codes from answer and acupoints column
                point_codes = extract_point_codes(answer + ' ' + acupoints_text)
                
                # Create record
                record = {
                    'category': category,
                    'question_hebrew': question.strip(),
                    'answer_hebrew': answer.strip(),
                    'acupoint_codes': point_codes,
                    'description_hebrew': description.strip() if description != 'nan' else None,
                    'pharmacopeia_hebrew': pharmacopeia.strip() if pharmacopeia != 'nan' else None,
                    'source_file': os.path.basename(filepath)
                }
                
                records.append(record)
                
            except Exception as e:
                print(f"  ⚠️  Error processing row {index + 1}: {str(e)}")
                continue
        
        return records
        
    except Exception as e:
        print(f"❌ Error reading file {filepath}: {str(e)}")
        return []


def upload_to_supabase(supabase: Client, records: List[Dict], batch_size: int = 100):
    """
    Upload records to Supabase in batches
    """
    total = len(records)
    uploaded = 0
    failed = 0
    
    # Upload in batches
    for i in range(0, total, batch_size):
        batch = records[i:i + batch_size]
        
        try:
            response = supabase.table(TABLE_NAME).insert(batch).execute()
            uploaded += len(batch)
            print(f"  ✅ Uploaded batch {i // batch_size + 1}: {len(batch)} records")
            
        except Exception as e:
            failed += len(batch)
            print(f"  ❌ Failed to upload batch {i // batch_size + 1}: {str(e)}")
    
    return uploaded, failed


# ========================================
# MAIN FUNCTION
# ========================================

def main():
    """
    Main function to batch upload all CSV files
    """
    print("=" * 60)
    print("TCM Clinical Assistant - CSV Batch Uploader")
    print("=" * 60)
    print()
    
    # Check configuration
    if SUPABASE_URL == "YOUR_SUPABASE_URL" or SUPABASE_KEY == "YOUR_SUPABASE_KEY":
        print("❌ ERROR: Please update SUPABASE_URL and SUPABASE_KEY in the script!")
        print()
        print("To get your credentials:")
        print("1. Go to your Supabase dashboard")
        print("2. Click 'Settings' → 'API'")
        print("3. Copy 'Project URL' and 'anon public' key")
        print()
        return
    
    # Initialize Supabase client
    try:
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected to Supabase")
        print()
    except Exception as e:
        print(f"❌ Failed to connect to Supabase: {str(e)}")
        return
    
    # Find all CSV files
    csv_files = []
    for filename in os.listdir(CSV_DIRECTORY):
        if filename.endswith('.csv'):
            filepath = os.path.join(CSV_DIRECTORY, filename)
            csv_files.append(filepath)
    
    if not csv_files:
        print(f"❌ No CSV files found in {CSV_DIRECTORY}")
        return
    
    print(f"📁 Found {len(csv_files)} CSV files:")
    for f in csv_files:
        print(f"   - {os.path.basename(f)}")
    print()
    
    # Process and upload each file
    total_uploaded = 0
    total_failed = 0
    
    for i, filepath in enumerate(csv_files, 1):
        filename = os.path.basename(filepath)
        category = get_category_from_filename(filepath)
        
        print(f"[{i}/{len(csv_files)}] Processing: {filename}")
        print(f"    Category: {category}")
        
        # Process CSV
        records = process_csv_file(filepath, category)
        
        if not records:
            print(f"  ⚠️  No valid records found in {filename}")
            print()
            continue
        
        print(f"  📊 Found {len(records)} records")
        
        # Upload to Supabase
        uploaded, failed = upload_to_supabase(supabase, records)
        total_uploaded += uploaded
        total_failed += failed
        
        print(f"  ✅ Completed: {uploaded} uploaded, {failed} failed")
        print()
    
    # Summary
    print("=" * 60)
    print("UPLOAD SUMMARY")
    print("=" * 60)
    print(f"Total files processed: {len(csv_files)}")
    print(f"Total records uploaded: {total_uploaded}")
    print(f"Total records failed: {total_failed}")
    print()
    
    if total_failed == 0:
        print("🎉 All records uploaded successfully!")
    else:
        print(f"⚠️  {total_failed} records failed to upload")
    
    print()
    print("✅ Batch upload completed!")
    print()


# ========================================
# STANDALONE CONFIGURATION CHECK
# ========================================

def test_configuration():
    """
    Test if CSV files are readable
    """
    print("Testing CSV file structure...")
    print()
    
    csv_files = [f for f in os.listdir(CSV_DIRECTORY) if f.endswith('.csv')]
    
    if not csv_files:
        print("❌ No CSV files found")
        return
    
    # Test first file
    test_file = os.path.join(CSV_DIRECTORY, csv_files[0])
    print(f"Testing: {csv_files[0]}")
    
    try:
        df = pd.read_csv(test_file, encoding='utf-8-sig', nrows=2)
        print(f"✅ File readable")
        print(f"   Columns found: {list(df.columns)}")
        print()
        
        # Check if expected columns exist
        missing_columns = []
        for col_name, col_hebrew in CSV_COLUMNS.items():
            if col_hebrew not in df.columns:
                missing_columns.append(col_hebrew)
        
        if missing_columns:
            print("⚠️  Warning: These columns are missing:")
            for col in missing_columns:
                print(f"   - {col}")
            print()
            print("You may need to update CSV_COLUMNS in the script")
        else:
            print("✅ All expected columns found!")
        
        print()
        print("Sample data:")
        print(df.head())
        
    except Exception as e:
        print(f"❌ Error reading file: {str(e)}")


# ========================================
# RUN
# ========================================

if __name__ == "__main__":
    import sys
    
    # Check if user wants to test configuration
    if len(sys.argv) > 1 and sys.argv[1] == "test":
        test_configuration()
    else:
        main()


"""
========================================
USAGE INSTRUCTIONS
========================================

1. Install requirements:
   pip install pandas supabase python-dotenv

2. Update configuration:
   - Set your SUPABASE_URL
   - Set your SUPABASE_KEY
   - Set CSV_DIRECTORY if files are in a different folder

3. Test the script (optional):
   python upload_csv_to_supabase.py test

4. Run the upload:
   python upload_csv_to_supabase.py

5. Check your Supabase dashboard to see the uploaded data!

========================================
"""
