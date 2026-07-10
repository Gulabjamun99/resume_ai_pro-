# 🤖 ANTIGRAVITY — INSTRUCTIONS (Read this first)

This is a **complete Flutter Android app** called **ResumeAI Pro** — an
AI-powered ATS resume builder, plus a FastAPI backend. All code is ready.
Your job is just to build and run it.

---

## ✅ Step-by-Step

### 1. Validate the Flutter project
```bash
cd resume_ai_clean
flutter doctor
```

### 2. Install Flutter dependencies
```bash
flutter pub get
```
This auto-generates `.dart_tool/`, `pubspec.lock`, and any missing gradle
wrapper files.

### 3. Set up and run the backend (do this FIRST, before building the app)
```bash
cd backend
pip install -r requirements.txt
```

Set these two environment variables before starting the server:
```bash
export AI_PROVIDER=gemini
export GEMINI_API_KEY=your_key_here
```

Get a **free** Gemini key — no credit card required — at:
**https://aistudio.google.com/apikey**

Then start the server:
```bash
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Verify it's running:
```bash
curl http://localhost:8000/health
# should return: {"status":"ok","message":"ResumeAI Pro backend running"}
```

### 4. Point the Flutter app at the backend
File: `lib/services/api_service.dart` (near the top)
```dart
static const String baseUrl = 'http://10.0.2.2:8000';
```
- **Android emulator** → this URL is already correct, no change needed
- **Real physical phone** on the same WiFi → replace with the developer's
  computer's WiFi IPv4 address, e.g. `http://192.168.1.XX:8000`
  (find it with `ipconfig` on Windows or `ifconfig` on Mac/Linux)
- **Deployed backend** (Render/Railway/etc.) → use that production URL instead

### 5. Build the APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### 6. If a Gradle/Kotlin error appears
This is normal the first time — Gradle downloads its own
`gradle-wrapper.jar` from the internet on first run. Just make sure
there's an internet connection during the build.

If `local.properties` complains about a wrong SDK path, edit
`android/local.properties`:
```properties
flutter.sdk=C:\\flutter
sdk.dir=C:\\Users\\<name>\\AppData\\Local\\Android\\sdk
```

---

## 💰 AI Provider — runs FREE by default (Gemini)

The backend never talks to any AI provider directly in `main.py` — every
AI call goes through `backend/ai_provider.py`, which supports four
providers, switched with **one environment variable**:

```bash
# DEFAULT — Google Gemini, genuinely free, no credit card, ~1500 req/day
export AI_PROVIDER=gemini
export GEMINI_API_KEY=your_key_from_aistudio.google.com/apikey

# Paid option — switch to this once revenue covers the cost (higher quality)
export AI_PROVIDER=claude
export ANTHROPIC_API_KEY=sk-ant-xxxxx

# Free backup — fastest, but open-source models only, lower writing quality
export AI_PROVIDER=groq
export GROQ_API_KEY=your_key_from_console.groq.com

# Free via aggregator — if you already have an OpenRouter key
export AI_PROVIDER=openrouter
export OPENROUTER_API_KEY=your_key_from_openrouter.ai/keys
```

**Use `gemini` as the default for launch.** It costs nothing as long as
total usage across all users stays under ~1500 AI calls/day. Nothing else
in the codebase needs to change to switch providers later — just these
two environment variables.

⚠️ **Honest tradeoff to know:** Google's free tier may use free-tier
prompts to improve their models. This app sends real personal data (name,
phone, work history) in every prompt. That's an acceptable tradeoff for
an early-stage free launch, but re-check Google's current terms at
ai.google.dev before scaling with a lot of real user data.

---

## 🆕 Old CV Upload + Smart Parsing

The app supports 3 ways to get a user's data in:
1. **Upload Old CV** (PDF/DOCX/Image) — AI reads it and extracts fields
   (OCR included for scanned images)
2. **Paste Text** — copy-paste from LinkedIn or anywhere
3. **Manual Form** — fill everything from scratch

Flow: `Landing` → `CVSourceScreen` (3 options) → `CVUploadScreen`
(upload/paste + an "Anything New to Add?" step) → `FormScreen`
(pre-filled, user verifies/edits) → rest of the flow continues as normal.

Backend routes involved:
- `POST /upload-cv` — takes a file, returns extracted raw text
- `POST /parse-cv` — takes raw text + any new info, returns structured JSON

Extra Python packages needed for this (already in `requirements.txt`):
```
pdfplumber       # PDF text extraction
pytesseract      # OCR for scanned images/PDFs
Pillow           # image processing
```

⚠️ The **Tesseract OCR engine** itself must also be installed on the
system (only needed for scanned image/PDF uploads — normal text-based
PDF/DOCX/paste all work without it):
- Windows: get the installer from
  https://github.com/UB-Mannheim/tesseract/wiki
- If not installed, everything else still works — only OCR on
  scanned/photo CVs will fail with a clear error message

---

## 🎯 JD-Tailored Resume Feature (₹10 flat, 2 free edits)

A separate flow where the user pastes a job description first, and the
AI reframes their real experience to match that specific job — never
inventing anything, just prioritizing and rewording truthfully.

Flow: `Landing` → `JDPasteScreen` → `CVSourceScreen` (jobDescription
carried through) → same CV upload/form flow → `TemplateSelectorScreen`
→ `VerifyScreen` (shows the JD being matched) → `PaymentScreen` (flat
₹10, 2 edits instead of the normal 3) → `BuildingScreen` → `ResultScreen`
(shows both ATS score and JD match %).

Backend route: `POST /generate-jd-tailored` — same shape response as
`/generate`, plus `jd_match_score`, `jd_keywords_matched`,
`jd_keywords_missing` fields.

---

## 🎨 8 Resume Templates + 12 Colors

`TemplateSelectorScreen` lets the user pick from 8 ATS-safe, single-column
layouts (Classic, Modern, Bold Accent, Executive, Minimalist, Full Color
Header, Timeline, Compact) and 12 accent colors. Color only touches
headers/section titles/skill tags — never sidebars or tables — so every
template stays fully ATS-parseable. The chosen `template_id` and
`template_color` flow through to both the in-app preview
(`resume_preview.dart`) and the backend PDF/DOCX generation, so the
downloaded file matches what was previewed.

---

## 🗂 Project Structure

```
resume_ai_clean/
├── lib/
│   ├── main.dart
│   ├── theme.dart
│   ├── models/
│   │   ├── resume_model.dart
│   │   └── template_model.dart
│   ├── services/api_service.dart       ← backend URL is set here
│   ├── screens/                        ← 10 screens, landing → result
│   └── widgets/resume_preview.dart      ← renders all 8 templates
├── android/
│   ├── app/build.gradle
│   ├── app/src/main/AndroidManifest.xml
│   ├── app/src/main/kotlin/.../MainActivity.kt
│   ├── app/src/main/res/mipmap-*/ic_launcher.png
│   ├── local.properties
│   ├── gradlew / gradlew.bat
│   └── build.gradle
├── backend/
│   ├── main.py                  ← all FastAPI routes
│   ├── ai_provider.py           ← switches between Gemini/Claude/Groq/OpenRouter
│   ├── .env.example             ← copy this to know what env vars to set
│   └── requirements.txt
├── pubspec.yaml
└── analysis_options.yaml
```

---

## ⚠️ Common Errors & Fixes

| Error | Fix |
|---|---|
| `gradle-wrapper.jar not found` | Run `flutter pub get` or `gradlew` once — it auto-downloads (needs internet) |
| `SDK location not found` | Fix the path in `android/local.properties` |
| `Connection refused` in the app | Check the backend is running: `curl http://localhost:8000/health` |
| `CLEARTEXT communication not permitted` | Already handled — `usesCleartextTraffic="true"` is set in `AndroidManifest.xml` |
| Kotlin version mismatch | Match `kotlin_version` in `android/build.gradle` to your installed Flutter SDK |
| AI call fails with a provider error | Check `AI_PROVIDER` and the matching `*_API_KEY` env var are both set correctly |

---

## 🎯 Summary

1. `cd backend && pip install -r requirements.txt`
2. `export AI_PROVIDER=gemini` + `export GEMINI_API_KEY=...`
3. `uvicorn main:app --host 0.0.0.0 --port 8000 --reload`
4. `cd .. && flutter pub get`
5. `flutter build apk --release`

If something errors, check the table above first — these are all normal
Flutter/backend setup issues, not bugs in the code.
