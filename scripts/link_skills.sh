#!/usr/bin/env bash

# Uncomment to echo command before executing (Used for debugging)
# set -x

set -euo pipefail

REPO="$(realpath "$(dirname "$0")/..")"
SKILLS="$REPO/skills"

result=$(find . -name "SKILL.md" -type f -exec dirname {} \; | xargs realpath)

echo "$result" | while read -r abs_path;
do
    [[ -z "$abs_path" ]] && continue

    name=$(basename "$abs_path")
    out="$HOME/.agents/skills/$name"

    echo "Linking absolute path: $abs_path -> $out"

    ln -sfn "$abs_path" "$out"
done
