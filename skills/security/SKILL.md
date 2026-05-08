---
name: security
description: "Security anti-patterns for AI-generated code. Covers 25+ anti-patterns with CWE references. Triggers: /security, security review, security audit, vulnerability scan, OWASP."
---

# Security Context

> **MANUAL INVOCATION ONLY** — Do not load proactively. Only use when:
> 1. User explicitly requests security review
> 2. Running as part of `security-auditor` agent

Security anti-patterns for AI-generated code. Synthesized from 150+ sources including CVE databases, OWASP, academic research.

---

## On Activation

**MANDATORY — READ ENTIRE FILE**: When this skill is activated, immediately read `~/.agents/skills-claude/sec-context/references/ANTI_PATTERNS_BREADTH.md` (~7300 lines) completely.

---

## References

| File | Lines | Content | When to Load |
|------|-------|---------|--------------|
| `~/.agents/skills-claude/sec-context/references/ANTI_PATTERNS_BREADTH.md` | ~7300 | 25+ anti-patterns, CWE refs, mitigations | **AUTO-LOAD on activation** |
| `~/.agents/skills-claude/sec-context/references/ANTI_PATTERNS_DEPTH.md` | ~7600 | Top 7 vulnerabilities, deep dive | Load for specific deep investigation |

**When to load DEPTH:**
- Investigating auth/session vulnerabilities
- Deep dive on injection patterns (SQL, command, XSS)
- Analyzing complex attack scenarios
- Full security audit requiring maximum coverage
