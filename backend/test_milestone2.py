# backend/test_milestone2.py
"""
Milestone 2 Security & Reliability Test Suite
Tests:
1. User Session Auth (POST /api/auth/session & GET /api/auth/verify)
2. API Rate Limiting (60 requests/min limit triggering HTTP 429)
3. Concurrent multi-threaded API calls to SQLite backend
4. Structured logging and error response structures
"""
import sys, os, time, concurrent.futures
from fastapi.testclient import TestClient

sys.path.insert(0, os.path.abspath(os.path.dirname(__file__)))
from main import app, _rate_limit_store

client = TestClient(app)

def test_session_auth_lifecycle():
    # 1. Create session
    resp = client.post("/api/auth/session", json={"user_email": "candidate@tech.com"})
    assert resp.status_code == 200
    data = resp.json()
    assert data["success"] is True
    token = data["session_token"]
    assert token.startswith("sess_")

    # 2. Verify with valid token
    headers = {"Authorization": f"Bearer {token}"}
    v_resp = client.get("/api/auth/verify", headers=headers)
    assert v_resp.status_code == 200
    assert v_resp.json()["valid"] is True
    assert v_resp.json()["user_email"] == "candidate@tech.com"

    # 3. Verify with invalid token
    bad_resp = client.get("/api/auth/verify", headers={"Authorization": "Bearer invalid_token"})
    assert bad_resp.status_code == 401

def test_rate_limiting_enforcement():
    _rate_limit_store.clear()
    ip_key = "127.0.0.1"

    # Send 60 requests (allowed)
    for _ in range(60):
        r = client.post("/api/cognitive-plan", json={
            "user_prompt": "test",
            "resume_data": {"summary": "test"}
        })
        assert r.status_code == 200

    # 61st request should trigger HTTP 429
    r_over = client.post("/api/cognitive-plan", json={
        "user_prompt": "test",
        "resume_data": {"summary": "test"}
    })
    assert r_over.status_code == 429
    assert "Rate limit exceeded" in r_over.json()["detail"]

    # Clear for subsequent tests
    _rate_limit_store.clear()

def test_concurrent_api_requests():
    _rate_limit_store.clear()
    
    def make_request(i):
        payload = {
            "user_prompt": f"Edit prompt {i}",
            "resume_data": {"personal": {"name": f"User {i}"}, "summary": "test"}
        }
        return client.post("/api/cognitive-plan", json=payload)

    # 10 concurrent threads hitting FastAPI
    with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
        futures = [executor.submit(make_request, i) for i in range(10)]
        results = [f.result() for f in concurrent.futures.as_completed(futures)]

    assert len(results) == 10
    assert all(r.status_code == 200 for r in results)
    _rate_limit_store.clear()

def test_invalid_payload_rejection():
    # Invalid email address in session creation
    resp = client.post("/api/auth/session", json={"user_email": "notanemail"})
    assert resp.status_code == 400

    # Missing authorization header in session verification
    resp_v = client.get("/api/auth/verify")
    assert resp_v.status_code == 401

def test_guardian_hallucination_rejection():
    import ai_provider
    orig = {"personal": {"name": "Alice"}, "experience": [{"co": "Google", "des": "Engineer"}]}
    tampered_patch = {
        "patch_id": "p_fake",
        "affected_sections": ["experience"],
        "after_snapshot": {"experience": []},
        "patch_operations": [{"after_state": "fake company"}]
    }
    
    val = ai_provider.validate_resume_patch(orig, tampered_patch)
    assert val["rollback_required"] is True or val["guardian_status"] == "REJECTED"



def test_binary_download_integrity():
    payload = {
        "resume_data": {"personal": {"name": "Test Download", "role": "Architect"}},
        "format": "pdf"
    }
    res_pdf = client.post("/download/pdf", json=payload)
    assert res_pdf.status_code == 200
    assert res_pdf.content.startswith(b"%PDF-")

    res_doc = client.post("/download/doc", json={"resume_data": payload["resume_data"], "format": "doc"})
    assert res_doc.status_code == 200
    assert res_doc.content.startswith(b"PK\x03\x04")

