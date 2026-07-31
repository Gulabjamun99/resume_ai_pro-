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

def run():
    print("=" * 80)
    print("MILESTONE 1 BACKEND TEST SUITE")
    print("=" * 80)

    tests = [
        ("Health Check Endpoint", test_health_check),
        ("Cognitive Plan Endpoint (/api/cognitive-plan)", test_cognitive_plan_endpoint),
        ("Differential Patch Endpoint (/api/differential-patch)", test_differential_patch_endpoint),
        ("Guardian Validate Endpoint (/api/guardian-validate)", test_guardian_validate_endpoint),
        ("Health Report Endpoint (/api/health-report)", test_health_report_endpoint),
        ("Render Document Endpoint (/api/render-document)", test_render_document_endpoint),
        ("Version Control Lifecycle & SQLite Persistence", test_version_lifecycle_and_sqlite_persistence)
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
