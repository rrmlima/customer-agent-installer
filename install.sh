#!/usr/bin/env bash
set -euo pipefail

SOURCE_URL="https://raw.githubusercontent.com/rrmlima/fazer-ai-deploy-standard/v0.3.0/scripts/bootstrap-install.sh"
EXPECTED_SHA256="8cb9687dc9c007ce5a4c75aacdd5d10d93e1a2967474558acf76b8ab244d4185"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "$SOURCE_URL" -o "$tmp"
actual="$(sha256sum "$tmp" | cut -d' ' -f1)"
if [[ "$actual" != "$EXPECTED_SHA256" ]]; then
  printf 'ERRO: checksum do bootstrap não confere\n' >&2
  exit 1
fi
exec bash "$tmp" "$@"
