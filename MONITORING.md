# Post-Launch Monitoring & Operations Guide — ResumeAI Pro

This document specifies the operational runbooks, backup schedules, and monitoring checklists for production operations.

---

## 📊 1. Production Monitoring Checklist

### A. Error Monitoring (Sentry / Structured Logs)
- [ ] Monitor Python backend structured JSON logs for HTTP 500 error spikes.
- [ ] Track exception rates in `/parse-cv`, `/download/pdf`, and `/download/doc`.
- [ ] Verify `user_sessions` authentication failure logs (`HTTP 401`).

### B. Performance Monitoring
- [ ] Maintain response latency SLA:
  - Backend API processing: `< 10 ms`
  - PDF export generation: `< 250 ms`
  - DOCX export generation: `< 150 ms`
- [ ] Alert on API sliding window rate limiting spikes (`HTTP 429 > 100/min`).

### C. Database Backup & Maintenance
- [ ] **SQLite Daily Snapshot Backup**:
  ```bash
  # Cron job running daily at midnight:
  sqlite3 /app/db.sqlite3 ".backup /app/backups/db_$(date +%Y%m%d).sqlite3"
  ```
- [ ] Check SQLite WAL checkpointing status (`PRAGMA wal_checkpoint(PASSIVE);`).

### D. Security Auditing
- [ ] Monitor CORS violation logs and unauthorized Bearer token attempts.
- [ ] Weekly review of `user_sessions` and `payments` table growth.

---

## 📈 2. Operational Dashboards & Metrics

1. **Active Session Dashboard**: Total active user session count (`SELECT COUNT(*) FROM user_sessions`).
2. **Version Control Commit Velocity**: Total resume versions generated (`SELECT COUNT(*) FROM version_commits`).
3. **Export Volume Metric**: Daily PDF vs DOCX download request counts.
