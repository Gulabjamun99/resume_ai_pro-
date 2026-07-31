# Database Schema & Persistence Specification — ResumeAI Pro (v1.0)

Database: **SQLite 3**  
Database File: `backend/db.sqlite3`

---

## 🗄️ Database Tables

### 1. `version_commits` (Version Control & Snapshot Store)

Stores every accepted, Guardian-certified resume modification as an immutable commit.

```sql
CREATE TABLE IF NOT EXISTS version_commits (
    version_index INTEGER PRIMARY KEY,
    version_id TEXT NOT NULL,
    parent_version_index INTEGER NOT NULL,
    timestamp TEXT NOT NULL,
    author TEXT NOT NULL,
    trigger_prompt TEXT NOT NULL,
    commit_message TEXT NOT NULL,
    patch_id TEXT NOT NULL,
    guardian_validation_id TEXT NOT NULL,
    guardian_signature TEXT NOT NULL,
    render_fingerprint TEXT NOT NULL,
    health_report_id TEXT NOT NULL,
    ats_score REAL NOT NULL,
    recruiter_score REAL NOT NULL,
    overall_health_score REAL NOT NULL,
    differential_snapshot TEXT NOT NULL,
    full_resume_snapshot TEXT NOT NULL,
    audit_trail TEXT NOT NULL
);
```

### 2. `user_sessions` (Session Authentication & User Tracking)

Stores active candidate sessions for Bearer Token authentication.

```sql
CREATE TABLE IF NOT EXISTS user_sessions (
    session_token TEXT PRIMARY KEY,
    user_email TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 3. `payments` (Payment Verification & Monetization Logs)

Stores bank UTR transaction verification records.

```sql
CREATE TABLE IF NOT EXISTS payments (
    utr TEXT PRIMARY KEY,
    amount INTEGER,
    status TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
