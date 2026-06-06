#!/usr/bin/env bash

# Uncomment to echo command before executing (Used for debugging)
# set -x

set -euo pipefail

REPO="$(realpath "$(dirname "$0")/..")"
SKILLS="$REPO/skills"

