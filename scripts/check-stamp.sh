#!/usr/bin/env bash
#
# Verify the consistency stamp matches the current commit.
#
# The stamp is written by Claude during /harden or /stage after validating
# README ↔ skills consistency. If the stamp is stale or missing, this script
# fails and tells you to run /harden.
#
# Usage: bash scripts/check-stamp.sh
# Exit 0 = stamp is current, Exit 1 = stale or missing

set -euo pipefail

STAMP_FILE=".consistency-stamp"
HEAD_HASH=$(git rev-parse HEAD)

if [ ! -f "$STAMP_FILE" ]; then
    echo "FAIL: No consistency stamp found."
    echo "      Run /harden to validate README and skills consistency."
    exit 1
fi

STAMP_HASH=$(head -1 "$STAMP_FILE")

if [ "$STAMP_HASH" != "$HEAD_HASH" ]; then
    echo "FAIL: Consistency stamp is stale."
    echo "      Stamp: $STAMP_HASH"
    echo "      HEAD:  $HEAD_HASH"
    echo "      Run /harden to re-validate after your changes."
    exit 1
fi

STAMP_TIME=$(sed -n '2p' "$STAMP_FILE")
echo "OK: Consistency verified at $STAMP_TIME (${HEAD_HASH:0:7})"
