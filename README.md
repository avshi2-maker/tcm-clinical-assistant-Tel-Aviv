# 🌿 TCM Knowledge Base - Hebrew Deep Thinking Module

A professional Traditional Chinese Medicine (TCM) knowledge base system with Hebrew-first interface, semantic search, and AI-powered Q&A capabilities using Claude API.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Node](https://img.shields.io/badge/node-%3E%3D18.0.0-brightgreen.svg)
![Python](https://img.shields.io/badge/python-%3E%3D3.9-blue.svg)

---

## 🎯 Features

### ✨ Core Capabilities

- **📚 Bilingual Knowledge Base**: English source documents automatically translated to Hebrew
- **🔍 Semantic Search**: Vector embeddings for intelligent content matching
- **🤖 AI-Powered Q&A**: Claude Sonnet 4 provides expert TCM answers in Hebrew
- **📊 RAG System**: Retrieval-Augmented Generation ensures accurate, sourced responses
- **🎨 Professional UI**: Hebrew-first interface designed for therapists
- **📝 Source Attribution**: Shows which acupuncture points or syndromes informed each answer
- **💾 Export Capability**: Save consultations for patient records
- **⚡ Fast Performance**: Sub-second semantic search with pgvector

### 📖 Supported Content Types

- **Acupuncture Points**: Full database with locations, functions, and indications
- **Zang-Fu Syndromes**: Complete TCM pathology with symptoms and treatments
- **Extensible**: Easy to add more TCM document types

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────┐
│                   Frontend (Next.js)                     │
│         Hebrew UI + Deep Thinking Module                 │
└────────────────────┬────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────┐
│               API Layer (Next.js Routes)                 │
│    • Question processing                                 │
│    • Embedding generation                                │
│    • Vector search                                       │
│    • Claude API integration                              │
└────────────────────┬────────────────────────────────────┘
                     │
        ┌────────────┴────────────┐
        │                         │
        ↓                         ↓
┌──────────────┐          ┌──────────────┐
│   Supabase   │          │  Claude API  │
│   Database   │          │   (Sonnet)   │
│              │          │              │
│ • pgvector   │          │ • Hebrew NLU │
│ • PostgreSQL │          │ • TCM Expert │
│ • Full-text  │          │ • RAG        │
└──────┬───────┘          └──────────────┘
       │
       │ Data Processing Pipeline
       │
┌──────────────────────────────┐
│   Document Processor         │
│   (Python)                   │
│                              │
│ • DOCX extraction            │
│ • Hebrew translation         │
│ • Embedding generation       │
│ • Database population        │
└──────────────────────────────┘
```

---

## 🚀 Quick Start

### Prerequisites

- **Node.js 18+** and npm
- **Python 3.9+** and pip
- **Supabase account** (free tier works)
- **Anthropic API key** (Claude)
- **OpenAI API key** (optional, for embeddings)

### Installation

#### Option 1: Automated Setup (Recommended)

```bash
# Clone the repository
git clone <your-repo>
cd tcm-knowledge-base

# Run quick-start script
./quick-start.sh
```

The script will:
1. Check prerequisites
2. Install dependencies
3. Guide you through environment setup
4. Provide next steps

#### Option 2: Manual Setup

```bash
# 1. Install Node.js dependencies
npm install

# 2. Install Python dependencies
pip install -r requirements.txt --break-system-packages

# 3. Create environment file
cp .env.example .env.local
# Edit .env.local with your credentials

# 4. Set up Supabase database
# - Enable vector extension in Supabase dashboard
# - Run supabase-schema.sql in SQL Editor

# 5. Process TCM documents
python3 tcm_document_processor.py

# 6. Start development server
npm run dev
```

### Environment Variables

Create `.env.local` with:

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# API Keys
ANTHROPIC_API_KEY=sk-ant-api03-...
OPENAI_API_KEY=sk-...

# Development
NODE_ENV=development
```

---

## 📚 Usage

### For Therapists

1. Navigate to `/deep-thinking` in your browser
2. Select search context (points, syndromes, or both)
3. Ask questions in Hebrew about TCM topics
4. Review AI-generated answers with source attribution
5. Export consultations for patient records

### Example Questions

- `מהן נקודות הדיקור הטובות ביותר לטיפול בכאבי ראש?`
- `תאר את תסמונת חסר צ'י של הטחול`
- `איך מטפלים בנדודי שינה בדיקור סיני?`
- `מהן האינדיקציות של הנקודה LI-4?`
- `הסבר על תסמונת חסר דם של הכבד`

### API Usage

```bash
curl -X POST http://localhost:3000/api/tcm-qa \
  -H "Content-Type: application/json" \
  -d '{
    "question": "מהן נקודות דיקור לכאב ראש?",
    "context": "both",
    "language": "he",
    "maxResults": 5
  }'
```

---

## 🛠️ Development

### Project Structure

```
tcm-knowledge-base/
├── app/
│   ├── api/
│   │   └── tcm-qa/
│   │       └── route.ts          # Main Q&A API endpoint
│   └── deep-thinking/
│       └── page.tsx               # Deep Thinking page
├── components/
│   ├── DeepThinkingModule.tsx    # Main UI component
│   └── ui/                        # Shadcn UI components
├── lib/
│   └── supabase.ts                # Supabase client
├── public/
├── scripts/
│   ├── tcm_document_processor.py # Document processing
│   └── quick-start.sh             # Setup automation
├── supabase-schema.sql            # Database schema
├── requirements.txt               # Python deps
├── package.json                   # Node deps
├── SETUP_GUIDE.md                # Detailed setup guide
└── README.md                      # This file
```

### Key Technologies

- **Frontend**: Next.js 14, React 18, TypeScript
- **UI**: Tailwind CSS, Radix UI, Lucide Icons
- **Backend**: Next.js API Routes, Supabase
- **Database**: PostgreSQL with pgvector extension
- **AI**: Claude Sonnet 4 (Anthropic)
- **Embeddings**: Sentence Transformers (MiniLM)
- **Translation**: Deep Translator (Google Translate)

### Development Workflow

```bash
# Start dev server
npm run dev

# Process new documents
python3 tcm_document_processor.py

# Run tests
npm test

# Build for production
npm run build

# Start production server
npm start
```

---

## 🧪 Testing

### API Testing

```bash
# Test health endpoint
curl http://localhost:3000/api/tcm-qa

# Test Q&A
curl -X POST http://localhost:3000/api/tcm-qa \
  -H "Content-Type: application/json" \
  -d '{"question":"מהן נקודות דיקור לכאב ראש?"}'
```

### Database Testing

```sql
-- Verify data
SELECT COUNT(*) FROM acupuncture_points;
SELECT COUNT(*) FROM zangfu_syndromes;

-- Test vector search
SELECT * FROM match_acupuncture_points(
  '[0.1, 0.2, ...]'::vector(384),
  0.7,
  5
);
```

---

## 📊 Performance

### Benchmarks

| Operation | Time |
|-----------|------|
| Vector search | < 100ms |
| Claude API | 1-3s |
| Total response | < 4s |
| Document processing | 20-30min (one-time) |

### Optimization Tips

1. **Caching**: Implement Redis for frequent queries
2. **Batch Processing**: Process multiple questions together
3. **Index Tuning**: Adjust HNSW parameters for your data
4. **Connection Pooling**: Use Supabase connection pooling

---

## 🔒 Security

### Best Practices

- ✅ Use environment variables for all secrets
- ✅ Enable Supabase Row Level Security (RLS)
- ✅ Validate all user inputs
- ✅ Rate limit API endpoints
- ✅ Use service role key only server-side
- ✅ Enable CORS properly
- ✅ Monitor API usage and costs

### RLS Policies

The database schema includes RLS policies:
- Public read access for therapists
- Service role only for write operations
- Automatic timestamp updates

---

## 💰 Cost Estimation

### Monthly Costs (100-500 queries/day)

| Service | Cost |
|---------|------|
| Supabase | $0-25 |
| Claude API | $10-50 |
| OpenAI Embeddings | $1-5 |
| Vercel Hosting | $0-20 |
| **Total** | **$11-100/mo** |

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow TypeScript best practices
- Write tests for new features
- Update documentation
- Maintain Hebrew language support
- Follow existing code style

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

### Important Notes

- Ensure you have proper licensing for source TCM documents
- Verify translation rights
- Medical information usage compliance
- Attribution requirements

---

## 🆘 Support

### Documentation

- **Setup Guide**: See [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Supabase Docs**: https://supabase.com/docs
- **Claude API Docs**: https://docs.anthropic.com
- **pgvector Guide**: https://github.com/pgvector/pgvector

### Troubleshooting

Common issues and solutions are documented in [SETUP_GUIDE.md](SETUP_GUIDE.md#troubleshooting)

### Community

- File issues on GitHub
- Join our discussion forum
- Contact: support@your-domain.com

---

## 🙏 Acknowledgments

- **Anthropic** for Claude API
- **Supabase** for database infrastructure
- **pgvector** for vector search capabilities
- **TCM community** for domain knowledge
- **Open source community** for tools and libraries

---

## 🗺️ Roadmap

### Upcoming Features

- [ ] Multi-user support with therapist accounts
- [ ] Patient consultation history
- [ ] Advanced filtering and search
- [ ] Mobile app (React Native)
- [ ] Additional TCM content types
- [ ] Offline mode for embeddings
- [ ] Admin dashboard
- [ ] Analytics and reporting

---

## 📞 Contact

**Project Maintainer**: Your Organization  
**Email**: support@your-domain.com  
**Website**: https://your-domain.com  

---

**Made with ❤️ for TCM practitioners worldwide**

*Last updated: January 2026*
