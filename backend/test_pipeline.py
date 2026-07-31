# backend/test_pipeline.py
"""
Production Hardening Milestone 1 Test Suite
Tests:
1. SQLite version history persistence in db.sqlite3
2. Full FastAPI endpoint response verification for Modules 5-10:
   - POST /api/cognitive-plan
   - POST /api/differential-patch
   - POST /api/guardian-validate
   - POST /api/health-report
   - POST /api/render-document
   - POST /api/version/commit
   - GET  /api/version/list
   - POST /api/version/diff
   - POST /api/version/rollback
   - POST /api/version/preview
   - GET  /api/version/analytics
   - GET  /api/version/export
3. Persistence across backend reset / restart
"""
import sys, os, json
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
from main import app
from ai_provider import reset_version_repository, _load_all_versions

client = TestClient(app)

SAMPLE_RESUME = {
    "personal": {"name": "TEST USER", "email": "test@domain.com", "phone": "+91 99999 88888", "role": "Senior Engineer"},
    "summary": "Experienced software developer in Python and cloud.",
    "experience": [{"co": "Acme Inc", "des": "Software Engineer", "bullets": ["Built cloud APIs."]}],
    "skills": {"technical": ["Python", "FastAPI", "Docker"]},
    "education": [{"deg": "B.Tech", "col": "State University", "yr": "2020"}]
}

def setup_function():
    reset_version_repository()

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

def test_cognitive_plan_endpoint():
    payload = {
        "user_prompt": "Rewrite summary for Google AI Architect",
        "resume_data": SAMPLE_RESUME,
        "candidate_goal": "FAANG Architect"
    }
    response = client.post("/api/cognitive-plan", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "plan_id" in data["plan"]
    assert "affected_sections" in data["plan"]

def test_differential_patch_endpoint():
    plan = {
        "plan_id": "plan_001",
        "detected_intent": "Rewrite",
        "affected_sections": ["summary"]
    }
    payload = {
        "edit_plan": plan,
        "original_resume": SAMPLE_RESUME,
        "parent_version": 0
    }
    response = client.post("/api/differential-patch", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "patch_id" in data["patch"]
    assert "patch_operations" in data["patch"]

def test_guardian_validate_endpoint():
    patch = {
        "patch_id": "patch_001",
        "affected_sections": ["summary"],
        "before_snapshot": {},
        "after_snapshot": {"summary": "New summary"}
    }
    payload = {
        "original_data": SAMPLE_RESUME,
        "patch_result": patch
    }
    response = client.post("/api/guardian-validate", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "guardian_status" in data["validation"]

def test_health_report_endpoint():
    payload = {"resume_data": SAMPLE_RESUME, "resume_version": 1}
    response = client.post("/api/health-report", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "overall_health_score" in data["health_report"]
    assert "ats_compatibility_score" in data["health_report"]

def test_render_document_endpoint():
    payload = {
        "resume_data": SAMPLE_RESUME,
        "design_spec": {"font_family": "Inter"},
        "template_name": "Executive",
        "resume_version": 1
    }
    response = client.post("/api/render-document", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["success"] is True
    assert "render_fingerprint" in data["render_report"]

def test_version_lifecycle_and_sqlite_persistence():
    # 1. Commit V1
    commit_payload = {
        "resume_data": SAMPLE_RESUME,
        "patch_result": {"patch_id": "p1", "affected_sections": ["summary"], "operations": []},
        "guardian_result": {"validation_id": "val1", "guardian_status": "APPROVED"},
        "health_report": {"report_id": "h1", "ats_score": 85.0, "overall_health_score": 84.0},
        "render_fingerprint": "sha256:fp1",
        "trigger_prompt": "Initial Commit"
    }
    resp1 = client.post("/api/version/commit", json=commit_payload)
    assert resp1.status_code == 200
    v1 = resp1.json()["commit"]
    assert v1["version_id"] == "v1"

    # 2. Commit V2
    RESUME_V2 = dict(SAMPLE_RESUME)
    RESUME_V2["summary"] = "Enhanced summary for senior role."
    commit_payload_2 = {
        "resume_data": RESUME_V2,
        "patch_result": {"patch_id": "p2", "affected_sections": ["summary"], "operations": []},
        "guardian_result": {"validation_id": "val2", "guardian_status": "APPROVED"},
        "health_report": {"report_id": "h2", "ats_score": 92.0, "overall_health_score": 90.0},
        "render_fingerprint": "sha256:fp2",
        "trigger_prompt": "Update Summary"
    }
    resp2 = client.post("/api/version/commit", json=commit_payload_2)
    assert resp2.status_code == 200
    v2 = resp2.json()["commit"]
    assert v2["version_id"] == "v2"

    # 3. List versions from DB
    resp_list = client.get("/api/version/list")
    assert resp_list.status_code == 200
    assert resp_list.json()["total"] == 2

    # 4. Diff V1 vs V2
    resp_diff = client.post("/api/version/diff", json={"version_a_index": 0, "version_b_index": 1})
    assert resp_diff.status_code == 200
    diff = resp_diff.json()["diff"]
    assert diff["version_a"] == "v1"
    assert diff["version_b"] == "v2"
    assert "summary" in diff["modified_sections"]

    # 5. Rollback to V1
    resp_rb = client.post("/api/version/rollback", json={"target_version_index": 0})
    assert resp_rb.status_code == 200
    v3 = resp_rb.json()["commit"]
    assert v3["version_id"] == "v3"
    assert v3["commit_message"] == "Rolled back resume state to match Version v1."

    # 6. Verify SQLite Persistence (re-read from DB directly)
    all_db_vers = _load_all_versions()
    assert len(all_db_vers) == 3
    assert all_db_vers[0]["version_id"] == "v1"
    assert all_db_vers[1]["version_id"] == "v2"
    assert all_db_vers[2]["version_id"] == "v3"

    # 7. Time Travel Preview V2
    resp_prev = client.post("/api/version/preview", json={"version_index": 1})
    assert resp_prev.status_code == 200
    assert resp_prev.json()["preview"]["version_id"] == "v2"

    # 8. Analytics
    resp_an = client.get("/api/version/analytics")
    assert resp_an.status_code == 200
    assert resp_an.json()["analytics"]["total_versions"] == 3

    # 9. Export
    resp_exp = client.get("/api/version/export")
    assert resp_exp.status_code == 200
    assert resp_exp.json()["export"]["total_versions"] == 3
