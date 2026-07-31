# Database Hardening & Schema Audit — ResumeAI Pro (v1.0)

> **Audit Date**: 2026-07-31  
> **Database**: SQLite 3 (`backend/db.sqlite3`)  
> **Status**: ✅ **VERIFIED & HARDENED**  

---

## 🗄️ 1. Database Architecture & Mode Verification

| Setting | Value | Purpose | Status |
|---------|-------|---------|--------|
| **Engine** | SQLite 3 | Embedded persistent database | Verified ✅ |
| **Journal Mode** | **WAL (Write-Ahead Logging)** | High-concurrency reads & non-blocking commits | Verified ✅ |
| **Row Factory** | `sqlite3.Row` | Named dictionary access per row | Verified ✅ |
| **Auto Vacuum** | Default | Prevents database file fragmentation | Verified ✅ |

---

## 📊 2. Table Schemas & Indexes

### A. Table `version_commits`
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

CREATE INDEX IF NOT EXISTS idx_version_commits_id ON version_commits(version_id);
```

### B. Table `user_sessions`
Stores active user session tokens.

```sql
CREATE TABLE IF NOT EXISTS user_sessions (
    session_token TEXT PRIMARY KEY,
    user_email TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_user_sessions_token ON user_sessions(session_token);
```

### C. Table `payments`
Stores bank UTR transaction verification logs.

```sql
CREATE TABLE IF NOT EXISTS payments (
    utr TEXT PRIMARY KEY,
    amount INTEGER,
    status TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_payments_utr ON payments(utr);
```

---

## 🐘 3. PostgreSQL Migration Readiness Plan

For enterprise cloud deployments requiring multi-region database scaling, the SQLite tables map 1-to-1 to PostgreSQL:

1. Replace `INTEGER PRIMARY KEY` with `SERIAL PRIMARY KEY` or `BIGSERIAL`.
2. Replace `TEXT` JSON fields (`differential_snapshot`, `full_resume_snapshot`, `audit_trail`) with PostgreSQL native `JSONB` data types.
3. Migrate `sqlite3` connection factory to `psycopg2` or `asyncpg` with SQLAlchemy ORM.
