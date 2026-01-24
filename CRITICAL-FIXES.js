// ================================================================
// CRITICAL FIXES FOR INDEX.HTML
// Add these functions to make your app search all 1,242 rows!
// ================================================================

// CONFIGURATION
const SUPABASE_URL = 'https://iqfglrwjemogoycbzltt.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTM4ODMsImV4cCI6MjA4NDEyOTg4M30.DTREv3efs86_HzESyWm-7480ImfEVgC6T-xBdS6A2F8';
const supabaseClient = supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

// GLOBAL VARIABLES
let searchableTables = []; // Will load from search_config
let isPaused = false;

// ================================================================
// FIX #1: LOAD SEARCH CONFIG (ADD THIS FUNCTION)
// This loads all 8 tables from your search_config
// ================================================================
async function loadSearchConfig() {
    try {
        console.log('🔄 Loading search configuration...');
        
        const { data, error } = await supabaseClient
            .from('search_config')
            .select('*')
            .eq('enabled', true)
            .order('priority');
        
        if (error) throw error;
        
        if (data && data.length > 0) {
            searchableTables = data.map(item => item.table_name);
            console.log('✅ Loaded searchable tables:', searchableTables);
            console.log(`✅ Will search ${searchableTables.length} tables with 1,242+ rows!`);
            
            // Show success message to user
            const statusDiv = document.getElementById('searchStatus');
            if (statusDiv) {
                statusDiv.innerHTML = `
                    <div class="bg-green-50 border-2 border-green-500 rounded-lg p-3 text-right">
                        <p class="text-green-800 font-bold">✅ מערכת חיפוש מוכנה!</p>
                        <p class="text-green-600 text-sm">נתונים מ-${searchableTables.length} טבלאות (1,242+ שורות)</p>
                    </div>
                `;
            }
        } else {
            console.warn('⚠️ No search config found, using defaults');
            // Fallback to default tables
            searchableTables = [
                'acupuncture_point_warnings',
                'acupuncture_points',
                'dr_roni_acupuncture_points',
                'v_symptom_acupoints',
                'zangfu_syndromes',
                'yin_yang_symptoms',
                'tcm_body_images'
            ];
        }
        
        return searchableTables;
        
    } catch (error) {
        console.error('❌ Error loading search config:', error);
        alert('שגיאה בטעינת הגדרות חיפוש. בדוק חיבור לאינטרנט.');
        return [];
    }
}

// ================================================================
// FIX #2: DYNAMIC MULTI-TABLE SEARCH (REPLACE EXISTING FUNCTION)
// This searches ALL tables from search_config
// ================================================================
async function searchMultipleQueries(queries) {
    if (!queries || queries.length === 0) {
        alert('אנא הזן לפחות שאילתה אחת');
        return null;
    }
    
    // Make sure search config is loaded
    if (searchableTables.length === 0) {
        await loadSearchConfig();
    }
    
    console.log(`🔍 Searching ${queries.length} queries across ${searchableTables.length} tables...`);
    
    const allResults = [];
    const searchedTables = new Set();
    
    try {
        // Search each query across ALL tables
        for (const query of queries) {
            if (!query || query.trim() === '') continue;
            
            console.log(`🔍 Query: "${query}"`);
            
            // Search each table
            for (const tableName of searchableTables) {
                try {
                    // Get table columns dynamically
                    const { data: sampleData, error: sampleError } = await supabaseClient
                        .from(tableName)
                        .select('*')
                        .limit(1);
                    
                    if (sampleError || !sampleData || sampleData.length === 0) {
                        console.log(`⚠️ Skipping empty table: ${tableName}`);
                        continue;
                    }
                    
                    // Get text columns
                    const columns = Object.keys(sampleData[0]);
                    const textColumns = columns.filter(col => {
                        const value = sampleData[0][col];
                        return typeof value === 'string';
                    });
                    
                    if (textColumns.length === 0) {
                        console.log(`⚠️ No text columns in: ${tableName}`);
                        continue;
                    }
                    
                    // Build search query
                    const orConditions = textColumns.map(col => 
                        `${col}.ilike.%${query}%`
                    ).join(',');
                    
                    // Execute search
                    const { data: results, error } = await supabaseClient
                        .from(tableName)
                        .select('*')
                        .or(orConditions)
                        .limit(10);
                    
                    if (error) {
                        console.error(`❌ Error searching ${tableName}:`, error);
                        continue;
                    }
                    
                    if (results && results.length > 0) {
                        console.log(`✅ Found ${results.length} results in ${tableName}`);
                        
                        // Tag results with source table
                        results.forEach(result => {
                            result._source_table = tableName;
                            result._query = query;
                        });
                        
                        allResults.push(...results);
                        searchedTables.add(tableName);
                    }
                    
                } catch (tableError) {
                    console.error(`❌ Error with table ${tableName}:`, tableError);
                    continue;
                }
            }
        }
        
        console.log(`✅ Search complete!`);
        console.log(`📊 Results: ${allResults.length} from ${searchedTables.size} tables`);
        console.log(`📋 Tables searched: ${Array.from(searchedTables).join(', ')}`);
        
        // Deduplicate by ID
        const uniqueResults = [];
        const seenIds = new Set();
        
        for (const result of allResults) {
            const uniqueKey = `${result._source_table}_${result.id}`;
            if (!seenIds.has(uniqueKey)) {
                seenIds.add(uniqueKey);
                uniqueResults.push(result);
            }
        }
        
        console.log(`✅ Final results after deduplication: ${uniqueResults.length}`);
        
        return {
            results: uniqueResults,
            tablesSearched: Array.from(searchedTables),
            queriesProcessed: queries.filter(q => q && q.trim() !== '')
        };
        
    } catch (error) {
        console.error('❌ Search error:', error);
        throw error;
    }
}

// ================================================================
// FIX #3: BODY PARTS DISPLAY (YOUR BOOM FEATURE!)
// This shows body diagrams WITH acupuncture points
// ================================================================
async function displayBodyPartsWithPoints(searchResults) {
    console.log('🎯 Displaying body parts with acupuncture points...');
    
    const bodyPartsDiv = document.getElementById('bodyPartsDisplay');
    if (!bodyPartsDiv) {
        console.error('❌ Body parts display div not found!');
        return;
    }
    
    try {
        // Get all body images
        const { data: images, error: imgError } = await supabaseClient
            .from('tcm_body_images')
            .select('*');
        
        if (imgError) throw imgError;
        
        if (!images || images.length === 0) {
            bodyPartsDiv.innerHTML = '<p class="text-gray-500 text-center">אין תמונות זמינות</p>';
            return;
        }
        
        // Extract acupoint codes from search results
        const acupointCodes = new Set();
        searchResults.forEach(result => {
            if (result.point_code) acupointCodes.add(result.point_code);
            if (result.point_number) acupointCodes.add(result.point_number);
        });
        
        // Get details for these acupoints from all relevant tables
        const acupointDetails = [];
        
        for (const code of acupointCodes) {
            // Search dr_roni_acupuncture_points
            const { data: roniData } = await supabaseClient
                .from('dr_roni_acupuncture_points')
                .select('*')
                .ilike('point_code', `%${code}%`)
                .limit(1);
            
            if (roniData && roniData.length > 0) {
                acupointDetails.push({
                    code: code,
                    name: roniData[0].english_name || roniData[0].chinese_name,
                    description: roniData[0].description,
                    source: 'Dr. Roni'
                });
            }
            
            // Search acupuncture_point_warnings
            const { data: warningData } = await supabaseClient
                .from('acupuncture_point_warnings')
                .select('*')
                .ilike('point_number', `%${code}%`)
                .limit(1);
            
            if (warningData && warningData.length > 0) {
                acupointDetails.push({
                    code: code,
                    name: warningData[0].point_number,
                    warning: warningData[0].warning_level,
                    explanation: warningData[0].explanation,
                    source: 'Safety Warning'
                });
            }
        }
        
        // Display images with points
        let html = '<div class="space-y-4">';
        
        // Show relevant images
        images.slice(0, 3).forEach(image => {
            html += `
                <div class="border-2 border-gray-300 rounded-lg p-4 bg-white">
                    <h4 class="font-bold text-blue-800 text-right mb-2">📍 ${image.title || image.filename}</h4>
                    <div class="bg-gray-100 rounded-lg p-2 mb-2">
                        <p class="text-sm text-gray-600 text-right">${image.description || 'תמונה אנטומית'}</p>
                    </div>
                    <div class="text-xs text-gray-500 text-right">
                        מזהה: ${image.id}
                    </div>
                </div>
            `;
        });
        
        // Show acupoint details
        if (acupointDetails.length > 0) {
            html += `
                <div class="border-2 border-green-500 rounded-lg p-4 bg-green-50">
                    <h4 class="font-bold text-green-800 text-right mb-3">✅ נקודות דיקור רלוונטיות:</h4>
            `;
            
            acupointDetails.forEach(point => {
                const warningBadge = point.warning ? 
                    `<span class="bg-red-500 text-white px-2 py-1 rounded text-xs">${point.warning}</span>` : '';
                
                html += `
                    <div class="border-b border-green-200 pb-2 mb-2 text-right">
                        <div class="flex justify-between items-start">
                            <span class="font-bold text-blue-700">${point.code}</span>
                            ${warningBadge}
                        </div>
                        <p class="text-sm text-gray-700 mt-1">${point.name || ''}</p>
                        ${point.description ? 
                            `<p class="text-xs text-gray-600 mt-1">${point.description.substring(0, 150)}...</p>` : ''}
                        ${point.explanation ? 
                            `<p class="text-xs text-red-600 mt-1">⚠️ ${point.explanation.substring(0, 100)}...</p>` : ''}
                        <p class="text-xs text-gray-400 mt-1">מקור: ${point.source}</p>
                    </div>
                `;
            });
            
            html += '</div>';
        }
        
        html += '</div>';
        
        bodyPartsDiv.innerHTML = html;
        console.log('✅ Body parts displayed with acupuncture points!');
        
    } catch (error) {
        console.error('❌ Error displaying body parts:', error);
        bodyPartsDiv.innerHTML = '<p class="text-red-500 text-center">שגיאה בהצגת חלקי גוף</p>';
    }
}

// ================================================================
// FIX #4: ENHANCED MULTI-QUERY EXECUTION
// This runs the search and displays everything
// ================================================================
async function performMultiQuery() {
    console.log('🚀 Starting multi-query search...');
    
    // Get queries from input boxes
    const query1 = document.getElementById('query1')?.value || '';
    const query2 = document.getElementById('query2')?.value || '';
    const query3 = document.getElementById('query3')?.value || '';
    const freeQuery = document.getElementById('freeQuery')?.value || '';
    
    const queries = [query1, query2, query3, freeQuery].filter(q => q && q.trim() !== '');
    
    if (queries.length === 0) {
        alert('אנא הזן לפחות שאילתה אחת');
        return;
    }
    
    // Show loading
    const resultsDiv = document.getElementById('searchResults');
    if (resultsDiv) {
        resultsDiv.innerHTML = `
            <div class="text-center p-8">
                <div class="animate-spin text-4xl mb-4">🔄</div>
                <p class="text-blue-600 font-bold">מחפש ב-8 טבלאות...</p>
                <p class="text-gray-500 text-sm">1,242+ שורות של מידע TCM</p>
            </div>
        `;
    }
    
    try {
        // Execute search
        const searchData = await searchMultipleQueries(queries);
        
        if (!searchData || searchData.results.length === 0) {
            // NO RESULTS - Show fallback
            if (resultsDiv) {
                resultsDiv.innerHTML = `
                    <div class="bg-yellow-50 border-2 border-yellow-500 rounded-lg p-6 text-right">
                        <h3 class="font-bold text-yellow-800 text-xl mb-3">⚠️ לא נמצאו תוצאות</h3>
                        <p class="text-yellow-700 mb-4">לא נמצאו תוצאות במאגר הנתונים שלנו (1,242 שורות).</p>
                        <p class="text-yellow-600 text-sm mb-4">
                            חיפשנו ב: ${searchData.tablesSearched.join(', ')}
                        </p>
                        <div class="bg-yellow-100 p-4 rounded-lg">
                            <p class="font-bold text-yellow-900 mb-2">💡 הצעות:</p>
                            <ul class="list-disc list-inside text-yellow-800 text-sm space-y-1">
                                <li>נסה מילות חיפוש שונות</li>
                                <li>בדוק איות</li>
                                <li>השתמש במונחים כלליים יותר</li>
                            </ul>
                        </div>
                    </div>
                `;
            }
            return;
        }
        
        // RESULTS FOUND - Display everything
        console.log(`✅ Displaying ${searchData.results.length} results`);
        
        // Display text results
        let html = `
            <div class="bg-green-50 border-2 border-green-500 rounded-lg p-4 mb-4 text-right">
                <h3 class="font-bold text-green-800 text-xl mb-2">✅ נמצאו ${searchData.results.length} תוצאות!</h3>
                <p class="text-green-600 text-sm">חיפוש ב: ${searchData.tablesSearched.join(', ')}</p>
            </div>
        `;
        
        // Group results by source table
        const resultsByTable = {};
        searchData.results.forEach(result => {
            const table = result._source_table || 'unknown';
            if (!resultsByTable[table]) {
                resultsByTable[table] = [];
            }
            resultsByTable[table].push(result);
        });
        
        // Display each table's results
        for (const [tableName, results] of Object.entries(resultsByTable)) {
            html += `
                <div class="border-2 border-blue-300 rounded-lg p-4 mb-4 bg-blue-50">
                    <h4 class="font-bold text-blue-800 text-right mb-3">📋 ${tableName} (${results.length} תוצאות)</h4>
            `;
            
            results.slice(0, 5).forEach((result, index) => {
                // Extract key fields
                const title = result.point_code || result.point_number || result.name_he || result.name_en || `תוצאה ${index + 1}`;
                const description = result.description || result.explanation || result.indications_he || result.symptoms_he || '';
                const warning = result.warning_level || '';
                
                html += `
                    <div class="border-b border-blue-200 pb-3 mb-3 text-right">
                        <div class="flex justify-between items-start mb-2">
                            <span class="font-bold text-blue-900">${title}</span>
                            ${warning ? `<span class="bg-red-500 text-white px-2 py-1 rounded text-xs">${warning}</span>` : ''}
                        </div>
                        ${description ? `<p class="text-sm text-gray-700">${description.substring(0, 200)}...</p>` : ''}
                        <p class="text-xs text-gray-400 mt-2">שאילתה: ${result._query}</p>
                    </div>
                `;
            });
            
            if (results.length > 5) {
                html += `<p class="text-sm text-blue-600 text-right">ועוד ${results.length - 5} תוצאות...</p>`;
            }
            
            html += '</div>';
        }
        
        if (resultsDiv) {
            resultsDiv.innerHTML = html;
        }
        
        // Display body parts with acupuncture points (YOUR BOOM!)
        await displayBodyPartsWithPoints(searchData.results);
        
        console.log('✅ Multi-query search complete!');
        
    } catch (error) {
        console.error('❌ Search error:', error);
        if (resultsDiv) {
            resultsDiv.innerHTML = `
                <div class="bg-red-50 border-2 border-red-500 rounded-lg p-4 text-right">
                    <h3 class="font-bold text-red-800 text-xl mb-2">❌ שגיאה בחיפוש</h3>
                    <p class="text-red-600">${error.message}</p>
                </div>
            `;
        }
    }
}

// ================================================================
// INITIALIZATION - CALL THIS ON PAGE LOAD
// ================================================================
async function initializeApp() {
    console.log('🚀 Initializing TCM Clinical Assistant...');
    
    // Load search configuration
    await loadSearchConfig();
    
    // Set up event listeners
    const runButton = document.getElementById('runSearchButton');
    if (runButton) {
        runButton.addEventListener('click', performMultiQuery);
        console.log('✅ Run button connected');
    }
    
    // Set up voice activation if available
    setupVoiceActivation();
    
    console.log('✅ App initialized successfully!');
}

// Call initialization when page loads
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initializeApp);
} else {
    initializeApp();
}

// ================================================================
// END OF CRITICAL FIXES
// ================================================================
