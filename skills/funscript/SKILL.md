---
name: funscript
description: "Organize funscript+video pairs across the NSFW collection: download from EroScripts/MEGA/torrents, match scripts to videos, classify into library categories, handle VR tags, and upload. Triggers: funscript, eroscripts, organize nsfw, match scripts, VR tags, XBVR, HMV, PMV, cock hero, JAV VR."
---

# Funscript Workflow

Source, match, classify, and organize funscript+video pairs across the NSFW collection.

$ARGUMENTS

---

## Quality Priority

**Always prioritize best quality when downloading:**

1. **Resolution:** Prefer highest available (8K > 6K > 5K > 4K > etc.)
2. **Merged over separate:** One concatenated file > bundled multi-part > separate files
3. **3D/VR conversions:** If a 3D VR conversion exists, download that instead of flat 2D
4. **Codec:** Prefer H.265/HEVC > AV1 > H.264 (compatibility with players)
5. **Stereo:** 3D/SBS > 2D when available
6. Check comments on the source thread for improved/upscaled script versions

**When multiple versions are offered on the source page:**
- Check for "3D VR conversion", "VR version", "180°/360° version"
- These are typically separate download links on the same post
- Download the VR version when available, not the flat 2D version

---

## Paths

| Location | Path | Contents |
|----------|------|----------|
| Downloads | `~/Downloads/` | Incoming files |
| Batch scripts | `~/Downloads/eroscripts_batch/` | Bulk-downloaded funscripts |
| XBVR | `/mnt/nsfw_1/XBVR/` | VR with scripts |
| Animations | `/mnt/nsfw_1/Animations/` | SFM/CGI/Blender |
| HMV PMV | `/mnt/nsfw_1/HMV PMV/` | Music videos |
| Fap Cock Hero | `/mnt/nsfw_1/Fap Cock Hero/` | Rhythm games |
| Non-XBVR | `/mnt/nsfw_1/Non-XBVR/` | Real non-VR |

**Managed library = these 5 categories only** (XBVR, Animations, HMV PMV, Fap Cock Hero, Non-XBVR). All flat.

### UNMANAGED folders (excluded from all library operations)

These top-level folders under `/mnt/nsfw_1/` are **excluded from orphan detection, duplicate scanning, corruption scans, classification, and cleanup**. Treat them as cold storage. Only reference them if the user explicitly asks.

- **`Non-Funscript/`** — holding area for downloaded content archives (incl. `Content/Hentai VR vault/`, `Normal/`, `Yiff/`).
- **`_orphans/`** — unmatched funscripts (scripts whose videos aren't in the library; e.g., paid-VR scripts awaiting a video source). Kept for possible future pairing.
- **`_inactive/`** — superseded complete video+script pairs kept as backup (e.g., scene parts retired in favor of a full movie).

**Cleanup rule:** NEVER delete from `~/Downloads/` — user manages that folder.

---

## Prerequisites

```bash
ffprobe -version >/dev/null 2>&1 || echo "ERROR: Install FFmpeg"
jq --version >/dev/null 2>&1 || echo "ERROR: Install jq"
pip3 show browser_cookie3 >/dev/null 2>&1 || pip3 install --break-system-packages browser_cookie3
```

MEGA: `megajs-cli` for individual files, `megacmd` (RPM: `megacmd`) for folders.

> **Credentials** (EroScripts, PornoLab, MEGA, Pixeldrain) live in TOOLS.md / password manager — not in this file.

---

## Eroscripts Downloads

### Cookie-based download (preferred for batch)

```python
import browser_cookie3, requests

cj = browser_cookie3.chrome(
    cookie_file="/home/ssuomi/.openclaw/browser/clawd/user-data/Default/Cookies"
)
cookies = {c.name: c.value for c in cj if hasattr(c, 'name')}

# Download funscript
r = requests.get(url, cookies=cookies)
data = r.content
```

**⚠️ Null-byte padding:** EroScripts funscript downloads may be null-padded to power-of-2 sizes (e.g., 16384 bytes). Always strip trailing nulls before writing:

```python
clean = data.rstrip(b'\x00')
```

Validate after stripping: `data.startswith(b'{')`

### Funscript validation

Always validate downloaded files — some URLs return HTML login pages (~44KB) instead of scripts:

```python
is_valid = (
    data.startswith(b'{') and
    (b'"actions"' in data or b'"version"' in data)
)
```

### Batch thread processing

1. Fetch thread JSON: `https://discuss.eroscripts.com/t/{ID}.json`
2. Extract all `.funscript` (and multi-axis) upload URLs from posts
3. Download with cookies + validate each
4. If filenames are hashed, extract display names from HTML and rename

### One script per video rule

**Only keep ONE funscript per video** — the most "average" (middle-of-the-road) version. When multiple scripts exist for the same video:
1. Pick the median action count / file size (avoid extremes — too few actions = lazy, too many = overdone)
2. Trash all other versions (including multi-axis variants like .pitch, .roll, .surge, .sway, .twist)
3. Rename the kept script to match the video filename exactly

### Multi-axis scripts

Download all axis files from a thread initially (to have options), then reduce to one:

| Suffix | Axis | Motion | Alt Names |
|--------|------|--------|-----------|
| `.funscript` | L0 | Primary up/down stroke | `.stroke`, `.L0` |
| `.surge` | L1 | Forward/backward | `.L1` |
| `.sway` | L2 | Left/right | `.L2` |
| `.twist` | R0 | Rotational twist | `.R0` |
| `.roll` | R1 | Roll left/right | `.R1` |
| `.pitch` | R2 | Tilt forward/backward | `.R2` |
| `.vib` | V0 | Vibration intensity | `.V0` |
| `.valve` | V1 | Suction/valve control | - |
| `.suck` | V2 | Suction pump | - |

Multi-axis extensions (`.pitch.funscript`, etc.) create **false orphans** under base-name matching — they are NOT orphaned.

**Script variant suffixes (intensity variations, not axes):** `.soft`, `.hard` (stroke range), `.handy` (Handy device limits), `.bj` (limited oral strokes).

### Patreon detection

If thread title or early posts mention "Patreon", flag as **blocked** immediately. Do not scrape further.

### Auto-Download Rule

**When Santeri shares eroscripts thread links, always automatically:**
1. Scan all posts in the thread for funscript uploads and video source links
2. Download all funscripts immediately (small, fast)
3. Start downloading videos from available sources (MEGA, Gofile, torrents)
4. Report what was found, downloaded, and any blockers (dead links, premium required, etc.)

Don't ask permission — just do it. Report results after.

**Blocked sources (no auto-download possible):**
- Dead MEGA links (verify via browser before downloading)
- Patreon-gated content

For blocked sources, report and move on.

### EroScripts Login

- Credentials are in TOOLS.md / password manager (account + 2FA).
- **Session:** Browser profile `clawd` with `browser_cookie3`
- **Private threads:** Return 404 without login — must use browser
- **Cookie-based download:** `_forum_session` + `_t` cookies from clawd browser profile
- **Sessions expire:** `_t` has expiry, `_forum_session` is session-only. If expired: log in via browser (openclaw profile), then extract fresh cookies with `browser_cookie3`. May need 2FA backup codes (in TOOLS.md).
- **Tip:** Gofile API returns `error-notPremium` but browser UI works — use browser to get direct download URL, then pass gofile cookies via `requests`

### Gofile Download (when API says premium-required)
1. Navigate to gofile folder in browser (clawd profile)
2. Hook `document.createElement('a')` to capture download URLs on click
3. Extract cookies via `browser_cookie3` for `gofile.io` domain
4. Download via `requests.get(url, cookies=gofile_cookies, stream=True)`

Or use `gofile-downloader` (Python CLI) which handles token creation and premium-gated files:
```bash
pip3 install --break-system-packages -r /tmp/gofile-downloader/requirements.txt
# git clone https://github.com/ltsdw/gofile-downloader.git /tmp/gofile-downloader
GF_DOWNLOAD_DIR="/path" python3 /tmp/gofile-downloader/gofile-downloader.py https://gofile.io/d/CONTENTID
python3 /tmp/gofile-downloader/gofile-downloader.py https://gofile.io/d/CONTENTID password   # with password
python3 /tmp/gofile-downloader/gofile-downloader.py urls.txt                               # batch from file
```

**Note:** gofile-downloader creates a guest account token automatically and downloads concurrently. Large files (10GB+) combined with MEGA downloads may cause OOM on this machine (shared memory APU) — run sequentially if needed.

---

## Video Sourcing

**Priority:** Prowlarr → PornoLab → MEGA → Direct download

### Prowlarr (API)

```bash
API_KEY=$(grep -oP 'ApiKey>\K[^<]+' /opt/dockerdata/prowlarr/config.xml)

# Search
curl -s "http://localhost:8501/api/v1/search?query=studio+scene&type=search" \
  -H "X-Api-Key: $API_KEY" | jq '.[] | {title, size, seeders, magnetUrl, guid}'

# Available indexers
curl -s "http://localhost:8501/api/v1/indexer" -H "X-Api-Key: $API_KEY" | jq '.[].name'
```

**Search strategy:** studio+scene → studio+performer → scene+vr → eroscripts thread links. Sort by seeders for healthy torrents.

**When Prowlarr returns `magnet=false`:** Check the `guid` field — it often contains a direct `.torrent` download URL with auth tokens. Download the file with `curl -o` and add via file upload.

### qBittorrent

**Endpoint:** `http://localhost:8506` (routed through gluetun VPN)
**⚠️ Don't specify custom savepath** — qBittorrent runs in a container; use the default path.

```bash
# From magnet
curl -s -X POST "http://localhost:8506/api/v2/torrents/add" \
  --data-urlencode "urls=$MAGNET" -d "category=XBVR"

# From .torrent file (when no magnet available — e.g. HappyFappy, PornoLab)
curl -s -X POST "http://localhost:8506/api/v2/torrents/add" \
  -F "torrents=@/path/to/file.torrent" -F "category=XBVR"

# List active / details / pause / delete
curl -s "http://localhost:8506/api/v2/torrents/info" | jq '.[] | {name, progress, state}'
curl -s "http://localhost:8506/api/v2/torrents/info?hashes=HASH" | jq .
curl -X POST "http://localhost:8506/api/v2/torrents/pause" -d "hashes=HASH"
curl -X POST "http://localhost:8506/api/v2/torrents/delete" -d "hashes=HASH&deleteFiles=true"
```

### MEGA downloads

**Preferred: megacmd** — handles large files and folders reliably, supports public links.
```bash
mega-login "EMAIL" 'PASSWORD'           # one-time, session persists (creds in TOOLS.md)
mega-get "https://mega.nz/file/XXXX#YYYY" /tmp/download/    # single file (public link)
mega-get "https://mega.nz/folder/XXXX#YYYY" /tmp/download/  # folder (public link)
mega-get "/Folder Name" /tmp/download/                      # folder from own account
```

**MEGA public folder links — verification:**
- Always verify public folder links before attempting download
- Open in browser first — dead/deleted folders show "Folder cannot be accessed"
- `mega-ls` cannot handle public folder URLs directly (expects mounted paths)
- MEGA API returns error -9 for public folders without proper decryption
- If the link is dead, check the thread for re-uploads or alternative hosts (gofile, pixeldrain); thread posts after the original may contain re-up links

**megajs-cli** works for small files but fails on large files (MAC verification error). Use `megacmd` instead.

**rclone** — alternative, requires configured `mega:` remote.
```bash
rclone about mega:  # verify auth
rclone copy mega:Path/ /mnt/nsfw_1/Dest/ --buffer-size 8M --no-check-certificate
```

**⚠️ OOM issue:** When swap is full (8GB swap on this machine), MEGA downloads get OOM-killed even with 124GB RAM. Check `free -h` — if swap is 100%, stop qBittorrent (uses 23GB) before downloading, then restart. megacmd handles crypto more efficiently than megajs-cli and is less likely to OOM when logged in.

### Pixeldrain

```bash
# API with auth cookie (required — returns 500 without pd_auth_key)
python3 -c "
import browser_cookie3, requests
cj = browser_cookie3.chrome(domain_name='pixeldrain.com', cookie_file='/home/ssuomi/.openclaw/browser/clawd/user-data/Default/Cookies')
cookies = {c.name: c.value for c in cj if hasattr(c, 'name')}
r = requests.get('https://pixeldrain.com/api/file/{ID}', cookies=cookies, stream=True)
with open('output.mp4', 'wb') as f:
    for chunk in r.iter_content(65536): f.write(chunk)
"

# Info endpoint (works without auth)
curl -s "https://pixeldrain.com/api/file/{ID}/info" | jq '.name, .size'
```

**Note:** Pixeldrain API returns HTTP 500 without the `pd_auth_key` cookie. Always extract cookies from the openclaw browser profile via `browser_cookie3`.

### PornoLab

Requires login (credentials in TOOLS.md).
- Magnet links don't work in qBittorrent (requires site auth)
- Must download `.torrent` file via browser, then upload to qBittorrent
- HTTP requests with cookies return 200 but serve HTML login page (not actual torrent)
- PornoLab likely binds sessions to IP — `bb_data` cookie appears valid per expiry but doesn't work for programmatic requests
- **Browser login works** — use openclaw profile to log in, then download `.torrent` via browser UI

### HappyFappy (PornoLab alternative)

`.torrent` download URLs with auth tokens work directly via `requests.get()` — no browser needed. Good fallback when PornoLab browser auth is problematic.

```python
import requests
r = requests.get(torrent_url)
with open('/tmp/file.torrent', 'wb') as f:
    f.write(r.content)
```

### EroScripts login (sourcing)

- Private threads return 404 via `web_fetch` — must use browser
- If session expired: log in via browser (openclaw profile), then use `browser_cookie3` to extract fresh cookies
- **2FA:** May require backup codes (in TOOLS.md). TOTP secret in password manager is preferred

### Blocked sources

- **Proton Drive** — requires JS rendering
- **Gofile** — some files require premium
- **PornoLab magnets** — qBittorrent can't connect (auth required)
- **Browser blob URLs** — `navigation` to `blob:` protocol is blocked; cannot extract downloads from JS-generated blob URLs
- **HTTPS→HTTP mixed content** — browser on HTTPS page cannot fetch/post to localhost HTTP (WebSocket, fetch, etc.)
- **Headless Chrome** — rejects self-signed certs, no way to bypass from page context

### Direct Downloads

```bash
curl -L -o "~/Downloads/script.funscript" "https://example.com/script.funscript"
curl -L -OJ "https://example.com/file.funscript"               # original filename
aria2c -x 16 -d ~/Downloads/ "https://example.com/large_video.mp4"  # multi-connection
```

---

## Long-running Downloads & Heartbeat

**Rule:** <2 min → do it now. Hours → hand off to heartbeat/cron.

**⚠️ ALWAYS use heartbeat for download monitoring unless explicitly told otherwise.**

**Pattern:**
1. Add torrent/start download
2. Download funscript immediately (small, do now)
3. Add entry to HEARTBEAT.md with identifiers
4. Heartbeat monitors → when complete: rename, classify, copy, notify Discord, remove entry

### Torrent monitoring

```bash
# Get hash after adding
curl -s "http://localhost:8506/api/v2/torrents/info?filter=downloading" | jq -r '.[-1] | "\(.hash) \(.name)"'
# Check status on each heartbeat
curl -s "http://localhost:8506/api/v2/torrents/info?hashes=HASH" | jq '.[0] | {name, progress, state}'
```

When `progress` equals `1` (or `state` is `"completed"`/`"seeding"`): rename with VR tags if needed, run upload workflow, notify, remove heartbeat line.

**HEARTBEAT.md entry (torrent):**
```markdown
- Torrent: [HASH] [FILENAME] (~X.XGB, category: [XBVR/Animations/etc]). Check qBittorrent API (progress=1). When complete: rename with VR tags, upload pair to /mnt/nsfw_1/[CATEGORY]/, notify "[FILENAME] uploaded to [CATEGORY]/", remove this line.
```

### Mega browser-download monitoring

Mega downloads decrypt to browser cache before saving. Heartbeat should:
```bash
find ~/.openclaw/browser/clawd/user-data/Default/File\ System -type f -size +100M -mmin -60 2>/dev/null
```
When a matching file appears: copy to `~/Downloads/` with proper name + VR tags, delete cache, run upload workflow, notify, remove line.

**HEARTBEAT.md entry (Mega):**
```markdown
- Mega download: [FILENAME] (~X.XGB, category: [XBVR/Animations/etc]). Check browser cache (~/.openclaw/browser/clawd/user-data/Default/File System -size +XXXM). When found: copy to ~/Downloads/[FINAL_NAME_WITH_VR_TAGS].mp4 + matching .funscript, delete cache, upload pair to /mnt/nsfw_1/[CATEGORY]/, notify "[FILENAME] uploaded to [CATEGORY]/", remove this line.
```

### Large direct-download monitoring

```bash
nohup aria2c -x 16 -d ~/Downloads/ -o "video.mp4" "URL" > /tmp/dl_video.log 2>&1 &
echo $! > /tmp/dl_video.pid
# Check
ps -p $(cat /tmp/dl_video.pid 2>/dev/null) >/dev/null 2>&1 && echo running || echo finished
stat -c%s ~/Downloads/video.mp4 2>/dev/null || echo 0
```
Completion = process gone AND file size stable for 2 checks. Then rename, cleanup `/tmp/dl_video.{pid,log}`, upload, notify, remove line.

**HEARTBEAT.md entry (direct):**
```markdown
- Direct download: [FILENAME] (~X.XGB, pid:/tmp/dl_NAME.pid, category: [XBVR/Animations/etc]). Check ~/Downloads/. When complete: rename with VR tags, cleanup /tmp files, upload pair to /mnt/nsfw_1/[CATEGORY]/, notify "[FILENAME] uploaded to [CATEGORY]/", remove this line.
```

---

## Matching Strategy

**Video extensions:** `.mp4`, `.mkv`, `.avi`, `.wmv`, `.webm`, `.m4v`, `.mov`
**Script extensions:** `.funscript`, `.pitch`, `.roll`, `.twist`, `.surge`, `.sway`

### ⚠️ Case-insensitive filesystem

The NSFW collection is on a CIFS mount (`/mnt/nsfw_1/`) which is **case-sensitive**. Many files have inconsistent casing between funscript and video (e.g., `kinkvr_Hook_Up.funscript` vs `KinkVR_Hook_Up.mp4`). **Always use case-insensitive matching** when checking for pairs.

**Recommended approach:** Use Python for matching — it handles special characters in filenames (quotes, brackets, backslashes) reliably:

```python
import os, re

def find_video_for_script(script_path, dir_path):
    """Find matching video for a funscript, case-insensitive."""
    base = os.path.splitext(os.path.basename(script_path))[0]
    # Strip multi-axis suffixes (.anal, .mono, .pitch, .roll, .surge, .sway, .twist)
    for suffix in ['.anal', '.mono', '.pitch', '.roll', '.surge', '.sway', '.twist']:
        if base.endswith(suffix):
            base = base[:-len(suffix)]
            break
    pattern = re.escape(base) + r'\.(mp4|mkv|webm|m4v|avi|wmv|mov)$'
    for f in os.listdir(dir_path):
        if re.match(pattern, f, re.IGNORECASE):
            return os.path.join(dir_path, f)
    return None
```

**Do NOT use bash `[ -f "$base.mp4" ]` for matching** — it is case-sensitive and breaks on filenames with quotes, brackets, and special characters.

Priority order:
1. **Exact match** — same base filename, case-insensitive (use Python)
2. **Partial match** — common prefix/substring (e.g., VRKM-1344)
3. **Fuzzy match** — `token_set_ratio > 70%` after normalization
4. **Duration match** — video duration vs funscript last action (±30s)
5. **Vision match** — extract a frame, use vision to identify content (last resort)

```bash
# Video duration (seconds)
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 video.mp4

# Funscript duration (ms → seconds)
jq -r '(.metadata.duration // (.actions | map(.at) | max)) / 1000' file.funscript
```

### Fuzzy matching pitfalls

- **Multi-axis scripts** create false orphans (e.g., `scene.pitch.funscript` has no `scene.pitch.mp4` — expected)
- **Similar but different scenes** — "Ultimate Tiktok 2" vs "Ultimate Petite 2" will score high but are different
- **Threshold:** 70% is good for finding candidates, but always verify before renaming
- **False positive pattern:** different creators making similar-named content
- **Encoded filenames:** Decode URL-encoded chars (`%20` → space) before matching
- **Trailing numbers:** `video (1).mp4` likely duplicates — compare size/duration/hash

---

## Categorization

### Decision tree

```
**Category follows CONTENT TYPE, not VR-ness.** VR is a format, not a category. Only real-person VR studio scenes go to XBVR; VR animations/PMVs/fap-heroes stay with their content type.
1. Real-person VR? (VR studio scene: SLR/BaDoinkVR/WankzVR/VRCosplayX/VRHush/VRSpy/CzechVR/etc. prefix, real performers, _180/_SBS/_3dh tags, sv3d/st3d boxes) → XBVR/
   **NOT** for VR animations (→ step 4) or VR-converted PMVs (→ step 2)
2. PMV/HMV? (HMV, PMV, known PMV creator, continuous music track, multi-scene edit; INCLUDES VR-converted PMVs — keep VR tags in filename) → HMV PMV/
   UNCERTAIN? → Research the creator name, then ask user if still unclear
3. Fap/Cock Hero? (Fap Hero, Cock Hero, BPM Training, Edge Hero, Beat; INCLUDES VR-converted fap heroes) → Fap Cock Hero/
4. Animation? (known animator, game char, SFM/CGI/Blender/3D style; INCLUDES VR animations — keep VR tags in filename) → Animations/
   UNCERTAIN about creator? → Research the name first
5. Real non-VR footage? → Non-XBVR/
6. Uncertain? → Research (web search, eroscripts), then ask as last resort
7. No funscript match → Report only, DO NOT move
```

### Abbreviations

CH/FH → `Fap Cock Hero/` | HMV/PMV → `HMV PMV/` | SFM → `Animations/` | JOI/CEI → `Non-XBVR/`

### Known VR studios (filename prefixes)

> **Note:** These lists are NOT exhaustive. If a name isn't listed, research it before assuming it's not a valid creator/studio/character. New creators emerge constantly.

**Western:**
SLR_, SLROriginals_, VirtualTaboo_, RealJamVR_, VRCosplayX_, WankzVR_, VRBangers_, BadoinkVR_, BaDoinkVR_, NaughtyAmericaVR_, VRHush_, CzechVR_, CzechVRFetish_, CzechVRCasting_, VRLatina_, VRConk_, LethalHardcoreVR_, MilfVR_, WetVR_, VRedging_, VRIntimacy_, SexBabesVR_, StasyQVR_, TmwVRnet_, VRSexperts_, 18VR_, BrasilVR_, DarkRoomVR_, HoloGirlsVR_, KinkVR_, LustReality_, PerVRt_, POVcentral_, RealVR_, SinsVR_, VirtualPorn_, VirtualRealPorn_, VirtualRealPassion_, VirtualRealTrans_, VirtualRealGay_, VRClubz_, VRSpy_, POVR_, VRAllure_, VRPFilms_, SwallowBay_, RealHotVR_, VRFootFetish_, OnlyTease_, WhorecraftVR_, VRPornJack_, VRSexyGirlz_, FuckPassVR_, TransVR_, BabeVR_, DDFNetworkVR_

**JAV VR:**
| Prefix | Studio |
|--------|--------|
| SIVR-/3DSVR- | SOD Create |
| VRKM-/KMVR- | KMPVR |
| DSVR- | Das! VR |
| JUVR- | Moodyz VR |
| KAVR- | Kawaii* VR |
| MDVR- | Madonna VR |
| WAVR- | Wan Factory |
| AJVR-/AVVR-/CRVR-/IPVR- | Various |
| BIBIVR-, CAFR-, CBIKMV-, CCVR-, CJVR-, COSVR-, DOCVR-, EBVR-, FSVR-, GOPJ-, HNVR-, NKKVR-, NHVR-, PPVR-, PRDVR-, PRVR-, PXVR-, SAVR-, SPIVR-, TMAVR-, URVRSP-, VRRB-, WABB-, WAVR-, WVR8- | Various |

**JAV regex:** `\b(SIVR|VRKM|3DSVR|DSVR|JUVR|KAVR|KMVR|MDVR|WAVR|AJVR|AVVR|CRVR|IPVR)[-_]?\d{3,4}\b`

### Known Animators

**High activity:**
Derpixon, Eipril, ENarane, Nagoonimation, NoduSFM, ZonkPunch, Megaera, HydraFXX, Lewdgazer, Magikal3D, AxenAnim, Bamh3D, GeckoCGI, Redmoa, LewdFraggy, Fpsblyck, GeneralButch, ceno0

**Medium activity:**
AANiX, AidenHet, Aphy3D, Captain Popcorn, Drills3D, DTee3D, Evilbaka, FOW, HornyHerring, IckySticky, LazyProcrastinator, Maiden Masher, Maplestar, MastaPov, Matchattea, Miwo, Rinhee, Rwt4184, SaltyIceCream, Sutekimeppou, TDonTran, Theobrobine, Toastedmw, Ubermation, Viciousfox, Visualoos, Wildeer Studio, Wutboi, Z1g3D, ZMSFM, Bulgingsenpai, Cawneil, Darktronicksfm, DesireSFM, Fugtrup, Lesdias, Nyl2, Opiumud, Pixelatedparoxysm, Rigid3D, Sableserviette, Secaz, Yeero, DerekSFM, ScavengerSFM, HowlSFM, HeadscissorAnimations, Saltoxicdue3D, DivideByZer0, Lies1410, DigitalHell, ZHado, Fastvass, Dubiousbutter

**Naming patterns:** `(Creator) Title`, `[Creator] Title`, `Creator - Title`, `Title by Creator`, `Title (Creator)`

### Known PMV/HMV Creators

> **Important:** Creator ≠ subject. "Babyfooji Into The Blue" = PMV *about* Babyfooji (actress), not *by* her.

**High confidence:**
AshleeHMV, Doomdork, Interceptor, Rondoudou, ScyllaHMV, SK3L3T0K, Wezzam, NoodleDude, JJULEZ, Nizhuanyyi, Aurora Studio, SemperLeaf, SLUTBEAT, Psychosplash, AphidHMVs, FracturedFilms, shinypink, BeachSideVideo

**Medium confidence:**
Kercec, KizuPMV, Proreducer, Rawsource, SQUIREEDITS, Neurotomo, Nintendawg, Selenba, ClubberLang, MrCandyMan, Arckom, PmvIsLife, BunnyMarthy, Cumtonic, Detoxxx, IEDIT, Jaguar681, Jerkmate, LordofPMV, OldManOfTheHMV, Shinyguy, StudioNasty, Surreal, Kaztale, SavageCabbage, LumaPictures, PulseEdits, CreamyVods, IoEdits

**PMV indicators (beyond creator name):** song-like title, "feat."/"ft."/"x" between names (music collabs), compilation/mix/megamix/collection, genre words (hypno, gooner, beta, JOI with music).

### Known Characters/Games (preserve in filename)

- **Overwatch:** D.Va, Mercy, Widowmaker, Tracer, Kiriko, Ashe, Brigitte, Mei, Pharah, Sombra, Symmetra, Ana, Moira, Zarya
- **Final Fantasy:** Tifa, Aerith, Yuffie, Jessie, Scarlet, Cindy, Lunafreya, Gentiana, Aranea
- **Stellar Blade:** Eve, Lily, Tachy, Raven, Adam
- **League of Legends:** Ahri, Jinx, Lux, Akali, Evelynn, Kai'Sa, Seraphine, Miss Fortune, Katarina, Nidalee, Sona
- **Genshin Impact:** Furina, Arlecchino, Raiden Shogun, Hu Tao, Ganyu, Ayaka, Yae Miko, Yelan, Shenhe, Eula, Keqing, Clorinde, Navia, Lumine
- **Honkai Star Rail:** Kafka, Firefly, March 7th, Robin, Acheron, Sparkle, Castorice, Seele, Bronya, Himeko, Topaz
- **Zenless Zone Zero:** Miyabi, Jane Doe, Burnice, Yanagi, Ellen Joe, Zhu Yuan, Astra Yao, Nicole, Soldier 11, Belle, Lycaon
- **Elden Ring:** Malenia, Ranni, Melina, Queen Marika
- **Black Myth Wukong:** Pingping, Lady Rakshashi, Spider Sisters, Fox Spirit
- **Baldur's Gate 3:** Shadowheart, Lae'zel, Karlach, Minthara
- **Nier:** 2B, A2, Kainé
- **Resident Evil:** Lady Dimitrescu, Jill, Claire, Ada
- **Helluva Boss:** Loona, Verosika, Stolas · **Hazbin Hotel:** Charlie, Vaggie, Angel Dust
- **The Witcher:** Triss, Yennefer, Ciri · **Persona 5:** Makoto, Ann, Futaba, Kasumi
- **Cyberpunk 2077:** Panam, Judy, Rebecca (Edgerunners) · **Atomic Heart:** The Twins (Left, Right)
- **Pokemon:** Cynthia, Marnie, Nessa, Bea, Hex Maniac · **MHA:** Momo, Uraraka, Mirko, Mt. Lady
- **Demon Slayer:** Mitsuri, Shinobu, Nezuko · **Chainsaw Man:** Makima, Power, Reze, Himeno
- **Dead or Alive:** Marie Rose, Honoka, Kasumi, Nyotengu · **Street Fighter:** Chun-Li, Cammy, Juri, Kimberly
- **Tomb Raider:** Lara Croft · **Metroid:** Samus Aran (Zero Suit) · **Mass Effect:** Liara, Miranda, Tali, Ashley
- **Dragon Age:** Morrigan, Leliana, Cassandra · **Halo:** Cortana · **Metal Gear:** Quiet, EVA, Sniper Wolf

**Game abbreviations in filenames:** OW/OW2, GI, HSR, ZZZ, FF7R/FFXIV/FFXV, RE2/RE3/REV, LoL, BG3, CP77, DMC5, DOA6, MK11, P5, SF6, TR, ME, DA, MGS.

---

## JAV VR Sourcing

1. Extract JAV code from thread title/content
2. Search Prowlarr: code → code without hyphen → performer+code → SIS001+code
3. JAV torrents often have low seeders — they complete eventually
4. Funscripts usually direct-upload to eroscripts (no external link needed)

---

## VR Tags (NEVER remove — critical for HereSphere)

Tags must start with underscore, hyphen, or space. Case-insensitive. HereSphere uses them for auto-detection. If a `.hsp` file exists alongside a video, it contains saved projection/stereo settings — copy it with the video.

**Projection (defaults to 360 if missing):**
| Tag | Meaning |
|-----|---------|
| `_180` | 180° equirectangular (most common) |
| `_360` | Full 360 spherical |
| `_F180`, `_180F` | Fisheye 180 FOV linear lens |
| `_FISHEYE190`, `_RF52` | Fisheye 190 FOV linear lens |
| `_MKX200` | Fisheye 200 FOV iZugar MKX200 |
| `_MKX220` | Fisheye 220 FOV iZugar MKX22 |
| `_VRCA220` | Fisheye 220 FOV VRCA220 |
| `_F135` | Fisheye 135 linear |
| `_EAC360`, `_360EAC` | Equiangular cubemap |
| `_dome` | Dome format |
| `_equirect` | Equirectangular (spherical standard) |
| `_cubemap` | Cubemap projection |

**Stereo format (defaults to mono if missing):**
| Tag | Meaning |
|-----|---------|
| `_SBS`, `_3dh` | Side-by-side half-width (most common) |
| `_SBSF`, `_LRF` | Side-by-side full-width |
| `_LR` | Left-right (same as SBS) |
| `_RL` | Right-left (swapped eyes) |
| `_TB`, `_3dv` | Top-bottom half-height |
| `_BT` | Bottom-top (swapped) |
| `_OU` | Over-under (same as TB) |
| `_mono`, `_2D` | Monoscopic (no stereo) |

**Resolution/quality:** `_8K`, `_7K`, `_6K`, `_5K`, `_4K`, `_2K`, `_original`, `_ps`, `_60`, `_90`, `_120` (frame rate)

**Codec (informational):** `h264`, `h265`, `HEVC`, `AV1`

Convention: `name_projection_stereo_resolution`. **Tag extraction:** If video lacks VR tags but matching funscript has them, copy tags to video filename.

---

## Filename Cleanup

**Remove:** `[ ] { } # @ ! $ % ^ & * + = | \ / ? < > " '`, duplicate quality markers (`_1080p_4K` → `_4K`), junk suffixes (`_final`, `_fixed`), URL artifacts (`%20`, `%2F`), excessive separators (`___`, `---`).

**Preserve:** VR tags (critical!), resolution markers, scene IDs (VRKM-1344), studio prefixes, character/performer/creator names, `_v2` (improved script version).

**Naming conventions by category:**
- **XBVR:** `[Studio] - Title - SceneID [resolution] [stereo].mp4` — keep original structure, minimal cleanup. Avoid `&` (breaks XBVR matching).
- **Animations:** `(Creator) Title` or `Creator - Title`
- **HMV PMV:** `(Creator) Title` — include creator if known
- **Non-XBVR:** `Studio - Title` or `Performer - Title`

---

## Script Quality Indicators

**Quality criteria (from eroscripts.com):**
| Criteria | Description |
|----------|-------------|
| **Syncing** | Tops/bottoms align with video action (most important) |
| **Scene Accuracy** | Movement matches on-screen speed/intensity |
| **Advanced Techniques** | Double-taps, head twists, throbbing, edge work |
| **Stroke Range** | Captures slow/medium/fast variations |

**BPM reference (beats = up + down movements):**
| BPM | Tempo |
|-----|-------|
| 0-60 | Very slow |
| 60-120 | Slow |
| 120-200 | Medium |
| 200-300 | Fast |
| 300+ | Very fast |

**Action count** = quality indicator (more actions = more detailed script). **Heatmap** (ScriptPlayer, Funscript.io, XBVR): blue (slow) → green → yellow → red (fast). Intensity = `500 * abs(pos_change) / abs(time_change)`.

---

## Funscript JSON Structure

```json
{
  "version": "1.0",
  "inverted": false,
  "range": 100,
  "metadata": {
    "creator": "ScriptCreator",
    "title": "Video Title",
    "duration": 1800000,
    "description": "...",
    "notes": "...",
    "performers": ["Name1", "Name2"],
    "tags": ["tag1", "tag2"],
    "type": "basic"
  },
  "actions": [
    {"at": 0, "pos": 50},
    {"at": 500, "pos": 100},
    {"at": 1000, "pos": 0}
  ]
}
```

**Key fields:**
- `actions[].at` — timestamp in milliseconds
- `actions[].pos` — position 0-100 (0=bottom, 100=top)
- `metadata.duration` — total duration in ms (may be absent; fall back to last action `at`)
- `metadata.creator` — script author (useful for classification)
- `inverted` — if true, positions are flipped (100=bottom)

**Never modify funscript JSON content** — only rename files.

---

## Upload Process

1. Verify prerequisites (ffprobe, jq)
2. Scan source directory for videos and funscripts (including subdirectories)
3. Match pairs using matching strategy
4. **Check for duplicates** (see below)
5. Classify each pair using decision tree
6. Research uncertain names before asking user
7. Clean filenames preserving critical tags
8. **Confirm with user before copying**
9. Copy both files together (never split pairs)
10. Verify copy (compare sizes)
11. Report results — keep sources, let user decide deletion

### Duplicate Detection

**Before moving, check for duplicates in:** (1) source directory (same content, different names), (2) destination folders (file already exists).

| Method | Reliability | Speed |
|--------|-------------|-------|
| Filename match (normalized) | Quick | Fast |
| Size match (`stat -c%s`) | Quick | Fast |
| Duration match (±1s via ffprobe) | Good | Medium |
| Partial hash (MD5 of first 10MB) | Best | Slow |

```bash
stat -c%s "file.mp4"                                   # size
head -c 10485760 "file.mp4" | md5sum                  # partial hash
ffprobe -v error -show_entries format=duration -of csv=p=0 "file.mp4"   # duration
```

**Larger file = better quality → overwrite. Same/smaller → skip and notify.**

```bash
# Copy pair + verify
cp "video.mp4" "/mnt/nsfw_1/CATEGORY/cleaned_name.mp4"
cp "video.funscript" "/mnt/nsfw_1/CATEGORY/cleaned_name.funscript"
ls -la "source.mp4" "/mnt/nsfw_1/CATEGORY/cleaned_name.mp4"
```

**Network drive notes:** Use `cp` not `mv` for cross-drive. Large files take time — be patient. Don't delete sources automatically.

---

## Library Cleanup

**Always dry-run first.** Show proposed changes and get confirmation.

**Checks:** duplicates across folders, orphaned funscripts (no matching video), orphaned videos (no funscript — report only), misclassified content, missing VR tags on VR content, broken naming, multi-channel sets missing channels, mismatched pair names.

**Output format:**
```
Analyzing /mnt/nsfw_1/...
Found issues:
1. MISCLASSIFIED: "HMV PMV/SomeAnimator - Title.mp4" → should be in Animations/
2. MISSING_TAGS: "XBVR/video.mp4" → needs VR tags from funscript
3. ORPHAN_SCRIPT: "Animations/orphan.funscript" → no matching video
4. NAME_MISMATCH: "video.mp4" + "video_old.funscript" → rename script?
Proceed with fixes? [Yes/No/Review each]
```

---

## XBVR Integration

**URL:** `http://xbvr.home.arpa/ui/` (LAN: `192.168.1.233:9999`)

**XBVR matching priority:**
1. Exact SceneID match (e.g., `vrcx-123` in filename)
2. URL slug match
3. Fuzzy title match (Levenshtein distance)
4. Duration + cast heuristics

**Best filename format:** `[Studio] - Title - SceneID [resolution] [stereo].mp4`
Example: `VirtualRealPorn - Amazing Scene - 12345 - 8K.mp4`

**Tips:** Avoid `&` in filenames (breaks matching). Include scene ID when available (most reliable). VR tags help auto-detection but XBVR may override.

### After uploading VR content

1. **Rescan storage:** Options → Storage → Rescan on the videos folder
2. **Check Files section:** High-probability match still needs a manual click to confirm. No match → continue.
3. **Try studio scraper:** Scene Data → Scrapers → run relevant studio
4. **Manual import:**
   - **JAV (VRKM, SIVR, etc.):** JAVDatabase — enter DVD code (e.g., SAVR-975) in import dialog
   - **Western:** TPDB — search theporndb.net, copy scene URL, paste in XBVR import
5. **Match file to scene:** Files → find video → click to match

Use the browser tool to interact with XBVR UI.

### External databases
- **JAVDatabase:** `https://www.javdatabase.com/movies/[code]/`
- **TPDB (ThePornDB):** `https://theporndb.net/`
- **StashDB:** community metadata via fingerprinting (Stash app)
- **R18/FANZA/DMM:** Japanese content metadata
- **IAFD:** performer database · **Data18:** scene database

---

## EroScripts Search Tips

**Search API:** `https://discuss.eroscripts.com/search.json?q=TERMS`
- Returns `.posts[]` and `.topics[]` arrays; each has `.id`, `.title`, `.slug`
- Topic URL: `https://discuss.eroscripts.com/t/{slug}/{id}`

**⚠️ Search pitfalls:**
- Too-specific queries miss results — filenames on disk rarely match thread titles exactly
- Example: file `Ramp up.mp4` matches thread "Ramp up (4h of anthros...)" but `q=ramp+up` returns generic "ramp speed" results
- EroScripts titles often include extra descriptors: creator name, subtitle, version info
- **Better strategy:** search unique identifying terms (creator name + keyword), not just filename
- Private threads (404 via API) still show up in search results if not logged in
- **Always check with browser if API search fails** — some threads are in private/creator categories
- Thread IDs from URLs are definitive — trust a shared link over search

---

## Useful Commands

```python
# Orphaned funscripts (case-insensitive, handles special chars)
import os, re
EXTENSIONS = r'\.(mp4|mkv|webm|m4v|avi|wmv|mov)$'
MULTI_AXIS = ['.anal', '.mono', '.pitch', '.roll', '.surge', '.sway', '.twist']
for f in sorted(os.listdir(DIR)):
    if not f.endswith('.funscript'): continue
    base = f[:-10]  # strip .funscript
    is_multi = any(base.endswith(s) for s in MULTI_AXIS)
    check = base
    for s in MULTI_AXIS:
        if check.endswith(s): check = check[:-len(s)]; break
    if not any(re.match(re.escape(check) + EXTENSIONS, g, re.I) for g in os.listdir(DIR)):
        tag = 'MULTI-AXIS VARIANT' if is_multi else 'ORPHAN'
        print(f'{tag}: {f}')

# Videos without scripts (case-insensitive)
import os, re
for f in sorted(os.listdir(DIR)):
    ext = os.path.splitext(f)[1].lower()
    if ext not in ('.mp4', '.mkv', '.webm', '.m4v', '.avi', '.wmv', '.mov'): continue
    base = os.path.splitext(f)[0]
    if not any(re.match(re.escape(base) + r'\.funscript$', g, re.I) for g in os.listdir(DIR)):
        print(f'NO SCRIPT: {f}')
```

```bash
# === Funscript analysis ===
jq '.actions | length' file.funscript                       # action count (quality)
jq '.metadata' file.funscript                               # all metadata
jq -r '.metadata.creator // "unknown"' file.funscript       # creator
jq -r '(.metadata.duration // (.actions | map(.at) | max)) / 1000' file.funscript  # duration (s)
jq '{first: .actions[0].at, last: .actions[-1].at}' file.funscript

# === Video analysis ===
ffprobe -v error -show_format -show_streams -of json "video.mp4"                       # full metadata
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "video.mp4"  # duration
ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "video.mp4"  # resolution
ffprobe -v error -select_streams v:0 -show_entries stream=display_aspect_ratio -of default=noprint_wrappers=1:nokey=1 "video.mp4"  # aspect (VR ~2:1)
ffprobe -v error -select_streams v:0 -show_entries stream_side_data=side_data_type -of default=noprint_wrappers=1:nokey=1 "video.mp4"  # spherical check
ffmpeg -ss 00:01:00 -i "video.mp4" -frames:v 1 -f image2 "frame.jpg"                    # thumbnail

# === File discovery ===
find ~/Downloads -name "*.funscript" -mtime -7
find ~/Downloads -type f \( -iname "*.mp4" -o -iname "*.mkv" \) -mtime -7
```

---

## Common Edge Cases

- **Subfolders:** Always check subdirectories (JAV often in `VRKM-1344/` folders)
- **Split videos:** Some JAV has parts (`-A`, `-B`, `-C`) — each needs its own script
- **Script naming mismatch:** Script may have extra suffixes (`_SL400`, `_Handy`) — match base name
- **VR tags only in script:** Copy VR tags from funscript filename to video
- **Multiple scripts per video:** Could be variants (soft/hard) or multi-axis — keep all initially, reduce to one
- **Mixed case:** Normalize case when comparing filenames
- **Empty funscripts:** Check action count > 0 before processing
- **Cross-folder duplicates:** Same video in multiple destination folders — consolidate
- **Archived videos:** Videos may arrive as archives (`.zip`/`.rar`/`.7z`) — a funscript whose base matches an entry *inside* an archive is **NOT an orphan**. List archive contents before declaring a script unmatched. Extract directly to the destination when local disk is tight.
- **Corrupt / incomplete downloads:** Active torrents leave half-written files (`moov atom not found`, unreadable by ffprobe). **Gate every video with ffprobe before copy** — never upload or delete a file that fails the readability check. Note: a torrent file can be ffprobe-readable yet still incomplete (moov at front), so cross-check qBittorrent completion %.
- **Torrent-managed files:** Before deleting local sources, query qBittorrent (`/api/v2/torrents/info` + `/torrents/files?hash=`) for files it manages. **Never delete a file that is seeding or still downloading** — keep its script too so the pair completes later.
- **Mislabeled / wrong-extension funscripts:** A funscript may be delivered as `.txt` or under a totally wrong filename (e.g. a script named for video A whose content is actually for scene "VSP54"/video B). **Never trust the filename alone** — verify a script matches its video by internal metadata (`metadata.title`/`creator`) and by duration (last action `at` vs video duration, ±a few %). When a video looks scriptless, also scan for `.txt` files whose content starts with `{"actions":`.
- **Content-duplicate scripts:** Two scripts with identical content can sit under different filenames (same `actions[-1].at` + `actions|length` + `metadata.title`). Fingerprint by `(lastAt, actionCount, title)` to detect redundant copies and discard extras.

---

## Anti-patterns (NEVER do these)

- Delete sources before verifying copy succeeded
- Remove VR tags from filenames (breaks HereSphere playback)
- Split video/funscript pairs (must always move together)
- Move videos without matching funscripts
- Move orphaned funscripts without matching video
- Modify funscript JSON content
- Overwrite existing files without confirmation
- Copy without checking for duplicates in destination first
- Assume classification without checking indicators
- Skip research when a name is unfamiliar
- Run cleanup without showing dry-run first
- Force-match files with very different durations
- Ignore multi-channel funscript sets (reduce to one per video, but knowingly)
- Assume fuzzy match >70% is correct without verification
- Treat multi-axis scripts (`.pitch`, `.surge`, etc.) as orphaned
