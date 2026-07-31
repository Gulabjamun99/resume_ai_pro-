# Contributing Guidelines — ResumeAI Pro

Thank you for your interest in contributing to ResumeAI Pro!

---

## 🛠️ Local Development Setup

1. **Clone Repository**:
   ```bash
   git clone https://github.com/Gulabjamun99/resume_ai_pro-.git
   cd resume_ai_pro-
   ```

2. **Backend Setup**:
   ```bash
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```

3. **Run Unit Tests & Verification**:
   ```bash
   python scratch/run_backend_tests.py
   python scratch/verify_real_e2e_pipeline.py
   ```

---

## 🧪 Pull Request Guidelines

- All PRs must target the `main` branch.
- Must pass all automated unit and E2E integration tests.
- Code must adhere to PEP 8 for Python and standard Dart conventions for Flutter.
