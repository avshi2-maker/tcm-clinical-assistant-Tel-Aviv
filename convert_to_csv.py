import json
import csv

print("=" * 60)
print("CONVERTING JSON TO CSV")
print("=" * 60)
print()

print("Loading dr_roni_translations_hebrew.json...")
with open('dr_roni_translations_hebrew.json', 'r', encoding='utf-8') as f:
    translations = json.load(f)

print(f"Loaded {len(translations)} translations")
print()

csv_data = []
for point_id, data in translations.items():
    row = {
        'id': point_id,
        'point_code': data.get('point_code', ''),
        'chinese_pinyin_hebrew': data['translations'].get('chinese_pinyin_hebrew', ''),
        'english_name_hebrew': data['translations'].get('english_name_hebrew', ''),
        'etymology_hebrew': data['translations'].get('etymology_hebrew', ''),
        'description_hebrew': data['translations'].get('description_hebrew', ''),
        'location_hebrew': data['translations'].get('location_hebrew', ''),
        'needling_hebrew': data['translations'].get('needling_hebrew', ''),
        'functions_hebrew': data['translations'].get('functions_hebrew', ''),
        'secondary_functions_hebrew': data['translations'].get('secondary_functions_hebrew', ''),
        'cautions_hebrew': data['translations'].get('cautions_hebrew', ''),
        'notes_hebrew': data['translations'].get('notes_hebrew', '')
    }
    csv_data.append(row)

csv_filename = 'dr_roni_translations_upload.csv'
print(f"Writing to {csv_filename}...")

with open(csv_filename, 'w', newline='', encoding='utf-8-sig') as f:
    fieldnames = ['id', 'point_code', 'chinese_pinyin_hebrew', 'english_name_hebrew', 'etymology_hebrew', 'description_hebrew', 'location_hebrew', 'needling_hebrew', 'functions_hebrew', 'secondary_functions_hebrew', 'cautions_hebrew', 'notes_hebrew']
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(csv_data)

print("CSV created successfully!")
print()
print("NEXT STEPS:")
print("1. Go to Supabase dashboard")
print("2. Table Editor -> dr_roni_complete")
print("3. Import CSV")
print()
input("Press Enter to exit...")
