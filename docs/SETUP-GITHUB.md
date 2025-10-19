# GitHub Setup Instructions

## Step 1: Create Remote Repository on GitHub

1. **Go to GitHub**: https://github.com/new

2. **Repository Details**:
   - **Repository name**: `Get-Privileged-Report` (or `privileged-activities-report`)
   - **Description**: Enterprise-grade PowerShell tool for auditing privileged activities with parallel processing and log capacity analysis
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README (we already have one)
   - **DO NOT** add .gitignore (we already have one)
   - **DO NOT** add license yet

3. **Click "Create repository"**

## Step 2: Link Local to Remote

After creating the repository on GitHub, run these commands:

```powershell
# Add the remote (replace YOUR_USERNAME with your GitHub username)
git remote add origin https://github.com/YOUR_USERNAME/Get-Privileged-Report.git

# Verify remote was added
git remote -v

# Push to GitHub
git branch -M main
git push -u origin main
```

## Alternative: Using SSH

If you have SSH keys set up:

```powershell
git remote add origin git@github.com:YOUR_USERNAME/Get-Privileged-Report.git
git branch -M main
git push -u origin main
```

## Repository Information

**Title**: Privileged Activities Report Generator

**Description**:
```
Enterprise-grade PowerShell tool for auditing privileged activities across Windows infrastructure. Features parallel processing (5-8x faster), risk scoring, log capacity analysis, and comprehensive reporting. Supports SOX, HIPAA, PCI DSS, and NIST 800-53 compliance requirements.
```

**Topics/Tags** (add these on GitHub after creation):
- powershell
- security-audit
- active-directory
- compliance
- windows-security
- event-log-analysis
- siem
- incident-response
- privileged-access
- audit-trail

## README Badges (Optional)

After pushing, you can add these badges to the top of README.md:

```markdown
![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-blue)
![Version](https://img.shields.io/badge/version-2.1.0-green)
![License](https://img.shields.io/badge/license-Enterprise-orange)
![Author](https://img.shields.io/badge/author-Adrian%20Johnson-blue)
```

## After First Push

1. **Set up GitHub Pages** (if making docs public):
   - Settings → Pages → Source: Deploy from main branch
   
2. **Add topics** (improves discoverability):
   - Main repo page → About → Settings icon → Add topics

3. **Create Release**:
   - Releases → Create a new release
   - Tag: v2.1.0
   - Title: "v2.1.0 - Log Capacity Analysis Edition"
   - Description: Copy from CHANGELOG.md

4. **Enable Discussions** (optional):
   - Settings → Features → Discussions

---

**Your local repository is ready!**  
Just create the remote on GitHub and run the connection commands above.

