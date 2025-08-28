{pkgs, ...}:
pkgs.writeShellScriptBin "image-processor" ''
  #!/usr/bin/env bash

  # Usage: ./image-processor [quality] [resolution] [webp-method] [files ...]
  # example:
  #   image-processor "" "" "" ./file1.jpg ./file2.jpg
  #   image-processor 90 1920x1080 "" file1.jpg

  prompt_if_empty() {
    local var_name="$1"
    local prompt_text="$2"
    local default_value="$3"

    if [[ -z "''${!var_name}" ]]; then
      echo -n "$prompt_text ($default_value): "
      read input
      printf -v "$var_name" "%s" "''${input:-$default_value}"
    fi
  }

  QUALITY="$1"
  RESOLUTION="$2"
  METHOD="$3"

  prompt_if_empty QUALITY "Enter quality" "80"
  prompt_if_empty RESOLUTION "Enter resolution" "4096x4096>"
  prompt_if_empty METHOD "Enter WebP method" "6"

  shift 3

  TOTAL_FILES=$#
  CURRENT_FILE=0
  shopt -s nocasematch

  for file in "$@"; do
    ((CURRENT_FILE++))
    ext="''${file##*.}"
    base="''${file%.*}"

    if [[ "$ext" =~ ^(jpg|jpeg|png)$ ]]; then
      echo -ne "[''${CURRENT_FILE}/''${TOTAL_FILES}] Processing: $file\r"
      ${pkgs.imagemagick}/bin/magick "$file" -resize "$RESOLUTION" -define webp:method="$METHOD" -quality "$QUALITY" "$base.webp"
      echo -ne "\e[2K\r[''${CURRENT_FILE}/''${TOTAL_FILES}] ✅ Done: $base.webp\n"
    else
      echo "[''${CURRENT_FILE}/''${TOTAL_FILES}] ❌ Skipping unsupported file: $file"
    fi

  done
  shopt -u nocasematch
  echo "Processing complete! Converted $CURRENT_FILE/$TOTAL_FILES files."
''
