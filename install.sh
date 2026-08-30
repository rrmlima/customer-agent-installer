#!/usr/bin/env bash
set -euo pipefail

SOURCE_URL="https://raw.githubusercontent.com/rrmlima/customer-agent-installer/main/bootstrap-v0.3.0.sh"
EXPECTED_SHA256="9c5cdfb2c55ae7f58cce5e68d5cad174f1208de63b3b3c5ffbbaecc4789cb4ff"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl -fsSL "$SOURCE_URL" -o "$tmp"
actual="$(sha256sum "$tmp" | cut -d' ' -f1)"
if [[ "$actual" != "$EXPECTED_SHA256" ]]; then
  printf 'ERRO: checksum do bootstrap não confere\n' >&2
  exit 1
fi
exec bash "$tmp" "$@"
