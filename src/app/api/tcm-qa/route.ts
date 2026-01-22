import { NextRequest, NextResponse } from 'next/server';
import Anthropic from '@anthropic-ai/sdk';
import { createClient } from '@supabase/supabase-js';

const anthropic = new Anthropic({
  apiKey: process.env.ANTHROPIC_API_KEY!,
});

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
);

export async function POST(request: NextRequest) {
  try {
    const { question } = await request.json();

    if (!question) {
      return NextResponse.json(
        { error: 'שאלה חסרה' },
        { status: 400 }
      );
    }

    const { data: syndromes } = await supabase
      .from('zangfu_syndromes')
      .select('name_he, symptoms_he')
      .limit(5);

    const { data: points } = await supabase
      .from('acupuncture_points')
      .select('point_code, name_he, functions_he')
      .limit(5);

    let context = 'מידע רלוונטי:\n\n';
    
    if (points && points.length > 0) {
      context += 'נקודות דיקור:\n';
      points.forEach(p => {
        context += `- ${p.point_code} (${p.name_he}): ${p.functions_he}\n`;
      });
      context += '\n';
    }

    if (syndromes && syndromes.length > 0) {
      context += 'תסמונות:\n';
      syndromes.forEach(s => {
        context += `- ${s.name_he}: ${s.symptoms_he?.substring(0, 200)}...\n`;
      });
    }

    const message = await anthropic.messages.create({
      model: 'claude-sonnet-4-20250514',
      max_tokens: 1024,
      messages: [
        {
          role: 'user',
          content: `אתה עוזר קליני לרפואה סינית מסורתית. ענה בעברית בלבד.

${context}

שאלה: ${question}

אנא ענה בצורה ברורה ומקצועית בעברית.`
        }
      ]
    });

    const answer = message.content[0].type === 'text' 
      ? message.content[0].text 
      : 'לא הצלחתי לקבל תשובה';

    return NextResponse.json({ answer });

  } catch (error) {
    console.error('Error:', error);
    return NextResponse.json(
      { error: 'שגיאה בעיבוד השאלה' },
      { status: 500 }
    );
  }
}