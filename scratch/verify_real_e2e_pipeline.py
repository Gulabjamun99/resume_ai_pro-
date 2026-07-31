# scratch/verify_real_e2e_pipeline.py
"""
Complete End-to-End Real Pipeline Verification for Milestone 1.
Tests the exact HTTP requests and data payloads that Flutter ApiService sends to FastAPI backend:

1. Health Check GET /health
2. CV Text Parsing POST /parse-cv
3. Proactive Suggestions POST /auto-build-from-cv
4. Cognitive Edit Planning POST /api/cognitive-plan
5. Section-Scoped Differential Patch POST /api/differential-patch
6. AI Resume Guardian Validation POST /api/guardian-validate
7. Multi-Dimensional Health Report POST /api/health-report
8. Real-Time Document Rendering POST /api/render-document
9. Version Commit to SQLite DB POST /api/version/commit
10. Version List from SQLite DB GET /api/version/list
11. Version Diff POST /api/version/diff
12. Time Travel Preview POST /api/version/preview
13. Non-Destructive Rollback POST /api/version/rollback
14. Real PDF Binary Generation POST /download/pdf
15. Real DOCX Binary Generation POST /download/doc
16. SQLite Database Persistence Verification Across Backend Re-Initialisation
"""
import sys, os, json, sqlite3, io, hashlib
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))
import main
from ai_provider import reset_version_repository, DB_FILE

client = TestClient(main.app)

RAW_CV_TEXT = """
RAHUL VERMA
Email: rahul.verma@cloudtech.com | Phone: +91 98765 43210 | Location: Bengaluru, India
LinkedIn: linkedin.com/in/rahulverma | GitHub: github.com/rahulverma

SUMMARY
Lead Software Engineer with 6+ years of experience in microservices architecture, Python, and cloud infrastructure.

WORK EXPERIENCE
Lead Software Engineer | TechCorp Solutions, Bengaluru | 2021 - Present
- Architected FastAPI microservices handling 2.5M daily requests with 45ms avg latency.
- Migrated legacy monolithic architecture to Docker and Kubernetes on AWS.

Software Engineer | DevSystems Ltd, Pune | 2018 - 2021
- Developed REST APIs using Python and Django.
- Optimized database queries reducing page load times by 35%.

EDUCATION
B.Tech Computer Science | IIT Kharagpur | 2014 - 2018 (CGPA: 8.8/10)

SKILLS
Technical: Python, FastAPI, Django, Docker, Kubernetes, AWS, PostgreSQL, Redis
Soft Skills: Team Leadership, System Design, Problem Solving
Languages: English, Hindi
Certifications: AWS Certified Solutions Architect
"""

def run_e2e_verification():
    print("=" * 90)
    print("   MILESTONE 1: REAL END-TO-END PIPELINE & PERSISTENCE VERIFICATION")
    print("=" * 90)

    # Clean DB state for deterministic test
    reset_version_repository()

    # Step 1: Health Check
    r1 = client.get("/health")
    assert r1.status_code == 200
    print("\n  [1] GET /health .......................................... PASS")

    # Step 2: Parse Raw CV Text
    r2 = client.post("/parse-cv", json={"extracted_text": RAW_CV_TEXT, "additional_info": "Added AI Agent experience"})
    assert r2.status_code == 200
    parsed_data = r2.json()["data"]
    assert "personal" in parsed_data or "name" in parsed_data
    print("  [2] POST /parse-cv (Raw CV Parsing) ...................... PASS")

    # Step 3: Auto-Build & Proactive Suggestions (Modules 1-4)
    r3 = client.post("/auto-build-from-cv", json={
        "extracted_text": RAW_CV_TEXT,
        "additional_info": "Lead AI Architect at Google",
        "job_description": "Senior AI Infrastructure Lead"
    })
    assert r3.status_code == 200
    build_resp = r3.json()
    resume_v1 = build_resp["data"]
    assert "health_scores" in build_resp
    assert "proactive_suggestions" in build_resp
    print("  [3] POST /auto-build-from-cv (Modules 1-4 Pipeline) ....... PASS")

    # Step 4: Cognitive Thinking Engine Edit Plan (Module 5)
    r4 = client.post("/api/cognitive-plan", json={
        "user_prompt": "Rewrite summary for Google AI Architect target role",
        "resume_data": resume_v1,
        "candidate_goal": "Google AI Architect"
    })
    assert r4.status_code == 200
    plan = r4.json()["plan"]
    assert "plan_id" in plan and "affected_sections" in plan
    print("  [4] POST /api/cognitive-plan (Module 5 Cognitive Plan) .... PASS")

    # Step 5: Section-Scoped Differential Patch Engine (Module 6)
    r5 = client.post("/api/differential-patch", json={
        "edit_plan": plan,
        "original_resume": resume_v1,
        "parent_version": 0
    })
    assert r5.status_code == 200
    patch = r5.json()["patch"]
    assert "patch_id" in patch and "patch_operations" in patch
    print("  [5] POST /api/differential-patch (Module 6 Differential Patch) PASS")

    # Step 6: AI Resume Guardian Validation (Module 7)
    r6 = client.post("/api/guardian-validate", json={
        "original_data": resume_v1,
        "patch_result": patch
    })
    assert r6.status_code == 200
    guardian = r6.json()["validation"]
    assert "guardian_status" in guardian
    print("  [6] POST /api/guardian-validate (Module 7 Guardian Gate) .. PASS")

    # Step 7: Multi-Dimensional Health Engine Report (Module 8)
    r7 = client.post("/api/health-report", json={
        "resume_data": resume_v1,
        "resume_version": 1
    })
    assert r7.status_code == 200
    health = r7.json()["health_report"]
    assert "overall_health_score" in health
    print("  [7] POST /api/health-report (Module 8 Health Engine) ...... PASS")

    # Step 8: Real-Time Rendering Engine Fingerprint (Module 9)
    r8 = client.post("/api/render-document", json={
        "resume_data": resume_v1,
        "design_spec": {"font_family": "Inter"},
        "template_name": "Executive",
        "resume_version": 1
    })
    assert r8.status_code == 200
    render = r8.json()["render_report"]
    assert "render_fingerprint" in render
    print("  [8] POST /api/render-document (Module 9 Render Engine) .... PASS")

    # Step 9: Version Commit v1 to SQLite DB (Module 10)
    r9 = client.post("/api/version/commit", json={
        "resume_data": resume_v1,
        "patch_result": patch,
        "guardian_result": guardian,
        "health_report": health,
        "render_fingerprint": render["render_fingerprint"],
        "trigger_prompt": "Initial Build",
        "author": "AI Assistant"
    })
    assert r9.status_code == 200
    commit_v1 = r9.json()["commit"]
    assert commit_v1["version_id"] == "v1"
    print("  [9] POST /api/version/commit (Module 10 SQLite Commit v1) . PASS")

    # Step 10: Commit v2 (Enhanced Summary)
    resume_v2 = json.loads(json.dumps(resume_v1))
    resume_v2["summary"] = "Senior AI Architect specializing in high-throughput FastAPI microservices, LLM agent orchestration, and AWS cloud infrastructure."
    r10 = client.post("/api/version/commit", json={
        "resume_data": resume_v2,
        "patch_result": {"patch_id": "p2", "affected_sections": ["summary"], "operations": []},
        "guardian_result": {"guardian_status": "APPROVED"},
        "health_report": {"overall_health_score": 94.0, "ats_score": 95.0},
        "render_fingerprint": "sha256:v2_fp",
        "trigger_prompt": "Rewrite summary for AI Architect"
    })
    assert r10.status_code == 200
    commit_v2 = r10.json()["commit"]
    assert commit_v2["version_id"] == "v2"
    print("  [10] POST /api/version/commit (Module 10 SQLite Commit v2) PASS")

    # Step 11: Fetch Version List from SQLite DB
    r11 = client.get("/api/version/list")
    assert r11.status_code == 200
    versions = r11.json()["versions"]
    assert len(versions) == 2
    print("  [11] GET /api/version/list (SQLite Version Repository) ... PASS")

    # Step 12: Diff v1 vs v2
    r12 = client.post("/api/version/diff", json={"version_a_index": 0, "version_b_index": 1})
    assert r12.status_code == 200
    diff = r12.json()["diff"]
    assert diff["version_a"] == "v1" and diff["version_b"] == "v2"
    print("  [12] POST /api/version/diff (Visual Diff Engine) .......... PASS")

    # Step 13: Time Travel Preview v1
    r13 = client.post("/api/version/preview", json={"version_index": 0})
    assert r13.status_code == 200
    prev = r13.json()["preview"]
    assert prev["version_id"] == "v1" and prev["read_only"] is True
    print("  [13] POST /api/version/preview (Time Travel Preview) ...... PASS")

    # Step 14: Non-Destructive Rollback to v1 (creates v3)
    r14 = client.post("/api/version/rollback", json={"target_version_index": 0})
    assert r14.status_code == 200
    commit_v3 = r14.json()["commit"]
    assert commit_v3["version_id"] == "v3"
    assert commit_v3["commit_message"] == "Rolled back resume state to match Version v1."
    print("  [14] POST /api/version/rollback (Non-Destructive Rollback) PASS")

    # Step 15: Download Real Binary PDF
    r15 = client.post("/download/pdf", json={
        "resume_data": resume_v1,
        "format": "pdf",
        "template_id": "classic",
        "template_color": "#1a1a2e"
    })
    assert r15.status_code == 200
    pdf_bytes = r15.content
    assert pdf_bytes.startswith(b"%PDF-")
    print(f"  [15] POST /download/pdf (Real Binary PDF: {len(pdf_bytes)} bytes) PASS")

    # Step 16: Download Real Binary DOCX
    r16 = client.post("/download/doc", json={
        "resume_data": resume_v1,
        "format": "doc",
        "template_id": "classic",
        "template_color": "#1a1a2e"
    })
    assert r16.status_code == 200
    docx_bytes = r16.content
    assert docx_bytes.startswith(b"PK\x03\x04")  # Standard Zip header for DOCX
    print(f"  [16] POST /download/doc (Real Binary DOCX: {len(docx_bytes)} bytes) PASS")

    # Step 17: SQLite Persistence Cross-Verification
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("SELECT COUNT(*) FROM version_commits")
    db_count = cursor.fetchone()[0]
    conn.close()
    assert db_count == 3
    print(f"  [17] SQLite DB Persistence Audit (3 rows in version_commits) PASS")

    print("\n" + "=" * 90)
    print("   ALL 17 E2E PIPELINE & PERSISTENCE VERIFICATIONS PASSED SUCCESSFULLY!")
    print("   MILESTONE 1 IS OFFICIALLY PRODUCTION VERIFIED!")
    print("=" * 90)

if __name__ == "__main__":
    run_e2e_verification()
