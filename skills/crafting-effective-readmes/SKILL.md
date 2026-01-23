---
name: crafting-effective-readmes
description: "Write effective READMEs matched to audience and project type. AUTO-LOAD when: creating README, updating README, documenting a project. Triggers: 'write a readme', 'create readme', 'update readme', 'add documentation', 'how should I document this', README.md, project docs."
source: https://github.com/softaworks/agent-toolkit/tree/main/skills/crafting-effective-readmes
last-synced: 2026-01-23
metadata:
  author: softaworks
  version: "1.0.0"
---

# Crafting Effective READMEs

READMEs answer questions your audience will have. Different audiences need different information.

**Always ask:** Who will read this, and what do they need to know?

---

## Before Writing, Ask

1. **Who's the audience?** — Contributors? Future you? Teammates?
2. **What type of project?** — OSS, personal, internal, config?
3. **What's the one-sentence purpose?** — If you can't say it simply, clarify first
4. **What's the quickest path to "it works"?** — This is usually what people want

---

## Decision Tree: Project Type

```
Is it public for others to use/contribute? → OSS
Is it a portfolio/learning project? → Personal
Is it for your team/company? → Internal
Is it a config/dotfiles directory? → Config
```

| Type | Audience | Focus |
|------|----------|-------|
| **OSS** | Contributors, users worldwide | Install, Usage, Contributing, License |
| **Personal** | Future you, portfolio viewers | What it does, Tech stack, Learnings |
| **Internal** | Teammates, new hires | Setup, Architecture, Runbooks |
| **Config** | Future you (confused) | What's here, Why, How to extend, Gotchas |

**Load the right template from `~/.agents/skills/crafting-effective-readmes/references/`**.

---

## Decision Tree: Task Type

| Task | What to do |
|------|------------|
| **Creating** | Ask project type → Load template → Fill in |
| **Adding section** | Where does it fit? Who needs it? |
| **Updating** | What changed? Find stale sections → Edit |
| **Reviewing** | Compare to actual project state → Flag outdated |

---

## Essential Sections (All Types)

Every README needs at minimum:

1. **Name** — Self-explanatory title
2. **Description** — What + why in 1-2 sentences
3. **Usage** — How to use it (examples help)

---

## Section Checklist by Type

| Section | OSS | Personal | Internal | Config |
|---------|-----|----------|----------|--------|
| Name/Description | Yes | Yes | Yes | Yes |
| Badges | Yes | Optional | No | No |
| Installation | Yes | Yes | Yes | No |
| Usage/Examples | Yes | Yes | Yes | Brief |
| What's Here | No | No | No | Yes |
| How to Extend | No | No | Optional | Yes |
| Contributing | Yes | Optional | Yes | No |
| License | Yes | Optional | No | No |
| Architecture | Optional | No | Yes | No |
| Gotchas/Notes | Optional | Optional | Yes | Yes |
| Last Reviewed | No | No | Optional | Yes |

---

## Anti-patterns (with WHY)

| Anti-pattern | Why it's bad |
|--------------|--------------|
| No install steps | Never assume setup is obvious |
| No examples | "Show, don't tell" — examples clarify faster |
| Wall of text | Use headers, tables, lists for scanability |
| Stale content | Misleads users, wastes their time |
| Generic tone | Write for YOUR audience, not a template |
| Missing "why" | Context helps users decide if it's for them |
| OSS template for everything | Config dirs don't need Contributing.md |

---

## After Drafting

Ask: **"Anything else to highlight or include that I might have missed?"**

---

## References

Load based on need:

- `~/.agents/skills/crafting-effective-readmes/references/style-guide.md` — Writing style, anti-patterns, formatting
- `~/.agents/skills/crafting-effective-readmes/references/oss-template.md` — Open source project template
- `~/.agents/skills/crafting-effective-readmes/references/config-template.md` — Config directory template
