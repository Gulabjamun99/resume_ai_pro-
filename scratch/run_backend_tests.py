# scratch/run_backend_tests.py
import unittest
import sys, os

sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "backend")))
from test_pipeline import (
    test_health_check,
    test_cognitive_plan_endpoint,
    test_differential_patch_endpoint,
    test_guardian_validate_endpoint,
    test_health_report_endpoint,
    test_render_document_endpoint,
    test_version_lifecycle_and_sqlite_persistence,
    setup_function
)
from test_milestone2 import (
    test_session_auth_lifecycle,
    test_rate_limiting_enforcement,
    test_concurrent_api_requests,
    test_invalid_payload_rejection,
    test_guardian_hallucination_rejection,
    test_binary_download_integrity
)

def run():
    print("=" * 80)
    print("MILESTONE 1 & 2 PRODUCTION HARDENING BACKEND TEST SUITE")
    print("=" * 80)

    tests = [
        ("Health Check Endpoint", test_health_check),
        ("Cognitive Plan Endpoint (/api/cognitive-plan)", test_cognitive_plan_endpoint),
        ("Differential Patch Endpoint (/api/differential-patch)", test_differential_patch_endpoint),
        ("Guardian Validate Endpoint (/api/guardian-validate)", test_guardian_validate_endpoint),
        ("Health Report Endpoint (/api/health-report)", test_health_report_endpoint),
        ("Render Document Endpoint (/api/render-document)", test_render_document_endpoint),
        ("Version Control Lifecycle & SQLite Persistence", test_version_lifecycle_and_sqlite_persistence),
        ("Bearer Token Auth & Session Management", test_session_auth_lifecycle),
        ("API Rate Limiting Enforcement (HTTP 429)", test_rate_limiting_enforcement),
        ("Multi-Threaded Concurrency Handling", test_concurrent_api_requests),
        ("Invalid Payload & Input Sanitization", test_invalid_payload_rejection),
        ("Guardian Hallucination Rejection Gate", test_guardian_hallucination_rejection),
        ("Real PDF & DOCX Binary Stream Integrity", test_binary_download_integrity)
    ]



    passed = 0
    failed = 0

    for name, test_fn in tests:
        setup_function()
        try:
            test_fn()
            print(f"  [PASS] {name:<55}")
            passed += 1
        except Exception as e:
            print(f"  [FAIL] {name:<55} Error: {e}")
            failed += 1

    print("=" * 80)
    print(f"TOTAL: {len(tests)} | PASSED: {passed} | FAILED: {failed}")
    print("=" * 80)
    if failed > 0:
        sys.exit(1)

if __name__ == "__main__":
    run()
