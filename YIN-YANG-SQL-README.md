# YIN-YANG ACUPOINT MAPPING DATABASE

## Overview
SQL database for linking Yin-Yang assessment symptoms to acupoints, body parts, and treatment protocols.

## Files
- `yin-yang-acupoint-mapping-COMPLETE.sql` - Main SQL file

## Quick Deploy to Supabase

### Option 1: Supabase Dashboard (Recommended)
1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Go to **SQL Editor**
4. Click **New Query**
5. Copy entire contents of `yin-yang-acupoint-mapping-COMPLETE.sql`
6. Paste and click **Run**

### Option 2: Supabase CLI
```bash
supabase db reset
supabase db push
```

## Tables Created
1. `yin_yang_symptoms` - 45+ symptom-to-acupoint mappings
2. `yin_yang_pattern_protocols` - 5 treatment protocols

## Views Created
1. `v_symptom_acupoints` - Flattened acupoint lookup
2. `v_pattern_summary` - Pattern statistics

## Verify Deployment
```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' AND table_name LIKE 'yin_yang%';

-- Check data count
SELECT COUNT(*) FROM yin_yang_symptoms;
SELECT COUNT(*) FROM yin_yang_pattern_protocols;

-- Test query
SELECT * FROM yin_yang_symptoms WHERE question_id = 'energy_level' LIMIT 3;
```

## Integration with Existing Tables
- Joins with `tcm_acupoints` (existing)
- Joins with `tcm_images` (existing)

## Date Created
January 20, 2026

## Version
1.0.0
