#!/usr/bin/env bash
# notarise.sh — codesign, notarise, and staple helper for Native Object Tools
#
# Usage:
#   notarise.sh sign   <component.4dbase>   Sign a single built component (v19 only)
#   notarise.sh dmg    <installer.dmg>      Submit a DMG for notarisation and staple it
#   notarise.sh verify <installer.dmg>      Verify stapling on a completed DMG
#
# Environment / assumptions:
#   - Developer ID Application certificate is in the runner's login keychain
#   - notarytool keychain profile "OTr-Notary" is already configured
#   - Called from the GitHub Actions workflow; exits non-zero on any failure
#
# Sentinel contract (when called from the workflow):
#   On failure this script writes a one-line sentinel and exits 1.
#   The workflow reads the sentinel's first line; any line not ending in
#   " passed" causes the job to fail.

set -euo pipefail

DEVELOPER_ID="Developer ID Application: Mac to Basics P/L (H8FSU88B4T)"
KEYCHAIN_PROFILE="OTr-Notary"
SENTINEL_DIR="${GITHUB_WORKSPACE:-.}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

die() {
    echo "$*" >&2
    exit 1
}

write_sentinel() {
    local name="$1"
    local status="$2"   # "passed" or "failed"
    local detail="${3:-}"
    local file="${SENTINEL_DIR}/${name}.txt"
    echo "${name} ${status}" > "$file"
    if [[ -n "$detail" ]]; then
        echo "$detail" >> "$file"
    fi
}

# ---------------------------------------------------------------------------
# sign — re-sign a built .4dbase component (used for v19)
#
# 4D v19 cannot sign during BUILD APPLICATION, so this step strips any
# existing ad-hoc signature and applies the Developer ID signature to the
# dylib inside the component bundle.
# ---------------------------------------------------------------------------

cmd_sign() {
    local component="$1"
    local sentinel_name="sign-$(basename "$component" .4dbase)"

    [[ -d "$component" ]] || die "sign: not a directory: $component"

    echo "Signing: $component"

    # Find the dylib to sign — 4D components ship lib4d-arm64.dylib (Apple Silicon)
    # and/or lib4d-x86_64.dylib (Intel). Sign all that are present.
    local dylibs
    dylibs=$(find "$component" -name "lib4d*.dylib" 2>/dev/null || true)

    if [[ -z "$dylibs" ]]; then
        # No dylib found — the component itself may be the signing target
        dylibs="$component"
    fi

    while IFS= read -r target; do
        echo "  Removing existing signature: $target"
        codesign --remove-signature "$target" 2>/dev/null || true

        echo "  Applying Developer ID signature: $target"
        codesign \
            --sign "$DEVELOPER_ID" \
            --options runtime \
            --timestamp \
            --force \
            "$target" \
            || { write_sentinel "$sentinel_name" "failed" "codesign failed on $target"; exit 1; }
    done <<< "$dylibs"

    # Sign the bundle itself
    echo "  Signing bundle: $component"
    codesign \
        --sign "$DEVELOPER_ID" \
        --options runtime \
        --timestamp \
        --force \
        "$component" \
        || { write_sentinel "$sentinel_name" "failed" "codesign failed on bundle $component"; exit 1; }

    echo "  Verifying signature"
    codesign --verify --deep --strict "$component" \
        || { write_sentinel "$sentinel_name" "failed" "codesign --verify failed on $component"; exit 1; }

    write_sentinel "$sentinel_name" "passed"
    echo "sign passed: $component"
}

# ---------------------------------------------------------------------------
# dmg — submit a DMG to Apple's notarisation service and staple it
# ---------------------------------------------------------------------------

cmd_dmg() {
    local dmg="$1"
    local sentinel_name="notarise-$(basename "$dmg" .dmg)"

    [[ -f "$dmg" ]] || die "dmg: file not found: $dmg"

    echo "Submitting for notarisation: $dmg"
    xcrun notarytool submit "$dmg" \
        --keychain-profile "$KEYCHAIN_PROFILE" \
        --wait \
        --output-format json \
        > "${SENTINEL_DIR}/${sentinel_name}-notarytool.json" \
        || { write_sentinel "$sentinel_name" "failed" "notarytool submit failed — see ${sentinel_name}-notarytool.json"; exit 1; }

    # Check the status field in the JSON response
    local status
    status=$(python3 -c \
        "import json,sys; d=json.load(open('${SENTINEL_DIR}/${sentinel_name}-notarytool.json')); print(d.get('status','unknown'))")

    if [[ "$status" != "Accepted" ]]; then
        write_sentinel "$sentinel_name" "failed" "notarytool status: $status — see ${sentinel_name}-notarytool.json"
        exit 1
    fi

    echo "Stapling: $dmg"
    xcrun stapler staple "$dmg" \
        || { write_sentinel "$sentinel_name" "failed" "stapler failed on $dmg"; exit 1; }

    echo "Validating staple: $dmg"
    xcrun stapler validate "$dmg" \
        || { write_sentinel "$sentinel_name" "failed" "stapler validate failed on $dmg"; exit 1; }

    write_sentinel "$sentinel_name" "passed"
    echo "notarise passed: $dmg"
}

# ---------------------------------------------------------------------------
# verify — validate stapling on an already-notarised DMG
# ---------------------------------------------------------------------------

cmd_verify() {
    local dmg="$1"

    [[ -f "$dmg" ]] || die "verify: file not found: $dmg"

    echo "Verifying: $dmg"
    xcrun stapler validate "$dmg" || die "stapler validate failed: $dmg"
    echo "verify passed: $dmg"
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------

[[ $# -ge 2 ]] || die "Usage: notarise.sh <sign|dmg|verify> <path>"

COMMAND="$1"
TARGET="$2"

case "$COMMAND" in
    sign)   cmd_sign   "$TARGET" ;;
    dmg)    cmd_dmg    "$TARGET" ;;
    verify) cmd_verify "$TARGET" ;;
    *)      die "Unknown command: $COMMAND. Expected: sign, dmg, or verify" ;;
esac
