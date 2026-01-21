# 🚀 Production Deployment Guide

Complete guide for deploying the TCM Knowledge Base to production.

---

## 📋 Pre-Deployment Checklist

### Code Review
- [ ] All environment variables using process.env
- [ ] No hardcoded API keys or secrets
- [ ] Error handling implemented
- [ ] Input validation added
- [ ] Rate limiting configured
- [ ] CORS properly set up
- [ ] Logging implemented
- [ ] Tests passing

### Security
- [ ] Supabase RLS policies enabled
- [ ] Service role key used only server-side
- [ ] API key rotation plan in place
- [ ] HTTPS enforced
- [ ] CSP headers configured
- [ ] XSS protection enabled
- [ ] SQL injection prevention verified

### Performance
- [ ] Database indexes created
- [ ] Vector search optimized
- [ ] Caching strategy defined
- [ ] CDN configured
- [ ] Images optimized
- [ ] Bundle size checked
- [ ] Lighthouse score > 90

### Monitoring
- [ ] Error tracking set up (Sentry)
- [ ] Analytics configured
- [ ] Uptime monitoring active
- [ ] Log aggregation ready
- [ ] Alert system configured
- [ ] Backup strategy defined

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Users (Therapists)                    │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ↓
┌─────────────────────────────────────────────────────────┐
│                  Vercel Edge Network                     │
│                  (Global CDN + SSL)                      │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ↓
┌─────────────────────────────────────────────────────────┐
│              Next.js App (Serverless)                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │  Static Pages (SSG)   │   API Routes (Edge)     │   │
│  │  - Landing            │   - /api/tcm-qa         │   │
│  │  - About              │   - /api/health         │   │
│  │  - Deep Thinking UI   │                         │   │
│  └─────────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────────┘
                        │
         ┌──────────────┴──────────────┐
         │                             │
         ↓                             ↓
┌─────────────────┐          ┌─────────────────┐
│    Supabase     │          │  Anthropic API  │
│   (Database)    │          │    (Claude)     │
│                 │          │                 │
│ • PostgreSQL    │          │ • Sonnet 4      │
│ • pgvector      │          │ • Hebrew NLU    │
│ • EU Region     │          │ • RAG Engine    │
└─────────────────┘          └─────────────────┘
```

---

## 🌐 Deployment Options

### Option 1: Vercel (Recommended)

#### Step 1: Prepare Repository

```bash
# 1. Commit all changes
git add .
git commit -m "Production ready"

# 2. Push to GitHub
git push origin main
```

#### Step 2: Deploy to Vercel

1. Go to [vercel.com](https://vercel.com)
2. Click "New Project"
3. Import your GitHub repository
4. Configure:

```
Framework Preset: Next.js
Build Command: npm run build
Output Directory: .next
Install Command: npm install
```

#### Step 3: Configure Environment Variables

In Vercel Dashboard → Settings → Environment Variables:

```bash
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# API Keys
ANTHROPIC_API_KEY=sk-ant-api03-...
OPENAI_API_KEY=sk-...

# Production
NODE_ENV=production
```

#### Step 4: Deploy

Click "Deploy" and wait for build to complete.

#### Step 5: Custom Domain (Optional)

1. Go to Settings → Domains
2. Add your domain: `tcm.yourdomain.com`
3. Configure DNS (follow Vercel's instructions)

---

### Option 2: Self-Hosted (Docker)

#### Step 1: Create Dockerfile

```dockerfile
# Dockerfile
FROM node:18-alpine AS base

# Install dependencies only when needed
FROM base AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

# Rebuild the source code only when needed
FROM base AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

ENV NEXT_TELEMETRY_DISABLED 1
RUN npm run build

# Production image
FROM base AS runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER nextjs

EXPOSE 3000

ENV PORT 3000
ENV HOSTNAME "0.0.0.0"

CMD ["node", "server.js"]
```

#### Step 2: Create docker-compose.yml

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_SUPABASE_URL=${NEXT_PUBLIC_SUPABASE_URL}
      - NEXT_PUBLIC_SUPABASE_ANON_KEY=${NEXT_PUBLIC_SUPABASE_ANON_KEY}
      - SUPABASE_SERVICE_ROLE_KEY=${SUPABASE_SERVICE_ROLE_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - NODE_ENV=production
    restart: unless-stopped
    
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl
    depends_on:
      - app
    restart: unless-stopped
```

#### Step 3: Deploy

```bash
# Build and start
docker-compose up -d

# Check logs
docker-compose logs -f app

# Update
git pull
docker-compose down
docker-compose up -d --build
```

---

## 🗄️ Database Production Setup

### Supabase Production Configuration

#### Step 1: Upgrade Plan (if needed)

For production, consider:
- **Pro Plan** ($25/mo): 8GB database, 250GB bandwidth
- **Team Plan** ($599/mo): Dedicated resources

#### Step 2: Configure Connection Pooling

1. Go to Database Settings
2. Enable Connection Pooling
3. Use pooled connection string in production

#### Step 3: Backup Configuration

```sql
-- Enable Point-in-Time Recovery (PITR)
-- In Supabase Dashboard: Database → Backups → Enable PITR

-- Manual backup script
pg_dump -h db.xxx.supabase.co \
  -U postgres \
  -d postgres \
  -F c \
  -f backup_$(date +%Y%m%d).dump
```

#### Step 4: Monitoring

Enable in Dashboard:
- Query performance monitoring
- Disk usage alerts
- Connection pool monitoring

---

## ⚡ Performance Optimization

### 1. Caching Strategy

```typescript
// lib/cache.ts
import { Redis } from '@upstash/redis'

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_URL,
  token: process.env.UPSTASH_REDIS_TOKEN,
})

export async function getCachedAnswer(question: string) {
  const cacheKey = `tcm-qa:${question}`
  const cached = await redis.get(cacheKey)
  
  if (cached) return JSON.parse(cached as string)
  return null
}

export async function cacheAnswer(question: string, answer: any) {
  const cacheKey = `tcm-qa:${question}`
  await redis.set(cacheKey, JSON.stringify(answer), {
    ex: 86400, // 24 hours
  })
}
```

### 2. Database Connection Pool

```typescript
// lib/supabase-server.ts
import { createClient } from '@supabase/supabase-js'

export const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    db: {
      schema: 'public',
    },
    auth: {
      persistSession: false,
    },
    global: {
      headers: {
        'x-connection-pool': 'true',
      },
    },
  }
)
```

### 3. Vector Index Optimization

```sql
-- Optimize HNSW index for production
DROP INDEX IF EXISTS idx_acupuncture_points_embedding_hnsw;

CREATE INDEX idx_acupuncture_points_embedding_hnsw 
ON acupuncture_points 
USING hnsw (embedding vector_cosine_ops)
WITH (m = 32, ef_construction = 100);

-- Analyze tables for query planner
ANALYZE acupuncture_points;
ANALYZE zangfu_syndromes;
```

---

## 📊 Monitoring & Logging

### 1. Error Tracking with Sentry

```bash
npm install @sentry/nextjs
```

```javascript
// sentry.client.config.js
import * as Sentry from "@sentry/nextjs";

Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  tracesSampleRate: 1.0,
  environment: process.env.NODE_ENV,
});
```

### 2. Analytics with Vercel Analytics

```typescript
// app/layout.tsx
import { Analytics } from '@vercel/analytics/react'

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  )
}
```

### 3. Uptime Monitoring

Use services like:
- **UptimeRobot**: Free tier, 50 monitors
- **Pingdom**: Professional monitoring
- **Better Uptime**: Beautiful status pages

---

## 🔐 Security Hardening

### 1. API Rate Limiting

```typescript
// middleware.ts
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'
import { Ratelimit } from '@upstash/ratelimit'
import { Redis } from '@upstash/redis'

const ratelimit = new Ratelimit({
  redis: Redis.fromEnv(),
  limiter: Ratelimit.slidingWindow(10, '10 s'),
})

export async function middleware(request: NextRequest) {
  if (request.nextUrl.pathname.startsWith('/api/')) {
    const ip = request.ip ?? '127.0.0.1'
    const { success } = await ratelimit.limit(ip)
    
    if (!success) {
      return new NextResponse('Too Many Requests', { status: 429 })
    }
  }
  
  return NextResponse.next()
}
```

### 2. Input Validation

```typescript
// lib/validation.ts
import { z } from 'zod'

export const qaRequestSchema = z.object({
  question: z.string()
    .min(1, 'Question cannot be empty')
    .max(500, 'Question too long'),
  context: z.enum(['points', 'syndromes', 'both']),
  language: z.enum(['he', 'en']),
  maxResults: z.number().min(1).max(10),
})
```

### 3. CORS Configuration

```typescript
// next.config.js
module.exports = {
  async headers() {
    return [
      {
        source: '/api/:path*',
        headers: [
          { key: 'Access-Control-Allow-Credentials', value: 'true' },
          { key: 'Access-Control-Allow-Origin', value: 'https://yourdomain.com' },
          { key: 'Access-Control-Allow-Methods', value: 'GET,POST' },
          { key: 'Access-Control-Allow-Headers', value: 'Content-Type' },
        ],
      },
    ]
  },
}
```

---

## 💰 Cost Optimization

### 1. Claude API Cost Management

```typescript
// Implement token counting and limits
import Anthropic from '@anthropic-ai/sdk'

const MAX_TOKENS_PER_REQUEST = 2000
const MONTHLY_BUDGET_USD = 100

async function generateAnswer(prompt: string) {
  // Check budget before making call
  const usage = await getMonthlyUsage()
  if (usage > MONTHLY_BUDGET_USD) {
    throw new Error('Monthly budget exceeded')
  }
  
  const message = await anthropic.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: MAX_TOKENS_PER_REQUEST,
    temperature: 0.3,
    messages: [{ role: 'user', content: prompt }],
  })
  
  // Log usage
  await logTokenUsage(message.usage)
  
  return message
}
```

### 2. Caching Strategy

- Cache frequently asked questions
- Use CDN for static assets
- Implement query result caching
- Use Supabase connection pooling

### 3. Resource Monitoring

```typescript
// Monitor API costs
import { trackEvent } from '@/lib/analytics'

async function handleQARequest(question: string) {
  const startTime = Date.now()
  
  try {
    const result = await generateAnswer(question)
    
    // Track metrics
    trackEvent('qa_request', {
      responseTime: Date.now() - startTime,
      tokens: result.usage?.output_tokens || 0,
      cached: result.cached,
    })
    
    return result
  } catch (error) {
    trackEvent('qa_error', { error: error.message })
    throw error
  }
}
```

---

## 🚨 Incident Response

### Monitoring Alerts

Set up alerts for:
- API error rate > 5%
- Response time > 5 seconds
- Database CPU > 80%
- Disk usage > 80%
- Monthly budget > 80%

### Rollback Procedure

```bash
# Vercel
vercel rollback

# Docker
git checkout <previous-commit>
docker-compose down
docker-compose up -d --build

# Database
# Restore from backup
pg_restore -h db.xxx.supabase.co \
  -U postgres \
  -d postgres \
  backup_YYYYMMDD.dump
```

---

## 📞 Support & Maintenance

### Regular Maintenance Tasks

**Daily:**
- Monitor error logs
- Check uptime status
- Review API usage

**Weekly:**
- Review performance metrics
- Check backup status
- Update dependencies

**Monthly:**
- Security audit
- Cost review
- Capacity planning
- Update documentation

### Logging Strategy

```typescript
// lib/logger.ts
import pino from 'pino'

export const logger = pino({
  level: process.env.LOG_LEVEL || 'info',
  transport: {
    target: 'pino-pretty',
    options: {
      colorize: true,
    },
  },
})

// Usage
logger.info({ userId, action: 'qa_request' }, 'User asked question')
logger.error({ error, userId }, 'Failed to generate answer')
```

---

## ✅ Post-Deployment Checklist

- [ ] All services running
- [ ] Health checks passing
- [ ] SSL certificates valid
- [ ] DNS configured correctly
- [ ] Monitoring active
- [ ] Backups configured
- [ ] Documentation updated
- [ ] Team notified
- [ ] User testing completed
- [ ] Performance benchmarks met

---

## 📚 Additional Resources

- [Next.js Deployment Docs](https://nextjs.org/docs/deployment)
- [Vercel Production Checklist](https://vercel.com/docs/production-checklist)
- [Supabase Production Guide](https://supabase.com/docs/guides/platform/going-into-prod)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)

---

**Questions?** Contact the infrastructure team or file an issue on GitHub.

*Last updated: January 2026*
