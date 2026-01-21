-- ============================================================================
-- TCM Knowledge Base - Supabase Database Schema
-- Hebrew-First Design with Vector Search Support
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================================
-- Main Tables
-- ============================================================================

-- Acupuncture Points Table
CREATE TABLE IF NOT EXISTS acupuncture_points (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    point_code TEXT UNIQUE NOT NULL,
    name_en TEXT,
    name_he TEXT NOT NULL,
    meridian TEXT NOT NULL,
    point_number INTEGER NOT NULL,
    
    -- Location information
    location_en TEXT,
    location_he TEXT,
    
    -- Functions and indications
    functions_en TEXT,
    functions_he TEXT,
    indications_en TEXT,
    indications_he TEXT,
    
    -- Additional metadata
    metadata JSONB DEFAULT '{}',
    
    -- Vector embedding for semantic search (384 dimensions for MiniLM)
    embedding vector(384),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Zang-Fu Syndromes Table
CREATE TABLE IF NOT EXISTS zangfu_syndromes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name_en TEXT,
    name_he TEXT NOT NULL,
    
    -- Syndrome details
    etiology_en TEXT,
    etiology_he TEXT,
    symptoms_en TEXT,
    symptoms_he TEXT,
    tongue_en TEXT,
    tongue_he TEXT,
    pulse_en TEXT,
    pulse_he TEXT,
    treatment_en TEXT,
    treatment_he TEXT,
    
    -- Additional metadata
    metadata JSONB DEFAULT '{}',
    
    -- Vector embedding for semantic search
    embedding vector(384),
    
    -- Timestamps
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- General TCM Documents Table (for other content)
CREATE TABLE IF NOT EXISTS tcm_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_file TEXT NOT NULL,
    section_type TEXT NOT NULL,
    title_en TEXT,
    title_he TEXT,
    content_en TEXT,
    content_he TEXT,
    metadata JSONB DEFAULT '{}',
    embedding vector(384),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================================================
-- Indexes for Performance
-- ============================================================================

-- B-tree indexes for exact matches
CREATE INDEX IF NOT EXISTS idx_acupuncture_points_meridian 
    ON acupuncture_points(meridian);
CREATE INDEX IF NOT EXISTS idx_acupuncture_points_code 
    ON acupuncture_points(point_code);
CREATE INDEX IF NOT EXISTS idx_acupuncture_points_number 
    ON acupuncture_points(point_number);

-- GIN indexes for full-text search on Hebrew content
CREATE INDEX IF NOT EXISTS idx_acupuncture_points_name_he_gin 
    ON acupuncture_points USING GIN (to_tsvector('simple', name_he));
CREATE INDEX IF NOT EXISTS idx_syndromes_name_he_gin 
    ON zangfu_syndromes USING GIN (to_tsvector('simple', name_he));

-- HNSW indexes for vector similarity search (faster than IVFFlat for most cases)
CREATE INDEX IF NOT EXISTS idx_acupuncture_points_embedding_hnsw 
    ON acupuncture_points USING hnsw (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_syndromes_embedding_hnsw 
    ON zangfu_syndromes USING hnsw (embedding vector_cosine_ops);
CREATE INDEX IF NOT EXISTS idx_tcm_documents_embedding_hnsw 
    ON tcm_documents USING hnsw (embedding vector_cosine_ops);

-- Metadata indexes (for filtering by specific fields)
CREATE INDEX IF NOT EXISTS idx_acupuncture_points_metadata 
    ON acupuncture_points USING GIN (metadata);
CREATE INDEX IF NOT EXISTS idx_syndromes_metadata 
    ON zangfu_syndromes USING GIN (metadata);

-- ============================================================================
-- Vector Similarity Search Functions
-- ============================================================================

-- Search acupuncture points by semantic similarity
CREATE OR REPLACE FUNCTION match_acupuncture_points(
    query_embedding vector(384),
    match_threshold float DEFAULT 0.7,
    match_count int DEFAULT 5
)
RETURNS TABLE (
    id uuid,
    point_code text,
    name_he text,
    name_en text,
    location_he text,
    functions_he text,
    indications_he text,
    similarity float
)
LANGUAGE sql STABLE
AS $$
    SELECT
        acupuncture_points.id,
        acupuncture_points.point_code,
        acupuncture_points.name_he,
        acupuncture_points.name_en,
        acupuncture_points.location_he,
        acupuncture_points.functions_he,
        acupuncture_points.indications_he,
        1 - (acupuncture_points.embedding <=> query_embedding) as similarity
    FROM acupuncture_points
    WHERE 1 - (acupuncture_points.embedding <=> query_embedding) > match_threshold
    ORDER BY similarity DESC
    LIMIT match_count;
$$;

-- Search syndromes by semantic similarity
CREATE OR REPLACE FUNCTION match_syndromes(
    query_embedding vector(384),
    match_threshold float DEFAULT 0.7,
    match_count int DEFAULT 5
)
RETURNS TABLE (
    id uuid,
    name_he text,
    name_en text,
    symptoms_he text,
    treatment_he text,
    similarity float
)
LANGUAGE sql STABLE
AS $$
    SELECT
        zangfu_syndromes.id,
        zangfu_syndromes.name_he,
        zangfu_syndromes.name_en,
        zangfu_syndromes.symptoms_he,
        zangfu_syndromes.treatment_he,
        1 - (zangfu_syndromes.embedding <=> query_embedding) as similarity
    FROM zangfu_syndromes
    WHERE 1 - (zangfu_syndromes.embedding <=> query_embedding) > match_threshold
    ORDER BY similarity DESC
    LIMIT match_count;
$$;

-- Hybrid search: combine full-text and vector search for acupuncture points
CREATE OR REPLACE FUNCTION hybrid_search_points(
    query_text text,
    query_embedding vector(384),
    match_threshold float DEFAULT 0.7,
    match_count int DEFAULT 5
)
RETURNS TABLE (
    id uuid,
    point_code text,
    name_he text,
    location_he text,
    functions_he text,
    similarity float,
    text_rank float
)
LANGUAGE sql STABLE
AS $$
    WITH vector_matches AS (
        SELECT
            id,
            point_code,
            name_he,
            location_he,
            functions_he,
            1 - (embedding <=> query_embedding) as similarity
        FROM acupuncture_points
        WHERE 1 - (embedding <=> query_embedding) > match_threshold
    ),
    text_matches AS (
        SELECT
            id,
            ts_rank(to_tsvector('simple', name_he || ' ' || COALESCE(functions_he, '')), 
                    plainto_tsquery('simple', query_text)) as rank
        FROM acupuncture_points
        WHERE to_tsvector('simple', name_he || ' ' || COALESCE(functions_he, '')) @@ 
              plainto_tsquery('simple', query_text)
    )
    SELECT
        v.id,
        v.point_code,
        v.name_he,
        v.location_he,
        v.functions_he,
        v.similarity,
        COALESCE(t.rank, 0) as text_rank
    FROM vector_matches v
    LEFT JOIN text_matches t ON v.id = t.id
    ORDER BY (v.similarity * 0.7 + COALESCE(t.rank, 0) * 0.3) DESC
    LIMIT match_count;
$$;

-- ============================================================================
-- Helper Functions
-- ============================================================================

-- Get all points for a specific meridian
CREATE OR REPLACE FUNCTION get_meridian_points(
    meridian_code text
)
RETURNS TABLE (
    point_code text,
    name_he text,
    location_he text,
    functions_he text
)
LANGUAGE sql STABLE
AS $$
    SELECT
        point_code,
        name_he,
        location_he,
        functions_he
    FROM acupuncture_points
    WHERE meridian = meridian_code
    ORDER BY point_number;
$$;

-- Search by point code pattern (e.g., "LI-%" for all Large Intestine points)
CREATE OR REPLACE FUNCTION search_point_codes(
    code_pattern text
)
RETURNS TABLE (
    point_code text,
    name_he text,
    name_en text,
    location_he text
)
LANGUAGE sql STABLE
AS $$
    SELECT
        point_code,
        name_he,
        name_en,
        location_he
    FROM acupuncture_points
    WHERE point_code LIKE code_pattern
    ORDER BY point_code;
$$;

-- ============================================================================
-- Triggers for Updated Timestamps
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_acupuncture_points_updated_at BEFORE UPDATE
    ON acupuncture_points FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_syndromes_updated_at BEFORE UPDATE
    ON zangfu_syndromes FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

CREATE TRIGGER update_tcm_documents_updated_at BEFORE UPDATE
    ON tcm_documents FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- ============================================================================
-- Row Level Security (RLS) Policies
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE acupuncture_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE zangfu_syndromes ENABLE ROW LEVEL SECURITY;
ALTER TABLE tcm_documents ENABLE ROW LEVEL SECURITY;

-- Allow public read access (for authenticated therapists)
CREATE POLICY "Allow public read access to acupuncture points"
    ON acupuncture_points FOR SELECT
    USING (true);

CREATE POLICY "Allow public read access to syndromes"
    ON zangfu_syndromes FOR SELECT
    USING (true);

CREATE POLICY "Allow public read access to documents"
    ON tcm_documents FOR SELECT
    USING (true);

-- Only service role can insert/update/delete (for data management)
-- These policies are created but will only work with service_role key
CREATE POLICY "Service role can insert acupuncture points"
    ON acupuncture_points FOR INSERT
    WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Service role can update acupuncture points"
    ON acupuncture_points FOR UPDATE
    USING (auth.role() = 'service_role');

CREATE POLICY "Service role can delete acupuncture points"
    ON acupuncture_points FOR DELETE
    USING (auth.role() = 'service_role');

-- ============================================================================
-- Sample Data for Testing
-- ============================================================================

-- Insert a few sample points for testing
INSERT INTO acupuncture_points (
    point_code, name_en, name_he, meridian, point_number,
    location_en, location_he,
    functions_en, functions_he,
    indications_en, indications_he
) VALUES 
(
    'LI-4', 'Hegu', 'הגו',
    'LI', 4,
    'On the dorsum of the hand, between the 1st and 2nd metacarpal bones',
    'על גב כף היד, בין עצמות המטקרפל הראשונה והשנייה',
    'Clears heat, releases exterior, disperses Wind',
    'מפזר חום, משחרר חיצוניות, מפזר רוח',
    'Headache, toothache, facial pain, sore throat',
    'כאב ראש, כאב שיניים, כאב פנים, כאב גרון'
),
(
    'ST-36', 'Zusanli', 'זוסנלי',
    'ST', 36,
    '3 cun below ST-35, one finger-breadth from the anterior crest of the tibia',
    '3 צון מתחת ל-ST-35, רוחב אצבע אחת מהשן הקדמי של השוקה',
    'Tonifies Qi and Blood, strengthens Spleen and Stomach',
    'מחזק צ\'י ודם, מחזק טחול וקיבה',
    'Digestive issues, fatigue, immune system support',
    'בעיות עיכול, עייפות, תמיכה במערכת החיסון'
);

-- ============================================================================
-- Usage Notes
-- ============================================================================

-- To use these functions, you'll need to:
-- 1. Install the pgvector extension
-- 2. Generate embeddings for your content (using Python script)
-- 3. Insert data with embeddings
-- 4. Query using the match_* functions

-- Example query:
-- SELECT * FROM match_acupuncture_points(
--     '[0.1, 0.2, ...]'::vector(384),  -- your query embedding
--     0.7,  -- similarity threshold
--     5     -- max results
-- );

COMMENT ON TABLE acupuncture_points IS 'Acupuncture points with Hebrew translations and vector embeddings for semantic search';
COMMENT ON TABLE zangfu_syndromes IS 'Zang-Fu syndrome patterns with Hebrew content and embeddings';
COMMENT ON FUNCTION match_acupuncture_points IS 'Semantic search for acupuncture points using vector similarity';
COMMENT ON FUNCTION match_syndromes IS 'Semantic search for syndromes using vector similarity';
