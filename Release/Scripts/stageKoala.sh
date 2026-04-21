#!/usr/bin/env bash
# stageKoala.sh — strip the working tree down to the Koala release set
#
# Usage (from anywhere inside the repo):
#   bash Release/Scripts/stageKoala.sh
#
# What it does:
#   Reads Resources/exclusions.json and deletes everything listed there
#   from the working tree in place. Run this on a branch or after a fresh
#   clone; discard with `git checkout .` or re-clone if something goes wrong.
#
#   Applies two rule types from exclusions.json:
#     alwaysStrip  — removes matching paths/globs unconditionally.
#     retainOnly   — for nominated directories, removes everything
#                    except the listed files.
#
# Exit code:
#   0 on success, 1 on any error.
#
# Dependencies:
#   bash 3.2+, python3 (stdlib only)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
EXCLUSIONS_JSON="${REPO_ROOT}/Resources/exclusions.json"

[[ -f "$EXCLUSIONS_JSON" ]] || { echo "stageKoala: exclusions manifest not found: $EXCLUSIONS_JSON" >&2; exit 1; }

echo "stageKoala: repo root = ${REPO_ROOT}"
echo "stageKoala: applying exclusions from Resources/exclusions.json"

python3 - "$REPO_ROOT" "$EXCLUSIONS_JSON" <<'PYEOF'
import json, os, sys, glob, shutil

repo_root = sys.argv[1]
json_path = sys.argv[2]

with open(json_path) as f:
    manifest = json.load(f)

# ---- alwaysStrip ----
for pattern in manifest.get("alwaysStrip", []):
    if pattern.endswith("/"):
        target = os.path.join(repo_root, pattern.rstrip("/"))
        if os.path.exists(target):
            shutil.rmtree(target)
            print(f"  removed dir:  {pattern.rstrip('/')}/")
    elif "*" in pattern:
        matches = glob.glob(os.path.join(repo_root, pattern))
        for match in matches:
            if os.path.isdir(match):
                shutil.rmtree(match)
            else:
                os.remove(match)
            print(f"  removed:      {os.path.relpath(match, repo_root)}")
        if not matches:
            print(f"  (no match):   {pattern}")
    else:
        target = os.path.join(repo_root, pattern)
        if os.path.isfile(target):
            os.remove(target)
            print(f"  removed:      {pattern}")
        elif os.path.isdir(target):
            shutil.rmtree(target)
            print(f"  removed dir:  {pattern}")
        else:
            print(f"  (not found):  {pattern}")

# ---- retainOnly ----
for rule in manifest.get("retainOnly", []):
    directory = rule["directory"].rstrip("/")
    keep_set  = set(rule.get("keep", []))
    abs_dir   = os.path.join(repo_root, directory)

    if not os.path.isdir(abs_dir):
        print(f"  (skip retainOnly — not found): {directory}/")
        continue

    # Build the set of absolute paths to preserve (files + their ancestor dirs)
    preserve = set()
    for keep_path in keep_set:
        abs_keep = os.path.join(abs_dir, keep_path)
        preserve.add(abs_keep)
        parent = os.path.dirname(abs_keep)
        while parent != abs_dir and parent.startswith(abs_dir):
            preserve.add(parent)
            parent = os.path.dirname(parent)

    # Walk depth-first; remove anything not in the preserve set
    for root, dirs, files in os.walk(abs_dir, topdown=False):
        for name in files:
            full = os.path.join(root, name)
            if full not in preserve:
                os.remove(full)
                print(f"  removed:      {os.path.relpath(full, repo_root)}")
        for name in dirs:
            full = os.path.join(root, name)
            if full not in preserve and os.path.isdir(full):
                shutil.rmtree(full)
                print(f"  removed dir:  {os.path.relpath(full, repo_root)}/")

PYEOF

echo "stageKoala: done"
