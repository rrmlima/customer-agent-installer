#!/usr/bin/env bash
set -euo pipefail

PROFILE="${HERMES_PROFILE:-fazer-ai}"
KIT_DIR="${CUSTOMER_AGENT_HOME:-$HOME/customer-agent-deploy}"
REPO="rrmlima/fazer-ai-deploy-standard"
VERSION="${CUSTOMER_AGENT_VERSION:-v0.3.0}"

say() { printf '\n==> %s\n' "$*"; }
die() { printf '\nERRO: %s\n' "$*" >&2; exit 1; }

case "$(uname -s)" in Linux|Darwin) ;; *) die "este instalador suporta Linux, macOS e WSL2" ;; esac
command -v curl >/dev/null || die "curl não está instalado"
command -v git >/dev/null || die "git não está instalado"

if ! command -v hermes >/dev/null; then
  say "Hermes não encontrado; instalando pelo instalador oficial"
  tmp="$(mktemp)"
  trap 'rm -f "$tmp"' EXIT
  curl -fsSL https://hermes-agent.nousresearch.com/install.sh -o "$tmp"
  bash "$tmp"
  export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"
fi
command -v hermes >/dev/null || die "Hermes foi instalado, mas não está no PATH; reabra o terminal e rode novamente"

if ! command -v gh >/dev/null; then
  die "GitHub CLI (gh) é necessário para acessar o kit privado. Instale em https://cli.github.com e rode novamente"
fi
if ! gh auth status >/dev/null 2>&1; then
  say "Autorize sua conta GitHub para acessar o kit privado"
  gh auth login
fi
gh repo view "$REPO" >/dev/null 2>&1 || die "a conta autenticada não tem acesso ao repositório privado $REPO"
gh auth setup-git >/dev/null

if ! hermes profile show "$PROFILE" >/dev/null 2>&1; then
  say "Criando o perfil Hermes $PROFILE"
  hermes profile create "$PROFILE" --clone --description "Instalador guiado de agentes de atendimento em VPS"
fi

if [[ -d "$KIT_DIR/.git" ]]; then
  say "Atualizando o kit em $KIT_DIR"
  git -C "$KIT_DIR" fetch --tags origin
else
  say "Baixando o kit privado em $KIT_DIR"
  mkdir -p "$(dirname "$KIT_DIR")"
  gh repo clone "$REPO" "$KIT_DIR"
fi

git -C "$KIT_DIR" checkout --detach "$VERSION"
"$KIT_DIR/scripts/install-hermes-onboarding.sh" "$PROFILE"

say "Validando o kit sem fazer deploy"
make -C "$KIT_DIR" test

printf '\nInstalação concluída. No Hermes, diga: quero instalar um novo cliente\n'
cd "$KIT_DIR"
profile_alias="$(command -v "$PROFILE" 2>/dev/null || true)"
if [[ -n "$profile_alias" ]]; then
  exec "$profile_alias" --skills customer-agent-onboarding --in "$KIT_DIR" --tui
fi
die "o alias do perfil $PROFILE não foi encontrado; execute: hermes profile use $PROFILE"