#!/usr/bin/env bash

set -euo pipefail
export INVENTORY_ONBOARDING_TEST_ROOT=1

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
onboarding_script="$project_root/modules/scripts/inventory-onboarding.sh"
test_root=$(mktemp -d "${TMPDIR:-/tmp}/inventory-onboarding-test.XXXXXX")
trap 'rm -rf "$test_root"' EXIT

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_file_contains() {
  local file=$1
  local expected=$2
  grep -Fq -- "$expected" "$file" || fail "$file does not contain: $expected"
}

assert_text_contains() {
  local text=$1
  local expected=$2
  grep -Fq -- "$expected" <<<"$text" || fail "output does not contain: $expected"
}

repository_snapshot() {
  local repository=$1

  (
    cd "$repository"
    sha256sum flake.nix
    find hosts -mindepth 1 -printf '%y %P\n' | LC_ALL=C sort
    while IFS= read -r -d '' file; do
      sha256sum "$file"
    done < <(find hosts -type f -print0 | LC_ALL=C sort -z)
    git status --porcelain=v1 --untracked-files=all
    git diff --cached --binary
  ) | sha256sum | cut -d ' ' -f 1
}

assert_repository_unchanged() {
  local repository=$1
  local expected_snapshot=$2
  local failure_name=$3
  local actual_snapshot

  actual_snapshot=$(repository_snapshot "$repository")
  [[ "$actual_snapshot" == "$expected_snapshot" ]] ||
    fail "$failure_name changed flake.nix, the Host inventory, or the Git index"
}

create_repository() {
  local repository=$1
  mkdir -p "$repository/hosts/templates"
  cp -R "$project_root/hosts/templates/linux" "$repository/hosts/templates/linux"
  cp -R "$project_root/hosts/templates/darwin" "$repository/hosts/templates/darwin"
  cp "$project_root/flake.nix" "$repository/flake.nix"
  mkdir -p "$repository/lib"
  cp "$project_root/lib/system-construction.nix" "$repository/lib/system-construction.nix"
  cp "$project_root/lib/inventory-onboarding-candidate.nix" "$repository/lib/inventory-onboarding-candidate.nix"
  cp "$project_root/lib/supported-systems.nix" "$repository/lib/supported-systems.nix"
  chmod -R u+w "$repository"
  git -C "$repository" init -q
  git -C "$repository" config user.name Test
  git -C "$repository" config user.email test@example.com
  git -C "$repository" add .
  git -C "$repository" commit -qm fixture
  printf 'leave me untracked\n' >"$repository/unrelated.txt"
}

create_linux_commands() {
  local bin_dir=$1
  mkdir -p "$bin_dir"

  printf '#!%s\n' "$BASH" >"$bin_dir/uname"
  cat >>"$bin_dir/uname" <<'EOF'
case "${1:-}" in
  -s) printf '%s\n' "${TEST_UNAME_S:-Linux}" ;;
  -m) printf '%s\n' "${TEST_UNAME_M:-x86_64}" ;;
  *) printf '%s\n' "${TEST_UNAME_S:-Linux}" ;;
esac
EOF

  printf '#!%s\n' "$BASH" >"$bin_dir/hostname"
  cat >>"$bin_dir/hostname" <<'EOF'
printf '%s\n' test-machine
EOF

  printf '#!%s\n' "$BASH" >"$bin_dir/timedatectl"
  cat >>"$bin_dir/timedatectl" <<'EOF'
printf '%s\n' UTC
EOF

  printf '#!%s\n' "$BASH" >"$bin_dir/nixos-generate-config"
  cat >>"$bin_dir/nixos-generate-config" <<'EOF'
printf '%s\n' '{ modulesPath, ... }: { imports = [ (modulesPath + "/profiles/qemu-guest.nix") ]; }'
EOF

  printf '#!%s\n' "$BASH" >"$bin_dir/nix"
  cat >>"$bin_dir/nix" <<'EOF'
if [[ "${TEST_NIX_FAIL:-0}" == 1 ]]; then
  printf 'candidate evaluation failed\n' >&2
  exit 1
fi
printf 'true\n'
EOF

  chmod +x "$bin_dir"/*
}

enable_real_candidate_evaluation() {
  local repository=$1
  local bin_dir=$2

  rm "$bin_dir/nix"
  cp "$project_root/flake.lock" "$repository/flake.lock"
  ln -s "$project_root/modules" "$repository/modules"
  ln -s "$project_root/overlays" "$repository/overlays"
}

install_git_add_failure() {
  local bin_dir=$1
  local real_git
  real_git=$(command -v git)
  printf '#!%s\n' "$BASH" >"$bin_dir/git"
  cat >>"$bin_dir/git" <<EOF
if [[ "\${1:-}" == "-C" ]]; then
  repository=\$2
  shift 2
else
  repository=""
fi
if [[ "\${1:-}" == "add" ]]; then
  printf 'simulated git add failure\\n' >&2
  exit 1
fi
if [[ -n "\$repository" ]]; then
  exec "$real_git" -C "\$repository" "\$@"
else
  exec "$real_git" "\$@"
fi
EOF
  chmod +x "$bin_dir/git"
}

run_onboarding() {
  bash "$onboarding_script"
}

test_linux_success_registers_only_new_host() {
  local repository="$test_root/linux-success"
  local bin_dir="$test_root/linux-bin"
  create_repository "$repository"
  create_linux_commands "$bin_dir"

  (
    cd "$repository"
    printf 'new-linux\nalice\nEurope/London\nalice@example.com\nAlice Example\n\n' |
      PATH="$bin_dir:$PATH" TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 \
        run_onboarding >/dev/null
  )

  [[ -d "$repository/hosts/new-linux" ]] || fail "new Linux host was not registered"
  assert_file_contains "$repository/hosts/new-linux/host.nix" 'system = "x86_64-linux";'
  assert_file_contains "$repository/hosts/new-linux/host.nix" 'username = "alice";'
  assert_file_contains "$repository/hosts/new-linux/variables.nix" 'gitName = "Alice Example";'
  assert_file_contains "$repository/hosts/new-linux/hardware-configuration.nix" 'qemu-guest.nix'

  local staged
  staged=$(git -C "$repository" diff --cached --name-only)
  [[ -n "$staged" ]] || fail "new host was not staged"
  if grep -Fvx 'hosts/new-linux/default.nix' <<<"$staged" |
    grep -Fvx 'hosts/new-linux/hardware-configuration.nix' |
    grep -Fvx 'hosts/new-linux/host.nix' |
    grep -Fvx 'hosts/new-linux/secrets/default.nix' |
    grep -Fvx 'hosts/new-linux/variables.nix' |
    grep -q .; then
    fail "onboarding staged files outside the new host: $staged"
  fi
  ! grep -Fxq unrelated.txt <<<"$staged" || fail "unrelated file was staged"
}

test_aarch64_linux_uses_detected_system() {
  local repository="$test_root/aarch64-linux-success"
  local bin_dir="$test_root/aarch64-linux-bin"
  create_repository "$repository"
  create_linux_commands "$bin_dir"

  (
    cd "$repository"
    printf 'arm-linux\nalice\nUTC\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TEST_UNAME_S=Linux TEST_UNAME_M=aarch64 \
        run_onboarding >/dev/null
  )

  assert_file_contains "$repository/hosts/arm-linux/host.nix" 'system = "aarch64-linux";'
}

test_candidate_failure_preserves_staging_without_inventory_changes() {
  local repository="$test_root/evaluation-failure"
  local bin_dir="$test_root/evaluation-failure-bin"
  local temporary_dir="$test_root/evaluation-failure-tmp"
  local output status staging_path snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  mkdir -p "$temporary_dir"
  snapshot=$(repository_snapshot "$repository")

  set +e
  output=$(
    cd "$repository"
    printf 'broken-host\nalice\nUTC\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TMPDIR="$temporary_dir" TEST_NIX_FAIL=1 \
        TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 run_onboarding 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "candidate evaluation failure unexpectedly succeeded"
  [[ ! -e "$repository/hosts/broken-host" ]] || fail "failed candidate changed the Host inventory"
  [[ -z "$(git -C "$repository" diff --cached --name-only)" ]] || fail "failed candidate staged files"
  staging_path=$(sed -n 's/^Candidate staging preserved at: //p' <<<"$output")
  [[ -n "$staging_path" && -d "$staging_path" ]] || fail "failed candidate staging was not preserved"
  assert_file_contains "$staging_path/host.nix" 'system = "x86_64-linux";'
  assert_repository_unchanged "$repository" "$snapshot" "candidate evaluation failure"
}

test_existing_host_failure_preserves_staging_without_inventory_changes() {
  local repository="$test_root/existing-host"
  local bin_dir="$test_root/existing-host-bin"
  local temporary_dir="$test_root/existing-host-tmp"
  local output status staging_path snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  mkdir -p "$repository/hosts/existing" "$temporary_dir"
  snapshot=$(repository_snapshot "$repository")

  set +e
  output=$(
    cd "$repository"
    printf 'existing\nalice\nUTC\nalice@example.com\nAlice\n' |
      PATH="$bin_dir:$PATH" TMPDIR="$temporary_dir" \
        TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 run_onboarding 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "existing Host unexpectedly succeeded"
  staging_path=$(sed -n 's/^Candidate staging preserved at: //p' <<<"$output")
  [[ -n "$staging_path" && -d "$staging_path" ]] || fail "existing Host failure did not preserve staging"
  [[ -z "$(git -C "$repository" diff --cached --name-only)" ]] || fail "existing Host failure staged files"
  assert_repository_unchanged "$repository" "$snapshot" "existing Host failure"
}

test_hardware_generation_failure_preserves_candidate() {
  local repository="$test_root/hardware-failure"
  local bin_dir="$test_root/hardware-failure-bin"
  local temporary_dir="$test_root/hardware-failure-tmp"
  local output status staging_path snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  mkdir -p "$temporary_dir"
  printf '#!%s\n' "$BASH" >"$bin_dir/nixos-generate-config"
  cat >>"$bin_dir/nixos-generate-config" <<'EOF'
printf 'hardware scan failed\n' >&2
exit 1
EOF
  chmod +x "$bin_dir/nixos-generate-config"
  snapshot=$(repository_snapshot "$repository")

  set +e
  output=$(
    cd "$repository"
    printf 'hardware-fail\nalice\nUTC\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TMPDIR="$temporary_dir" \
        TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 run_onboarding 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "hardware generation failure unexpectedly succeeded"
  [[ ! -e "$repository/hosts/hardware-fail" ]] || fail "hardware failure changed the Host inventory"
  staging_path=$(sed -n 's/^Candidate staging preserved at: //p' <<<"$output")
  [[ -n "$staging_path" && -d "$staging_path" ]] || fail "hardware failure did not preserve staging"
  [[ -f "$staging_path/host.nix" ]] || fail "hardware failure staging omitted the Host declaration"
  assert_repository_unchanged "$repository" "$snapshot" "hardware generation failure"
}

test_git_add_failure_rolls_back_registration() {
  local repository="$test_root/git-add-failure"
  local bin_dir="$test_root/git-add-failure-bin"
  local temporary_dir="$test_root/git-add-failure-tmp"
  local output status staging_path snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  printf 'preserve this staged change\n' >"$repository/preexisting-staged.txt"
  git -C "$repository" add preexisting-staged.txt
  snapshot=$(repository_snapshot "$repository")
  install_git_add_failure "$bin_dir"
  mkdir -p "$temporary_dir"

  set +e
  output=$(
    cd "$repository"
    printf 'git-fail\nalice\nUTC\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TMPDIR="$temporary_dir" \
        TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 run_onboarding 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "git add failure unexpectedly succeeded"
  [[ ! -e "$repository/hosts/git-fail" ]] || fail "git add failure left a registered Host"
  staging_path=$(sed -n 's/^Candidate staging preserved at: //p' <<<"$output")
  [[ -n "$staging_path" && -d "$staging_path" ]] || fail "git add failure did not preserve staging"
  assert_file_contains "$staging_path/host.nix" 'system = "x86_64-linux";'
  assert_repository_unchanged "$repository" "$snapshot" "git add failure"
}

test_unresolved_placeholder_preserves_candidate() {
  local repository="$test_root/placeholder-failure"
  local bin_dir="$test_root/placeholder-failure-bin"
  local temporary_dir="$test_root/placeholder-failure-tmp"
  local output status staging_path snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  mkdir -p "$temporary_dir"
  printf '%s\n' '# %%UNRESOLVED%%' >>"$repository/hosts/templates/linux/variables.nix"
  snapshot=$(repository_snapshot "$repository")

  set +e
  output=$(
    cd "$repository"
    printf 'placeholder-fail\nalice\nUTC\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TMPDIR="$temporary_dir" \
        TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 run_onboarding 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "unresolved placeholder unexpectedly succeeded"
  [[ ! -e "$repository/hosts/placeholder-fail" ]] || fail "placeholder failure changed the Host inventory"
  staging_path=$(sed -n 's/^Candidate staging preserved at: //p' <<<"$output")
  [[ -n "$staging_path" && -d "$staging_path" ]] || fail "placeholder failure did not preserve staging"
  assert_file_contains "$staging_path/variables.nix" '%%UNRESOLVED%%'
  assert_repository_unchanged "$repository" "$snapshot" "placeholder validation failure"
}

test_invalid_metadata_preserves_staging_before_generation() {
  local repository="$test_root/metadata-failure"
  local bin_dir="$test_root/metadata-failure-bin"
  local temporary_dir="$test_root/metadata-failure-tmp"
  local output status staging_path snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  mkdir -p "$temporary_dir"
  snapshot=$(repository_snapshot "$repository")

  set +e
  output=$(
    cd "$repository"
    printf 'metadata-fail\nalice\nUTC\nnot-an-email\nAlice\n' |
      PATH="$bin_dir:$PATH" TMPDIR="$temporary_dir" \
        TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 run_onboarding 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "invalid metadata unexpectedly succeeded"
  [[ ! -e "$repository/hosts/metadata-fail" ]] || fail "metadata failure changed the Host inventory"
  staging_path=$(sed -n 's/^Candidate staging preserved at: //p' <<<"$output")
  [[ -n "$staging_path" && -d "$staging_path" ]] || fail "metadata failure did not preserve staging"
  [[ -z "$(git -C "$repository" diff --cached --name-only)" ]] || fail "metadata failure changed the index"
  assert_repository_unchanged "$repository" "$snapshot" "metadata validation failure"
}

test_missing_template_preserves_staging() {
  local repository="$test_root/template-failure"
  local bin_dir="$test_root/template-failure-bin"
  local temporary_dir="$test_root/template-failure-tmp"
  local output status staging_path snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  mkdir -p "$temporary_dir"
  rm -rf "$repository/hosts/templates/linux"
  snapshot=$(repository_snapshot "$repository")

  set +e
  output=$(
    cd "$repository"
    PATH="$bin_dir:$PATH" TMPDIR="$temporary_dir" \
      TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 run_onboarding </dev/null 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "missing template unexpectedly succeeded"
  staging_path=$(sed -n 's/^Candidate staging preserved at: //p' <<<"$output")
  [[ -n "$staging_path" && -d "$staging_path" ]] || fail "missing template did not preserve staging"
  assert_repository_unchanged "$repository" "$snapshot" "missing template failure"
}

test_darwin_candidate_failure_preserves_staging() {
  local repository="$test_root/darwin-evaluation-failure"
  local bin_dir="$test_root/darwin-evaluation-failure-bin"
  local temporary_dir="$test_root/darwin-evaluation-failure-tmp"
  local output status staging_path snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  mkdir -p "$temporary_dir"
  snapshot=$(repository_snapshot "$repository")

  set +e
  output=$(
    cd "$repository"
    printf 'broken-mac\nalice\nUTC\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TMPDIR="$temporary_dir" TEST_NIX_FAIL=1 \
        TEST_UNAME_S=Darwin TEST_UNAME_M=arm64 run_onboarding 2>&1
  )
  status=$?
  set -e

  [[ $status -ne 0 ]] || fail "Darwin candidate failure unexpectedly succeeded"
  [[ ! -e "$repository/hosts/broken-mac" ]] || fail "Darwin failure changed the Host inventory"
  staging_path=$(sed -n 's/^Candidate staging preserved at: //p' <<<"$output")
  [[ -n "$staging_path" && -d "$staging_path" ]] || fail "Darwin failure did not preserve staging"
  assert_file_contains "$staging_path/host.nix" 'system = "aarch64-darwin";'
  assert_repository_unchanged "$repository" "$snapshot" "Darwin candidate failure"
}

test_invalid_host_name_preserves_repository() {
  local repository="$test_root/invalid-host-name"
  local bin_dir="$test_root/invalid-host-name-bin"
  local snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  snapshot=$(repository_snapshot "$repository")

  if (
    cd "$repository"
    printf 'bad host\nalice\nUTC\nalice@example.com\nAlice\n' |
      PATH="$bin_dir:$PATH" TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 \
        run_onboarding >/dev/null 2>&1
  ); then
    fail "invalid Host name was accepted"
  fi

  assert_repository_unchanged "$repository" "$snapshot" "invalid Host name failure"
}

test_darwin_success_skips_linux_hardware_generation() {
  local repository="$test_root/darwin-success"
  local bin_dir="$test_root/darwin-bin"
  create_repository "$repository"
  create_linux_commands "$bin_dir"

  printf '#!%s\n' "$BASH" >"$bin_dir/nixos-generate-config"
  cat >>"$bin_dir/nixos-generate-config" <<'EOF'
printf 'nixos-generate-config must not run on Darwin\n' >&2
exit 99
EOF
  chmod +x "$bin_dir/nixos-generate-config"

  (
    cd "$repository"
    printf 'new-mac\nalice\nAmerica/New_York\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TEST_UNAME_S=Darwin TEST_UNAME_M=arm64 \
        run_onboarding >/dev/null
  )

  assert_file_contains "$repository/hosts/new-mac/host.nix" 'system = "aarch64-darwin";'
  [[ ! -e "$repository/hosts/new-mac/hardware-configuration.nix" ]] || fail "Darwin Host contains Linux hardware configuration"
}

test_real_cli_evaluates_complete_darwin_candidate() {
  local repository="$test_root/real-darwin-success"
  local bin_dir="$test_root/real-darwin-bin"
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  enable_real_candidate_evaluation "$repository" "$bin_dir"

  (
    cd "$repository"
    printf 'evaluated-mac\nalice\nUTC\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TEST_UNAME_S=Darwin TEST_UNAME_M=arm64 \
        run_onboarding >/dev/null
  )

  assert_file_contains "$repository/hosts/evaluated-mac/host.nix" 'system = "aarch64-darwin";'
  [[ -n "$(git -C "$repository" diff --cached --name-only -- hosts/evaluated-mac)" ]] ||
    fail "real CLI candidate evaluation did not register and stage the Host"
}

test_rejects_unsupported_current_platform() {
  local repository="$test_root/unsupported-platform"
  local bin_dir="$test_root/unsupported-platform-bin"
  local snapshot
  create_repository "$repository"
  create_linux_commands "$bin_dir"
  snapshot=$(repository_snapshot "$repository")

  if (
    cd "$repository"
    PATH="$bin_dir:$PATH" TEST_UNAME_S=Darwin TEST_UNAME_M=x86_64 \
      run_onboarding </dev/null >/dev/null 2>&1
  ); then
    fail "unsupported Darwin platform was accepted"
  fi
  assert_repository_unchanged "$repository" "$snapshot" "unsupported platform failure"
}

test_help_describes_local_transaction() {
  local output
  output=$(bash "$onboarding_script" --help)
  grep -Fq 'current machine' <<<"$output" || fail "help omits the current-machine restriction"
  grep -Fq 'stages only the new Host' <<<"$output" || fail "help omits precise staging"
  grep -Fq 'never commits' <<<"$output" || fail "help omits the no-commit guarantee"
}

test_interactive_output_keeps_wizard_guidance() {
  local repository="$test_root/wizard-output"
  local bin_dir="$test_root/wizard-output-bin"
  local output
  create_repository "$repository"
  create_linux_commands "$bin_dir"

  output=$(
    cd "$repository"
    printf 'pretty-host\nalice\nUTC\nalice@example.com\nAlice\n\n' |
      PATH="$bin_dir:$PATH" TEST_UNAME_S=Linux TEST_UNAME_M=x86_64 \
        run_onboarding 2>&1
  )

  assert_text_contains "$output" '✨ Host Inventory Setup Wizard'
  assert_text_contains "$output" '💡 Tip: Press Enter to keep the default value.'
  assert_text_contains "$output" '🖥️  Hostname'
  assert_text_contains "$output" '🔎 Please confirm your details'
  assert_text_contains "$output" '🔍 Validating the candidate configuration...'
  assert_text_contains "$output" '🎉 Registered Host pretty-host'
  assert_text_contains "$output" '🧩 Review the staged Host files before committing.'
}

test_linux_success_registers_only_new_host
test_aarch64_linux_uses_detected_system
test_candidate_failure_preserves_staging_without_inventory_changes
test_existing_host_failure_preserves_staging_without_inventory_changes
test_hardware_generation_failure_preserves_candidate
test_git_add_failure_rolls_back_registration
test_unresolved_placeholder_preserves_candidate
test_invalid_metadata_preserves_staging_before_generation
test_missing_template_preserves_staging
test_darwin_success_skips_linux_hardware_generation
test_darwin_candidate_failure_preserves_staging
test_invalid_host_name_preserves_repository
if [[ ${INVENTORY_ONBOARDING_SKIP_REAL_NIX_TEST:-0} != 1 ]]; then
  test_real_cli_evaluates_complete_darwin_candidate
fi
test_rejects_unsupported_current_platform
test_help_describes_local_transaction
test_interactive_output_keeps_wizard_guidance
printf 'inventory onboarding tests passed\n'
