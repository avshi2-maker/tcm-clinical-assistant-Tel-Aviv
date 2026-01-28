# TCM App Setup Script
# Run this in PowerShell from your project folder

Write-Host "🌿 Creating TCM Clinical Assistant App Files..." -ForegroundColor Green

# Create directories
Write-Host "📁 Creating directories..."
New-Item -ItemType Directory -Force -Path "src\app\api\tcm-qa" | Out-Null

# Create layout.tsx
Write-Host "📄 Creating layout.tsx..."
@'
import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "TCM Clinical Assistant",
  description: "Traditional Chinese Medicine Knowledge Base with AI Assistant",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="he" dir="rtl">
      <body className={inter.className}>{children}</body>
    </html>
  );
}
'@ | Out-File -FilePath "src\app\layout.tsx" -Encoding UTF8

# Create page.tsx
Write-Host "📄 Creating page.tsx..."
@'
'use client';

import { useState } from 'react';

export default function Home() {
  const [question, setQuestion] = useState('');
  const [answer, setAnswer] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setAnswer('');

    try {
      const response = await fetch('/api/tcm-qa', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ question }),
      });

      const data = await response.json();
      setAnswer(data.answer || data.error);
    } catch (error) {
      setAnswer('שגיאה בחיבור לשרת');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="min-h-screen bg-gradient-to-br from-green-50 to-blue-50 p-8">
      <div className="max-w-4xl mx-auto">
        <h1 className="text-4xl font-bold text-center mb-8 text-green-800">
          🌿 עוזר קליני לרפואה סינית
        </h1>

        <div className="bg-white rounded-lg shadow-xl p-8 mb-8">
          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label htmlFor="question" className="block text-lg font-medium text-gray-700 mb-2">
                שאל שאלה בעברית:
              </label>
              <textarea
                id="question"
                value={question}
                onChange={(e) => setQuestion(e.target.value)}
                placeholder="לדוגמה: מהן הנקודות לטיפול בכאב ראש?"
                className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-green-500 focus:border-transparent resize-none"
                rows={4}
                disabled={loading}
              />
            </div>

            <button
              type="submit"
              disabled={loading || !question.trim()}
              className="w-full bg-green-600 hover:bg-green-700 disabled:bg-gray-400 text-white font-semibold py-3 px-6 rounded-lg transition-colors"
            >
              {loading ? 'מחפש תשובה...' : 'שלח שאלה'}
            </button>
          </form>
        </div>

        {answer && (
          <div className="bg-white rounded-lg shadow-xl p-8">
            <h2 className="text-2xl font-bold text-green-800 mb-4">תשובה:</h2>
            <div className="prose prose-lg max-w-none text-gray-700 whitespace-pre-wrap">
              {answer}
            </div>
          </div>
        )}

        {loading && (
          <div className="bg-white rounded-lg shadow-xl p-8">
            <div className="flex items-center justify-center space-x-2 space-x-reverse">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-green-600"></div>
              <span className="text-lg text-gray-600">מעבד את השאלה...</span>
            </div>
          </div>
        )}
      </div>
    </main>
  );
}
'@ | Out-File -FilePath "src\app\page.tsx" -Encoding UTF8

# Create globals.css
Write-Host "📄 Creating globals.css..."
@'
@tailwind base;
@tailwind components;
@tailwind utilities;

:root {
  --foreground-rgb: 0, 0, 0;
  --background-start-rgb: 214, 219, 220;
  --background-end-rgb: 255, 255, 255;
}

body {
  color: rgb(var(--foreground-rgb));
  background: linear-gradient(
      to bottom,
      transparent,
      rgb(var(--background-end-rgb))
    )
    rgb(var(--background-start-rgb));
}

@layer utilities {
  .text-balance {
    text-wrap: balance;
  }
}
'@ | Out-File -FilePath "src\app\globals.css" -Encoding UTF8

# Create API route
Write-Host "📄 Creating API route..."
@'
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

    // Search for relevant TCM content
    const { data: syndromes, error: syndromesError } = await supabase
      .from('zangfu_syndromes')
      .select('name_he, symptoms_he')
      .limit(5);

    const { data: points, error: pointsError } = await supabase
      .from('acupuncture_points')
      .select('point_code, name_he, functions_he')
      .limit(5);

    if (syndromesError || pointsError) {
      console.error('Database error:', syndromesError || pointsError);
    }

    // Build context for Claude
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

    // Ask Claude
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
'@ | Out-File -FilePath "src\app\api\tcm-qa\route.ts" -Encoding UTF8

Write-Host ""
Write-Host "✅ All files created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Stop the dev server (Ctrl+C)" -ForegroundColor White
Write-Host "2. Run: npm run dev" -ForegroundColor White
Write-Host "3. Open: http://localhost:3000" -ForegroundColor White
Write-Host ""
