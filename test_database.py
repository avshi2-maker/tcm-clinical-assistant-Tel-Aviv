#!/usr/bin/env python3
"""
Test TCM Database & Search Functions
"""

from supabase import create_client
from sentence_transformers import SentenceTransformer
from config import SUPABASE_URL, SUPABASE_KEY

print("🧪 TCM Database Test")
print("="*60)

# Connect to Supabase
supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
print("✅ Connected to Supabase\n")

# Check acupuncture points
print("📊 Acupuncture Points:")
try:
    response = supabase.table('acupuncture_points').select('point_code, name_he').limit(10).execute()
    print(f"   Total count: {len(response.data)} (showing first 10)")
    for point in response.data:
        print(f"   • {point['point_code']}: {point['name_he']}")
except Exception as e:
    print(f"   ❌ Error: {e}")

print()

# Check syndromes
print("📊 Zang-Fu Syndromes:")
try:
    response = supabase.table('zangfu_syndromes').select('name_he').limit(10).execute()
    print(f"   Total count: {len(response.data)} (showing first 10)")
    for syndrome in response.data:
        print(f"   • {syndrome['name_he'][:60]}...")
except Exception as e:
    print(f"   ❌ Error: {e}")

print("\n" + "="*60)
print("🔍 Testing Vector Search")
print("="*60 + "\n")

# Load embedding model
print("⏳ Loading embedding model...")
model = SentenceTransformer('all-MiniLM-L6-v2')
print("✅ Model loaded\n")

# Test query in Hebrew
test_query = "כאב ראש"  # Headache in Hebrew
print(f"🔎 Searching for: '{test_query}'")

# Generate query embedding
query_embedding = model.encode(test_query).tolist()

# Search acupuncture points
print("\n📍 Relevant Acupuncture Points:")
try:
    response = supabase.rpc(
        'match_acupuncture_points',
        {
            'query_embedding': query_embedding,
            'match_threshold': 0.5,
            'match_count': 3
        }
    ).execute()
    
    if response.data:
        for i, point in enumerate(response.data, 1):
            print(f"\n{i}. {point['point_code']} - {point['name_he']}")
            print(f"   Functions: {point['functions_he'][:100]}...")
            print(f"   Similarity: {point['similarity']:.3f}")
    else:
        print("   No results found")
except Exception as e:
    print(f"   ❌ Error: {e}")

# Search syndromes
print("\n🏥 Relevant Syndromes:")
try:
    response = supabase.rpc(
        'match_syndromes',
        {
            'query_embedding': query_embedding,
            'match_threshold': 0.5,
            'match_count': 3
        }
    ).execute()
    
    if response.data:
        for i, syndrome in enumerate(response.data, 1):
            print(f"\n{i}. {syndrome['name_he']}")
            print(f"   Symptoms: {syndrome['symptoms_he'][:100]}...")
            print(f"   Similarity: {syndrome['similarity']:.3f}")
    else:
        print("   No results found")
except Exception as e:
    print(f"   ❌ Error: {e}")

print("\n" + "="*60)
print("✅ Database test complete!")
print("="*60)
print("\nNext step: Run the Next.js app to test Claude Q&A!")
