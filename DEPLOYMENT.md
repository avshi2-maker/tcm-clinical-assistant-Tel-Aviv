# 🚀 DEPLOYMENT GUIDE - TCM Clinical Assistant

---

## 📋 **TABLE OF CONTENTS**

1. [Git Setup](#git-setup)
2. [GitHub Deployment](#github-deployment)
3. [Supabase Configuration](#supabase-configuration)
4. [Vercel Deployment](#vercel-deployment)
5. [Local Development](#local-development)
6. [Troubleshooting](#troubleshooting)

---

## 🔧 **GIT SETUP**

### **Prerequisites:**
- Git installed on Windows
- GitHub account created
- SSH key configured (optional but recommended)

### **Initial Git Setup:**

```bash
# Navigate to project folder
cd C:\tcm-clinical-assistant-Tel-Aviv

# Initialize Git
git init

# Configure user (first time only)
git config user.name "Your Name"
git config user.email "your.email@example.com"

# Add all files
git add .

# First commit
git commit -m "🔒 IRONCLAD BASELINE v1.0.0"

# Check status
git status
```

---

## 📦 **GITHUB DEPLOYMENT**

### **Step 1: Create GitHub Repository**

1. Go to https://github.com
2. Click "New repository"
3. Name: `tcm-clinical-assistant`
4. Description: "TCM Clinical Assistant - RAG-based AI system"
5. **Private** (recommended for business app)
6. **Do NOT** initialize with README (we have one)
7. Click "Create repository"

### **Step 2: Connect Local to GitHub**

```bash
# Add GitHub as remote
git remote add origin https://github.com/YOUR_USERNAME/tcm-clinical-assistant.git

# Verify remote
git remote -v

# Push to GitHub
git push -u origin main
```

### **Step 3: Verify Upload**

1. Go to your GitHub repository URL
2. You should see:
   - index.html
   - README.md
   - .gitignore
   - DEPLOYMENT.md
   - STRUCTURE.md

---

## 🗄️ **SUPABASE CONFIGURATION**

### **Database is Already Set Up!**

Your Supabase database contains:
- `dr_roni_complete` (341 acupuncture points)
- `zangfu_syndromes` (11 syndromes)
- `diagnostic_questions` (52 symptom questions)
- `symptom_syndrome_mapping` (96 mappings)
- `syndrome_treatment_points` (66 treatment protocols)

### **Connection Details:**

In `index.html`, find these lines (around line 1850):

```javascript
const SUPABASE_URL = 'YOUR_SUPABASE_URL';
const SUPABASE_KEY = 'YOUR_SUPABASE_KEY';
```

**⚠️ IMPORTANT:**
- These credentials should already be correct
- **DO NOT** commit real credentials to public GitHub
- If repository is public, use environment variables

### **To Use Environment Variables (Advanced):**

1. Create `.env` file (ignored by Git):
```
SUPABASE_URL=your_url_here
SUPABASE_KEY=your_key_here
```

2. Update index.html to read from env (requires build step)

---

## ☁️ **VERCEL DEPLOYMENT** (Recommended for Production)

### **Why Vercel?**
- ✅ Free for personal projects
- ✅ Automatic HTTPS
- ✅ CDN worldwide
- ✅ Auto-deploys from GitHub
- ✅ Custom domain support

### **Step 1: Install Vercel CLI**

```bash
npm install -g vercel
```

### **Step 2: Deploy**

```bash
# Navigate to project
cd C:\tcm-clinical-assistant-Tel-Aviv

# Login to Vercel
vercel login

# Deploy
vercel

# Follow prompts:
# - Link to existing project? No
# - Project name: tcm-clinical-assistant
# - Directory: ./ (current)
# - Override settings? No
```

### **Step 3: Production Deployment**

```bash
# Deploy to production
vercel --prod
```

### **Step 4: Custom Domain (Optional)**

1. Go to Vercel dashboard
2. Select your project
3. Go to "Settings" → "Domains"
4. Add your domain (e.g., `tcm.yourdomain.com`)
5. Follow DNS configuration instructions

---

## 💻 **LOCAL DEVELOPMENT**

### **Simple Method (Current):**

```bash
# Just open the file
start index.html
```

### **With Local Server (Better):**

```bash
# Option 1: Python
python -m http.server 8000

# Option 2: Node.js (if installed)
npx http-server -p 8000

# Then open:
http://localhost:8000
```

### **Why Local Server?**
- Better CORS handling
- Proper file paths
- Simulate production environment
- Test Supabase connection

---

## 🔄 **WORKFLOW FOR UPDATES**

### **Making Changes:**

```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Make your changes to index.html

# 3. Test locally
start index.html

# 4. If it works, commit
git add index.html
git commit -m "feat: Your feature description"

# 5. Push branch
git push origin feature/your-feature-name

# 6. Create Pull Request on GitHub

# 7. After review, merge to main

# 8. Deploy to production
git checkout main
git pull origin main
vercel --prod
```

### **Hotfix (Emergency):**

```bash
# 1. Create hotfix branch from main
git checkout main
git checkout -b hotfix/fix-description

# 2. Make minimal fix

# 3. Test

# 4. Commit and push
git add index.html
git commit -m "fix: Critical bug description"
git push origin hotfix/fix-description

# 5. Merge immediately to main

# 6. Deploy
vercel --prod
```

---

## 🧪 **TESTING BEFORE DEPLOYMENT**

### **Pre-Deployment Checklist:**

- [ ] Test on Chrome
- [ ] Test on Firefox
- [ ] Test on Safari (if available)
- [ ] Test on mobile (Chrome DevTools)
- [ ] 450 questions load correctly
- [ ] Clinical modules load correctly
- [ ] Query boxes work
- [ ] Search executes properly
- [ ] Results display
- [ ] Share buttons work
- [ ] Supabase connection active
- [ ] No console errors

### **Load Testing:**

1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Refresh page
4. Check:
   - All resources load (no 404s)
   - Supabase queries succeed
   - Page loads in < 3 seconds

---

## 🐛 **TROUBLESHOOTING**

### **Problem: "git" not recognized**

**Solution:**
```bash
# Install Git for Windows
# Download from: https://git-scm.com/download/win
# Restart terminal after install
```

### **Problem: Can't push to GitHub**

**Solution:**
```bash
# Authenticate with GitHub
git config --global credential.helper wincred

# Or set up SSH key:
ssh-keygen -t ed25519 -C "your_email@example.com"
# Add key to GitHub: Settings → SSH Keys
```

### **Problem: Supabase not connecting**

**Check:**
1. Are credentials correct in index.html?
2. Is Supabase project active?
3. Check browser console for errors
4. Verify CORS settings in Supabase dashboard

### **Problem: Vercel deployment fails**

**Check:**
1. Is index.html in root directory?
2. Are there any build errors?
3. Check Vercel logs: `vercel logs`

### **Problem: Changes not showing**

**Solution:**
```bash
# Clear browser cache
# Chrome: Ctrl+Shift+Delete

# Or hard refresh
# Chrome: Ctrl+F5

# Or use incognito mode
# Chrome: Ctrl+Shift+N
```

---

## 📊 **DEPLOYMENT ENVIRONMENTS**

### **Development (Local):**
- **URL:** `file:///C:/tcm-clinical-assistant-Tel-Aviv/index.html`
- **Purpose:** Testing changes
- **Database:** Supabase (shared)

### **Staging (Vercel Preview):**
- **URL:** Auto-generated by Vercel
- **Purpose:** Test before production
- **Deploys:** Automatic from feature branches

### **Production (Vercel):**
- **URL:** `https://tcm-clinical-assistant.vercel.app`
- **Purpose:** Live for therapists
- **Deploys:** Manual (`vercel --prod`)

---

## 🔐 **SECURITY BEST PRACTICES**

### **DO:**
- ✅ Keep Supabase credentials private
- ✅ Use environment variables for production
- ✅ Keep GitHub repository private
- ✅ Review code before merging
- ✅ Test everything locally first

### **DON'T:**
- ❌ Commit credentials to public repos
- ❌ Push untested code to production
- ❌ Share Supabase keys publicly
- ❌ Deploy with console errors

---

## 📞 **SUPPORT RESOURCES**

### **Git Help:**
- Official docs: https://git-scm.com/doc
- GitHub guides: https://guides.github.com

### **Vercel Help:**
- Documentation: https://vercel.com/docs
- Status page: https://vercel-status.com

### **Supabase Help:**
- Documentation: https://supabase.com/docs
- Status page: https://status.supabase.com

---

## ✅ **DEPLOYMENT CHECKLIST**

### **First Time Setup:**
- [ ] Git installed
- [ ] GitHub account created
- [ ] Repository created
- [ ] Code pushed to GitHub
- [ ] Vercel account created
- [ ] Project deployed to Vercel
- [ ] Custom domain configured (optional)
- [ ] Supabase connected
- [ ] Everything tested

### **Every Update:**
- [ ] Changes tested locally
- [ ] No console errors
- [ ] Committed to feature branch
- [ ] Pull request created
- [ ] Code reviewed
- [ ] Merged to main
- [ ] Deployed to production
- [ ] Verified live site works

---

## 🎊 **YOU'RE READY!**

**Your app is now:**
- ✅ Version controlled (Git)
- ✅ Backed up (GitHub)
- ✅ Deployed (Vercel)
- ✅ Documented (README, STRUCTURE)
- ✅ Protected (IRONCLAD baseline)

**No more losing work!**

**No more 10-hour debugging!**

**Sleep peacefully!** 😴

---

**Last Updated:** 2026-01-28  
**Version:** 1.0.0 IRONCLAD BASELINE
