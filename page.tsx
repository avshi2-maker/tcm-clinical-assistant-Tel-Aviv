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
