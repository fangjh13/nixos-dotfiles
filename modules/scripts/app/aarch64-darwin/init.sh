#!/usr/bin/env bash

# ==========================================
# Strict Mode (Error Exit Mechanism)
# ==========================================
set -e
set -u
set -o pipefail

# ==========================================
# Define colors and styles
# ==========================================
# Standard colors for echo/printf (C_ prefix for 'Console')
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_CYAN='\033[0;36m'
C_BOLD='\033[1m'
C_NC='\033[0m'

# Readline-safe colors for 'read -p' prompts (P_ prefix for 'Prompt')
P_RED=$'\001\033[0;31m\002'
P_YELLOW=$'\001\033[1;33m\002'
P_BOLD=$'\001\033[1m\002'
P_NC=$'\001\033[0m\002'

# ==========================================
# Custom functions
# ==========================================
_print() {
  printf "%b\n" "$1"
}

_prompt() {
  local message="$1"
  local variable="$2"
  local default_val="${3:-}"

  if help read 2>/dev/null | grep -q -- ' -i '; then
    read -r -e -p "$message" -i "$default_val" "$variable"
    return
  fi

  local input=""
  read -r -p "$message" input
  if [[ -z "$input" ]]; then
    input="$default_val"
  fi
  printf -v "$variable" '%s' "$input"
}

_escape_sed_replacement() {
  LC_ALL=C LANG=C printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'
}

detect_timezone() {
  local timezone=""

  if command -v systemsetup >/dev/null 2>&1; then
    timezone=$(sudo systemsetup -gettimezone 2>/dev/null || true)
    timezone=${timezone#Time Zone: }
  fi

  if [[ -z "$timezone" && -L /etc/localtime ]]; then
    local timezone_link
    timezone_link=$(readlink /etc/localtime 2>/dev/null || true)
    case "$timezone_link" in
    *zoneinfo/*)
      timezone=${timezone_link##*zoneinfo/}
      ;;
    esac
  fi

  if [[ -z "$timezone" ]]; then
    timezone="Asia/Shanghai"
  fi

  printf "%s" "$timezone"
}

# ==========================================
# Pre-flight checks
# ==========================================
if [[ ! -f ./flake.nix || ! -d ./hosts/example-darwin ]]; then
  _print "${C_RED}❌ Please run this script from the repository root.${C_NC}"
  exit 1
fi

RAW_OS=$(uname -s 2>/dev/null || echo "")
RAW_ARCH=$(uname -m 2>/dev/null || echo "")

if [[ "$RAW_OS" != "Darwin" ]]; then
  _print "${C_RED}❌ This script only supports macOS.${C_NC}"
  exit 1
fi

if [[ "$RAW_ARCH" != "arm64" && "$RAW_ARCH" != "aarch64" ]]; then
  _print "${C_RED}❌ This script only supports Apple Silicon Macs.${C_NC}"
  _print "${C_YELLOW}Detected architecture: ${RAW_ARCH:-unknown}${C_NC}"
  exit 1
fi

# ==========================================
# Automatically get default system variables
# ==========================================
SYS_USER=$(id -un 2>/dev/null || echo "${USER:-unknown}")
SYS_HOST=""

if command -v scutil >/dev/null 2>&1; then
  SYS_HOST=$(scutil --get LocalHostName 2>/dev/null || true)
  if [[ -z "$SYS_HOST" ]]; then
    SYS_HOST=$(scutil --get HostName 2>/dev/null || true)
  fi
fi

if [[ -z "$SYS_HOST" ]]; then
  SYS_HOST=$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "${HOSTNAME:-unknown}")
fi

if command -v git >/dev/null 2>&1; then
  SYS_GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)
  SYS_GIT_NAME=$(git config --global user.name 2>/dev/null || true)
else
  SYS_GIT_EMAIL=""
  SYS_GIT_NAME=""
fi

SYS_TIMEZONE=$(detect_timezone)
NIX_SYSTEM="aarch64-darwin"

# ==========================================
# Interactive input (with defaults)
# ==========================================
clear
echo -e "${C_CYAN}${C_BOLD}======================================"
echo -e "       macOS Setup Wizard             "
echo -e "======================================${C_NC}\n"

_print "${C_YELLOW}Tip: Press Enter to keep the default value, or edit it directly.${C_NC}\n"

_prompt "👤 ${P_BOLD}Username${P_NC} (Desired)  : " USERNAME "$SYS_USER"
_prompt "🖥️ ${P_BOLD}Hostname${P_NC} (System)   : " HOST_NAME "$SYS_HOST"
_prompt "🌍 ${P_BOLD}Timezone${P_NC}            : " TIMEZONE "$SYS_TIMEZONE"
_prompt "📧 ${P_BOLD}Git Email${P_NC}           : " GIT_EMAIL "$SYS_GIT_EMAIL"
_prompt "📝 ${P_BOLD}Git Name${P_NC}            : " GIT_NAME "$SYS_GIT_NAME"

# ==========================================
# Confirmation step
# ==========================================
confirm_details() {
  echo ""
  _print "${C_CYAN}${C_BOLD}=== Please confirm your details ===${C_NC}"

  printf "  ⚙️ %-11s: ${C_GREEN}%s${C_NC}\n" "Nix System" "$NIX_SYSTEM"
  printf "  👤 %-11s: ${C_GREEN}%s${C_NC}\n" "Username" "$USERNAME"
  printf "  🖥️ %-11s: ${C_GREEN}%s${C_NC}\n" "Hostname" "$HOST_NAME"
  printf "  🌍 %-11s: ${C_GREEN}%s${C_NC}\n" "Timezone" "$TIMEZONE"
  printf "  📧 %-11s: ${C_GREEN}%s${C_NC}\n" "Git Email" "$GIT_EMAIL"
  printf "  📝 %-11s: ${C_GREEN}%s${C_NC}\n" "Git Name" "$GIT_NAME"
  echo ""

  _prompt "❓ ${P_YELLOW}Is the above information correct? [Y/n]: ${P_NC}" choice

  case "$choice" in
  [Yy]* | "")
    _print "\n${C_GREEN}✅ Continuing...${C_NC}"
    ;;
  [Nn]*)
    _print "\n${C_RED}❌ User aborted. Exiting script.${C_NC}"
    exit 1
    ;;
  *)
    _print "\n${C_RED}⚠️ Invalid option. Exiting script.${C_NC}"
    exit 1
    ;;
  esac
}

confirm_details

# ==========================================
# Copy template files and replace variables
# ==========================================
TARGET_HOST_DIR="./hosts/$HOST_NAME"

if [[ -e "$TARGET_HOST_DIR" ]]; then
  _print "${C_RED}❌ Target host directory already exists: $TARGET_HOST_DIR${C_NC}"
  exit 1
fi

cp -r ./hosts/example-darwin "$TARGET_HOST_DIR"

replace_variable() {
  local file="$1"
  local escaped_username escaped_host_name escaped_git_name escaped_git_email escaped_timezone

  escaped_username=$(_escape_sed_replacement "$USERNAME")
  escaped_host_name=$(_escape_sed_replacement "$HOST_NAME")
  escaped_git_name=$(_escape_sed_replacement "$GIT_NAME")
  escaped_git_email=$(_escape_sed_replacement "$GIT_EMAIL")
  escaped_timezone=$(_escape_sed_replacement "$TIMEZONE")

  LC_ALL=C LANG=C sed -i '' -e "s|%%USERNAME%%|$escaped_username|g" "$file"
  LC_ALL=C LANG=C sed -i '' -e "s|%%HOSTNAME%%|$escaped_host_name|g" "$file"
  LC_ALL=C LANG=C sed -i '' -e "s|%%GITNAME%%|$escaped_git_name|g" "$file"
  LC_ALL=C LANG=C sed -i '' -e "s|%%GITEMAIL%%|$escaped_git_email|g" "$file"
  LC_ALL=C LANG=C sed -i '' -e "s|%%TIMEZONE%%|$escaped_timezone|g" "$file"
}
export -f _escape_sed_replacement
export -f replace_variable
export USERNAME HOST_NAME GIT_NAME GIT_EMAIL TIMEZONE
find "$TARGET_HOST_DIR" -type f -exec bash -c 'replace_variable "$1"' _ {} \;
_print "${C_CYAN}🔧 Darwin template copied and variables generated.${C_NC}"

# Update flake.nix with the new host information
_print "${C_CYAN}🔧 Updating flake.nix file.${C_NC}"
ESCAPED_NIX_SYSTEM=$(_escape_sed_replacement "$NIX_SYSTEM")
ESCAPED_HOST_NAME=$(_escape_sed_replacement "$HOST_NAME")
ESCAPED_USERNAME=$(_escape_sed_replacement "$USERNAME")
LC_ALL=C LANG=C sed -E \
  -e "s|^( *system *)= *\"[^\"]*\"|\\1= \"$ESCAPED_NIX_SYSTEM\"|" \
  -e "s|^( *host *)= *\"[^\"]*\"|\\1= \"$ESCAPED_HOST_NAME\"|" \
  -e "s|^( *username *)= *\"[^\"]*\"|\\1= \"$ESCAPED_USERNAME\"|" \
  ./flake.nix >./flake.nix.tmp && mv ./flake.nix.tmp ./flake.nix

echo
_print "${C_GREEN}🎉 The configuration generation is complete and located in the hosts/$HOST_NAME folder.${C_NC}"
_print "${C_GREEN}🧩 You can now build the nix-darwin system for this host.${C_NC}"
