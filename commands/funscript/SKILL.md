# Funscript Workflow

Workflow for organizing funscript+video pairs: analyze, match, classify, rename, and upload.

$ARGUMENTS

---

## Prerequisites

Check before any operation:
```bash
ffprobe -version >/dev/null 2>&1 || echo "ERROR: Install FFmpeg"
jq --version >/dev/null 2>&1 || echo "ERROR: Install jq"
```

---

## Destination Library

**Path:** `Z:\Miscellaneous\P\`

| Folder | Content Type | Indicators |
|--------|--------------|------------|
| `XBVR/` | VR with scripts | _180, _SBS, _3dh, VR studio prefixes |
| `Animations/` | SFM/CGI/Blender (non-music) | Known animators, game characters |
| `HMV PMV/` | Music videos (animated OR real) | HMV, PMV, has music audio |
| `Fap Cock Hero/` | Rhythm games | Fap Hero, Cock Hero, BPM |
| `Non-XBVR/` | Real non-VR (non-PMV) | Performer names, studio names |

---

## Research When Uncertain

**When to research:** If a name in the filename is unfamiliar and could be:
- An animator/creator
- A PMV/HMV editor
- A game character
- A performer/actress
- A studio

**How to research:**
1. Use WebSearch to look up the name + context (e.g., "Nagoonimation animator", "Babyfooji OnlyFans")
2. Use WebFetch on relevant results if needed
3. Check these sites:
   - **Animators:** rule34video.com, iwara.tv, erome.com, graphtreon.com/top-patreon-creators/animation
   - **PMV creators:** spankbang.com (search "[name] HMV/PMV"), pornhub (community), pmvhaven.com, hmvmania.com (3700+ videos, 700+ creators)
   - **Characters:** rule34.xxx, danbooru (character tags)
   - **Performers:** iafd.com, indexxx.com, freeones.com
   - **VR studios:** sexlikereal.com, vrporn.com
   - **Scripts/community:** eroscripts.com (largest funscript community)
   - **Commercial scripts:** SexLikeReal (SLR), RealSync, CzechVR (higher quality, professionally synced)

**Research triggers:**
- Name at start of filename in brackets/parentheses: likely creator
- Name followed by game title: likely character
- Name with studio-like suffix (Productions, Studio, 3D): likely animator
- Japanese name + code pattern: likely JAV performer

**After research:** Add newly discovered creators/animators to your working knowledge for the session.

---

## Matching Strategy

**Video extensions:** `.mp4`, `.mkv`, `.avi`, `.wmv`, `.webm`, `.m4v`, `.mov`
**Script extensions:** `.funscript`, `.pitch`, `.roll`, `.twist`, `.surge`, `.sway`

Priority order:
1. **Exact Match**: Same base filename (ignoring extension)
2. **Partial Match**: Common prefix/substring (e.g., VRKM-1344)
3. **Fuzzy Match**: token_set_ratio > 70% after normalization
4. **Duration Match**: Video duration vs funscript last action (±30s tolerance)
5. **Vision Match**: Extract frame, use vision to identify content

```bash
# Video duration (seconds)
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "video.mp4"

# Funscript duration (ms → seconds)
jq -r '(.metadata.duration // (.actions | map(.at) | max)) / 1000' "file.funscript"
```

**Multi-axis funscripts:** Some videos have multiple files for different motion axes:

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

Keep all channels together as a set. Base filename stays the same.

**Script variant suffixes (intensity variations):**
- `.soft.funscript` / `.hard.funscript` - stroke range variations
- `.handy.funscript` - optimized for Handy device (stroke limits)
- `.bj.funscript` - limited strokes simulating oral

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
- 0-60: Very slow
- 60-120: Slow
- 120-200: Medium
- 200-300: Fast
- 300+: Very fast

**Action count as quality indicator:** More actions = more detailed script

**Heatmap visualization:** Tools like ScriptPlayer, Funscript.io, and XBVR generate heatmaps showing intensity over time. Color gradient from blue (slow) → green → yellow → red (fast). Intensity = `500 * abs(pos_change) / abs(time_change)`

---

## Classification Decision Tree

```
1. VR Detection
   Has _180, _SBS, _3dh, VR studio prefix, 2:1 aspect ratio? → XBVR/
   Check spherical metadata in file (sv3d/st3d boxes)
   Check filename for VR tags (_180, _360, _SBS, _3dh, _FISHEYE, etc.)

2. PMV/HMV Detection (can be animated OR real)
   - Filename contains HMV, PMV, "music video"? → HMV PMV/
   - Known PMV creator in filename? → HMV PMV/
   - Has continuous music track throughout? → likely HMV PMV/
   - Multiple performers/scenes edited together? → likely HMV PMV/
   - UNCERTAIN? → Research the creator name, then ask user if still unclear

3. Fap/Cock Hero Detection (can be animated OR real)
   Fap Hero, Cock Hero, BPM Training, Edge Hero, Beat? → Fap Cock Hero/

4. Animation vs Real
   - Known animator in filename? → Animations/
   - Game character name + 3D/SFM/Blender style? → Animations/
   - UNCERTAIN about creator? → Research the name first
   - Real footage? → Non-XBVR/

5. No funscript match → Report only, DO NOT move
```

---

## Known VR Studios (filename prefixes)

> **Note:** All "Known" lists below are NOT exhaustive. If a name isn't listed, research it before assuming it's not a valid creator/studio/character. New creators emerge constantly.

**Western:**
SLR_, SLROriginals_, VirtualTaboo_, RealJamVR_, VRCosplayX_, WankzVR_, VRBangers_, BadoinkVR_, BaDoinkVR_, NaughtyAmericaVR_, VRHush_, CzechVR_, CzechVRFetish_, CzechVRCasting_, VRLatina_, VRConk_, LethalHardcoreVR_, MilfVR_, WetVR_, VRedging_, VRIntimacy_, SexBabesVR_, StasyQVR_, TmwVRnet_, VRSexperts_, 18VR_, BrasilVR_, DarkRoomVR_, HoloGirlsVR_, KinkVR_, LustReality_, PerVRt_, POVcentral_, RealVR_, SinsVR_, VirtualPorn_, VirtualRealPorn_, VirtualRealPassion_, VirtualRealTrans_, VirtualRealGay_, VRClubz_, VRSpy_, POVR_, VRAllure_, VRPFilms_, SwallowBay_, RealHotVR_, VRFootFetish_, OnlyTease_, WhorecraftVR_, VRPornJack_, VRSexyGirlz_, FuckPassVR_, TransVR_, BabeVR_, DDFNetworkVR_

**JAV (always match video code):**
3DSVR-, AJVR-, AQUCO-, AQULA-, AVVR-, BIBIVR-, CAFR-, CBIKMV-, CCVR-, CJVR-, COSVR-, CRVR-, DOCVR-, DSVR-, EBVR-, FSVR-, GOPJ-, HNVR-, IPVR-, JUVR-, KAVR-, KIVR-, KIWVR-, KMVR-, MDVR-, MTVR-, NHVR-, NKKVR-, PPVR-, PRDVR-, PRVR-, PXVR-, SAVR-, SIVR-, SPIVR-, TMAVR-, URVRSP-, VRKM-, VRRB-, WABB-, WAVR-, WVR8-

---

## Known Animators

**High activity:**
Derpixon, Eipril, ENarane, Nagoonimation, NoduSFM, ZonkPunch, Megaera, HydraFXX, Lewdgazer, Magikal3D, AxenAnim, Bamh3D, GeckoCGI, Redmoa, LewdFraggy, Fpsblyck, GeneralButch, ceno0

**Medium activity:**
AANiX, AidenHet, Aphy3D, Captain Popcorn, Drills3D, DTee3D, Evilbaka, FOW, HornyHerring, IckySticky, LazyProcrastinator, Maiden Masher, Maplestar, MastaPov, Matchattea, Miwo, Rinhee, Rwt4184, SaltyIceCream, Sutekimeppou, TDonTran, Theobrobine, Toastedmw, Ubermation, Viciousfox, Visualoos, Wildeer Studio, Wutboi, Z1g3D, ZMSFM, Bulgingsenpai, Cawneil, Darktronicksfm, DesireSFM, Fugtrup, Lesdias, Nyl2, Opiumud, Pixelatedparoxysm, Rigid3D, Sableserviette, Secaz, Yeero, DerekSFM, ScavengerSFM, HowlSFM, HeadscissorAnimations, Saltoxicdue3D, DivideByZer0, Lies1410, DigitalHell, ZHado, Fastvass, Dubiousbutter

**Naming patterns:**
- `(Creator) Title` - most common
- `[Creator] Title`
- `Creator - Title`
- `Title by Creator`
- `Title (Creator)`

---

## Known PMV/HMV Creators

**Important:** Creator ≠ subject. "Babyfooji Into The Blue" = PMV *about* Babyfooji (actress), not *by* her.

**High confidence:**
AshleeHMV, Doomdork, Interceptor, Rondoudou, ScyllaHMV, SK3L3T0K, Wezzam, NoodleDude, JJULEZ, Nizhuanyyi, Aurora Studio, SemperLeaf, SLUTBEAT, Psychosplash, AphidHMVs, FracturedFilms, shinypink, BeachSideVideo

**Medium confidence:**
Kercec, KizuPMV, Proreducer, Rawsource, SQUIREEDITS, Neurotomo, Nintendawg, Selenba, ClubberLang, MrCandyMan, Arckom, PmvIsLife, BunnyMarthy, Cumtonic, Detoxxx, IEDIT, Jaguar681, Jerkmate, LordofPMV, OldManOfTheHMV, Shinyguy, StudioNasty, Surreal, Kaztale, SavageCabbage, LumaPictures, PulseEdits, CreamyVods, IoEdits

**PMV indicators (beyond creator name):**
- Title sounds like song name
- "feat.", "ft.", "x" between names (like music collabs)
- Compilation words: compilation, mix, megamix, collection
- Genre words: hypno, gooner, beta, JOI (with music)

---

## Known Characters/Games (preserve in filename)

**Overwatch:** D.Va, Mercy, Widowmaker, Tracer, Kiriko, Ashe, Brigitte, Mei, Pharah, Sombra, Symmetra, Ana, Moira, Zarya

**Final Fantasy:** Tifa, Aerith, Yuffie, Jessie, Scarlet, Cindy, Lunafreya, Gentiana, Aranea

**Stellar Blade:** Eve, Lily, Tachy, Raven, Adam

**League of Legends:** Ahri, Jinx, Lux, Akali, Evelynn, Kai'Sa, Seraphine, Miss Fortune, Katarina, Nidalee, Sona

**Genshin Impact:** Furina, Arlecchino, Raiden Shogun, Hu Tao, Ganyu, Ayaka, Yae Miko, Yelan, Shenhe, Eula, Keqing, Clorinde, Navia, Lumine

**Honkai Star Rail:** Kafka, Firefly, March 7th, Robin, Acheron, Sparkle, Castorice, Seele, Bronya, Himeko, Topaz

**Zenless Zone Zero:** Miyabi, Jane Doe, Burnice, Yanagi, Ellen Joe, Zhu Yuan, Astra Yao, Nicole, Soldier 11, Belle, Lycaon

**Elden Ring:** Malenia, Ranni, Melina, Queen Marika

**Black Myth Wukong:** Pingping, Lady Rakshashi, Spider Sisters, Fox Spirit

**Other popular:**
- Baldur's Gate 3: Shadowheart, Lae'zel, Karlach, Minthara
- Nier: 2B, A2, Kainé
- Resident Evil: Lady Dimitrescu, Jill, Claire, Ada
- Helluva Boss: Loona, Verosika, Stolas
- Hazbin Hotel: Charlie, Vaggie, Angel Dust
- The Witcher: Triss, Yennefer, Ciri
- Persona 5: Makoto, Ann, Futaba, Kasumi
- Cyberpunk 2077: Panam, Judy, Rebecca (Edgerunners)
- Atomic Heart: The Twins (Left, Right)
- Pokemon: Cynthia, Marnie, Nessa, Bea, Hex Maniac
- My Hero Academia: Momo, Uraraka, Mirko, Mt. Lady
- Demon Slayer: Mitsuri, Shinobu, Nezuko
- Chainsaw Man: Makima, Power, Reze, Himeno
- Fortnite: Various skins
- Dead or Alive: Marie Rose, Honoka, Kasumi, Nyotengu
- Street Fighter: Chun-Li, Cammy, Juri, Kimberly
- Tomb Raider: Lara Croft
- Metroid: Samus Aran (Zero Suit Samus)
- Mass Effect: Liara, Miranda, Tali, Ashley
- Dragon Age: Morrigan, Leliana, Cassandra
- Halo: Cortana
- Metal Gear: Quiet, EVA, Sniper Wolf

**Common game abbreviations in filenames:**
OW/OW2 (Overwatch), GI (Genshin), HSR (Honkai Star Rail), ZZZ (Zenless Zone Zero), FF7R/FFXIV/FFXV (Final Fantasy), RE2/RE3/REV (Resident Evil), LoL (League of Legends), BG3 (Baldur's Gate 3), CP77 (Cyberpunk), DMC5 (Devil May Cry), DOA6 (Dead or Alive), MK11 (Mortal Kombat), P5 (Persona 5), SF6 (Street Fighter 6), TR (Tomb Raider), ME (Mass Effect), DA (Dragon Age), MGS (Metal Gear Solid)

---

## VR Tags (Critical for HereSphere)

**NEVER remove these from filenames - HereSphere uses them for auto-detection.**
Tags must start with underscore, hyphen, or space. Case-insensitive.

**Projection (defaults to 360 if missing):**
```
_180        - 180-degree equirectangular (most common)
_360        - Full 360 spherical
_F180, _180F - Fisheye 180 FOV linear lens
_FISHEYE190, _RF52 - Fisheye 190 FOV linear lens
_MKX200     - Fisheye 200 FOV iZugar MKX200 lens
_MKX220     - Fisheye 220 FOV iZugar MKX22 lens
_VRCA220    - Fisheye 220 FOV VRCA220 lens
_F135       - Fisheye 135 linear
_EAC360, _360EAC - Equiangular cubemap
_dome       - Dome format
_equirect   - Equirectangular (spherical standard)
_cubemap    - Cubemap projection
```

**Stereo format (defaults to mono if missing):**
```
_SBS, _3dh  - Side-by-side half-width (most common)
_SBSF, _LRF - Side-by-side full-width
_LR         - Left-right (same as SBS)
_RL         - Right-left (swapped eyes)
_TB, _3dv   - Top-bottom half-height
_BT         - Bottom-top (swapped)
_OU         - Over-under (same as TB)
_mono, _2D  - Monoscopic (no stereo)
```

**Resolution/quality:**
```
_8K, _7K, _6K, _5K, _4K, _2K  - Resolution
_original, _ps               - Source quality indicators
_60, _90, _120               - Frame rate
```

**Codec (informational, doesn't affect playback):**
```
h264, h265, HEVC, AV1
```

**Tags are case-insensitive.** Order doesn't matter but convention is: `name_projection_stereo_resolution`

**Tag extraction:** If video lacks VR tags but matching funscript has them, copy tags to video filename.

**HereSphere settings:** If a `.hsp` file exists alongside a video, it contains saved projection/stereo settings. Portable - copy with video when moving.

---

## Filename Cleanup

**Remove:**
- Special characters: `[ ] { } # @ ! $ % ^ & * + = | \ / ? < > " '`
- Duplicate quality markers: `_1080p_4K` → `_4K`
- Junk suffixes: `_final`, `_v2`, `_fixed` (unless meaningful)
- URL artifacts: `%20`, `%2F`, encoded characters
- Excessive separators: `___`, `---`, multiple spaces

**Preserve:**
- VR tags (critical!)
- Resolution markers
- Scene IDs: VRKM-1344, scene numbers
- Studio prefixes
- Character names
- Performer names
- Creator names

**Naming conventions by category:**
- **XBVR:** Keep original structure, minimal cleanup only
- **Animations:** `(Creator) Title` or `Creator - Title`
- **HMV PMV:** `(Creator) Title` - include creator if known
- **Non-XBVR:** `Studio - Title` or `Performer - Title`

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
    "description": "Script description",
    "license": "...",
    "notes": "Additional notes",
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
- `actions[].at` - Timestamp in milliseconds
- `actions[].pos` - Position 0-100 (0=bottom, 100=top)
- `metadata.duration` - Total duration in ms (may be absent)
- `metadata.creator` - Script author (useful for classification)
- `inverted` - If true, positions are flipped (100=bottom)

---

## Useful Commands

```bash
# === Video Analysis ===

# Full metadata (JSON)
ffprobe -v error -show_format -show_streams -of json "video.mp4"

# Duration only (seconds)
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "video.mp4"

# Resolution
ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=s=x:p=0 "video.mp4"

# Aspect ratio check (VR is typically 2:1)
ffprobe -v error -select_streams v:0 -show_entries stream=display_aspect_ratio -of default=noprint_wrappers=1:nokey=1 "video.mp4"

# VR/spherical metadata (check for sv3d/st3d boxes)
ffprobe -v error -select_streams v:0 -show_entries stream_side_data=side_data_type -of default=noprint_wrappers=1 "video.mp4"

# Detailed spherical metadata
ffprobe -v quiet -show_streams -select_streams v "video.mp4" | grep -i spherical

# Audio streams (for PMV detection)
ffprobe -v error -select_streams a -show_entries stream=codec_name,bit_rate,channels -of json "video.mp4"

# Extract thumbnail frame
ffmpeg -ss 00:01:00 -i "video.mp4" -frames:v 1 -f image2 "frame.jpg"

# === Funscript Analysis ===

# Duration (prefer metadata, fallback to last action)
jq -r '(.metadata.duration // (.actions | map(.at) | max)) / 1000' file.funscript

# Creator from metadata
jq -r '.metadata.creator // "unknown"' file.funscript

# Title from metadata
jq -r '.metadata.title // empty' file.funscript

# Script type/notes
jq -r '.metadata.notes // empty' file.funscript

# Action count (quality indicator - more = better scripted)
jq '.actions | length' file.funscript

# Average intensity (higher = more active script)
jq '[.actions[].pos] | add / length' file.funscript

# Check if inverted
jq -r '.inverted // false' file.funscript

# Get all metadata at once
jq '.metadata' file.funscript

# Performers list
jq -r '.metadata.performers // [] | join(", ")' file.funscript

# Tags list
jq -r '.metadata.tags // [] | join(", ")' file.funscript

# First and last action timestamps (for duration verification)
jq '{first: .actions[0].at, last: .actions[-1].at} | "\(.first/1000)s - \(.last/1000)s"' file.funscript

# === File Operations ===

# Find all video files
find . -maxdepth 1 -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.wmv" -o -iname "*.webm" \)

# Find all funscripts
find . -maxdepth 1 -type f -iname "*.funscript"

# Find orphaned funscripts (no matching video)
for f in *.funscript; do base="${f%.funscript}"; ls "$base".{mp4,mkv,avi,wmv,webm} 2>/dev/null || echo "Orphan: $f"; done

# Find videos without funscripts
for f in *.mp4 *.mkv 2>/dev/null; do base="${f%.*}"; [ -f "$base.funscript" ] || echo "No script: $f"; done
```

---

## Upload Process

1. **Verify prerequisites** (ffprobe, jq)
2. **Scan source directory** for videos and funscripts (including subdirectories)
3. **Match pairs** using matching strategy
4. **Check for duplicates** (see below)
5. **Classify each pair** using decision tree
6. **Research uncertain names** before asking user
7. **Clean filenames** preserving critical tags
8. **Confirm with user** before copying
9. **Copy both files together** (never split pairs)
10. **Verify copy** (check file sizes match)
11. **Report results** - keep sources, let user decide deletion

### Duplicate Detection

**Before moving, check for duplicates in:**
1. **Source directory** - same content with different names
2. **Destination folders** - file already exists in target location

**Detection methods:**
- **Filename match:** Same base name (normalized) already exists
- **Size match:** Same file size (quick check)
- **Duration match:** Same video duration (±1s tolerance)
- **Hash match:** MD5/SHA256 of first 10MB (most reliable, slower)

```bash
# Quick size check
stat -c%s "file.mp4"  # Linux
powershell -c "(Get-Item 'file.mp4').Length"  # Windows

# Partial hash (first 10MB)
head -c 10485760 "file.mp4" | md5sum  # Linux
powershell -c "Get-FileHash -Algorithm MD5 -InputStream ([System.IO.File]::OpenRead('file.mp4') | Select-Object -First 10485760)"  # Windows (approx)

# Video duration comparison
ffprobe -v error -show_entries format=duration -of csv=p=0 "file.mp4"
```

**Duplicate report format:**
```
⚠️  DUPLICATES FOUND:

In source:
  - "Video Title.mp4" and "Video Title (1).mp4" (same size: 2.3GB)

In destination (Z:\Miscellaneous\P\):
  - "XBVR/VRCosplayX_Loona.mp4" already exists (same duration: 34:21)
  - "Animations/Creator - Title.mp4" already exists (same hash)

Options: [Skip duplicates] [Overwrite] [Rename with suffix] [Review each]
```

```bash
# Copy pair to destination
cp "video.mp4" "Z:/Miscellaneous/P/CATEGORY/cleaned_name.mp4"
cp "video.funscript" "Z:/Miscellaneous/P/CATEGORY/cleaned_name.funscript"

# Verify sizes match
ls -la "source.mp4" "Z:/Miscellaneous/P/CATEGORY/cleaned_name.mp4"
```

**Network drive notes:**
- Use `cp` not `mv` for cross-drive
- Large files may take time - be patient
- Verify after copy completes
- Don't delete sources automatically

---

## Library Cleanup

**Always dry-run first.** Show proposed changes and get confirmation.

**Checks to perform:**
- **Duplicates** - same content across folders or with different names (by size/duration/hash)
- Orphaned funscripts (no matching video)
- Orphaned videos (no funscript) - report only, don't move
- Misclassified content (VR in wrong folder, animation in Non-XBVR, etc.)
- Missing VR tags on VR content
- Broken/inconsistent naming
- Multi-channel funscripts missing channels
- Pairs with mismatched names

**Output format:**
```
Analyzing Z:\Miscellaneous\P...

Found issues:
1. MISCLASSIFIED: "HMV PMV/SomeAnimator - Title.mp4" → should be in Animations/
2. MISSING_TAGS: "XBVR/video.mp4" → needs VR tags from funscript
3. ORPHAN_SCRIPT: "Animations/orphan.funscript" → no matching video
4. NAME_MISMATCH: "video.mp4" + "video_old.funscript" → rename script?

Proceed with fixes? [Yes/No/Review each]
```

---

---

## XBVR Integration

**URL:** `http://192.168.0.233:8509/ui/`

**XBVR matching priority:**
1. Exact SceneID match (e.g., `vrcx-123` in filename)
2. URL slug match
3. Fuzzy title match (Levenshtein distance)
4. Duration + cast heuristics

**Best filename format for XBVR:**
```
[Studio] - Title - SceneID [resolution] [stereo].mp4
Example: VirtualRealPorn - Amazing Scene - 12345 - 8K.mp4
```

**XBVR matching tips:**
- Avoid `&` in filenames (breaks matching)
- Include scene ID when available (most reliable match)
- VR tags in filename help auto-detection but XBVR may override
- Levenshtein fuzzy matching used for title-based matching

### After uploading VR content:

1. **Rescan storage:** Options → Storage → click Rescan on the videos folder
2. **Check Files section:** Look for the new video
   - High probability match shown? → Still needs manual click to confirm!
   - No match? → Continue to step 3
3. **Try studio scraper:** Scene Data → Scrapers → run relevant studio
4. **Manual import if needed:**
   - **JAV content (VRKM, SIVR, etc.):** Use JAVDatabase
     - Enter DVD code (e.g., SAVR-975) in import dialog
   - **Western content:** Use TPDB
     - Search on theporndb.net to find scene
     - Copy scene URL, paste in XBVR import
5. **Match file to scene:** Files → find video → click to match

### Browser automation:
```bash
alias ab='C:/Users/sants/AppData/Roaming/npm/node_modules/agent-browser/bin/agent-browser-win32-x64.exe'
ab --session xbvr open http://192.168.0.233:8509/ui/
ab --session xbvr snapshot -i
ab --session xbvr click @element-ref
```

### External databases:
- **JAVDatabase:** `https://www.javdatabase.com/movies/[code]/`
- **TPDB (ThePornDB):** `https://theporndb.net/` (search, then use scene URL)
- **StashDB:** Community metadata via fingerprinting (used by Stash app)
- **R18/FANZA/DMM:** Japanese content metadata
- **IAFD:** Performer database
- **Data18:** Scene database

---

## Common Edge Cases

- **Subfolders:** Always check subdirectories (JAV often in `VRKM-1344/` folders)
- **Split videos:** Some JAV has parts (`-A`, `-B`, `-C`) - each needs its own script
- **Script naming mismatch:** Script may have extra suffixes (`_SL400`, `_Handy`) - match base name
- **VR tags only in script:** Copy VR tags from funscript filename to video
- **Multiple scripts per video:** Could be variants (soft/hard) or multi-axis - keep all
- **Encoded filenames:** Decode URL-encoded chars (`%20` → space) before matching
- **Mixed case:** Normalize case when comparing filenames
- **Trailing numbers:** `video (1).mp4` likely duplicates - compare size/duration/hash
- **Cross-folder duplicates:** Same video in multiple destination folders - consolidate
- **Empty funscripts:** Check action count > 0 before processing

---

## Anti-Patterns (NEVER do these)

- Delete sources before verifying copy succeeded
- Remove VR tags from filenames (breaks HereSphere playback)
- Split video/funscript pairs (must always move together)
- Move videos without matching funscripts
- Move orphaned funscripts without matching video
- Modify funscript JSON content
- Overwrite existing files without confirmation
- **Copy without checking for duplicates in destination first**
- Assume classification without checking indicators
- Skip research when name is unfamiliar
- Run cleanup without showing dry-run first
- Force-match files with very different durations
- Ignore multi-channel funscript sets (keep all channels together)

---

## Example Session

```
User: /funscript analyze downloads and upload to library

1. Scan C:\Users\sants\Downloads...

Found 5 videos, 4 funscripts:
├── VRCosplayX_Helluva_Boss_Loona_8K_180_3dh.mp4 + .funscript ✓
├── Babyfooji Into The Blue_AV1.mp4 + _SL400.funscript ✓
├── VRKM-1344/VRKM-1344-C.mp4 + ...8K_180_3DH.funscript ✓
├── (Unknown) Juno Dance.mp4 + .funscript ✓
└── random_video.mp4 (NO FUNSCRIPT - will not move)

2. Classification:
   - VRCosplayX → VR tags present → XBVR/
   - Babyfooji → researching... OnlyFans performer, not creator
     → "Into The Blue" sounds like song → likely PMV → HMV PMV/
   - VRKM-1344 → JAV VR code → XBVR/
   - "Juno Dance" → researching "Juno"... Stellar Blade character
     → Animation style → Animations/

3. Proposed actions:
   COPY: VRCosplayX_Helluva_Boss_Loona_8K_180_3dh.* → XBVR/
   COPY: Babyfooji Into The Blue.* → HMV PMV/ (renamed, removed _AV1_SL400)
   COPY: VRKM-1344*.* → XBVR/VRKM-1344_8K_180_3DH.* (merged VR tags)
   COPY: Juno Dance.* → Animations/(Unknown) Juno Dance.*
   SKIP: random_video.mp4 (no funscript)

Proceed? [Yes/No/Review each]
```
