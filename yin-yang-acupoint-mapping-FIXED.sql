-- =====================================================
-- YIN-YANG ASSESSMENT ACUPOINT MAPPING SYSTEM
-- Complete SQL for Supabase
-- =====================================================
-- This creates tables linking Yin-Yang symptoms to acupoints and body parts
-- Version: 1.0.0
-- Date: 2026-01-20
-- =====================================================

-- ==================== TABLE 1: YIN_YANG_SYMPTOMS ====================
-- Maps each question option to relevant acupoints, body parts, and explanations

CREATE TABLE IF NOT EXISTS yin_yang_symptoms (
    id SERIAL PRIMARY KEY,
    question_id TEXT NOT NULL,              -- e.g., 'energy_level', 'cold_sensitivity'
    symptom_option TEXT NOT NULL,           -- e.g., 'very_low', 'cold_extremities'
    question_text_he TEXT,                  -- Hebrew question text
    option_text_he TEXT,                    -- Hebrew option text
    
    -- Pattern classification
    pattern_indication TEXT,                -- e.g., 'yin_def', 'yang_def', 'qi_def'
    severity_score INTEGER,                 -- 1-5 score weight
    
    -- Acupoint associations (stored as arrays for flexibility)
    primary_acupoints TEXT[],               -- Main treatment points
    secondary_acupoints TEXT[],             -- Supporting points
    meridians_affected TEXT[],              -- Meridians involved
    
    -- Body part associations
    affected_body_parts TEXT[],             -- Body regions affected
    organ_systems TEXT[],                   -- TCM organ systems (Zang-Fu)
    
    -- Educational content
    symptom_explanation_he TEXT,            -- Patient-friendly Hebrew
    symptom_explanation_en TEXT,            -- Patient-friendly English
    tcm_mechanism TEXT,                     -- TCM pathology explanation
    treatment_principle TEXT,               -- Treatment strategy
    
    -- Metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for fast lookups
CREATE INDEX idx_question_option ON yin_yang_symptoms(question_id, symptom_option);
CREATE INDEX idx_pattern ON yin_yang_symptoms(pattern_indication);
CREATE INDEX idx_acupoints ON yin_yang_symptoms USING GIN (primary_acupoints);

-- ==================== TABLE 2: YIN_YANG_PATTERN_PROTOCOLS ====================
-- Treatment protocols for each pattern type

CREATE TABLE IF NOT EXISTS yin_yang_pattern_protocols (
    id SERIAL PRIMARY KEY,
    pattern_type TEXT NOT NULL UNIQUE,      -- 'yin_def', 'yang_def', 'balanced', etc.
    pattern_name_he TEXT,                   -- Hebrew name
    pattern_name_en TEXT,                   -- English name
    
    -- Treatment protocols
    primary_points TEXT[],                  -- Core treatment points
    supporting_points TEXT[],               -- Additional beneficial points
    contraindicated_points TEXT[],          -- Points to avoid
    
    -- Protocol details
    treatment_principle_he TEXT,            -- Hebrew treatment principle
    treatment_principle_en TEXT,            -- English treatment principle
    point_selection_rationale TEXT,         -- Why these points
    lifestyle_recommendations TEXT[],       -- Diet, exercise, habits
    
    -- Educational
    patient_explanation_he TEXT,            -- Patient-friendly description
    patient_explanation_en TEXT,
    typical_signs TEXT[],                   -- Common signs/symptoms
    
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_pattern_type ON yin_yang_pattern_protocols(pattern_type);

-- ==================== INSERT DATA: ALL 15 QUESTIONS ====================

-- ========== QUESTION 1: ENERGY LEVEL ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Very Low Energy
('energy_level', 'very_low', 
 'כיצד האנרגיה הכללית שלך במהלך היום?', 'נמוכה מאוד, מותש/ת',
 'qi_def', 4,
 ARRAY['ST-36', 'SP-6', 'CV-6', 'BL-20', 'BL-23'],
 ARRAY['CV-4', 'CV-12', 'ST-25', 'GV-4'],
 ARRAY['spleen_meridian', 'stomach_meridian', 'kidney_meridian', 'conception_vessel'],
 ARRAY['abdomen', 'lower_back', 'legs', 'spleen', 'stomach'],
 ARRAY['spleen', 'stomach', 'kidney'],
 'תשישות קיצונית מעידה על חוסר צ''י בטחול ובקיבה - הגוף אינו מייצר מספיק אנרגיה מהמזון',
 'Spleen and Stomach Qi deficiency leads to insufficient production of post-natal Qi. Kidney Qi may also be depleted',
 'Tonify Spleen and Stomach Qi, support Kidney Yang'
),

-- Low Energy
('energy_level', 'low',
 'כיצד האנרגיה הכללית שלך במהלך היום?', 'נמוכה למדי',
 'yang_def', 2,
 ARRAY['ST-36', 'SP-6', 'CV-4', 'BL-23'],
 ARRAY['CV-6', 'GV-4', 'KI-3'],
 ARRAY['spleen_meridian', 'stomach_meridian', 'kidney_meridian'],
 ARRAY['abdomen', 'lower_back', 'legs'],
 ARRAY['spleen', 'kidney'],
 'אנרגיה נמוכה עם נטייה להרגיש קר - חוסר יאנג בטחול וכליות',
 'Mild Yang deficiency affecting Spleen and Kidney Yang transformation',
 'Tonify and warm Spleen and Kidney Yang'
),

-- High Agitated Energy
('energy_level', 'high_agitated',
 'כיצד האנרגיה הכללית שלך במהלך היום?', 'גבוהה עם חוסר מנוחה או תסיסה',
 'yang_excess', 3,
 ARRAY['LR-3', 'LR-2', 'HT-7', 'PC-6', 'SP-6'],
 ARRAY['GB-20', 'GB-34', 'LI-4', 'ST-36'],
 ARRAY['liver_meridian', 'heart_meridian', 'pericardium_meridian'],
 ARRAY['liver', 'head', 'chest', 'legs'],
 ARRAY['liver', 'heart'],
 'אנרגיה מוגברת עם חוסר שקט - עודף יאנג או סטגנציה בכבד העולה כלפי מעלה',
 'Liver Yang rising or Liver Qi stagnation transforming into Heat. May involve Heart Fire',
 'Calm Liver, clear Heat, settle Yang, nourish Heart'
);

-- ========== QUESTION 2: TEMPERATURE PREFERENCE ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Very Cold
('temperature_preference', 'very_cold',
 'האם את/ה בדרך כלל מרגיש/ה יותר קר או חם בהשוואה לאנשים אחרים?', 
 'לעתים קרובות מרגיש/ה קר, לא אוהב/ת קור',
 'yang_def', 4,
 ARRAY['CV-4', 'CV-6', 'GV-4', 'KI-3', 'KI-7', 'ST-36', 'BL-23'],
 ARRAY['SP-6', 'BL-20', 'CV-8'],
 ARRAY['conception_vessel', 'governing_vessel', 'kidney_meridian', 'stomach_meridian'],
 ARRAY['lower_abdomen', 'lower_back', 'hands', 'feet', 'whole_body'],
 ARRAY['kidney', 'spleen'],
 'הרגשת קור קבועה - חוסר יאנג בכליות ובטחול, הגוף לא מצליח לחמם את עצמו',
 'Kidney and Spleen Yang deficiency - insufficient Yang Qi to warm the body and extremities',
 'Strongly tonify and warm Kidney Yang, support Spleen Yang, warm Ming Men'
),

-- Slightly Cold
('temperature_preference', 'slightly_cold',
 'האם את/ה בדרך כלל מרגיש/ה יותר קר או חם בהשוואה לאנשים אחרים?',
 'מעט יותר קר מאחרים',
 'yang_def', 2,
 ARRAY['ST-36', 'SP-6', 'CV-4', 'KI-3'],
 ARRAY['CV-6', 'BL-23', 'GV-4'],
 ARRAY['spleen_meridian', 'stomach_meridian', 'kidney_meridian'],
 ARRAY['abdomen', 'legs', 'back'],
 ARRAY['spleen', 'kidney'],
 'נטייה קלה להרגיש קר - חוסר יאנג קל בטחול או כליות',
 'Mild Yang deficiency, primarily affecting Spleen or Kidney',
 'Tonify Spleen and Kidney Yang gently'
),

-- Hot
('temperature_preference', 'hot',
 'האם את/ה בדרך כלל מרגיש/ה יותר קר או חם בהשוואה לאנשים אחרים?',
 'לעתים קרובות מרגיש/ה חם, לא אוהב/ת חום',
 'yang_excess', 3,
 ARRAY['LI-11', 'LI-4', 'ST-44', 'LR-2', 'GB-20'],
 ARRAY['GV-14', 'LI-10', 'SP-10', 'BL-40'],
 ARRAY['large_intestine_meridian', 'stomach_meridian', 'liver_meridian'],
 ARRAY['face', 'head', 'upper_body', 'hands'],
 ARRAY['stomach', 'large_intestine', 'liver'],
 'הרגשת חום מתמדת - עודף יאנג או חום בקיבה, מעיים, או כבד',
 'Excess Heat in Stomach, Large Intestine, or Liver. May be Yang Ming Heat',
 'Clear Heat, drain Fire, cool Blood'
),

-- Evening Hot
('temperature_preference', 'evening_hot',
 'האם את/ה בדרך כלל מרגיש/ה יותר קר או חם בהשוואה לאנשים אחרים?',
 'יותר חום בערב או בלילה',
 'yin_def', 4,
 ARRAY['KI-3', 'KI-6', 'SP-6', 'HT-6', 'LU-7'],
 ARRAY['KI-2', 'HT-7', 'PC-6', 'LR-3'],
 ARRAY['kidney_meridian', 'heart_meridian', 'spleen_meridian'],
 ARRAY['chest', 'palms', 'soles', 'face'],
 ARRAY['kidney', 'heart', 'liver'],
 'חום בערב - חוסר יין עם חום מחסור, במיוחד בכליות ולב',
 'Kidney and Heart Yin deficiency with deficiency Heat rising in afternoon/evening',
 'Nourish Yin, clear deficiency Heat, especially Kidney and Heart Yin'
);

-- ========== QUESTION 3: COLD SENSITIVITY ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Marked Cold Extremities
('cold_sensitivity', 'marked',
 'האם יש לך ידיים/רגליים קרות או הרגשת קור בגב התחתון/בטן?',
 'לעתים קרובות ובאופן ברור',
 'yang_def', 4,
 ARRAY['KI-3', 'KI-7', 'ST-36', 'CV-4', 'CV-6', 'GV-4', 'BL-23'],
 ARRAY['SP-6', 'LR-3', 'PC-6', 'CV-8'],
 ARRAY['kidney_meridian', 'stomach_meridian', 'conception_vessel', 'governing_vessel'],
 ARRAY['hands', 'feet', 'lower_back', 'lower_abdomen'],
 ARRAY['kidney', 'spleen'],
 'ידיים ורגליים קרות - חוסר יאנג בכליות, הגוף לא מצליח לחמם את הגפיים',
 'Kidney Yang deficiency fails to warm extremities. Yang Qi cannot reach the four limbs',
 'Strongly warm and tonify Kidney Yang, warm Ming Men Fire, promote circulation to limbs'
),

-- Mild Cold Sensitivity
('cold_sensitivity', 'mild',
 'האם יש לך ידיים/רגליים קרות או הרגשת קור בגב התחתון/בטן?',
 'לפעמים',
 'yang_def', 2,
 ARRAY['ST-36', 'SP-6', 'KI-3', 'CV-4'],
 ARRAY['KI-7', 'BL-23', 'GV-4'],
 ARRAY['kidney_meridian', 'spleen_meridian', 'stomach_meridian'],
 ARRAY['hands', 'feet', 'abdomen'],
 ARRAY['kidney', 'spleen'],
 'נטייה לקור בגפיים - חוסר יאנג קל, במיוחד בזרימה להברות',
 'Mild Yang deficiency affecting circulation to extremities',
 'Tonify Yang, warm and promote circulation'
);

-- ========== QUESTION 4: HEAT SENSATION ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Afternoon/Evening Heat
('heat_sensation', 'pm_heat',
 'האם את/ה חווה תחושות של חום (כפות ידיים, כפות רגליים, חזה, פנים)?',
 'יותר אחר הצהריים/ערב',
 'yin_def', 4,
 ARRAY['KI-3', 'KI-6', 'KI-2', 'SP-6', 'HT-6'],
 ARRAY['LR-3', 'HT-7', 'PC-6', 'ST-44'],
 ARRAY['kidney_meridian', 'heart_meridian', 'spleen_meridian'],
 ARRAY['palms', 'soles', 'chest', 'face'],
 ARRAY['kidney', 'heart', 'liver'],
 'חום בערב (5 Palm Heat) - חוסר יין בכליות ולב עם חום מחסור',
 'Kidney and Heart Yin deficiency with deficiency Heat. Characteristic afternoon tidal fever pattern',
 'Nourish Yin, clear deficiency Heat, especially Kidney and Heart'
),

-- All Day Heat
('heat_sensation', 'all_day_heat',
 'האם את/ה חווה תחושות של חום (כפות ידיים, כפות רגליים, חזה, פנים)?',
 'כל היום או מתחמם/ת בקלות',
 'yang_excess', 4,
 ARRAY['LI-11', 'LI-4', 'ST-44', 'LR-2', 'GB-20', 'GV-14'],
 ARRAY['LI-10', 'SP-10', 'BL-40', 'ST-43'],
 ARRAY['large_intestine_meridian', 'stomach_meridian', 'liver_meridian', 'gallbladder_meridian'],
 ARRAY['whole_body', 'face', 'head', 'chest'],
 ARRAY['stomach', 'liver', 'large_intestine'],
 'חום כל היום - עודף יאנג או חום עודף בקיבה, כבד, או דם',
 'Excess Heat in Yangming (Stomach/Large Intestine) or Liver Fire/Heat. May involve Blood Heat',
 'Clear Heat, drain Fire, cool Blood, calm Yang'
),

-- Night Sweats with Heat
('heat_sensation', 'night_sweats',
 'האם את/ה חווה תחושות של חום (כפות ידיים, כפות רגליים, חזה, פנים)?',
 'הזעות לילה עם חום',
 'yin_def', 5,
 ARRAY['KI-3', 'KI-6', 'KI-7', 'HT-6', 'SP-6', 'LU-7'],
 ARRAY['HT-7', 'KI-2', 'PC-6', 'LR-3'],
 ARRAY['kidney_meridian', 'heart_meridian', 'lung_meridian'],
 ARRAY['chest', 'back', 'whole_body'],
 ARRAY['kidney', 'heart', 'lung'],
 'הזעות לילה עם חום - חוסר יין חמור בכליות, לב, או ריאות',
 'Severe Yin deficiency of Kidney, Heart, or Lung with steaming bone deficiency Heat',
 'Strongly nourish Yin, clear deficiency Heat, stop sweating'
);

-- ========== QUESTION 5: SWEATING ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Spontaneous Sweating
('sweating', 'spontaneous',
 'איך ההזעה שלך?', 'הזעה ספונטנית עם מעט מאמץ',
 'qi_def', 3,
 ARRAY['ST-36', 'SP-6', 'LU-9', 'HT-6', 'KI-7'],
 ARRAY['CV-6', 'BL-20', 'BL-13', 'LI-4'],
 ARRAY['lung_meridian', 'heart_meridian', 'spleen_meridian'],
 ARRAY['chest', 'back', 'whole_body'],
 ARRAY['lung', 'heart', 'spleen'],
 'הזעה ספונטנית ביום - חוסר צ''י בריאות, הגנה חיצונית חלשה',
 'Lung Qi and Defensive Qi deficiency. Wei Qi fails to control pores',
 'Tonify Lung and Spleen Qi, stabilize exterior, stop sweating'
),

-- Night Sweats
('sweating', 'night',
 'איך ההזעה שלך?', 'הזעות לילה',
 'yin_def', 4,
 ARRAY['KI-3', 'KI-6', 'HT-6', 'SP-6', 'LU-7'],
 ARRAY['KI-7', 'HT-7', 'PC-6', 'KI-2'],
 ARRAY['kidney_meridian', 'heart_meridian', 'spleen_meridian'],
 ARRAY['chest', 'back', 'whole_body'],
 ARRAY['kidney', 'heart'],
 'הזעות לילה - חוסר יין עם חום מחסור, במיוחד בכליות ולב',
 'Kidney and Heart Yin deficiency with deficiency Heat steaming fluids outward at night',
 'Nourish Yin, clear deficiency Heat, stop sweating'
),

-- No Sweat Cold Body
('sweating', 'no_sweat_cold',
 'איך ההזעה שלך?', 'ללא הזעה, גוף קר',
 'yang_def', 3,
 ARRAY['CV-4', 'CV-6', 'GV-4', 'BL-23', 'ST-36'],
 ARRAY['KI-3', 'KI-7', 'SP-6', 'BL-20'],
 ARRAY['conception_vessel', 'governing_vessel', 'kidney_meridian'],
 ARRAY['whole_body', 'lower_back', 'abdomen'],
 ARRAY['kidney', 'spleen'],
 'אין הזעה עם גוף קר - חוסר יאנג חמור, חוסר חום לייצר הזעה',
 'Severe Yang deficiency. Insufficient Yang Qi to produce sweat and warm body',
 'Strongly tonify and warm Yang, especially Kidney and Spleen Yang'
);

-- ========== QUESTION 6: THIRST ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Low Thirst, Prefers Warm
('thirst', 'low_thirst',
 'תאר/י את הצמא וצריכת הנוזלים שלך', 'מעט צמא, מעדיף/ה משקאות חמים',
 'yang_def', 2,
 ARRAY['ST-36', 'SP-6', 'CV-4', 'BL-20'],
 ARRAY['CV-6', 'CV-12', 'KI-3', 'BL-23'],
 ARRAY['spleen_meridian', 'stomach_meridian', 'kidney_meridian'],
 ARRAY['abdomen', 'digestive_system'],
 ARRAY['spleen', 'stomach', 'kidney'],
 'מעט צמא עם העדפה לחם - חוסר יאנג בטחול וקיבה',
 'Spleen and Stomach Yang deficiency. Insufficient Yang to transform fluids, prefers warmth',
 'Warm and tonify Spleen and Stomach Yang'
),

-- High Thirst, Prefers Cold
('thirst', 'high_cold',
 'תאר/י את הצמא וצריכת הנוזלים שלך', 'צמא חזק, מעדיף/ה משקאות קרים',
 'yang_excess', 3,
 ARRAY['ST-44', 'ST-43', 'LI-11', 'LI-4', 'SP-6'],
 ARRAY['ST-36', 'CV-12', 'LR-2', 'KI-6'],
 ARRAY['stomach_meridian', 'large_intestine_meridian'],
 ARRAY['mouth', 'throat', 'digestive_system'],
 ARRAY['stomach', 'large_intestine'],
 'צמא חזק למשקאות קרים - חום בקיבה או מעיים גדולים',
 'Stomach Heat or Large Intestine Heat consuming fluids, creating thirst for cold',
 'Clear Heat from Stomach and Large Intestine, generate fluids'
),

-- Dry Mouth, Little Drink
('thirst', 'dry_mouth_little_drink',
 'תאר/י את הצמא וצריכת הנוזלים שלך', 'פה יבש אך רק לגימות קטנות',
 'yin_def', 4,
 ARRAY['KI-3', 'KI-6', 'SP-6', 'ST-36', 'LU-7'],
 ARRAY['KI-2', 'HT-6', 'CV-12', 'ST-44'],
 ARRAY['kidney_meridian', 'stomach_meridian', 'spleen_meridian'],
 ARRAY['mouth', 'throat'],
 ARRAY['kidney', 'stomach', 'lung'],
 'פה יבש אך שותה מעט - חוסר יין, נוזלים פנימיים מתדלדלים',
 'Yin deficiency with internal dryness. Body lacks fluids but cannot drink much',
 'Nourish Yin, generate fluids, moisten dryness'
);

-- ========== QUESTION 7: SLEEP ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Difficulty Falling Asleep
('sleep', 'difficulty_falling',
 'איך השינה שלך?', 'קשה להירדם, מוח עסוק',
 'yang_excess', 3,
 ARRAY['HT-7', 'PC-6', 'SP-6', 'AN-MIAN', 'YIN-TANG'],
 ARRAY['LR-3', 'GB-20', 'DU-20', 'KI-6'],
 ARRAY['heart_meridian', 'pericardium_meridian', 'liver_meridian'],
 ARRAY['head', 'chest', 'mind'],
 ARRAY['heart', 'liver'],
 'קשה להירדם, מחשבות רבות - כבד או לב לא רגועים, יאנג לא יורד',
 'Heart and Liver Yang excess or Liver Qi stagnation. Yang fails to descend, Shen is restless',
 'Calm Heart and Liver, settle Yang, quiet Shen, promote downward flow'
),

-- Waking at Night
('sleep', 'waking_night',
 'איך השינה שלך?', 'מתעורר/ת לעתים קרובות, חום, הזעות לילה',
 'yin_def', 4,
 ARRAY['KI-3', 'KI-6', 'HT-6', 'HT-7', 'SP-6'],
 ARRAY['KI-2', 'PC-6', 'LU-7', 'AN-MIAN'],
 ARRAY['kidney_meridian', 'heart_meridian'],
 ARRAY['chest', 'whole_body'],
 ARRAY['kidney', 'heart'],
 'התעוררות בלילה עם חום - חוסר יין בלב וכליות, חום מחסור',
 'Heart and Kidney Yin deficiency. Deficiency Heat disturbs Shen at night',
 'Nourish Heart and Kidney Yin, clear deficiency Heat, calm Shen'
),

-- Excessive Sleep
('sleep', 'excessive_sleep',
 'איך השינה שלך?', 'צריך/ה הרבה שינה, עדיין עייף/ה',
 'yang_def', 3,
 ARRAY['ST-36', 'SP-6', 'CV-6', 'BL-20', 'BL-23', 'GV-4'],
 ARRAY['CV-4', 'KI-3', 'CV-12', 'GV-20'],
 ARRAY['spleen_meridian', 'stomach_meridian', 'kidney_meridian'],
 ARRAY['whole_body', 'abdomen', 'back'],
 ARRAY['spleen', 'kidney'],
 'צורך בהרבה שינה אך עייף - חוסר יאנג בטחול וכליות, אנרגיה נמוכה',
 'Spleen and Kidney Yang deficiency. Insufficient Yang Qi to maintain wakefulness and vitality',
 'Tonify and warm Spleen and Kidney Yang, raise Qi'
);

-- ========== QUESTION 8: STOOL ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Loose Stool with Cold
('stool', 'loose_cold',
 'איך תנועות המעיים שלך?', 'רופפות, במיוחד עם קור או בבוקר',
 'yang_def', 4,
 ARRAY['ST-36', 'SP-6', 'ST-25', 'CV-6', 'BL-20', 'BL-25'],
 ARRAY['CV-4', 'CV-12', 'BL-23', 'GV-4'],
 ARRAY['spleen_meridian', 'stomach_meridian', 'conception_vessel'],
 ARRAY['abdomen', 'intestines', 'lower_back'],
 ARRAY['spleen', 'kidney', 'large_intestine'],
 'צואה רופפה בבוקר או עם קור - חוסר יאנג בטחול וכליות',
 'Spleen and Kidney Yang deficiency. Morning diarrhea (cock crow diarrhea) is classic Kidney Yang deficiency',
 'Warm and tonify Spleen and Kidney Yang, firm intestines'
),

-- Dry Constipation
('stool', 'dry_constipation',
 'איך תנועות המעיים שלך?', 'צואה יבשה, קשה או עצירות',
 'yin_def', 3,
 ARRAY['ST-36', 'ST-25', 'ST-37', 'SP-6', 'KI-6', 'SJ-6'],
 ARRAY['ST-44', 'LR-3', 'CV-12', 'BL-25'],
 ARRAY['stomach_meridian', 'large_intestine_meridian', 'kidney_meridian'],
 ARRAY['abdomen', 'intestines'],
 ARRAY['large_intestine', 'kidney', 'stomach'],
 'עצירות עם צואה יבשה - חוסר יין או נוזלים במעיים, אולי חום',
 'Yin and fluid deficiency or Heat drying the Large Intestine. Kidney Yin fails to moisten',
 'Nourish Yin, moisten intestines, clear Heat if present'
);

-- ========== QUESTION 9: URINE ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Frequent Clear Urine
('urine', 'frequent_clear',
 'איך ההטלה שלך?', 'תכופה, בהירה, במיוחד בלילה',
 'yang_def', 4,
 ARRAY['CV-4', 'CV-3', 'KI-3', 'KI-7', 'BL-23', 'BL-28'],
 ARRAY['SP-6', 'SP-9', 'CV-6', 'GV-4'],
 ARRAY['kidney_meridian', 'bladder_meridian', 'conception_vessel'],
 ARRAY['bladder', 'lower_abdomen', 'lower_back'],
 ARRAY['kidney', 'bladder'],
 'השתנה תכופה ובהירה בלילה - חוסר יאנג בכליות, כליות לא מחזיקות שתן',
 'Kidney Yang deficiency fails to consolidate urine. Bladder loses control',
 'Warm and tonify Kidney Yang, consolidate Bladder, reduce urination'
),

-- Dark Scanty Urine
('urine', 'dark_scanty',
 'איך ההטלה שלך?', 'כהה, מועטה',
 'yin_def', 3,
 ARRAY['KI-3', 'KI-6', 'SP-6', 'SP-9', 'CV-3', 'BL-28'],
 ARRAY['KI-2', 'ST-36', 'CV-4', 'LR-8'],
 ARRAY['kidney_meridian', 'bladder_meridian', 'spleen_meridian'],
 ARRAY['bladder', 'lower_abdomen'],
 ARRAY['kidney', 'bladder'],
 'שתן כהה ומועט - חוסר יין או נוזלים, אולי חום בשלפוחית השתן',
 'Yin and fluid deficiency or Heat in Bladder consuming fluids. Dark color indicates concentration or Heat',
 'Nourish Yin, clear Heat from Bladder, promote urination, generate fluids'
);

-- ========== QUESTION 10: BODY BUILD ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Thin and Dry
('body_build', 'thin_dry',
 'איך היית מתאר/ת את מבנה הגוף והתחושה שלך?', 'רזה, יבש, נטייה ליובש',
 'yin_def', 4,
 ARRAY['KI-3', 'SP-6', 'ST-36', 'LU-7', 'KI-6'],
 ARRAY['CV-12', 'BL-20', 'BL-23', 'SP-10'],
 ARRAY['kidney_meridian', 'spleen_meridian', 'stomach_meridian'],
 ARRAY['whole_body', 'skin', 'muscles'],
 ARRAY['kidney', 'spleen', 'stomach', 'lung'],
 'גוף רזה ויבש - חוסר יין, נוזלי גוף ודם, לא מספיק הזנה',
 'Yin, Blood, and fluid deficiency. Insufficient nourishment to muscles and tissues',
 'Nourish Yin, tonify Blood, strengthen Spleen and Stomach to generate Qi and Blood'
),

-- Puffy and Cold
('body_build', 'puffy_cold',
 'איך היית מתאר/ת את מבנה הגוף והתחושה שלך?', 'נפוח, מרגיש/ה קר, כבד',
 'yang_def', 4,
 ARRAY['CV-4', 'CV-6', 'SP-6', 'SP-9', 'ST-36', 'BL-20', 'BL-23'],
 ARRAY['CV-9', 'ST-28', 'KI-3', 'GV-4'],
 ARRAY['spleen_meridian', 'kidney_meridian', 'stomach_meridian'],
 ARRAY['abdomen', 'legs', 'whole_body'],
 ARRAY['spleen', 'kidney'],
 'נפיחות עם קור - חוסר יאנג בטחול וכליות, מים מצטברים',
 'Spleen and Kidney Yang deficiency with water accumulation. Damp and phlegm retention',
 'Warm and tonify Spleen and Kidney Yang, resolve Damp, transform phlegm'
),

-- Robust with Red Face
('body_build', 'robust_red_face',
 'איך היית מתאר/ת את מבנה הגוף והתחושה שלך?', 'חסון עם נטייה לפנים אדומות או קול חזק',
 'yang_excess', 3,
 ARRAY['LI-11', 'LI-4', 'ST-44', 'LR-3', 'LR-2', 'GB-20'],
 ARRAY['GV-14', 'LI-10', 'SP-10', 'ST-36'],
 ARRAY['large_intestine_meridian', 'stomach_meridian', 'liver_meridian'],
 ARRAY['face', 'head', 'upper_body'],
 ARRAY['stomach', 'liver', 'large_intestine'],
 'מבנה חזק עם פנים אדומות - עודף יאנג או חום בקיבה וכבד',
 'Yang excess or Heat in Yangming and Liver. Robust constitution with excess Heat rising',
 'Clear Heat, drain excess, calm Liver Yang, cool Blood'
);

-- ========== QUESTION 11: PAIN ==========

INSERT INTO yin_yang_symptoms (
    question_id, symptom_option, question_text_he, option_text_he,
    pattern_indication, severity_score,
    primary_acupoints, secondary_acupoints, meridians_affected,
    affected_body_parts, organ_systems,
    symptom_explanation_he, tcm_mechanism, treatment_principle
) VALUES
-- Cold Pain Better with Warmth
('pain', 'cold_pain_better_warm',
 'כאבים קבועים כלשהם (מפרקים, גב, גפיים)?', 'כאב קר, טוב יותר עם חום/לחץ',
 'yang_def', 3,
 ARRAY['ST-36', 'SP-6', 'BL-23', 'GV-4', 'CV-4', 'CV-6'],
 ARRAY['BL-20', 'KI-3', 'GB-34', 'local_ah_shi'],
 ARRAY['kidney_meridian', 'bladder_meridian', 'governing_vessel'],
 ARRAY['back', 'joints', 'knees', 'lower_back'],
 ARRAY['kidney', 'spleen'],
 'כאב קר המשתפר עם חום - חוסר יאנג, קור חוסם מרידיאנים',
 'Yang deficiency with Cold obstruction. Cold contracts and blocks meridians causing pain',
 'Warm Yang, expel Cold, unblock meridians, promote Qi and Blood flow'
),

-- Burning Pain
('pain', 'burning_pain',
 'כאבים קבועים כלשהם (מפרקים, גב, גפיים)?', 'תחושת שריפה או כאב חום',
 'yang_excess', 3,
 ARRAY['LI-11', 'LI-4', 'SP-10', 'BL-40', 'LR-2', 'GB-34'],
 ARRAY['ST-44', 'LR-3', 'SP-6', 'local_ah_shi'],
 ARRAY['large_intestine_meridian', 'liver_meridian', 'gallbladder_meridian'],
 ARRAY['joints', 'muscles', 'affected_area'],
 ARRAY['liver', 'blood'],
 'כאב שורף - חום בדם או מרידיאנים, אולי יין לא מספיק',
 'Heat in Blood or meridians. May be from Yin deficiency causing deficiency Heat or true excess Heat',
 'Clear Heat, cool Blood, nourish Yin if deficiency pattern'
);

-- ==================== INSERT PATTERN PROTOCOLS ====================

INSERT INTO yin_yang_pattern_protocols (
    pattern_type, pattern_name_he, pattern_name_en,
    primary_points, supporting_points, contraindicated_points,
    treatment_principle_he, treatment_principle_en,
    point_selection_rationale,
    patient_explanation_he, patient_explanation_en,
    typical_signs, lifestyle_recommendations
) VALUES
-- Yin Deficiency Protocol
('yin_def', 
 'חסר יין', 'Yin Deficiency',
 ARRAY['KI-3', 'KI-6', 'SP-6', 'ST-36', 'HT-6', 'LU-7'],
 ARRAY['KI-2', 'KI-10', 'HT-7', 'PC-6', 'LR-3', 'CV-4'],
 ARRAY['GV-4', 'CV-8_moxa', 'BL-23_moxa'],
 'להזין יין, לבנות נוזלים, לנקות חום מחסור',
 'Nourish Yin, generate fluids, clear deficiency Heat',
 'KI-3 (source point) tonifies Kidney Yin. KI-6 (opening point of Yin Qiao) nourishes Yin and clears heat. SP-6 (crossing of 3 Yin meridians) nourishes Yin of Liver, Spleen, and Kidney. ST-36 tonifies source Qi to generate Yin. HT-6 nourishes Heart Yin. LU-7 generates fluids',
 'הגוף שלך צריך יותר נוזלים ותזונה מקררת. כמו מדבר שצריך גשם',
 'Your body needs more cooling nourishment and fluids, like a desert needing rain',
 ARRAY['חום אחר הצהריים או בערב', 'הזעות לילה', 'פה יבש', 'גוף רזה', 'שינה קלה'],
 ARRAY['שתייה של נוזלים, במיוחד מים פושרים', 'מזון מזין: תרד, פטריות, אגוזים', 'הימנע מתבלינים חריפים', 'שינה מספקת', 'תרגילים עדינים כמו יוגה']
),

-- Yang Deficiency Protocol
('yang_def',
 'חסר יאנג', 'Yang Deficiency',
 ARRAY['CV-4', 'CV-6', 'GV-4', 'ST-36', 'SP-6', 'KI-3', 'BL-23'],
 ARRAY['CV-8_moxa', 'KI-7', 'BL-20', 'SP-9', 'GV-20'],
 ARRAY['cold_technique', 'strong_reducing'],
 'לחמם ולחזק יאנג, לחזק אש מינג מן',
 'Warm and tonify Yang, strengthen Ming Men Fire',
 'CV-4 and CV-6 tonify and warm Kidney Yang (lower Dan Tian). GV-4 (Ming Men) is the gate of vitality, warms Kidney Yang. ST-36 tonifies Yang and Qi. KI-3 and BL-23 tonify Kidney Yang. Use moxa extensively',
 'האנרגיה המחממת של הגוף שלך חלשה. צריך לחזק את האש הפנימית',
 'Your body''s warming energy is weak. Need to strengthen the internal fire',
 ARRAY['תחושת קור', 'השתנה תכופה בהירה', 'צואה רופפה', 'אנרגיה נמוכה', 'משקה חם מועדף'],
 ARRAY['מזון מחמם: ג''ינג''ר, קינמון, בשר', 'שתיית משקאות חמים', 'שמירה על חום הגוף', 'תרגילים מתונים', 'הימנע מקור ומזון קר']
),

-- Balanced Pattern
('balanced',
 'איזון יחסי', 'Relative Balance',
 ARRAY['ST-36', 'SP-6', 'LR-3', 'PC-6', 'LI-4'],
 ARRAY['CV-6', 'CV-12', 'GV-20', 'KI-3'],
 ARRAY[]::text[],
 'לשמור על איזון, לחזק צ''י כללי',
 'Maintain balance, strengthen overall Qi',
 'General tonification points to maintain health. ST-36 and SP-6 tonify Qi and Blood. LR-3 ensures smooth Qi flow. LI-4 and PC-6 regulate Qi. Regular preventive treatment',
 'הגוף שלך מאוזן יחסית. המשך בהרגלים הטובים',
 'Your body is relatively balanced. Continue good habits',
 ARRAY['אנרגיה יציבה', 'שינה טובה', 'תיאבון טוב', 'עיכול תקין'],
 ARRAY['דיאטה מאוזנת', 'שינה קבועה', 'פעילות גופנית סדירה', 'ניהול מתח', 'בדיקות מניעה']
),

-- Yang Excess Pattern
('yang_excess',
 'עודף יאנג', 'Yang Excess',
 ARRAY['LI-11', 'LI-4', 'ST-44', 'LR-3', 'LR-2', 'GB-20', 'GV-14'],
 ARRAY['SP-6', 'SP-10', 'BL-40', 'PC-6', 'HT-7'],
 ARRAY['moxa', 'warming_techniques'],
 'לנקות חום, לנקז אש, להרגיע יאנג',
 'Clear Heat, drain Fire, calm Yang',
 'LI-11 clears Heat from Yangming. ST-44 drains Stomach Fire. LR-2 and LR-3 drain Liver Fire and calm Liver Yang. GB-20 subdues Liver Yang rising. GV-14 clears Heat. Use reducing technique',
 'יש עודף חום ואנרגיה בגוף, צריך לקרר ולהרגיע',
 'Excess heat and energy in body, need to cool and calm',
 ARRAY['תחושת חום', 'פנים אדומות', 'עצבנות', 'צמא למשקאות קרים', 'השתנה כהה'],
 ARRAY['מזון מקרר: מלפפון, תרד, מנטה', 'הימנע מתבלינים חריפים ואלכוהול', 'שתיית נוזלים קרים', 'מדיטציה', 'הימנע מחום יתר']
),

-- Qi Deficiency Pattern
('qi_def',
 'חסר צ''י', 'Qi Deficiency',
 ARRAY['ST-36', 'SP-6', 'CV-6', 'CV-12', 'BL-20', 'BL-21'],
 ARRAY['LU-9', 'CV-4', 'ST-25', 'PC-6', 'GV-20'],
 ARRAY[]::text[],
 'לחזק צ''י, לתמוך בטחול וקיבה',
 'Tonify Qi, support Spleen and Stomach',
 'ST-36 and SP-6 are primary Qi tonification points. CV-6 (Sea of Qi) tonifies Qi. CV-12 (Mu of Stomach) tonifies Spleen and Stomach. BL-20 and BL-21 are Back Shu points for Spleen and Stomach',
 'האנרגיה הכללית שלך נמוכה, צריך לבנות כוח',
 'Your overall energy is low, need to build strength',
 ARRAY['עייפות', 'קוצר נשימה בעת מאמץ', 'הזעה ספונטנית', 'תיאבון חלש', 'קול חלש'],
 ARRAY['מזון מזין וקל לעיכול', 'ארוחות קטנות תכופות', 'מנוחה מספקת', 'תרגילים עדינים', 'הימנע ממזון קר וגולמי']
);

-- ==================== HELPER VIEWS ====================

-- View to get all acupoint recommendations for a specific answer
CREATE OR REPLACE VIEW v_symptom_acupoints AS
SELECT 
    s.question_id,
    s.symptom_option,
    s.option_text_he,
    s.pattern_indication,
    s.symptom_explanation_he,
    unnest(s.primary_acupoints) as acupoint_code,
    'primary' as point_type
FROM yin_yang_symptoms s
UNION ALL
SELECT 
    s.question_id,
    s.symptom_option,
    s.option_text_he,
    s.pattern_indication,
    s.symptom_explanation_he,
    unnest(s.secondary_acupoints) as acupoint_code,
    'secondary' as point_type
FROM yin_yang_symptoms s;

-- View to get pattern protocol summary
CREATE OR REPLACE VIEW v_pattern_summary AS
SELECT 
    pattern_type,
    pattern_name_he,
    pattern_name_en,
    patient_explanation_he,
    array_length(primary_points, 1) as num_primary_points,
    array_length(typical_signs, 1) as num_signs,
    array_length(lifestyle_recommendations, 1) as num_recommendations
FROM yin_yang_pattern_protocols;

-- ==================== SAMPLE QUERIES ====================

-- Example 1: Get all acupoints for someone with "very low energy"
-- SELECT * FROM v_symptom_acupoints 
-- WHERE question_id = 'energy_level' AND symptom_option = 'very_low';

-- Example 2: Get treatment protocol for Yin Deficiency
-- SELECT * FROM yin_yang_pattern_protocols WHERE pattern_type = 'yin_def';

-- Example 3: Find all symptoms that involve Kidney meridian
-- SELECT DISTINCT question_id, symptom_option, option_text_he
-- FROM yin_yang_symptoms
-- WHERE 'kidney_meridian' = ANY(meridians_affected);

-- ==================== GRANT PERMISSIONS ====================
-- Uncomment and adjust based on your Supabase setup

-- GRANT SELECT ON yin_yang_symptoms TO anon, authenticated;
-- GRANT SELECT ON yin_yang_pattern_protocols TO anon, authenticated;
-- GRANT SELECT ON v_symptom_acupoints TO anon, authenticated;
-- GRANT SELECT ON v_pattern_summary TO anon, authenticated;

-- ==================== COMPLETE ====================
-- This SQL file is ready to run in Supabase SQL editor
-- It creates all tables, indexes, views, and populates with complete data
-- for all 15 Yin-Yang assessment questions
