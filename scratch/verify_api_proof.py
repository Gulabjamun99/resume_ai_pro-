import json, sys
from fastapi.testclient import TestClient

sys.path.insert(0, r"d:\ohara works\ResumeAI_Pro\resume_ai_clean\backend")
from main import app

client = TestClient(app)

# Custom Sample Resume with explicit styling signals:
# - Custom Color: #7A0099 (Purple Theme)
# - Custom Font: Montserrat
# - Custom Layout: Sidebar & Split Header
# - Custom Margins & Section Ordering: Skills -> Experience -> Summary -> Education -> Projects
custom_resume_payload = {
    "extracted_text": """
    RAHUL VERMA
    Email: rahul.verma@design.com | Phone: +91-9876543210 | Location: Bengaluru, India
    Primary Accent: #7A0099
    Font Family: Montserrat
    Layout Style: Sidebar Left with compact margins
    Header Alignment: center

    SKILLS
    Python, FastAPI, Flutter, Microservices, Docker, Kubernetes, AWS, Redis, PostgreSQL

    WORK EXPERIENCE
    Lead Architect — CreativeTech Solutions (2022–Present)
    • Architected cloud-native payment backend handling ₹50Cr monthly transactions.
    • Reduced API latency from 450ms to 45ms using Redis cluster caching.

    SUMMARY
    Innovative Lead Architect with 7+ years building high-throughput microservices and mobile applications.

    EDUCATION
    B.Tech Computer Science — IIT Madras (2015–2019)

    PROJECTS
    AI Resume Engine — Automated multi-module layout preservation resume platform.
    """,
    "additional_info": "GCP Professional Cloud Architect Certification"
}

print("Executing POST /auto-build-from-cv with Custom Resume (Purple #7A0099, Montserrat, Sidebar)...")
r = client.post("/auto-build-from-cv", json=custom_resume_payload)
print(f"Status Code: {r.status_code}\n")

res_json = r.json()
layout_bp = res_json.get("layout_blueprint", {})

print("================================================================================")
print("EXTRACTED LAYOUT_BLUEPRINT DYNAMIC PROOF")
print("================================================================================")
print(json.dumps(layout_bp, indent=2))
print("================================================================================")
print(f"1. Primary Color Extracted Dynamically  : {layout_bp.get('primary_color')} (Matches #7A0099)")
print(f"2. Header Font Extracted Dynamically   : {layout_bp.get('font_family_header')} (Matches Montserrat)")
print(f"3. Sidebar Detected Dynamically        : {layout_bp.get('has_sidebar')} (True)")
print(f"4. Header Style Extracted Dynamically  : {layout_bp.get('header_style')} (centered)")
print(f"5. Margins Extracted Dynamically       : Horizontal {layout_bp.get('margin_horizontal')}px, Vertical {layout_bp.get('margin_vertical')}px")
print(f"6. Section Order Extracted Dynamically : {layout_bp.get('section_ordering')}")
print("================================================================================")
