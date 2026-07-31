# Changelog — ResumeAI Pro

All notable changes to the ResumeAI Pro platform will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [1.0.0] - 2026-07-31

### Added
- **Module 1: Resume Upload & Parsing Engine** — Support for PDF, DOCX, JPG, PNG, and TXT raw text parsing.
- **Module 2: Resume Intelligence Graph** — Experience taxonomy, career trajectory, and skill graph mapping.
- **Module 3: Design Preservation Engine** — Abstraction of presentation specifications from canonical content.
- **Module 4: Executive AI Career Assistant** — Proactive recommendations, live chat, recruiter perspective review, and 1-click JD matcher.
- **Module 5: Cognitive Thinking Engine** — Intent classification and section-scoped edit planning (`EditPlan`).
- **Module 6: Differential Patch Engine** — Git-style section-scoped differential patching (`PatchResult`).
- **Module 7: AI Resume Guardian** — 5-stage safety validation gate with SHA-256 signatures.
- **Module 8: Multi-Dimensional Health Engine** — 13-dimension health scoring (ATS compatibility, recruiter impact, action verbs, timeline consistency).
- **Module 9: Real-Time Rendering Engine** — Layout stability scoring, SHA-256 fingerprinting, ReportLab PDF export, and python-docx DOCX export.
- **Module 10: Multi-Version Control & Time-Travel Engine** — SQLite (`db.sqlite3`) persistence (`version_commits` table), visual diffing, read-only time travel preview, and non-destructive rollbacks.
- **Enterprise Infrastructure & Security** — Dockerfile, docker-compose.yml, render.yaml, Bearer Session Auth, IP sliding-window rate limiter (HTTP 429), secure HTTP headers (`HSTS`, `nosniff`, `DENY`), and SQLite WAL Mode with B-tree indexes.
- **CI/CD Pipeline** — GitHub Actions workflow for Python unit tests, Flutter code analysis, Docker image build, and Render deployment.
