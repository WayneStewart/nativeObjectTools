#!/usr/bin/env bash
# stageKoala.sh — strip the Echidna working tree down to the Koala release tree
#
# Usage:
#   stageKoala.sh <source_dir> <dest_dir>
#
#   source_dir  Path to a clean clone of the Echidna repository.
#               The script never modifies this tree.
#   dest_dir    Destination directory for the stripped Koala tree.
#               Must not already exist; the script creates it.
#
# What it does:
#   1. Copies the entire source tree to dest_dir (rsync, no git history).
#   2. Applies every rule in Resources/exclusions.json:
#        alwaysStrip  — removes matching paths/globs unconditionally.
#        retainOnly   — for nominated directories, removes everything
#                       except the listed files.
#   3. Writes a one-line sentinel to dest_dir/stage-koala.txt:
#        "stage-koala passed"   on success
#        "stage-koala failed"   on any error (also exits 1)
#
# Sentinel contract:
#   The GitHub Actions workflow reads the first line of the sentinel with
#   `head -n 1`. Any line not equal to "stage-koala passed" fails the job.
#
# Dependencies:
#   bash 3.2+, rsync, python3 (stdlib only — used to parse exclusions.json)
#
# Notes:
#   - Glob patterns in alwaysStrip use standard shell glob syntax.
#     `*` matches within a single path component only; `**` is not used.
#   - Paths ending in `/` denote directories and are removed recursively.
#   - All paths in exclusions.json are relative to the repository root.

set -euo pipefail

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

die() {
    echo "stageKoala: error: $*" >&2
    if [[ -n "${DEST_DIR:-}" ]]; then
        write_sentinel "failed" "$*"
    fi
    exit 1
}

write_sentinel() {
    local status="$1"   # "passed" or "failed"
    local detail="${2:-}"
    local file="${DEST_DIR}/stage-koala.txt"
    echo "stage-koala ${status}" > "$file"
    if [[ -n "$detail" ]]; then
        echo "$detail" >> "$file"
    fi
}

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------

[[ $# -eq 2 ]] || {
    echo "Usage: stageKoala.sh <source_dir> <dest_dir>" >&2
    exit 1
}

SOURCE_DIR="${1%/}"   # strip any trailing slash
DEST_DIR="${2%/}"

[[ -d "$SOURCE_DIR" ]] || die "source directory not found: $SOURCE_DIR"
[[ ! -e "$DEST_DIR" ]] || die "destination already exists (remove it first): $DEST_DIR"

EXCLUSIONS_JSON="${SOURCE_DIR}/Resources/exclusions.json"
[[ -f "$EXCLUSIONS_JSON" ]] || die "exclusions manifest not found: $EXCLUSIONS_JSON"

# ---------------------------------------------------------------------------
# Step 1: Copy source to dest (rsync; excludes .git metadata)
# ---------------------------------------------------------------------------

echo "stageKoala: copying ${SOURCE_DIR} → ${DEST_DIR}"
rsync -a --exclude='.git/' "${SOURCE_DIR}/" "${DEST_DIR}/"
echo "stageKoala: copy complete"

# ---------------------------------------------------------------------------
# Step 2: Parse exclusions.json with Python and emit a shell script fragment
#         that performs the actual deletions. Using Python for JSON parsing
#         avoids a dependency on jq while remaining readable and testable.
# ---------------------------------------------------------------------------

STRIP_SCRIPT=$(python3 - "$DEST_DIR" "$EXCLUSIONS_JSON" <<'PYEOF'
import json, os, sys

dest_dir   = sys.argv[1]
json_path  = sys.argv[2]

with open(json_path) as f:
    manifest = json.load(f)

lines = []

# ---- alwaysStrip ----
for pattern in manifest.get("alwaysStrip", []):
    if pattern.endswith("/"):
        # Directory — remove recursively
        abs_pattern = os.path.join(dest_dir, pattern.rstrip("/"))
        lines.append(f'rm -rf -- "{abs_pattern}"')
    elif "*" in pattern:
        # Glob — let the shell expand it
        abs_pattern = os.path.join(dest_dir, pattern)
        lines.append(f'for f in {abs_pattern}; do [ -e "$f" ] && rm -rf -- "$f" || true; done')
    else:
        # Literal file/path
        abs_pattern = os.path.join(dest_dir, pattern)
        lines.append(f'rm -f -- "{abs_pattern}"')

# ---- retainOnly ----
for rule in manifest.get("retainOnly", []):
    directory = rule["directory"].rstrip("/")
    keep_set  = set(rule.get("keep", []))
    abs_dir   = os.path.join(dest_dir, directory)
    lines.append(f'# retainOnly: {directory}')
    lines.append(f'if [ -d "{abs_dir}" ]; then')
    # Walk only the immediate contents described in keep_set, which may use
    # slash-separated sub-paths like "images/Wombat.png". Build a set of all
    # paths (and their ancestor directories) that must be preserved so we can
    # identify anything not in that set for deletion.
    lines.append(f'  _keep_abs=""')
    for keep_path in keep_set:
        abs_keep = os.path.join(abs_dir, keep_path)
        lines.append(f'  _keep_abs="$_keep_abs\\n{abs_keep}"')
        # Also protect the parent directory of each keep path
        parent = os.path.dirname(abs_keep)
        while parent != abs_dir and parent != "/":
            lines.append(f'  _keep_abs="$_keep_abs\\n{parent}"')
            parent = os.path.dirname(parent)
    lines.append(f'  while IFS= read -r -d "" _item; do')
    lines.append(f'    if ! printf "%b" "$_keep_abs" | grep -qxF "$_item"; then')
    lines.append(f'      rm -rf -- "$_item"')
    lines.append(f'    fi')
    lines.append(f'  done < <(find "{abs_dir}" -mindepth 1 -maxdepth 2 -print0)')
    lines.append(f'fi')

print("\n".join(lines))
PYEOF
)

# ---------------------------------------------------------------------------
# Step 3: Execute the generated deletion commands
# ---------------------------------------------------------------------------

echo "stageKoala: applying exclusions"
eval "$STRIP_SCRIPT"
echo "stageKoala: exclusions applied"

# ---------------------------------------------------------------------------
# Step 4: Write success sentinel
# ---------------------------------------------------------------------------

write_sentinel "passed"
echo "stageKoala: stage-koala passed"
