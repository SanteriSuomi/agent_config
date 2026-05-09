# Security Checklist & References
> Appendices of AI Code Security Anti-Patterns (Breadth)

## Pre-Generation Security Checklist

**Before generating ANY code, verify these critical security requirements:**

### ✓ Secrets & Credentials
- [ ] No hardcoded API keys, passwords, tokens, or secrets
- [ ] Credentials loaded from environment variables or secret managers
- [ ] No secrets in client-side/frontend code
- [ ] Git history checked for accidentally committed secrets

### ✓ Input Handling
- [ ] All user input validated on the SERVER side
- [ ] Input type, length, and format constraints enforced
- [ ] Database queries use parameterized/prepared statements
- [ ] Shell commands use argument arrays, not string concatenation
- [ ] File paths validated and canonicalized before use

### ✓ Output Encoding
- [ ] HTML output properly encoded to prevent XSS
- [ ] Context-appropriate encoding (HTML, URL, JS, CSS)
- [ ] Content-Security-Policy header configured
- [ ] Error messages don't expose internal details

### ✓ Authentication & Sessions
- [ ] Passwords hashed with bcrypt/Argon2 (not MD5/SHA1)
- [ ] Session tokens generated with cryptographically secure randomness
- [ ] Session IDs regenerated on authentication state changes
- [ ] Rate limiting on authentication endpoints
- [ ] JWT tokens use strong secrets and explicit algorithms

### ✓ Cryptography
- [ ] Modern algorithms only (AES-GCM, ChaCha20-Poly1305)
- [ ] Keys from environment/secret manager, not hardcoded
- [ ] Unique IVs/nonces for each encryption operation
- [ ] Key derivation uses PBKDF2/Argon2/scrypt

### ✓ File Operations
- [ ] File uploads validate extension, MIME type, and magic bytes
- [ ] File size limits enforced
- [ ] Uploaded files stored outside web root
- [ ] Path traversal prevented with basename + realpath validation
- [ ] Temp files use mkstemp with restrictive permissions

### ✓ API Security
- [ ] All endpoints require authentication (unless explicitly public)
- [ ] Object-level authorization verified (ownership checks)
- [ ] Response DTOs with explicit field allowlists
- [ ] Rate limiting applied to prevent abuse
- [ ] Error responses use standard format without internal details

### ✓ Dependencies
- [ ] Package names verified to exist before importing
- [ ] Dependencies pinned to exact versions with lockfiles
- [ ] No packages with known vulnerabilities
- [ ] Transitive dependencies reviewed

### ✓ Configuration
- [ ] Debug mode disabled in production
- [ ] Default credentials replaced with strong values
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options)
- [ ] CORS restricted to known origins
- [ ] Admin interfaces protected with additional authentication

---

## External References

### OWASP Resources
- **OWASP Top 10 (2021):** https://owasp.org/Top10/
- **OWASP ASVS:** https://owasp.org/www-project-application-security-verification-standard/
- **OWASP Cheat Sheet Series:** https://cheatsheetseries.owasp.org/
- **OWASP Testing Guide:** https://owasp.org/www-project-web-security-testing-guide/

### CWE (Common Weakness Enumeration)
- **CWE Database:** https://cwe.mitre.org/
- **CWE Top 25 (2024):** https://cwe.mitre.org/top25/archive/2024/2024_cwe_top25.html

### CWE References in This Document
| CWE ID | Name | Sections |
|--------|------|----------|
| CWE-16 | Configuration | 7.5 |
| CWE-20 | Improper Input Validation | 6.1-6.6 |
| CWE-22 | Path Traversal | 6.6, 10.1 |
| CWE-59 | Symlink Following | 10.5 |
| CWE-78 | OS Command Injection | 2.2 |
| CWE-79 | Cross-site Scripting (XSS) | 3.1-3.5 |
| CWE-80 | Basic XSS | 3.1-3.5 |
| CWE-89 | SQL Injection | 2.1 |
| CWE-90 | LDAP Injection | 2.3 |
| CWE-117 | Log Injection | Quick Reference |
| CWE-180 | Incorrect Canonicalization | 6.6 |
| CWE-200 | Information Exposure | 9.4 |
| CWE-209 | Error Message Information Exposure | 7.2, 9.6 |
| CWE-215 | Information Exposure Through Debug | 7.1 |
| CWE-259 | Hard-coded Password | 1.1-1.5 |
| CWE-284 | Improper Access Control | 9.1 |
| CWE-287 | Improper Authentication | 4.1-4.7, 9.1 |
| CWE-307 | Brute Force | 4.2 |
| CWE-326 | Inadequate Encryption Strength | 5.1 |
| CWE-327 | Use of Broken Crypto Algorithm | 5.1 |
| CWE-328 | Weak Hash | 5.1 |
| CWE-330 | Insufficient Randomness | 5.6 |
| CWE-346 | Origin Validation Error (CORS) | 7.4 |
| CWE-377 | Insecure Temporary File | 10.4 |
| CWE-384 | Session Fixation | 4.4 |
| CWE-434 | Unrestricted File Upload | 10.2 |
| CWE-494 | Download Without Integrity Check | 8.5 |
| CWE-521 | Weak Password Requirements | 4.1 |
| CWE-613 | Insufficient Session Expiration | 4.4 |
| CWE-639 | Insecure Direct Object Reference | 9.2 |
| CWE-643 | XPath Injection | 2.4 |
| CWE-732 | Incorrect Permission Assignment | 10.6 |
| CWE-759 | Use of One-Way Hash without Salt | 5.7 |
| CWE-770 | Resource Exhaustion (Rate Limiting) | 9.5 |
| CWE-798 | Hard-coded Credentials | 1.1-1.5 |
| CWE-829 | Inclusion of Untrusted Functionality | 8.4 |
| CWE-915 | Mass Assignment | 9.3 |
| CWE-943 | NoSQL Injection | 2.5 |
| CWE-1104 | Use of Unmaintained Components | 8.1 |
| CWE-1284 | Improper Validation of Array Index | 6.3 |
| CWE-1333 | ReDoS | 6.4 |
| CWE-1336 | Template Injection | 2.6 |
| CWE-1357 | Reliance on Insufficiently Trustworthy Component | 8.1-8.6 |

### Additional Security Resources
- **NIST NVD:** https://nvd.nist.gov/
- **Snyk Vulnerability Database:** https://snyk.io/vuln/
- **GitHub Advisory Database:** https://github.com/advisories
- **MITRE ATT&CK:** https://attack.mitre.org/

---

## Document Metadata

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 |
| **Created** | 2026-01-18 |
| **Last Updated** | 2026-01-18 |
| **Coverage** | 10 security domains, 50+ anti-patterns |
| **Format** | Language-agnostic pseudocode |
| **License** | MIT |

### Version History
| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-18 | Initial comprehensive release covering all 10 security domains |

### Contributing
This document is designed to be extended. When adding new anti-patterns:
1. Follow the BAD/GOOD pseudocode format
2. Include CWE references where applicable
3. Add entries to the Quick Reference Table
4. Update the Pre-Generation Checklist if needed

---

## Summary

This document provides comprehensive security anti-pattern guidance across 10 critical domains:

1. **Secrets and Credentials Management** - Preventing credential exposure
2. **Injection Vulnerabilities** - SQL, Command, LDAP, XPath, NoSQL, Template
3. **Cross-Site Scripting (XSS)** - Reflected, Stored, DOM-based
4. **Authentication and Session Management** - Passwords, sessions, JWT, MFA
5. **Cryptographic Failures** - Algorithms, keys, randomness
6. **Input Validation** - Type checking, length limits, ReDoS
7. **Configuration and Deployment** - Debug mode, headers, CORS
8. **Dependency and Supply Chain** - Packages, typosquatting, integrity
9. **API Security** - Auth, IDOR, rate limiting, data exposure
10. **File Handling** - Uploads, path traversal, permissions

**Key Statistics from AI Code Security Research:**
- AI-generated code has an **86% XSS failure rate**
- **5-21% of AI-suggested packages don't exist** (slopsquatting)
- AI code is **2.74x more likely** to have XSS vulnerabilities
- **21.7% hallucination rate** for package names in some domains

**Remember:** Security is not optional. Every line of generated code should follow these secure patterns by default.

---

*Generated for use as an LLM system prompt, RAG context, or security reference document.*
*Compatible with any language - implement pseudocode patterns in your target framework.*
