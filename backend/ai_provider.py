# backend/ai_provider.py
"""
Single place that talks to whichever AI provider is configured.

Why this file exists:
  Early on, before the app has paying users, running everything on Claude
  costs real money per resume. Google's Gemini API has a genuinely free
  tier (no credit card, ~1500 requests/day on Flash models as of 2026) that
  is good enough for resume writing. This module lets the whole backend
  switch between providers with ONE environment variable — no other file
  needs to change.

Usage:
  export AI_PROVIDER=gemini   # free tier, good for launch / low volume
  export AI_PROVIDER=claude   # paid, higher quality, use once revenue covers cost

  export GEMINI_API_KEY=...     (get free, no card, from aistudio.google.com)
  export ANTHROPIC_API_KEY=...  (only needed if AI_PROVIDER=claude)

Honest tradeoff to know about the free Gemini tier:
  Google's free tier may use your prompts to improve their models. This app
  sends real personal data (name, phone, email, work history) in every
  prompt. That's an acceptable tradeoff for a bootstrapped MVP, but you
  should know it before shipping — read Google's current terms at
  ai.google.dev before relying on this for real user data at scale.
"""
import os
import json
import re

PROVIDER = os.environ.get("AI_PROVIDER", "gemini").lower()

_anthropic_client = None
_gemini_client = None
_openrouter_client = None


def _get_anthropic_client():
    global _anthropic_client
    if _anthropic_client is None:
        import anthropic
        _anthropic_client = anthropic.Anthropic(api_key=os.environ.get("ANTHROPIC_API_KEY", ""))
    return _anthropic_client


def _get_gemini_client():
    global _gemini_client
    if _gemini_client is None:
        from google import genai
        _gemini_client = genai.Client(api_key=os.environ.get("GEMINI_API_KEY", ""))
    return _gemini_client


def _get_openrouter_client():
    global _openrouter_client
    if _openrouter_client is None:
        from openai import OpenAI
        _openrouter_client = OpenAI(
            base_url="https://openrouter.ai/api/v1",
            api_key=os.environ.get("OPENROUTER_API_KEY", ""),
        )
    return _openrouter_client


def generate_json(prompt: str, max_tokens: int = 2000) -> dict:
    """
    Sends the prompt to whichever provider is configured, and returns
    the parsed JSON dict using a multi-pass repair algorithm that handles
    markdown code fences, unescaped newlines, trailing commas, and truncation.
    """
    raw = _call_provider(prompt, max_tokens)
    return repair_json(raw)


def repair_json(raw: str) -> dict:
    if not raw or not raw.strip():
        return {}

    s = raw.strip()
    
    # 1. Clean markdown code fences if present
    s = re.sub(r'^```json\s*', '', s, flags=re.IGNORECASE)
    s = re.sub(r'^```\s*', '', s)
    s = re.sub(r'\s*```$', '', s)

    # 2. Extract content between first { and last }
    first_brace = s.find('{')
    last_brace = s.rfind('}')
    if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
        s = s[first_brace:last_brace + 1]
    
    s = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', s)
    
    # Pass 1: Standard json.loads
    try:
        return json.loads(s)
    except Exception:
        pass
        
    # Pass 2: Fix unescaped newlines/tabs/quotes inside string literals
    result = []
    in_string = False
    escaped = False
    for char in s:
        if char == '"' and not escaped:
            in_string = not in_string
            result.append(char)
        elif in_string and char == '\n':
            result.append('\\n')
        elif in_string and char == '\r':
            result.append('')
        elif in_string and char == '\t':
            result.append('\\t')
        else:
            result.append(char)
            
        if char == '\\' and not escaped:
            escaped = True
        else:
            escaped = False
    s_fixed = ''.join(result)
    
    # Clean trailing commas before } or ]
    s_fixed = re.sub(r',\s*([\]}])', r'\1', s_fixed)
    
    try:
        return json.loads(s_fixed)
    except Exception:
        pass

    # Pass 3: Auto-close truncated JSON if missing braces/quotes
    open_braces = s_fixed.count('{') - s_fixed.count('}')
    open_brackets = s_fixed.count('[') - s_fixed.count(']')
    s_closed = s_fixed
    if s_closed.count('"') % 2 != 0:
        s_closed += '"'
    s_closed += ']' * max(0, open_brackets)
    s_closed += '}' * max(0, open_braces)
    s_closed = re.sub(r',\s*([\]}])', r'\1', s_closed)
    
    try:
        return json.loads(s_closed)
    except Exception as e:
        print(f"JSON Repair warning: {e}. Attempting regex key-value extraction.")

    # Pass 4: Regex-based field extraction fallback (Guarantees dictionary return)
    fallback = {}
    def match_str(key):
        m = re.search(rf'"{key}"\s*:\s*"([^"]*)"', raw)
        return m.group(1) if m else ""

    fallback["name"] = match_str("name")
    fallback["phone"] = match_str("phone")
    fallback["email"] = match_str("email")
    fallback["city"] = match_str("city")
    fallback["linkedin"] = match_str("linkedin")
    fallback["github"] = match_str("github")
    fallback["role"] = match_str("role")
    fallback["summary"] = match_str("summary")
    fallback["industry"] = match_str("industry")
    fallback["extra"] = match_str("extra")
    fallback["edus"] = []
    fallback["works"] = []
    fallback["skills"] = {"tech": "", "soft": "", "lang": "", "cert": ""}
    fallback["projs"] = []
    
    return fallback


def _call_provider(prompt: str, max_tokens: int) -> str:
    if PROVIDER == "gemini":
        return _call_gemini(prompt, max_tokens)
    elif PROVIDER == "claude":
        return _call_claude(prompt, max_tokens)
    elif PROVIDER == "groq":
        return _call_groq(prompt, max_tokens)
    elif PROVIDER == "openrouter":
        return _call_openrouter(prompt, max_tokens)
    else:
        raise ValueError(f"Unknown AI_PROVIDER '{PROVIDER}'. Use 'gemini', 'claude', 'groq', or 'openrouter'.")


def _call_claude(prompt: str, max_tokens: int) -> str:
    client = _get_anthropic_client()
    message = client.messages.create(
        model="claude-3-5-sonnet-20241022",
        max_tokens=max_tokens,
        messages=[{"role": "user", "content": prompt}],
    )
    return message.content[0].text


def _call_gemini(prompt: str, max_tokens: int) -> str:
    client = _get_gemini_client()
    # Fast official models: gemini-2.0-flash with fallback to gemini-1.5-flash
    model_name = os.environ.get("GEMINI_MODEL", "gemini-2.0-flash")
    try:
        response = client.models.generate_content(
            model=model_name,
            contents=prompt,
            config={
                "max_output_tokens": max_tokens,
                "temperature": 0.1,
                "response_mime_type": "application/json",
            },
        )
        return response.text
    except Exception as e:
        print(f"Primary model {model_name} failed: {e}. Trying fallback gemini-1.5-flash...")
        response = client.models.generate_content(
            model="gemini-1.5-flash",
            contents=prompt,
            config={
                "max_output_tokens": max_tokens,
                "temperature": 0.1,
                "response_mime_type": "application/json",
            },
        )
        return response.text


def _call_groq(prompt: str, max_tokens: int) -> str:
    """Fallback option: free, no card, but open-source models only (lower
    resume-writing quality than Gemini/Claude). Useful if Gemini's daily
    quota runs out on a busy day."""
    from groq import Groq
    client = Groq(api_key=os.environ.get("GROQ_API_KEY", ""))
    completion = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=max_tokens,
    )
    return completion.choices[0].message.content


def _call_openrouter(prompt: str, max_tokens: int) -> str:
    """
    OpenRouter is an aggregator — one API key, one OpenAI-compatible
    endpoint, access to many models including free-tier Gemini variants
    (model names ending in ':free'). Handy if you already have an
    OpenRouter key rather than a direct Google AI Studio key.
    Set OPENROUTER_MODEL to change which model it routes to.
    """
    client = _get_openrouter_client()
    model = os.environ.get("OPENROUTER_MODEL", "google/gemini-2.0-flash-exp:free")
    completion = client.chat.completions.create(
        model=model,
        messages=[{"role": "user", "content": prompt}],
        max_tokens=max_tokens,
    )
    return completion.choices[0].message.content
