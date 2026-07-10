import os, json, re, io, traceback, sqlite3, httpx
from fastapi import FastAPI, HTTPException, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import StreamingResponse, JSONResponse
from pydantic import BaseModel
from typing import Optional, List
import ai_provider

app = FastAPI(title="ResumeAI Pro Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Read Supabase configuration from environment variables
SUPABASE_URL = os.getenv("SUPABASE_URL", "").strip().rstrip("/")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "").strip()

# ── Database Setup (Zero-Cost Bootstrapping) ──
DB_FILE = os.path.join(os.path.dirname(__file__), "db.sqlite3")

def init_db():
    if SUPABASE_URL and SUPABASE_KEY:
        print("Using Supabase cloud database.")
        return
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS payments (
        utr TEXT PRIMARY KEY,
        amount INTEGER,
        status TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)
    conn.commit()
    conn.close()

init_db()

# AI provider (Gemini / Claude / Groq) is configured via ai_provider.py
# and the AI_PROVIDER environment variable — see that file for details.

# ── Models ──────────────────────────────────────────────
class EduEntry(BaseModel):
    deg: str = ""
    col: str = ""
    yr: str = ""
    grade: str = ""
    honors: str = ""

class WorkEntry(BaseModel):
    co: str = ""
    des: str = ""
    start: str = ""
    end: str = "Present"
    loc: str = ""
    pts: str = ""

class ProjectEntry(BaseModel):
    name: str = ""
    tech: str = ""
    desc: str = ""

class Skills(BaseModel):
    tech: str = ""
    soft: str = ""
    lang: str = ""
    cert: str = ""

class ResumeRequest(BaseModel):
    name: str
    phone: str
    email: str
    city: str = ""
    linkedin: str = ""
    github: str = ""
    role: str
    exp: int = 0
    industry: str = ""
    ctc: str = ""
    summary: str = ""
    edus: List[EduEntry] = []
    works: List[WorkEntry] = []
    skills: Skills = Skills()
    projs: List[ProjectEntry] = []
    extra: str = ""
    template_id: str = "classic"
    template_color: str = "#1a1a2e"

class EditRequest(BaseModel):
    current_data: dict
    user_message: str

class ParseAndMergeRequest(BaseModel):
    extracted_text: str
    additional_info: str = ""  # new experience/skills the user mentioned

class DownloadRequest(BaseModel):
    resume_data: dict
    format: str  # "pdf" or "doc"
    template_id: str = "classic"
    template_color: str = "#1a1a2e"

class JDTailorRequest(BaseModel):
    """Everything needed to build a resume tailored to one specific job posting."""
    job_description: str
    name: str
    phone: str
    email: str
    city: str = ""
    linkedin: str = ""
    github: str = ""
    role: str = ""
    exp: int = 0
    industry: str = ""
    ctc: str = ""
    summary: str = ""
    edus: List[EduEntry] = []
    works: List[WorkEntry] = []
    skills: Skills = Skills()
    projs: List[ProjectEntry] = []
    extra: str = ""
    template_id: str = "classic"
    template_color: str = "#1a1a2e"

class VerifyPaymentRequest(BaseModel):
    utr: str
    amount: int

# ── Health ───────────────────────────────────────────────
@app.get("/health")
def health():
    return {"status": "ok", "message": "ResumeAI Pro backend running"}

# ── Verify Payment ───────────────────────────────────────
@app.post("/verify-payment")
async def verify_payment(req: VerifyPaymentRequest):
    utr = req.utr.strip()
    if len(utr) != 12 or not utr.isdigit():
        raise HTTPException(status_code=400, detail="Invalid UTR. Must be 12 numeric digits.")
    
    if SUPABASE_URL and SUPABASE_KEY:
        headers = {
            "apikey": SUPABASE_KEY,
            "Authorization": f"Bearer {SUPABASE_KEY}",
            "Content-Type": "application/json",
            "Prefer": "return=representation"
        }
        # Query UTR from Supabase
        async with httpx.AsyncClient() as client:
            try:
                r = await client.get(f"{SUPABASE_URL}/rest/v1/payments?utr=eq.{utr}", headers=headers)
                if r.status_code == 200:
                    rows = r.json()
                    if len(rows) > 0:
                        return {"status": "error", "message": "This UTR has already been used."}
                else:
                    raise HTTPException(status_code=500, detail=f"Supabase fetch error: {r.text}")
                
                # Insert UTR into Supabase
                data = {
                    "utr": utr,
                    "amount": req.amount,
                    "status": "approved"
                }
                r_post = await client.post(f"{SUPABASE_URL}/rest/v1/payments", headers=headers, json=data)
                if r_post.status_code != 201:
                    raise HTTPException(status_code=500, detail=f"Supabase insert error: {r_post.text}")
                
                return {"status": "success", "message": "Payment verified successfully"}
            except Exception as e:
                raise HTTPException(status_code=500, detail=f"Database error: {str(e)}")
    else:
        # Local SQLite fallback
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        try:
            cursor.execute("SELECT amount, status FROM payments WHERE utr = ?", (utr,))
            row = cursor.fetchone()
            if row:
                conn.close()
                return {"status": "error", "message": "This UTR has already been used."}
            
            # Insert as approved (Auto-approve for boot-strapping, owner can audit bank logs manually)
            cursor.execute("INSERT INTO payments (utr, amount, status) VALUES (?, ?, ?)", (utr, req.amount, "approved"))
            conn.commit()
            conn.close()
            return {"status": "success", "message": "Payment verified successfully"}
        except Exception as e:
            conn.close()
            raise HTTPException(status_code=500, detail=str(e))

# ── Upload Old CV → Extract Raw Text ─────────────────────
@app.post("/upload-cv")
async def upload_cv(file: UploadFile = File(...)):
    """
    Purana CV upload hota hai (PDF / DOCX / Image).
    Ye route sirf RAW TEXT nikalta hai file se — koi AI call nahi karta yahan.
    Agle step (/parse-cv) mein ye text AI ko bhejke structured data banta hai.
    """
    filename = (file.filename or "").lower()
    content = await file.read()

    if len(content) == 0:
        raise HTTPException(status_code=400, detail="File khali hai")
    if len(content) > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="File 10MB se badi hai")

    extracted_text = ""

    try:
        if filename.endswith(".pdf"):
            import pdfplumber
            with pdfplumber.open(io.BytesIO(content)) as pdf:
                pages_text = []
                for page in pdf.pages:
                    t = page.extract_text()
                    if t:
                        pages_text.append(t)
                extracted_text = "\n".join(pages_text)

            # Agar PDF scanned image hai (text nahi nikla), OCR try karo
            if not extracted_text.strip():
                extracted_text = _ocr_pdf(content)

        elif filename.endswith(".docx"):
            from docx import Document
            doc = Document(io.BytesIO(content))
            paras = [p.text for p in doc.paragraphs if p.text.strip()]
            # Tables bhi padho (kai resumes table format mein hote hain)
            for table in doc.tables:
                for row in table.rows:
                    for cell in row.cells:
                        if cell.text.strip():
                            paras.append(cell.text)
            extracted_text = "\n".join(paras)

        elif filename.endswith((".jpg", ".jpeg", ".png")):
            extracted_text = _ocr_image(content)

        elif filename.endswith(".txt"):
            extracted_text = content.decode("utf-8", errors="ignore")

        else:
            raise HTTPException(status_code=400, detail="Sirf PDF, DOCX, JPG, PNG, TXT supported hai")

        if not extracted_text.strip():
            raise HTTPException(status_code=422, detail="File se text nahi nikal paya. Scanned/blurry image ho sakti hai — clear photo try karo ya manually likho.")

        # Control characters hatao jo JSON ko break kar sakte hain
        extracted_text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', extracted_text)

        return JSONResponse(content={"success": True, "extracted_text": extracted_text.strip()})

    except HTTPException:
        raise
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"File read error: {str(e)}")


def _ocr_image(content: bytes) -> str:
    import pytesseract
    from PIL import Image
    img = Image.open(io.BytesIO(content))
    return pytesseract.image_to_string(img)


def _ocr_pdf(content: bytes) -> str:
    """Scanned PDF ke liye — pages ko image mein convert karke OCR karo"""
    try:
        import pdfplumber
        import pytesseract
        text_parts = []
        with pdfplumber.open(io.BytesIO(content)) as pdf:
            for page in pdf.pages:
                im = page.to_image(resolution=200).original
                text_parts.append(pytesseract.image_to_string(im))
        return "\n".join(text_parts)
    except Exception:
        return ""


# ── Parse Extracted Text → Structured Resume Data (AI) ───
@app.post("/parse-cv")
async def parse_cv(req: ParseAndMergeRequest):
    """
    Raw text (purane CV se) + user ka naya bola hua experience/update —
    dono ko Claude AI ko bhejke ek clean structured JSON banwata hai
    jo seedha frontend form ko pre-fill kar sake.
    """
    prompt = f"""You are an expert resume parser. The user uploaded their OLD resume/CV.
Extract ALL information from the raw text below into clean structured fields.

RAW CV TEXT (extracted from PDF/DOCX/Image, may have formatting issues - fix them):
---
{req.extracted_text}
---

{"ADDITIONAL INFO USER PROVIDED (new experience/skills since this old CV was made - MERGE this in):" if req.additional_info else ""}
{req.additional_info}

INSTRUCTIONS:
1. Extract name, phone, email, city, LinkedIn, GitHub if present
2. Extract target role / current designation
3. Calculate total years of experience from work history dates (estimate if needed)
4. Extract ALL work experience entries with company, designation, dates, location, responsibilities
5. Extract ALL education entries
6. Extract ALL skills (technical, soft, languages, certifications) - split them into separate lists
7. Extract any projects mentioned
8. Extract any achievements/awards/extra info
9. If user provided ADDITIONAL INFO above, merge it intelligently:
   - If it's a new job, add it as the most recent work experience
   - If it's new skills, add them to skills list
   - If it's a new certification, add to certifications
   - If it's general update, incorporate appropriately
10. Clean up any OCR errors or formatting issues in the text
11. If experience years cannot be determined, set to 0 and let user confirm

CRITICAL: Return ONLY valid JSON, no markdown, no explanation. Exact structure:
{{
  "name": "",
  "phone": "",
  "email": "",
  "city": "",
  "linkedin": "",
  "github": "",
  "role": "",
  "exp": 0,
  "industry": "",
  "ctc": "",
  "summary": "",
  "edus": [{{"deg":"","col":"","yr":"","grade":"","honors":""}}],
  "works": [{{"co":"","des":"","start":"","end":"","loc":"","pts":""}}],
  "skills": {{"tech":"comma,separated,skills","soft":"comma,separated","lang":"comma,separated","cert":"line1\\nline2"}},
  "projs": [{{"name":"","tech":"","desc":""}}],
  "extra": "achievements as bullet points separated by newline",
  "confidence_notes": "Brief note on what was unclear or might need user verification (e.g. 'Experience years estimated from dates' or 'Phone number not found in CV')"
}}"""

    try:
        parsed = ai_provider.generate_json(prompt, max_tokens=3000)
        return JSONResponse(content={"success": True, "data": parsed})
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"AI parse error: {str(e)}")
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


# ── Generate Resume ──────────────────────────────────────
@app.post("/generate")
async def generate_resume(req: ResumeRequest):
    level = "Senior" if req.exp >= 4 else "Junior"

    works_text = ""
    for i, w in enumerate(req.works):
        if w.co:
            works_text += f"{i+1}. {w.des} at {w.co} | {w.start} to {w.end} | {w.loc or 'India'}\n"
            works_text += f"   Details: {w.pts or 'Not provided'}\n\n"

    edu_text = ""
    for i, e in enumerate(req.edus):
        if e.deg or e.col:
            edu_text += f"{i+1}. {e.deg} from {e.col}, {e.yr}"
            if e.grade: edu_text += f" ({e.grade})"
            if e.honors: edu_text += f" - {e.honors}"
            edu_text += "\n"

    projs_text = ""
    for i, p in enumerate(req.projs):
        if p.name:
            projs_text += f"{i+1}. {p.name} | Tech: {p.tech} | {p.desc}\n"

    prompt = f"""You are an expert ATS resume writer for Indian job market. Create a professional, ATS-optimized resume.

CANDIDATE INFO:
Name: {req.name}
Phone: {req.phone}
Email: {req.email}
City: {req.city}
LinkedIn: {req.linkedin or 'N/A'}
GitHub/Portfolio: {req.github or 'N/A'}
Target Role: {req.role}
Experience: {req.exp} years ({level} level)
Industry: {req.industry}
CTC: {req.ctc or 'N/A'}
User Summary: {req.summary or 'PLEASE GENERATE A STRONG ONE'}

EDUCATION:
{edu_text or 'Not provided'}

WORK EXPERIENCE:
{works_text or 'Fresher - no experience'}

SKILLS:
Technical: {req.skills.tech}
Soft Skills: {req.skills.soft}
Languages: {req.skills.lang}
Certifications: {req.skills.cert}

PROJECTS:
{projs_text or 'None'}

EXTRA/ACHIEVEMENTS:
{req.extra or 'None'}

INSTRUCTIONS:
1. Write compelling 3-line professional summary (if not provided or improve if provided)
2. Transform ALL work bullets with strong action verbs: Led, Architected, Delivered, Reduced, Increased, Optimized, Implemented, Built, Spearheaded, Managed, Developed, Designed, Automated, Streamlined
3. Add realistic quantifiable metrics wherever possible (estimate based on role/company size)
4. Insert relevant ATS keywords for {req.industry} industry and {req.role} role
5. For {level} level - {'focus on leadership, strategy, business impact, team management' if level == 'Senior' else 'focus on technical skills, projects, learning agility, contributions'}
6. Make every bullet IMPACTFUL - avoid vague statements
7. Generate 3-5 strong bullets per job minimum
8. Skills list should be comprehensive and ATS-friendly

PAGE LENGTH RULE (critical):
- Target ONE page total (roughly 450-550 words across all sections combined).
- Absolute maximum is TWO pages — never exceed this under any circumstances.
- To hit this length WITHOUT dropping any company, role, or fact the candidate gave you:
  - Give the most recent / most relevant role the most bullets (4-5, detailed).
  - Compress older or less relevant roles into fewer, tighter bullets (1-3 lines) —
    keep the company name, title, and dates for every single job, just say less about each.
  - Tighten wording everywhere (shorter sentences, fewer filler words) rather than cutting jobs.
  - If a candidate has 6+ years experience and many jobs, it is fine and expected to use 2 pages.

NEVER-SKIP RULE (critical):
- Every company name, job title, date range, degree, certification, skill, and project the
  candidate mentioned MUST appear somewhere in the output. You may reword, shorten, or merge
  bullets for brevity, but you must NEVER silently drop an entire company, role, certification,
  or skill to save space. If space is tight, compress the wording, not the content coverage.
- Double-check your own output against the input before finalizing: does every job the
  candidate listed appear in "experience"? Does every skill they listed appear in "skills"?

CRITICAL: Return ONLY valid JSON, no markdown backticks, no explanation. Exact structure:
{{
  "summary": "3-line professional summary",
  "education": [{{"deg":"","col":"","yr":"","grade":"","honors":""}}],
  "experience": [{{"co":"","des":"","start":"","end":"","loc":"","bullets":["bullet1","bullet2","bullet3"]}}],
  "skills": {{
    "technical": ["skill1","skill2"],
    "soft": ["skill1","skill2"],
    "languages": ["lang1"],
    "certifications": ["cert1"]
  }},
  "projects": [{{"name":"","tech":"","desc":""}}],
  "extra": ["achievement1"],
  "ats_keywords": ["kw1","kw2","kw3","kw4","kw5","kw6","kw7","kw8"],
  "ats_score": 92,
  "estimated_pages": 1
}}"""

    try:
        parsed = ai_provider.generate_json(prompt, max_tokens=2000)
        # Attach personal info
        parsed["personal"] = {
            "name": req.name, "phone": req.phone, "email": req.email,
            "city": req.city, "linkedin": req.linkedin, "github": req.github,
            "role": req.role
        }
        return JSONResponse(content={"success": True, "data": parsed})
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"AI response parse error: {str(e)}")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ── Generate JD-Tailored Resume ──────────────────────────
@app.post("/generate-jd-tailored")
async def generate_jd_tailored_resume(req: JDTailorRequest):
    """
    Builds a resume specifically tailored to one job posting. Reads the JD,
    figures out what it's really asking for, then writes the resume so the
    candidate's real experience is framed in that language — same never-skip
    and page-length rules as normal generation, plus JD-keyword matching.
    """
    level = "Senior" if req.exp >= 4 else "Junior"

    works_text = ""
    for i, w in enumerate(req.works):
        if w.co:
            works_text += f"{i+1}. {w.des} at {w.co} | {w.start} to {w.end} | {w.loc or 'India'}\n"
            works_text += f"   Details: {w.pts or 'Not provided'}\n\n"

    edu_text = ""
    for i, e in enumerate(req.edus):
        if e.deg or e.col:
            edu_text += f"{i+1}. {e.deg} from {e.col}, {e.yr}"
            if e.grade: edu_text += f" ({e.grade})"
            if e.honors: edu_text += f" - {e.honors}"
            edu_text += "\n"

    projs_text = ""
    for i, p in enumerate(req.projs):
        if p.name:
            projs_text += f"{i+1}. {p.name} | Tech: {p.tech} | {p.desc}\n"

    prompt = f"""You are an expert ATS resume writer. Build a resume for this candidate that is
SPECIFICALLY TAILORED to the job description below — while staying 100% truthful to their
real background. You are reframing and prioritizing real experience, never inventing it.

TARGET JOB DESCRIPTION:
---
{req.job_description}
---

CANDIDATE'S REAL BACKGROUND:
Name: {req.name}
Phone: {req.phone}
Email: {req.email}
City: {req.city}
LinkedIn: {req.linkedin or 'N/A'}
GitHub/Portfolio: {req.github or 'N/A'}
Current/Target Role: {req.role or 'Not specified'}
Experience: {req.exp} years ({level} level)
Industry: {req.industry or 'Not specified'}
User Summary: {req.summary or 'PLEASE GENERATE ONE TAILORED TO THE JD'}

EDUCATION:
{edu_text or 'Not provided'}

WORK EXPERIENCE:
{works_text or 'Fresher - no experience'}

SKILLS:
Technical: {req.skills.tech}
Soft Skills: {req.skills.soft}
Languages: {req.skills.lang}
Certifications: {req.skills.cert}

PROJECTS:
{projs_text or 'None'}

EXTRA/ACHIEVEMENTS:
{req.extra or 'None'}

TAILORING INSTRUCTIONS (critical):
1. Read the job description carefully and identify: the top 8-12 keywords/skills it repeats
   or emphasizes, the seniority level it implies, and the kind of impact it cares about
   (e.g. scale, cost savings, leadership, specific tech stack).
2. Write the professional summary using language that mirrors the JD's own phrasing where
   truthful — if the JD says "cloud-native microservices" and the candidate has that
   experience, use that exact phrase rather than a generic synonym.
3. Reorder the technical skills list so skills mentioned in the JD appear FIRST, followed by
   the candidate's other real skills. Do not add skills the candidate never mentioned.
4. For each real job, rewrite bullets to foreground the parts of that work most relevant to
   this JD — same real accomplishments, framed in the JD's language and priorities.
5. If the candidate has genuine experience matching a JD requirement, make sure a bullet
   explicitly reflects it. If they do NOT have something the JD asks for, do not fabricate it —
   simply do not force it in.
6. Transform all bullets with strong action verbs and quantifiable impact, same as normal.

PAGE LENGTH RULE (critical):
- Target ONE page total (roughly 450-550 words across all sections combined).
- Absolute maximum is TWO pages — never exceed this.
- Give the most JD-relevant role(s) the most bullets; compress less relevant older roles into
  tighter bullets while still keeping every company, title, and date range.

NEVER-SKIP RULE (critical):
- Every company, job title, date range, degree, certification, skill, and project the candidate
  actually gave you MUST appear somewhere in the output. Reword and reorder for relevance —
  never silently delete a real job or skill to save space or "improve" JD fit.

CRITICAL: Return ONLY valid JSON, no markdown backticks, no explanation. Exact structure:
{{
  "summary": "3-line professional summary tailored to this JD",
  "education": [{{"deg":"","col":"","yr":"","grade":"","honors":""}}],
  "experience": [{{"co":"","des":"","start":"","end":"","loc":"","bullets":["bullet1","bullet2","bullet3"]}}],
  "skills": {{
    "technical": ["JD-matched skill first","JD-matched skill","...","other real skills"],
    "soft": ["skill1","skill2"],
    "languages": ["lang1"],
    "certifications": ["cert1"]
  }},
  "projects": [{{"name":"","tech":"","desc":""}}],
  "extra": ["achievement1"],
  "ats_keywords": ["kw1","kw2","kw3","kw4","kw5","kw6","kw7","kw8"],
  "ats_score": 92,
  "estimated_pages": 1,
  "jd_match_score": 88,
  "jd_keywords_matched": ["keyword1","keyword2","keyword3","keyword4","keyword5"],
  "jd_keywords_missing": ["keyword the JD wants that the candidate genuinely doesn't have"]
}}"""

    try:
        parsed = ai_provider.generate_json(prompt, max_tokens=3000)
        parsed["personal"] = {
            "name": req.name, "phone": req.phone, "email": req.email,
            "city": req.city, "linkedin": req.linkedin, "github": req.github,
            "role": req.role
        }
        return JSONResponse(content={"success": True, "data": parsed})
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=500, detail=f"AI response parse error: {str(e)}")
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

# ── Edit Resume via Chat ─────────────────────────────────
@app.post("/edit")
async def edit_resume(req: EditRequest):
    prompt = f"""You are an expert resume editor. Apply the user's requested changes to this resume.

CURRENT RESUME JSON:
{json.dumps(req.current_data, indent=2)}

USER REQUEST: "{req.user_message}"

Rules:
- Understand exactly what needs to change
- Apply changes precisely and intelligently
- Keep all other sections unchanged
- Maintain professional tone and ATS optimization
- If user asks to add/change skills, update the skills array
- If user asks to change summary, rewrite summary
- If user asks to change job bullets, rewrite those specific bullets

Return ONLY the updated complete JSON in exact same structure. No markdown, no explanation."""

    try:
        parsed = ai_provider.generate_json(prompt, max_tokens=2000)
        return JSONResponse(content={"success": True, "data": parsed})
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ── Download PDF ─────────────────────────────────────────
@app.post("/download/pdf")
async def download_pdf(req: DownloadRequest):
    try:
        from reportlab.lib.pagesizes import A4
        from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
        from reportlab.lib.units import mm
        from reportlab.lib import colors
        from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, HRFlowable, ListFlowable, ListItem
        from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY

        rd = req.resume_data
        p = rd.get("personal", {})
        buffer = io.BytesIO()

        # Resolve accent color from template selection (defaults to navy)
        accent_hex = req.template_color if req.template_color else "#1a1a2e"
        template_id = req.template_id or "classic"
        try:
            accent_color = colors.HexColor(accent_hex)
        except Exception:
            accent_color = colors.HexColor("#1a1a2e")

        doc = SimpleDocTemplate(
            buffer, pagesize=A4,
            rightMargin=15*mm, leftMargin=15*mm,
            topMargin=10*mm, bottomMargin=10*mm
        )

        styles = getSampleStyleSheet()
        story = []

        # Custom styles — section headings and name use the chosen accent color.
        # Layout always stays single-column regardless of template, so the
        # PDF remains fully ATS-parseable no matter which style was picked.
        name_style = ParagraphStyle('Name', fontSize=20, fontName='Helvetica-Bold',
                                     alignment=TA_CENTER, spaceAfter=2, textColor=accent_color)
        role_style = ParagraphStyle('Role', fontSize=11, fontName='Helvetica',
                                     alignment=TA_CENTER, spaceAfter=3, textColor=accent_color)
        contact_style = ParagraphStyle('Contact', fontSize=9, fontName='Helvetica',
                                        alignment=TA_CENTER, spaceAfter=8, textColor=colors.HexColor('#555'))
        section_style = ParagraphStyle('Section', fontSize=9, fontName='Helvetica-Bold',
                                        spaceBefore=6, spaceAfter=2, textColor=accent_color,
                                        letterSpacing=1.5)
        body_style = ParagraphStyle('Body', fontSize=9, fontName='Helvetica',
                                     spaceAfter=2, textColor=colors.HexColor('#222'), leading=12)
        bullet_style = ParagraphStyle('Bullet', fontSize=9, fontName='Helvetica',
                                       spaceAfter=1, textColor=colors.HexColor('#222'),
                                       leftIndent=12, leading=12)
        bold_style = ParagraphStyle('Bold', fontSize=9, fontName='Helvetica-Bold',
                                     spaceAfter=1, textColor=colors.HexColor('#111'))
        italic_style = ParagraphStyle('Italic', fontSize=9, fontName='Helvetica-Oblique',
                                       spaceAfter=2, textColor=colors.HexColor('#444'))

        def hr():
            return HRFlowable(width="100%", thickness=0.5, color=colors.HexColor('#cccccc'), spaceAfter=4)

        def section_hr():
            return HRFlowable(width="100%", thickness=1, color=accent_color, spaceAfter=4)

        # Header
        story.append(Paragraph(p.get('name', ''), name_style))
        story.append(Paragraph(p.get('role', ''), role_style))
        contacts = [x for x in [p.get('phone'), p.get('email'), p.get('city')] if x]
        if p.get('linkedin'): contacts.append(p['linkedin'])
        if p.get('github'): contacts.append(p['github'])
        story.append(Paragraph(' | '.join(contacts), contact_style))
        story.append(section_hr())

        # Summary
        if rd.get('summary'):
            story.append(Paragraph('PROFESSIONAL SUMMARY', section_style))
            story.append(section_hr())
            story.append(Paragraph(rd['summary'], body_style))
            story.append(Spacer(1, 2))

        # Experience
        exp = [w for w in rd.get('experience', []) if w.get('co')]
        if exp:
            story.append(Paragraph('WORK EXPERIENCE', section_style))
            story.append(section_hr())
            for w in exp:
                from reportlab.platypus import Table, TableStyle
                title_date = f"<b>{w.get('des','')}</b>"
                date_str = f"{w.get('start','')} – {w.get('end','Present')}"
                story.append(Paragraph(title_date, bold_style))
                co_loc = f"{w.get('co','')}{' | ' + w.get('loc','') if w.get('loc') else ''} | {date_str}"
                story.append(Paragraph(co_loc, italic_style))
                for b in (w.get('bullets') or []):
                    if b:
                        story.append(Paragraph(f"• {b}", bullet_style))
                story.append(Spacer(1, 2))

        # Education
        edus = [e for e in rd.get('education', []) if e.get('deg') or e.get('col')]
        if edus:
            story.append(Paragraph('EDUCATION', section_style))
            story.append(section_hr())
            for e in edus:
                story.append(Paragraph(f"<b>{e.get('deg','')}</b>", bold_style))
                col_parts = [e.get('col',''), e.get('yr',''), e.get('grade',''), e.get('honors','')]
                story.append(Paragraph(' | '.join([x for x in col_parts if x]), italic_style))
            story.append(Spacer(1, 2))

        # Technical Skills
        sk = rd.get('skills', {})
        tech = [s for s in (sk.get('technical') or []) if s]
        if tech:
            story.append(Paragraph('TECHNICAL SKILLS', section_style))
            story.append(section_hr())
            story.append(Paragraph(', '.join(tech), body_style))
            story.append(Spacer(1, 2))

        # Certifications
        certs = [c for c in (sk.get('certifications') or []) if c]
        if certs:
            story.append(Paragraph('CERTIFICATIONS', section_style))
            story.append(section_hr())
            for c in certs:
                story.append(Paragraph(f"• {c}", bullet_style))
            story.append(Spacer(1, 2))

        # Projects
        projs = [pr for pr in rd.get('projects', []) if pr.get('name')]
        if projs:
            story.append(Paragraph('KEY PROJECTS', section_style))
            story.append(section_hr())
            for pr in projs:
                story.append(Paragraph(f"<b>{pr.get('name','')}</b> | <i>{pr.get('tech','')}</i>", bold_style))
                if pr.get('desc'):
                    story.append(Paragraph(pr['desc'], body_style))
            story.append(Spacer(1, 2))

        # Languages
        langs = [l for l in (sk.get('languages') or []) if l]
        if langs:
            story.append(Paragraph('LANGUAGES', section_style))
            story.append(section_hr())
            story.append(Paragraph(', '.join(langs), body_style))
            story.append(Spacer(1, 2))

        # Extra / Achievements
        extra = [x for x in (rd.get('extra') or []) if x]
        if extra:
            story.append(Paragraph('ACHIEVEMENTS & ACTIVITIES', section_style))
            story.append(section_hr())
            for x in extra:
                story.append(Paragraph(f"• {x}", bullet_style))

        doc.build(story)
        buffer.seek(0)
        name_slug = (p.get('name') or 'Resume').replace(' ', '_')
        return StreamingResponse(
            buffer,
            media_type="application/pdf",
            headers={"Content-Disposition": f"attachment; filename={name_slug}_Resume.pdf"}
        )
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

# ── Download DOCX ────────────────────────────────────────
@app.post("/download/doc")
async def download_doc(req: DownloadRequest):
    try:
        from docx import Document
        from docx.shared import Pt, RGBColor, Inches, Cm
        from docx.enum.text import WD_ALIGN_PARAGRAPH
        from docx.oxml.ns import qn
        from docx.oxml import OxmlElement
        import copy

        rd = req.resume_data
        p = rd.get("personal", {})
        doc = Document()

        # Resolve accent color from template selection (defaults to navy).
        # Layout always stays single-column so the DOCX remains fully
        # ATS-parseable regardless of which template/color was picked.
        accent_hex = (req.template_color or "#1a1a2e").lstrip("#")
        try:
            accent_rgb = RGBColor(int(accent_hex[0:2], 16), int(accent_hex[2:4], 16), int(accent_hex[4:6], 16))
        except Exception:
            accent_rgb = RGBColor(0x1a, 0x1a, 0x2e)

        # Page margins
        for section in doc.sections:
            section.top_margin = Cm(1.5)
            section.bottom_margin = Cm(1.5)
            section.left_margin = Cm(2)
            section.right_margin = Cm(2)

        def add_hr(doc):
            para = doc.add_paragraph()
            para.paragraph_format.space_before = Pt(0)
            para.paragraph_format.space_after = Pt(0)
            pPr = para._p.get_or_add_pPr()
            pBdr = OxmlElement('w:pBdr')
            bottom = OxmlElement('w:bottom')
            bottom.set(qn('w:val'), 'single')
            bottom.set(qn('w:sz'), '6')
            bottom.set(qn('w:space'), '1')
            bottom.set(qn('w:color'), accent_hex)
            pBdr.append(bottom)
            pPr.append(pBdr)
            return para

        def section_header(doc, text):
            para = doc.add_paragraph()
            para.paragraph_format.space_before = Pt(8)
            para.paragraph_format.space_after = Pt(0)
            run = para.add_run(text.upper())
            run.bold = True
            run.font.size = Pt(9)
            run.font.color.rgb = accent_rgb
            add_hr(doc)

        # Name
        name_para = doc.add_paragraph()
        name_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
        name_para.paragraph_format.space_after = Pt(2)
        nr = name_para.add_run(p.get('name', ''))
        nr.bold = True
        nr.font.size = Pt(20)
        nr.font.color.rgb = accent_rgb

        # Role
        role_para = doc.add_paragraph()
        role_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
        role_para.paragraph_format.space_after = Pt(2)
        rr = role_para.add_run(p.get('role', ''))
        rr.font.size = Pt(11)
        rr.font.color.rgb = accent_rgb

        # Contact
        contacts = [x for x in [p.get('phone'), p.get('email'), p.get('city'), p.get('linkedin'), p.get('github')] if x]
        contact_para = doc.add_paragraph()
        contact_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
        contact_para.paragraph_format.space_after = Pt(4)
        cr = contact_para.add_run(' | '.join(contacts))
        cr.font.size = Pt(9)
        cr.font.color.rgb = RGBColor(0x55, 0x55, 0x55)

        add_hr(doc)

        # Summary
        if rd.get('summary'):
            section_header(doc, 'Professional Summary')
            sp = doc.add_paragraph(rd['summary'])
            sp.paragraph_format.space_after = Pt(4)
            for run in sp.runs:
                run.font.size = Pt(9)

        # Experience
        exp = [w for w in rd.get('experience', []) if w.get('co')]
        if exp:
            section_header(doc, 'Work Experience')
            for w in exp:
                title_para = doc.add_paragraph()
                title_para.paragraph_format.space_before = Pt(4)
                title_para.paragraph_format.space_after = Pt(0)
                tr = title_para.add_run(w.get('des', ''))
                tr.bold = True
                tr.font.size = Pt(9)
                co_para = doc.add_paragraph()
                co_para.paragraph_format.space_after = Pt(0)
                co_text = f"{w.get('co','')} | {w.get('start','')} – {w.get('end','Present')}"
                if w.get('loc'): co_text += f" | {w['loc']}"
                cor = co_para.add_run(co_text)
                cor.italic = True
                cor.font.size = Pt(9)
                cor.font.color.rgb = RGBColor(0x44, 0x44, 0x44)
                for b in (w.get('bullets') or []):
                    if b:
                        bp = doc.add_paragraph(style='List Bullet')
                        bp.paragraph_format.space_after = Pt(1)
                        bp.paragraph_format.left_indent = Cm(0.5)
                        br = bp.add_run(b)
                        br.font.size = Pt(9)

        # Education
        edus = [e for e in rd.get('education', []) if e.get('deg') or e.get('col')]
        if edus:
            section_header(doc, 'Education')
            for e in edus:
                ep = doc.add_paragraph()
                ep.paragraph_format.space_before = Pt(3)
                ep.paragraph_format.space_after = Pt(0)
                er = ep.add_run(e.get('deg', ''))
                er.bold = True; er.font.size = Pt(9)
                col_parts = [e.get('col',''), e.get('yr',''), e.get('grade',''), e.get('honors','')]
                cp = doc.add_paragraph()
                cp.paragraph_format.space_after = Pt(2)
                cr2 = cp.add_run(' | '.join([x for x in col_parts if x]))
                cr2.italic = True; cr2.font.size = Pt(9)
                cr2.font.color.rgb = RGBColor(0x44, 0x44, 0x44)

        # Skills
        sk = rd.get('skills', {})
        tech = [s for s in (sk.get('technical') or []) if s]
        if tech:
            section_header(doc, 'Technical Skills')
            sp2 = doc.add_paragraph(', '.join(tech))
            sp2.paragraph_format.space_after = Pt(4)
            for run in sp2.runs: run.font.size = Pt(9)

        certs = [c for c in (sk.get('certifications') or []) if c]
        if certs:
            section_header(doc, 'Certifications')
            for c in certs:
                cp2 = doc.add_paragraph(style='List Bullet')
                cp2.paragraph_format.space_after = Pt(1)
                cr3 = cp2.add_run(c)
                cr3.font.size = Pt(9)

        # Projects
        projs = [pr for pr in rd.get('projects', []) if pr.get('name')]
        if projs:
            section_header(doc, 'Key Projects')
            for pr in projs:
                pp = doc.add_paragraph()
                pp.paragraph_format.space_before = Pt(3)
                pp.paragraph_format.space_after = Pt(0)
                pnr = pp.add_run(pr.get('name', ''))
                pnr.bold = True; pnr.font.size = Pt(9)
                if pr.get('tech'):
                    pp.add_run(f" | {pr['tech']}").font.size = Pt(9)
                if pr.get('desc'):
                    dp = doc.add_paragraph(pr['desc'])
                    dp.paragraph_format.space_after = Pt(2)
                    for run in dp.runs: run.font.size = Pt(9)

        # Languages
        langs = [l for l in (sk.get('languages') or []) if l]
        if langs:
            section_header(doc, 'Languages')
            lp = doc.add_paragraph(', '.join(langs))
            for run in lp.runs: run.font.size = Pt(9)

        # Extra
        extra = [x for x in (rd.get('extra') or []) if x]
        if extra:
            section_header(doc, 'Achievements & Activities')
            for x in extra:
                xp = doc.add_paragraph(style='List Bullet')
                xp.paragraph_format.space_after = Pt(1)
                xr = xp.add_run(x)
                xr.font.size = Pt(9)

        buffer = io.BytesIO()
        doc.save(buffer)
        buffer.seek(0)
        name_slug = (p.get('name') or 'Resume').replace(' ', '_')
        return StreamingResponse(
            buffer,
            media_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            headers={"Content-Disposition": f"attachment; filename={name_slug}_Resume.docx"}
        )
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
