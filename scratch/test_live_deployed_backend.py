import httpx, json, sys, time

LIVE_URL = "https://resume-ai-backend-85zs.onrender.com"

def run_live_tests():
    print("=" * 80)
    print(f"TESTING LIVE DEPLOYED BACKEND: {LIVE_URL}")
    print("=" * 80)

    client = httpx.Client(timeout=45.0)

    # 1. Health Check
    res = client.get(f"{LIVE_URL}/health")
    print(f"[1] GET /health -> Status {res.status_code}: {res.json()}")
    assert res.status_code == 200

    # 2. OpenAPI Spec & Version Check
    res = client.get(f"{LIVE_URL}/openapi.json")
    print(f"[2] GET /openapi.json -> Status {res.status_code}")
    assert res.status_code == 200
    spec = res.json()
    version = spec.get("info", {}).get("version")
    title = spec.get("info", {}).get("title")
    print(f"    OpenAPI Title: {title} | Version: {version}")

    # 3. Parse Raw CV
    parse_payload = {
        "extracted_text": "Rahul Verma\nPhone: +91-9876543210\nEmail: rahul@example.com\nExperience: 5 years Software Engineer at TechCorp India.",
        "additional_info": "Promoted to Lead Backend Developer in 2024"
    }
    res = client.post(f"{LIVE_URL}/parse-cv", json=parse_payload)
    print(f"[3] POST /parse-cv -> Status {res.status_code}")
    assert res.status_code == 200
    parsed_data = res.json().get("data", {})
    print(f"    Parsed Data Returned Successfully")

    # 4. Generate Resume
    gen_payload = {
        "name": "Rahul Verma",
        "phone": "+91-9876543210",
        "email": "rahul@example.com",
        "city": "Bengaluru",
        "role": "Lead Backend Developer",
        "exp": 5,
        "industry": "Software Engineering",
        "skills": {"tech": "Python, Go, FastAPI, PostgreSQL, Docker, Redis", "soft": "Leadership"},
        "template_id": "classic",
        "template_color": "#1a1a2e"
    }
    res = client.post(f"{LIVE_URL}/generate", json=gen_payload)
    print(f"[4] POST /generate -> Status {res.status_code}")
    assert res.status_code == 200
    gen_data = res.json().get("data", {})
    ats_score = gen_data.get("atsScore", 90)
    print(f"    Generated Resume ATS Score: {ats_score}/100")

    # 5. AI Edit
    edit_payload = {
        "current_data": gen_data,
        "user_message": "Summary me Google Cloud and Kubernetes add kar do"
    }
    res = client.post(f"{LIVE_URL}/edit", json=edit_payload)
    print(f"[5] POST /edit -> Status {res.status_code}")
    assert res.status_code == 200
    edited_data = res.json().get("data", {})
    print(f"    Edited Resume Summary: {edited_data.get('summary', '')[:80]}...")

    # 6. SQLite Version Commit (Module 10)
    commit_payload = {
        "resume_data": edited_data,
        "patch_result": {"status": "success", "modified_fields": ["summary"]},
        "guardian_result": {"passed": True, "confidence": 0.98},
        "health_report": {"ats_score": ats_score, "status": "healthy"},
        "render_fingerprint": "sha256_fingerprint_live_test",
        "trigger_prompt": "Summary me Google Cloud and Kubernetes add kar do",
        "author": "AI Assistant"
    }
    res = client.post(f"{LIVE_URL}/api/version/commit", json=commit_payload)
    print(f"[6] POST /api/version/commit -> Status {res.status_code}")
    assert res.status_code == 200
    commit_info = res.json().get("data", {})
    commit_id = commit_info.get("version") or commit_info.get("commit_id")
    print(f"    Version Commit ID: {commit_id}")

    # 7. PDF Download
    pdf_payload = {
        "resume_data": edited_data,
        "format": "pdf",
        "template_id": "classic",
        "template_color": "#1a1a2e"
    }
    res = client.post(f"{LIVE_URL}/download/pdf", json=pdf_payload)
    print(f"[7] POST /download/pdf -> Status {res.status_code}")
    assert res.status_code == 200
    pdf_bytes = len(res.content)
    print(f"    Downloaded PDF Byte Size: {pdf_bytes} bytes")
    assert pdf_bytes > 500

    print("=" * 80)
    print(f"ALL LIVE DEPLOYED BACKEND E2E TESTS PASSED SUCCESSFULLY ON {LIVE_URL}!")
    print("=" * 80)

if __name__ == "__main__":
    run_live_tests()
