#!/usr/bin/env bash

# Exit immediately when a command fails, a variable is unset, or a pipeline fails.
set -euo pipefail

# ==============================================================================
# Terminal presentation
# ==============================================================================
# Keep redirected output clean while preserving the colorful interactive wizard.
C_RED=""
C_GREEN=""
C_YELLOW=""
C_CYAN=""
C_BOLD=""
C_RESET=""
if [[ -t 2 && -z "${NO_COLOR:-}" && "${TERM:-}" != "dumb" ]]; then
  C_RED=$'\033[0;31m'
  C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[1;33m'
  C_CYAN=$'\033[0;36m'
  C_BOLD=$'\033[1m'
  C_RESET=$'\033[0m'
fi

print_line() {
  printf '%b\n' "$1" >&2
}

print_banner() {
  print_line ""
  print_line "${C_CYAN}${C_BOLD}╭────────────────────────────────────────╮"
  print_line "│     ✨ Host Inventory Setup Wizard     │"
  print_line "╰────────────────────────────────────────╯${C_RESET}"
  print_line "${C_YELLOW}💡 Tip: Press Enter to keep the default value.${C_RESET}"
  print_line ""
}

step() {
  print_line "${C_CYAN}$1${C_RESET}"
}

success() {
  print_line "${C_GREEN}$1${C_RESET}"
}

# ==============================================================================
# CLI and input helpers
# ==============================================================================
usage() {
  cat <<'EOF'
Usage: nix run .#init [--help]

Interactively register the current machine in the Host inventory. The command
detects the local Nix system, builds and validates a candidate in OS temporary
storage, atomically installs it under hosts/, and stages only the new Host.
It never commits changes and cannot target a remote machine or another platform.
EOF
}

die() {
  print_line "${C_RED}❌ Error: $1${C_RESET}"
  exit 1
}

prompt() {
  local label=$1
  local default_value=$2
  local result_name=$3
  local answer

  printf '%b' "${C_BOLD}${label}${C_RESET} [${C_GREEN}${default_value}${C_RESET}]: " >&2
  if [[ -t 0 ]] && help read 2>/dev/null | grep -q -- ' -i '; then
    if ! IFS= read -r -e -i "$default_value" answer; then
      answer=""
    fi
  elif ! IFS= read -r answer; then
    answer=""
  fi
  if [[ -z "$answer" ]]; then
    answer=$default_value
  fi
  printf -v "$result_name" '%s' "$answer"
}

# Validate fields before interpolating them into Nix source files or paths.
require_clean() {
  local label=$1
  local value=$2
  local trimmed

  trimmed=$(printf '%s' "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  [[ -n "$value" ]] || die "$label must not be empty"
  [[ "$trimmed" == "$value" ]] || die "$label must not contain leading or trailing whitespace"
}

require_nix_string_literal_text() {
  local label=$1
  local value=$2

  if printf '%s' "$value" | grep -q '["\\$]'; then
    die "$label must not contain double quotes, backslashes, or dollar signs"
  fi
}

# Replace one template token at a time through a temporary file.
replace_placeholder() {
  local file=$1
  local placeholder=$2
  local value=$3
  local escaped_value temporary_file

  escaped_value=$(printf '%s' "$value" | sed -e 's/[&|\\]/\\&/g')
  temporary_file="${file}.inventory-onboarding"
  sed "s|${placeholder}|${escaped_value}|g" "$file" >"$temporary_file"
  mv "$temporary_file" "$file"
}

# Prefer the platform service and fall back to the /etc/localtime symlink.
detect_timezone() {
  local timezone=""

  if command -v timedatectl >/dev/null 2>&1; then
    timezone=$(timedatectl show -p Timezone --value 2>/dev/null || true)
  fi
  if [[ -z "$timezone" && -L /etc/localtime ]]; then
    timezone=$(readlink /etc/localtime 2>/dev/null || true)
    timezone=${timezone##*zoneinfo/}
  fi
  printf '%s' "${timezone:-UTC}"
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi
[[ $# -eq 0 ]] || die "unknown argument: $1"

# ==============================================================================
# Repository and transaction setup
# ==============================================================================
repository=$(git rev-parse --show-toplevel 2>/dev/null) || die "run this command from the inventory repository"
[[ -f "$repository/flake.nix" ]] || die "repository does not contain flake.nix"
[[ -f "$repository/lib/system-construction.nix" ]] || die "repository does not contain the system-construction module"

stage_parent=$(mktemp -d "${TMPDIR:-/tmp}/inventory-onboarding.XXXXXX")
staging_path="$stage_parent/candidate"
mkdir -p "$staging_path"
repository_temp=""
registered_path=""
completed=0

cleanup() {
  local status=$?
  if [[ -n "$repository_temp" && -d "$repository_temp" ]]; then
    rm -rf -- "$repository_temp"
  fi
  if [[ $status -ne 0 && -n "$registered_path" && -d "$registered_path" ]]; then
    git -C "$repository" reset -q -- "hosts/$host_name" >/dev/null 2>&1 || true
    rm -rf -- "$registered_path"
  fi
  if [[ $completed -eq 1 ]]; then
    rm -rf -- "$stage_parent"
  elif [[ -d "$staging_path" ]]; then
    printf 'Candidate staging preserved at: %s\n' "$staging_path" >&2
  fi
  exit "$status"
}
trap cleanup EXIT

# ==============================================================================
# Current-machine detection
# ==============================================================================
raw_os=$(uname -s)
raw_arch=$(uname -m)
case "${raw_os}:${raw_arch}" in
Linux:x86_64)
  nix_system=x86_64-linux
  platform=linux
  ;;
Linux:aarch64 | Linux:arm64)
  nix_system=aarch64-linux
  platform=linux
  ;;
Darwin:aarch64 | Darwin:arm64)
  nix_system=aarch64-darwin
  platform=darwin
  ;;
*)
  die "unsupported current machine: ${raw_os} ${raw_arch}"
  ;;
esac

template="$repository/hosts/templates/$platform"
[[ -d "$template" ]] || die "missing $platform Host template: $template"

# ==============================================================================
# Interactive configuration
# ==============================================================================
default_username=$(id -un 2>/dev/null || printf '%s' "${USER:-}")
default_hostname=$(hostname -s 2>/dev/null || hostname 2>/dev/null || true)
default_timezone=$(detect_timezone)
default_git_email=$(git config --global user.email 2>/dev/null || true)
default_git_name=$(git config --global user.name 2>/dev/null || true)
host_name=""
username=""
timezone=""
git_email=""
git_name=""
confirmation=""

print_banner
step "⚙️  Detected current Nix system: ${C_BOLD}$nix_system${C_RESET}"
prompt "🖥️  Hostname" "$default_hostname" host_name
prompt "👤  Username" "$default_username" username
prompt "🌍  Timezone" "$default_timezone" timezone
prompt "📧  Git email" "$default_git_email" git_email
prompt "📝  Git name" "$default_git_name" git_name

[[ "$host_name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || die "Host name contains unsupported characters"
[[ "$username" =~ ^[A-Za-z_][A-Za-z0-9_-]*$ ]] || die "username contains unsupported characters"
[[ "$timezone" =~ ^[A-Za-z0-9._+-]+(/[A-Za-z0-9._+-]+)*$ ]] || die "timezone is not a safe timezone identifier"
[[ "$git_email" =~ ^[^[:space:]@]+@[^[:space:]@]+$ ]] || die "Git email is not valid"
require_clean "Host name" "$host_name"
require_clean "username" "$username"
require_clean "timezone" "$timezone"
require_clean "Git email" "$git_email"
require_clean "Git name" "$git_name"
require_nix_string_literal_text "Git email" "$git_email"
require_nix_string_literal_text "Git name" "$git_name"
[[ ! -e "$repository/hosts/$host_name" ]] || die "Host already exists: $host_name"

print_line ""
print_line "${C_CYAN}${C_BOLD}🔎 Please confirm your details${C_RESET}"
printf '  ⚙️  %-10s: %b%s%b\n' "Nix system" "$C_GREEN" "$nix_system" "$C_RESET" >&2
printf '  🖥️  %-10s: %b%s%b\n' "Hostname" "$C_GREEN" "$host_name" "$C_RESET" >&2
printf '  👤  %-10s: %b%s%b\n' "Username" "$C_GREEN" "$username" "$C_RESET" >&2
printf '  🌍  %-10s: %b%s%b\n' "Timezone" "$C_GREEN" "$timezone" "$C_RESET" >&2
printf '  📧  %-10s: %b%s <%s>%b\n' "Git" "$C_GREEN" "$git_name" "$git_email" "$C_RESET" >&2
print_line ""
prompt "❓ Register this current machine? (yes/no)" "yes" confirmation
case "$confirmation" in
yes | y | Y | YES) success "✅ Continuing..." ;;
*) die "onboarding cancelled" ;;
esac

# ==============================================================================
# Candidate generation
# ==============================================================================
step "📋 Copying the ${platform} Host template..."
rm -rf -- "$staging_path"
cp -R "$template" "$staging_path"
replace_placeholder "$staging_path/variables.nix" '%%GITNAME%%' "$git_name"
replace_placeholder "$staging_path/variables.nix" '%%GITEMAIL%%' "$git_email"
replace_placeholder "$staging_path/variables.nix" '%%TIMEZONE%%' "$timezone"

printf '{\n  system = "%s";\n  username = "%s";\n}\n' "$nix_system" "$username" >"$staging_path/host.nix"

if [[ "$platform" == linux ]]; then
  step "🔧 Generating the NixOS hardware configuration..."
  if [[ ${INVENTORY_ONBOARDING_TEST_ROOT:-0} == 1 || $EUID -eq 0 ]]; then
    nixos-generate-config --show-hardware-config >"$staging_path/hardware-configuration.nix"
  elif [[ -x /run/wrappers/bin/sudo ]]; then
    # The user-owned staging file must not be created as root.
    # shellcheck disable=SC2024
    /run/wrappers/bin/sudo nixos-generate-config --show-hardware-config >"$staging_path/hardware-configuration.nix"
  else
    die "Linux hardware generation requires root or /run/wrappers/bin/sudo"
  fi
fi

# Reject incomplete templates before the more expensive Nix evaluation.
if grep -R -n '%%[A-Z][A-Z]*%%' "$staging_path" >&2; then
  die "candidate contains unresolved template placeholders"
fi

candidate_hosts="$stage_parent/hosts"
mkdir -p "$candidate_hosts"
cp -R "$repository/hosts/." "$candidate_hosts/"
cp -R "$staging_path" "$candidate_hosts/$host_name"

step "🔍 Validating the candidate configuration..."
# The single-quoted Nix expression must be passed literally.
# shellcheck disable=SC2016
INVENTORY_ONBOARDING_REPOSITORY="$repository" \
  INVENTORY_ONBOARDING_HOSTS="$candidate_hosts" \
  INVENTORY_ONBOARDING_HOST="$host_name" \
  nix eval --impure --expr '
  let
    repository = builtins.getEnv "INVENTORY_ONBOARDING_REPOSITORY";
    hostName = builtins.getEnv "INVENTORY_ONBOARDING_HOST";
    flake = builtins.getFlake ("path:" + repository);
    validateCandidate = import (builtins.toPath (repository + "/lib/inventory-onboarding-candidate.nix")) {
      inputs = flake.inputs;
    };
  in
    validateCandidate {
      hostsPath = builtins.toPath (builtins.getEnv "INVENTORY_ONBOARDING_HOSTS");
      inherit hostName;
    }
' >/dev/null

# ==============================================================================
# Atomic registration and precise Git staging
# ==============================================================================
step "📦 Registering the validated Host..."
repository_temp=$(mktemp -d "$repository/.inventory-onboarding.XXXXXX")
cp -R "$staging_path" "$repository_temp/$host_name"
registered_path="$repository/hosts/$host_name"
mv "$repository_temp/$host_name" "$registered_path"
rmdir "$repository_temp"
repository_temp=""

git -C "$repository" add -- "hosts/$host_name"
completed=1
success "🎉 Registered Host $host_name and staged only hosts/$host_name."
print_line "${C_GREEN}🧩 Review the staged Host files before committing. No commit was created.${C_RESET}"
