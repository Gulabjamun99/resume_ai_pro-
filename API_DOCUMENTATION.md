# REST API Documentation — ResumeAI Pro Backend (v1.0)

Base URL: `http://localhost:8000` (or configured server host)

---

## 🔑 Authentication & Session API

### 1. Create Session
`POST /api/auth/session`

**Request**:
```json
{
  "user_email": "candidate@domain.com"
}
```

**Response**:
```json
{
  "success": true,
  "session_token": "sess_a1b2c3d4e5f6...",
  "user_email": "candidate@domain.com"
}
```

### 2. Verify Session
`GET /api/auth/verify`  
*Header*: `Authorization: Bearer <session_token>`

**Response**:
```json
{
  "valid": true,
  "session_token": "sess_a1b2c3d4e5f6...",
  "user_email": "candidate@domain.com"
}
```

---

## 📄 Parsing & Building API

### 3. Upload CV File
`POST /upload-cv`  
*Multipart Form File*: `file` (PDF, DOCX, JPG, PNG, TXT)

**Response**:
```json
{
  "success": true,
  "extracted_text": "RAW RESUME TEXT..."
}
```

### 4. Parse CV Text
`POST /parse-cv`

**Request**:
```json
{
  "extracted_text": "RAW RESUME TEXT...",
  "additional_info": "Added AWS certification"
}
```

**Response**:
```json
{
  "success": true,
  "data": { ... }
}
```

---

## 🧠 Cognitive Edit & Guardian API

### 5. Plan Cognitive Edit
`POST /api/cognitive-plan`

**Request**:
```json
{
  "user_prompt": "Rewrite summary for Google AI Architect",
  "resume_data": { ... },
  "candidate_goal": "Google AI Architect"
}
```

### 6. Generate Differential Patch
`POST /api/differential-patch`

**Request**:
```json
{
  "edit_plan": { ... },
  "original_resume": { ... },
  "parent_version": 0
}
```

### 7. Guardian Validation
`POST /api/guardian-validate`

**Request**:
```json
{
  "original_data": { ... },
  "patch_result": { ... }
}
```

---

## 📊 Health & Rendering API

### 8. Health Report
`POST /api/health-report`

### 9. Render Document
`POST /api/render-document`

### 10. Download Binary PDF
`POST /download/pdf` -> Returns `application/pdf` binary stream.

### 11. Download Binary DOCX
`POST /download/doc` -> Returns `application/vnd.openxmlformats-officedocument.wordprocessingml.document` binary stream.

---

## 📜 Version History & Control API

### 12. Commit Version
`POST /api/version/commit`

### 13. List Versions
`GET /api/version/list`

### 14. Diff Versions
`POST /api/version/diff`

### 15. Non-Destructive Rollback
`POST /api/version/rollback`

### 16. Time Travel Preview
`POST /api/version/preview`

### 17. Version Analytics
`GET /api/version/analytics`

### 18. Export Repository
`GET /api/version/export`
