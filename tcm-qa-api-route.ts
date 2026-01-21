// app/api/tcm-qa/route.ts
/**
 * TCM Q&A API Route with Hebrew Support
 * Provides intelligent answers using Claude API with Supabase RAG
 */

import { createClient } from '@supabase/supabase-js';
import Anthropic from '@anthropic-ai/sdk';
import { NextRequest, NextResponse } from 'next/server';

// Initialize clients
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY!,
});

// Types
interface SearchResult {
  id: string;
  point_code?: string;
  name_he: string;
  name_en?: string;
  location_he?: string;
  functions_he?: string;
  indications_he?: string;
  symptoms_he?: string;
  treatment_he?: string;
  similarity: number;
}

interface QARequest {
  question: string;
  context?: 'points' | 'syndromes' | 'both';
  language?: 'he' | 'en';
  maxResults?: number;
}

/**
 * Generate embedding using Claude's built-in capabilities
 * For production, consider using a dedicated embedding model
 */
async function generateEmbedding(text: string): Promise<number[]> {
  // Using a simple embedding model (replace with your preferred model)
  // For Hebrew support, consider using multilingual models like:
  // - sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2
  // - intfloat/multilingual-e5-large
  
  // This is a placeholder - implement actual embedding generation
  // You can use OpenAI embeddings, Cohere, or self-hosted models
  const response = await fetch('https://api.openai.com/v1/embeddings', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      model: 'text-embedding-3-small',
      input: text,
    }),
  });
  
  const data = await response.json();
  return data.data[0].embedding;
}

/**
 * Search Supabase for relevant TCM content
 */
async function searchTCMContent(
  query: string,
  context: 'points' | 'syndromes' | 'both' = 'both',
  maxResults: number = 5
): Promise<{ points: SearchResult[]; syndromes: SearchResult[] }> {
  const results = { points: [], syndromes: [] };
  
  try {
    // Generate embedding for the query
    const embedding = await generateEmbedding(query);
    
    // Search acupuncture points
    if (context === 'points' || context === 'both') {
      const { data: pointsData, error: pointsError } = await supabase.rpc(
        'match_acupuncture_points',
        {
          query_embedding: embedding,
          match_threshold: 0.7,
          match_count: maxResults,
        }
      );
      
      if (!pointsError && pointsData) {
        results.points = pointsData;
      }
    }
    
    // Search syndromes
    if (context === 'syndromes' || context === 'both') {
      const { data: syndromesData, error: syndromesError } = await supabase.rpc(
        'match_syndromes',
        {
          query_embedding: embedding,
          match_threshold: 0.7,
          match_count: maxResults,
        }
      );
      
      if (!syndromesError && syndromesData) {
        results.syndromes = syndromesData;
      }
    }
    
    return results;
  } catch (error) {
    console.error('Search error:', error);
    return results;
  }
}

/**
 * Generate answer using Claude with RAG context
 */
async function generateAnswer(
  question: string,
  searchResults: { points: SearchResult[]; syndromes: SearchResult[] },
  language: 'he' | 'en' = 'he'
): Promise<string> {
  // Build context from search results
  let context = '';
  
  if (searchResults.points.length > 0) {
    context += '\n## נקודות דיקור רלוונטיות:\n\n';
    searchResults.points.forEach((point, idx) => {
      context += `### ${idx + 1}. ${point.point_code} - ${point.name_he}\n`;
      if (point.location_he) context += `**מיקום:** ${point.location_he}\n`;
      if (point.functions_he) context += `**תפקידים:** ${point.functions_he}\n`;
      if (point.indications_he) context += `**אינדיקציות:** ${point.indications_he}\n`;
      context += '\n';
    });
  }
  
  if (searchResults.syndromes.length > 0) {
    context += '\n## תסמונות צאנג-פו רלוונטיות:\n\n';
    searchResults.syndromes.forEach((syndrome, idx) => {
      context += `### ${idx + 1}. ${syndrome.name_he}\n`;
      if (syndrome.symptoms_he) context += `**תסמינים:** ${syndrome.symptoms_he}\n`;
      if (syndrome.treatment_he) context += `**טיפול:** ${syndrome.treatment_he}\n`;
      context += '\n';
    });
  }
  
  // System prompt for TCM expertise
  const systemPrompt = language === 'he' 
    ? `אתה מומחה לרפואה סינית מסורתית (TCM) עם ידע עמוק בדיקור סיני ובאבחון תסמונות צאנג-פו.
      
תפקידך:
1. לענות על שאלות בתחום הרפואה הסינית בעברית ברורה ומקצועית
2. להסתמך על המידע שסופק לך מהמסמכים הרפואיים
3. לספק תשובות מדויקות, מפורטות ומעשיות
4. לציין את מקורות המידע (נקודות דיקור או תסמונות) שממנן שאבת את המידע
5. להזהיר כשיש צורך בהתייעצות עם מטפל מוסמך

חשוב:
- תמיד כתוב בעברית תקנית
- השתמש במינוח מקצועי אך מובן
- הדגש מידע חשוב
- אם אין מספיק מידע, ציין זאת בבירור

להלן המידע הרלוונטי מהמסמכים:`
    : `You are an expert in Traditional Chinese Medicine (TCM) with deep knowledge of acupuncture and Zang-Fu syndrome diagnosis.

Your role:
1. Answer TCM-related questions with clear, professional information
2. Rely on the provided medical document information
3. Provide accurate, detailed, and practical answers
4. Cite sources (acupuncture points or syndromes) where information came from
5. Warn when consultation with a licensed practitioner is needed

Important:
- Always write in clear, professional English
- Use proper medical terminology
- Emphasize important information
- If insufficient information is available, state this clearly

Here is the relevant information from the documents:`;
  
  const userPrompt = language === 'he'
    ? `${context}

---

**שאלת המטופל:** ${question}

אנא ספק תשובה מקצועית ומפורטת המבוססת על המידע שסופק למעלה. אם המידע לא מספיק כדי לענות באופן מלא, ציין זאת ומה עוד צריך לברר.`
    : `${context}

---

**Patient Question:** ${question}

Please provide a professional and detailed answer based on the information provided above. If the information is insufficient to answer fully, state this and what else needs to be clarified.`;
  
  try {
    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 2000,
      temperature: 0.3, // Lower temperature for more consistent medical advice
      system: systemPrompt,
      messages: [
        {
          role: 'user',
          content: userPrompt,
        },
      ],
    });
    
    const textContent = message.content.find((block) => block.type === 'text');
    return textContent ? textContent.text : 'לא ניתן להפיק תשובה';
    
  } catch (error) {
    console.error('Claude API error:', error);
    throw new Error('Failed to generate answer');
  }
}

/**
 * Main API handler
 */
export async function POST(request: NextRequest) {
  try {
    const body: QARequest = await request.json();
    const { question, context = 'both', language = 'he', maxResults = 5 } = body;
    
    if (!question || question.trim().length === 0) {
      return NextResponse.json(
        { error: 'Question is required' },
        { status: 400 }
      );
    }
    
    // Step 1: Search for relevant content
    console.log('Searching for relevant TCM content...');
    const searchResults = await searchTCMContent(question, context, maxResults);
    
    // Step 2: Generate answer with Claude
    console.log('Generating answer with Claude...');
    const answer = await generateAnswer(question, searchResults, language);
    
    // Step 3: Return response
    return NextResponse.json({
      question,
      answer,
      sources: {
        points: searchResults.points.length,
        syndromes: searchResults.syndromes.length,
      },
      metadata: {
        pointResults: searchResults.points.map((p) => ({
          code: p.point_code,
          name: p.name_he,
          similarity: p.similarity,
        })),
        syndromeResults: searchResults.syndromes.map((s) => ({
          name: s.name_he,
          similarity: s.similarity,
        })),
      },
    });
    
  } catch (error) {
    console.error('API error:', error);
    return NextResponse.json(
      { error: 'Internal server error', details: error.message },
      { status: 500 }
    );
  }
}

/**
 * Health check endpoint
 */
export async function GET() {
  return NextResponse.json({
    status: 'ok',
    service: 'TCM Q&A API',
    language: 'Hebrew',
    features: ['acupuncture_points', 'zangfu_syndromes', 'semantic_search'],
  });
}
