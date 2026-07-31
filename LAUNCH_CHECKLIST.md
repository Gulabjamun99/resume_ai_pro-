# ResumeAI Pro v1.0.0 — Production Launch & Play Console Checklist

> **Status**: 🟢 **LAUNCH MODE ACTIVE — PRODUCTION READY**  
> **Release Candidate**: `v1.0.0-rc1`  
> **Target SDK**: `34` (Android 14 / 15)  
> **Min SDK**: `21` (Android 5.0+)  

---

## 1. 📋 Google Play Console Submission Checklist
- [x] **Signed Release AAB**: `build/app/outputs/bundle/release/app-release.aab` (44.2 MB)
- [x] **Version Name & Code**: `versionName: "1.0.0"`, `versionCode: 1`
- [x] **App Category**: Productivity / Business
- [x] **Pricing & Distribution**: Free with optional in-app UPI tier unlocks (₹10 / ₹20 / ₹50)
- [x] **Target Audience**: Age 18+ (Job Seekers & Professionals)

---

## 2. 🛡️ Privacy Policy Review & Compliance
- **Hosted Privacy Policy URL**: `https://resume-ai-backend-85zs.onrender.com/privacy`
- **Data Types Processed**:
  - Personal Information (Name, Email, Phone Number, City, LinkedIn/GitHub links)
  - Work Experience & Career History (User-provided resume details)
  - Payment Reference Information (12-digit UPI UTR number for transaction audit)
- **Data Protection Guarantee**:
  - SSL/TLS Encrypted Transport (HTTPS)
  - Zero Data Monetization or Third-Party Sale
  - Non-Destructive User Data Ownership & Version Control

---

## 3. 🎨 Play Store Listing Assets
- **App Icon**: 512×512 PNG (`android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png`)
- **Feature Graphic**: 1024×500 PNG (`play_store_assets/feature_graphic.png`)
- **Phone Screenshots**: 8 High-Res Screenshots covering:
  1. *Landing Page & ATS Score Guarantee*
  2. *Resume Import Source (PDF / DOCX / Paste / Scratch)*
  3. *Step-by-Step Form & Interactive Data Verification*
  4. *Live Resume Canvas Preview (Zoom & Pan Gestures)*
  5. *Conversational Live AI Assistant (Hinglish/English Edits)*
  6. *ATS Audit & Skill Density Suggestions*
  7. *Recruiter Review & Hiring Impression Metrics*
  8. *Time-Travel Version Control & Non-Destructive Rollback*

---

## 4. 🔒 Data Safety Questionnaire Mapping
| Data Type | Collected / Shared | Purpose | Encrypted in Transit? | User Deletion Supported? |
| :--- | :--- | :--- | :--- | :--- |
| Name & Contact Info | Collected | Account & Resume Generation | Yes (HTTPS) | Yes |
| Work & Education | Collected | Resume Processing | Yes (HTTPS) | Yes |
| Financial Info (UTR) | Collected | Payment Verification | Yes (HTTPS) | Yes |
| Device IDs & Logs | Not Shared | Diagnostics & Rate Limiting | Yes (HTTPS) | Automatic Purge |

---

## 5. 🔞 Content Rating Questionnaire Guidance
- **Sex / Nudity**: None (0)
- **Violence / Gore**: None (0)
- **Profanity / Hate Speech**: None (0)
- **User Interactions**: Unrestricted Internet Access (for AI prompt execution & PDF downloads)
- **Expected Rating**: **PEGI 3 / Everyone 3+**

---

## 6. 🔐 Release Signing & ProGuard Verification
- **Keystore**: Release Keystore configured with RSA key length >= 2048-bit.
- **R8 / ProGuard Rules**: `android/app/proguard-rules.pro` keeps Flutter embedding, HttpEngine, and SQLite native libraries.
- **Shrinking Metrics**: MaterialIcons tree-shaken by 99.6% (1.6MB -> 6.8KB).

---

## 7. 📊 Production Monitoring & Logging Checklist
- **Backend Health Check**: `https://resume-ai-backend-85zs.onrender.com/health` (Monitored every 5 mins)
- **OpenAPI Endpoint Verification**: `https://resume-ai-backend-85zs.onrender.com/openapi.json`
- **Rate Limit Limit Enforcement**: IP-sliding window (60 requests/min limit returning HTTP 429)
- **SQLite DB Maintenance**: Write-Ahead Logging (`PRAGMA journal_mode=WAL;`) enabled.

---

## 8. 🚦 Version 1.0.1 Bug-Fix Roadmap (Post-Launch)
- **Critical Class**: Blockers affecting PDF generation or app crash (Immediate hotfix via `hotfix/*`).
- **Recommended Class**: Minor UI spacing tweaks or secondary template color options (Scheduled for `v1.0.1`).
- **Future Enhancement Class**: Cloud backup sync, multi-language support, custom font uploads (Deferred to `v1.1`).
