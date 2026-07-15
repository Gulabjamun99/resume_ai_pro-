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


def generate_json(prompt: str, max_tokens: int = 3000) -> dict:
    """
    Sends the prompt to whichever provider is configured, and returns
    the parsed JSON dict. Enforces robust extraction of JSON blocks,
    handles markdown code fences, and cleans trailing commas.
    """
    raw = _call_provider(prompt, max_tokens)
    raw = raw.strip()
    
    # Robustly find the JSON boundaries
    first_brace = raw.find('{')
    last_brace = raw.rfind('}')
    
    if first_brace != -1 and last_brace != -1 and last_brace > first_brace:
        json_str = raw[first_brace:last_brace + 1]
    else:
        json_str = raw

    # Clean markdown fences
    json_str = re.sub(r'^```json\s*', '', json_str)
    json_str = re.sub(r'^```\s*', '', json_str)
    json_str = re.sub(r'\s*```$', '', json_str)

    try:
        return json.loads(json_str)
    except json.JSONDecodeError:
        # Fallback 1: Remove trailing commas in arrays/objects (e.g. [1, 2,])
        cleaned = re.sub(r',\s*([\]}])', r'\1', json_str)
        try:
            return json.loads(cleaned)
        except json.JSONDecodeError as e:
            # Fallback 2: Print raw string to log and raise with helpful context
            print(f"JSON Parse Failed. Raw response: {raw}")
            raise e


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
        model="claude-sonnet-4-6",
        max_tokens=max_tokens,
        messages=[{"role": "user", "content": prompt}],
    )
    return message.content[0].text


def _call_gemini(prompt: str, max_tokens: int) -> str:
    client = _get_gemini_client()
    # Free-tier-eligible model as of 2026. If Google renames/retires it,
    # update this one line — nothing else in the backend needs to change.
    #
    # response_mime_type="application/json" tells Gemini to guarantee valid
    # JSON output natively, instead of us hoping it didn't wrap the answer
    # in markdown fences or add commentary. This is more reliable than the
    # "ask nicely and regex-strip the response" approach.
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
        config={
            "max_output_tokens": max_tokens,
            "temperature": 0.7,
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
