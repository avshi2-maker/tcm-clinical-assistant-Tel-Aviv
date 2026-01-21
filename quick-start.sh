#!/bin/bash

# ============================================================================
# TCM Knowledge Base - Quick Start Setup Script
# ============================================================================

set -e  # Exit on error

echo "============================================================"
echo "🌿 TCM Knowledge Base - Quick Start Setup"
echo "============================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() {
    echo -e "${BLUE}ℹ ${NC}$1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================================================
# Step 1: Check Prerequisites
# ============================================================================

info "Step 1: Checking prerequisites..."

if ! command_exists python3; then
    error "Python 3 is not installed. Please install Python 3.9 or higher."
    exit 1
fi
success "Python 3 found: $(python3 --version)"

if ! command_exists node; then
    error "Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi
success "Node.js found: $(node --version)"

if ! command_exists npm; then
    error "npm is not installed. Please install npm."
    exit 1
fi
success "npm found: $(npm --version)"

echo ""

# ============================================================================
# Step 2: Environment Configuration
# ============================================================================

info "Step 2: Setting up environment..."

if [ ! -f ".env.local" ]; then
    warning ".env.local not found. Creating from template..."
    cat > .env.local << 'EOF'
# Supabase Configuration
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# API Keys
ANTHROPIC_API_KEY=sk-ant-api03-your-key-here
OPENAI_API_KEY=sk-your-key-here

# Optional
GOOGLE_TRANSLATE_API_KEY=

# Development
NODE_ENV=development
EOF
    warning "Please edit .env.local with your actual API keys and Supabase credentials"
    warning "Get Supabase credentials from: https://app.supabase.com/project/_/settings/api"
    warning "Get Anthropic API key from: https://console.anthropic.com/account/keys"
    
    read -p "Press Enter once you've updated .env.local..."
else
    success ".env.local already exists"
fi

echo ""

# ============================================================================
# Step 3: Install Node Dependencies
# ============================================================================

info "Step 3: Installing Node.js dependencies..."

if [ -f "package.json" ]; then
    npm install
    success "Node.js dependencies installed"
else
    error "package.json not found!"
    exit 1
fi

echo ""

# ============================================================================
# Step 4: Install Python Dependencies
# ============================================================================

info "Step 4: Installing Python dependencies..."

if [ -f "requirements.txt" ]; then
    python3 -m pip install -r requirements.txt --break-system-packages --quiet
    success "Python dependencies installed"
else
    error "requirements.txt not found!"
    exit 1
fi

echo ""

# ============================================================================
# Step 5: Database Setup Instructions
# ============================================================================

info "Step 5: Database setup instructions..."

echo ""
echo "📋 Please complete these manual steps in Supabase:"
echo ""
echo "1. Go to your Supabase project: https://app.supabase.com"
echo "2. Navigate to: Database → Extensions"
echo "3. Enable the 'vector' extension"
echo "4. Go to: SQL Editor → New Query"
echo "5. Copy and paste the contents of 'supabase-schema.sql'"
echo "6. Click 'Run' to execute the schema"
echo ""

read -p "Press Enter once you've completed the database setup..."

success "Database setup acknowledged"

echo ""

# ============================================================================
# Step 6: Verify Setup
# ============================================================================

info "Step 6: Verifying setup..."

# Check if .env.local has been configured
if grep -q "your-project.supabase.co" .env.local; then
    warning "It looks like you haven't updated your Supabase URL in .env.local"
fi

if grep -q "your-key-here" .env.local; then
    warning "It looks like you haven't updated your API keys in .env.local"
fi

success "Setup verification complete"

echo ""

# ============================================================================
# Step 7: Next Steps
# ============================================================================

echo "============================================================"
echo "🎉 Setup Complete!"
echo "============================================================"
echo ""
echo "📚 Next Steps:"
echo ""
echo "1. Process your TCM documents:"
echo "   python3 tcm_document_processor.py"
echo ""
echo "2. Start the development server:"
echo "   npm run dev"
echo ""
echo "3. Open your browser to:"
echo "   http://localhost:3000/deep-thinking"
echo ""
echo "4. For testing the API directly:"
echo "   curl -X POST http://localhost:3000/api/tcm-qa \\"
echo "     -H 'Content-Type: application/json' \\"
echo "     -d '{\"question\":\"מהן נקודות דיקור לכאב ראש?\"}'"
echo ""
echo "============================================================"
echo "📖 Documentation:"
echo "   See SETUP_GUIDE.md for detailed instructions"
echo "============================================================"
echo ""

# Ask if user wants to process documents now
read -p "Would you like to process the TCM documents now? (y/N): " process_now

if [[ $process_now =~ ^[Yy]$ ]]; then
    echo ""
    info "Starting document processing..."
    
    if [ -f "tcm_document_processor.py" ]; then
        python3 tcm_document_processor.py
    else
        error "tcm_document_processor.py not found!"
        exit 1
    fi
else
    info "Skipping document processing. Run it manually when ready:"
    echo "   python3 tcm_document_processor.py"
fi

echo ""
success "All done! 🚀"
echo ""
