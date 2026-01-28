-- KIDNEY MERIDIAN POINTS ONLY (27 points)
-- Liver points already exist - skipping those
-- IDs will auto-increment from current max

-- First, find the current maximum ID
DO $$
DECLARE
    next_id INTEGER;
BEGIN
    SELECT COALESCE(MAX(id), 0) + 1 INTO next_id FROM dr_roni_complete;

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 0,
        'Kid1',
        'Gushing Spring',
        'מעיין שוצף',
        'במרכז השליש הקדמי של כף הרגל, בשקע בין עצמות המטטרסל השנייה והשלישית, כאשר האצבעות מכופפות.',
        'מרגיע את השן, מנקה אש מהראש, מחיה הכרה, מחזק את הכליות ומוריד יאנג עולה.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 1,
        'Kid2',
        'Blazing Valley',
        'עמק לוהט',
        'בגבול התחתון‑קדמי של הסקפף המדיאלי של עצם הטאלוס, בשקע קדמי‑תחתון למלאולוס המדיאלי, על שפת הקמורה של כף הרגל.',
        'מנקה אש ריקה מכליות, מקרר חום עליון, מטפל בהזעות לילה, גרד בכפות הרגליים, כאב גרון וצמא.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 2,
        'Kid3',
        'Great Ravine',
        'ערוץ גדול',
        'בשקע בין המלאולוס המדיאלי של הקרסול לבין גיד אכילס, בגובה הקצה העליון של המלאולוס המדיאלי.',
        'מחזק צ׳י, יין וג׳ינג הכליות, מחזק גב תחתון וברכיים, מטפל בעייפות, כאבי גב, טיניטוס, בעיות פוריות והפרעות שתן.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 3,
        'Kid4',
        'Great Bell',
        'פעמון גדול',
        'אחורית ומתחת ל־Kid3, בשקע קדמי לגיד אכילס, כ־0.5 צון מתחת לגובה המלאולוס המדיאלי.',
        'מחזק את הכליות ומייצב צ׳י, מחבר בין כליות לשלפוחית השתן, מטפל בפחדים, טיניטוס, כאבי גב תחתון והפרעות שתן.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 4,
        'Kid5',
        'Water Spring',
        'מעיין מים',
        'כ־1 צון מתחת ל־Kid3, בשקע קדמי לגיד אכילס.',
        'מווסת רחם ווסת, מטפל בדימום רחמי וכאב גניטלי, מחזק ומייצב צ׳י הכליות.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 5,
        'Kid6',
        'Shining Sea',
        'ים זוהר',
        'בשקע מתחת לקצה התחתון של המלאולוס המדיאלי, בין המלאולוס לעצם הקלקנאוס.',
        'מזין יין כליות, מיטיב עם הגרון, מרגיע את השן, מטפל בנדודי שינה, יובש בגרון, עצירות ומחלות גינקולוגיות מחוסר יין.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 6,
        'Kid7',
        'Returning Current',
        'זרם חוזר',
        '2 צון מעל Kid3, בגבול הקדמי של גיד אכילס, על הקצה המדיאלי של השוק האחורית.',
        'מחזק יאנג הכליות, מווסת הזעה (חוסר ועודף), מטפל בבצקות, בעיות שתן ושלשול על רקע קור.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 7,
        'Kid8',
        'Exchange Belief',
        'החלפת אמונה',
        '0.5 צון קדמית ל־Kid7 ו־2 צון מעל Kid3, בשפה המדיאלית האחורית של השוק.',
        'מווסת רחם ווסת, מטפל בדימום רחמי, כאבי בטן תחתונה והפרשות גינקולוגיות מלחות‑חום.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 8,
        'Kid9',
        'Guest House',
        'בית האורח',
        '5 צון מעל Kid3, על הקו המחבר Kid3 ל־Kid10, כ־1 צון מאחורי גבול השוק המדיאלית.',
        'מרגיע את השן, מטהר לב מחום, מטפל בחרדה, מצבי מניה‑דפרסיה, כאבים באזור הלב ובטן תחתונה בהריון.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 9,
        'Kid10',
        'Yin Valley',
        'עמק יין',
        'בשקע בין הגיד של שריר סמיטנדינוסוס וסמיממברנוסוס לבין הקונדיל המדיאלי של הטיביה, בקצה המדיאלי של קפל הפופליטאה כשהברך כפופה.',
        'מקרר חום ולחות‑חום בשלפוחית ובגניטליה, מזין יין הכליות, מטפל בכאב ברך פנימי, קושי במתן שתן וגירוד גניטלי.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 10,
        'Kid11',
        'Pubic Bone',
        'עצם החיק',
        '0.5 צון לטרלית לקו האמצע, בגבול העליון של סימפיזיס פוביס, בגובה CV2.',
        'מחזק ומחמם את הכליות, מיטיב עם הגניטליה ודרכי השתן, מטפל בהפרעות שתן, כאבי בטן תחתונה וחולשת פרינאום.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 11,
        'Kid12',
        'Great Luminance',
        'זוהר גדול',
        '0.5 צון לטרלית לקו האמצע, 1 צון מעל גבול סימפיזיס פוביס, בגובה CV3.',
        'מווסת דרכי שתן ורחם, מטפל בהפרשות וגינליות ואי‑שליטה במתן שתן, מחזק רצפת אגן.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 12,
        'Kid13',
        'Qi Hole',
        'חור הצ׳י',
        '0.5 צון לטרלית לקו האמצע, 2 צון מעל גבול סימפיזיס פוביס, בגובה CV4.',
        'מחזק ג׳ינג וצ׳י הכליות, תומך בפוריות, מטפל באמנוריאה, אי‑סדירות וסת, כאבי בטן תחתונה ושלשול כרוני.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 13,
        'Kid14',
        'Fourfold Fullness',
        'מלאות מרובעת',
        '0.5 צון לטרלית לקו האמצע, 3 צון מעל גבול סימפיזיס פוביס, בגובה CV5.',
        'מווסת מחמם תחתון ומעיים, מפזר הצטברויות ברחם ובמעיים, מטפל בעצירות, נפיחות וגושים באגן.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 14,
        'Kid15',
        'Central Flow',
        'זרימה מרכזית',
        '0.5 צון לטרלית לקו האמצע, 4 צון מעל גבול סימפיזיס פוביס, בגובה CV6.',
        'מחזק צ׳י וכליות, מטפל בחולשה בבטן תחתונה, כאבי בטן, שלשולים והצטברויות במעיים.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 15,
        'Kid16',
        'Vitals Shu',
        'שׁו של האברים החיוניים',
        '0.5 צון לטרלית לקו האמצע, בגובה הטבור, בגובה CV8.',
        'מווסת צ׳י במעיים, מטפל בכאב בטן, שלשולים, עצירות והקאות, מחזק קשר כליות‑מעיים.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 16,
        'Kid17',
        'Shang Bend',
        'עיקול עליון',
        '0.5 צון לטרלית לקו האמצע, 2 צון מעל הטבור, בגובה CV10.',
        'מווסת קיבה ומעיים, מטפל בנפיחות אפיגסטרית, חוסר תיאבון, הקאות ושלשולים.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 17,
        'Kid18',
        'Stone Pass',
        'מעבר האבן',
        '0.5 צון לטרלית לקו האמצע, 3 צון מעל הטבור, בגובה CV11.',
        'משחרר תקיעויות בקיבה, מטפל בכאב אפיגסטרי, גיהוקים, בחילות והקאות.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 18,
        'Kid19',
        'Yin Metropolis',
        'עיר יין',
        '0.5 צון לטרלית לקו האמצע, 4 צון מעל הטבור, בגובה CV12.',
        'מווסת קיבה, מפזר ליחה ולחות, מטפל בבחילה, צרבת, מלאות בקיבה ושיעול ליחתי.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 19,
        'Kid20',
        'Abdomen Connecting Valley',
        'עמק מחבר הבטן',
        '0.5 צון לטרלית לקו האמצע, 5 צון מעל הטבור, בגובה CV13.',
        'מניע צ׳י במחמם האמצעי, מטפל בכאב ברום הבטן, פלפיטציות, שיעול וליחה בחזה.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 20,
        'Kid21',
        'Dark Gate',
        'שער אפל',
        '0.5 צון לטרלית לקו האמצע, 6 צון מעל הטבור, בגובה CV14.',
        'מטהר חזה וקיבה, מוריד צ׳י מורד, מטפל בבחילה, הקאות, קוצר נשימה ולחץ בחזה.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 21,
        'Kid22',
        'Walking Corridor',
        'מסדרון ההליכה',
        'בשקע במרווח הבין‑צלעי החמישי, 2 צון לטרלית לקו האמצע הקדמי.',
        'פותח חזה, מרגיע שיעול וצפצופים, מטפל בכאבים בין‑צלעיים, קוצר נשימה ולחץ בחזה.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 22,
        'Kid23',
        'Spirit Seal',
        'חותם הרוח',
        'במרווח הבין‑צלעי הרביעי, 2 צון לטרלית לקו האמצע הקדמי.',
        'מחזק צ׳י ויין לב‑כליות, מרגיע את השן, מטפל בפחד, אינסומניה, פלפיטציות וכאבים בחזה.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 23,
        'Kid24',
        'Spirit Burial Ground',
        'קבורת הרוח',
        'במרווח הבין‑צלעי השלישי, 2 צון לטרלית לקו האמצע הקדמי.',
        'פותח חזה ומפזר ליחה, מרגיע נפש, מטפל בשיעול, צפצופים, תחושת לחץ בחזה ועצבנות.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 24,
        'Kid25',
        'Spirit Storehouse',
        'מחסן הרוח',
        'במרווח הבין‑צלעי השני, 2 צון לטרלית לקו האמצע הקדמי.',
        'מווסת צ׳י בחזה, מטפל בשיעול כרוני, אסתמה, פלפיטציות וחרדה.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 25,
        'Kid26',
        'Comfortable Chest',
        'חזה נוח',
        'במרווח הבין‑צלעי הראשון, 2 צון לטרלית לקו האמצע הקדמי.',
        'מרחיב חזה, מפחית שיעול וקוצר נשימה, מטפל בכאב בין‑צלעי ותחושת מחנק בחזה.'
    );

    INSERT INTO dr_roni_complete (id, point_code, english_name, english_name_hebrew, location_hebrew, functions_hebrew)
    VALUES (
        next_id + 26,
        'Kid27',
        'Shu Mansion',
        'אחוזת השׁו',
        'בשקע מתחת לקלביקולה, 2 צון לטרלית לקו האמצע הקדמי.',
        'מייצב ומוריד צ׳י מורד מהריאות, פותח חזה, מטפל בשיעול, אסתמה, כיח בחזה ונוקשות כתפיים.'
    );

END $$;