// components/DeepThinkingModule.tsx
/**
 * Deep Thinking Module - Hebrew TCM Q&A Interface
 * Professional therapist interface for TCM knowledge base
 */

'use client';

import React, { useState, useRef, useEffect } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Textarea } from '@/components/ui/textarea';
import { Badge } from '@/components/ui/badge';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Alert, AlertDescription } from '@/components/ui/alert';
import {
  Brain,
  Send,
  Loader2,
  BookOpen,
  Stethoscope,
  Sparkles,
  Copy,
  Download,
  RefreshCw,
} from 'lucide-react';

interface Message {
  id: string;
  role: 'user' | 'assistant';
  content: string;
  sources?: {
    points: number;
    syndromes: number;
  };
  metadata?: {
    pointResults?: Array<{ code: string; name: string; similarity: number }>;
    syndromeResults?: Array<{ name: string; similarity: number }>;
  };
  timestamp: Date;
}

interface DeepThinkingModuleProps {
  className?: string;
}

export function DeepThinkingModule({ className = '' }: DeepThinkingModuleProps) {
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [context, setContext] = useState<'both' | 'points' | 'syndromes'>('both');
  const messagesEndRef = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  // Example questions for quick start
  const exampleQuestions = [
    'מהן נקודות הדיקור הטובות ביותר לטיפול בכאבי ראש?',
    'תאר לי את תסמונת חסר צ\'י של הטחול',
    'איך מטפלים בנדודי שינה בדיקור סיני?',
    'מהן האינדיקציות של הנקודה ST-36?',
    'הסבר על תסמונת חסר דם של הכבד',
  ];

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || isLoading) return;

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
      timestamp: new Date(),
    };

    setMessages((prev) => [...prev, userMessage]);
    setInput('');
    setIsLoading(true);

    try {
      const response = await fetch('/api/tcm-qa', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          question: input,
          context,
          language: 'he',
          maxResults: 5,
        }),
      });

      if (!response.ok) {
        throw new Error('Failed to get response');
      }

      const data = await response.json();

      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: data.answer,
        sources: data.sources,
        metadata: data.metadata,
        timestamp: new Date(),
      };

      setMessages((prev) => [...prev, assistantMessage]);
    } catch (error) {
      console.error('Error:', error);
      const errorMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: 'מצטער, אירעה שגיאה בעיבוד השאלה. אנא נסה שוב.',
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, errorMessage]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleExampleClick = (question: string) => {
    setInput(question);
  };

  const copyToClipboard = (text: string) => {
    navigator.clipboard.writeText(text);
  };

  const exportConversation = () => {
    const conversationText = messages
      .map((msg) => {
        const role = msg.role === 'user' ? 'שאלה' : 'תשובה';
        return `${role} [${msg.timestamp.toLocaleString('he-IL')}]:\n${msg.content}\n`;
      })
      .join('\n---\n\n');

    const blob = new Blob([conversationText], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `tcm-consultation-${new Date().toISOString().split('T')[0]}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const clearConversation = () => {
    if (confirm('האם אתה בטוח שברצונך למחוק את השיחה?')) {
      setMessages([]);
    }
  };

  return (
    <div className={`max-w-5xl mx-auto ${className}`} dir="rtl">
      <Card className="shadow-xl border-2 border-blue-100">
        <CardHeader className="bg-gradient-to-r from-blue-50 to-indigo-50 border-b">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="p-2 bg-blue-500 rounded-lg">
                <Brain className="w-6 h-6 text-white" />
              </div>
              <div>
                <CardTitle className="text-2xl font-bold text-blue-900">
                  מודול חשיבה עמוקה
                </CardTitle>
                <p className="text-sm text-blue-600 mt-1">
                  ייעוץ מקצועי ברפואה סינית מסורתית
                </p>
              </div>
            </div>
            <div className="flex gap-2">
              <Button
                variant="outline"
                size="sm"
                onClick={exportConversation}
                disabled={messages.length === 0}
              >
                <Download className="w-4 h-4 ml-2" />
                ייצוא
              </Button>
              <Button
                variant="outline"
                size="sm"
                onClick={clearConversation}
                disabled={messages.length === 0}
              >
                <RefreshCw className="w-4 h-4 ml-2" />
                נקה
              </Button>
            </div>
          </div>
        </CardHeader>

        <CardContent className="p-6">
          {/* Context Selection */}
          <div className="mb-6">
            <label className="text-sm font-medium text-gray-700 mb-2 block">
              תחום חיפוש:
            </label>
            <Tabs value={context} onValueChange={(v) => setContext(v as any)}>
              <TabsList className="grid w-full grid-cols-3">
                <TabsTrigger value="both" className="flex items-center gap-2">
                  <Sparkles className="w-4 h-4" />
                  הכל
                </TabsTrigger>
                <TabsTrigger value="points" className="flex items-center gap-2">
                  <Stethoscope className="w-4 h-4" />
                  נקודות דיקור
                </TabsTrigger>
                <TabsTrigger value="syndromes" className="flex items-center gap-2">
                  <BookOpen className="w-4 h-4" />
                  תסמונות
                </TabsTrigger>
              </TabsList>
            </Tabs>
          </div>

          {/* Example Questions */}
          {messages.length === 0 && (
            <div className="mb-6 p-4 bg-blue-50 rounded-lg border border-blue-200">
              <h3 className="text-sm font-semibold text-blue-900 mb-3 flex items-center gap-2">
                <Sparkles className="w-4 h-4" />
                שאלות לדוגמה:
              </h3>
              <div className="flex flex-wrap gap-2">
                {exampleQuestions.map((question, idx) => (
                  <Button
                    key={idx}
                    variant="outline"
                    size="sm"
                    onClick={() => handleExampleClick(question)}
                    className="text-xs hover:bg-blue-100"
                  >
                    {question}
                  </Button>
                ))}
              </div>
            </div>
          )}

          {/* Messages */}
          <div className="space-y-4 mb-6 max-h-[500px] overflow-y-auto">
            {messages.map((message) => (
              <div
                key={message.id}
                className={`flex ${message.role === 'user' ? 'justify-start' : 'justify-end'}`}
              >
                <div
                  className={`max-w-[80%] rounded-lg p-4 ${
                    message.role === 'user'
                      ? 'bg-blue-100 border border-blue-200'
                      : 'bg-gradient-to-br from-indigo-50 to-purple-50 border border-indigo-200'
                  }`}
                >
                  <div className="flex items-start justify-between mb-2">
                    <span className="text-xs font-semibold text-gray-600">
                      {message.role === 'user' ? 'שאלה' : 'תשובה מומחה'}
                    </span>
                    {message.role === 'assistant' && (
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => copyToClipboard(message.content)}
                        className="h-6 w-6 p-0"
                      >
                        <Copy className="w-3 h-3" />
                      </Button>
                    )}
                  </div>

                  <div className="prose prose-sm max-w-none text-gray-800 leading-relaxed">
                    {message.content}
                  </div>

                  {message.sources && (
                    <div className="flex gap-2 mt-3 pt-3 border-t border-gray-200">
                      {message.sources.points > 0 && (
                        <Badge variant="secondary" className="text-xs">
                          <Stethoscope className="w-3 h-3 ml-1" />
                          {message.sources.points} נקודות
                        </Badge>
                      )}
                      {message.sources.syndromes > 0 && (
                        <Badge variant="secondary" className="text-xs">
                          <BookOpen className="w-3 h-3 ml-1" />
                          {message.sources.syndromes} תסמונות
                        </Badge>
                      )}
                    </div>
                  )}

                  {message.metadata && (
                    <details className="mt-3 pt-3 border-t border-gray-200">
                      <summary className="text-xs text-gray-600 cursor-pointer hover:text-gray-800">
                        הצג מקורות מפורטים
                      </summary>
                      <div className="mt-2 space-y-2 text-xs">
                        {message.metadata.pointResults && message.metadata.pointResults.length > 0 && (
                          <div>
                            <div className="font-semibold text-gray-700 mb-1">נקודות דיקור:</div>
                            <ul className="list-disc list-inside space-y-1">
                              {message.metadata.pointResults.map((point, idx) => (
                                <li key={idx} className="text-gray-600">
                                  {point.code} - {point.name} ({(point.similarity * 100).toFixed(1)}%)
                                </li>
                              ))}
                            </ul>
                          </div>
                        )}
                        {message.metadata.syndromeResults && message.metadata.syndromeResults.length > 0 && (
                          <div>
                            <div className="font-semibold text-gray-700 mb-1">תסמונות:</div>
                            <ul className="list-disc list-inside space-y-1">
                              {message.metadata.syndromeResults.map((syndrome, idx) => (
                                <li key={idx} className="text-gray-600">
                                  {syndrome.name} ({(syndrome.similarity * 100).toFixed(1)}%)
                                </li>
                              ))}
                            </ul>
                          </div>
                        )}
                      </div>
                    </details>
                  )}

                  <div className="text-xs text-gray-400 mt-2">
                    {message.timestamp.toLocaleTimeString('he-IL')}
                  </div>
                </div>
              </div>
            ))}
            {isLoading && (
              <div className="flex justify-end">
                <div className="bg-gradient-to-br from-indigo-50 to-purple-50 border border-indigo-200 rounded-lg p-4">
                  <Loader2 className="w-5 h-5 animate-spin text-indigo-600" />
                </div>
              </div>
            )}
            <div ref={messagesEndRef} />
          </div>

          {/* Input Form */}
          <form onSubmit={handleSubmit} className="space-y-3">
            <div className="relative">
              <Textarea
                value={input}
                onChange={(e) => setInput(e.target.value)}
                placeholder="שאל שאלה מקצועית על נקודות דיקור, תסמונות, או טיפולים..."
                className="min-h-[100px] pr-4 text-right resize-none border-2 border-gray-200 focus:border-blue-400 rounded-lg"
                disabled={isLoading}
              />
            </div>

            <div className="flex items-center justify-between">
              <div className="text-xs text-gray-500">
                {input.length > 0 && `${input.length} תווים`}
              </div>
              <Button
                type="submit"
                disabled={!input.trim() || isLoading}
                className="bg-gradient-to-r from-blue-500 to-indigo-600 hover:from-blue-600 hover:to-indigo-700 text-white"
              >
                {isLoading ? (
                  <>
                    <Loader2 className="w-4 h-4 ml-2 animate-spin" />
                    מעבד...
                  </>
                ) : (
                  <>
                    <Send className="w-4 h-4 ml-2" />
                    שלח שאלה
                  </>
                )}
              </Button>
            </div>
          </form>

          {/* Info Alert */}
          <Alert className="mt-4 bg-amber-50 border-amber-200">
            <AlertDescription className="text-xs text-amber-800">
              💡 <strong>הערה חשובה:</strong> מודול זה מספק מידע מקצועי המבוסס על ספרות רפואה סינית מסורתית.
              התשובות אינן מהוות תחליף לייעוץ רפואי אישי. תמיד התייעץ עם מטפל מוסמך לפני יישום טיפול.
            </AlertDescription>
          </Alert>
        </CardContent>
      </Card>
    </div>
  );
}

export default DeepThinkingModule;
