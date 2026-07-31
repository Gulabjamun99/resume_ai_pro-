# ResumeAI Pro — AI Resume Intelligence & Editing Platform (v1.0 Release Candidate)

ResumeAI Pro is an enterprise-grade AI Resume Editor & Intelligence Engine. It operates on a canonical, immutable **ResumeWorkspace** model and executes section-scoped differential edits through a 10-module pipeline.

---

## 🚀 Key Features (Modules 1–10)

- **Module 1: Resume Upload & Parsing Engine** — Parses PDF, DOCX, JPG, PNG, TXT raw resume text into structured `ResumeData`.
- **Module 2: Resume Intelligence Graph** — Maps career trajectories, skill taxonomies, and experience graphs.
- **Module 3: Design Preservation Engine** — Separates content from design specifications (typography, margins, colors).
- **Module 4: Executive AI Career Assistant** — Proactive suggestions, recruiter review analysis, and JD keyword matching.
- **Module 5: Cognitive Thinking Engine** — Intent classification and section-scoped edit planning without full resume regeneration.
- **Module 6: Differential Patch Engine** — Generates Git-style section-scoped patches (`PatchResult`).
- **Module 7: AI Resume Guardian** — 5-stage validation gate (Data Integrity, Truthfulness, ATS, Layout, Business Rules) with SHA-256 signatures.
- **Module 8: Multi-Dimensional Health Engine** — 13-dimension health scoring (ATS compatibility, recruiter impact, action verb density, timeline consistency).
- **Module 9: Real-Time Rendering Engine** — Layout stability scoring, SHA-256 fingerprinting, plus real PDF (ReportLab) and DOCX (python-docx) file generation.
- **Module 10: Multi-Version Control & Time-Travel Engine** — Git-inspired persistent version control in SQLite (`db.sqlite3`), recruiter visual diffing, read-only time travel preview, and non-destructive rollbacks.

---

## 🏗️ Quick Start

### Backend (Python FastAPI)

```bash
cd backend
python -m venv venv
# On Windows:
venv\Scripts\activate

pip install -r requirements.txt
python -m uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Frontend (Flutter)

```bash
# Verify Flutter SDK
flutter doctor

# Run app locally
flutter run
```

---

## 🧪 Testing

```bash
# Run backend test suite (10 unit tests covering REST endpoints, SQLite, security & concurrency)
python scratch/run_backend_tests.py

# Run real E2E pipeline verification (17-step end-to-end flow)
python scratch/verify_real_e2e_pipeline.py
```

---

## 📚 Documentation Index

- [Architecture Guide](file:///d:/ohara%20works/ResumeAI_Pro/resume_ai_clean/ARCHITECTURE.md)
- [API Documentation](file:///d:/ohara%20works/ResumeAI_Pro/resume_ai_clean/API_DOCUMENTATION.md)
- [Database Schema](file:///d:/ohara%20works/ResumeAI_Pro/resume_ai_clean/DATABASE_SCHEMA.md)
- [Version History](file:///d:/ohara%20works/ResumeAI_Pro/resume_ai_clean/VERSION_HISTORY.md)
- [Deployment Guide](file:///d:/ohara%20works/ResumeAI_Pro/resume_ai_clean/DEPLOYMENT.md)
- [Testing & Quality Guide](file:///d:/ohara%20works/ResumeAI_Pro/resume_ai_clean/TESTING.md)
