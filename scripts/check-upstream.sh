#!/bin/bash
# Is there a newer gamescope than UPSTREAM_VERSION, and does the patch still apply to it?
# Prints key=value lines (also appended to $GITHUB_OUTPUT when set): latest, current, newer (yes/no), applies (yes/no/n.a.).
# usage: scripts/check-upstream.sh
set -u
cd "$(dirname "$0")/.." || exit 1

current=$(tr -d '[:space:]' < UPSTREAM_VERSION)
# plain release tags only (3.16.31, not 3.16.23.6 or -dmemcg)
latest=$(git ls-remote --tags --refs https://github.com/ValveSoftware/gamescope.git |
    sed 's|.*refs/tags/||' | grep -E '^3\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
[[ -n "$latest" ]] || { echo "could not read gamescope's tags" >&2; exit 1; }

newer=no applies=n.a.
if [[ "$(printf '%s\n%s\n' "$current" "$latest" | sort -V | tail -1)" == "$latest" && "$latest" != "$current" ]]; then
    newer=yes
    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    git -c advice.detachedHead=false clone -q --depth 1 --branch "$latest" https://github.com/ValveSoftware/gamescope.git "$work/gamescope" || exit 1
    if git -C "$work/gamescope" apply --check "$PWD/gamescope-gbm-scanout.patch" 2>/dev/null; then applies=yes; else applies=no; fi
fi

out="current=$current
latest=$latest
newer=$newer
applies=$applies"
echo "$out"
[[ -n "${GITHUB_OUTPUT:-}" ]] && echo "$out" >> "$GITHUB_OUTPUT"
exit 0
