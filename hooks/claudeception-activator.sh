#!/bin/bash

# Claudeception Auto-Activation Hook (Claude Code)
# Injects reminder to evaluate session for extractable knowledge.
#
# Setup: Add to ~/.claude/settings.json:
#   "hooks": {
#     "PostToolUse": [{
#       "matcher": ".*",
#       "hooks": ["bash ~/.agents/hooks/claudeception-activator.sh"]
#     }]
#   }

cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧠 SKILL EVALUATION REMINDER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

After completing this request, evaluate:
- Non-obvious debugging or investigation?
- Reusable solution for future situations?
- Discovery not obvious from documentation?

If YES to any → Use Skill(continuous-learning) to extract knowledge.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
