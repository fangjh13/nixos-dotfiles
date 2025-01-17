#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Info:
#   author:    Fython
#   file:      web-open.sh
#   created:   2024-03-21
#   version:   1.0
# -----------------------------------------------------------------------------
# Requirements:
#   rofi
# Description:
#   Use rofi to search the web.
# Usage:
#   rofi -show 'wo' -modi wo:./web-open.sh
# -----------------------------------------------------------------------------
# Script:

declare -A URLS

URLS=(
  ["g"]="https://www.google.com/search?q="
  ["dt"]="http://dict.cn/"
)

# List for rofi
gen_list() {
  str=""
  for i in "${!URLS[@]}"; do
    if [ "$str" != "" ]; then
      str="$str | <b>${i}</b>"
    else
      str="<b>${i}</b>"
    fi
  done
  echo "( ${str} )"
}

if [ "$@" ]; then
  platform=$(echo "$@" | awk -F ' ' '{print $1}')
  query=$(echo "$@" | awk -F ' ' '{print $2}')
  if
    [ -n "${URLS[$platform]}" ] &
    [ -n "${query}" ]
  then
    xdg-open "${URLS[$platform]}$query"
    exit 0
  fi
else
  echo -en "\0prompt\x1f󰜏\n"
  echo -en "\0message\x1fSyntax [command] [keywords]\t\tSupport Command: $(gen_list)\n"
fi
