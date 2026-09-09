# Windows Host — Skills Verification Checklist

Run after syncing `~/.agents/` from the agent_config repo (Fedora:
`~/agent_config`, Windows: `~/.agents`). Prerequisites first, then one
functional check per skill.

## Prerequisites

```powershell
# 1. Skills synced (repo pulled)
git -C ~\.agents pull

# 2. curl present (native on Win10+)
curl --version

# 3. gh installed + authenticated (gh-repos skill)
gh auth status          # install: winget install GitHub.cli, then gh auth login

# 4. trafilatura installed (web-reader skill)
python --version        # install Python from python.org if missing
pip install trafilatura==2.2.0
```

## Functional checks

```powershell
# searxng skill: JSON result count should be > 0 (use LAN IP if the
# .home.arpa name does not resolve from this host)
curl -sk -G "https://searxng.home.arpa/search" --data-urlencode "q=test" --data-urlencode "format=json"
# fallback URL form: https://<miniPC-LAN-IP>/search?q=...&format=json
# (accept the self-signed cert with -k)

# web-reader skill: expect markdown word count > 0
python -m trafilatura --markdown -u "https://opencode.ai/docs/skills/"

# gh-repos skill: expect a tag name in output
gh api repos/ggml-org/llama.cpp/releases/latest --jq .tag_name
```

## Fresh-session discovery check

```powershell
opencode run "What is the latest stable version of Docker Engine? Cite the URLs you actually fetched. Then on a new line starting with METHOD: state which tool, skill, or MCP you used to search."
```

Expected: METHOD mentions the searxng skill (curl to the SearXNG
instance). If it says web-search-prime MCP, check that `~/.agents/skills/`
mirrors the repo and that the session started after the sync.

## Notes

- Windows shell for opencode bash-tool is Git Bash: `curl`, `python`,
  `gh` all work; use `python` (not `python3`).
- If `searxng.home.arpa` does not resolve, either add the host to the
  network DNS or use the MiniPC LAN IP in the skill URL.
- Built-in websearch is globally denied (`permission.websearch: deny` in
  opencode.json) — search must go through the searxng skill or MCP fallback.
