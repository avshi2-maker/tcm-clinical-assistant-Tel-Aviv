import json

print("Creating SQL UPDATE statements...")

with open('dr_roni_translations_hebrew.json', 'r', encoding='utf-8') as f:
    translations = json.load(f)

sql_statements = []

for point_id, data in translations.items():
    trans = data['translations']
    
    # Escape single quotes for SQL
    def escape(text):
        if text is None:
            return ''
        return text.replace("'", "''")
    
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