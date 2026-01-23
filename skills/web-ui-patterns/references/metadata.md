# Metadata Reference

SEO, Open Graph, and structured data rules.

---

## Before Setting Metadata, Ask

1. **Is this page shareable?** — Needs full OG tags
2. **Is this page indexable?** — Check robots, canonical
3. **What's the canonical URL?** — One source of truth
4. **Is there user-generated content?** — Escape/sanitize

---

## Correctness (critical)

- Define metadata in one place per page — no competing systems
- No duplicate title, description, canonical, or robots tags
- Metadata must be deterministic (no random values)
- Escape/sanitize user-generated strings
- Every page needs safe defaults for title and description

## Title & Description (high)

- Every page must have a title
- Consistent title format across site (e.g., "Page | Site")
- Keep titles short and readable (<60 chars ideal)
- Shareable pages need meta description
- Descriptions must be plain text (<160 chars ideal)

## Canonical & Indexing (high)

- Canonical must point to preferred URL
- Use `noindex` only for private/duplicate/non-public pages
- Robots meta must match actual access intent
- Staging/preview pages should be noindex
- Paginated pages need correct canonical behavior

## Social Cards (high)

- Shareable pages need: `og:title`, `og:description`, `og:image`
- OG and Twitter images use **absolute URLs**
- Correct image dimensions (1200×630 for OG, 1200×600 for Twitter)
- `og:url` must match canonical
- Use sensible `og:type` (usually `website` or `article`)
- Set `twitter:card` appropriately (`summary_large_image` default)

## Icons & Manifest (medium)

- Include favicon that works across browsers
- Include `apple-touch-icon` when relevant
- Manifest must be valid and referenced
- Set `theme-color` intentionally to match page
- Stable, cacheable icon paths

## Structured Data (medium)

- Add JSON-LD only if it maps to real page content
- JSON-LD must be valid and reflect rendered content
- Never invent ratings, reviews, prices, or organization details
- One structured data block per page unless required

## Locale & i18n

- Set `html lang` attribute correctly
- Set `og:locale` when localization exists
- Add `hreflang` alternates only when pages truly exist
- Localized pages must canonicalize correctly per locale

## Dark Mode & Theming

- `color-scheme: dark` on `<html>` for dark themes
- `<meta name="theme-color">` matches page background
- Native `<select>`: explicit `background-color` and `color`

## Common Mistakes

| Mistake | Why it's bad |
|---------|--------------|
| Relative OG image URL | Won't display in social previews |
| Missing canonical | Duplicate content issues |
| Dynamic/random metadata | Inconsistent SEO, caching issues |
| `og:url` ≠ canonical | Confuses crawlers |
| Missing `lang` attribute | Screen readers use wrong pronunciation |
