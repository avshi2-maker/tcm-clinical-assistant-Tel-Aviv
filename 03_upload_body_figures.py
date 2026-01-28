#!/usr/bin/env python3
"""
TCM Clinical Assistant - Body Figures Upload Script
Uploads body diagram images to Supabase Storage and updates database
Author: Claude AI for TCM Clinic
Date: January 2026
"""

import os
import sys
from pathlib import Path
from supabase import create_client, Client

# ============================================================================
# CONFIGURATION
# ============================================================================

SUPABASE_URL = "https://iqfglrwjemogoycbzltt.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTM4ODMsImV4cCI6MjA4NDEyOTg4M30.DTREv3efs86_HzESyWm-7480ImfEVgC6T-xBdS6A2F8"

STORAGE_BUCKET = "body-figures"  # Create this bucket in Supabase Storage first!

# Map filenames to database figure_name
FIGURE_MAPPING = {
    # Your image filenames → database figure_name
    "full_body_front.png": "full_body_anterior",
    "full_body_back.png": "full_body_posterior",
    "head_face_front.png": "head_face_anterior",
    "arm_hand_side.png": "hand_arm_lateral",
    "leg_foot_side.png": "leg_foot_lateral",
    
    # Add more mappings as you have images
    # "your_image_file.png": "database_figure_name"
}

# ============================================================================
# FUNCTIONS
# ============================================================================

def create_storage_bucket(supabase: Client):
    """Create the storage bucket if it doesn't exist"""
    try:
        # Try to create bucket (will fail if exists, which is fine)
        supabase.storage.create_bucket(STORAGE_BUCKET, {
            'public': True,  # Make images publicly accessible
            'file_size_limit': 10485760,  # 10MB limit
            'allowed_mime_types': ['image/png', 'image/jpeg', 'image/jpg', 'image/svg+xml']
        })
        print(f"✅ Created bucket: {STORAGE_BUCKET}")
    except Exception as e:
        if "already exists" in str(e).lower():
            print(f"✅ Bucket already exists: {STORAGE_BUCKET}")
        else:
            print(f"⚠️  Bucket creation: {str(e)}")

def upload_image(supabase: Client, local_path: str, figure_name: str):
    """
    Upload a body figure image to Supabase Storage
    """
    filename = os.path.basename(local_path)
    storage_path = f"{figure_name}/{filename}"
    
    try:
        # Read file
        with open(local_path, 'rb') as f:
            file_data = f.read()
        
        # Determine content type
        ext = Path(local_path).suffix.lower()
        content_types = {
            '.png': 'image/png',
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg',
            '.svg': 'image/svg+xml'
        }
        content_type = content_types.get(ext, 'image/png')
        
        # Upload to Supabase Storage
        result = supabase.storage.from_(STORAGE_BUCKET).upload(
            storage_path,
            file_data,
            {
                'content-type': content_type,
                'upsert': 'true'  # Overwrite if exists
            }
        )
        
        # Get public URL
        public_url = supabase.storage.from_(STORAGE_BUCKET).get_public_url(storage_path)
        
        print(f"  ✅ Uploaded: {filename}")
        print(f"     URL: {public_url}")
        
        return public_url
        
    except Exception as e:
        print(f"  ❌ Error uploading {filename}: {str(e)}")
        return None

def update_database(supabase: Client, figure_name: str, image_url: str):
    """
    Update the body_figures table with the image URL
    """
    try:
        result = supabase.table('body_figures').update({
            'image_url': image_url,
            'updated_at': 'NOW()'
        }).eq('figure_name', figure_name).execute()
        
        if result.data:
            print(f"  ✅ Updated database for: {figure_name}")
            return True
        else:
            print(f"  ⚠️  No figure found in database: {figure_name}")
            return False
            
    except Exception as e:
        print(f"  ❌ Database update error: {str(e)}")
        return False

def process_images(images_folder: str):
    """
    Main function to process all images
    """
    print("="*60)
    print("🫀 TCM BODY FIGURES UPLOAD")
    print("="*60)
    
    # Connect to Supabase
    try:
        supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Connected to Supabase")
    except Exception as e:
        print(f"❌ Failed to connect: {str(e)}")
        return
    
    # Create storage bucket
    create_storage_bucket(supabase)
    
    # Check if images folder exists
    if not os.path.exists(images_folder):
        print(f"\n❌ Folder not found: {images_folder}")
        print("   Create this folder and put your body figure images in it!")
        return
    
    # Process each image
    print(f"\n📂 Processing images from: {images_folder}\n")
    
    uploaded_count = 0
    updated_count = 0
    
    for filename, figure_name in FIGURE_MAPPING.items():
        filepath = os.path.join(images_folder, filename)
        
        print(f"📤 Processing: {filename}")
        print(f"   → Figure: {figure_name}")
        
        if not os.path.exists(filepath):
            print(f"  ⚠️  File not found, skipping...")
            continue
        
        # Upload image
        image_url = upload_image(supabase, filepath, figure_name)
        
        if image_url:
            uploaded_count += 1
            
            # Update database
            if update_database(supabase, figure_name, image_url):
                updated_count += 1
        
        print()  # Blank line
    
    # Summary
    print("="*60)
    print("✅ UPLOAD COMPLETE!")
    print("="*60)
    print(f"📤 Images uploaded: {uploaded_count}")
    print(f"💾 Database updated: {updated_count}")
    print("="*60)
    
    # Show how to access
    if uploaded_count > 0:
        print("\n🌐 Access your images:")
        print(f"   Supabase Dashboard → Storage → {STORAGE_BUCKET}")
        print(f"   Public URL format: {SUPABASE_URL}/storage/v1/object/public/{STORAGE_BUCKET}/...")

# ============================================================================
# MAIN
# ============================================================================

if __name__ == "__main__":
    print("\n" + "="*60)
    print("  TCM CLINICAL ASSISTANT - BODY FIGURES UPLOADER")
    print("="*60 + "\n")
    
    # Get images folder from command line or use default
    if len(sys.argv) > 1:
        images_folder = sys.argv[1]
    else:
        images_folder = "./body_figures_images"
    
    print(f"📁 Images folder: {images_folder}\n")
    
    # Instructions
    print("📋 INSTRUCTIONS:")
    print("1. Create folder: " + images_folder)
    print("2. Put your body figure images in it")
    print("3. Update FIGURE_MAPPING in this script to match your filenames")
    print("4. Run: python 03_upload_body_figures.py\n")
    
    input("Press ENTER to start upload (or Ctrl+C to cancel)...")
    
    # Process
    process_images(images_folder)
    
    print("\n✅ Done!\n")
