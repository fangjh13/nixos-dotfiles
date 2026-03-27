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
# Wrapping ANSI codes in \001 and \002 tells Readline they have 0 physical width.
# This strictly fixes cursor jumping issues and prevents Backspace from erasing prompts.
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
  # Use ${3:-} to prevent 'set -u' from crashing if default_val is not passed
  local default_val="${3:-}"

  # Using '-p "$message"' tells Readline exactly where the prompt ends.
  # This creates a hard boundary so backspace CANNOT erase the prompt.
  read -r -e -p "$message" -i "$default_val" "$variable"
}

# ==========================================
# Automatically get default system variables
# ==========================================
SYS_USER=$(id -un 2>/dev/null || echo "${USER:-unknown}")
SYS_HOST=$(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || echo "${HOSTNAME:-unknown}")

if command -v git >/dev/null 2>&1; then
  SYS_GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)
  SYS_GIT_NAME=$(git config --global user.name 2>/dev/null || true)
else
  SYS_GIT_EMAIL=""
  SYS_GIT_NAME=""
fi

# Detect system architecture and OS for Nix
RAW_OS=$(uname -s | tr '[:upper:]' '[:lower:]')
RAW_ARCH=$(uname -m)
case "$RAW_ARCH" in
x86_64) NIX_ARCH="x86_64" ;;
aarch64 | arm64) NIX_ARCH="aarch64" ;; # macOS M series chips often return arm64, but in Nix it's aarch64
*) NIX_ARCH="$RAW_ARCH" ;;
esac
SYS_NIX_SYSTEM="${NIX_ARCH}-${RAW_OS}"

# ==========================================
# Interactive input (with defaults)
# ==========================================
clear
echo -e "${C_CYAN}${C_BOLD}======================================"
echo -e "         System Setup Wizard          "
echo -e "======================================${C_NC}\n"

_print "${C_YELLOW}Tip: Press Enter to keep the default value, or edit it directly.${C_NC}\n"

# Use P_ (Prompt) colors here because this text is fed into 'read -p'
_prompt "⚙️ ${P_BOLD}Nix System${P_NC} (Target) : " NIX_SYSTEM "$SYS_NIX_SYSTEM"
_prompt "👤 ${P_BOLD}Username${P_NC} (Desired)  : " USERNAME "$SYS_USER"
_prompt "🖥️ ${P_BOLD}Hostname${P_NC} (System)   : " HOST_NAME "$SYS_HOST"
_prompt "📧 ${P_BOLD}Git Email${P_NC}           : " GIT_EMAIL "$SYS_GIT_EMAIL"
_prompt "📝 ${P_BOLD}Git Name${P_NC}            : " GIT_NAME "$SYS_GIT_NAME"

# ==========================================
# Confirmation step
# ==========================================
confirm_details() {
  echo ""
  _print "${C_CYAN}${C_BOLD}=== Please confirm your details ===${C_NC}"
  # Use C_ (Console) colors because this is a standard printf output

  printf "  ⚙️ %-11s: ${C_GREEN}%s${C_NC}\n" "Nix System" "$NIX_SYSTEM"
  printf "  👤 %-11s: ${C_GREEN}%s${C_NC}\n" "Username" "$USERNAME"
  printf "  🖥️ %-11s: ${C_GREEN}%s${C_NC}\n" "Hostname" "$HOST_NAME"
  printf "  📧 %-11s: ${C_GREEN}%s${C_NC}\n" "Git Email" "$GIT_EMAIL"
  printf "  📝 %-11s: ${C_GREEN}%s${C_NC}\n" "Git Name" "$GIT_NAME"
  echo ""

  # Use P_ colors for read -p
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
cp -r ./hosts/example-linux ./hosts/"$HOST_NAME"

replace_variable() {
  local file="$1"
  sed -i -e "s/%%USERNAME%%/$USERNAME/g" "$file"
  sed -i -e "s/%%HOSTNAME%%/$HOST_NAME/g" "$file"
  sed -i -e "s/%%GITNAME%%/$GIT_NAME/g" "$file"
  sed -i -e "s/%%GITEMAIL%%/$GIT_EMAIL/g" "$file"
}

export -f replace_variable
export USERNAME HOST_NAME GIT_NAME GIT_EMAIL
find ./hosts/"$HOST_NAME" -type f -exec bash -c 'replace_variable "$0"' {} \;
_print "${C_CYAN}🔧 Template files copied and variables replaced.${C_NC}"

_print "${C_CYAN}🔧 Generating hardware configuration. ${C_NC}"
sudo nixos-generate-config --show-hardware-config >./hosts/"$HOST_NAME"/hardware-configuration.nix

_print "${C_CYAN}🔧 Updating flake.nix file.${C_NC}"
sed -E \
  -e "s/^( *system *)= *\"[^\"]*\"/\1= \"$NIX_SYSTEM\"/" \
  -e "s/^( *host *)= *\"[^\"]*\"/\1= \"$HOST_NAME\"/" \
  -e "s/^( *username *)= *\"[^\"]*\"/\1= \"$USERNAME\"/" \
  ./flake.nix >./flake.nix.tmp && mv ./flake.nix.tmp ./flake.nix

echo
_print "${C_GREEN}🎉 The configuration generation is complete and located in the hosts/$HOST_NAME folder. You can now build the NixOS system"
_print "🧩 You may also customize the values within the variables.nix file. ${C_NC}"
