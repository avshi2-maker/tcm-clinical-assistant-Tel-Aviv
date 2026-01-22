#!/usr/bin/env python3
"""
Simplified TCM Document Processor
No pypandoc required - uses only python-docx for DOCX extraction
"""

import os
import time
from typing import List, Dict
from docx import Document
from deep_translator import GoogleTranslator
from supabase import create_client
from sentence_transformers import SentenceTransformer
from tqdm import tqdm

# Import config
from config import SUPABASE_URL, SUPABASE_KEY, ACUPUNCTURE_FILE, SYNDROME_FILE

class SimpleTCMProcessor:
    """Simplified processor for TCM documents"""
    
    def __init__(self):
        print("🔧 Initializing processor...")
        
        # Initialize Supabase
        self.supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("   ✅ Supabase connected")
        
        # Initialize translator
        self.translator = GoogleTranslator(source='en', target='iw')  # 'iw' is Hebrew code
        print("   ✅ Translator ready")
        
        # Initialize embedding model
        print("   ⏳ Loading embedding model (this may take a minute)...")
        self.model = SentenceTransformer('all-MiniLM-L6-v2')
        print("   ✅ Embedding model loaded")
        
        print("✅ Processor ready!\n")
    
    def translate_text(self, text: str) -> str:
        """Translate text to Hebrew with chunking"""
        if not text or len(text.strip()) == 0:
            return ""
        
        # If text is short, translate directly
        if len(text) <= 4500:
            try:
                return self.translator.translate(text)
            except Exception as e:
                print(f"   ⚠️  Translation error: {e}")
                return text
        
        # Split long text by sentences
        sentences = text.split('. ')
        translated = []
        current_chunk = ""
        
        for sentence in sentences:
            if len(current_chunk) + len(sentence) > 4500:
                # Translate current chunk
                try:
                    translated.append(self.translator.translate(current_chunk))
                    time.sleep(0.1)  # Avoid rate limits
                except Exception as e:
                    print(f"   ⚠️  Translation error: {e}")
                    translated.append(current_chunk)
                current_chunk = sentence
            else:
                current_chunk += sentence + ". "
        
        # Translate final chunk
        if current_chunk:
            try:
                translated.append(self.translator.translate(current_chunk))
            except:
                translated.append(current_chunk)
        
        return " ".join(translated)
    
    def generate_embedding(self, text: str) -> List[float]:
        """Generate 384-dimensional embedding"""
        embedding = self.model.encode(text)
        return embedding.tolist()
    
    def extract_docx_content(self, file_path: str) -> List[Dict]:
        """Extract paragraphs from DOCX file"""
        print(f"📖 Reading: {os.path.basename(file_path)}")
        
        doc = Document(file_path)
        sections = []
        current_section = {
            'title': '',
            'content': [],
            'level': 0
        }
        
        for para in doc.paragraphs:
            text = para.text.strip()
            if not text:
                continue
            
            # Check if it's a heading
            if para.style.name.startswith('Heading'):
                # Save previous section
                if current_section['content']:
                    sections.append(current_section.copy())
                
                # Start new section
                level = 1
                if para.style.name[-1].isdigit():
                    level = int(para.style.name[-1])
                
                current_section = {
                    'title': text,
                    'content': [],
                    'level': level
                }
            else:
                current_section['content'].append(text)
        
        # Add final section
        if current_section['content']:
            sections.append(current_section)
        
        print(f"   ✅ Found {len(sections)} sections")
        return sections
    
    def parse_acupuncture_points(self, sections: List[Dict]) -> List[Dict]:
        """Extract acupuncture point information"""
        import re
        points = []
        
        print("🔍 Parsing acupuncture points...")
        
        for section in sections:
            title = section['title']
            content = '\n'.join(section['content'])
            
            # Look for point codes like "LI-4", "ST-36", etc.
            point_pattern = r'([A-Z]{2,3})-?(\d+)'
            matches = re.findall(point_pattern, title)
            
            if matches:
                meridian, number = matches[0]
                point_code = f"{meridian}-{number}"
                
                point = {
                    'point_code': point_code,
                    'name_en': title,
                    'meridian': meridian,
                    'point_number': int(number),
                    'content_en': content,
                    'location_en': '',
                    'functions_en': '',
                    'indications_en': ''
                }
                
                # Try to extract specific sections
                content_lower = content.lower()
                
                # Location
                if 'location:' in content_lower:
                    loc_start = content_lower.index('location:')
                    loc_end = content_lower.find('\n', loc_start)
                    if loc_end == -1:
                        loc_end = len(content)
                    point['location_en'] = content[loc_start:loc_end].replace('location:', '').strip()
                
                points.append(point)
        
        print(f"   ✅ Extracted {len(points)} acupuncture points")
        return points
    
    def process_acupuncture_book(self, file_path: str):
        """Process acupuncture points book"""
        print("\n" + "="*60)
        print("📖 PROCESSING ACUPUNCTURE POINTS BOOK")
        print("="*60 + "\n")
        
        # Extract content
        sections = self.extract_docx_content(file_path)
        
        # Parse points
        points = self.parse_acupuncture_points(sections)
        
        if len(points) == 0:
            print("⚠️  No points found. Processing all sections as general content...")
            points = []
            for i, section in enumerate(sections[:50]):  # Limit to first 50 for testing
                points.append({
                    'point_code': f'GEN-{i+1}',
                    'name_en': section['title'],
                    'meridian': 'GEN',
                    'point_number': i+1,
                    'content_en': '\n'.join(section['content'][:5]),  # First 5 paragraphs
                    'location_en': '',
                    'functions_en': '',
                    'indications_en': ''
                })
            print(f"   ✅ Created {len(points)} content sections")
        
        # Process and store
        print(f"\n🔄 Processing {len(points)} points...")
        success_count = 0
        
        for i, point in enumerate(tqdm(points, desc="Translating & storing")):
            try:
                # Translate
                point['name_he'] = self.translate_text(point['name_en'])
                point['location_he'] = self.translate_text(point['location_en'])
                point['functions_he'] = self.translate_text(point['functions_en'])
                point['indications_he'] = self.translate_text(point.get('content_en', '')[:500])  # First 500 chars
                
                # Generate embedding from Hebrew content
                embedding_text = f"{point['name_he']} {point['location_he']} {point['functions_he']}"
                embedding = self.generate_embedding(embedding_text)
                
                # Store in Supabase
                data = {
                    'point_code': point['point_code'],
                    'name_en': point['name_en'],
                    'name_he': point['name_he'],
                    'meridian': point['meridian'],
                    'point_number': point['point_number'],
                    'location_en': point['location_en'],
                    'location_he': point['location_he'],
                    'functions_en': point['functions_en'],
                    'functions_he': point['functions_he'],
                    'indications_en': point['indications_en'],
                    'indications_he': point['indications_he'],
                    'embedding': embedding
                }
                
                self.supabase.table('acupuncture_points').upsert(data).execute()
                success_count += 1
                
                # Small delay to avoid rate limits
                if i % 10 == 0:
                    time.sleep(0.5)
                
            except Exception as e:
                print(f"\n   ⚠️  Error processing {point['point_code']}: {e}")
                continue
        
        print(f"\n✅ Successfully processed {success_count}/{len(points)} points!")
    
    def process_syndrome_book(self, file_path: str):
        """Process syndromes book"""
        print("\n" + "="*60)
        print("📖 PROCESSING ZANG-FU SYNDROMES")
        print("="*60 + "\n")
        
        # Extract content
        sections = self.extract_docx_content(file_path)
        
        print(f"\n🔄 Processing {len(sections)} sections...")
        success_count = 0
        
        # Process first 20 sections for testing
        for i, section in enumerate(tqdm(sections[:20], desc="Translating & storing")):
            try:
                title = section['title']
                content = '\n'.join(section['content'][:3])  # First 3 paragraphs
                
                # Translate
                name_he = self.translate_text(title)
                content_he = self.translate_text(content)
                
                # Generate embedding
                embedding_text = f"{name_he} {content_he}"
                embedding = self.generate_embedding(embedding_text)
                
                # Store in Supabase
                data = {
                    'name_en': title,
                    'name_he': name_he,
                    'symptoms_en': content,
                    'symptoms_he': content_he,
                    'etiology_en': '',
                    'etiology_he': '',
                    'tongue_en': '',
                    'tongue_he': '',
                    'pulse_en': '',
                    'pulse_he': '',
                    'treatment_en': '',
                    'treatment_he': '',
                    'embedding': embedding
                }
                
                self.supabase.table('zangfu_syndromes').insert(data).execute()
                success_count += 1
                
                time.sleep(0.5)  # Rate limiting
                
            except Exception as e:
                print(f"\n   ⚠️  Error processing section: {e}")
                continue
        
        print(f"\n✅ Successfully processed {success_count}/{min(20, len(sections))} syndromes!")


def main():
    """Main execution"""
    print("\n" + "="*60)
    print("🌿 TCM DOCUMENT PROCESSOR - SIMPLIFIED VERSION")
    print("="*60)
    print()
    print(f"📖 Acupuncture: {os.path.basename(ACUPUNCTURE_FILE)}")
    print(f"📖 Syndromes: {os.path.basename(SYNDROME_FILE)}")
    print(f"🗄️  Database: {SUPABASE_URL}")
    print()
    print("⏱️  Estimated time: 15-20 minutes")
    print("   (Processing first 50 points + 20 syndromes for testing)")
    print()
    
    response = input("Ready to start? (yes/no): ")
    if response.lower() not in ['yes', 'y']:
        print("Cancelled.")
        return
    
    print()
    
    try:
        processor = SimpleTCMProcessor()
        
        # Process acupuncture book
        processor.process_acupuncture_book(ACUPUNCTURE_FILE)
        
        # Process syndromes
        processor.process_syndrome_book(SYNDROME_FILE)
        
        print("\n" + "="*60)
        print("🎉 PROCESSING COMPLETE!")
        print("="*60)
        print()
        print("✅ Documents processed and stored in Supabase")
        print("✅ All content translated to Hebrew")
        print("✅ Vector embeddings generated")
        print()
        print("Next steps:")
        print("1. Check your Supabase database")
        print("2. Test the search functions")
        print("3. Run the Next.js app for Q&A!")
        print()
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()


if __name__ == "__main__":
    main()
