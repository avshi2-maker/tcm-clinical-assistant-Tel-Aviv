/**
 * ====================================
 * TCM Clinical Assistant Library
 * ====================================
 * Modular JavaScript library for:
 * - Point code extraction
 * - Body images display
 * - Q&A knowledge base search
 * - Pharmacopeia recommendations
 * 
 * Author: TCM Clinical Assistant Team
 * Version: 1.0.0
 * ====================================
 */

const TCMAssistant = (function() {
    'use strict';
    
    // ====================================
    // CONFIGURATION
    // ====================================
    const CONFIG = {
        // Supabase tables
        tables: {
            bodyImages: 'body_images',
            qaKnowledge: 'qa_knowledge_base'
        },
        
        // Columns
        bodyImagesColumns: {
            bodyPart: 'body_part',
            imageUrl: 'image_url',
            acupointCodes: 'acupoint_codes'
        },
        
        qaColumns: {
            question: 'question_hebrew',
            answer: 'answer_hebrew',
            acupointCodes: 'acupoint_codes',
            description: 'description_hebrew',
            pharmacopeia: 'pharmacopeia_hebrew',
            category: 'category'
        },
        
        // UI container IDs
        containers: {
            bodyImages: 'bodyImagesContainer',
            qaResults: 'qaResultsContainer',
            imageModal: 'imageModal'
        }
    };
    
    // ====================================
    // UTILITY FUNCTIONS
    // ====================================
    
    /**
     * Extract acupuncture point codes from text
     * Matches patterns like: LI4, ST36, GB20, BL23, REN17, etc.
     */
    function extractPointCodes(text) {
        if (!text) return [];
        
        // Pattern for standard acupuncture point codes
        const pointPattern = /\b([A-Z]{1,3})\s*[-]?\s*(\d{1,2}[A-Za-z]?)\b/gi;
        const matches = text.matchAll(pointPattern);
        
        const pointCodes = new Set();
        for (const match of matches) {
            const code = `${match[1].toUpperCase()}${match[2]}`;
            pointCodes.add(code);
        }
        
        return Array.from(pointCodes);
    }
    
    /**
     * Format body part name for display
     */
    function formatBodyPart(bodyPart) {
        if (!bodyPart) return '';
        
        return bodyPart
            .split('_')
            .map(word => word.charAt(0).toUpperCase() + word.slice(1))
            .join(' ');
    }
    
    /**
     * Show loading state
     */
    function showLoading(containerId, message = 'טוען...') {
        const container = document.getElementById(containerId);
        if (!container) return;
        
        container.innerHTML = `
            <div class="tcm-loading">
                <div class="tcm-spinner"></div>
                <p>${message}</p>
            </div>
        `;
    }
    
    /**
     * Clear container
     */
    function clearContainer(containerId) {
        const container = document.getElementById(containerId);
        if (container) {
            container.innerHTML = '';
        }
    }
    
    // ====================================
    // BODY IMAGES FUNCTIONS
    // ====================================
    
    /**
     * Fetch body images from Supabase
     */
    async function fetchBodyImages(pointCodes) {
        if (!pointCodes || pointCodes.length === 0) {
            return [];
        }

        try {
            const { data, error } = await window.supabase
                .from(CONFIG.tables.bodyImages)
                .select(`
                    ${CONFIG.bodyImagesColumns.bodyPart},
                    ${CONFIG.bodyImagesColumns.imageUrl},
                    ${CONFIG.bodyImagesColumns.acupointCodes}
                `);

            if (error) {
                console.error('Error fetching body images:', error);
                return [];
            }

            if (!data) return [];

            // Filter images that contain any of the requested point codes
            const matchingImages = data.filter(image => {
                if (!image[CONFIG.bodyImagesColumns.acupointCodes] || 
                    !Array.isArray(image[CONFIG.bodyImagesColumns.acupointCodes])) {
                    return false;
                }
                
                return image[CONFIG.bodyImagesColumns.acupointCodes].some(code => 
                    pointCodes.includes(code)
                );
            });

            return matchingImages;
        } catch (error) {
            console.error('Error in fetchBodyImages:', error);
            return [];
        }
    }
    
    /**
     * Display body images
     */
    function displayBodyImages(images) {
        const container = document.getElementById(CONFIG.containers.bodyImages);
        if (!container) return;
        
        if (!images || images.length === 0) {
            container.innerHTML = '';
            return;
        }

        const html = `
            <div class="tcm-body-images-section">
                <div class="tcm-section-header">
                    <span class="tcm-icon">📍</span>
                    <h3>מיקום נקודות על גוף האדם (${images.length} תמונות)</h3>
                </div>
                <div class="tcm-images-grid">
                    ${images.map(img => `
                        <div class="tcm-image-card" onclick="TCMAssistant.openImageModal('${img[CONFIG.bodyImagesColumns.imageUrl]}', '${img[CONFIG.bodyImagesColumns.bodyPart]}', '${(img[CONFIG.bodyImagesColumns.acupointCodes] || []).join(', ')}')">
                            <img src="${img[CONFIG.bodyImagesColumns.imageUrl]}" 
                                 alt="${formatBodyPart(img[CONFIG.bodyImagesColumns.bodyPart])}"
                                 loading="lazy"
                                 onerror="this.style.display='none'">
                            <div class="tcm-card-title">${formatBodyPart(img[CONFIG.bodyImagesColumns.bodyPart])}</div>
                            <div class="tcm-card-subtitle">${(img[CONFIG.bodyImagesColumns.acupointCodes] || []).join(', ')}</div>
                        </div>
                    `).join('')}
                </div>
            </div>
        `;

        container.innerHTML = html;
    }
    
    // ====================================
    // Q&A KNOWLEDGE BASE FUNCTIONS
    // ====================================
    
    /**
     * Search Q&A knowledge base by point codes
     */
    async function searchKnowledgeBase(pointCodes) {
        if (!pointCodes || pointCodes.length === 0) {
            return [];
        }

        try {
            const { data, error } = await window.supabase
                .from(CONFIG.tables.qaKnowledge)
                .select('*');

            if (error) {
                console.error('Error searching knowledge base:', error);
                return [];
            }

            if (!data) return [];

            // Filter Q&A entries that contain any of the requested point codes
            const matchingQA = data.filter(qa => {
                if (!qa[CONFIG.qaColumns.acupointCodes]) {
                    return false;
                }
                
                // Handle both string and array formats
                let codes = qa[CONFIG.qaColumns.acupointCodes];
                if (typeof codes === 'string') {
                    codes = extractPointCodes(codes);
                }
                
                return codes.some(code => pointCodes.includes(code));
            });

            return matchingQA;
        } catch (error) {
            console.error('Error in searchKnowledgeBase:', error);
            return [];
        }
    }
    
    /**
     * Display Q&A results
     */
    function displayQAResults(qaResults) {
        const container = document.getElementById(CONFIG.containers.qaResults);
        if (!container) return;
        
        if (!qaResults || qaResults.length === 0) {
            container.innerHTML = '';
            return;
        }

        const html = `
            <div class="tcm-qa-section">
                <div class="tcm-section-header">
                    <span class="tcm-icon">💡</span>
                    <h3>ידע קליני רלוונטי (${qaResults.length} תוצאות)</h3>
                </div>
                <div class="tcm-qa-grid">
                    ${qaResults.map((qa, index) => `
                        <div class="tcm-qa-card">
                            <div class="tcm-qa-question">
                                <strong>שאלה:</strong> ${qa[CONFIG.qaColumns.question] || ''}
                            </div>
                            <div class="tcm-qa-answer">
                                <strong>תשובה:</strong> ${qa[CONFIG.qaColumns.answer] || ''}
                            </div>
                            ${qa[CONFIG.qaColumns.description] ? `
                                <div class="tcm-qa-description">
                                    <strong>תיאור:</strong> ${qa[CONFIG.qaColumns.description]}
                                </div>
                            ` : ''}
                            ${qa[CONFIG.qaColumns.pharmacopeia] ? `
                                <div class="tcm-qa-pharmacopeia">
                                    <strong>פרמקופיאה:</strong> ${qa[CONFIG.qaColumns.pharmacopeia]}
                                </div>
                            ` : ''}
                            ${qa[CONFIG.qaColumns.category] ? `
                                <div class="tcm-qa-category">
                                    <span class="tcm-badge">${qa[CONFIG.qaColumns.category]}</span>
                                </div>
                            ` : ''}
                        </div>
                    `).join('')}
                </div>
            </div>
        `;

        container.innerHTML = html;
    }
    
    // ====================================
    // MODAL FUNCTIONS
    // ====================================
    
    /**
     * Open image modal
     */
    function openImageModal(imageUrl, bodyPart, codes) {
        const modal = document.getElementById(CONFIG.containers.imageModal);
        if (!modal) return;
        
        const modalImage = modal.querySelector('#modalImage');
        const modalRegion = modal.querySelector('#modalRegion');
        const modalCodes = modal.querySelector('#modalCodes');

        if (modalImage) modalImage.src = imageUrl;
        if (modalRegion) modalRegion.textContent = formatBodyPart(bodyPart);
        if (modalCodes) modalCodes.textContent = codes;

        modal.classList.add('active');
    }
    
    /**
     * Close image modal
     */
    function closeImageModal() {
        const modal = document.getElementById(CONFIG.containers.imageModal);
        if (modal) {
            modal.classList.remove('active');
        }
    }
    
    // ====================================
    // MAIN PROCESSING FUNCTION
    // ====================================
    
    /**
     * Process AI response and display all related information
     * This is the main function to call after getting AI response
     */
    async function processAIResponse(aiResponse) {
        console.log('TCM Assistant: Processing AI response...');
        
        // Extract point codes
        const pointCodes = extractPointCodes(aiResponse);
        
        if (pointCodes.length === 0) {
            console.log('TCM Assistant: No point codes found');
            clearContainer(CONFIG.containers.bodyImages);
            clearContainer(CONFIG.containers.qaResults);
            return;
        }

        console.log('TCM Assistant: Found point codes:', pointCodes);
        
        // Show loading states
        showLoading(CONFIG.containers.bodyImages, 'טוען תמונות נקודות...');
        showLoading(CONFIG.containers.qaResults, 'מחפש ידע קליני...');
        
        // Fetch and display body images
        const images = await fetchBodyImages(pointCodes);
        displayBodyImages(images);
        console.log('TCM Assistant: Displayed', images.length, 'body images');
        
        // Fetch and display Q&A knowledge
        const qaResults = await searchKnowledgeBase(pointCodes);
        displayQAResults(qaResults);
        console.log('TCM Assistant: Displayed', qaResults.length, 'Q&A results');
    }
    
    // ====================================
    // INITIALIZATION
    // ====================================
    
    /**
     * Initialize the TCM Assistant
     */
    function init(customConfig = {}) {
        console.log('TCM Assistant: Initializing...');
        
        // Merge custom configuration
        if (customConfig.tables) {
            Object.assign(CONFIG.tables, customConfig.tables);
        }
        
        // Set up event listeners
        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                closeImageModal();
            }
        });
        
        // Click outside modal to close
        const modal = document.getElementById(CONFIG.containers.imageModal);
        if (modal) {
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    closeImageModal();
                }
            });
        }
        
        console.log('TCM Assistant: Ready!');
    }
    
    // ====================================
    // PUBLIC API
    // ====================================
    
    return {
        // Main functions
        init: init,
        processAIResponse: processAIResponse,
        
        // Body images
        fetchBodyImages: fetchBodyImages,
        displayBodyImages: displayBodyImages,
        
        // Q&A Knowledge base
        searchKnowledgeBase: searchKnowledgeBase,
        displayQAResults: displayQAResults,
        
        // Modal
        openImageModal: openImageModal,
        closeImageModal: closeImageModal,
        
        // Utilities
        extractPointCodes: extractPointCodes,
        
        // Configuration (read-only access)
        getConfig: () => ({ ...CONFIG })
    };
})();

// Make it available globally
window.TCMAssistant = TCMAssistant;

console.log('✅ TCM Assistant Library Loaded');
