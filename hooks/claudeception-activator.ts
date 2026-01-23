/**
 * Claudeception Auto-Activation Plugin (OpenCode)
 * Injects reminder to evaluate session for extractable knowledge.
 *
 * Setup: Copy to ~/.config/opencode/plugins/ or add to opencode.jsonc:
 *   "plugins": ["~/.agents/hooks/claudeception-activator.ts"]
 */

const REMINDER = `
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 SKILL EVALUATION REMINDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

After completing this request, evaluate:
- Non-obvious debugging or investigation?
- Reusable solution for future situations?
- Discovery not obvious from documentation?

If YES to any → Use Skill(continuous-learning) to extract knowledge.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
`;

export default async () => ({
  "message.updated": async (input: any, output: any) => {
    if (input?.role === "user") {
      return { ...output, systemContext: (output?.systemContext || "") + REMINDER };
    }
    return output;
  },
  "session.compacted": async (_input: any, output: any) => {
    return { ...output, additionalContext: REMINDER };
  }
});
