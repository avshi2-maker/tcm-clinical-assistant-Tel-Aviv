/**
 * TCM Clinical Assistant - Supabase Configuration
 * Central configuration file for all Supabase connections
 * 
 * SECURITY NOTE:
 * - This file contains the PUBLIC anon key (safe for client-side use)
 * - The anon key has Row Level Security (RLS) restrictions
 * - Never commit service_role key to public repositories
 * 
 * USAGE:
 * Include this script BEFORE any page that needs Supabase:
 * <script src="supabase-config.js"></script>
 * 
 * Then access via: window.TCM_SUPABASE.client
 * 
 * Date: January 21, 2026
 * Version: 1.0.0
 */

(function() {
    'use strict';
    
    // ==================== CONFIGURATION ====================
    const SUPABASE_URL = 'https://iqfglrwjemogoycbzltt.supabase.co';
    const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTM4ODMsImV4cCI6MjA4NDEyOTg4M30.DTREv3efs86_HzESyWm-7480ImfEVgC6T-xBdS6A2F8';
    
    // ==================== VALIDATION ====================
    if (!window.supabase) {
        console.error('❌ Supabase library not loaded! Please include: <script src="https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2"></script>');
        return;
    }
    
    // ==================== INITIALIZE CLIENT ====================
    const supabaseClient = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
    
    // ==================== GLOBAL NAMESPACE ====================
    window.TCM_SUPABASE = {
        // Direct client access
        client: supabaseClient,
        
        // Config values (read-only)
        url: SUPABASE_URL,
        version: '1.0.0',
        
        // Utility functions
        async testConnection() {
            try {
                const { data, error } = await supabaseClient
                    .from('yin_yang_symptoms')
                    .select('count')
                    .limit(1);
                
                if (error) {
                    console.error('❌ Supabase connection test failed:', error);
                    return false;
                }
                
                console.log('✅ Supabase connection successful!');
                return true;
            } catch (err) {
                console.error('❌ Supabase connection error:', err);
                return false;
            }
        },
        
        // Quick access to tables
        tables: {
            yinYangSymptoms: 'yin_yang_symptoms',
            yinYangProtocols: 'yin_yang_pattern_protocols',
            acupoints: 'tcm_acupoints',
            images: 'tcm_body_images',
            formulas: 'tcm_formulas'
        }
    };
    
    // ==================== CONSOLE INFO ====================
    console.log('✅ TCM Supabase Config Loaded');
    console.log('📍 URL:', SUPABASE_URL);
    console.log('🔧 Version:', window.TCM_SUPABASE.version);
    console.log('📚 Usage: window.TCM_SUPABASE.client');
    
})();
