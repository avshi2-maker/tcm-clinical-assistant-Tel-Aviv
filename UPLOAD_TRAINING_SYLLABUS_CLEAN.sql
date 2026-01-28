-- ========================================
-- TCM TRAINING SYLLABUS
-- Clean upload script - 48 training Q&A
-- ========================================

-- Create table
CREATE TABLE IF NOT EXISTS tcm_training_syllabus (
    id TEXT PRIMARY KEY,
    category TEXT NOT NULL,
    number INTEGER,
    name_hebrew TEXT NOT NULL,
    name_english TEXT NOT NULL,
    pinyin TEXT,
    clinical_description TEXT,
    acupuncture_points TEXT,
    treatment_principle TEXT,
    question_hebrew TEXT,
    question_english TEXT,
    body_system TEXT,
    difficulty_level TEXT,
    clinical_priority TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_syllabus_category ON tcm_training_syllabus(category);
CREATE INDEX IF NOT EXISTS idx_syllabus_difficulty ON tcm_training_syllabus(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_syllabus_priority ON tcm_training_syllabus(clinical_priority);

-- Clear existing data
TRUNCATE TABLE tcm_training_syllabus;

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P001', 'Pulse Diagnosis', 1, 'דופק צף', 'Floating Pulse', 'Fu Mai', 'Felt superficially, external pathogen', 'LI4, LU7, GB20, DU14', 'Release exterior, disperse Wind', '?מהו דופק צף ומה המשמעות הקלינית שלו', 'What is Floating Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P002', 'Pulse Diagnosis', 2, 'דופק עמוק', 'Deep Pulse', 'Chen Mai', 'Only felt with heavy pressure, interior condition', 'CV12, ST36, SP6, BL20', 'Tonify interior, strengthen Qi', '?מהו דופק עמוק ומה המשמעות הקלינית שלו', 'What is Deep Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P003', 'Pulse Diagnosis', 3, 'דופק איטי', 'Slow Pulse', 'Chi Mai', '<60 bpm, Cold or Yang deficiency', 'CV4, CV6, ST36, BL23 + moxa', 'Warm Yang, disperse Cold', '?מהו דופק איטי ומה המשמעות הקלינית שלו', 'What is Slow Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P004', 'Pulse Diagnosis', 4, 'דופק מהיר', 'Rapid Pulse', 'Shuo Mai', '>90 bpm, Heat or Yin deficiency', 'LI11, GV14, KI6, HT8', 'Clear heat, cool Blood', '?מהו דופק מהיר ומה המשמעות הקלינית שלו', 'What is Rapid Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P005', 'Pulse Diagnosis', 5, 'דופק מלא', 'Full Pulse', 'Shi Mai', 'Strong at all levels, excess syndrome', 'LI11, ST44, LI4, ST25', 'Reduce excess, drain', '?מהו דופק מלא ומה המשמעות הקלינית שלו', 'What is Full Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P006', 'Pulse Diagnosis', 6, 'דופק ריק', 'Empty Pulse', 'Xu Mai', 'Weak, deficiency syndrome', 'CV12, CV6, ST36, SP6, BL20', 'Tonify Qi and Blood', '?מהו דופק ריק ומה המשמעות הקלינית שלו', 'What is Empty Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P007', 'Pulse Diagnosis', 7, 'דופק חלקלק', 'Slippery Pulse', 'Hua Mai', 'Smooth flow, Phlegm or pregnancy', 'ST40, SP9, CV12, LU5', 'Resolve Phlegm, dry Dampness', '?מהו דופק חלקלק ומה המשמעות הקלינית שלו', 'What is Slippery Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P008', 'Pulse Diagnosis', 8, 'דופק מחוספס', 'Choppy Pulse', 'Se Mai', 'Rough, Blood stasis or deficiency', 'SP10, SP6, LV3, BL17', 'Move Blood, break stasis', '?מהו דופק מחוספס ומה המשמעות הקלינית שלו', 'What is Choppy Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P009', 'Pulse Diagnosis', 9, 'דופק ארוך', 'Long Pulse', 'Chang Mai', 'Extends beyond normal position, excess or health', 'LV3, GB34, LI4', 'Soothe Liver, move Qi', '?מהו דופק ארוך ומה המשמעות הקלינית שלו', 'What is Long Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P010', 'Pulse Diagnosis', 10, 'דופק קצר', 'Short Pulse', 'Duan Mai', 'Shorter than normal, Qi deficiency', 'CV6, ST36, LU9, PC6', 'Tonify Qi, regulate', '?מהו דופק קצר ומה המשמעות הקלינית שלו', 'What is Short Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P011', 'Pulse Diagnosis', 11, 'דופק חוטי', 'Thready Pulse', 'Xi Mai', 'Thin like thread, Blood/Yin deficiency', 'SP6, ST36, BL17, BL20, LV8', 'Build Blood, nourish Yin', '?מהו דופק חוטי ומה המשמעות הקלינית שלו', 'What is Thready Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P012', 'Pulse Diagnosis', 12, 'דופק רחב', 'Large Pulse', 'Hong Mai', 'Wide and large, excess heat', 'LI11, ST44, DU14, LI4', 'Clear excess heat', '?מהו דופק רחב ומה המשמעות הקלינית שלו', 'What is Large Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P013', 'Pulse Diagnosis', 13, 'דופק מתוח', 'Wiry Pulse', 'Xian Mai', 'Taut like string, Liver Qi stagnation', 'LV3, LV14, GB34, PC6', 'Soothe Liver, move Qi', '?מהו דופק מתוח ומה המשמעות הקלינית שלו', 'What is Wiry Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P014', 'Pulse Diagnosis', 14, 'דופק מהודק', 'Tight Pulse', 'Jin Mai', 'Tighter than wiry, Cold or pain', 'CV6, ST36, SP6 + moxa', 'Warm meridians, stop pain', '?מהו דופק מהודק ומה המשמעות הקלינית שלו', 'What is Tight Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P015', 'Pulse Diagnosis', 15, 'דופק רך', 'Soft Pulse', 'Ru Mai', 'Soft and floating, Dampness', 'SP9, SP6, ST36, CV12', 'Strengthen Spleen, dry Damp', '?מהו דופק רך ומה המשמעות הקלינית שלו', 'What is Soft Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P016', 'Pulse Diagnosis', 16, 'דופק חלוש', 'Weak Pulse', 'Ruo Mai', 'Deep and weak, Qi-Blood deficiency', 'CV4, CV6, ST36, SP6, BL20, BL23', 'Tonify Qi and Blood deeply', '?מהו דופק חלוש ומה המשמעות הקלינית שלו', 'What is Weak Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P017', 'Pulse Diagnosis', 17, 'דופק מפוזר', 'Scattered Pulse', 'San Mai', 'Irregular and unfocused, Qi collapse', 'CV4, CV6, CV8 + heavy moxa', 'Emergency rescue Qi', '?מהו דופק מפוזר ומה המשמעות הקלינית שלו', 'What is Scattered Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P018', 'Pulse Diagnosis', 18, 'דופק מפסיק', 'Intermittent Pulse', 'Dai Mai', 'Regular rhythm with stops, Heart deficiency', 'HT7, PC6, CV17, BL15', 'Calm Heart, tonify', '?מהו דופק מפסיק ומה המשמעות הקלינית שלו', 'What is Intermittent Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P019', 'Pulse Diagnosis', 19, 'דופק נמהר', 'Hasty Pulse', 'Cu Mai', 'Rapid with irregular stops, excess heat', 'HT8, PC8, HT7, LI11', 'Clear Heart fire', '?מהו דופק נמהר ומה המשמעות הקלינית שלו', 'What is Hasty Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P020', 'Pulse Diagnosis', 20, 'דופק קשור', 'Knotted Pulse', 'Jie Mai', 'Slow with irregular stops, Cold or stasis', 'CV4, CV6, SP6 + moxa, LV3', 'Warm Yang, move Blood', '?מהו דופק קשור ומה המשמעות הקלינית שלו', 'What is Knotted Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P021', 'Pulse Diagnosis', 21, 'דופק עורי', 'Leather Pulse', 'Ge Mai', 'Hollow and hard, blood loss', 'SP1, BL17, ST36, SP6', 'Stop bleeding, build Blood', '?מהו דופק עורי ומה המשמעות הקלינית שלו', 'What is Leather Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P022', 'Pulse Diagnosis', 22, 'דופק איתן', 'Firm Pulse', 'Lao Mai', 'Deep, wiry, long; interior cold-stasis', 'CV4, CV6, SP6, SP10 + moxa', 'Warm, move Blood', '?מהו דופק איתן ומה המשמעות הקלינית שלו', 'What is Firm Pulse and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('P023', 'Pulse Diagnosis', 23, 'דופק שעועית', 'Spinning Bean', 'Dong Mai', 'Short, slippery, rapid; pain/fright', 'HT7, PC6, CV17, SP6', 'Calm Spirit, stop pain', '?מהו דופק שעועית ומה המשמעות הקלינית שלו', 'What is Spinning Bean and what is its clinical significance?', 'Cardiovascular/Qi-Blood', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T001', 'Tongue Diagnosis', 1, 'לשון חיוורת', 'Pale Tongue', '-', 'Blood/Qi deficiency, Cold', 'SP6, ST36, BL20, BL17, CV4', 'Tonify Blood and Qi', '?מה מעידה לשון חיוורת על מצב המטופל', 'What does Pale Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T002', 'Tongue Diagnosis', 2, 'לשון אדומה', 'Red Tongue', '-', 'Heat, Yin deficiency', 'KI6, SP6, LI11, HT8', 'Clear heat, nourish Yin', '?מה מעידה לשון אדומה על מצב המטופל', 'What does Red Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T003', 'Tongue Diagnosis', 3, 'לשון אדומה כהה', 'Dark Red Tongue', '-', 'Extreme heat, severe Yin deficiency', 'KI3, KI6, LI11, DU14, HT7', 'Strongly clear heat, rescue Yin', '?מה מעידה לשון אדומה כהה על מצב המטופל', 'What does Dark Red Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T004', 'Tongue Diagnosis', 4, 'לשון סגולה', 'Purple Tongue', '-', 'Blood stasis, Cold stagnation', 'SP10, LV3, SP6, BL17', 'Move Blood, break stasis', '?מה מעידה לשון סגולה על מצב המטופל', 'What does Purple Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T005', 'Tongue Diagnosis', 5, 'לשון כחולה', 'Blue Tongue', '-', 'Severe Cold, blood stagnation', 'CV4, CV6, SP6 + heavy moxa', 'Emergency warm Yang', '?מה מעידה לשון כחולה על מצב המטופל', 'What does Blue Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T006', 'Tongue Diagnosis', 6, 'ציפוי לבן דק', 'Thin White Coating', '-', 'Normal or slight exterior Cold', 'LI4, LU7, if pathogen present', 'Release exterior if needed', '?מה מעידה ציפוי לבן דק על מצב המטופל', 'What does Thin White Coating indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T007', 'Tongue Diagnosis', 7, 'ציפוי לבן עבה', 'Thick White Coating', '-', 'Cold-Dampness, Phlegm', 'CV12, ST40, SP9, SP6', 'Transform Phlegm-Damp', '?מה מעידה ציפוי לבן עבה על מצב המטופל', 'What does Thick White Coating indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T008', 'Tongue Diagnosis', 8, 'ציפוי צהוב', 'Yellow Coating', '-', 'Heat, Damp-Heat', 'LI11, ST44, SP9, LV2', 'Clear heat, dry Dampness', '?מה מעידה ציפוי צהוב על מצב המטופל', 'What does Yellow Coating indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T009', 'Tongue Diagnosis', 9, 'ציפוי אפור/שחור', 'Grey/Black Coating', '-', 'Extreme heat or extreme cold', 'Varies - check pulse and symptoms', 'Emergency treatment', '?מה מעידה ציפוי אפור/שחור על מצב המטופל', 'What does Grey/Black Coating indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T010', 'Tongue Diagnosis', 10, 'ללא ציפוי', 'No Coating', '-', 'Stomach/Kidney Yin deficiency', 'ST36, KI3, KI6, SP6', 'Nourish Yin, generate fluids', '?מה מעידה ללא ציפוי על מצב המטופל', 'What does No Coating indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T011', 'Tongue Diagnosis', 11, 'לשון נפוחה', 'Swollen Tongue', '-', 'Spleen deficiency, Dampness', 'SP9, SP6, ST36, CV12', 'Strengthen Spleen, drain Damp', '?מה מעידה לשון נפוחה על מצב המטופל', 'What does Swollen Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T012', 'Tongue Diagnosis', 12, 'לשון דקה', 'Thin Tongue', '-', 'Blood/Yin deficiency', 'SP6, ST36, BL17, BL20, KI3', 'Tonify Blood and Yin', '?מה מעידה לשון דקה על מצב המטופל', 'What does Thin Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T013', 'Tongue Diagnosis', 13, 'לשון נוקשה', 'Stiff Tongue', '-', 'Wind-stroke, heat in Heart', 'DU20, GB20, HT7, PC6, LV3', 'Extinguish Wind, open orifices', '?מה מעידה לשון נוקשה על מצב המטופל', 'What does Stiff Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T014', 'Tongue Diagnosis', 14, 'לשון רועדת', 'Trembling Tongue', '-', 'Spleen Qi deficiency, Wind', 'CV12, ST36, SP6, DU20', 'Tonify Spleen, calm Wind', '?מה מעידה לשון רועדת על מצב המטופל', 'What does Trembling Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T015', 'Tongue Diagnosis', 15, 'לשון סדוקה', 'Cracked Tongue', '-', 'Yin deficiency, heat injury', 'KI3, KI6, SP6, LU5', 'Nourish Yin, generate fluids', '?מה מעידה לשון סדוקה על מצב המטופל', 'What does Cracked Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T016', 'Tongue Diagnosis', 16, 'קצה אדום', 'Red Tip', '-', 'Heart fire', 'HT8, HT7, PC8, PC7', 'Clear Heart fire', '?מה מעידה קצה אדום על מצב המטופל', 'What does Red Tip indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T017', 'Tongue Diagnosis', 17, 'צדדים אדומים', 'Red Sides', '-', 'Liver fire/heat', 'LV2, LV3, GB34, GB43', 'Clear Liver fire', '?מה מעידה צדדים אדומים על מצב המטופל', 'What does Red Sides indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T018', 'Tongue Diagnosis', 18, 'לשון גיאוגרפית', 'Geographic Tongue', '-', 'Stomach/Spleen Yin deficiency', 'ST36, SP6, CV12, KI3', 'Nourish Stomach Yin', '?מה מעידה לשון גיאוגרפית על מצב המטופל', 'What does Geographic Tongue indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T019', 'Tongue Diagnosis', 19, 'סימני שיניים', 'Teeth Marks', '-', 'Spleen Qi deficiency, Dampness', 'SP9, SP6, ST36, CV12', 'Tonify Spleen, drain Damp', '?מה מעידה סימני שיניים על מצב המטופל', 'What does Teeth Marks indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('T020', 'Tongue Diagnosis', 20, 'ורידים תת-לשוניים', 'Sublingual Veins', '-', 'Blood stasis (if dark/distended)', 'SP10, LV3, BL17, SP6', 'Move Blood, break stasis', '?מה מעידה ורידים תת-לשוניים על מצב המטופל', 'What does Sublingual Veins indicate about the patient''s condition?', 'Digestive/Organ systems', 'Intermediate', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('E001', 'Five Elements', 1, 'עץ - כבד', 'Wood - Liver', '-', 'Signs: Wiry pulse, green-blue tongue sides. Symptoms: Anger, headaches, eye issues', 'LV3, LV14, GB34, LV8', 'Soothe Liver, move Qi', '?איך מאבחנים ומטפלים באלמנט עץ - כבד', 'How to diagnose and treat Wood - Liver element imbalances?', 'Organ meridian system', 'Advanced', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('E002', 'Five Elements', 2, 'אש - לב', 'Fire - Heart', '-', 'Signs: Full rapid pulse, red tongue tip. Symptoms: Insomnia, anxiety, palpitations', 'HT7, HT8, PC6, PC7', 'Clear Heart fire, calm Spirit', '?איך מאבחנים ומטפלים באלמנט אש - לב', 'How to diagnose and treat Fire - Heart element imbalances?', 'Organ meridian system', 'Advanced', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('E003', 'Five Elements', 3, 'אדמה - טחול', 'Earth - Spleen', '-', 'Signs: Soft pulse, yellow tongue coating. Symptoms: Digestion, worry, obesity', 'SP6, SP9, ST36, CV12', 'Tonify Spleen, drain Damp', '?איך מאבחנים ומטפלים באלמנט אדמה - טחול', 'How to diagnose and treat Earth - Spleen element imbalances?', 'Organ meridian system', 'Advanced', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('E004', 'Five Elements', 4, 'מתכת - ריאה', 'Metal - Lung', '-', 'Signs: Floating weak pulse, pale dry tongue. Symptoms: Breathing, sadness, skin', 'LU7, LU9, LI4, LI11', 'Tonify Lung Qi, release exterior', '?איך מאבחנים ומטפלים באלמנט מתכת - ריאה', 'How to diagnose and treat Metal - Lung element imbalances?', 'Organ meridian system', 'Advanced', 'High');

INSERT INTO tcm_training_syllabus (id, category, number, name_hebrew, name_english, pinyin, clinical_description, acupuncture_points, treatment_principle, question_hebrew, question_english, body_system, difficulty_level, clinical_priority)
VALUES ('E005', 'Five Elements', 5, 'מים - כליות', 'Water - Kidney', '-', 'Signs: Deep weak pulse, dark puffy tongue. Symptoms: Fear, bones, urinary, fertility', 'KI3, BL23, CV4, DU4', 'Tonify Kidney Yin-Yang', '?איך מאבחנים ומטפלים באלמנט מים - כליות', 'How to diagnose and treat Water - Kidney element imbalances?', 'Organ meridian system', 'Advanced', 'High');


-- Verify upload
SELECT 
    'Training Syllabus Upload Complete!' as message,
    COUNT(*) as total_rows
FROM tcm_training_syllabus;

-- Show breakdown
SELECT 
    category,
    COUNT(*) as items
FROM tcm_training_syllabus
GROUP BY category
ORDER BY category;
