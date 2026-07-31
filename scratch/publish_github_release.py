import os, httpx, json

TOKEN = os.getenv("GITHUB_TOKEN", "")
REPO = "Gulabjamun99/resume_ai_pro-"
TAG = "v1.0.0-rc1"
TITLE = "ResumeAI Pro v1.0.0-rc1 — Release Candidate 1"

headers = {
    "Authorization": f"token {TOKEN}",
    "Accept": "application/vnd.github.v3+json"
}

notes_path = r"d:\ohara works\ResumeAI_Pro\resume_ai_clean\RELEASE_NOTES_v1.0.md"
with open(notes_path, "r", encoding="utf-8") as f:
    body_text = f.read()

# 1. Create GitHub Release
release_url = f"https://api.github.com/repos/{REPO}/releases"
payload = {
    "tag_name": TAG,
    "target_commitish": "main",
    "name": TITLE,
    "body": body_text,
    "draft": False,
    "prerelease": True
}

print(f"Creating GitHub Release for tag '{TAG}'...")
res = httpx.post(release_url, headers=headers, json=payload, timeout=30.0)

if res.status_code not in (200, 201):
    print(f"Release creation status {res.status_code}: {res.text}")
    res_existing = httpx.get(f"{release_url}/tags/{TAG}", headers=headers)
    if res_existing.status_code == 200:
        release_data = res_existing.json()
    else:
        raise Exception(f"Failed to create or fetch release: {res.text}")
else:
    release_data = res.json()

upload_url_template = release_data["upload_url"]
upload_base = upload_url_template.split("{")[0]
html_url = release_data.get("html_url")
print(f"Release created successfully: {html_url}")
