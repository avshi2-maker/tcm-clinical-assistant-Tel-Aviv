#!/usr/bin/env python3
"""
Supabase Database Backup Script
Exports all data to JSON files for backup
"""

import json
from datetime import datetime
from supabase import create_client
from config import SUPABASE_URL, SUPABASE_KEY

def backup_database():
    """Backup all tables to JSON files"""
    
    print("🗄️  Starting Supabase Backup...")
    
    # Connect
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    # Create backup folder with timestamp
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_folder = f"backup_{timestamp}"
    
    import os
    os.makedirs(backup_folder, exist_ok=True)
    
    print(f"📁 Backup folder: {backup_folder}")
    
    # Backup acupuncture points
    print("\n📍 Backing up acupuncture points...")
    try:
        response = supabase.table('acupuncture_points').select('*').execute()
        with open(f"{backup_folder}/acupuncture_points.json", 'w', encoding='utf-8') as f:
            json.dump(response.data, f, ensure_ascii=False, indent=2)
        print(f"   ✅ Saved {len(response.data)} acupuncture points")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # Backup syndromes
    print("\n🏥 Backing up zang-fu syndromes...")
    try:
        response = supabase.table('zangfu_syndromes').select('*').execute()
        with open(f"{backup_folder}/zangfu_syndromes.json", 'w', encoding='utf-8') as f:
            json.dump(response.data, f, ensure_ascii=False, indent=2)
        print(f"   ✅ Saved {len(response.data)} syndromes")
    except Exception as e:
        print(f"   ❌ Error: {e}")
    
    # Backup TCM documents (if exists)
    print("\n📚 Backing up TCM documents...")
    try:
        response = supabase.table('tcm_documents').select('*').execute()
        if response.data:
            with open(f"{backup_folder}/tcm_documents.json", 'w', encoding='utf-8') as f:
                json.dump(response.data, f, ensure_ascii=False, indent=2)
            print(f"   ✅ Saved {len(response.data)} documents")
        else:
            print("   ℹ️  No documents in table")
    except Exception as e:
        print(f"   ⚠️  Table might not exist: {e}")
    
    print("\n" + "="*60)
    print("✅ Backup Complete!")
    print("="*60)
    print(f"\n📁 Backup saved to: {backup_folder}/")
    print("\nBackup contains:")
    print("  - acupuncture_points.json")
    print("  - zangfu_syndromes.json")
    print("  - tcm_documents.json (if exists)")
    print("\n⚠️  Store this backup in a SECURE location!")
    print("   (These files contain your database content)")

if __name__ == "__main__":
    backup_database()