# Writing Style (Anti-Slop)

Remove AI-generated writing patterns. But avoiding AI patterns is only half the job — sterile, voiceless writing is just as obvious as slop.

**Source:** Based on Wikipedia's "Signs of AI writing" guide (WikiProject AI Cleanup)

---

## Personality and Soul

Good writing has a human behind it. Clean but soulless writing is still obviously AI.

### Signs of soulless writing:
- Every sentence same length and structure
- No opinions, just neutral reporting
- No acknowledgment of uncertainty or mixed feelings
- No first-person perspective when appropriate
- No humor, edge, or personality
- Reads like a Wikipedia article or press release

### How to add voice:

**Have opinions.** Don't just report — react. "I genuinely don't know how to feel about this" beats neutrally listing pros and cons.

**Vary rhythm.** Short punchy sentences. Then longer ones that take their time. Mix it up.

**Acknowledge complexity.** Real humans have mixed feelings. "This is impressive but also unsettling" beats "This is impressive."

**Use "I" when it fits.** First person isn't unprofessional — it's honest. "Here's what gets me..." signals a real person thinking.

**Let some mess in.** Perfect structure feels algorithmic. Tangents and half-formed thoughts are human.

**Be specific about feelings.** Not "this is concerning" but "there's something unsettling about agents churning away at 3am while nobody's watching."

### Example

**Before (clean but soulless):**
> The experiment produced interesting results. The agents generated 3 million lines of code. Some developers were impressed while others were skeptical. The implications remain unclear.

**After (has a pulse):**
> I genuinely don't know how to feel about this one. 3 million lines of code, generated while the humans presumably slept. Half the dev community is losing their minds, half are explaining why it doesn't count. The truth is probably somewhere boring in the middle — but I keep thinking about those agents working through the night.

---

## Content Patterns to Avoid

| Pattern | Example | Fix |
|---------|---------|-----|
| Inflated significance | "groundbreaking", "transformative" | State facts without superlatives |
| Overclaiming | "widely acclaimed", "universally recognized" | Remove or cite source |
| Superficial -ing analysis | "showcasing", "highlighting" | Use concrete verbs |
| Promotional tone | "exceptional", "state-of-the-art" | Describe, don't advertise |
| Vague attribution | "experts say", "studies show" | Cite specific sources or remove |
| Formulaic challenges | "Despite challenges..." as filler | Only if genuinely relevant |
| Generic positive endings | "The future looks bright" | Be specific or cut |
| Media list without context | "Featured in NYT, BBC, CNN" | Say what was covered |

### Examples

**Inflated significance:**
> The framework serves as a testament to the team's commitment to innovation, marking a pivotal moment in the evolution of frontend development.

→ The framework adds server components and streaming. It released in March 2024.

**Vague attribution:**
> Experts believe this will have a lasting impact on the entire sector.

→ A 2024 Gartner report predicts 40% adoption by 2026.

**Generic positive ending:**
> The future looks bright for the company. Exciting times lie ahead as they continue their journey toward excellence.

→ The company plans to open two more locations next year.

---

## Language Patterns to Avoid

| Pattern | Bad | Good |
|---------|-----|------|
| Copula avoidance | "serves as", "functions as" | "is" |
| Negative parallelism | "not just X, but Y" | "X and Y" or state directly |
| Rule of three | Always listing 3 things | Vary: 1, 2, 4, 5 items |
| Synonym cycling | "happy, joyful, elated" | Pick one word |
| False ranges | "from X to Y" when unnecessary | Be specific or drop |

### Examples

**Copula avoidance:**
> Gallery 825 serves as LAAA's exhibition space. The gallery features four rooms and boasts 3,000 square feet.

→ Gallery 825 is LAAA's exhibition space. It has four rooms totaling 3,000 square feet.

**Rule of three:**
> The event features keynote sessions, panel discussions, and networking opportunities. Attendees can expect innovation, inspiration, and industry insights.

→ The event includes talks and panels. There's time for networking between sessions.

**False ranges:**
> Our journey takes us from the singularity of the Big Bang to the grand cosmic web, from the birth and death of stars to the enigmatic dance of dark matter.

→ The book covers the Big Bang, star formation, and dark matter theories.

---

## Overused AI Words

**Avoid:** delve, crucial, vital, essential, significant, notably, moreover, furthermore, comprehensive, robust, seamless, cutting-edge, innovative, leverage, utilize, facilitate, streamline, harness, foster, enhance, bolster, underscore, multifaceted, intricate, nuanced, paradigm, synergy, holistic, tapestry, landscape (abstract), pivotal, testament, enduring, vibrant, nestled

**Use instead:** Direct, simple words. "Important" not "crucial". "Use" not "utilize". "Show" not "showcase".

---

## Style Patterns to Avoid

| Pattern | Issue |
|---------|-------|
| Em dash overuse | One per paragraph max |
| Excessive bold | For emphasis, not decoration |
| Formatted lists with colons | "**Item:** description" — often unnecessary |
| Title Case in Headings | Use sentence case |
| Decorative emojis | Only if explicitly requested |
| Curly quotes | Use straight quotes in code/docs |

### Example

**Before:**
> - **User Experience:** The UX has been significantly improved
> - **Performance:** Performance has been enhanced
> - **Security:** Security has been strengthened

→ The update improves the interface, speeds up load times, and adds encryption.

---

## Filler to Remove

| Filler | Action |
|--------|--------|
| "In order to" | → "To" |
| "It's important to note that" | Delete, just state it |
| "As you can see" | Delete |
| "Let me explain" | Delete, just explain |
| "Basically" / "Actually" / "Simply" | Delete |
| "Obviously" | Delete — if obvious, don't say it |
| "Due to the fact that" | → "Because" |
| "At this point in time" | → "Now" |
| "Has the ability to" | → "Can" |

---

## AI Artifacts to Remove

- "As of my knowledge cutoff..."
- "I don't have access to real-time..."
- "Based on the information provided..."
- "While specific details are limited..."
- Sycophantic openers: "Great question!", "Excellent point!"
- Excessive hedging: "could potentially possibly", "might have some effect"
- Meta-commentary: "I think", "In my opinion" (unless asked)

---

## What Good Writing Looks Like

- **Specific** — Concrete details, not vague generalizations
- **Direct** — Start with the point, not wind-up
- **Varied** — Different sentence lengths and structures
- **Active** — "The function returns X" not "X is returned"
- **Honest** — Acknowledge limitations, don't oversell
- **Opinionated** — Take a stance when appropriate
- **Human** — Has voice, personality, occasional imperfection

---

## Full Example

**Before (AI-sounding):**
> The new software update serves as a testament to the company's commitment to innovation. Moreover, it provides a seamless, intuitive, and powerful user experience — ensuring that users can accomplish their goals efficiently. It's not just an update, it's a revolution in how we think about productivity. Industry experts believe this will have a lasting impact on the entire sector, highlighting the company's pivotal role in the evolving technological landscape.

**After (humanized):**
> The update adds batch processing, keyboard shortcuts, and offline mode. Early feedback from beta testers has been positive — most report faster task completion. Whether it changes anything long-term, who knows. But the keyboard shortcuts alone sold me.

**What changed:**
- Removed "serves as a testament" (inflated)
- Removed "Moreover" (AI word)
- Removed "seamless, intuitive, and powerful" (rule of three + promotional)
- Removed "It's not just...it's..." (negative parallelism)
- Removed "Industry experts believe" (vague attribution)
- Removed "pivotal role", "evolving landscape" (AI vocabulary)
- Added specific features and honest opinion

---

## Application

Use when writing:
- Documentation
- Comments
- Commit messages
- UI copy
- Error messages
- README files
- Any user-facing text
