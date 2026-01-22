#!/usr/bin/env python3
"""
Simple Document Processor Runner
Run this from your tcm-clinical-assistant-Tel-Aviv folder
"""

import os
import sys
from pathlib import Path

# Add current directory to path
sys.path.insert(0, str(Path(__file__).parent))

# Import configuration
try:
    from config import SUPABASE_URL, SUPABASE_KEY, ACUPUNCTURE_FILE, SYNDROME_FILE
except ImportError:
    print("❌ Error: config.py not found!")
    print("Make sure config.py is in the same folder as this script.")
    sys.exit(1)

# Verify files exist
if not os.path.exists(ACUPUNCTURE_FILE):
    print(f"❌ Error: Cannot find {ACUPUNCTURE_FILE}")
    sys.exit(1)

if not os.path.exists(SYNDROME_FILE):
    print(f"❌ Error: Cannot find {SYNDROME_FILE}")
    sys.exit(1)

print("=" * 60)
print("🌿 TCM Document Processor")
print("=" * 60)
print()
print(f"📖 Acupuncture file: {os.path.basename(ACUPUNCTURE_FILE)}")
print(f"📖 Syndromes file: {os.path.basename(SYNDROME_FILE)}")
print(f"🗄️  Database: {SUPABASE_URL}")
print()
print("⏱️  Estimated time: 25-30 minutes")
print()

response = input("Ready to start processing? (yes/no): ")
if response.lower() not in ['yes', 'y']:
    print("Cancelled.")
    sys.exit(0)

print()
print("🚀 Starting document processing...")
print()

# Import the main processor
try:
    from tcm_document_processor import TCMProcessor
    import asyncio
except ImportError as e:
    print(f"❌ Error importing modules: {e}")
    print()
    print("Make sure you've installed all dependencies:")
    print("  pip install -r requirements.txt --break-system-packages")
    sys.exit(1)

# Run the processor
async def main():
    processor = TCMProcessor(SUPABASE_URL, SUPABASE_KEY)
    
    try:
        # Process acupuncture book
        print("📖 Processing Acupuncture Points Book...")
        await processor.process_acupuncture_book(ACUPUNCTURE_FILE)
        print("✅ Acupuncture points processed!")
        print()
        
        # Process syndromes book
        print("📖 Processing Zang-Fu Syndromes...")
        await processor.process_syndrome_book(SYNDROME_FILE)
        print("✅ Syndromes processed!")
        print()
        
        print("=" * 60)
        print("🎉 All documents processed successfully!")
        print("=" * 60)
        print()
        print("Next steps:")
        print("1. Check your Supabase database")
        print("2. Run the Next.js app to test Q&A")
        print("3. Ask questions in Hebrew!")
        
    except Exception as e:
        print(f"❌ Error during processing: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
