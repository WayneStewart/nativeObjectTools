# Handover — Native Object Tools release pipeline

**Date:** 2026-04-22 (second session)
**Purpose:** End-of-session handover. Prior handover: `Release/handover-2026-04-22.md`.

---

## What was accomplished this session

### 1. Branch model finalised

Four branches settled:

| Branch | Purpose | Who writes to it |
|---|---|---|
| Wombat (per-feature) | Active development; one branch per feature/fix | Developer |
| Echidna | Integration branch; only receives confirmed merges from Wombat | Developer |
| Koala | Stripped, OTr_-flavoured, build-verified release source | Pipeline (force-push only) |
| Platypus | Stripped, renamed OT-flavoured, build-verified release source | Pipeline (force-push only) |

Pipeline trigger: `workflow_dispatch` on Echidna. Koala and Platypus are never pushed to by hand.

### 2. End-to-end packaging process confirmed (manual)

All steps tested successfully on the dev machine (Pardalote):

- **Codesign:** `codesign --remove-signature` then `codesign --verbose --deep --timestamp --force --sign` on `lib4d-arm64.dylib` inside each component's `Libraries/` folder. v19 only.
- **DMG Canvas CLI:** builds, notarises, and staples in one step. Template paths are relative to template location and resolve correctly.
- **ZIP:** mount DMG at fixed mountpoint (`-mountpoint /Volumes/OTrNN`), `cd` into mountpoint, then `zip -r` — critical that `cd` happens first to avoid path prefix in ZIP entries.
- **Notarisation credentials:** Apple ID + app-specific password stored as GitHub Actions secret `NOTARIZATION_PASSWORD`.

DMG Canvas CLI symlink created at `/usr/local/bin/dmgcanvas` on dev machine. Must be created on runner also.

### 3. DMG Canvas templates moved into repo

Three templates committed to `Release/Templates/`:

| Template | Text object identifier (title) |
|---|---|
| `Object Tools Replacement 19.dmgcanvas` | `dkptruadnw` |
| `Object Tools Replacement 20.dmgcanvas` | `mpzbasjdff` |
| `Object Tools Replacement 21.dmgcanvas` | `mpzbasjdff` |

Version text label removed from templates during tidying — version appears in filename only.

### 4. `release.yml` written and committed

Full pipeline workflow at `.github/workflows/release.yml`. Structure:

| Job | Depends on | What it does |
|---|---|---|
| `strip` | — | Checks out Echidna, clears build-output, runs stageKoala.sh, reads version from InfoPlist.json |
| `build-otr` | strip | Builds OTr_ component for v19, v20, v21 |
| `push-koala` | strip, build-otr | Force-pushes stripped tree to Koala branch |
| `rename` | push-koala | Runs Renamer (forward) to produce Platypus state |
| `build-ot` | strip, rename | Builds OT component for v19, v20, v21 |
| `push-platypus` | strip, build-ot | Force-pushes renamed tree to Platypus branch |
| `package` | strip, build-otr, build-ot, push-platypus | Signs dylibs, runs dmgcanvas, mounts/zips for all three versions |
| `publish` | strip, package | Creates GitHub Release and uploads all 6 artefacts via `gh` CLI |

Key facts baked into the workflow:
- Runner work path: `/Users/runner/actions-runner/_work/nativeObjectTools/nativeObjectTools/`
- 4D executables: `/Applications/4D/19/4D.app`, `/Applications/4D/20/4D.app`, `/Applications/4D/21/4D.app` (no `LTS` subdirectory on runner)
- Sentinel filename: `build-{version}-{variant}.txt`, line 1: `build-{version}-{variant} passed`
- Version read from `Resources/InfoPlist.json` using `encoding='utf-8-sig'` (file has BOM)
- `GITHUB_TOKEN` is automatic — no manual secret needed for GitHub Release creation
- `NOTARIZATION_PASSWORD` secret must exist in repository settings

### 5. First workflow run attempted — stalled

The workflow ran successfully through the `strip` job (including the UTF-8 BOM fix for InfoPlist.json). The `build-otr` job launched 4D v19 headlessly but 4D stalled — the diagnostic log shows only 3 entries (parameters parsed, then nothing) followed by thousands of SSL write timeout errors to an AWS endpoint (`35.180.74.122:443`). This is 4D's licence/activation network call hanging.

4D was force-quit before bed. Root cause not yet confirmed.

---

## Open issues

### 4D licence activation on runner account

The stall is almost certainly 4D attempting to contact the licence server at startup and timing out. 4D must be launched interactively at least once under the `runner` account to cache its licence before headless runs will work reliably.

**First thing to do next session:** Launch 4D v19 interactively under the runner account, confirm it activates cleanly, quit it, then re-run the workflow.

Also worth checking: does the runner's network configuration allow outbound HTTPS to Apple/4D licence endpoints? The timeouts suggest it may be blocked or rate-limited.

### dmgcanvas symlink on runner

Confirmed on dev machine (`/usr/local/bin/dmgcanvas`). Must be verified on runner before the `package` job can succeed. Run `which dmgcanvas` under the runner account.

### v20 and v21 builds untested

Only v19 has been manually tested end-to-end. The workflow will attempt v20 and v21 but these have never been run headlessly. Expect possible issues.

### Multi-version `build-otr` sentinel collision

Each of v19, v20, v21 writes to the same sentinel filename (`build-{version}-OTr.txt`) since the version is the same for all three. The workflow reads the sentinel immediately after each build, so this should be fine sequentially — but worth keeping in mind if steps are ever parallelised.

---

## Key terminal commands (for reference)

```bash
# Manual codesign (run from component's Libraries/ folder)
codesign --remove-signature lib4d-arm64.dylib
codesign --verbose --deep --timestamp --force \
    --sign "Developer ID Application: Mac to Basics P/L (H8FSU88B4T)" \
    lib4d-arm64.dylib

# Manual DMG Canvas CLI
REPO='/Users/waynestewart/4D/Projects/OT Replacement'
VERSION="1.0 Beta 5"
dmgcanvas \
    "$REPO/nativeObjectTools/Release/Templates/Object Tools Replacement 19.dmgcanvas" \
    "$REPO/nativeObjectTools/Builds/19/Object Tools 19 LTS $VERSION.dmg" \
    -notarizationAppleID "waynestewart@mac.com" \
    -notarizationPassword "YOUR_APP_SPECIFIC_PASSWORD" \
    -notarizationTeamID "H8FSU88B4T"

# Manual mount and zip
hdiutil attach "$DMG" -mountpoint /Volumes/OTr19 -nobrowse -quiet
cd /Volumes/OTr19
zip -r "$ZIP" "Native Object Tools.4dbase" "Object Tools.4dbase"
hdiutil detach /Volumes/OTr19 -quiet
```

---

## Key facts

- **Apple Team ID:** H8FSU88B4T
- **Developer ID:** `Developer ID Application: Mac to Basics P/L (H8FSU88B4T)`
- **Notarization Apple ID:** waynestewart@mac.com
- **GitHub Actions secret:** `NOTARIZATION_PASSWORD` (app-specific password)
- **Runner install path:** `/Users/runner/actions-runner/`
- **Runner label set:** `self-hosted`, `macOS`, `X64`, `iMac-Pro`, `native-object-tools-release`
- **Repository:** github.com/WayneStewart/nativeObjectTools
- **4D executables on runner:** `/Applications/4D/19/4D.app`, `/Applications/4D/20/4D.app`, `/Applications/4D/21/4D.app`
- **4D executables on dev machine:** `/Applications/4D/19/LTS/4D.app` etc. (has `LTS` subdirectory)
- **dmgcanvas CLI:** `/usr/local/bin/dmgcanvas` (symlink) on dev machine; must be confirmed on runner
- **InfoPlist.json:** UTF-8 with BOM — read with `encoding='utf-8-sig'` in Python
- **Sentinel contract:** `build-{version}-{variant}.txt`, line 1 is `build-{version}-{variant} passed` or `build-{version}-{variant} failed`
- **build-output/ directory:** must exist and be empty before each workflow run; created by `strip` job

---

**End of handover.**
