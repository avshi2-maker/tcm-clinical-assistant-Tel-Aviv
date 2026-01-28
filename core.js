/**
 * CORE.JS - IRON-CLAD FOUNDATION
 * ================================
 * DO NOT MODIFY THIS FILE AFTER IT WORKS!
 * 
 * This file contains:
 * - Supabase connection
 * - Global configuration
 * - Shared utilities
 * 
 * Used by ALL pages in the TCM system
 */

// Global namespace to avoid conflicts
window.TCM = window.TCM || {};

// ============================================================================
// SUPABASE CONFIGURATION (LOCKED)
// ============================================================================

const SUPABASE_CONFIG = {
    url: 'https://iqfglrwjemogoycbzltt.supabase.co',
    key: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlxZmdscndqZW1vZ295Y2J6bHR0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1NTM4ODMsImV4cCI6MjA4NDEyOTg4M30.DTREv3efs86_HzESyWm-7480ImfEVgC6T-xBdS6A2F8'
};

// Initialize Supabase client
TCM.supabase = window.supabase.createClient(
    SUPABASE_CONFIG.url,
    SUPABASE_CONFIG.key
);

console.log('✅ TCM Core loaded - Supabase connected');

// ============================================================================
// GLOBAL UTILITIES (LOCKED)
// ============================================================================

TCM.utils = {
    /**
     * Format date in Hebrew
     */
    formatDate: function(date) {
        return new Date(date).toLocaleDateString('he-IL');
    },
    
    /**
     * Debounce function for search
     */
    debounce: function(func, wait) {
        let timeout;
        return function executedFunction(...args) {
            const later = () => {
                clearTimeout(timeout);
                func(...args);
            };
            clearTimeout(timeout);
            timeout = setTimeout(later, wait);
        };
    },
    
    /**
     * Show loading indicator
     */
    showLoading: function(elementId) {
        const element = document.getElementById(elementId);
        if (element) {
            element.innerHTML = '<div class="loading">⏳ טוען...</div>';
        }
    },
    
    /**
     * Hide loading indicator
     */
    hideLoading: function(elementId) {
        const element = document.getElementById(elementId);
        if (element) {
            const loading = element.querySelector('.loading');
            if (loading) loading.remove();
        }
    },
    
    /**
     * Show error message
     */
    showError: function(elementId, message) {
        const element = document.getElementById(elementId);
        if (element) {
            element.innerHTML = `<div class="error">❌ ${message}</div>`;
        }
    }
};

// ============================================================================
// CACHE MANAGEMENT (LOCKED)
// ============================================================================

TCM.cache = {
    storage: new Map(),
    ttl: 5 * 60 * 1000, // 5 minutes
    
    set: function(key, value) {
        this.storage.set(key, {
            value: value,
            timestamp: Date.now()
        });
    },
    
    get: function(key) {
        const item = this.storage.get(key);
        if (!item) return null;
        
        // Check if expired
        if (Date.now() - item.timestamp > this.ttl) {
            this.storage.delete(key);
            return null;
        }
        
        return item.value;
    },
    
    clear: function() {
        this.storage.clear();
    }
};

// ============================================================================
// NAVIGATION (SHARED)
// ============================================================================

TCM.navigation = {
    /**
     * Initialize navigation for current page
     */
    init: function() {
        const currentPage = window.location.pathname.split('/').pop() || 'index.html';
        const navLinks = document.querySelectorAll('nav a');
        
        navLinks.forEach(link => {
            const href = link.getAttribute('href');
            if (href === currentPage) {
                link.classList.add('active');
            }
        });
    }
};

// ============================================================================
// INITIALIZATION
// ============================================================================

// Auto-initialize when DOM is ready
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', function() {
        TCM.navigation.init();
    });
} else {
    TCM.navigation.init();
}

console.log('✅ TCM Core initialized');
