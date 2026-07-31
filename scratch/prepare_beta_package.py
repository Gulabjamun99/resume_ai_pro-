import json, os

assets = {
    "app_name": "ResumeAI Pro — ATS Resume Builder",
    "short_description": "Build ATS-optimized, job-tailored resumes in minutes with AI Guardian safety & version history.",
    "full_description": """ResumeAI Pro is an enterprise-grade ATS resume intelligence platform designed for job seekers.

KEY FEATURES:
• ATS Optimization (90+ ATS Compatibility Score)
• AI Guardian Gate (5-stage anti-hallucination validation)
• Job Description Tailoring (Align bullets to target JD)
• Time-Travel Version History (SQLite-persisted diffs & non-destructive rollback)
• Binary PDF & Editable DOCX Download
• Conversational Live Assistant (Edit sections via Hinglish/English chat)
• Recruiter & Executive Impression Audits

PRIVACY & DATA SAFETY:
• Strict TLS/HTTPS Encryption
• Zero Data Monetization
• Non-Destructive Data Ownership""",
    "category": "Productivity / Business",
    "content_rating": "Everyone",
    "privacy_policy_url": "https://resume-ai-backend-85zs.onrender.com/privacy",
    "target_sdk": 34,
    "min_sdk": 21
}

with open(r"d:\ohara works\ResumeAI_Pro\resume_ai_clean\play_store_metadata.json", "w", encoding="utf-8") as f:
    json.dump(assets, f, indent=2)

print("Play Store metadata generated successfully!")
