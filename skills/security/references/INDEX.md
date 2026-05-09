---
type: reference
title: AI Code Security Anti-Patterns - Breadth Version
created: 2026-01-18
version: 1.0.0
tags:
  - security
  - anti-patterns
  - ai-generated-code
  - llm
  - secure-coding
related:
  - "[[ANTI_PATTERNS_DEPTH]]"
  - "[[Ranking-Matrix]]"
  - "[[Pseudocode-Examples]]"
---

# AI Code Security Anti-Patterns
## Breadth Version - Comprehensive Coverage

> **Purpose:** Security anti-patterns guide for AI-assisted code generation
> **Audience:** Any LLM system prompt, RAG system, or context file
> **Format:** Pseudocode examples (implement in your target language)
> **How to use:** Include in system prompt or reference during code generation

---

## INSTRUCTIONS FOR AI/LLM

This document contains security anti-patterns you MUST avoid when generating code.
Each section shows a VULNERABLE pattern (marked BAD) and a SECURE alternative (marked GOOD).
All examples are in PSEUDOCODE - implement the secure patterns in whatever language
the developer is using. When in doubt, choose the more secure option.

**Key Statistics:**
- AI-generated code has an **86% XSS failure rate** (vs 31.6% human code)
- **5-21% of AI-suggested packages don't exist** (slopsquatting risk)
- AI code is **2.74x more likely** to have XSS vulnerabilities
- **21.7% hallucination rate** for package names in some domains
- SQL injection patterns appeared "thousands of times" in AI training data

**Before generating any code:**
1. Never hardcode credentials, API keys, or secrets
2. Always parameterize database queries
3. Validate and sanitize all user input
4. Use cryptographically secure random for security tokens
5. Verify packages exist before suggesting imports
6. Encode output for the appropriate context (HTML, URL, JS)

---

## Quick Reference Table

| Pattern | CWE | Severity | Quick Fix |
|---------|-----|----------|-----------|
| Hallucinated Packages | CWE-1357 | Critical | Verify packages exist before import |
| XSS (Reflected/Stored/DOM) | CWE-79 | Critical | Encode output for context |
| Hardcoded Secrets | CWE-798 | Critical | Use environment variables |
| SQL Injection | CWE-89 | Critical | Use parameterized queries |
| Missing Authentication | CWE-287 | Critical | Apply auth to all protected endpoints |
| Command Injection | CWE-78 | Critical | Use argument arrays, avoid shell |
| Missing Input Validation | CWE-20 | High | Validate type, length, format, range |
| Unrestricted File Upload | CWE-434 | Critical | Validate extension, MIME, and size |
| Insufficient Randomness | CWE-330 | High | Use secrets module for tokens |
| Missing Rate Limiting | CWE-770 | High | Implement per-IP/user limits |
| Excessive Data Exposure | CWE-200 | High | Use DTOs with field allowlists |
| Path Traversal | CWE-22 | High | Validate paths within allowed dirs |
| Weak Password Hashing | CWE-327 | High | Use bcrypt/argon2 with salt |
| Log Injection | CWE-117 | Medium | Sanitize newlines, use structured logging |
| Debug Mode in Production | CWE-215 | High | Environment-based configuration |
| Weak Encryption | CWE-326 | High | Use AES-GCM or ChaCha20-Poly1305 |
| Session Fixation | CWE-384 | High | Regenerate session ID on login |
| JWT Misuse | CWE-287 | High | Strong secrets, explicit algorithms |
| Mass Assignment | CWE-915 | High | Allowlist assignable fields |
| Missing Security Headers | CWE-16 | Medium | Add CSP, X-Frame-Options, HSTS |
| Open CORS | CWE-346 | Medium | Restrict to known origins |
| LDAP Injection | CWE-90 | High | Escape special LDAP characters |
| XPath Injection | CWE-643 | High | Use parameterized XPath or validate |
| Insecure Temp Files | CWE-377 | Medium | Use mkstemp with restrictive perms |
| Verbose Error Messages | CWE-209 | Medium | Generic external, detailed internal |

---

## Topic Files

This reference is split into topic files for targeted loading:

| File | Sections | Load When |
|------|----------|-----------|
| **SECRETS_INJECTION.md** | 1-2: Secrets & Credentials, Injection Vulnerabilities | Working with auth, DB queries, shell commands, user input |
| **XSS_AUTH.md** | 3-4: XSS, Authentication & Session Management | Building web UI, login flows, session handling |
| **CRYPTO_VALIDATION.md** | 5-6: Cryptographic Failures, Input Validation | Using encryption, hashing, validating user input |
| **CONFIG_DEPENDENCIES.md** | 7-8: Configuration & Deployment, Dependency Security | Setting up servers, managing packages, CI/CD |
| **API_FILEHANDLING.md** | 9-10: API Security, File Handling | Building APIs, handling file uploads, path operations |
| **CHECKLIST.md** | Checklist, References, Metadata | Pre-generation review, looking up CWE details |
