# OpenAPI Contract Audit — ResumeAI Pro (v1.0)

> **Audit Date**: 2026-07-31  
> **API Version**: 1.0.0  
> **Format**: REST JSON & Binary Media Streams  

---

## 📋 Complete Endpoint Specification

### 1. `POST /api/auth/session`
- **Description**: Issue a new Bearer Session Token for candidate email.
- **Request Body**: `{"user_email": "candidate@domain.com"}`
- **Success Response (200 OK)**: `{"success": true, "session_token": "sess_...", "user_email": "..."}`
- **Error Response (400 Bad Request)**: `{"detail": "Invalid email address"}`

### 2. `GET /api/auth/verify`
- **Description**: Verify Bearer Token validity.
- **Header**: `Authorization: Bearer <session_token>`
- **Success Response (200 OK)**: `{"valid": true, "session_token": "...", "user_email": "..."}`
- **Error Response (401 Unauthorized)**: `{"detail": "Invalid or expired session token"}`

### 3. `POST /upload-cv`
- **Description**: Extract raw text from uploaded resume file.
- **Content-Type**: `multipart/form-data` (`file`)
- **Success Response (200 OK)**: `{"success": true, "extracted_text": "..."}`
- **Error Response (400 / 422)**: File empty, > 10MB, or unsupported format.

### 4. `POST /parse-cv`
- **Description**: Parse raw text into structured JSON.
- **Request Body**: `{"extracted_text": "...", "additional_info": "..."}`
- **Success Response (200 OK)**: `{"success": true, "data": { ... }}`

### 5. `POST /api/cognitive-plan`
- **Description**: Module 5 Edit Intent Planning.
- **Request Body**: `{"user_prompt": "...", "resume_data": { ... }}`
- **Success Response (200 OK)**: `{"success": true, "plan": { ... }}`

### 6. `POST /api/differential-patch`
- **Description**: Module 6 Section-Scoped Patch Generation.
- **Request Body**: `{"edit_plan": { ... }, "original_resume": { ... }}`
- **Success Response (200 OK)**: `{"success": true, "patch": { ... }}`

### 7. `POST /api/guardian-validate`
- **Description**: Module 7 AI Resume Guardian 5-Stage Validation.
- **Request Body**: `{"original_data": { ... }, "patch_result": { ... }}`
- **Success Response (200 OK)**: `{"success": true, "validation": { ... }}`

### 8. `POST /api/health-report`
- **Description**: Module 8 Multi-Dimensional Health Scoring.
- **Request Body**: `{"resume_data": { ... }}`
- **Success Response (200 OK)**: `{"success": true, "health_report": { ... }}`

### 9. `POST /api/render-document`
- **Description**: Module 9 Render Fingerprinting & Layout Stability.
- **Request Body**: `{"resume_data": { ... }}`
- **Success Response (200 OK)**: `{"success": true, "render_report": { ... }}`

### 10. `POST /api/version/commit`
- **Description**: Module 10 Commit Version to SQLite DB.
- **Request Body**: `{"resume_data": { ... }, "patch_result": { ... }, "guardian_result": { ... }, "health_report": { ... }, "render_fingerprint": "..."}`
- **Success Response (200 OK)**: `{"success": true, "commit": { ... }}`

### 11. `GET /api/version/list`
- **Description**: List version commits from SQLite DB.
- **Success Response (200 OK)**: `{"success": true, "versions": [ ... ], "total": 3}`

### 12. `POST /api/version/diff`
- **Description**: Visual Diff between any two versions.
- **Request Body**: `{"version_a_index": 0, "version_b_index": 1}`
- **Success Response (200 OK)**: `{"success": true, "diff": { ... }}`

### 13. `POST /api/version/rollback`
- **Description**: Non-destructive rollback restoring previous state.
- **Request Body**: `{"target_version_index": 0}`
- **Success Response (200 OK)**: `{"success": true, "commit": { ... }}`

### 14. `POST /api/version/preview`
- **Description**: Read-only time travel preview.
- **Request Body**: `{"version_index": 0}`
- **Success Response (200 OK)**: `{"success": true, "preview": { ... }}`

### 15. `POST /download/pdf`
- **Description**: Download real binary PDF document.
- **Response**: `application/pdf` binary stream.

### 16. `POST /download/doc`
- **Description**: Download real binary DOCX document.
- **Response**: `application/vnd.openxmlformats-officedocument.wordprocessingml.document` binary stream.
