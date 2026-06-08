---
name: security
description: "Security anti-patterns for AI-generated code. Covers 25+ anti-patterns with CWE references. Triggers: /security, security review, security audit, vulnerability scan, OWASP."
---

# Security Context

> Load when working on security-sensitive code: authentication, authorization,
> encryption, user input handling, file uploads. Also when the user explicitly
> requests a security review or running as part of `security-auditor` agent.

Security anti-patterns for AI-generated code. Synthesized from 150+ sources including CVE databases, OWASP, academic research.

Source: [Arcanum-Sec/sec-context](https://github.com/Arcanum-Sec/sec-context) by Jason Haddix, CC BY 4.0.

---

## On Activation

1. Read `~/.agents/skills/security/references/INDEX.md` for the quick reference table and statistics.
2. Load only the topic file(s) relevant to the code being audited. Do **not** load all files at once.

---

## Topic Files

| File | Lines | Sections | Load When Auditing |
|------|-------|----------|--------------------|
| `INDEX.md` | ~95 | Quick reference table, instructions | **Always load first** |
| `SECRETS_INJECTION.md` | ~640 | Secrets & Credentials, Injection (SQL/Command/LDAP/XPath/NoSQL/SSTI) | Hardcoded values, DB queries, shell commands |
| `XSS_AUTH.md` | ~1250 | XSS (Reflected/Stored/DOM), Auth & Sessions, JWT, MFA | Output rendering, login flows, session handling |
| `CRYPTO_VALIDATION.md` | ~1280 | Crypto failures, Input validation, ReDoS, path traversal | Encryption, hashing, user input handling |
| `CONFIG_DEPENDENCIES.md` | ~1660 | Config/deployment security, Dependency & supply chain | Debug flags, headers, CORS, package audits |
| `API_FILEHANDLING.md` | ~2210 | API security (IDOR, rate limiting), File handling | REST endpoints, file uploads, path traversal |
| `CHECKLIST.md` | ~185 | Pre-gen checklist, external references, CWE index | Final review pass, looking up specific CWEs |

## Deep Dive

| File | Lines | Content | When to Load |
|------|-------|---------|--------------|
| `ANTI_PATTERNS_DEPTH.md` | ~7600 | Top 7 vulnerabilities, exhaustive analysis | Specific deep investigation of a vulnerability class |

## Archived

`ANTI_PATTERNS_BREADTH.md` — original monolith (~7300 lines). Kept for reference; prefer the split topic files.
