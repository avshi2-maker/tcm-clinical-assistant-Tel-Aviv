// ============================================================================
// TCM CLINICAL ASSISTANT - SMART SEARCH EDGE FUNCTION
// File: 04_smart_search_edge_function.ts
// Purpose: Multi-query priority search with token management
// Deploy to: Supabase Edge Functions
// Author: Claude AI for TCM Clinic
// Date: January 2026
// ============================================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// ============================================================================
// TYPES
// ============================================================================

interface SearchRequest {
  queries: string[]        // Up to 3 queries from user
  userId?: string          // Therapist ID
  useDeepSearch?: boolean  // Allow Gemini API (costs tokens)
  maxResults?: number
}

interface SearchResult {
  assetName: string
  assetNameHebrew: string
  priority: number
  results: any[]
  tokensUsed: number
  responseMs: number
}

// ============================================================================
// MAIN HANDLER
// ============================================================================

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Parse request
    const { 
      queries, 
      userId, 
      useDeepSearch = false, 
      maxResults = 10 
    }: SearchRequest = await req.json()

    // Validate
    if (!queries || queries.length === 0) {
      throw new Error('At least one query is required')
    }

    console.log(`🔍 Search request: ${queries.join(' | ')}`)

    // Initialize Supabase
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const startTime = Date.now()

    // Get search priority order
    const combinedQuery = queries.join(' ')
    const prioritizedAssets = await getPriorityAssets(
      supabase, 
      combinedQuery, 
      useDeepSearch
    )

    console.log(`📊 Priority order:`, prioritizedAssets.map(a => a.asset_name))

    // Search each asset in priority order
    const allResults: SearchResult[] = []
    let totalTokensUsed = 0

    for (const asset of prioritizedAssets) {
      const assetStart = Date.now()

      try {
        const results = await searchAsset(
          supabase,
          asset,
          queries,
          maxResults
        )

        const responseMs = Date.now() - assetStart

        if (results.length > 0) {
          const tokensUsed = asset.requires_tokens ? 1 : 0
          totalTokensUsed += tokensUsed

          allResults.push({
            assetName: asset.asset_name,
            assetNameHebrew: asset.asset_name_hebrew,
            priority: asset.priority_level,
            results: results,
            tokensUsed: tokensUsed,
            responseMs: responseMs
          })

          console.log(`  ✅ ${asset.asset_name}: ${results.length} results (${responseMs}ms)`)

          // Stop if we have enough good results
          if (allResults.length >= 2 && allResults[0].results.length >= 5) {
            console.log(`  🎯 Sufficient results, stopping search`)
            break
          }
        }

      } catch (error) {
        console.error(`  ❌ ${asset.asset_name} error:`, error.message)
        // Continue with next asset
      }
    }

    // Deduct tokens if used
    if (totalTokensUsed > 0 && userId) {
      await deductUserTokens(supabase, userId, totalTokensUsed)
    }

    const totalTime = Date.now() - startTime

    // Response
    const response = {
      success: true,
      queries: queries,
      results: allResults,
      totalResults: allResults.reduce((sum, r) => sum + r.results.length, 0),
      tokensUsed: totalTokensUsed,
      searchTimeMs: totalTime,
      timestamp: new Date().toISOString()
    }

    return new Response(
      JSON.stringify(response),
      { 
        status: 200, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )

  } catch (error) {
    console.error('❌ Search error:', error)
    return new Response(
      JSON.stringify({ 
        success: false,
        error: error.message 
      }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      }
    )
  }
})

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

async function getPriorityAssets(
  supabase: any,
  query: string,
  allowTokens: boolean
) {
  // Check routing rules for pattern matches
  const { data: rules } = await supabase
    .from('search_routing_rules')
    .select('*')
    .eq('is_active', true)

  let priorityOverride = null

  // Find matching rule
  for (const rule of rules || []) {
    const pattern = new RegExp(rule.query_pattern, 'i')
    if (pattern.test(query)) {
      priorityOverride = rule.priority_override
      console.log(`  🎯 Matched rule: ${rule.rule_name}`)
      break
    }
  }

  // Get assets
  let assetsQuery = supabase
    .from('search_assets')
    .select('*')
    .eq('is_active', true)

  if (!allowTokens) {
    assetsQuery = assetsQuery.eq('requires_tokens', false)
  }

  const { data: assets, error } = await assetsQuery
    .order('priority_level', { ascending: true })

  if (error) throw error

  // Apply priority override if matched
  if (priorityOverride && priorityOverride.length > 0) {
    const reordered = []
    
    // Add assets in override order
    for (const priority of priorityOverride) {
      const asset = assets.find(a => a.priority_level === priority)
      if (asset) reordered.push(asset)
    }
    
    // Add remaining assets
    for (const asset of assets) {
      if (!reordered.includes(asset)) {
        reordered.push(asset)
      }
    }
    
    return reordered
  }

  return assets
}

async function searchAsset(
  supabase: any,
  asset: any,
  queries: string[],
  maxResults: number
): Promise<any[]> {
  
  const combinedQuery = queries.join(' ')

  switch (asset.search_endpoint) {
    case 'qa_knowledge_base':
      return await searchQAKnowledgeBase(supabase, combinedQuery, maxResults)
    
    case 'body_figures':
      return await searchBodyFigures(supabase, combinedQuery, maxResults)
    
    case 'tcm_hebrew_qa':
      return await searchTCMHebrewQA(supabase, combinedQuery, maxResults)
    
    default:
      console.log(`  ⚠️ No handler for: ${asset.search_endpoint}`)
      return []
  }
}

// ============================================================================
// ASSET-SPECIFIC SEARCH FUNCTIONS
// ============================================================================

async function searchQAKnowledgeBase(
  supabase: any,
  query: string,
  maxResults: number
): Promise<any[]> {
  
  // Try full-text search on question_hebrew
  const { data, error } = await supabase
    .from('qa_knowledge_base')
    .select('*')
    .textSearch('question_hebrew', query)
    .limit(maxResults)

  if (error) {
    console.error('QA search error:', error)
    return []
  }

  return data || []
}

async function searchBodyFigures(
  supabase: any,
  query: string,
  maxResults: number
): Promise<any[]> {
  
  // Search symptom links
  const { data: symptomLinks } = await supabase
    .from('figure_symptom_links')
    .select('*')
    .or(`symptom_hebrew.ilike.%${query}%,symptom_english.ilike.%${query}%`)
    .order('priority', { ascending: true })
    .limit(5)

  if (!symptomLinks || symptomLinks.length === 0) {
    return []
  }

  // Get figure IDs
  const figureIds = symptomLinks.flatMap(sl => sl.figure_ids || [])
  
  if (figureIds.length === 0) {
    return []
  }

  // Get figures with acupoints
  const { data: figures } = await supabase
    .from('body_figures')
    .select(`
      *,
      acupoint_mappings (
        acupoint_code,
        acupoint_name_hebrew,
        description_hebrew,
        indications
      )
    `)
    .in('id', figureIds)
    .limit(maxResults)

  // Add recommended points from symptom links
  return (figures || []).map(figure => ({
    ...figure,
    recommended_points: symptomLinks
      .find(sl => sl.figure_ids?.includes(figure.id))
      ?.acupoint_codes || [],
    symptom_match: symptomLinks
      .find(sl => sl.figure_ids?.includes(figure.id))
      ?.symptom_hebrew || query
  }))
}

async function searchTCMHebrewQA(
  supabase: any,
  query: string,
  maxResults: number
): Promise<any[]> {
  
  const { data, error } = await supabase
    .from('tcm_hebrew_qa')
    .select('*')
    .ilike('question', `%${query}%`)
    .limit(maxResults)

  if (error) {
    console.error('TCM Hebrew QA search error:', error)
    return []
  }

  return data || []
}

// ============================================================================
// TOKEN MANAGEMENT
// ============================================================================

async function deductUserTokens(
  supabase: any,
  userId: string,
  tokensToDeduct: number
): Promise<void> {
  
  try {
    const { error } = await supabase
      .from('therapists')
      .update({ 
        tokens_remaining: supabase.raw(`tokens_remaining - ${tokensToDeduct}`)
      })
      .eq('id', userId)

    if (error) {
      console.error('Token deduction error:', error)
    } else {
      console.log(`  💰 Deducted ${tokensToDeduct} tokens from user ${userId}`)
    }
  } catch (error) {
    console.error('Token deduction failed:', error)
  }
}

console.log('🚀 Smart Search Edge Function loaded!')
