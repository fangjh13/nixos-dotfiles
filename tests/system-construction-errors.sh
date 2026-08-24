#!/usr/bin/env bash

set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
evaluation_file="$project_root/tests/system-construction-error-eval.nix"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_failure_contains() {
  local case_name=$1
  shift
  local output status expected

  set +e
  output=$(
    SYSTEM_CONSTRUCTION_ERROR_CASE="$case_name" \
      nix eval --impure --show-trace --file "$evaluation_file" 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "$case_name unexpectedly succeeded"
  for expected in "$@"; do
    grep -Fq -- "$expected" <<<"$output" ||
      fail "$case_name diagnostic does not contain: $expected"
  done
}

assert_failure_contains \
  declaration-not-attributes \
  'Host `broken-host`' \
  'Host declaration'
assert_failure_contains \
  declaration-unknown-field \
  'Host `broken-host`' \
  'Host declaration fields' \
  '`system`' \
  '`username`'
assert_failure_contains \
  missing-declaration \
  'Host `broken-host`' \
  'Host declaration'
assert_failure_contains \
  platform-mismatch \
  'Host `linux-host`' \
  'declared system' \
  'evaluated host platform'

printf 'system construction error diagnostics passed\n'
