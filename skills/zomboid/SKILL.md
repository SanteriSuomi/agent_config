---
name: zomboid
description: "Manage the Project Zomboid dedicated server (container 'zomboid' in ~/mediaserver/compose.yml): add/remove workshop mods, restart safely, RCON commands, sandbox vars, server options, user accounts/roles, password resets, backups. Triggers: zomboid, pz server, add mod, workshop mod, server restart, rcon, sandbox settings, access level, admin, whitelist, server password, mod not found."
---

# Project Zomboid Server Management

Container `zomboid` in `~/mediaserver/compose.yml` (image `renegademaster/zomboid-dedicated-server`). World name `mormonlesbianvampirehunters`. Version **pinned at 42.20.3** — players run depot-downgraded clients; do NOT update the game (see Version Pin below).

## Hard Rules

- **Default: NO restart.** Only restart when the user explicitly permits it (e.g. "restart", "restart permitted"). Restarts drop online players.
- Never run steamcmd `app_update` against the server volume — it would bump 42.20.3 → 42.20.4+ and checksum-kick every downgraded client.
- Never echo secrets from `.env` (join/RCON/admin passwords). Point the user at `grep ZOMBOID_* ~/mediaserver/.env`.
- **THE FREEZE BUG (solved 2026-09-06):** the image's `ProjectZomboid64.json` ships `-XX:+UseZGC`. Under the cgroup memory limit, accumulated file page cache (workshop re-verify ~4G/boot + autosaves + PZ internal backups) squeezes the JVM → ZGC allocation stalls → worker threads peg a core, game loop starves 30→4→0 TPS, RCON dies, full map freeze for all players. Misdiagnosed first as a "heap leak" because `docker stats` counts page cache as container memory. Fix applied: `GC_CONFIG=G1GC` + `MAX_RAM=8G` env (entrypoint seds the json each boot) + `BackupsOnStart=false` + sidecar telemetry (anon vs file split, RCON stall alert). **Diagnostics that cracked it**: `/proc/<pid>/smaps_rollup` (anon 1.7G vs RSS 15.9G), cgroup `memory.stat` (anon vs file), `/proc/<pid>/task/*/comm` (ZWorkerYoung = ZGC spinning). If it ever recurs: check thread comms first, then anon/file split — don't trust docker stats alone.
- **Anti-cheat policy scale (from bytecode):** `1=Ban, 2=Kick, 3=Log, 4=Disabled`. Do NOT set to 1 thinking it's "log only" — 1 is MAXIMUM enforcement. Setting to 0 is rejected. Current setting: all at 4 (disabled), only SteamVAC active. World resets regenerate INI but anti-cheat changeoption values persist in the INI file — however the runtime may not hot-apply them; a restart after changeoption is the safe pattern.
- **`setaccesslevel` on an ONLINE player:** the DB updates but the in-memory IsoPlayer keeps the old role until disconnect/reconnect or server restart. A demoted admin who stays online retains admin powers. To force-clear: restart, or ban+unban (ban forcibly disconnects).

## Paths

| What | Where | Owner |
|---|---|---|
| Compose definition | `~/mediaserver/compose.yml` (zomboid service, ~line 980) | ssuomi |
| Server INI | `/opt/dockerdata/zomboid/config/Server/mormonlesbianvampirehunters.ini` | root |
| Sandbox vars | `/opt/dockerdata/zomboid/config/Server/mormonlesbianvampirehunters_SandboxVars.lua` | root |
| User DB | `/opt/dockerdata/zomboid/config/db/mormonlesbianvampirehunters.db` (table `whitelist`) | root |
| Workshop content | `/opt/dockerdata/zomboid/server/steamapps/workshop/content/108600/<id>/` | root |
| World backups | `/opt/dockerdata/zomboid/backups/` | ssuomi |

Root-owned files: no sudo on this host — edit via throwaway container:
`docker run --rm -i -v <dir>:/srv python:3.12-slim python3 - <<'EOF' ... EOF`
(**always `-i`** or the heredoc never reaches the container — silent no-op).
SQLite: read-only queries work from host python; writes need the root container.

## Restart Protocol (when permitted)

Preferred: `python3 ~/mediaserver/scripts/zomboid-rcon.py restart -m "<reason>" -d 60` (announce → wait → save → restart → verify, see RCON section).

Manual equivalent:
1. RCON `save` (script above) — graceful stop also saves (`stop_grace_period: 2m`)
2. `docker compose up -d zomboid` from `~/mediaserver` (recreates on config change; plain `restart` if only sandbox vars changed)
3. Verify in `docker logs zomboid`:
   - `version=42.20.3` — if it shows anything else, STOP and report
   - `LuaNet: Initialization [DONE]` = fully up
   - `grep -c 'required mod.*not found'` should be 0
   - New mods present in `loading <ModID>` lines
   - Entry script adds 2 junk IDs (513111049/514427485) to INI `WorkshopItems=` — harmless, ignore
- GOTCHA: `docker compose up -d zomboid` **no-ops** when compose config is unchanged ("Container zomboid Running") — use `docker compose restart zomboid` to force a reload without recreate, or change the config first

## Client Verification Wall (critical lesson)

B42 clients verify **every server mod byte-for-byte** during the connection handshake, plus vanilla files against the server's version. Consequences (all empirically confirmed):

- **Local/server-only mods are impossible** on a public server: no workshop ID → every connecting client rejects with "mod X is not installed (workshopid: 0)"
- **Modifying a workshop mod's Lua server-side breaks every login**: "File doesn't match the server" — even with `AntiCheatChecksum=2` disabled (the vanilla/mod file check is client-enforced; no server option bypasses it)
- `reloadlua` does NOT bypass the handshake
- The only injection path that works: upload the mod as a **real Steam workshop item** (in-game uploader) and add its ID to MOD_WORKSHOP_IDS — clients then auto-download identical files
- Vanilla-file mismatch (`isreadabook.lua` etc.) = client/server version mismatch. Server on 42.20.3 + client re-updated by Steam → client must re-run `download_depot 108600 108604 3729595427051857860` and set "only update when I launch"
- B42's local-mod scanner also silently drops mods whose mod.info lacks full metadata (`modversion`, `versionMin`, `poster` etc.) — irrelevant for servers (client wall) but matters when preparing a workshop upload

## Character Data Surgery (players.db)

Table `networkPlayers` (keyed by username+world+playerIndex — one account can hold several characters). `name` column goes stale; the real name lives in the blob descriptor. A new character's row only materializes at world entry + first save.

The `data` blob = Java-serialized IsoPlayer (big-endian ByteBuffer, sequential count+entries). Verified-parseable structures:

- **XP header + three sections** (in order after `[totalXp f][lvl i][last i]`):
  1. `xpMap`: N × [2B-len name][float XP] — raw skill XP
  2. `perkList`: M × [name][int level] — **the UI-displayed levels** (authoritative for display; NOT recomputed on save — only `addxp` updates it; direct writes persist)
  3. `xpMapMultiplier`: K × [name][float mult][byte minL][byte maxL] — skill-book multipliers
- **B42 per-skill XP curves are per-perk** (`xp1..xp10` fields on PerkFactory$Perk, set in Java — not the B41 75×n formula). Combat skills (Blunt, Sprinting) are steeper than crafting (Woodwork ≈ classic curve); passives huge (Strength L8 ≈ 240k XP). Don't hand-compute thresholds — use addxp (game computes perkList consistently) or copy perkList directly.
- **readBooks/knownRecipes triple**: `[readBooks: cnt × [name][int pages]]` (pages may be -1) + 4-byte float gap (`reduceInfectionPower`) + `[knownRecipes: cnt × [name]]` — recipes are Make*/Forge*/base:* patterns. A fresh character who read nothing has NO anchor (count 0) — have them read any magazine first, then splice the full set.
- **Stats block**: 19 big-endian floats, alphabetical, last = TEMPERATURE ≈ 37 (strong anchor). BodyDamage per-part layout NOT reliably parseable — don't byte-patch health.
- Death mechanics: `isDead` column force-zeroes health at load; flipping to 0 on a death-state blob = instant re-death (health ~0 serialized). Reviving in place is not achievable without a Lua heal (blocked by client wall). Real revival = new character + splice.

**Transfer recipe (proven repeatedly)**: extract donor xpMap+perkList+multipliers+readBooks+knownRecipes from a backup tar → max-merge with the fresh character's baseline → splice blocks back-to-front (later offsets first) → reparse-verify → write. `addxp` (RCON, live, player must be ONLINE) is preferred for skills when possible; negative values work for corrections. Syntax: `addxp <player> <Perk>=<xp>`.

**CRITICAL splice-visibility rules**:
- The running server holds players.db via ONE open connection — a copy-modify-swap (rename+replace) leaves it serving the OLD inode: splices are invisible until restart. Live-inode writes (no rename) keep visibility but hit SQLite locks; retry with busy_timeout, and if even READS lock (hot journal from interrupted save): stop server → scratch-copy db+journal → recover + edit in scratch → swap → start (~4 min routine).
- Best workflow: player logs out → stop server → splice → start. Every successful splice this session followed a restart.
- Map exploration: `map_visited_server/<username>.zip` = one fixed-size 4,016,020-byte bitmap; transfer = byte-wise OR union, repack same inner name. Username-keyed → new character on same account inherits automatically.
- **Homoglyph accounts + POSIX locale trap**: a player registered `Wеbh` (Cyrillic е, U+0435) alongside ASCII `Webh`. The container ran with no `LANG` → JVM `sun.jnu.encoding=ASCII` → `InvalidPathException` in `WorldMapVisitedServer.loadUser` → map fog silently resets for the non-ASCII account (read AND write both fail). Fix: `LANG=C.UTF-8` in the zomboid env (compose) + repack the ASCII account's zip to the Cyrillic name (outer filename AND inner zip entry must match the username exactly). Check for homoglyphs with `repr()` on whitelist usernames — terminals render them identically.

## RCON

Endpoint `192.168.0.233:27015`, password `ZOMBOID_RCON_PASSWORD` in `.env`. **Use the wrapper script** — it handles auth, PZ's response-lag quirk, and echo filtering:

```
python3 ~/mediaserver/scripts/zomboid-rcon.py <command>          # any RCON command
python3 ~/mediaserver/scripts/zomboid-rcon.py restart -m "server restart in ~1 min" -d 60
```

The `restart` subcommand: shows online players → broadcasts `-m` message in-game (`servermsg`) → waits `-d` seconds (default 60) → `servermsg Restarting now.` → RCON `save` → `docker compose up -d zomboid` (recreates when compose config changed; falls back to `restart` if no-op) → polls container health (≤7 min) → verifies `version=42.20.3` and counts `required mod not found` (exits nonzero on version mismatch).

Known-good commands: `save`, `setaccesslevel <user> <role>`, `showoptions`, `changeoption <name> <value>`, `players`, `servermsg <text>`, `kickuser`, `banuser`, `teleportto <username> x,y,z` (coords COMMA-separated — space-separated args get rejected), `addxp <player> <perk> <xp>`. **Arguments must be unquoted** — `setaccesslevel "user" "admin"` silently no-ops; `setaccesslevel user admin` works. **EXCEPTION: `servermsg` multi-word text MUST be quoted** (`servermsg "my message"`) or PZ returns its usage string and nothing is broadcast; single-word dummies like `servermsg .` work unquoted. Empty RCON echo usually means unknown command or bad syntax (the usage string comes back in a later packet). No sandbox-var or per-user `changepassword` console commands exist. RCON responses are unreliable for multi-packet outputs (`showoptions` often returns nothing).

## Users & Roles

- Role IDs in `whitelist.role`: 2=user, 4=observer, 5=gm, 6=moderator, 7=admin
- Grant/revoke live: RCON `setaccesslevel <username> admin` / `user` — no restart; verify with sqlite read (`role` column)
- Boot admin-sync: entrypoint passes `ADMIN_USERNAME`/`ADMIN_PASSWORD` env; on boot the server hashes+writes that account's whitelist row. It does NOT re-grant role. If that account is demoted, password still gets overwritten at each boot — keep `.env` `ZOMBOID_ADMIN_PASSWORD` equal to that account's intended password.

## Passwords — three layers

1. **Join password** = `.env ZOMBOID_SERVER_PASSWORD` → INI `Password=`
2. **Admin env password** = `.env ZOMBOID_ADMIN_PASSWORD` (boot-synced to ADMIN_USERNAME account; also the in-game `/login` admin password)
3. **Account password** per whitelist row (what the client asks to claim a username)

PZ hash format (verified in bytecode): `bcrypt( md5hex(plaintext), salt="$2a$12$O/BFHoDFPrfFaNPAACmWpu" )` — fixed salt, MD5-hex preimage. Login reads the DB per attempt, so live resets work without restart:

```python
# in root container with /db mounted + pip install bcrypt
import bcrypt, hashlib, sqlite3
h = bcrypt.hashpw(hashlib.md5(b"<plaintext>").hexdigest().encode(),
                  b"$2a$12$O/BFHoDFPrfFaNPAACmWpu").decode()
c = sqlite3.connect("/db/mormonlesbianvampirehunters.db", timeout=15)
c.execute("UPDATE whitelist SET password=? WHERE username=? AND world='mormonlesbianvampirehunters'", (h, "<username>"))
c.commit()
```

Plain bcrypt without the MD5 stage will NEVER match — do not repeat that mistake. Backup the .db before writing.

## Server Options vs Sandbox Vars

- **Server options** (INI: PVP, safehouse rules, MaxPlayers, welcome msg…): live via RCON `changeoption` or in-game admin panel; persist by editing INI (root container) before next boot, else env/regeneration may not keep them.
- **Sandbox vars** (zombies, loot, XP, day length, respawn): file-only (`_SandboxVars.lua`) + restart. No console command exists. Mid-save semantics: population/loot changes affect newly spawned/refilled content; standing zombies never re-roll (speed/lore) until killed.
- Current tuned values (as of 2026-08-29): PopulationMultiplier=0.35, Peak=1.2, RespawnHours=168, RespawnUnseenHours=72, RespawnMultiplier=0.1, RallyGroupSize=10, SprinterPercentage=2.

## Mod Management

Env in compose.yml: `MOD_NAMES` (load list, incl. add-on IDs like `86fordE150mm`, `ECTO1`) and `MOD_WORKSHOP_IDS` (unique workshop IDs). They map to INI `Mods=`/`WorkshopItems=` — **no strict pairing/count match** (e.g. 141 names / 120 IDs is normal).

Add workflow:
1. Resolve mod metadata via Steam Web API (not rate-limited, unlike steamcommunity pages):
   `POST https://api.steampowered.com/ISteamRemoteStorage/GetPublishedFileDetails/v1/` with `itemcount` + `publishedfileids[N]` → title, tags, time_updated, description (contains `Mod ID:`)
2. Reject/flag: B41-only (no Build 42 tag + stale update date), `[DISCONTINUED]`/`[Outdated]` titles
3. Append to both env lists in compose.yml; validate: `docker compose config` → parse OK, counts, no dupes
4. On next permitted restart, verify via load logs

Gotchas:
- **Version-resolved mod IDs**: an item may ship `42.20/mod.info` (id=A) AND `common/mod.info` (id=B). On 42.20.3 the loader registers A. If logs show `required mod "X" not found` and X was taken from the description, read the actual `mods/*/mod.info` files under the workshop dir and correct compose.yml.
- Mutually-exclusive builds: Firearms (2256623447) ships `firearmmod`/`firearmmodbeta`/`firearmmodvanilla` — load only ONE (server uses `firearmmod`).
- Client-side-only mods (e.g. Performance Tuner) are fine to list server-side just for distribution; their "engine file" manual installs are per-player and out of scope.
- `AdvancedAnimator visitFileFailed` stack traces, `template "DAMN..." not found`, XuiSkin icon warnings, mannequin-zone error = benign noise.

## Client Compatibility (players)

- Clients must be exactly 42.20.3. Mismatch → `ChecksumPacket ... kicked` in server logs + "File doesn't match the one on the server" client-side. Fix is client-side: Steam console `download_depot 108600 108604 3729595427051857860` (Windows; Mac 108602/6221927640309426534) + disable auto-update.
- FPS mod conflict: server pushes `Tempo_PerfKit_42203_Local` (Performance Tuner); players must NOT run ZBBetterFPS/BetterFPS_B42.
- FPS issues after depot downgrade: delete `%USERPROFILE%\Zomboid\TexturePacks` (stale repack), check Steam didn't half re-update.

## Version Pin (critical)

`version=42.20.3` must hold. The entrypoint's own steamcmd check has been failing with `Error! App '380870' state is 0x6` — this failure is load-bearing; it keeps the server pinned. After any restart, verify the version line FIRST. If a restart ever lands a newer version, options: throwaway steamcmd container with the old depot manifest (`docker run --rm -v /opt/dockerdata/zomboid/server:/home/steam/ZomboidDedicatedServer steamcmd/steamcmd:latest +login anonymous +download_depot 380870 <manifest> +quit` then place files) — or wait for players to update.

## Backups

**`zomboid-butler` sidecar** (compose service `zomboid-butler`, code in `~/mediaserver/zomboid-butler/` — 9 modules: `main.py` entrypoint, `config.py` knobs+state, `rcon.py`, `dockerapi.py`, `notify.py`, `backup.py`, `telemetry.py`, `updates.py`, `restarts.py`; dir mounted ro at `/app`, runs `python /app/main.py`): hourly cycle = RCON `save` → SQLite-API consistent copies → `world-hourly-<ts>.tar.gz` (keep 24, `/opt/dockerdata/zomboid/backups/`) + memory anon/file telemetry + GC digest (parses `config/gc.log`, appends to `backups/gc-history.log`, "pending" until first server restart with GC logging) + workshop update check + RCON health (ntfy on stall). 60s tick = **three valves**: (1) memory emergency (`EMERGENCY_TOTAL_PCT=90` of limit OR `EMERGENCY_ANON_GB=7.5` → servermsg 2-min warning → save → docker-API restart → verify → ntfy; RCON dead = instant restart); (2) **GC degradation** (`GC_PAUSE_MIN_COUNT=3` pauses >1s in the last hour → announced restart; boot-storm guarded — window excludes first 10 min while uptime < 80 min, skipped entirely under 20 min uptime; 60-min cooldown) — memory can look fine while pauses degrade play, this is the player-experience valve; (3) **dynamic update restarts** — join-attempt trigger uses `JOIN_COOLDOWN_MINUTES=45` (clients auto-update mods on game launch → checksum-kick vs outdated server → blocked joiner is urgent), empty-server uses `UPDATE_COOLDOWN_HOURS=2`; stuck-breaker: same items pending after 2 restarts → 24h pause + ntfy. LESSON (2026-09-08): the original single 12h cooldown gated the join-trigger, blocking players for hours after any restart — split cooldowns by urgency. State: `backups/butler-state.json`. Notifications DIRECT to ntfy container IP via docker API (Caddy :80 redirects; `http://<ntfy-ip>:80/<topic>` works).

**STAGED (2026-09-07, pending `docker compose up -d zomboid` — valve restarts via docker API do NOT apply compose config)**: `mem_limit: 19g` + `JAVA_TOOL_OPTIONS=-XX:+UseCompactObjectHeaders` (env, NOT vmArgs — the entrypoint sed `s/-XX:+Use.*/...` would clobber any `-XX:+Use*` flag added to the json) + rotated `-Xlog:gc:file=/home/steam/Zomboid/gc.log:time,uptime:filecount=5,filesize=10M` in json + mod `Tempo_PerfKit`/`3736629791` (B42 perf: dense-zombie render LOD, chunk streaming; successor of the pulled Tempo_PerfKit_42203_Local lineage). **ZGC was staged then deliberately reverted to G1GC/8G**: G1 proved itself empirically (plateau ~6.6-6.9G with 4-6 players, sawtooth cycles down ~1.4G, zero freezes) and the one 0-TPS freeze class occurred under ZGC+cgroup pressure; dev guidance sanctions G1 at ≤8G heaps. Don't revisit ZGC without new evidence.

**TIS dev guidance (Reddit, 2026-09)**: ZGC is TIS default, G1 fine ≤8G heaps; Xms should be omitted (heap grows/shrinks ~every 10 min); reserve ~30% outside heap; scheduled restarts "should not be necessary" (leaks = reportable bugs); monitor heap via GC logs/in-game Show Statistics — NOT container/system monitors (they measure committed+cache, not live set); `-XX:+UseCompactObjectHeaders` (Java 25) lowers RAM ~free win; `-XX:+UseStringDeduplication` trades CPU for RAM.

**GC tuning applied (2026-09-09)**: `-XX:G1HeapRegionSize=32m` in the json vmArgs (sed-safe, no `-XX:+Use` prefix) — PZ world saves allocate huge serialization buffers that become G1 humongous objects with default region sizes → multi-second mixed-GC stalls that players feel as rubber-banding even at low heap usage. gc-history showed pauses climbing 1.3→3.5s during sessions with anon under 4.5G. With 32m regions, humongous threshold = 16m. GC digest format in `gc-history.log`: `live-set=XM gcs=N hr: max-pause=Xms pauses>1s=N` (live-set = heap after last Pause line; pauses windowed to last hour, boot-storm-excluded).

**ZeroByte restic**: weekly Mondays 04:00 (`keepLast:1, keepMonthly:2` — snapshot list looks sparse by design). Check with:
`docker exec zerobyte restic -r /var/lib/zerobyte/repositories/78BTzDh4 --password-file /var/lib/zerobyte/data/restic.pass snapshots`
Caveat: `keepLast:1` means one failed weekly run = no recent snapshot.

Gotchas: PZ's OWN boot-rotation backups live in `config/backups/` (BackupsOnStart, grew to 3.9 GB) — exclude from any tar. Manual hot backup (no restart): RCON `save` → API DB copies → tar Saves/db/Server → same dir. Stopped-state backup is the gold standard. Rollback: stop, extract over `/opt/dockerdata/zomboid/config`, start. Snapshot inventory Aug 30-31: `world-20260828.tar.gz`, `world-20260829-prerevive.tar.gz`, `world-20260830-prerecipe/premap.tar.gz`, `world-hourly-*`.

Hot backup (no restart, no player drops): RCON `save` → SQLite backup-API copies of players/vehicles/whitelist DBs → `tar -czf /opt/dockerdata/zomboid/backups/world-$(date +%Y%m%d)-manual.tar.gz -C /opt/dockerdata/zomboid/config Saves db Server` (+ the API copies). Stopped-state backup (gold standard, uses a restart window): RCON `save` → `docker compose stop zomboid` → same tar → `up -d`. Rollback: stop, extract over `/opt/dockerdata/zomboid/config`, start. Existing snapshots: `world-20260828.tar.gz` (pre-mod-surge), `world-20260829-prerevive.tar.gz`, `world-20260829-manual.tar.gz`.
