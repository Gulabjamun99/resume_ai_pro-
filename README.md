# ResumeAI Pro — AI Resume Intelligence & Editing Platform (v1.0 General Availability)

ResumeAI Pro is an enterprise-grade AI Resume Workspace. It operates on a canonical, immutable **ResumeWorkspace** model, extracts design blueprints (`LayoutBlueprint`), and executes section-scoped differential edits through a 10-module pipeline.

---

## 🚀 Key Features (Modules 1–10)

- **Module 1: Resume Upload & Parsing Engine** — Parses PDF, DOCX, JPG, PNG, TXT raw resume text into structured `ResumeData` without synthetic fallbacks.
- **Module 2: Resume Intelligence Graph** — Maps career trajectories, skill taxonomies, and experience graphs.
- **Module 3: Design Preservation Engine** — Separates content from design specifications (typography, margins, colors, header layout, sidebars).
- **Module 4: Executive AI Career Assistant** — Proactive suggestions, recruiter review analysis, and JD keyword matching.
- **Module 5: Cognitive Thinking Engine** — Intent classification and section-scoped edit planning without full resume regeneration.
- **Module 6: Differential Patch Engine** — Generates Git-style section-scoped patches (`PatchResult`).
- **Module 7: AI Resume Guardian** — 5-stage validation gate (Data Integrity, Truthfulness, ATS, Layout, Business Rules) with SHA-256 signatures.
- **Module 8: Multi-Dimensional Health Engine** — 13-dimension health scoring (ATS compatibility, recruiter impact, action verb density, timeline consistency).
- **Module 9: Real-Time Rendering Engine** — Layout stability scoring, SHA-256 fingerprinting, plus real PDF (ReportLab) and DOCX (python-docx) binary generation.
- **Module 10: Multi-Version Control & Time-Travel Engine** — Git-inspired persistent version control in SQLite (`db.sqlite3`), recruiter visual diffing, read-only time travel preview, and non-destructive rollbacks.

---

## 🏗️ Quick Start & Local Execution

### 1. Backend Setup (Python 3.10+ / FastAPI)

```bash
cd backend

# Create virtual environment
python -m venv venv
# On Windows:
venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start production backend server
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

Backend will be active at: `http://localhost:8000` (OpenAPI Docs at `http://localhost:8000/docs`).

---

### 2. Environment Variables (`.env`)

Create a `.env` file in the `backend/` directory:

```env
GEMINI_API_KEY=your_gemini_api_key_here
GEMINI_MODEL=gemini-2.0-flash
DATABASE_URL=sqlite:///./db.sqlite3
ENVIRONMENT=production
```

---

### 3. Frontend Setup (Flutter 3.x)

```bash
# Get dependencies
flutter pub get

# Run Flutter app locally
flutter run

# Build Android Production Release APK
cmd /c "set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr&& cd android && gradlew.bat assembleRelease"
```

The compiled release APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing & Verification Logs

```bash
# Run backend 13-point test suite (REST endpoints, SQLite, security & concurrency)
python scratch/run_backend_tests.py

# Run real E2E pipeline verification (Zero-hallucination audit, PDF/DOCX generation)
python scratch/execute_zero_hallucination_proof.py
```

---

## 📚 Documentation Index

- [Architecture Guide](ARCHITECTURE.md)
- [API Documentation](API_DOCUMENTATION.md)
- [Database Schema](DATABASE_SCHEMA.md)
- [Version History](VERSION_HISTORY.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Testing & Quality Guide](TESTING.md)
