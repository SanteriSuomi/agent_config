---
name: sec-context
description: "MANUAL ONLY - Security anti-patterns for AI-generated code. Only invoke when user explicitly requests security review or in security-auditor agent. NOT for proactive use. Covers 25+ anti-patterns with CWE references. Triggers: /sec-context, security review, security audit."
source: https://github.com/Arcanum-Sec/sec-context
last-synced: 2026-01-23
metadata:
  author: Arcanum-Sec
  invocation: manual-only
---

# Security Context

> **MANUAL INVOCATION ONLY** — Do not load proactively. Only use when:
> 1. User explicitly requests security review
> 2. Running as part of `security-auditor` agent

Security anti-patterns for AI-generated code. Synthesized from 150+ sources including CVE databases, OWASP, academic research.

---

## On Activation

**MANDATORY — READ ENTIRE FILE**: When this skill is activated, immediately read `~/.agents/skills/sec-context/references/ANTI_PATTERNS_BREADTH.md` (~7300 lines) completely.

---

## References

| File | Lines | Content | When to Load |
|------|-------|---------|--------------|
| `~/.agents/skills/sec-context/references/ANTI_PATTERNS_BREADTH.md` | ~7300 | 25+ anti-patterns, CWE refs, mitigations | **AUTO-LOAD on activation** |
| `~/.agents/skills/sec-context/references/ANTI_PATTERNS_DEPTH.md` | ~7600 | Top 7 vulnerabilities, deep dive | Load for specific deep investigation |

**When to load DEPTH:**
- Investigating auth/session vulnerabilities
- Deep dive on injection patterns (SQL, command, XSS)
- Analyzing complex attack scenarios
- Full security audit requiring maximum coverage
