import json
import sys

print("=" * 60)
print("Creating SQL UPDATE statements...")
print("=" * 60)
print()

try:
    with open('dr_roni_translations_hebrew.json', 'r', encoding='utf-8') as f:
        translations = json.load(f)
    print(f"Loaded {len(translations)} translations")
except Exception as e:
    print(f"ERROR: {e}")
    sys.exit(1)

def escape(text):
    if text is None or text == '':
        return ''
    text = str(text)
    text = text.replace("\\", "\\\\")
    text = text.replace("'", "''")
    return text

sql_statements = []
count = 0

for point_id, data in translations.items():
    trans = data['translations']
    count += 1
    
    sql = f"""UPDATE dr_roni_complete SET
    chinese_pinyin_hebrew = '{escape(trans.get('chinese_pinyin_hebrew', ''))}',
    english_name_hebrew = '{escape(trans.get('english_name_hebrew', ''))}',
    etymology_hebrew = '{escape(trans.get('etymology_hebrew', ''))}',
    description_hebrew = '{escape(trans.get('description_hebrew', ''))}',
    location_hebrew = '{escape(trans.get('location_hebrew', ''))}',
    needling_hebrew = '{escape(trans.get('needling_hebrew', ''))}',
    functions_hebrew = '{escape(trans.get('functions_hebrew', ''))}',
    secondary_functions_hebrew = '{escape(trans.get('secondary_functions_hebrew', ''))}',
    cautions_hebrew = '{escape(trans.get('cautions_hebrew', ''))}',
    notes_hebrew = '{escape(trans.get('notes_hebrew', ''))}' 
WHERE id = {point_id};"""
    
    sql_statements.append(sql)
    
    if count % 10 == 0:
        print(f"Processed {count}/{len(translations)} points...")

print()
print(f"Writing SQL file...")

try:
    with open('update_translations.sql', 'w', encoding='utf-8') as f:
        f.write('-- Hebrew Translations Update\n')
        f.write('-- Total updates: ' + str(len(sql_statements)) + '\n\n')
        f.write('\n\n'.join(sql_statements))
    
    print(f"SUCCESS!")
    print(f"Created: update_translations.sql")
    print(f"Total statements: {len(sql_statements)}")
    print()
    print("NEXT STEPS:")
    print("1. Open Supabase SQL Editor")
    print("2. Copy/paste the SQL file content")
    print("3. Run it!")
    print()
except Exception as e:
    print(f"ERROR writing file: {e}")

input("Press Enter to exit...")
