-- Fix Vector Search Functions - Lower Threshold for Better Hebrew Matching
-- Run this in Supabase SQL Editor

-- Drop existing functions first
DROP FUNCTION IF EXISTS match_acupuncture_points(vector, float, int);
DROP FUNCTION IF EXISTS match_syndromes(vector, float, int);

-- Fix acupuncture points search (lower threshold from 0.5 to 0.3)
CREATE OR REPLACE FUNCTION match_acupuncture_points(
  query_embedding vector(384),
  match_threshold float DEFAULT 0.3,  -- Lowered from 0.5
  match_count int DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  point_code text,
  name_en text,
  name_he text,
  meridian text,
  point_number int,
  location_en text,
  location_he text,
  functions_en text,
  functions_he text,
  indications_en text,
  indications_he text,
  similarity float
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    acupuncture_points.id,
    acupuncture_points.point_code,
    acupuncture_points.name_en,
    acupuncture_points.name_he,
    acupuncture_points.meridian,
    acupuncture_points.point_number,
    acupuncture_points.location_en,
    acupuncture_points.location_he,
    acupuncture_points.functions_en,
    acupuncture_points.functions_he,
    acupuncture_points.indications_en,
    acupuncture_points.indications_he,
    1 - (acupuncture_points.embedding <=> query_embedding) as similarity
  FROM acupuncture_points
  WHERE 1 - (acupuncture_points.embedding <=> query_embedding) > match_threshold
  ORDER BY acupuncture_points.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;

-- Fix syndromes search (lower threshold from 0.5 to 0.3)
CREATE OR REPLACE FUNCTION match_syndromes(
  query_embedding vector(384),
  match_threshold float DEFAULT 0.3,  -- Lowered from 0.5
  match_count int DEFAULT 10
)
RETURNS TABLE (
  id uuid,
  name_en text,
  name_he text,
  symptoms_en text,
  symptoms_he text,
  etiology_en text,
  etiology_he text,
  tongue_en text,
  tongue_he text,
  pulse_en text,
  pulse_he text,
  treatment_en text,
  treatment_he text,
  similarity float
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    zangfu_syndromes.id,
    zangfu_syndromes.name_en,
    zangfu_syndromes.name_he,
    zangfu_syndromes.symptoms_en,
    zangfu_syndromes.symptoms_he,
    zangfu_syndromes.etiology_en,
    zangfu_syndromes.etiology_he,
    zangfu_syndromes.tongue_en,
    zangfu_syndromes.tongue_he,
    zangfu_syndromes.pulse_en,
    zangfu_syndromes.pulse_he,
    zangfu_syndromes.treatment_en,
    zangfu_syndromes.treatment_he,
    1 - (zangfu_syndromes.embedding <=> query_embedding) as similarity
  FROM zangfu_syndromes
  WHERE 1 - (zangfu_syndromes.embedding <=> query_embedding) > match_threshold
  ORDER BY zangfu_syndromes.embedding <=> query_embedding
  LIMIT match_count;
END;
$$;
