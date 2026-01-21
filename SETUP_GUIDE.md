# TCM Knowledge Base - Complete Setup Guide
## Hebrew Q&A System with Deep Thinking Module

This guide will help you set up a complete TCM (Traditional Chinese Medicine) knowledge base system with Hebrew translation, semantic search, and AI-powered Q&A capabilities.

---

## 📋 Table of Contents

1. [System Overview](#system-overview)
2. [Prerequisites](#prerequisites)
3. [Environment Setup](#environment-setup)
4. [Database Setup](#database-setup)
5. [Document Processing](#document-processing)
6. [API Configuration](#api-configuration)
7. [Frontend Integration](#frontend-integration)
8. [Testing & Validation](#testing-validation)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 System Overview

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│                     User Interface                       │
│              (DeepThinkingModule.tsx)                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     │ Hebrew Question
                     ↓
┌─────────────────────────────────────────────────────────┐
│                   Next.js API Route                      │
│              (/api/tcm-qa/route.ts)                     │
│  • Receives question                                     │
│  • Generates embedding                                   │
│  • Searches Supabase                                     │
│  • Calls Claude API                                      │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ↓                         ↓
┌──────────────┐          ┌──────────────┐
│   Supabase   │          │  Claude API  │
│   Database   │          │   (Sonnet)   │
│              │          │              │
│ • Vector DB  │          │ • Hebrew NLU │
│ • Embeddings │          │ • TCM Expert │
│ • Full-text  │          │ • Answer Gen │
└──────────────┘          └──────────────┘
        ↑
        │
        │ Populated by
        │
┌──────────────────────────┐
│   Document Processor     │
│ (tcm_document_processor) │
│                          │
│ • Extracts DOCX content  │
│ • Translates to Hebrew   │
│ • Generates embeddings   │
│ • Stores in Supabase     │
└──────────────────────────┘
```

### Key Features

✅ **Bilingual Support**: English source → Hebrew interface
✅ **Semantic Search**: Vector embeddings for intelligent matching
✅ **RAG System**: Retrieval-Augmented Generation for accurate answers
✅ **Professional UI**: Hebrew-first, therapist-focused interface
✅ **Source Attribution**: Shows which points/syndromes informed the answer
✅ **Export Capability**: Save consultations for patient records

---

## 🔧 Prerequisites

### Required Software

- **Python 3.9+** with pip
- **Node.js 18+** with npm/yarn
- **Supabase Account** (free tier works)
- **Anthropic API Key** (for Claude)
- **OpenAI API Key** (optional, for embeddings)

### Required Python Packages

```bash
pip install --break-system-packages \
  python-docx \
  pypandoc \
  deep-translator \
  supabase \
  sentence-transformers \
  tqdm \
  anthropic
```

### Required Node.js Packages

```bash
npm install \
  @supabase/supabase-js \
  @anthropic-ai/sdk \
  @radix-ui/react-tabs \
  @radix-ui/react-alert \
  lucide-react
```

---

## 🌍 Environment Setup

### 1. Create Environment File

Create `.env.local` in your Next.js project root:

```bash
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# API Keys
ANTHROPIC_API_KEY=sk-ant-api03-...
OPENAI_API_KEY=sk-...  # For embeddings

# Optional: Translation API (if not using deep-translator)
GOOGLE_TRANSLATE_API_KEY=...

# Development
NODE_ENV=development
```

### 2. Secure Your Keys

**IMPORTANT**: Never commit `.env.local` to version control!

Add to `.gitignore`:
```
.env.local
.env*.local
*.pyc
__pycache__/
```

---

## 💾 Database Setup

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Choose a region close to your users (for Israel: EU/Middle East)
4. Save your project URL and keys

### Step 2: Enable Vector Extension

1. Go to **Database** → **Extensions**
2. Enable `vector` extension
3. This enables vector similarity search

### Step 3: Run Schema Script

1. Go to **SQL Editor** in Supabase
2. Create new query
3. Copy contents of `supabase-schema.sql`
4. Run the script

This creates:
- `acupuncture_points` table
- `zangfu_syndromes` table
- `tcm_documents` table
- Vector search functions
- Indexes for performance

### Step 4: Verify Setup

Run this query to verify:

```sql
-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check if vector extension is enabled
SELECT * FROM pg_extension WHERE extname = 'vector';

-- Test vector search function
SELECT match_acupuncture_points(
  array_fill(0.1::float, ARRAY[384])::vector(384),
  0.5,
  5
);
```

---

## 📚 Document Processing

### Step 1: Prepare Your Documents

Place your DOCX files in the working directory:
- `ACUPUNCTURE POINTS BOOK^MPOINTS CATACORIES.docx`
- `zang-fu-syndromes-hebrew.docx`

### Step 2: Configure Processor

Edit `tcm_document_processor.py`:

```python
# Configuration section
SUPABASE_URL = "https://your-project.supabase.co"
SUPABASE_KEY = "your-service-role-key"  # Use service role for inserts

ACUPUNCTURE_FILE = 'ACUPUNCTURE POINTS BOOK^MPOINTS CATACORIES.docx'
SYNDROME_FILE = 'zang-fu-syndromes-hebrew.docx'
```

### Step 3: First-Time Setup (Create Tables)

Uncomment these lines in the `main()` function:

```python
# Setup database (first time only)
sql_commands = await processor.db.setup_tables()
print("Run these SQL commands in Supabase SQL editor:")
print(sql_commands)
```

### Step 4: Run Document Processing

```bash
python3 tcm_document_processor.py
```

**Expected Output:**
```
====================================================================
🌿 TCM Document Processing Pipeline
====================================================================

📖 Processing Acupuncture Points Book: ACUPUNCTURE POINTS BOOK...
Found 1247 sections
Extracted 361 acupuncture points
Translating to Hebrew: 100%|████████████| 361/361 [15:23<00:00]
Processing points: 100%|████████████████| 361/361 [20:15<00:00]
✅ Completed processing 361 acupuncture points

📖 Processing Zang-Fu Syndromes: zang-fu-syndromes-hebrew.docx
Found 2144 sections
Extracted 87 syndromes
Processing syndromes: 100%|████████████| 87/87 [05:42<00:00]
✅ Completed processing 87 syndromes

====================================================================
✅ All documents processed successfully!
====================================================================
```

### Step 5: Verify Data Import

Check Supabase:

```sql
-- Count points
SELECT COUNT(*) FROM acupuncture_points;

-- Count syndromes
SELECT COUNT(*) FROM zangfu_syndromes;

-- Check sample data
SELECT point_code, name_he, meridian 
FROM acupuncture_points 
LIMIT 5;
```

---

## 🔌 API Configuration

### Step 1: Create API Route

Create file: `app/api/tcm-qa/route.ts`

Use the provided `tcm-qa-api-route.ts` code.

### Step 2: Test API Endpoint

```bash
curl -X POST http://localhost:3000/api/tcm-qa \
  -H "Content-Type: application/json" \
  -d '{
    "question": "מהן נקודות הדיקור הטובות ביותר לטיפול בכאבי ראש?",
    "context": "both",
    "language": "he",
    "maxResults": 5
  }'
```

**Expected Response:**
```json
{
  "question": "מהן נקודות הדיקור הטובות ביותר לטיפול בכאבי ראש?",
  "answer": "לטיפול בכאבי ראש, נקודות הדיקור המומלצות ביותר הן:\n\n1. LI-4 (הגו)...",
  "sources": {
    "points": 5,
    "syndromes": 0
  },
  "metadata": {
    "pointResults": [
      {
        "code": "LI-4",
        "name": "הגו",
        "similarity": 0.89
      }
    ]
  }
}
```

---

## 🎨 Frontend Integration

### Step 1: Add Component

Copy `DeepThinkingModule.tsx` to your components directory:

```
src/
  components/
    DeepThinkingModule.tsx
    ui/
      card.tsx
      button.tsx
      textarea.tsx
      tabs.tsx
      alert.tsx
      badge.tsx
```

### Step 2: Add to Page

```tsx
// app/deep-thinking/page.tsx
import { DeepThinkingModule } from '@/components/DeepThinkingModule';

export default function DeepThinkingPage() {
  return (
    <div className="container mx-auto py-8">
      <DeepThinkingModule />
    </div>
  );
}
```

### Step 3: Configure Tailwind

Add to `tailwind.config.js`:

```js
module.exports = {
  content: [
    './app/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Arial', 'Helvetica', 'sans-serif'],
      },
    },
  },
  plugins: [
    require('@tailwindcss/typography'),
  ],
};
```

### Step 4: Add Hebrew Font Support

Add to `app/globals.css`:

```css
@layer base {
  html {
    direction: rtl;
  }
  
  body {
    font-family: 'Arial', 'Helvetica', sans-serif;
    direction: rtl;
  }
}
```

---

## ✅ Testing & Validation

### Test Checklist

- [ ] Database tables created
- [ ] Vector extension enabled
- [ ] Sample data inserted
- [ ] API endpoint responds
- [ ] Hebrew text displays correctly
- [ ] Search returns relevant results
- [ ] Claude generates appropriate answers
- [ ] Sources are properly attributed
- [ ] Export functionality works

### Sample Test Questions

1. **Basic Point Query**: "מהן האינדיקציות של הנקודה LI-4?"
2. **Syndrome Query**: "תאר את תסמונת חסר צ'י של הטחול"
3. **Treatment Query**: "איך מטפלים בנדודי שינה בדיקור סיני?"
4. **Comparative Query**: "מה ההבדל בין חסר דם לחסר צ'י?"
5. **Complex Query**: "אילו נקודות דיקור מתאימות לטיפול במיגרנה עם בחילות?"

### Performance Benchmarks

| Operation | Expected Time |
|-----------|--------------|
| Vector search | < 100ms |
| Claude API call | 1-3 seconds |
| Total response | < 4 seconds |
| Document processing | 20-30 min (one-time) |

---

## 🔧 Troubleshooting

### Common Issues

#### 1. Translation Errors

**Problem**: "Translation API rate limit exceeded"

**Solution**:
```python
# Add delays in HebrewTranslator class
import time
time.sleep(0.5)  # Between translations
```

#### 2. Vector Dimension Mismatch

**Problem**: "dimension mismatch"

**Solution**: Ensure all embeddings use same model:
```python
# Always use the same model
model = SentenceTransformer('all-MiniLM-L6-v2')  # 384 dimensions
```

#### 3. Claude API Errors

**Problem**: "Invalid API key"

**Solution**: Check your `.env.local`:
```bash
# Verify API key format
ANTHROPIC_API_KEY=sk-ant-api03-...
```

#### 4. Hebrew Display Issues

**Problem**: Text appears left-to-right

**Solution**: Add RTL support:
```tsx
<div dir="rtl" className="...">
```

#### 5. Slow Search Performance

**Problem**: Queries take > 1 second

**Solution**: Check indexes:
```sql
-- Verify HNSW index exists
SELECT indexname FROM pg_indexes 
WHERE tablename = 'acupuncture_points';

-- Rebuild if needed
REINDEX INDEX idx_acupuncture_points_embedding_hnsw;
```

---

## 🚀 Production Deployment

### Checklist

- [ ] Use environment variables (not hardcoded keys)
- [ ] Enable Supabase RLS policies
- [ ] Set up monitoring (Sentry, LogRocket)
- [ ] Configure rate limiting
- [ ] Enable CORS properly
- [ ] Set up backups
- [ ] Test with production data
- [ ] Monitor API costs (Claude + OpenAI)

### Recommended Hosting

- **Frontend**: Vercel (automatic Next.js optimization)
- **Database**: Supabase (already cloud-hosted)
- **APIs**: Serverless functions (included with Vercel)

---

## 📊 Cost Estimation

### Monthly Costs (Estimated)

| Service | Free Tier | Paid Tier |
|---------|-----------|-----------|
| Supabase | 500MB DB, 2GB bandwidth | $25/mo for 8GB |
| Claude API | - | ~$0.003/1K tokens |
| OpenAI Embeddings | - | ~$0.0001/1K tokens |
| Vercel | 100GB bandwidth | $20/mo Pro |

**Typical Monthly**: $50-100 for moderate usage (100-500 queries/day)

---

## 📞 Support & Resources

### Documentation

- [Supabase Docs](https://supabase.com/docs)
- [Anthropic Claude API](https://docs.anthropic.com)
- [pgvector Guide](https://github.com/pgvector/pgvector)

### Community

- Supabase Discord
- Anthropic Developer Community
- TCM Professional Forums

---

## 📝 License & Attribution

This implementation template is provided as-is for professional TCM practice management systems.

**Important**: Ensure you have proper licensing for:
- Source TCM documents
- Translation rights
- Medical information usage

---

**Version**: 1.0.0  
**Last Updated**: January 2026  
**Maintained by**: [Your Organization]
